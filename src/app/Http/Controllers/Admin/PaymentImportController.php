<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Models\ThirdParty;
use App\Payments\Actions\GenerateBankPaymentFileAction;
use App\Payments\Actions\ImportPaymentBatchAction;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;
use LogicException;
use Throwable;

class PaymentImportController extends Controller
{
    public function index(): Response
    {
        $batches = PaymentBatch::query()
            ->withCount('importErrors')
            ->latest('id')
            ->paginate(15)
            ->through(fn (PaymentBatch $batch): array => [
                'id' => $batch->id,
                'source_file_name' => $batch->source_file_name,
                'payment_date' => $batch->payment_date?->toDateString(),
                'has_model_sheet' => $batch->has_model_sheet,
                'status' => $batch->status,
                'bank_payment_lines_count' => $batch->bank_payment_lines_count,
                'receipts_count' => $batch->receipts_count,
                'invoices_count' => $batch->invoices_count,
                'bank_payment_total' => $batch->bank_payment_total,
                'invoice_total' => $batch->invoice_total,
                'import_errors_count' => $batch->import_errors_count,
                'can_delete' => $batch->status !== 'generating',
                'imported_at' => $batch->imported_at?->format('Y-m-d H:i'),
            ]);

        $catalogCount = ThirdParty::query()->where('is_active', true)->count();

        return Inertia::render('Admin/Imports/Index', [
            'batches' => $batches,
            'catalogCount' => $catalogCount,
        ]);
    }

    public function store(Request $request, ImportPaymentBatchAction $importer, GenerateBankPaymentFileAction $bankFileGenerator): RedirectResponse
    {
        $validated = $request->validate([
            'file' => ['required', 'file', 'mimes:xlsx', 'max:51200'],
            'payment_date' => ['nullable', 'date_format:Y-m-d'],
        ]);

        $uploadedFile = $request->file('file');
        $originalName = $uploadedFile->getClientOriginalName();
        $path = $uploadedFile->storeAs('imports', Str::uuid()->toString().'.xlsx', 'local');

        try {
            $batch = $importer->execute(
                Storage::disk('local')->path($path),
                $validated['payment_date'] ?? null,
                $originalName,
                $request->user()?->id,
            );
        } catch (LogicException $exception) {
            Storage::disk('local')->delete($path);

            return back()->with('error', $exception->getMessage());
        } catch (Throwable $throwable) {
            Storage::disk('local')->delete($path);

            report($throwable);

            return back()->with('error', 'No fue posible importar el archivo. Revisa que sea un Excel valido de pagos.');
        }

        if ($batch->status === 'validated') {
            $batch->update([
                'status' => 'approved',
                'approved_by_user_id' => $request->user()?->id,
                'approved_at' => now(),
            ]);

            try {
                $bankFileGenerator->execute($batch);
            } catch (Throwable $throwable) {
                report($throwable);

                return redirect()
                    ->route('admin.imports.show', $batch)
                    ->with('error', 'La importacion termino, pero no fue posible generar los archivos bancarios.');
            }
        }

        return redirect()
            ->route('admin.imports.show', $batch)
            ->with(
                $batch->status === 'needs_review' ? 'error' : 'success',
                $batch->status === 'needs_review'
                    ? "Importacion #{$batch->id} requiere revision y aprobacion antes de generar los TXT."
                    : "Importacion #{$batch->id} creada correctamente.",
            );
    }

