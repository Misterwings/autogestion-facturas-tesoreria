<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ThirdParty extends Model
{
    protected $fillable = [
        'document_number',
        'person_type',
        'name',
        'alternate_name',
        'password',
        'is_active',
    ];

    protected $hidden = [
        'password',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    public function bankAccounts(): HasMany
    {
        return $this->hasMany(ThirdPartyBankAccount::class);
    }

    public function primaryBankAccount(): HasOne
    {
        return $this->hasOne(ThirdPartyBankAccount::class)
            ->where('is_primary', true)
            ->where('is_active', true);
    }
}
