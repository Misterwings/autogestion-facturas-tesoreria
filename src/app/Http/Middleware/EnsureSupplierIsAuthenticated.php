<?php

namespace App\Http\Middleware;

use App\Models\ThirdParty;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSupplierIsAuthenticated
{
    public function handle(Request $request, Closure $next): Response
    {
        $supplierId = $request->session()->get('supplier_third_party_id');

        if (! is_numeric($supplierId)) {
            return redirect()->guest(route('supplier.login'));
        }

        $supplier = ThirdParty::query()->find((int) $supplierId);

        $passwordVersion = (string) $request->session()->get('supplier_password_version');
        $currentPasswordVersion = $supplier?->password !== null ? hash('sha256', $supplier->password) : '';

        if ($passwordVersion === '' && $currentPasswordVersion !== '') {
            // Upgrade sessions created before credential versioning was introduced.
            $passwordVersion = $currentPasswordVersion;
            $request->session()->put('supplier_password_version', $passwordVersion);
        }

        if ($supplier === null || ! $supplier->is_active || $passwordVersion === '' || ! hash_equals($currentPasswordVersion, $passwordVersion)) {
            $request->session()->forget(['supplier_third_party_id', 'supplier_password_version']);

            return redirect()->guest(route('supplier.login'));
        }

        $request->attributes->set('supplier', $supplier);

        return $next($request);
    }
}
