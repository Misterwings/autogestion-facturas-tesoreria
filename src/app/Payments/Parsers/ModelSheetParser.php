<?php

namespace App\Payments\Parsers;

use App\Payments\DTO\ModelThirdPartyData;
use App\Payments\DTO\SpreadsheetRow;
use App\Payments\Support\SpreadsheetValue;
use InvalidArgumentException;
use Traversable;

class ModelSheetParser
{
    /**
     * @param  Traversable<SpreadsheetRow>  $rows
     * @return list<ModelThirdPartyData>
     */
    public function parse(Traversable $rows): array
    {
        $thirdParties = [];

        foreach ($rows as $row) {
            if ($row->number === 1) {
                continue;
            }

            $nit = SpreadsheetValue::cleanIdentifier($row->value(1));
            $accountNumber = SpreadsheetValue::cleanIdentifier($row->value(3));
            $hasData = collect(range(1, 7))->contains(fn (int $column): bool => $row->value($column) !== '');

            if (! $hasData) {
                continue;
            }

            $personType = SpreadsheetValue::cleanIdentifier($row->value(2));
            $accountType = strtoupper($row->value(4));
            $bankCode = SpreadsheetValue::cleanIdentifier($row->value(5));
            $bankName = $row->value(6);
            $thirdPartyName = $row->value(7);

            if (! SpreadsheetValue::isSafeIdentifier($nit)
                || ! in_array($personType, ['1', '2'], true)
                || ! SpreadsheetValue::isSafeIdentifier($accountNumber)
                || ! in_array($accountType, ['CA', 'CC'], true)
                || ! SpreadsheetValue::isSafeIdentifier($bankCode, 20)
                || SpreadsheetValue::hasControlCharacters($bankName)
                || SpreadsheetValue::hasControlCharacters($thirdPartyName)) {
                throw new InvalidArgumentException("Invalid MODELO data at row {$row->number}.");
            }

            $thirdParties[] = new ModelThirdPartyData(
                nit: $nit,
                personType: $personType,
                bankAccountNumber: $accountNumber,
                bankAccountType: $accountType,
                bankCode: $bankCode,
                bankName: $bankName,
                thirdPartyName: $thirdPartyName,
                sourceRow: $row->number,
            );
        }

        return $thirdParties;
    }
}
