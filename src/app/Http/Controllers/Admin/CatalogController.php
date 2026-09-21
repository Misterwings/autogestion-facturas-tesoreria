<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bank;
use App\Models\ThirdParty;
use App\Models\ThirdPartyBankAccount;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Importers\CatalogImporter;
use App\Payments\Parsers\ModelSheetParser;
use App\Payments\Support\SpreadsheetValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;
use Throwable;

class CatalogController extends Controller
{
    public function index(Request $request): Response
    {
        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:50', 'regex:/^[A-Za-z0-9.\- ]+$/'],
        ]);
        $search = SpreadsheetValue::cleanIdentifier((string) ($validated['search'] ?? ''));

        $thirdParties = ThirdParty::query()
            ->where('is_active', true)
            ->when($search !== '', fn ($query) => $query->where('document_number', 'like', '%'.$search.'%'))
            ->with('primaryBankAccount.bank')
            ->orderBy('document_number')
            ->paginate(50)
            ->withQueryString()
            ->through(fn (ThirdParty $tp): array => [
                'id' => $tp->id,
                'document_number' => $tp->document_number,
                'person_type' => $tp->person_type,
                'name' => $tp->name,
                'alternate_name' => $tp->alternate_name,
                'has_password' => $tp->password !== null,
                'bank_account' => $tp->primaryBankAccount?->account_number,
                'bank_account_type' => $tp->primaryBankAccount?->account_type,
                'bank_name' => $tp->primaryBankAccount?->bank?->name,
                'bank_code' => $tp->primaryBankAccount?->bank?->code,
            ]);

        return Inertia::render('Admin/Catalog/Index', [
            'thirdParties' => $thirdParties,
            'filters' => [
                'search' => $search,
            ],
            'stats' => [
                'third_parties_count' => ThirdParty::query()->where('is_active', true)->count(),
                'banks_count' => Bank::count(),
                'accounts_count' => ThirdPartyBankAccount::query()
                    ->where('is_active', true)
                    ->whereHas('thirdParty', fn ($query) => $query->where('is_active', true))
                    ->count(),
            ],
        ]);
    }

    public function seed(
        Request $request,
        ModelSheetParser $modelSheetParser,
        ExcelWorkbookReaderFactoryInterface $readerFactory,
        CatalogImporter $catalogImporter,
    ): RedirectResponse {
        $validated = $request->validate([
            'file' => ['required', 'file', 'mimes:xlsx', 'max:51200'],
        ]);

        $uploadedFile = $request->file('file');
        $path = $uploadedFile->storeAs('imports', 'modelo-'.Str::uuid().'.xlsx', 'local');

        try {
            $reader = $readerFactory->open(Storage::disk('local')->path($path));
            $sheetNames = $reader->sheetNames();

            if (! in_array('MODELO', $sheetNames, true)) {
                Storage::disk('local')->delete($path);

                return back()->with('error', 'El archivo no contiene la hoja MODELO.');
            }

            $modelThirdParties = $modelSheetParser->parse($reader->rows('MODELO'));

            if (count($modelThirdParties) === 0) {
                Storage::disk('local')->delete($path);

                return back()->with('error', 'No se encontraron terceros en la hoja MODELO.');
            }

            DB::transaction(function () use ($modelThirdParties, $catalogImporter): void {
                foreach ($modelThirdParties as $thirdParty) {
                    $catalogImporter->importModelThirdParty($thirdParty);
                }
            });

            Storage::disk('local')->delete($path);

            $count = count($modelThirdParties);

            return back()->with('success', "Catalogo actualizado: {$count} registros desde MODELO.");
        } catch (Throwable $e) {
            Storage::disk('local')->delete($path);

            report($e);

            return back()->with('error', 'No fue posible procesar el archivo MODELO.');
        }
    }

    public function update(Request $request, ThirdParty $thirdParty): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'not_regex:/[\x00-\x1F\x7F]/'],
            'alternate_name' => ['nullable', 'string', 'max:255', 'not_regex:/[\x00-\x1F\x7F]/'],
            'person_type' => ['required', 'in:1,2'],
            'bank_account_number' => ['required', 'string', 'max:50', 'regex:/^[A-Za-z0-9.\-]+$/'],
            'bank_account_type' => ['required', 'in:CA,CC'],
            'bank_code' => ['required', 'string', 'max:20', 'regex:/^[A-Za-z0-9.\-]+$/'],
            'password' => ['nullable', 'string', 'min:8', 'max:255', 'confirmed'],
        ]);
        $alternateName = trim((string) ($validated['alternate_name'] ?? ''));

        $thirdPartyData = [
            'name' => $validated['name'],
            'alternate_name' => $alternateName !== '' ? $alternateName : null,
            'person_type' => $validated['person_type'],
        ];

        if ($request->filled('password')) {
            $thirdPartyData['password'] = $validated['password'];
        }

        DB::transaction(function () use ($thirdParty, $thirdPartyData, $validated): void {
            $thirdParty->update($thirdPartyData);

            $bank = Bank::firstOrCreate(
                ['code' => $validated['bank_code']],
                ['name' => 'Banco '.$validated['bank_code']],
            );

            $thirdParty->bankAccounts()->lockForUpdate()->get();
            $thirdParty->bankAccounts()->update(['is_primary' => false]);

            ThirdPartyBankAccount::updateOrCreate(
                [
                    'third_party_id' => $thirdParty->id,
                    'bank_id' => $bank->id,
                    'account_number' => $validated['bank_account_number'],
                    'account_type' => $validated['bank_account_type'],
                ],
                [
                    'is_primary' => true,
                    'is_active' => true,
                ],
            );
        });

        return back()->with('success', 'Tercero actualizado correctamente.');
    }

    public function destroy(ThirdParty $thirdParty): RedirectResponse
    {
        $thirdParty->update([
            'is_active' => false,
            'password' => null,
        ]);

        return back()->with('success', 'Tercero desactivado. Su historial fue conservado.');
    }
}
