<?php

namespace Tests\Feature;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\User;
use App\Payments\Actions\GenerateBankPaymentFileAction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class BankPaymentFileGenerationTest extends TestCase
{
    use RefreshDatabase;

    public function test_bank_file_is_generated_from_persisted_bank_payment_lines(): void
    {
        Storage::fake('local');

        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
        ]);
        $branch = Branch::create(['name' => 'MERCADEO']);
        $granada = Branch::create(['name' => 'GRANADA']);

        $this->bankLine($batch, $branch, '9001', '1', '123', 'CA', '007', '100.40');
        $this->bankLine($batch, $branch, '9001', '1', '123', 'CA', '007', '100.50');
        $this->bankLine($batch, $branch, '9002', '2', '999', 'CC', '051', '50.00');
        $this->bankLine($batch, $granada, '9003', '1', '777', 'CA', '007', '25.00');

        app(GenerateBankPaymentFileAction::class)->execute($batch);

        Storage::disk('local')->assertExists("bank-payment-files/payment-batch-{$batch->id}.txt");
        Storage::disk('local')->assertExists("bank-payment-files/payment-batch-{$batch->id}-granada.txt");
        Storage::disk('local')->assertExists("bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-mercadeo.txt");
        Storage::disk('local')->assertExists("bank-payment-files/payment-batch-{$batch->id}-branch-{$granada->id}-granada.txt");
        $this->assertSame("9001\t1\t123\tCA\t007\t201\n9002\t2\t999\tCC\t051\t50\n", Storage::disk('local')->get("bank-payment-files/payment-batch-{$batch->id}.txt"));
        $this->assertSame("9003\t1\t777\tCA\t007\t25\n", Storage::disk('local')->get("bank-payment-files/payment-batch-{$batch->id}-granada.txt"));
        $this->assertSame("9001\t1\t123\tCA\t007\t201\n9002\t2\t999\tCC\t051\t50\n", Storage::disk('local')->get("bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-mercadeo.txt"));
        $this->assertSame([
            (string) $granada->id => "bank-payment-files/payment-batch-{$batch->id}-branch-{$granada->id}-granada.txt",
            (string) $branch->id => "bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-mercadeo.txt",
        ], $batch->refresh()->branch_file_paths);
    }

    public function test_branch_bank_file_download_includes_lines_without_receipt(): void
    {
        Storage::fake('local');

        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
        ]);
        $branch = Branch::create(['name' => 'OFICINA']);

        $this->bankLine($batch, $branch, '9004', '2', '444', 'CA', '007', '75.00');
        app(GenerateBankPaymentFileAction::class)->execute($batch);

        $response = $this->actingAs(User::factory()->create())
            ->get("/admin/imports/{$batch->id}/bank-file/branches/{$branch->id}");

        $response->assertOk();
        $this->assertStringContainsString("payment-batch-{$batch->id}-oficina.txt", $response->headers->get('content-disposition'));
        $this->assertSame("9004\t2\t444\tCA\t007\t75\n", Storage::disk('local')->get("bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-oficina.txt"));
    }

    public function test_granada_file_path_is_cleared_when_regeneration_has_no_granada_rows(): void
    {
        Storage::fake('local');

        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
            'granada_file_path' => 'bank-payment-files/old-granada.txt',
        ]);
        $branch = Branch::create(['name' => 'MERCADEO']);

        $this->bankLine($batch, $branch, '9001', '1', '123', 'CA', '007', '100.00');

        app(GenerateBankPaymentFileAction::class)->execute($batch);

        $this->assertNull($batch->refresh()->granada_file_path);
    }

    private function bankLine(
        PaymentBatch $batch,
        Branch $branch,
        string $nit,
        string $personType,
        string $accountNumber,
        string $accountType,
        string $bankCode,
        string $amount,
    ): BankPaymentLine {
        return BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'nit' => $nit,
            'person_type' => $personType,
            'bank_account_number' => $accountNumber,
            'bank_account_type' => $accountType,
            'bank_code' => $bankCode,
            'amount' => $amount,
            'source_sheet' => $branch->name,
            'source_row' => 7,
        ]);
    }
}
