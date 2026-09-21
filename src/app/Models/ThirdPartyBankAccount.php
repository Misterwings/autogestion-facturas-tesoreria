<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ThirdPartyBankAccount extends Model
{
    protected $fillable = [
        'third_party_id',
        'bank_id',
        'account_number',
        'account_type',
        'is_primary',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_primary' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function thirdParty(): BelongsTo
    {
        return $this->belongsTo(ThirdParty::class);
    }

    public function bank(): BelongsTo
    {
        return $this->belongsTo(Bank::class);
    }
}
