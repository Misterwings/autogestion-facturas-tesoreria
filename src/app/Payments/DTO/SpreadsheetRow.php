<?php

namespace App\Payments\DTO;

final readonly class SpreadsheetRow
{
    /**
     * @param  array<int, string>  $values
     */
    public function __construct(
        public int $number,
        private array $values,
    ) {}

    public function value(int $column): string
    {
        $value = $this->values[$column] ?? '';

        return trim(str_replace("\xc2\xa0", ' ', $value));
    }
}
