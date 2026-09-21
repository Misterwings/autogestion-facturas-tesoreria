<?php

namespace App\Payments\Importers;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\ImportError;
use App\Models\Invoice;
use App\Models\PaymentBatch;
use App\Models\PaymentReceipt;
use App\Models\ThirdParty;
use App\Payments\DTO\InvoiceData;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\Support\ThirdPartyName;

class InvoiceReceiptImporter
{
    public function import(PaymentBatch $batch, Branch $branch, PaymentReceiptData $data, ?BankPaymentLine $bankPaymentLine, ?string $effectivePaymentDate = null): PaymentReceipt
    {
        $thirdPartyId = $bankPaymentLine?->third_party_id
            ?? $this->resolveThirdPartyId($batch, $data);

        $thirdParty = $thirdPartyId !== null ? ThirdParty::find($thirdPartyId) : null;
        $bankPaymentLine?->loadMissing('bank');

        $receipt = PaymentReceipt::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdPartyId,
            'beneficiary_document_number' => $bankPaymentLine?->nit ?? $thirdParty?->document_number,
            'beneficiary_name' => $bankPaymentLine?->third_party_name ?? $thirdParty?->name,
            'beneficiary_person_type' => $bankPaymentLine?->person_type ?? $thirdParty?->person_type,
            'beneficiary_bank_name' => $bankPaymentLine?->bank?->name,
            'beneficiary_bank_code' => $bankPaymentLine?->bank_code,
            'beneficiary_account_number' => $bankPaymentLine?->bank_account_number,
            'beneficiary_account_type' => $bankPaymentLine?->bank_account_type,
            'receipt_number' => $data->receiptNumber,
            'payment_date' => $effectivePaymentDate ?? $data->paymentDate,
            'amount' => $data->amount,
            'concept' => $data->concept,
            'source_sheet' => $data->sourceSheet,
            'source_row' => $data->sourceRow,
            'warnings' => $data->warnings,
        ]);

        foreach ($data->invoices as $invoice) {
            $this->importInvoice($batch, $branch, $receipt, $invoice, $thirdPartyId, $effectivePaymentDate);
        }

        if ($bankPaymentLine !== null) {
            $bankPaymentLine->update([
                'payment_receipt_id' => $receipt->id,
                'has_invoice_detail' => true,
            ]);
        }

        foreach ($data->warnings as $warning) {
            ImportError::create([
                'payment_batch_id' => $batch->id,
                'severity' => 'warning',
                'code' => $warning,
                'message' => "Receipt {$data->receiptNumber} produced warning: {$warning}.",
                'source_sheet' => $data->sourceSheet,
                'source_row' => $data->sourceRow,
            ]);
        }

        return $receipt;
    }

    private function importInvoice(
        PaymentBatch $batch,
        Branch $branch,
        PaymentReceipt $receipt,
        InvoiceData $data,
        ?int $thirdPartyId,
        ?string $effectivePaymentDate,
    ): Invoice {
        return Invoice::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'payment_receipt_id' => $receipt->id,
            'third_party_id' => $thirdPartyId ?? $this->resolveInvoiceThirdPartyId($batch, $data),
            'payment_date' => $effectivePaymentDate ?? $data->paymentDate,
            'detail_document_number' => $data->detailDocumentNumber,
            'third_party_name' => $data->thirdPartyName,
            'support_document' => $data->supportDocument,
            'causation_document' => $data->causationDocument,
            'amount' => $data->amount,
            'concept' => $data->concept,
            'source_sheet' => $data->sourceSheet,
            'source_row' => $data->sourceRow,
        ]);
    }

    private function resolveThirdPartyId(PaymentBatch $batch, PaymentReceiptData $data): ?int
    {
        foreach ($data->invoices as $invoice) {
            $id = $this->resolveInvoiceThirdPartyId($batch, $invoice);
            if ($id !== null) {
                return $id;
            }
        }

        return null;
    }

    private function resolveInvoiceThirdPartyId(PaymentBatch $batch, InvoiceData $data): ?int
    {
        return $this->resolveThirdPartyIdByDocumentNumber($data->detailDocumentNumber, $data->thirdPartyName)
            ?? $this->resolveThirdPartyIdByName($data->thirdPartyName, $batch, $data->sourceSheet, $data->sourceRow);
    }

    private function resolveThirdPartyIdByDocumentNumber(string $documentNumber, string $thirdPartyName): ?int
    {
        if ($documentNumber === '') {
            return null;
        }

        $thirdPartyId = ThirdParty::query()
            ->where('document_number', $documentNumber)
            ->value('id');

        if ($thirdPartyId !== null || ! ctype_digit($documentNumber)) {
            return $thirdPartyId;
        }

        $matches = ThirdParty::query()
            ->where('document_number', 'like', $documentNumber.'%')
            ->limit(10)
            ->get(['id', 'document_number', 'name', 'alternate_name'])
            ->filter(fn (ThirdParty $thirdParty): bool => preg_match('/^'.preg_quote($documentNumber, '/').'\d$/', $thirdParty->document_number) === 1)
            ->values();

        if ($matches->count() !== 1) {
            return null;
        }

        $thirdParty = $matches->first();

        return ThirdPartyName::matches($thirdPartyName, $thirdParty->name, $thirdParty->alternate_name)
            ? $thirdParty->id
            : null;
    }

    private function resolveThirdPartyIdByName(?string $name, PaymentBatch $batch, ?string $sourceSheet, ?int $sourceRow): ?int
    {
        $name = trim((string) $name);

        if ($name === '') {
            return null;
        }

        $matches = ThirdParty::query()
            ->whereRaw('LOWER(name) = ?', [mb_strtolower($name)])
            ->orWhereRaw('LOWER(alternate_name) = ?', [mb_strtolower($name)])
            ->limit(2)
            ->get();

        if ($matches->count() === 1) {
            return $matches->first()->id;
        }

        if ($matches->count() > 1) {
            ImportError::create([
                'payment_batch_id' => $batch->id,
                'severity' => 'warning',
                'code' => 'ambiguous_third_party_name_match',
                'message' => "Third-party name {$name} matched more than one catalog record.",
                'source_sheet' => $sourceSheet,
                'source_row' => $sourceRow,
            ]);
        }

        return null;
    }
}
