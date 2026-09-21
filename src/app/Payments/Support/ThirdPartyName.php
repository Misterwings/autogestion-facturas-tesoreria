<?php

namespace App\Payments\Support;

use Illuminate\Support\Str;

final class ThirdPartyName
{
    public static function matches(?string $name, ?string ...$candidates): bool
    {
        $names = self::variants($name);

        if ($names === []) {
            return false;
        }

        foreach ($candidates as $candidate) {
            if (array_intersect($names, self::variants($candidate)) !== []) {
                return true;
            }
        }

        return false;
    }

    /** @return list<string> */
    public static function variants(?string $name): array
    {
        $name = trim((string) $name);
        if ($name === '') {
            return [];
        }

        $segments = [$name];
        if (str_contains($name, '/')) {
            $segments[] = strstr($name, '/', true);
        }

        return collect($segments)
            ->map(fn (string $value): string => Str::upper(Str::ascii($value)))
            ->map(fn (string $value): string => preg_replace('/[^A-Z0-9]/', '', $value) ?? '')
            ->filter()
            ->unique()
            ->values()
            ->all();
    }
}
