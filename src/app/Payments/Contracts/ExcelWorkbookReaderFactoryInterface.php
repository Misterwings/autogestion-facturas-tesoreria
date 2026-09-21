<?php

namespace App\Payments\Contracts;

interface ExcelWorkbookReaderFactoryInterface
{
    public function open(string $path): ExcelWorkbookReaderInterface;
}
