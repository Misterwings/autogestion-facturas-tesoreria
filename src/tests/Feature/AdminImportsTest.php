<?php

namespace Tests\Feature;

use App\Models\PaymentBatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminImportsTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_from_admin_imports(): void
    {
        $response = $this->get('/admin/imports');

        $response->assertRedirect('/login');
    }

    public function test_admin_imports_index_returns_successful_response(): void
    {
        $response = $this->actingAs(User::factory()->create())->get('/admin/imports');

        $response->assertOk();
    }

    public function test_admin_import_detail_returns_successful_response(): void
    {
        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
        ]);

        $response = $this->actingAs(User::factory()->create())->get("/admin/imports/{$batch->id}");

        $response->assertOk();
    }

    public function test_admin_can_download_bank_file(): void
    {
        Storage::fake('local');
        Storage::disk('local')->put('bank-payment-files/payment-batch-1.txt', "123\t2\t456\tCA\t7\t1000\n");

        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
            'bank_file_path' => 'bank-payment-files/payment-batch-1.txt',
        ]);

        $response = $this->actingAs(User::factory()->create())->get("/admin/imports/{$batch->id}/bank-file");

        $response->assertOk();
        $this->assertSame("attachment; filename=payment-batch-{$batch->id}.txt", $response->headers->get('content-disposition'));
    }

    public function test_admin_can_delete_batch_and_its_private_files(): void
    {
        Storage::fake('local');
        Storage::disk('local')->put('imports/source.xlsx', 'workbook');
        Storage::disk('local')->put('bank-payment-files/main.txt', 'main');
        Storage::disk('local')->put('bank-payment-files/granada.txt', 'granada');
        Storage::disk('local')->put('bank-payment-files/branch.txt', 'branch');

        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'source_file_path' => Storage::disk('local')->path('imports/source.xlsx'),
            'status' => 'ready',
            'bank_file_path' => 'bank-payment-files/main.txt',
            'granada_file_path' => 'bank-payment-files/granada.txt',
            'branch_file_paths' => ['1' => 'bank-payment-files/branch.txt'],
        ]);

        $this->actingAs(User::factory()->create())
            ->withSession(['_token' => 'test-token'])
            ->delete("/admin/imports/{$batch->id}", ['_token' => 'test-token'])
            ->assertRedirect('/admin/imports');

        $this->assertDatabaseMissing('payment_batches', ['id' => $batch->id]);
        Storage::disk('local')->assertMissing('imports/source.xlsx');
        Storage::disk('local')->assertMissing('bank-payment-files/main.txt');
        Storage::disk('local')->assertMissing('bank-payment-files/granada.txt');
        Storage::disk('local')->assertMissing('bank-payment-files/branch.txt');
    }

    public function test_admin_cannot_delete_batch_while_files_are_being_generated(): void
    {
        Storage::fake('local');
        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'status' => 'generating',
        ]);

        $this->actingAs(User::factory()->create())
            ->withSession(['_token' => 'test-token'])
            ->from("/admin/imports/{$batch->id}")
            ->delete("/admin/imports/{$batch->id}", ['_token' => 'test-token'])
            ->assertRedirect("/admin/imports/{$batch->id}");

        $this->assertDatabaseHas('payment_batches', ['id' => $batch->id]);
    }
}