    public function show(PaymentBatch $paymentBatch): Response
    {
        $paymentBatch->loadCount('importErrors');

        $branchTotals = $paymentBatch->bankPaymentLines()
            ->join('branches', 'branches.id', '=', 'bank_payment_lines.branch_id')
            ->selectRaw('branches.id as branch_id, branches.name as branch, count(*) as lines_count, sum(bank_payment_lines.amount) as total')
            ->groupBy('branches.id', 'branches.name')
            ->orderBy('branches.name')
            ->get()
            ->map(fn ($row): array => [
                'branch_id' => (int) $row->branch_id,
                'branch' => $row->branch,
                'lines_count' => (int) $row->lines_count,
                'total' => (string) $row->total,
            ]);

        $errors = $paymentBatch->importErrors()
            ->latest('id')
            ->paginate(50, ['*'], 'errors_page')
            ->withQueryString()
            ->through(fn ($error): array => [
                'id' => $error->id,
                'severity' => $error->severity,
                'code' => $error->code,
                'message' => $error->message,
                'source_sheet' => $error->source_sheet,
                'source_row' => $error->source_row,
            ]);

        $bankPaymentLines = $paymentBatch->bankPaymentLines()
            ->with('branch')
            ->orderBy('source_sheet')
            ->orderBy('source_row')
            ->paginate(50, ['*'], 'bank_lines_page')
            ->withQueryString()
            ->through(fn ($line): array => [
                'id' => $line->id,
                'branch' => $line->branch?->name,
                'nit' => $line->nit,
                'person_type' => $line->person_type,
                'bank_account_number' => $line->bank_account_number,
                'bank_account_type' => $line->bank_account_type,
                'bank_code' => $line->bank_code,
                'third_party_name' => $line->third_party_name,
                'amount' => $line->amount,
                'has_invoice_detail' => $line->has_invoice_detail,
                'source_row' => $line->source_row,
            ]);

        $receipts = $paymentBatch->paymentReceipts()
            ->with(['branch', 'thirdParty'])
            ->withCount('invoices')
            ->orderBy('source_sheet')
            ->orderBy('source_row')
            ->paginate(50, ['*'], 'receipts_page')
            ->withQueryString()
            ->through(fn ($receipt): array => [
                'id' => $receipt->id,
                'receipt_number' => $receipt->receipt_number,
                'branch' => $receipt->branch?->name,
                'third_party' => $receipt->thirdParty?->name,
                'nit' => $receipt->thirdParty?->document_number,
                'amount' => $receipt->amount,
                'payment_date' => $receipt->payment_date?->toDateString(),
                'invoices_count' => $receipt->invoices_count,
            ]);

        return Inertia::render('Admin/Imports/Show', [
            'batch' => [
                'id' => $paymentBatch->id,
                'source_file_name' => $paymentBatch->source_file_name,
                'payment_date' => $paymentBatch->payment_date?->toDateString(),
                'has_model_sheet' => $paymentBatch->has_model_sheet,
                'status' => $paymentBatch->status,
                'bank_payment_lines_count' => $paymentBatch->bank_payment_lines_count,
                'receipts_count' => $paymentBatch->receipts_count,
                'invoices_count' => $paymentBatch->invoices_count,
                'bank_payment_total' => $paymentBatch->bank_payment_total,
                'invoice_total' => $paymentBatch->invoice_total,
                'import_errors_count' => $paymentBatch->import_errors_count,
                'can_approve' => $paymentBatch->status === 'needs_review',
                'can_delete' => $paymentBatch->status !== 'generating',
                'imported_at' => $paymentBatch->imported_at?->format('Y-m-d H:i'),
            ],
            'branchTotals' => $branchTotals,
            'errors' => $errors,
            'bankPaymentLines' => $bankPaymentLines,
            'receipts' => $receipts,
        ]);
    }

    public function downloadBankFile(PaymentBatch $paymentBatch)
    {
        if ($paymentBatch->bank_file_path === null || ! Storage::disk('local')->exists($paymentBatch->bank_file_path)) {
            return back()->with('error', 'El archivo no existe. Aprueba el lote o regeneralo desde consola.');
        }

        return Storage::disk('local')->download(
            $paymentBatch->bank_file_path,
            "payment-batch-{$paymentBatch->id}.txt",
            ['Content-Type' => 'text/plain; charset=UTF-8'],
        );
    }

    public function downloadGranadaFile(PaymentBatch $paymentBatch)
    {
        if ($paymentBatch->granada_file_path === null || ! Storage::disk('local')->exists($paymentBatch->granada_file_path)) {
            return back()->with('error', 'No hay un archivo de GRANADA disponible para descargar.');
        }

        if ($paymentBatch->granada_file_path === null) {
            return back()->with('error', 'No hay datos de GRANADA para generar el archivo.');
        }

        return Storage::disk('local')->download(
            $paymentBatch->granada_file_path,
            "payment-batch-{$paymentBatch->id}-granada.txt",
            ['Content-Type' => 'text/plain; charset=UTF-8'],
        );
    }

