<?php

namespace App\Payments\Parsers;

use App\Payments\DTO\BankPaymentLineData;
use App\Payments\DTO\SpreadsheetRow;
use App\Payments\Support\SpreadsheetValue;
use InvalidArgumentException;
use Traversable;

class BankPaymentLineParser
{
    /**
     * @param  Traversable<SpreadsheetRow>  $rows
     * @return list<BankPaymentLineData>
     */
    public function parse(string $sheetName, Traversable $rows, array &$warnings = []): array
    {
        $lines = [];

        foreach ($rows as $row) {
            if ($row->number <= 6) {
                continue;
            }

            $nit = SpreadsheetValue::cleanIdentifier($row->value(9));
            $personType = SpreadsheetValue::cleanIdentifier($row->value(10));
            $accountNumber = SpreadsheetValue::cleanIdentifier($row->value(11));
            $accountType = strtoupper($row->value(12));
            $bankCode = SpreadsheetValue::cleanIdentifier($row->value(13));
            $amount = $row->value(14);

            $hasBankData = collect(range(9, 15))->contains(fn (int $column): bool => $row->value($column) !== '');

            if (! $hasBankData) {
                continue;
            }

            if (! SpreadsheetValue::isSafeIdentifier($nit) || ! in_array($personType, ['1', '2'], true)) {
                $warnings[] = $this->warning('invalid_bank_identity', 'NIT/DNI or person type is invalid.', $row->number);

                continue;
            }

            if (! SpreadsheetValue::isSafeIdentifier($accountNumber) || ! in_array($accountType, ['CA', 'CC'], true)) {
                $warnings[] = $this->warning('invalid_bank_account', 'Bank account number or type is invalid.', $row->number);

                continue;
            }

            if (! SpreadsheetValue::isSafeIdentifier($bankCode, 20)) {
                $warnings[] = $this->warning('invalid_bank_code', 'Bank code is invalid.', $row->number);

                continue;
            }

            try {
                $normalizedAmount = SpreadsheetValue::decimal($amount);
            } catch (InvalidArgumentException) {
                $warnings[] = $this->warning('invalid_bank_amount', 'Bank amount must be positive and have at most two decimal places.', $row->number);

                continue;
            }

            $thirdPartyName = $row->value(15);
            if ($thirdPartyName !== '' && SpreadsheetValue::hasControlCharacters($thirdPartyName)) {
                $warnings[] = $this->warning('invalid_bank_third_party_name', 'Third-party name contains control characters.', $row->number);

                continue;
            }

            $lines[] = new BankPaymentLineData(
                sourceSheet: $sheetName,
                sourceRow: $row->number,
                nit: $nit,
                personType: $personType,
                bankAccountNumber: $accountNumber,
                bankAccountType: $accountType,
                bankCode: $bankCode,
                amount: $normalizedAmount,
                thirdPartyName: $thirdPartyName !== '' ? $thirdPartyName : null,
            );
        }

        return $lines;
    }

    /** @return array{code: string, message: string, row: int, severity: string} */
    private function warning(string $code, string $message, int $row): array
    {
        return compact('code', 'message', 'row') + ['severity' => 'warning'];
    }
}
