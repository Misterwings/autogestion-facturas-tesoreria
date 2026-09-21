<?php

namespace Tests\Feature;

use App\Models\Bank;
use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Models\User;
use App\Payments\Actions\ImportPaymentBatchAction;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Contracts\ExcelWorkbookReaderInterface;
use App\Payments\DTO\InvoiceData;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\DTO\SpreadsheetRow;
use App\Payments\Formatters\TabDelimitedBankPaymentFileFormatter;
use App\Payments\Importers\ReceiptMatcher;
use App\Payments\Support\Money;
use Generator;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use InvalidArgumentException;
use LogicException;
use RuntimeException;
use Tests\TestCase;

class PaymentWorkflowHardeningTest extends TestCase
{
    use RefreshDatabase;

    public function test_single_amount_match_requires_matching_third_party_identity(): void
    {
        $batch = PaymentBatch::create(['source_file_name' => 'payments.xlsx', 'status' => 'imported']);
        $branch = Branch::create(['name' => 'MERCADEO']);
        $thirdParty = ThirdParty::create([
            'document_number' => '9001',
            'person_type' => '1',
            'name' => 'Proveedor Alpha',
        ]);
        $line = BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdParty->id,
            'nit' => '9001',
            'person_type' => '1',
            'bank_account_number' => '123',
            'bank_account_type' => 'CA',
            'bank_code' => '007',
            'third_party_name' => 'Proveedor Alpha',
            'amount' => '1000.00',
            'source_sheet' => 'MERCADEO',
            'source_row' => 7,
        ]);
        $receipt = new PaymentReceiptData(
            sourceSheet: 'MERCADEO',
            sourceRow: 8,
            receiptNumber: 'PEL-1',
            paymentDate: '2026-08-01',
            amount: '1000.00',
            concept: null,
            invoices: [new InvoiceData(
                sourceSheet: 'MERCADEO',
                sourceRow: 7,
                paymentDate: '2026-08-01',
                detailDocumentNumber: 'OTHER',
                thirdPartyName: 'Proveedor Beta',
                supportDocument: 'SUP-1',
                causationDocument: 'CAU-1',
                amount: '1000.00',
                concept: null,
            )],
        );
        $matcher = new ReceiptMatcher(collect([$line]));

        $this->assertNull($matcher->match($receipt));
        $this->assertSame('bank_payment_line_identity_mismatch', $matcher->lastFailure()['code']);
    }

    public function test_same_source_file_cannot_be_imported_twice(): void
    {
        $path = storage_path('framework/testing/idempotency.xlsx');
        file_put_contents($path, 'same workbook bytes');

        $rows = [
            'MERCADEO' => [new SpreadsheetRow(7, [
                9 => '9001',
                10 => '1',
                11 => '123',
                12 => 'CA',
                13 => '007',
                14 => '1000',
                15 => 'Proveedor Alpha',
            ])],
        ];
        $this->app->instance(ExcelWorkbookReaderFactoryInterface::class, $this->readerFactory($rows));

        try {
            app(ImportPaymentBatchAction::class)->execute($path);

            $this->expectException(LogicException::class);
            app(ImportPaymentBatchAction::class)->execute($path);
        } finally {
            @unlink($path);
        }
    }

    public function test_admin_can_approve_reviewed_batch_and_generate_files(): void
    {
        Storage::fake('local');
        $user = User::factory()->create();
        $batch = PaymentBatch::create(['source_file_name' => 'payments.xlsx', 'status' => 'needs_review']);
        $branch = Branch::create(['name' => 'OFICINA']);
        BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'nit' => '9001',
            'person_type' => '1',
            'bank_account_number' => '123',
            'bank_account_type' => 'CA',
            'bank_code' => '007',
            'amount' => '1000.00',
            'source_sheet' => 'OFICINA',
            'source_row' => 7,
        ]);

        $this->actingAs($user)
            ->withSession(['_token' => 'test-token'])
            ->post("/admin/imports/{$batch->id}/approve", ['_token' => 'test-token'])
            ->assertRedirect();

        $batch->refresh();
        $this->assertSame('ready', $batch->status);
        $this->assertSame($user->id, $batch->approved_by_user_id);
        $this->assertNotNull($batch->approved_at);
        $this->assertNotNull($batch->bank_file_checksum);
        Storage::disk('local')->assertExists($batch->bank_file_path);
    }

    public function test_download_does_not_generate_missing_file(): void
    {
        Storage::fake('local');
        $batch = PaymentBatch::create(['source_file_name' => 'payments.xlsx', 'status' => 'needs_review']);

        $this->actingAs(User::factory()->create())
            ->get("/admin/imports/{$batch->id}/bank-file")
            ->assertRedirect();

        $this->assertSame('needs_review', $batch->refresh()->status);
        $this->assertNull($batch->bank_file_path);
    }

    public function test_bank_formatter_rejects_control_characters(): void
    {
        $this->expectException(RuntimeException::class);

        (new TabDelimitedBankPaymentFileFormatter)->format(new Collection([[
            'nit' => "9001\n9002",
            'person_type' => '1',
            'account_number' => '123',
            'account_type' => 'CA',
            'bank_code' => '007',
            'amount' => 1000,
        ]]));
    }

    public function test_money_rejects_non_positive_and_excess_precision_values(): void
    {
        foreach (['0', '-1', '0.001', '1e3'] as $value) {
            try {
                Money::normalize($value);
                $this->fail("{$value} should be rejected.");
            } catch (InvalidArgumentException) {
                $this->addToAssertionCount(1);
            }
        }

        $this->assertSame('1000.50', Money::normalize('1000,5'));
        $this->assertSame(1001, Money::roundToWholePeso('1000.50'));
    }

    public function test_database_allows_only_one_primary_account_per_third_party(): void
    {
        $thirdParty = ThirdParty::create(['document_number' => '9001', 'person_type' => '1', 'name' => 'Proveedor']);
        $bank = Bank::create(['code' => '007', 'name' => 'Banco']);
        ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => '123',
            'account_type' => 'CA',
            'is_primary' => true,
        ]);

        $this->expectException(QueryException::class);
        ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => '456',
            'account_type' => 'CC',
            'is_primary' => true,
        ]);
    }

    public function test_catalog_delete_deactivates_third_party_without_removing_history(): void
    {
        $thirdParty = ThirdParty::create([
            'document_number' => '9001',
            'person_type' => '1',
            'name' => 'Proveedor',
            'password' => 'password123',
        ]);

        $this->actingAs(User::factory()->create())
            ->withSession(['_token' => 'test-token'])
            ->delete("/admin/catalog/{$thirdParty->id}", ['_token' => 'test-token'])
            ->assertRedirect();

        $this->assertDatabaseHas('third_parties', ['id' => $thirdParty->id, 'is_active' => false]);
        $this->assertNull($thirdParty->refresh()->password);
    }

    public function test_admin_login_is_rate_limited(): void
    {
        for ($attempt = 1; $attempt <= 5; $attempt++) {
            $this->withSession(['_token' => 'test-token'])
                ->post('/login', [
                    '_token' => 'test-token',
                    'email' => 'missing@example.com',
                    'password' => 'invalid-password',
                ])
                ->assertSessionHasErrors('email');
        }

        $this->withSession(['_token' => 'test-token'])
            ->post('/login', [
                '_token' => 'test-token',
                'email' => 'missing@example.com',
                'password' => 'invalid-password',
            ])
            ->assertTooManyRequests();
    }

    /** @param array<string, list<SpreadsheetRow>> $rowsBySheet */
    private function readerFactory(array $rowsBySheet): ExcelWorkbookReaderFactoryInterface
    {
        return new class($rowsBySheet) implements ExcelWorkbookReaderFactoryInterface
        {
            /** @param array<string, list<SpreadsheetRow>> $rowsBySheet */
            public function __construct(private readonly array $rowsBySheet) {}

            public function open(string $path): ExcelWorkbookReaderInterface
            {
                return new class($this->rowsBySheet) implements ExcelWorkbookReaderInterface
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
                };
            }
        };
    }
}
