<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payment_batches', function (Blueprint $table) {
            $table->string('granada_file_path')->nullable()->after('bank_file_path');
        });
    }

    public function down(): void
    {
        Schema::table('payment_batches', function (Blueprint $table) {
            $table->dropColumn('granada_file_path');
        });
    }
};
