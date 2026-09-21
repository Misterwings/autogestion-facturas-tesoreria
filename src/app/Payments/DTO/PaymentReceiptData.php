<?php

namespace App\Payments\DTO;

final readonly class PaymentReceiptData
{
    /**
     * @param  list<InvoiceData>  $invoices
     * @param  list<string>  $warnings
     */
    public function __construct(
        public string $sourceSheet,
        public int $sourceRow,
        public string $receiptNumber,
        public ?string $paymentDate,
        public string $amount,
        public ?string $concept,
        public array $invoices,
        public array $warnings = [],
    ) {}
}
