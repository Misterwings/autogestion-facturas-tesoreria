<?php

namespace Tests\Feature;

use App\Models\Bank;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class CatalogAlternateNameTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_store_alternate_name_for_third_party(): void
    {
        $thirdParty = ThirdParty::create([
            'document_number' => '9001',
            'person_type' => '1',
            'name' => 'Proveedor Principal',
        ]);
        $bank = Bank::create(['code' => '007', 'name' => 'Banco 007']);
        ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => '123',
            'account_type' => 'CA',
            'is_primary' => true,
            'is_active' => true,
        ]);

        $response = $this->actingAs(User::factory()->create())
            ->withSession(['_token' => 'test-token'])
            ->put("/admin/catalog/{$thirdParty->id}", [
                '_token' => 'test-token',
                'name' => 'Proveedor Principal',
                'alternate_name' => 'Proveedor Alterno',
                'person_type' => '1',
                'bank_account_number' => '123',
                'bank_account_type' => 'CA',
                'bank_code' => '007',
            ]);

        $response->assertRedirect();
        $this->assertSame('Proveedor Alterno', $thirdParty->refresh()->alternate_name);
    }

    public function test_admin_can_search_catalog_by_partial_document_number(): void
    {
        ThirdParty::create([
            'document_number' => '9001234567',
            'person_type' => '1',
            'name' => 'Proveedor Encontrado',
        ]);
        ThirdParty::create([
            'document_number' => '800987654',
            'person_type' => '1',
            'name' => 'Proveedor Distinto',
        ]);

        $this->actingAs(User::factory()->create())
            ->get('/admin/catalog?search=900123456')
            ->assertOk()
            ->assertInertia(fn (Assert $page) => $page
                ->component('Admin/Catalog/Index')
                ->where('filters.search', '900123456')
                ->has('thirdParties.data', 1)
                ->where('thirdParties.data.0.document_number', '9001234567')
            );
    }
}
