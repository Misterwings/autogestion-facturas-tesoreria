<?php

use App\Models\Bank;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Models\User;
use App\Payments\Actions\GenerateBankPaymentFileAction;
use App\Payments\Actions\ImportPaymentBatchAction;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Importers\CatalogImporter;
use App\Payments\Parsers\ModelSheetParser;
use App\Payments\Parsers\PaymentSheetParser;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('admin:user {email : Admin email} {--name=Admin : Admin name} {--password= : Admin password}', function () {
    $password = $this->option('password');

    if (! is_string($password) || $password === '') {
        $password = $this->secret('Password');
    }

    if (! is_string($password) || strlen($password) < 8) {
        $this->error('Password must be at least 8 characters.');

        return 1;
    }

    $user = User::updateOrCreate(
        ['email' => (string) $this->argument('email')],
        [
            'name' => (string) $this->option('name'),
            'password' => $password,
        ],
    );

    $this->info("Admin user ready: {$user->email}");
})->purpose('Create or update an admin user for the protected web panel');

Artisan::command('payments:seed-catalog {file : Path to an Excel file containing a MODELO sheet} {--clear : Remove existing catalog data before seeding}', function (CatalogImporter $catalogImporter, ModelSheetParser $modelSheetParser, ExcelWorkbookReaderFactoryInterface $readerFactory) {
    $file = (string) $this->argument('file');

    $reader = $readerFactory->open($file);
    $sheetNames = $reader->sheetNames();

    if (! in_array('MODELO', $sheetNames, true)) {
        $this->error('The file does not contain a MODELO sheet.');

        return;
    }

    $modelThirdParties = $modelSheetParser->parse($reader->rows('MODELO'));

    if (count($modelThirdParties) === 0) {
        $this->error('No third parties found in the MODELO sheet.');

        return;
    }

    DB::transaction(function () use ($modelThirdParties, $catalogImporter): void {
        if ($this->option('clear')) {
            $this->warn('Clearing existing catalog data...');
            ThirdPartyBankAccount::query()->delete();
            ThirdParty::query()->delete();
            Bank::query()->delete();
        }

        foreach ($modelThirdParties as $thirdParty) {
            $catalogImporter->importModelThirdParty($thirdParty);
        }
    });

    $this->info('Catalog seeded: '.count($modelThirdParties).' third-party records from MODELO.');
    $this->line('Third parties: '.ThirdParty::count());
    $this->line('Banks: '.Bank::count());
    $this->line('Bank accounts: '.ThirdPartyBankAccount::count());
})->purpose('Pre-seed third-party and bank catalog from a MODELO sheet before importing payment files');

Artisan::command('payments:import {file : Path to the weekly payment Excel file} {--date= : Payment date in Y-m-d format} {--no-bank-file : Import without generating bank TXT files} {--approve-warnings : Explicitly approve a batch with warnings and generate its bank files}', function (ImportPaymentBatchAction $importer, GenerateBankPaymentFileAction $bankFileGenerator) {
    $file = (string) $this->argument('file');
    $date = $this->option('date') !== null ? (string) $this->option('date') : null;
    if ($date !== null && CarbonImmutable::createFromFormat('!Y-m-d', $date)?->format('Y-m-d') !== $date) {
        $this->error('The --date option must use the Y-m-d format.');

        return 1;
    }

    $batch = $importer->execute($file, $date);

    $canGenerate = $batch->status === 'validated' || ($batch->status === 'needs_review' && $this->option('approve-warnings'));
    if (! $this->option('no-bank-file') && $canGenerate) {
        $batch->update(['status' => 'approved', 'approved_at' => now()]);
        $bankFileGenerator->execute($batch);
        $batch->refresh();
    } elseif (! $this->option('no-bank-file') && $batch->status === 'needs_review') {
        $this->warn('The batch requires review. Re-run with --approve-warnings or approve it in the web panel.');
    }

    $this->info("Imported payment batch #{$batch->id}");
    $this->line("Payment date: {$batch->payment_date?->toDateString()}");
    $this->line("Bank lines: {$batch->bank_payment_lines_count} ({$batch->bank_payment_total})");
    $this->line("Receipts: {$batch->receipts_count}");
    $this->line("Invoices: {$batch->invoices_count} ({$batch->invoice_total})");

    if ($batch->bank_file_path !== null) {
        $this->line("Consolidated file: storage/app/private/{$batch->bank_file_path}");
    }
    if ($batch->granada_file_path !== null) {
        $this->line("Granada file: storage/app/private/{$batch->granada_file_path}");
    }
    if (($batch->branch_file_paths ?? []) !== []) {
        $branchNames = Branch::query()->whereIn('id', array_keys($batch->branch_file_paths))->pluck('name', 'id');

        foreach ($batch->branch_file_paths as $branchId => $path) {
            $branchName = $branchNames[(int) $branchId] ?? "Branch {$branchId}";
            $this->line("{$branchName} file: storage/app/private/{$path}");
        }
    }
})->purpose('Import a weekly payment Excel file and generate the consolidated bank TXT');

