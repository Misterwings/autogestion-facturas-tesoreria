<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payment_batches', function (Blueprint $table) {
            $table->json('branch_file_paths')->nullable()->after('granada_file_path');
        });
    }

    public function down(): void
    {
        Schema::table('payment_batches', function (Blueprint $table) {
            $table->dropColumn('branch_file_paths');
        });
    }
};
