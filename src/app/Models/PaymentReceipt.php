<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PaymentReceipt extends Model
{
    protected $fillable = [
        'payment_batch_id',
        'branch_id',
        'third_party_id',
        'beneficiary_document_number',
        'beneficiary_name',
        'beneficiary_person_type',
        'beneficiary_bank_name',
        'beneficiary_bank_code',
        'beneficiary_account_number',
        'beneficiary_account_type',
        'receipt_number',
        'payment_date',
        'amount',
        'concept',
        'source_sheet',
        'source_row',
        'warnings',
    ];

    protected function casts(): array
    {
        return [
            'payment_date' => 'date',
            'amount' => 'decimal:2',
            'warnings' => 'array',
        ];
    }

    public function paymentBatch(): BelongsTo
    {
        return $this->belongsTo(PaymentBatch::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function thirdParty(): BelongsTo
    {
        return $this->belongsTo(ThirdParty::class);
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }
}
