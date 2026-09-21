<?php

namespace Tests\Feature;

use App\Models\Bank;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\PaymentReceipt;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class SupplierReceiptsTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_is_redirected_from_supplier_receipts(): void
    {
        $response = $this->get('/proveedor/comprobantes');

        $response->assertRedirect('/proveedor/login');
    }

    public function test_supplier_login_page_renders_supplier_access(): void
    {
        $response = $this->get('/proveedor/login');

        $response->assertOk();
        $response->assertInertia(fn (Assert $page) => $page
            ->component('Supplier/Login')
        );
    }

    public function test_supplier_portal_entry_renders_supplier_access(): void
    {
        $response = $this->get('/proveedor');

        $response->assertOk();
        $response->assertInertia(fn (Assert $page) => $page
            ->component('Supplier/Login')
        );
    }

    public function test_supplier_can_login_with_document_number_and_password(): void
    {
        $thirdParty = ThirdParty::create([
            'document_number' => '9001',
            'person_type' => '1',
            'name' => 'Proveedor Alpha',
            'password' => 'supplier-password',
        ]);

        $response = $this
            ->withSession(['_token' => 'test-token'])
            ->post('/proveedor/login', [
                '_token' => 'test-token',
                'document_number' => '9001',
                'password' => 'supplier-password',
            ]);

        $response->assertRedirect('/proveedor/comprobantes');
        $response->assertSessionHas('supplier_third_party_id', $thirdParty->id);
    }

    public function test_supplier_without_password_cannot_login(): void
    {
        ThirdParty::create([
            'document_number' => '9001',
            'person_type' => '1',
            'name' => 'Proveedor Alpha',
        ]);

        $response = $this
            ->withSession(['_token' => 'test-token'])
            ->post('/proveedor/login', [
                '_token' => 'test-token',
                'document_number' => '9001',
                'password' => 'supplier-password',
            ]);

        $response->assertSessionHasErrors('document_number');
    }

    public function test_supplier_receipts_index_only_shows_authenticated_third_party_receipts(): void
    {
        $supplier = $this->thirdParty('9001', 'Proveedor Alpha');
        $otherSupplier = $this->thirdParty('9002', 'Proveedor Beta');

        $this->receipt($supplier, 'PEL-1', '1000.00');
        $this->receipt($otherSupplier, 'PEL-2', '2000.00');

        $response = $this
            ->withSession(['supplier_third_party_id' => $supplier->id])
            ->get('/proveedor/comprobantes');

        $response->assertOk();
        $response->assertInertia(fn (Assert $page) => $page
            ->component('Supplier/Receipts/Index')
            ->where('supplier.document_number', '9001')
            ->where('totals.receipts_count', 1)
            ->has('receipts.data', 1)
            ->where('receipts.data.0.receipt_number', 'PEL-1')
        );
    }

    public function test_supplier_can_filter_receipts_by_payment_date_and_branch(): void
    {
        $supplier = $this->thirdParty('9001', 'Proveedor Alpha');
        $matchingReceipt = $this->receipt($supplier, 'PEL-1', '1000.00', '2026-07-02', 'MERCADEO');

        $this->receipt($supplier, 'PEL-2', '2000.00', '2026-07-03', 'MERCADEO');
        $this->receipt($supplier, 'PEL-3', '3000.00', '2026-07-02', 'OFICINA');

        $response = $this
            ->withSession(['supplier_third_party_id' => $supplier->id])
            ->get('/proveedor/comprobantes?payment_date=2026-07-02&branch_id='.$matchingReceipt->branch_id);

        $response->assertOk();
        $response->assertInertia(fn (Assert $page) => $page
            ->component('Supplier/Receipts/Index')
            ->where('filters.payment_date', '2026-07-02')
            ->where('filters.branch_id', (string) $matchingReceipt->branch_id)
            ->where('totals.receipts_count', 1)
            ->has('receipts.data', 1)
            ->where('receipts.data.0.receipt_number', 'PEL-1')
        );
    }

    public function test_supplier_can_download_own_receipt_pdf(): void
    {
        $supplier = $this->thirdParty('9001', 'Proveedor Alpha');
        $receipt = $this->receipt($supplier, 'PEL-1', '1000.00');

        $response = $this
            ->withSession(['supplier_third_party_id' => $supplier->id])
            ->get("/proveedor/comprobantes/{$receipt->id}/pdf");

        $response->assertOk();
        $this->assertStringContainsString('comprobante-PEL-1.pdf', $response->headers->get('content-disposition'));
    }

    public function test_supplier_cannot_download_other_supplier_receipt_pdf(): void
    {
        $supplier = $this->thirdParty('9001', 'Proveedor Alpha');
        $otherSupplier = $this->thirdParty('9002', 'Proveedor Beta');
        $receipt = $this->receipt($otherSupplier, 'PEL-2', '2000.00');

        $response = $this
            ->withSession(['supplier_third_party_id' => $supplier->id])
            ->get("/proveedor/comprobantes/{$receipt->id}/pdf");

        $response->assertNotFound();
    }

    public function test_admin_can_set_supplier_password_from_catalog(): void
    {
        $thirdParty = $this->thirdParty('9001', 'Proveedor Alpha', null);
        $bank = Bank::create(['code' => '007', 'name' => 'Banco 007']);

        ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => '123456',
            'account_type' => 'CA',
            'is_primary' => true,
            'is_active' => true,
        ]);

        $response = $this->actingAs(User::factory()->create())
            ->withSession(['_token' => 'test-token'])
            ->put("/admin/catalog/{$thirdParty->id}", [
                '_token' => 'test-token',
                'name' => 'Proveedor Alpha',
                'alternate_name' => '',
                'person_type' => '1',
                'bank_account_number' => '123456',
                'bank_account_type' => 'CA',
                'bank_code' => '007',
                'password' => 'supplier-password',
                'password_confirmation' => 'supplier-password',
            ]);

        $response->assertRedirect();
        $response->assertSessionHasNoErrors();
        $this->assertTrue(Hash::check('supplier-password', $thirdParty->refresh()->password));
    }

    private function thirdParty(string $documentNumber, string $name, ?string $password = 'supplier-password'): ThirdParty
    {
        return ThirdParty::create([
            'document_number' => $documentNumber,
            'person_type' => '1',
            'name' => $name,
            'password' => $password,
        ]);
    }

    private function receipt(
        ThirdParty $thirdParty,
        string $receiptNumber,
        string $amount,
        string $paymentDate = '2026-07-02',
        string $branchName = 'MERCADEO',
    ): PaymentReceipt {
        $batch = PaymentBatch::firstOrCreate(
            ['source_file_name' => 'pagos.xlsx'],
            [
                'payment_date' => $paymentDate,
                'status' => 'imported',
            ],
        );

        $branch = Branch::firstOrCreate(['name' => $branchName]);

        return PaymentReceipt::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdParty->id,
            'receipt_number' => $receiptNumber,
            'payment_date' => $paymentDate,
            'amount' => $amount,
            'concept' => 'Pago proveedores',
            'source_sheet' => $branchName,
            'source_row' => 7,
        ]);
    }
}
