<?php

namespace App\Payments\Parsers;

use App\Payments\DTO\InvoiceData;
use App\Payments\DTO\PaymentReceiptData;
use App\Payments\DTO\SpreadsheetRow;
use App\Payments\Support\ExcelSerialDate;
use App\Payments\Support\Money;
use App\Payments\Support\SpreadsheetValue;
use InvalidArgumentException;
use Traversable;

class InvoiceDetailParser
{
    /**
     * @param  Traversable<SpreadsheetRow>  $rows
     * @return list<PaymentReceiptData>
     */
    public function parse(string $sheetName, Traversable $rows, array &$warnings = []): array
    {
        $receipts = [];
        $pendingInvoices = [];

        foreach ($rows as $row) {
            if ($row->number <= 6) {
                continue;
            }

            if ($this->isInvoiceRow($row)) {
                try {
                    $amount = Money::normalizeSigned($row->value(7));
                } catch (InvalidArgumentException) {
                    $warnings[] = $this->warning('invalid_invoice_amount', 'Invoice amount must be non-zero and have at most two decimal places.', $row->number);

                    continue;
                }

                $pendingInvoices[] = new InvoiceData(
                    sourceSheet: $sheetName,
                    sourceRow: $row->number,
                    paymentDate: ExcelSerialDate::toDateString($row->value(2)),
                    detailDocumentNumber: SpreadsheetValue::cleanIdentifier($row->value(3)),
                    thirdPartyName: $row->value(4),
                    supportDocument: $row->value(5),
                    causationDocument: $row->value(6),
                    amount: $amount,
                    concept: $row->value(8) !== '' ? $row->value(8) : null,
                );

                continue;
            }

            if ($this->isReceiptCandidate($row)) {
                if (! SpreadsheetValue::isNumeric($row->value(7))) {
                    $warnings[] = $this->warning('invalid_receipt_amount', 'Receipt amount is not numeric.', $row->number);

                    continue;
                }

                if ($pendingInvoices === []) {
                    $warnings[] = $this->warning('receipt_without_invoices', 'Receipt has no preceding invoice rows.', $row->number);

                    continue;
                }

                try {
                    $receiptAmount = SpreadsheetValue::decimal($row->value(7));
                } catch (InvalidArgumentException) {
                    $warnings[] = $this->warning('invalid_receipt_amount', 'Receipt amount must be positive and have at most two decimal places.', $row->number);

                    continue;
                }

                $receiptWarnings = [];
                $invoiceTotal = array_reduce(
                    $pendingInvoices,
                    fn (int $total, InvoiceData $invoice): int => $total + Money::centsSigned($invoice->amount),
                    0,
                );

                if (Money::cents($receiptAmount) !== $invoiceTotal) {
                    $receiptWarnings[] = 'receipt_amount_differs_from_invoice_total';
                }

                $receipts[] = new PaymentReceiptData(
                    sourceSheet: $sheetName,
                    sourceRow: $row->number,
                    receiptNumber: $row->value(2),
                    paymentDate: $pendingInvoices[0]->paymentDate,
                    amount: $receiptAmount,
                    concept: $row->value(8) !== '' ? $row->value(8) : null,
                    invoices: $pendingInvoices,
                    warnings: $receiptWarnings ?? [],
                );

                $pendingInvoices = [];
                unset($receiptWarnings);

                continue;
            }

            if ($this->hasInvoiceData($row) && ! $this->isSummaryRow($row)) {
                $warnings[] = $this->warning('invalid_invoice_row', 'Invoice row is incomplete or contains an invalid value.', $row->number);
            }
        }

        if ($pendingInvoices !== []) {
            $warnings[] = $this->warning(
                'invoices_without_receipt',
                count($pendingInvoices).' invoice row(s) were not followed by a valid PEL receipt.',
                $pendingInvoices[0]->sourceRow,
            );
        }

        return $receipts;
    }

    private function isInvoiceRow(SpreadsheetRow $row): bool
    {
        return SpreadsheetValue::isNumeric($row->value(2))
            && $row->value(3) !== ''
            && $row->value(5) !== ''
            && $row->value(6) !== ''
            && SpreadsheetValue::isNumeric($row->value(7));
    }

    private function isReceiptCandidate(SpreadsheetRow $row): bool
    {
        return preg_match('/(?:^|[-_\s])PEL(?:$|[-_\s])/i', trim($row->value(2))) === 1;
    }

    private function hasInvoiceData(SpreadsheetRow $row): bool
    {
        return collect(range(2, 8))->contains(fn (int $column): bool => $row->value($column) !== '');
    }

    private function isSummaryRow(SpreadsheetRow $row): bool
    {
        return in_array(mb_strtolower(trim($row->value(2))), ['gran total', 'total'], true)
            || mb_strtolower(trim($row->value(6))) === 'pago total';
    }

    /** @return array{code: string, message: string, row: int, severity: string} */
    private function warning(string $code, string $message, int $row): array
    {
        return compact('code', 'message', 'row') + ['severity' => 'warning'];
    }
}
