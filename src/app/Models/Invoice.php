<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Invoice extends Model
{
    protected $fillable = [
        'payment_batch_id',
        'branch_id',
        'payment_receipt_id',
        'third_party_id',
        'payment_date',
        'detail_document_number',
        'third_party_name',
        'support_document',
        'causation_document',
        'amount',
        'concept',
        'status',
        'source_sheet',
        'source_row',
    ];

    protected function casts(): array
    {
        return [
            'payment_date' => 'date',
            'amount' => 'decimal:2',
        ];
    }

    public function paymentBatch(): BelongsTo
    {
        return $this->belongsTo(PaymentBatch::class);
    }

    public function paymentReceipt(): BelongsTo
    {
        return $this->belongsTo(PaymentReceipt::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function thirdParty(): BelongsTo
    {
        return $this->belongsTo(ThirdParty::class);
    }
}
