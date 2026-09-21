<?php

namespace Tests\Feature;

use App\Models\Bank;
use App\Models\Branch;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Payments\Actions\GenerateBankPaymentFileAction;
use App\Payments\Actions\ImportPaymentBatchAction;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Contracts\ExcelWorkbookReaderInterface;
use App\Payments\DTO\SpreadsheetRow;
use Generator;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PaymentImportActionTest extends TestCase
{
    use RefreshDatabase;

    public function test_import_uses_model_sheet_before_branch_bank_lines_without_overwriting_primary_account(): void
    {
        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MODELO' => [
                new SpreadsheetRow(1, []),
                new SpreadsheetRow(2, [
                    1 => '9001',
                    2 => '1',
                    3 => 'MODELACC',
                    4 => 'CA',
                    5 => '007',
                    6 => 'Banco Modelo',
                    7 => 'Proveedor Modelo',
                ]),
            ],
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => 'DOC-1',
                    4 => 'Proveedor Modelo',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                    9 => '9001',
                    10 => '1',
                    11 => 'BANKLINEACC',
                    12 => 'CC',
                    13 => '051',
                    14 => '1000',
                    15 => 'Proveedor Modelo',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $thirdParty = ThirdParty::where('document_number', '9001')->firstOrFail();

        $this->assertTrue($batch->has_model_sheet);
        $this->assertSame('Proveedor Modelo', $thirdParty->name);
        $this->assertSame('MODELACC', $thirdParty->primaryBankAccount()->first()?->account_number);
        $this->assertDatabaseHas('third_party_bank_accounts', [
            'third_party_id' => $thirdParty->id,
            'account_number' => 'BANKLINEACC',
            'account_type' => 'CC',
            'is_primary' => 0,
        ]);
        $this->assertDatabaseHas('bank_payment_lines', [
            'payment_batch_id' => $batch->id,
            'nit' => '9001',
            'bank_account_number' => 'BANKLINEACC',
            'has_invoice_detail' => 1,
        ]);
        $this->assertDatabaseHas('payment_receipts', [
            'payment_batch_id' => $batch->id,
            'beneficiary_document_number' => '9001',
            'beneficiary_name' => 'Proveedor Modelo',
            'beneficiary_bank_code' => '051',
            'beneficiary_account_number' => 'BANKLINEACC',
            'beneficiary_account_type' => 'CC',
        ]);
    }

    public function test_import_builds_bank_lines_from_catalog_when_branch_sheet_has_no_bank_block(): void
    {
        Storage::fake('local');

        $bank = Bank::create(['code' => '007', 'name' => 'Banco Catalogo']);
        $thirdParty = ThirdParty::create([
            'document_number' => '90014',
            'person_type' => '1',
            'name' => 'Proveedor Catalogo',
            'alternate_name' => 'Proveedor con nombre distinto en Excel',
        ]);
        ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => '123456789',
            'account_type' => 'CA',
            'is_primary' => true,
            'is_active' => true,
        ]);

        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => '9001',
                    4 => 'Proveedor con nombre distinto en Excel',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');
        app(GenerateBankPaymentFileAction::class)->execute($batch);

        $branch = Branch::where('name', 'MERCADEO')->firstOrFail();
        $receipt = $batch->paymentReceipts()->firstOrFail();
        $branchFilePath = "bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-mercadeo.txt";

        $this->assertDatabaseHas('bank_payment_lines', [
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'payment_receipt_id' => $receipt->id,
            'nit' => '90014',
            'person_type' => '1',
            'bank_account_number' => '123456789',
            'bank_account_type' => 'CA',
            'bank_code' => '007',
            'has_invoice_detail' => 1,
        ]);
        $this->assertDatabaseMissing('import_errors', [
            'payment_batch_id' => $batch->id,
            'code' => 'bank_payment_line_not_found',
        ]);
        $this->assertSame([
            (string) $branch->id => $branchFilePath,
        ], $batch->refresh()->branch_file_paths);
        Storage::disk('local')->assertExists($branchFilePath);
        $this->assertSame("90014\t1\t123456789\tCA\t007\t1000\n", Storage::disk('local')->get($branchFilePath));
    }

    public function test_import_warns_when_fallback_has_no_primary_bank_account(): void
    {
        ThirdParty::create([
            'document_number' => '9002',
            'person_type' => '1',
            'name' => 'Proveedor Sin Cuenta',
        ]);

        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => 'DOC-1',
                    4 => 'Proveedor Sin Cuenta',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertDatabaseCount('bank_payment_lines', 0);
        $this->assertDatabaseHas('import_errors', [
            'payment_batch_id' => $batch->id,
            'code' => 'bank_payment_line_missing_primary_account',
            'source_sheet' => 'MERCADEO',
            'source_row' => 8,
        ]);
        $this->assertDatabaseMissing('import_errors', [
            'payment_batch_id' => $batch->id,
            'code' => 'bank_payment_line_not_found',
        ]);
    }

    public function test_import_resolves_invoice_third_party_by_alternate_name_when_no_bank_line_exists(): void
    {
        $thirdParty = ThirdParty::create([
            'document_number' => '9002',
            'person_type' => '1',
            'name' => 'Proveedor Principal',
            'alternate_name' => 'Proveedor Alterno',
        ]);

        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => 'DOC-1',
                    4 => 'Proveedor Alterno',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                    8 => 'Pago proveedor',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertDatabaseHas('payment_receipts', [
            'payment_batch_id' => $batch->id,
            'third_party_id' => $thirdParty->id,
            'receipt_number' => 'PEL-1',
        ]);
        $this->assertDatabaseHas('invoices', [
            'payment_batch_id' => $batch->id,
            'third_party_id' => $thirdParty->id,
            'third_party_name' => 'Proveedor Alterno',
        ]);
    }

    public function test_import_resolves_nit_without_check_digit_when_catalog_name_matches(): void
    {
        $thirdParty = ThirdParty::create([
            'document_number' => '9000402990',
            'person_type' => '1',
            'name' => 'ATLANTIC FS SAS / NUEVA CUENTA',
        ]);

        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => '900040299',
                    4 => 'ATLANTIC FS S.A.S.',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertDatabaseHas('payment_receipts', [
            'payment_batch_id' => $batch->id,
            'third_party_id' => $thirdParty->id,
            'receipt_number' => 'PEL-1',
        ]);
    }

    public function test_import_does_not_resolve_nit_without_check_digit_when_name_differs(): void
    {
        ThirdParty::create([
            'document_number' => '9000402990',
            'person_type' => '1',
            'name' => 'ATLANTIC FS SAS',
        ]);

        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '45123',
                    3 => '900040299',
                    4 => 'PROVEEDOR DIFERENTE',
                    5 => 'SOP-1',
                    6 => 'CAU-1',
                    7 => '1000',
                ]),
                new SpreadsheetRow(8, [
                    2 => 'PEL-1',
                    7 => '1000',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertDatabaseHas('payment_receipts', [
            'payment_batch_id' => $batch->id,
            'third_party_id' => null,
            'receipt_number' => 'PEL-1',
        ]);
        $this->assertDatabaseHas('import_errors', [
            'payment_batch_id' => $batch->id,
            'code' => 'bank_payment_line_missing_third_party',
        ]);
    }

    public function test_import_recognizes_prefixed_pel_receipt_number(): void
    {
        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '46212',
                    3 => '16720297',
                    4 => 'GARRIDO ALBERTO',
                    5 => '005-DSF746-00000000-000',
                    6 => '005-DSF-00000746',
                    7 => '577065',
                ]),
                new SpreadsheetRow(8, [
                    2 => '005-PEL-02607006',
                    7 => '577065',
                    8 => 'Habladores',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertDatabaseHas('payment_receipts', [
            'payment_batch_id' => $batch->id,
            'receipt_number' => '005-PEL-02607006',
            'amount' => '577065.00',
        ]);
        $this->assertSame(1, $batch->receipts_count);
        $this->assertSame(1, $batch->invoices_count);
    }

    public function test_import_includes_negative_credit_notes_in_invoice_total(): void
    {
        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, new FakeExcelWorkbookReaderFactory([
            'MERCADEO' => [
                new SpreadsheetRow(7, [
                    2 => '46212',
                    3 => '830074144',
                    4 => 'GLOBAL WINE & SPIRITS LTDA',
                    5 => '001-NIF-1',
                    6 => '001-NIF-1',
                    7 => '-250',
                    8 => 'Nota credito',
                ]),
                new SpreadsheetRow(8, [
                    2 => '46212',
                    3 => '830074144',
                    4 => 'GLOBAL WINE & SPIRITS LTDA',
                    5 => '001-FAC-1',
                    6 => '001-FAC-1',
                    7 => '1000',
                ]),
                new SpreadsheetRow(9, [
                    2 => '001-PEL-1',
                    7 => '750',
                ]),
                new SpreadsheetRow(10, [
                    2 => 'Gran total',
                    7 => '750',
                ]),
            ],
        ]));

        $batch = app(ImportPaymentBatchAction::class)->execute('fake.xlsx');

        $this->assertSame('750.00', $batch->invoice_total);
        $this->assertSame(2, $batch->invoices_count);
        $this->assertDatabaseHas('invoices', [
            'payment_batch_id' => $batch->id,
            'amount' => '-250.00',
        ]);
        $this->assertDatabaseMissing('import_errors', [
            'payment_batch_id' => $batch->id,
            'code' => 'receipt_amount_differs_from_invoice_total',
        ]);
    }
}

class FakeExcelWorkbookReaderFactory implements ExcelWorkbookReaderFactoryInterface
{
    /** @param array<string, list<SpreadsheetRow>> $rowsBySheet */
    public function __construct(private readonly array $rowsBySheet) {}

    public function open(string $path): ExcelWorkbookReaderInterface
    {
        return new FakeExcelWorkbookReader($this->rowsBySheet);
    }
}

class FakeExcelWorkbookReader implements ExcelWorkbookReaderInterface
{
    /** @param array<string, list<SpreadsheetRow>> $rowsBySheet */
    public function __construct(private readonly array $rowsBySheet) {}

    public function sheetNames(): array
    {
        return array_keys($this->rowsBySheet);
    }

    public function rows(string $sheetName): Generator
    {
        foreach ($this->rowsBySheet[$sheetName] ?? [] as $row) {
            yield $row;
        }
    }
}
