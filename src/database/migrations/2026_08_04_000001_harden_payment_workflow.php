<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('third_parties', function (Blueprint $table) {
            $table->boolean('is_active')->default(true)->after('password');
        });

        Schema::table('payment_batches', function (Blueprint $table) {
            $table->string('source_file_hash', 64)->nullable()->unique()->after('source_file_path');
            $table->foreignId('imported_by_user_id')->nullable()->after('status')->constrained('users')->nullOnDelete();
            $table->foreignId('approved_by_user_id')->nullable()->after('imported_by_user_id')->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable()->after('approved_by_user_id');
            $table->string('bank_file_checksum', 64)->nullable()->after('bank_file_path');
            $table->json('bank_file_checksums')->nullable()->after('bank_file_checksum');
            $table->timestamp('bank_files_generated_at')->nullable()->after('bank_file_checksums');
        });

        Schema::table('payment_receipts', function (Blueprint $table) {
            $table->string('beneficiary_document_number')->nullable()->after('third_party_id');
            $table->string('beneficiary_name')->nullable()->after('beneficiary_document_number');
            $table->string('beneficiary_person_type', 1)->nullable()->after('beneficiary_name');
            $table->string('beneficiary_bank_name')->nullable()->after('beneficiary_person_type');
            $table->string('beneficiary_bank_code', 20)->nullable()->after('beneficiary_bank_name');
            $table->string('beneficiary_account_number')->nullable()->after('beneficiary_bank_code');
            $table->string('beneficiary_account_type', 2)->nullable()->after('beneficiary_account_number');
            $table->index(['third_party_id', 'payment_date', 'branch_id'], 'payment_receipts_supplier_filter_index');
        });

        DB::table('bank_payment_lines')
            ->leftJoin('banks', 'banks.id', '=', 'bank_payment_lines.bank_id')
            ->whereNotNull('bank_payment_lines.payment_receipt_id')
            ->select([
                'bank_payment_lines.id',
                'bank_payment_lines.payment_receipt_id',
                'bank_payment_lines.nit',
                'bank_payment_lines.third_party_name',
                'bank_payment_lines.person_type',
                'bank_payment_lines.bank_code',
                'bank_payment_lines.bank_account_number',
                'bank_payment_lines.bank_account_type',
                'banks.name as bank_name',
            ])
            ->orderBy('bank_payment_lines.id')
            ->chunkById(500, function ($lines): void {
                foreach ($lines as $line) {
                    DB::table('payment_receipts')
                        ->where('id', $line->payment_receipt_id)
                        ->update([
                            'beneficiary_document_number' => $line->nit,
                            'beneficiary_name' => $line->third_party_name,
                            'beneficiary_person_type' => $line->person_type,
                            'beneficiary_bank_name' => $line->bank_name,
                            'beneficiary_bank_code' => $line->bank_code,
                            'beneficiary_account_number' => $line->bank_account_number,
                            'beneficiary_account_type' => $line->bank_account_type,
                        ]);
                }
            }, 'bank_payment_lines.id', 'id');

        DB::table('payment_receipts')
            ->join('third_parties', 'third_parties.id', '=', 'payment_receipts.third_party_id')
            ->whereNull('payment_receipts.beneficiary_document_number')
            ->select([
                'payment_receipts.id',
                'third_parties.document_number',
                'third_parties.name',
                'third_parties.person_type',
            ])
            ->orderBy('payment_receipts.id')
            ->chunkById(500, function ($receipts): void {
                foreach ($receipts as $receipt) {
                    DB::table('payment_receipts')
                        ->where('id', $receipt->id)
                        ->update([
                            'beneficiary_document_number' => $receipt->document_number,
                            'beneficiary_name' => $receipt->name,
                            'beneficiary_person_type' => $receipt->person_type,
                        ]);
                }
            }, 'payment_receipts.id', 'id');

        DB::table('third_party_bank_accounts')
            ->where('is_primary', true)
            ->orderBy('id')
            ->get(['id', 'third_party_id'])
            ->groupBy('third_party_id')
            ->each(function ($accounts): void {
                DB::table('third_party_bank_accounts')
                    ->whereIn('id', $accounts->pluck('id')->slice(1))
                    ->update(['is_primary' => false]);
            });

        if (in_array(DB::getDriverName(), ['pgsql', 'sqlite'], true)) {
            DB::statement('CREATE UNIQUE INDEX third_party_one_primary_account ON third_party_bank_accounts (third_party_id) WHERE is_primary = true');
        }
    }

    public function down(): void
    {
        if (in_array(DB::getDriverName(), ['pgsql', 'sqlite'], true)) {
            DB::statement('DROP INDEX IF EXISTS third_party_one_primary_account');
        }

        Schema::table('payment_receipts', function (Blueprint $table) {
            $table->dropIndex('payment_receipts_supplier_filter_index');
            $table->dropColumn([
                'beneficiary_document_number',
                'beneficiary_name',
                'beneficiary_person_type',
                'beneficiary_bank_name',
                'beneficiary_bank_code',
                'beneficiary_account_number',
                'beneficiary_account_type',
            ]);
        });

        Schema::table('payment_batches', function (Blueprint $table) {
            $table->dropForeign(['imported_by_user_id']);
            $table->dropForeign(['approved_by_user_id']);
            $table->dropUnique(['source_file_hash']);
            $table->dropColumn([
                'source_file_hash',
                'imported_by_user_id',
                'approved_by_user_id',
                'approved_at',
                'bank_file_checksum',
                'bank_file_checksums',
                'bank_files_generated_at',
            ]);
        });

        Schema::table('third_parties', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
