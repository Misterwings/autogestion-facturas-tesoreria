<?php

namespace App\Payments\DTO;

final readonly class ParsedPaymentSheet
{
    /**
     * @param  list<BankPaymentLineData>  $bankPaymentLines
     * @param  list<PaymentReceiptData>  $paymentReceipts
     * @param  list<array{code: string, message: string, row?: int, severity?: string}>  $warnings
     */
    public function __construct(
        public string $sheetName,
        public array $bankPaymentLines,
        public array $paymentReceipts,
        public array $warnings = [],
    ) {}
}
