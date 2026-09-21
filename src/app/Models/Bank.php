<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Bank extends Model
{
    protected $fillable = [
        'code',
        'name',
    ];

    public function accounts(): HasMany
    {
        return $this->hasMany(ThirdPartyBankAccount::class);
    }
}
