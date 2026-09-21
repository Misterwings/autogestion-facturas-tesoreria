<?php

namespace App\Payments\DTO;

final readonly class InvoiceData
{
    public function __construct(
        public string $sourceSheet,
        public int $sourceRow,
        public ?string $paymentDate,
        public string $detailDocumentNumber,
        public string $thirdPartyName,
        public string $supportDocument,
        public string $causationDocument,
        public string $amount,
        public ?string $concept,
    ) {}
}
