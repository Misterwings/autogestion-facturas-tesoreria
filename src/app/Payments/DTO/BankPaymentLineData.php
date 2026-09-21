<?php

namespace App\Payments\DTO;

final readonly class BankPaymentLineData
{
    public function __construct(
        public string $sourceSheet,
        public int $sourceRow,
        public string $nit,
        public string $personType,
        public string $bankAccountNumber,
        public string $bankAccountType,
        public string $bankCode,
        public string $amount,
        public ?string $thirdPartyName,
    ) {}
}
