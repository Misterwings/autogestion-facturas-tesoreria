<?php

namespace Tests\Feature;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\ThirdParty;
use App\Payments\DTO\InvoiceData;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\Importers\ReceiptMatcher;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReceiptMatcherTest extends TestCase
{
    use RefreshDatabase;

    public function test_receipt_matcher_uses_third_party_name_to_disambiguate_same_amount_lines(): void
    {
        [$alphaLine, $betaLine] = $this->sameAmountLines();
        $receipt = $this->receiptFor('Proveedor Beta');

        $matchedLine = (new ReceiptMatcher(collect([$alphaLine, $betaLine])))->match($receipt);

        $this->assertTrue($betaLine->is($matchedLine));
    }

    public function test_receipt_matcher_uses_alternate_name_to_disambiguate_same_amount_lines(): void
    {
        [$alphaLine, $betaLine] = $this->sameAmountLines();
        $betaLine->thirdParty->update(['alternate_name' => 'Proveedor Alterno Beta']);
        $receipt = $this->receiptFor('Proveedor Alterno Beta');

        $matchedLine = (new ReceiptMatcher(collect([$alphaLine, $betaLine])))->match($receipt);

        $this->assertTrue($betaLine->is($matchedLine));
    }

    public function test_receipt_matcher_accepts_incomplete_nit_only_with_matching_name(): void
    {
        [$alphaLine] = $this->sameAmountLines();
        $alphaLine->update(['nit' => '9001234567']);
        $receipt = $this->receiptFor('Proveedor Alpha', '900123456');

        $matchedLine = (new ReceiptMatcher(collect([$alphaLine])))->match($receipt);

        $this->assertTrue($alphaLine->is($matchedLine));
    }

    public function test_receipt_matcher_rejects_incomplete_nit_when_name_does_not_match(): void
    {
        [$alphaLine] = $this->sameAmountLines();
        $alphaLine->update(['nit' => '9001234567']);
        $matcher = new ReceiptMatcher(collect([$alphaLine]));

        $this->assertNull($matcher->match($this->receiptFor('Proveedor Distinto', '900123456')));
        $this->assertSame('bank_payment_line_identity_mismatch', $matcher->lastFailure()['code']);
    }

    public function test_receipt_matcher_refuses_ambiguous_amount_only_match(): void
    {
        [$alphaLine, $betaLine] = $this->sameAmountLines();
        $receipt = $this->receiptFor('Proveedor Gamma');
        $matcher = new ReceiptMatcher(collect([$alphaLine, $betaLine]));

        $this->assertNull($matcher->match($receipt));
        $this->assertSame('ambiguous_bank_payment_line_match', $matcher->lastFailure()['code']);
    }

    /** @return array{0: BankPaymentLine, 1: BankPaymentLine} */
    private function sameAmountLines(): array
    {
        $batch = PaymentBatch::create([
            'source_file_name' => 'pagos.xlsx',
            'payment_date' => '2026-07-02',
            'status' => 'imported',
        ]);
        $branch = Branch::create(['name' => 'MERCADEO']);
        $alpha = ThirdParty::create(['document_number' => '9001', 'person_type' => '1', 'name' => 'Proveedor Alpha']);
        $beta = ThirdParty::create(['document_number' => '9002', 'person_type' => '1', 'name' => 'Proveedor Beta']);

        return [
            $this->line($batch, $branch, $alpha, '9001', 'Proveedor Alpha'),
            $this->line($batch, $branch, $beta, '9002', 'Proveedor Beta'),
        ];
    }

    private function line(PaymentBatch $batch, Branch $branch, ThirdParty $thirdParty, string $nit, string $name): BankPaymentLine
    {
        return BankPaymentLine::create([
            'payment_batch_id' => $batch->id,
            'branch_id' => $branch->id,
            'third_party_id' => $thirdParty->id,
            'nit' => $nit,
            'person_type' => '1',
            'bank_account_number' => $nit.'123',
            'bank_account_type' => 'CA',
            'bank_code' => '007',
            'third_party_name' => $name,
            'amount' => '1000.00',
            'source_sheet' => $branch->name,
            'source_row' => 7,
        ]);
    }

    private function receiptFor(string $thirdPartyName, string $documentNumber = 'DOC-1'): PaymentReceiptData
    {
        return new PaymentReceiptData(
            sourceSheet: 'MERCADEO',
            sourceRow: 8,
            receiptNumber: 'PEL-1',
            paymentDate: '2026-07-02',
            amount: '1000.00',
            concept: null,
            invoices: [new InvoiceData(
                sourceSheet: 'MERCADEO',
                sourceRow: 7,
                paymentDate: '2026-07-02',
                detailDocumentNumber: $documentNumber,
                thirdPartyName: $thirdPartyName,
                supportDocument: 'SOP-1',
                causationDocument: 'CAU-1',
                amount: '1000.00',
                concept: null,
            )],
        );
    }
}