Artisan::command('payments:bank-file {batch : Payment batch id}', function (GenerateBankPaymentFileAction $bankFileGenerator) {
    $batch = PaymentBatch::findOrFail((int) $this->argument('batch'));
    $bankFileGenerator->execute($batch);
    $batch->refresh();

    $this->info("Generated bank files for payment batch #{$batch->id}");
    if ($batch->bank_file_path !== null) {
        $this->line("Consolidated: storage/app/private/{$batch->bank_file_path}");
    }
    if ($batch->granada_file_path !== null) {
        $this->line("Granada: storage/app/private/{$batch->granada_file_path}");
    }
    if (($batch->branch_file_paths ?? []) !== []) {
        $branchNames = Branch::query()->whereIn('id', array_keys($batch->branch_file_paths))->pluck('name', 'id');

        foreach ($batch->branch_file_paths as $branchId => $path) {
            $branchName = $branchNames[(int) $branchId] ?? "Branch {$branchId}";
            $this->line("{$branchName}: storage/app/private/{$path}");
        }
    }
})->purpose('Regenerate the consolidated bank TXT for an imported payment batch');

Artisan::command('payments:inspect {file : Path to the payment Excel file} {--sheet=MERCADEO} {--all : Summarize every configured payment sheet} {--from=1 : First row to display} {--limit=10 : Number of rows to display}', function (ExcelWorkbookReaderFactoryInterface $readerFactory, PaymentSheetParser $paymentSheetParser) {
    $reader = $readerFactory->open((string) $this->argument('file'));
    $sheet = (string) $this->option('sheet');

    $this->line('Sheets: '.implode(', ', array_slice($reader->sheetNames(), 0, 12)));

    if ($this->option('all')) {
        $availableSheets = $reader->sheetNames();
        $summary = [];

        foreach (config('payment_import.branch_sheets', []) as $configuredSheet) {
            if (! in_array($configuredSheet, $availableSheets, true)) {
                continue;
            }

            $parsedSheet = $paymentSheetParser->parse($reader, $configuredSheet);
            $summary[] = [
                $configuredSheet,
                count($parsedSheet->bankPaymentLines),
                count($parsedSheet->paymentReceipts),
                count($parsedSheet->warnings),
                implode(', ', array_unique(array_column($parsedSheet->warnings, 'code'))),
            ];
        }

        $this->newLine();
        $this->table(['Sheet', 'Bank lines', 'Receipts', 'Warnings', 'Warning codes'], $summary);

        return;
    }

    $count = 0;
    $from = max(1, (int) $this->option('from'));
    $limit = max(1, (int) $this->option('limit'));
    foreach ($reader->rows($sheet) as $row) {
        if ($row->number < $from) {
            continue;
        }

        $this->line(json_encode([
            'row' => $row->number,
            'b' => $row->value(2),
            'c' => $row->value(3),
            'd' => $row->value(4),
            'e' => $row->value(5),
            'f' => $row->value(6),
            'g' => $row->value(7),
            'h' => $row->value(8),
            'i' => $row->value(9),
            'j' => $row->value(10),
            'k' => $row->value(11),
            'l' => $row->value(12),
            'm' => $row->value(13),
            'n' => $row->value(14),
            'o' => $row->value(15),
        ], JSON_UNESCAPED_UNICODE));

        if (++$count >= $limit) {
            break;
        }
    }

    $parsed = $paymentSheetParser->parse($reader, $sheet);
    $this->newLine();
    $this->line('Parsed bank lines: '.count($parsed->bankPaymentLines));
    $this->line('Parsed receipts: '.count($parsed->paymentReceipts));
    $this->line('Parser warnings: '.count($parsed->warnings));
    if ($parsed->warnings !== []) {
        $this->table(
            ['Row', 'Code', 'Message'],
            array_map(
                fn (array $warning): array => [
                    $warning['row'] ?? '',
                    $warning['code'],
                    $warning['message'],
                ],
                $parsed->warnings,
            ),
        );
    }
})->purpose('Inspect sheet names and sample rows from a payment Excel file');
