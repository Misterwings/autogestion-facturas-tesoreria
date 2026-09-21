<?php

namespace App\Http\Middleware;

use App\Models\ThirdParty;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    protected $rootView = 'app';

    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    public function share(Request $request): array
    {
        $supplier = $request->attributes->get('supplier');

        if (! $supplier instanceof ThirdParty && $request->session()->has('supplier_third_party_id')) {
            $supplier = ThirdParty::query()->find($request->session()->get('supplier_third_party_id'));
        }

        return [
            ...parent::share($request),
            'auth' => [
                'user' => $request->user() !== null ? [
                    'id' => $request->user()->id,
                    'name' => $request->user()->name,
                    'email' => $request->user()->email,
                ] : null,
            ],
            'supplier' => $supplier instanceof ThirdParty ? [
                'id' => $supplier->id,
                'document_number' => $supplier->document_number,
                'name' => $supplier->name,
            ] : null,
            'flash' => [
                'success' => $request->session()->get('success'),
                'error' => $request->session()->get('error'),
            ],
        ];
    }
}
