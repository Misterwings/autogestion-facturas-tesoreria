<?php

namespace App\Payments\Contracts;

use App\Payments\DTO\SpreadsheetRow;
use Generator;

interface ExcelWorkbookReaderInterface
{
    /**
     * @return list<string>
     */
    public function sheetNames(): array;

    /**
     * @return Generator<SpreadsheetRow>
     */
    public function rows(string $sheetName): Generator;
}
