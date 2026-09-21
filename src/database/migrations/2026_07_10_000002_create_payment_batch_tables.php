<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_batches', function (Blueprint $table) {
            $table->id();
            $table->string('source_file_name');
            $table->string('source_file_path')->nullable();
            $table->date('payment_date')->nullable();
            $table->boolean('has_model_sheet')->default(false);
            $table->string('status')->default('imported');
            $table->unsignedInteger('bank_payment_lines_count')->default(0);
            $table->unsignedInteger('receipts_count')->default(0);
            $table->unsignedInteger('invoices_count')->default(0);
            $table->decimal('bank_payment_total', 18, 2)->default(0);
            $table->decimal('invoice_total', 18, 2)->default(0);
            $table->string('bank_file_path')->nullable();
            $table->timestamp('imported_at')->nullable();
            $table->timestamps();
        });

        Schema::create('payment_receipts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_batch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('third_party_id')->nullable()->constrained()->nullOnDelete();
            $table->string('receipt_number');
            $table->date('payment_date')->nullable();
            $table->decimal('amount', 18, 2);
            $table->string('concept')->nullable();
            $table->string('source_sheet');
            $table->unsignedInteger('source_row');
            $table->json('warnings')->nullable();
            $table->timestamps();

            $table->unique(['payment_batch_id', 'branch_id', 'receipt_number'], 'payment_receipt_unique');
        });

        Schema::create('bank_payment_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_batch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('third_party_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('bank_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('payment_receipt_id')->nullable()->constrained()->nullOnDelete();
            $table->string('nit');
            $table->string('person_type', 1);
            $table->string('bank_account_number');
            $table->string('bank_account_type', 2);
            $table->string('bank_code', 20);
            $table->string('third_party_name')->nullable();
            $table->decimal('amount', 18, 2);
            $table->string('source_sheet');
            $table->unsignedInteger('source_row');
            $table->boolean('has_invoice_detail')->default(false);
            $table->json('warnings')->nullable();
            $table->timestamps();

            $table->index(['payment_batch_id', 'nit']);
            $table->index(['payment_batch_id', 'payment_receipt_id']);
        });

        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_batch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained();
            $table->foreignId('payment_receipt_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('third_party_id')->nullable()->constrained()->nullOnDelete();
            $table->date('payment_date')->nullable();
            $table->string('detail_document_number');
            $table->string('third_party_name');
            $table->string('support_document');
            $table->string('causation_document');
            $table->decimal('amount', 18, 2);
            $table->string('concept')->nullable();
            $table->string('status')->default('paid');
            $table->string('source_sheet');
            $table->unsignedInteger('source_row');
            $table->timestamps();

            $table->index(['payment_batch_id', 'detail_document_number']);
            $table->index(['payment_batch_id', 'causation_document']);
        });

        Schema::create('import_errors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_batch_id')->constrained()->cascadeOnDelete();
            $table->string('severity')->default('warning');
            $table->string('code');
            $table->text('message');
            $table->string('source_sheet')->nullable();
            $table->unsignedInteger('source_row')->nullable();
            $table->json('context')->nullable();
            $table->timestamps();

            $table->index(['payment_batch_id', 'severity']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('import_errors');
        Schema::dropIfExists('invoices');
        Schema::dropIfExists('bank_payment_lines');
        Schema::dropIfExists('payment_receipts');
        Schema::dropIfExists('payment_batches');
    }
};
