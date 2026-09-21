<?php

namespace App\Payments\Importers;

use App\Models\BankPaymentLine;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\Support\Money;
use App\Payments\Support\ThirdPartyName;
use Illuminate\Support\Collection;

class ReceiptMatcher
{
    /** @var array<int, true> */
    private array $usedLineIds = [];

    /** @var array{code: string, message: string}|null */
    private ?array $lastFailure = null;

    /**
     * @param  Collection<int, BankPaymentLine>  $bankPaymentLines
     */
    public function __construct(private readonly Collection $bankPaymentLines) {}

    public function match(PaymentReceiptData $receipt): ?BankPaymentLine
    {
        $this->lastFailure = null;

        $amountMatches = $this->bankPaymentLines
            ->filter(fn (BankPaymentLine $line): bool => ! isset($this->usedLineIds[$line->id])
                && Money::cents((string) $line->amount) === Money::cents($receipt->amount))
            ->values();

        if ($amountMatches->isEmpty()) {
            $this->lastFailure = [
                'code' => 'bank_payment_line_not_found',
                'message' => "Receipt {$receipt->receiptNumber} could not be matched to a bank line by amount.",
            ];

            return null;
        }

        $nameMatches = $amountMatches
            ->filter(fn (BankPaymentLine $line): bool => $this->matchesReceiptIdentity($line, $receipt))
            ->values();

        if ($nameMatches->count() === 1) {
            return $this->markUsed($nameMatches->first());
        }

        $this->lastFailure = [
            'code' => $amountMatches->count() === 1 ? 'bank_payment_line_identity_mismatch' : 'ambiguous_bank_payment_line_match',
            'message' => "Receipt {$receipt->receiptNumber} matches {$amountMatches->count()} bank line(s) by amount but has no unique third-party identity match.",
        ];

        return null;
    }

    /** @return array{code: string, message: string}|null */
    public function lastFailure(): ?array
    {
        return $this->lastFailure;
    }

    /** @return Collection<int, BankPaymentLine> */
    public function unmatchedLines(): Collection
    {
        return $this->bankPaymentLines->reject(fn (BankPaymentLine $line): bool => isset($this->usedLineIds[$line->id]));
    }

    private function markUsed(BankPaymentLine $line): BankPaymentLine
    {
        $this->usedLineIds[$line->id] = true;

        return $line;
    }

    private function matchesReceiptIdentity(BankPaymentLine $line, PaymentReceiptData $receipt): bool
    {
        $documents = collect($receipt->invoices)
            ->map(fn ($invoice): string => preg_replace('/[^A-Za-z0-9]/', '', $invoice->detailDocumentNumber) ?? '')
            ->filter();
        $lineDocument = preg_replace('/[^A-Za-z0-9]/', '', $line->nit) ?? '';

        if ($lineDocument !== '' && $documents->contains($lineDocument)) {
            return true;
        }

        $receiptNames = collect($receipt->invoices)
            ->flatMap(fn ($invoice): array => ThirdPartyName::variants($invoice->thirdPartyName))
            ->filter()
            ->unique()
            ->values();

        if ($receiptNames->isEmpty()) {
            return false;
        }

        return collect([$line->third_party_name, $line->thirdParty?->name, $line->thirdParty?->alternate_name])
            ->flatMap(fn (?string $name): array => ThirdPartyName::variants($name))
            ->filter()
            ->contains(fn (string $name): bool => $receiptNames->contains($name));
    }
}
