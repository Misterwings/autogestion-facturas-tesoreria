<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('banks', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20)->unique();
            $table->string('name');
            $table->timestamps();
        });

        Schema::create('branches', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->timestamps();
        });

        Schema::create('third_parties', function (Blueprint $table) {
            $table->id();
            $table->string('document_number')->unique();
            $table->string('person_type', 1);
            $table->string('name');
            $table->timestamps();
        });

        Schema::create('third_party_bank_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('third_party_id')->constrained()->cascadeOnDelete();
            $table->foreignId('bank_id')->constrained();
            $table->string('account_number');
            $table->string('account_type', 2);
            $table->boolean('is_primary')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['third_party_id', 'bank_id', 'account_number', 'account_type'], 'third_party_bank_account_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('third_party_bank_accounts');
        Schema::dropIfExists('third_parties');
        Schema::dropIfExists('branches');
        Schema::dropIfExists('banks');
    }
};
