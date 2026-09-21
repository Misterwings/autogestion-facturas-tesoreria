<?php

namespace App\Payments\Importers;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Payments\DTO\BankPaymentLineData;
use Illuminate\Support\Collection;

class BankPaymentLineImporter
{
    public function __construct(private readonly CatalogImporter $catalogImporter) {}

    /**
     * @param  list<BankPaymentLineData>  $lines
     * @return Collection<int, BankPaymentLine>
     */
    public function importMany(PaymentBatch $batch, Branch $branch, array $lines): Collection
    {
        return collect($lines)->map(fn (BankPaymentLineData $line): BankPaymentLine => $this->import($batch, $branch, $line));
    }

    public function import(PaymentBatch $batch, Branch $branch, BankPaymentLineData $data): BankPaymentLine
    {
        [$thirdParty, $bank] = $this->catalogImporter->importFromBankLine($data);

        return BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdParty->id,
            'bank_id' => $bank->id,
            'nit' => $data->nit,
            'person_type' => $data->personType,
            'bank_account_number' => $data->bankAccountNumber,
            'bank_account_type' => $data->bankAccountType,
            'bank_code' => $data->bankCode,
            'third_party_name' => $data->thirdPartyName,
            'amount' => $data->amount,
            'source_sheet' => $data->sourceSheet,
            'source_row' => $data->sourceRow,
        ]);
    }
}