    public function downloadBranchBankFile(PaymentBatch $paymentBatch, Branch $branch)
    {
        if (! $paymentBatch->bankPaymentLines()->where('branch_id', $branch->id)->exists()) {
            return back()->with('error', 'No hay datos para generar el archivo de esta sede.');
        }

        $path = $paymentBatch->branch_file_paths[(string) $branch->id] ?? null;

        if ($path === null || ! Storage::disk('local')->exists($path)) {
            return back()->with('error', 'El archivo de esta sede no existe. Regenera los archivos del lote.');
        }

        if ($path === null) {
            return back()->with('error', 'No fue posible generar el archivo de esta sede.');
        }

        return Storage::disk('local')->download(
            $path,
            'payment-batch-'.$paymentBatch->id.'-'.Str::slug($branch->name).'.txt',
            ['Content-Type' => 'text/plain; charset=UTF-8'],
        );
    }

    public function approve(Request $request, PaymentBatch $paymentBatch, GenerateBankPaymentFileAction $bankFileGenerator): RedirectResponse
    {
        $approved = DB::transaction(function () use ($request, $paymentBatch): bool {
            $batch = PaymentBatch::query()->lockForUpdate()->findOrFail($paymentBatch->id);
            if ($batch->status !== 'needs_review') {
                return false;
            }

            $batch->update([
                'status' => 'approved',
                'approved_by_user_id' => $request->user()?->id,
                'approved_at' => now(),
            ]);

            return true;
        });

        if (! $approved) {
            return back()->with('error', 'El lote ya fue aprobado o no esta pendiente de revision.');
        }

        try {
            $bankFileGenerator->execute($paymentBatch->refresh());
        } catch (Throwable $throwable) {
            report($throwable);

            return back()->with('error', 'El lote fue aprobado, pero fallo la generacion de los archivos bancarios.');
        }

        return back()->with('success', "Lote #{$paymentBatch->id} aprobado y archivos bancarios generados.");
    }

    public function destroy(Request $request, PaymentBatch $paymentBatch): RedirectResponse
    {
        $paths = DB::transaction(function () use ($paymentBatch): ?array {
            $batch = PaymentBatch::query()->lockForUpdate()->findOrFail($paymentBatch->id);
            if ($batch->status === 'generating') {
                return null;
            }

            $paths = collect([
                $batch->bank_file_path,
                $batch->granada_file_path,
                ...array_values($batch->branch_file_paths ?? []),
                $this->localSourcePath($batch->source_file_path),
            ])->filter(fn ($path): bool => is_string($path) && $path !== '')
                ->unique()
                ->values()
                ->all();

            $batch->delete();

            return $paths;
        });

        if ($paths === null) {
            return back()->with('error', 'No se puede eliminar un lote mientras se generan sus archivos.');
        }

        Storage::disk('local')->delete($paths);
        Log::info('Payment batch deleted', [
            'batch_id' => $paymentBatch->id,
            'actor_id' => $request->user()?->id,
            'deleted_files' => count($paths),
        ]);

        return redirect()->route('admin.imports.index')->with('success', "Lote #{$paymentBatch->id} eliminado correctamente.");
    }

    private function localSourcePath(?string $sourcePath): ?string
    {
        if ($sourcePath === null || $sourcePath === '' || str_contains($sourcePath, '..')) {
            return null;
        }

        $sourcePath = str_replace('\\', '/', $sourcePath);
        if (preg_match('/^[A-Za-z]:\//', $sourcePath) === 1) {
            return null;
        }

        if (! str_starts_with($sourcePath, '/')) {
            return ltrim($sourcePath, '/');
        }

        $localRoot = rtrim(str_replace('\\', '/', Storage::disk('local')->path('')), '/');
        if (! str_starts_with($sourcePath, $localRoot.'/')) {
            return null;
        }

        return ltrim(substr($sourcePath, strlen($localRoot)), '/');
    }
}
