<?php

namespace App\Payments\Formatters;

use App\Payments\Contracts\BankPaymentFileFormatterInterface;
use Illuminate\Support\Collection;
use RuntimeException;

class TabDelimitedBankPaymentFileFormatter implements BankPaymentFileFormatterInterface
{
    public function format(Collection $rows): string
    {
        if ($rows->isEmpty()) {
            return '';
        }

        return $rows->map(function (array $row): string {
            $values = [
                $row['nit'],
                $row['person_type'],
                $row['account_number'],
                $row['account_type'],
                $row['bank_code'],
                (string) $row['amount'],
            ];

            if (collect($values)->contains(fn (string $value): bool => preg_match('/[\x00-\x1F\x7F]/', $value) === 1)) {
                throw new RuntimeException('A bank file value contains a control character.');
            }

            return implode("\t", $values);
        })->implode("\n")."\n";
    }
}
