<?php

namespace App\Payments\DTO;

final readonly class ModelThirdPartyData
{
    public function __construct(
        public string $nit,
        public string $personType,
        public string $bankAccountNumber,
        public string $bankAccountType,
        public string $bankCode,
        public string $bankName,
        public string $thirdPartyName,
        public int $sourceRow,
    ) {}
}
