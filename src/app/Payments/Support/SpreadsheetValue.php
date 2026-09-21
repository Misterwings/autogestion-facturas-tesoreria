<?php

namespace App\Payments\Support;

final class SpreadsheetValue
{
    public static function cleanIdentifier(string $value): string
    {
        $value = trim(str_replace(["\xc2\xa0", ' '], '', $value));

        if (preg_match('/^-?\d+\.0+$/', $value) === 1) {
            return strtok($value, '.');
        }

        return $value;
    }

    public static function isNumeric(string $value): bool
    {
        return $value !== '' && is_numeric(str_replace(',', '.', $value));
    }

    public static function decimal(string $value): string
    {
        return Money::normalize($value);
    }

    public static function hasControlCharacters(string $value): bool
    {
        return preg_match('/[\x00-\x1F\x7F]/', $value) === 1;
    }

    public static function isSafeIdentifier(string $value, int $maxLength = 50): bool
    {
        return $value !== ''
            && strlen($value) <= $maxLength
            && ! self::hasControlCharacters($value)
            && preg_match('/^[A-Za-z0-9.-]+$/', $value) === 1;
    }
}
