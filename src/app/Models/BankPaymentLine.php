<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BankPaymentLine extends Model
{
    protected $fillable = [
        'payment_batch_id',
        'branch_id',
        'third_party_id',
        'bank_id',
        'payment_receipt_id',
        'nit',
        'person_type',
        'bank_account_number',
        'bank_account_type',
        'bank_code',
        'third_party_name',
        'amount',
        'source_sheet',
        'source_row',
        'has_invoice_detail',
        'warnings',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'has_invoice_detail' => 'boolean',
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

    public function bank(): BelongsTo
    {
        return $this->belongsTo(Bank::class);
    }

    public function paymentReceipt(): BelongsTo
    {
        return $this->belongsTo(PaymentReceipt::class);
    }
}
