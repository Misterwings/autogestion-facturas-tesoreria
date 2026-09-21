<?php

namespace App\Http\Controllers\Supplier;

use App\Http\Controllers\Controller;
use App\Models\PaymentReceipt;
use App\Models\ThirdParty;
use App\Payments\Actions\GenerateReceiptPdfAction;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class ReceiptController extends Controller
{
    public function index(Request $request): InertiaResponse
    {
        $supplier = $this->supplier($request);
        $filters = $request->validate([
            'payment_date' => ['nullable', 'date_format:Y-m-d'],
            'branch_id' => ['nullable', 'integer'],
        ]);

        $baseReceiptsQuery = PaymentReceipt::query()
            ->where('third_party_id', $supplier->id);

        $branches = (clone $baseReceiptsQuery)
            ->join('branches', 'branches.id', '=', 'payment_receipts.branch_id')
            ->select('branches.id', 'branches.name')
            ->distinct()
            ->orderBy('branches.name')
            ->get()
            ->map(fn ($branch): array => [
                'id' => (int) $branch->id,
                'name' => $branch->name,
            ]);

        $receiptsQuery = (clone $baseReceiptsQuery)
            ->when($filters['payment_date'] ?? null, fn ($query, string $paymentDate) => $query->whereDate('payment_date', $paymentDate))
            ->when($filters['branch_id'] ?? null, fn ($query, $branchId) => $query->where('branch_id', $branchId));

        $receipts = (clone $receiptsQuery)
            ->with(['branch', 'paymentBatch'])
            ->withCount('invoices')
            ->orderByDesc('payment_date')
            ->orderByDesc('id')
            ->paginate(15)
            ->withQueryString()
            ->through(fn (PaymentReceipt $receipt): array => [
                'id' => $receipt->id,
                'receipt_number' => $receipt->receipt_number,
                'payment_date' => $receipt->payment_date?->toDateString(),
                'amount' => $receipt->amount,
                'branch' => $receipt->branch?->name,
                'concept' => $receipt->concept,
                'invoices_count' => $receipt->invoices_count,
                'batch' => [
                    'id' => $receipt->paymentBatch?->id,
                    'source_file_name' => $receipt->paymentBatch?->source_file_name,
                ],
            ]);

        return Inertia::render('Supplier/Receipts/Index', [
            'supplier' => [
                'id' => $supplier->id,
                'document_number' => $supplier->document_number,
                'name' => $supplier->name,
            ],
            'filters' => [
                'payment_date' => $filters['payment_date'] ?? '',
                'branch_id' => (string) ($filters['branch_id'] ?? ''),
            ],
            'branches' => $branches,
            'receipts' => $receipts,
            'totals' => [
                'receipts_count' => (clone $receiptsQuery)->count(),
                'amount_total' => (string) (clone $receiptsQuery)->sum('amount'),
            ],
        ]);
    }

    public function download(PaymentReceipt $paymentReceipt, Request $request, GenerateReceiptPdfAction $action)
    {
        $supplier = $this->supplier($request);

        abort_if((int) $paymentReceipt->third_party_id !== $supplier->id, 404);

        return $action->execute($paymentReceipt)->download("comprobante-{$paymentReceipt->receipt_number}.pdf");
    }

    private function supplier(Request $request): ThirdParty
    {
        $supplier = $request->attributes->get('supplier');

        if ($supplier instanceof ThirdParty) {
            return $supplier;
        }

        return ThirdParty::findOrFail($request->session()->get('supplier_third_party_id'));
    }
}
