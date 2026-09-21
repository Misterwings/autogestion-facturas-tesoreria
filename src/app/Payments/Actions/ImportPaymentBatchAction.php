<?php

namespace App\Payments\Actions;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\ImportError;
use App\Models\Invoice;
use App\Models\PaymentBatch;
use App\Models\PaymentReceipt;
use App\Models\ThirdPartyBankAccount;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\DTO\ParsedPaymentSheet;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\Importers\BankPaymentLineImporter;
use App\Payments\Importers\CatalogImporter;
use App\Payments\Importers\InvoiceReceiptImporter;
use App\Payments\Importers\ReceiptMatcher;
use App\Payments\Parsers\ModelSheetParser;
use App\Payments\Parsers\PaymentSheetParser;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;
use LogicException;

class ImportPaymentBatchAction
{
    public function __construct(
        private readonly ExcelWorkbookReaderFactoryInterface $readerFactory,
        private readonly ModelSheetParser $modelSheetParser,
        private readonly PaymentSheetParser $paymentSheetParser,
        private readonly CatalogImporter $catalogImporter,
        private readonly BankPaymentLineImporter $bankPaymentLineImporter,
        private readonly InvoiceReceiptImporter $invoiceReceiptImporter,
    ) {}

    public function execute(string $filePath, ?string $paymentDate = null, ?string $sourceFileName = null, ?int $importedByUserId = null): PaymentBatch
    {
        $sourceFileHash = is_file($filePath) ? hash_file('sha256', $filePath) : null;
        if ($sourceFileHash !== null) {
            $existingBatch = PaymentBatch::query()->where('source_file_hash', $sourceFileHash)->first();
            if ($existingBatch !== null) {
                throw new LogicException("This payment file was already imported as batch #{$existingBatch->id}.");
            }
        }

        $reader = $this->readerFactory->open($filePath);
        $sheetNames = $reader->sheetNames();
        $hasModelSheet = in_array('MODELO', $sheetNames, true);
        $modelThirdParties = $hasModelSheet ? $this->modelSheetParser->parse($reader->rows('MODELO')) : [];
        $paymentSheets = $this->parsePaymentSheets($reader, $sheetNames);
        if ($paymentSheets === []) {
            throw new InvalidArgumentException('The workbook contains none of the configured payment sheets.');
        }

        $hasPaymentData = collect($paymentSheets)->contains(
            fn (ParsedPaymentSheet $sheet): bool => $sheet->bankPaymentLines !== [] || $sheet->paymentReceipts !== [],
        );
        if (! $hasPaymentData) {
            throw new InvalidArgumentException('The workbook contains no valid payment records.');
        }

        $paymentDate ??= $this->firstPaymentDate($paymentSheets);

        $batch = DB::transaction(function () use ($filePath, $sourceFileHash, $paymentDate, $sourceFileName, $importedByUserId, $hasModelSheet, $modelThirdParties, $paymentSheets): PaymentBatch {
            $batch = PaymentBatch::create([
                'source_file_name' => $sourceFileName ?? basename($filePath),
                'source_file_path' => realpath($filePath) ?: $filePath,
                'source_file_hash' => $sourceFileHash,
                'payment_date' => $paymentDate,
                'has_model_sheet' => $hasModelSheet,
                'status' => 'importing',
                'imported_by_user_id' => $importedByUserId,
            ]);

            foreach ($modelThirdParties as $thirdParty) {
                $this->catalogImporter->importModelThirdParty($thirdParty);
            }

            foreach ($paymentSheets as $paymentSheet) {
                $this->importPaymentSheet($batch, $paymentSheet, $paymentDate);
            }

            $this->refreshBatchTotals($batch);

            return $batch->refresh();
        });

        Log::info('Payment batch imported', [
            'batch_id' => $batch->id,
            'source_hash' => $sourceFileHash,
            'status' => $batch->status,
            'bank_lines' => $batch->bank_payment_lines_count,
            'receipts' => $batch->receipts_count,
            'invoices' => $batch->invoices_count,
            'warnings' => $batch->importErrors()->count(),
            'actor_id' => $importedByUserId,
        ]);

        return $batch;
    }

    /**
     * @param  list<string>  $sheetNames
     * @return list<ParsedPaymentSheet>
     */
    private function parsePaymentSheets($reader, array $sheetNames): array
    {
        $configuredSheets = config('payment_import.branch_sheets', []);
        $parsedSheets = [];

        foreach ($configuredSheets as $sheetName) {
            if (in_array($sheetName, $sheetNames, true)) {
                $parsedSheets[] = $this->paymentSheetParser->parse($reader, $sheetName);
            }
        }

        return $parsedSheets;
    }

    private function importPaymentSheet(PaymentBatch $batch, ParsedPaymentSheet $paymentSheet, ?string $effectivePaymentDate): void
    {
        $branch = Branch::firstOrCreate(['name' => $paymentSheet->sheetName]);
        $this->recordParserWarnings($batch, $paymentSheet);
        $bankPaymentLines = $this->bankPaymentLineImporter->importMany($batch, $branch, $paymentSheet->bankPaymentLines);

        if ($bankPaymentLines->isEmpty()) {
            foreach ($paymentSheet->paymentReceipts as $receipt) {
                $paymentReceipt = $this->invoiceReceiptImporter->import($batch, $branch, $receipt, null, $effectivePaymentDate);
                $this->createFallbackBankPaymentLine($batch, $branch, $paymentReceipt);
            }

            return;
        }

        $bankPaymentLines->each(fn (BankPaymentLine $line) => $line->loadMissing('thirdParty'));
        $matcher = new ReceiptMatcher($bankPaymentLines);

        foreach ($paymentSheet->paymentReceipts as $receipt) {
            $matchedLine = $matcher->match($receipt);
            $this->recordMatchFailure($batch, $receipt, $matcher->lastFailure());
            $this->invoiceReceiptImporter->import($batch, $branch, $receipt, $matchedLine, $effectivePaymentDate);
        }

        foreach ($matcher->unmatchedLines() as $line) {
            $this->recordUnmatchedBankLine($batch, $line);
        }
    }

