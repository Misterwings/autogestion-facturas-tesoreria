<?php

namespace App\Payments\Excel;

use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Contracts\ExcelWorkbookReaderInterface;

class XlsxWorkbookReaderFactory implements ExcelWorkbookReaderFactoryInterface
{
    public function open(string $path): ExcelWorkbookReaderInterface
    {
        return new XlsxWorkbookReader($path);
    }
}
