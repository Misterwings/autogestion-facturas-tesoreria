<?php

namespace App\Payments\Actions;

use App\Models\BankPaymentLine;
use App\Models\Branch;
use App\Models\PaymentBatch;
use App\Payments\Contracts\BankPaymentFileFormatterInterface;
use App\Payments\Support\Money;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class GenerateBankPaymentFileAction
{
    public function __construct(private readonly BankPaymentFileFormatterInterface $formatter) {}

    public function execute(PaymentBatch $batch): array
    {
        $batch = DB::transaction(function () use ($batch): PaymentBatch {
            $locked = PaymentBatch::query()->lockForUpdate()->findOrFail($batch->id);
            if ($locked->status === 'generating') {
                throw new RuntimeException('Bank files are already being generated for this batch.');
            }

            $locked->update(['status' => 'generating']);

            return $locked;
        });

        $oldPaths = collect([
            $batch->bank_file_path,
            $batch->granada_file_path,
            ...array_values($batch->branch_file_paths ?? []),
        ])->filter()->values();
        $temporaryPaths = [];

        try {
            [$artifacts, $paths] = $this->artifacts($batch);
            if ($artifacts === []) {
                throw new RuntimeException('The batch has no bank payment lines to export.');
            }

            $disk = Storage::disk('local');
            foreach ($artifacts as $path => $contents) {
                $temporaryPath = $path.'.tmp-'.Str::uuid();
                $temporaryPaths[$path] = $temporaryPath;

                if (! $disk->put($temporaryPath, $contents) || $disk->size($temporaryPath) !== strlen($contents)) {
                    throw new RuntimeException("Unable to verify temporary bank file: {$path}");
                }
            }

            foreach ($temporaryPaths as $path => $temporaryPath) {
                if (! $disk->move($temporaryPath, $path)) {
                    throw new RuntimeException("Unable to publish bank file: {$path}");
                }
            }

            $mainContents = isset($paths['bank_file_path']) ? $artifacts[$paths['bank_file_path']] : null;
            $paths['bank_file_checksum'] = $mainContents !== null ? hash('sha256', $mainContents) : null;
            $paths['bank_file_checksums'] = collect($artifacts)
                ->mapWithKeys(fn (string $contents, string $path): array => [$path => hash('sha256', $contents)])
                ->all();
            $paths['bank_files_generated_at'] = now();
            $paths['status'] = 'ready';
            $batch->update($paths);

            $newPaths = collect(array_keys($artifacts));
            $oldPaths->diff($newPaths)->each(fn (string $path) => $disk->delete($path));

            Log::info('Bank payment files generated', [
                'batch_id' => $batch->id,
                'artifact_count' => count($artifacts),
                'checksum' => $paths['bank_file_checksum'],
            ]);

            return $paths;
        } catch (Throwable $throwable) {
            foreach ($temporaryPaths as $temporaryPath) {
                Storage::disk('local')->delete($temporaryPath);
            }
            $batch->update(['status' => 'generation_failed']);
            Log::error('Bank payment file generation failed', [
                'batch_id' => $batch->id,
                'exception' => $throwable,
            ]);

            throw $throwable;
        }
    }

    /**
     * Aggregate bank reference lines (columns I:N) using the values stored at import time.
     *
     * @param  list<string>  $excludeBranches
     * @return Collection<int, array{nit: string, person_type: string, account_number: string, account_type: string, bank_code: string, amount: int}>
     */
    private function consolidatedRows(PaymentBatch $batch, ?string $onlyBranch = null, array $excludeBranches = []): Collection
    {
        $query = BankPaymentLine::query()
            ->where('bank_payment_lines.payment_batch_id', $batch->id)
            ->join('branches', 'branches.id', '=', 'bank_payment_lines.branch_id');

        if ($onlyBranch !== null) {
            $query->where('branches.name', $onlyBranch);
        } elseif ($excludeBranches !== []) {
            $query->whereNotIn('branches.name', $excludeBranches);
        }

        return $query
            ->select(
                'bank_payment_lines.nit',
                'bank_payment_lines.person_type',
                'bank_payment_lines.bank_account_number as account_number',
                'bank_payment_lines.bank_account_type as account_type',
                'bank_payment_lines.bank_code',
                DB::raw('SUM(bank_payment_lines.amount) as total_amount')
            )
            ->groupBy(
                'bank_payment_lines.nit',
                'bank_payment_lines.person_type',
                'bank_payment_lines.bank_account_number',
                'bank_payment_lines.bank_account_type',
                'bank_payment_lines.bank_code'
            )
            ->orderBy('bank_payment_lines.nit')
            ->orderBy('bank_payment_lines.person_type')
            ->orderBy('bank_payment_lines.bank_account_number')
            ->orderBy('bank_payment_lines.bank_account_type')
            ->orderBy('bank_payment_lines.bank_code')
            ->get()
            ->map(fn (object $row): array => [
                'nit' => $row->nit,
                'person_type' => $row->person_type,
                'account_number' => $row->account_number,
                'account_type' => $row->account_type,
                'bank_code' => $row->bank_code,
                'amount' => Money::roundToWholePeso((string) $row->total_amount),
            ]);
    }

    /**
     * @return array{0: array<string, string>, 1: array{bank_file_path: ?string, granada_file_path: ?string, branch_file_paths: array<string, string>}}
     */
    private function artifacts(PaymentBatch $batch): array
    {
        $artifacts = [];
        $paths = [
            'bank_file_path' => null,
            'granada_file_path' => null,
            'branch_file_paths' => [],
        ];

        $rows = $this->consolidatedRows($batch, excludeBranches: ['GRANADA']);
        if ($rows->isNotEmpty()) {
            $path = "bank-payment-files/payment-batch-{$batch->id}.txt";
            $artifacts[$path] = $this->formatter->format($rows);
            $paths['bank_file_path'] = $path;
        }

        $granadaRows = $this->consolidatedRows($batch, 'GRANADA');
        if ($granadaRows->isNotEmpty()) {
            $path = "bank-payment-files/payment-batch-{$batch->id}-granada.txt";
            $artifacts[$path] = $this->formatter->format($granadaRows);
            $paths['granada_file_path'] = $path;
        }

        foreach ($this->branchesWithPaymentLines($batch) as $branch) {
            $rows = $this->consolidatedRows($batch, $branch->name);

            if ($rows->isEmpty()) {
                continue;
            }

            $path = "bank-payment-files/payment-batch-{$batch->id}-branch-{$branch->id}-".Str::slug($branch->name).'.txt';
            $artifacts[$path] = $this->formatter->format($rows);
            $paths['branch_file_paths'][(string) $branch->id] = $path;
        }

        return [$artifacts, $paths];
    }

    /** @return Collection<int, Branch> */
    private function branchesWithPaymentLines(PaymentBatch $batch): Collection
    {
        return Branch::query()
            ->whereHas('bankPaymentLines', fn ($query) => $query->where('payment_batch_id', $batch->id))
            ->orderBy('name')
            ->get();
    }
}
