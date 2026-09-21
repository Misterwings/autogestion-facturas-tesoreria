<?php

use App\Http\Controllers\Admin\CatalogController;
use App\Http\Controllers\Admin\PaymentImportController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Supplier\ReceiptController as SupplierReceiptController;
use App\Http\Controllers\Supplier\SessionController as SupplierSessionController;
use App\Models\PaymentReceipt;
use App\Payments\Actions\GenerateReceiptPdfAction;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthenticatedSessionController::class, 'create'])->name('login');
    Route::post('/login', [AuthenticatedSessionController::class, 'store'])->middleware('throttle:login')->name('login.store');
});

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])->middleware('auth')->name('logout');

Route::prefix('proveedor')->name('supplier.')->group(function () {
    Route::get('/', [SupplierSessionController::class, 'create'])->name('entry');
    Route::get('/login', [SupplierSessionController::class, 'create'])->name('login');
    Route::post('/login', [SupplierSessionController::class, 'store'])->middleware('throttle:login')->name('login.store');

    Route::middleware('supplier')->group(function () {
        Route::post('/logout', [SupplierSessionController::class, 'destroy'])->name('logout');
        Route::get('/comprobantes', [SupplierReceiptController::class, 'index'])->name('receipts.index');
        Route::get('/comprobantes/{paymentReceipt}/pdf', [SupplierReceiptController::class, 'download'])->name('receipts.pdf');
    });
});

Route::prefix('admin')->middleware(['auth', 'can:manage-payments'])->name('admin.')->group(function () {
    Route::redirect('/', '/admin/imports');

    Route::get('/imports', [PaymentImportController::class, 'index'])->name('imports.index');
    Route::post('/imports', [PaymentImportController::class, 'store'])->name('imports.store');
    Route::get('/imports/{paymentBatch}', [PaymentImportController::class, 'show'])->name('imports.show');
    Route::delete('/imports/{paymentBatch}', [PaymentImportController::class, 'destroy'])->name('imports.destroy');
    Route::post('/imports/{paymentBatch}/approve', [PaymentImportController::class, 'approve'])->name('imports.approve');
    Route::get('/imports/{paymentBatch}/bank-file', [PaymentImportController::class, 'downloadBankFile'])->name('imports.bank-file');
    Route::get('/imports/{paymentBatch}/bank-file/branches/{branch}', [PaymentImportController::class, 'downloadBranchBankFile'])->name('imports.branch-bank-file');
    Route::get('/imports/{paymentBatch}/granada-file', [PaymentImportController::class, 'downloadGranadaFile'])->name('imports.granada-file');

    Route::get('/catalog', [CatalogController::class, 'index'])->name('catalog.index');
    Route::post('/catalog/seed', [CatalogController::class, 'seed'])->name('catalog.seed');
    Route::put('/catalog/{thirdParty}', [CatalogController::class, 'update'])->name('catalog.update');
    Route::delete('/catalog/{thirdParty}', [CatalogController::class, 'destroy'])->name('catalog.destroy');

    Route::get('/payment-receipts/{paymentReceipt}/pdf', function (PaymentReceipt $paymentReceipt, GenerateReceiptPdfAction $action) {
        return $action->execute($paymentReceipt)->download("comprobante-{$paymentReceipt->receipt_number}.pdf");
    })->name('payment-receipts.pdf');
});
