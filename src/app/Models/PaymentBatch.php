<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PaymentBatch extends Model
{
    protected $fillable = [
        'source_file_name',
        'source_file_path',
        'source_file_hash',
        'payment_date',
        'has_model_sheet',
        'status',
        'imported_by_user_id',
        'approved_by_user_id',
        'approved_at',
        'bank_payment_lines_count',
        'receipts_count',
        'invoices_count',
        'bank_payment_total',
        'invoice_total',
        'bank_file_path',
        'bank_file_checksum',
        'bank_file_checksums',
        'bank_files_generated_at',
        'granada_file_path',
        'branch_file_paths',
        'imported_at',
    ];

    protected function casts(): array
    {
        return [
            'payment_date' => 'date',
            'has_model_sheet' => 'boolean',
            'bank_payment_total' => 'decimal:2',
            'invoice_total' => 'decimal:2',
            'branch_file_paths' => 'array',
            'bank_file_checksums' => 'array',
            'imported_at' => 'datetime',
            'approved_at' => 'datetime',
            'bank_files_generated_at' => 'datetime',
        ];
    }

    public function bankPaymentLines(): HasMany
    {
        return $this->hasMany(BankPaymentLine::class);
    }

    public function paymentReceipts(): HasMany
    {
        return $this->hasMany(PaymentReceipt::class);
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }

    public function importErrors(): HasMany
    {
        return $this->hasMany(ImportError::class);
    }

    public function importedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'imported_by_user_id');
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by_user_id');
    }
}
