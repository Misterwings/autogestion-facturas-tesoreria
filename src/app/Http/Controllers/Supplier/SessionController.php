<?php

namespace App\Http\Controllers\Supplier;

use App\Http\Controllers\Controller;
use App\Models\ThirdParty;
use App\Payments\Support\SpreadsheetValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class SessionController extends Controller
{
    public function create(Request $request): InertiaResponse|RedirectResponse
    {
        if ($request->session()->has('supplier_third_party_id')) {
            return redirect()->route('supplier.receipts.index');
        }

        return Inertia::render('Supplier/Login');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'document_number' => ['required', 'string', 'max:50'],
            'password' => ['required', 'string'],
        ]);

        $documentNumber = SpreadsheetValue::cleanIdentifier($validated['document_number']);
        $thirdParty = ThirdParty::query()
            ->where('document_number', $documentNumber)
            ->where('is_active', true)
            ->first();

        if ($thirdParty === null || $thirdParty->password === null || ! Hash::check($validated['password'], $thirdParty->password)) {
            throw ValidationException::withMessages([
                'document_number' => 'El NIT/DNI o la contrasena no son correctos.',
            ]);
        }

        $request->session()->regenerate();
        $request->session()->put('supplier_third_party_id', $thirdParty->id);
        $request->session()->put('supplier_password_version', hash('sha256', $thirdParty->password));

        return redirect()->intended(route('supplier.receipts.index'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        $request->session()->forget(['supplier_third_party_id', 'supplier_password_version']);
        $request->session()->regenerateToken();

        return redirect()->route('supplier.login');
    }
}
