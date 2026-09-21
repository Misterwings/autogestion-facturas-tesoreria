<?php

namespace App\Payments\Importers;

use App\Models\Bank;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Payments\DTO\BankPaymentLineData;
use App\Payments\DTO\ModelThirdPartyData;

class CatalogImporter
{
    public function importModelThirdParty(ModelThirdPartyData $data): ThirdParty
    {
        $bank = $this->syncBank($data->bankCode, $data->bankName);
        $thirdParty = $this->syncThirdParty($data->nit, $data->personType, $data->thirdPartyName);
        $this->syncPrimaryAccount($thirdParty, $bank, $data->bankAccountNumber, $data->bankAccountType);

        return $thirdParty;
    }

    /** @return array{0: ThirdParty, 1: Bank} */
    public function importFromBankLine(BankPaymentLineData $data): array
    {
        $bank = $this->syncBank($data->bankCode, null);
        $thirdParty = $this->syncThirdParty($data->nit, $data->personType, $data->thirdPartyName);
        $this->syncReferencedAccount($thirdParty, $bank, $data->bankAccountNumber, $data->bankAccountType);

        return [$thirdParty, $bank];
    }

    private function syncBank(string $code, ?string $name): Bank
    {
        $bank = Bank::firstOrCreate(
            ['code' => $code],
            ['name' => $name ?: "Banco {$code}"],
        );

        if ($name !== null && $name !== '' && str_starts_with($bank->name, 'Banco ')) {
            $bank->update(['name' => $name]);
        }

        return $bank;
    }

    private function syncThirdParty(string $documentNumber, string $personType, ?string $name): ThirdParty
    {
        $existing = ThirdParty::where('document_number', $documentNumber)->first();

        if ($existing !== null) {
            $attributes = ['person_type' => $personType, 'is_active' => true];
            if ($name !== null && trim($name) !== '') {
                $attributes['name'] = trim($name);
            }

            $existing->update($attributes);

            return $existing;
        }

        return ThirdParty::create([
            'document_number' => $documentNumber,
            'person_type' => $personType,
            'name' => $name !== null && trim($name) !== '' ? trim($name) : $documentNumber,
            'is_active' => true,
        ]);
    }

    private function syncPrimaryAccount(ThirdParty $thirdParty, Bank $bank, string $accountNumber, string $accountType): ThirdPartyBankAccount
    {
        ThirdPartyBankAccount::query()
            ->where('third_party_id', $thirdParty->id)
            ->update(['is_primary' => false]);

        return ThirdPartyBankAccount::updateOrCreate(
            [
                'third_party_id' => $thirdParty->id,
                'bank_id' => $bank->id,
                'account_number' => $accountNumber,
                'account_type' => $accountType,
            ],
            [
                'is_primary' => true,
                'is_active' => true,
            ],
        );
    }

    private function syncReferencedAccount(ThirdParty $thirdParty, Bank $bank, string $accountNumber, string $accountType): ThirdPartyBankAccount
    {
        $hasPrimary = $thirdParty->bankAccounts()->where('is_primary', true)->exists();
        $account = ThirdPartyBankAccount::where([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => $accountNumber,
            'account_type' => $accountType,
        ])->first();

        if ($account !== null) {
            $account->update([
                'is_primary' => $account->is_primary || ! $hasPrimary,
                'is_active' => true,
            ]);

            return $account;
        }

        return ThirdPartyBankAccount::create([
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'account_number' => $accountNumber,
            'account_type' => $accountType,
            'is_primary' => ! $hasPrimary,
            'is_active' => true,
        ]);
    }
}