    private function recordParserWarnings(PaymentBatch $batch, ParsedPaymentSheet $sheet): void
    {
        foreach ($sheet->warnings as $warning) {
            ImportError::create([
                'payment_batch_id' => $batch->id,
                'severity' => $warning['severity'] ?? 'warning',
                'code' => $warning['code'],
                'message' => $warning['message'],
                'source_sheet' => $sheet->sheetName,
                'source_row' => $warning['row'] ?? null,
            ]);
        }
    }

    /** @param array{code: string, message: string}|null $failure */
    private function recordMatchFailure(PaymentBatch $batch, PaymentReceiptData $receipt, ?array $failure): void
    {
        if ($failure === null) {
            return;
        }

        ImportError::create([
            'payment_batch_id' => $batch->id,
            'severity' => 'warning',
            'code' => $failure['code'],
            'message' => $failure['message'],
            'source_sheet' => $receipt->sourceSheet,
            'source_row' => $receipt->sourceRow,
        ]);
    }

    private function recordUnmatchedBankLine(PaymentBatch $batch, BankPaymentLine $line): void
    {
        ImportError::create([
            'payment_batch_id' => $batch->id,
            'severity' => 'warning',
            'code' => 'bank_payment_line_without_invoice_detail',
            'message' => "Bank payment line for {$line->nit} was imported without invoice detail.",
            'source_sheet' => $line->source_sheet,
            'source_row' => $line->source_row,
        ]);
    }

    private function createFallbackBankPaymentLine(PaymentBatch $batch, Branch $branch, PaymentReceipt $receipt): void
    {
        $receipt->loadMissing('thirdParty');

        if ($receipt->thirdParty === null) {
            $this->recordFallbackBankLineFailure(
                $batch,
                $receipt,
                'bank_payment_line_missing_third_party',
                "Receipt {$receipt->receipt_number} could not generate a bank line because no third party was resolved.",
            );

            return;
        }

        $account = $this->primaryActiveAccount($receipt);

        if ($account === null) {
            $this->recordFallbackBankLineFailure(
                $batch,
                $receipt,
                'bank_payment_line_missing_primary_account',
                "Receipt {$receipt->receipt_number} could not generate a bank line because {$receipt->thirdParty->document_number} has no active primary bank account.",
            );

            return;
        }

        BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $receipt->thirdParty->id,
            'bank_id' => $account->bank_id,
            'payment_receipt_id' => $receipt->id,
            'nit' => $receipt->thirdParty->document_number,
            'person_type' => $receipt->thirdParty->person_type,
            'bank_account_number' => $account->account_number,
            'bank_account_type' => $account->account_type,
            'bank_code' => $account->bank->code,
            'third_party_name' => $receipt->thirdParty->name,
            'amount' => $receipt->amount,
            'source_sheet' => $receipt->source_sheet,
            'source_row' => $receipt->source_row,
            'has_invoice_detail' => true,
        ]);

        $receipt->update([
            'beneficiary_document_number' => $receipt->thirdParty->document_number,
            'beneficiary_name' => $receipt->thirdParty->name,
            'beneficiary_person_type' => $receipt->thirdParty->person_type,
            'beneficiary_bank_name' => $account->bank->name,
            'beneficiary_bank_code' => $account->bank->code,
            'beneficiary_account_number' => $account->account_number,
            'beneficiary_account_type' => $account->account_type,
        ]);
    }

    private function primaryActiveAccount(PaymentReceipt $receipt): ?ThirdPartyBankAccount
    {
        return $receipt->thirdParty
            ->bankAccounts()
            ->where('is_primary', true)
            ->where('is_active', true)
            ->with('bank')
            ->first();
    }

    private function recordFallbackBankLineFailure(PaymentBatch $batch, PaymentReceipt $receipt, string $code, string $message): void
    {
        ImportError::create([
            'payment_batch_id' => $batch->id,
            'severity' => 'warning',
            'code' => $code,
            'message' => $message,
            'source_sheet' => $receipt->source_sheet,
            'source_row' => $receipt->source_row,
        ]);
    }

    /** @param list<ParsedPaymentSheet> $paymentSheets */
    private function firstPaymentDate(array $paymentSheets): ?string
    {
        foreach ($paymentSheets as $paymentSheet) {
            foreach ($paymentSheet->paymentReceipts as $receipt) {
                if ($receipt->paymentDate !== null) {
                    return $receipt->paymentDate;
                }
            }
        }

        return null;
    }

    private function refreshBatchTotals(PaymentBatch $batch): void
    {
        $requiresReview = $batch->importErrors()->exists();

        $batch->update([
            'status' => $requiresReview ? 'needs_review' : 'validated',
            'bank_payment_lines_count' => $batch->bankPaymentLines()->count(),
            'receipts_count' => $batch->paymentReceipts()->count(),
            'invoices_count' => $batch->invoices()->count(),
            'bank_payment_total' => $batch->bankPaymentLines()->sum('amount'),
            'invoice_total' => Invoice::query()->where('payment_batch_id', $batch->id)->sum('amount'),
            'imported_at' => now(),
        ]);
    }
}
