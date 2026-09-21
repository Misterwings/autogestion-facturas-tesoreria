<?php

namespace App\Payments\Contracts;

use Illuminate\Support\Collection;

interface BankPaymentFileFormatterInterface
{
    /**
     * @param  Collection<int, array{nit: string, person_type: string, account_number: string, account_type: string, bank_code: string, amount: int}>  $rows
     */
    public function format(Collection $rows): string;
}
