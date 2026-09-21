<?php

namespace App\Payments\Support;

use DateInterval;
use DateTimeImmutable;

final class ExcelSerialDate
{
    public static function toDateString(string $value): ?string
    {
        if (! SpreadsheetValue::isNumeric($value)) {
            return null;
        }

        $days = (int) floor((float) SpreadsheetValue::decimal($value));

        if ($days <= 0) {
            return null;
        }

        return (new DateTimeImmutable('1899-12-30'))
            ->add(new DateInterval('P'.$days.'D'))
            ->format('Y-m-d');
    }
}
