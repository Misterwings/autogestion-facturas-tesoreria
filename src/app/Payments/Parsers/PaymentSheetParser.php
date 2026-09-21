<?php

namespace App\Payments\Parsers;

use App\Payments\Contracts\ExcelWorkbookReaderInterface;
use App\Payments\DTO\ParsedPaymentSheet;

class PaymentSheetParser
{
    public function __construct(
        private readonly BankPaymentLineParser $bankPaymentLineParser,
        private readonly InvoiceDetailParser $invoiceDetailParser,
    ) {}

    public function parse(ExcelWorkbookReaderInterface $reader, string $sheetName): ParsedPaymentSheet
    {
        $rows = iterator_to_array($reader->rows($sheetName), false);
        $warnings = [];

        return new ParsedPaymentSheet(
            sheetName: $sheetName,
            bankPaymentLines: $this->bankPaymentLineParser->parse($sheetName, new \ArrayIterator($rows), $warnings),
            paymentReceipts: $this->invoiceDetailParser->parse($sheetName, new \ArrayIterator($rows), $warnings),
            warnings: $warnings,
        );
    }
}
