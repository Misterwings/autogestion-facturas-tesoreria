<?php

namespace App\Payments\Actions;

use App\Models\PaymentReceipt;
use Barryvdh\DomPDF\Facade\Pdf as DomPdf;
use Barryvdh\DomPDF\PDF as DomPdfDocument;

class GenerateReceiptPdfAction
{
    public function execute(PaymentReceipt $receipt): DomPdfDocument
    {
        $receipt->loadMissing([
            'branch',
            'paymentBatch',
            'thirdParty.primaryBankAccount.bank', // Fallback for receipts imported before snapshots existed.
            'invoices' => fn ($query) => $query->orderBy('source_row'),
        ]);

        return DomPdf::loadView('pdf.payment-receipt', [
            'receipt' => $receipt,
            'logoDataUri' => $this->logoDataUri(),
            'generatedAt' => now(),
        ])->setPaper('letter');
    }

    private function logoDataUri(): ?string
    {
        $path = resource_path('logo_mw.jpg');
        $mime = 'image/jpeg';

        if (! is_file($path) && extension_loaded('gd')) {
            $path = resource_path('logo_mw.png');
            $mime = 'image/png';
        }

        if (! is_file($path)) {
            return null;
        }

        $contents = file_get_contents($path);

        if ($contents === false) {
            return null;
        }

        return 'data:'.$mime.';base64,'.base64_encode($contents);
    }
}
