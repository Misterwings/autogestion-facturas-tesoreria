<?php

namespace App\Payments\Support;

use InvalidArgumentException;

final class Money
{
    public static function normalize(string $value): string
    {
        return self::normalizeValue($value, false);
    }

    public static function normalizeSigned(string $value): string
    {
        return self::normalizeValue($value, true);
    }

    public static function centsSigned(string $value): int
    {
        $normalized = self::normalizeSigned($value);
        $negative = str_starts_with($normalized, '-');
        [$major, $minor] = explode('.', ltrim($normalized, '-'));
        $cents = ((int) $major * 100) + (int) $minor;

        return $negative ? -$cents : $cents;
    }

    private static function normalizeValue(string $value, bool $allowNegative): string
    {
        $value = str_replace(',', '.', trim($value));
        $pattern = $allowNegative
            ? '/^(-?)(\d{1,16})(?:\.(\d{1,2}))?$/'
            : '/^()(\d{1,16})(?:\.(\d{1,2}))?$/';

        if (preg_match($pattern, $value, $matches) !== 1) {
            throw new InvalidArgumentException('The amount must be a non-zero decimal with at most two decimal places.');
        }

        $sign = $matches[1];
        $major = ltrim($matches[2], '0');
        $major = $major === '' ? '0' : $major;
        $minor = str_pad($matches[3] ?? '', 2, '0');

        if ($major === '0' && $minor === '00') {
            throw new InvalidArgumentException('The amount must be greater than zero.');
        }

        return $sign.$major.'.'.$minor;
    }

    public static function cents(string $value): int
    {
        [$major, $minor] = explode('.', self::normalize($value));

        return ((int) $major * 100) + (int) $minor;
    }

    public static function fromCents(int $cents): string
    {
        if ($cents <= 0) {
            throw new InvalidArgumentException('The amount must be greater than zero.');
        }

        return intdiv($cents, 100).'.'.str_pad((string) ($cents % 100), 2, '0', STR_PAD_LEFT);
    }

    public static function roundToWholePeso(string $value): int
    {
        $cents = self::cents($value);

        return intdiv($cents, 100) + (($cents % 100) >= 50 ? 1 : 0);
    }
}
