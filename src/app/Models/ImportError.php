<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ImportError extends Model
{
    protected $fillable = [
        'payment_batch_id',
        'severity',
        'code',
        'message',
        'source_sheet',
        'source_row',
        'context',
    ];

    protected function casts(): array
    {
        return [
            'context' => 'array',
        ];
    }

    public function paymentBatch(): BelongsTo
    {
        return $this->belongsTo(PaymentBatch::class);
    }
}
