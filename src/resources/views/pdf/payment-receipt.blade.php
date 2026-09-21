<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8">
        <style>
            @page { margin: 28px 32px; }

            * { box-sizing: border-box; }
            body { margin: 0; font-family: DejaVu Sans, sans-serif; color: #111827; font-size: 11px; line-height: 1.45; }
            h1, h2, h3, p { margin: 0; }
            table { width: 100%; border-collapse: collapse; }

            .header { border-radius: 18px; background: #07111f; color: #ffffff; padding: 18px 20px; }
            .header-table td { vertical-align: middle; border: 0; padding: 0; }
            .logo-box { width: 128px; height: 82px; border-radius: 16px; background: #ffffff; padding: 8px; text-align: center; }
            .logo { max-width: 112px; max-height: 66px; }
            .logo-fallback { padding-top: 10px; font-weight: bold; line-height: 1; }
            .logo-fallback .red { color: #e30620; font-size: 20px; }
            .logo-fallback .blue { color: #07579f; font-size: 20px; }
            .logo-fallback .est { margin-top: 5px; color: #64748b; font-size: 7px; letter-spacing: 1px; text-transform: uppercase; }
            .brand { color: #93c5fd; font-size: 9px; font-weight: bold; letter-spacing: 2.4px; text-transform: uppercase; }
            .title { margin-top: 7px; font-size: 26px; font-weight: bold; letter-spacing: -0.6px; }
            .subtitle { margin-top: 7px; color: #cbd5e1; font-size: 11px; }
            .receipt-pill { display: inline-block; border: 1px solid rgba(255, 255, 255, 0.22); border-radius: 999px; padding: 7px 10px; background: rgba(255, 255, 255, 0.08); color: #ffffff; font-size: 10px; font-weight: bold; }

            .summary { margin-top: 14px; border: 1px solid #dbe5f0; border-radius: 16px; overflow: hidden; }
            .summary td { border: 0; padding: 0; vertical-align: stretch; }
            .summary-cell { padding: 13px 15px; border-right: 1px solid #e5e7eb; background: #f8fafc; }
            .summary-cell.last { border-right: 0; }
            .summary-label { color: #64748b; font-size: 8.5px; font-weight: bold; letter-spacing: 1.4px; text-transform: uppercase; }
            .summary-value { margin-top: 4px; color: #0f172a; font-size: 13px; font-weight: bold; }
            .amount-box { background: #e30620; color: #ffffff; padding: 14px 16px; text-align: right; }
            .amount-label { color: #ffe4e6; font-size: 8.5px; font-weight: bold; letter-spacing: 1.4px; text-transform: uppercase; }
            .amount-value { margin-top: 4px; font-size: 22px; font-weight: bold; }

            .section { margin-top: 18px; }
            .section-title { margin-bottom: 8px; color: #07579f; font-size: 12px; font-weight: bold; letter-spacing: 1.5px; text-transform: uppercase; }
            .info-table { border: 1px solid #dbe5f0; border-radius: 14px; overflow: hidden; }
            .info-table th { width: 26%; background: #f1f5f9; color: #475569; font-size: 9px; font-weight: bold; letter-spacing: 1px; text-align: left; text-transform: uppercase; }
            .info-table th, .info-table td { border: 1px solid #e5e7eb; padding: 8px 10px; vertical-align: top; }
            .info-table td { color: #111827; }
            .muted { color: #64748b; }
            .mono { font-family: DejaVu Sans Mono, monospace; }

            .invoice-table { border: 1px solid #dbe5f0; }
            .invoice-table th { background: #07111f; color: #ffffff; font-size: 8.5px; font-weight: bold; letter-spacing: 0.7px; text-align: left; text-transform: uppercase; }
            .invoice-table th, .invoice-table td { border: 1px solid #e5e7eb; padding: 7px 8px; vertical-align: top; }
            .invoice-table tbody tr:nth-child(even) td { background: #f8fafc; }
            .invoice-table .money { text-align: right; white-space: nowrap; }
            .invoice-table tfoot td { background: #fff7ed; font-weight: bold; }
            .invoice-table tfoot .total-label { color: #7c2d12; text-align: right; }
            .invoice-table tfoot .total-value { color: #7c2d12; font-size: 12px; text-align: right; }

            .footer { margin-top: 16px; border-top: 1px solid #e5e7eb; padding-top: 10px; color: #64748b; font-size: 9px; }
            .footer-table td { border: 0; padding: 0; vertical-align: top; }
            .footer-right { text-align: right; }
        </style>
    </head>
    <body>
        @php
            $account = $receipt->thirdParty?->primaryBankAccount;
            $beneficiaryName = $receipt->beneficiary_name ?? $receipt->thirdParty?->name;
            $beneficiaryDocument = $receipt->beneficiary_document_number ?? $receipt->thirdParty?->document_number;
            $bankName = $receipt->beneficiary_bank_name ?? $account?->bank?->name;
            $accountType = $receipt->beneficiary_account_type ?? $account?->account_type;
            $accountNumber = (string) ($receipt->beneficiary_account_number ?? $account?->account_number ?? '');
            $maskedAccount = $accountNumber !== '' ? str_repeat('*', max(strlen($accountNumber) - 4, 0)).substr($accountNumber, -4) : 'Sin cuenta registrada';
            $money = fn ($value) => number_format((float) $value, 2, ',', '.');
            $invoiceTotal = $receipt->invoices->sum('amount');
            $generatedAtValue = isset($generatedAt) ? $generatedAt : now();
        @endphp

        <div class="header">
            <table class="header-table">
                <tr>
                    <td style="width: 150px;">
                        <div class="logo-box">
                            @if ($logoDataUri)
                                <img src="{{ $logoDataUri }}" alt="Mister Wings" class="logo">
                            @else
                                <div class="logo-fallback">
                                    <div class="red">mister</div>
                                    <div class="blue">wings</div>
                                    <div class="est">Est. 2003</div>
                                </div>
                            @endif
                        </div>
                    </td>
                    <td>
                        <h1 class="title">Comprobante de pago</h1>
                        <p class="subtitle">Documento generado para consulta de pagos a proveedores de Mister Wings.</p>
                    </td>
                    <td style="width: 160px; text-align: right;">
                        <span class="receipt-pill">{{ $receipt->receipt_number }}</span>
                    </td>
                </tr>
            </table>
        </div>

        <table class="summary">
            <tr>
                <td style="width: 33%;">
                    <div class="summary-cell">
                        <p class="summary-label">Fecha de pago</p>
                        <p class="summary-value">{{ optional($receipt->payment_date)->format('Y-m-d') ?? 'Sin fecha' }}</p>
                    </div>
                </td>
                <td style="width: 33%;">
                    <div class="summary-cell">
                        <p class="summary-label">Sede</p>
                        <p class="summary-value">{{ $receipt->branch?->name ?? 'Sin sede' }}</p>
                    </div>
                </td>
                <td style="width: 33%;">
                    <div class="amount-box">
                        <p class="amount-label">Total pagado</p>
                        <p class="amount-value">$ {{ $money($receipt->amount) }}</p>
                    </div>
                </td>
            </tr>
        </table>

        <div class="section">
            <h2 class="section-title">Informacion del beneficiario</h2>
            <table class="info-table">
                <tr>
                    <th>Tercero</th>
                    <td>{{ $beneficiaryName ?? 'Sin tercero asociado' }}</td>
                    <th>NIT / DNI</th>
                    <td class="mono">{{ $beneficiaryDocument ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <th>Banco</th>
                    <td>{{ $bankName ?? 'Sin banco registrado' }}</td>
                    <th>Cuenta</th>
                    <td class="mono">{{ $accountType ?? '' }} {{ $maskedAccount }}</td>
                </tr>
                <tr>
                    <th>Concepto</th>
                    <td colspan="3">{{ $receipt->concept ?? 'Pago proveedores' }}</td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2 class="section-title">Facturas pagadas</h2>
            <table class="invoice-table">
                <thead>
                    <tr>
                        <th style="width: 20%;">Documento soporte</th>
                        <th style="width: 20%;">Documento causacion</th>
                        <th>Concepto</th>
                        <th style="width: 20%;" class="money">Valor</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($receipt->invoices as $invoice)
                        <tr>
                            <td class="mono">{{ $invoice->support_document }}</td>
                            <td class="mono">{{ $invoice->causation_document }}</td>
                            <td>{{ $invoice->concept ?? 'Pago factura' }}</td>
                            <td class="money">$ {{ $money($invoice->amount) }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="muted" style="text-align: center;">No hay facturas asociadas a este comprobante.</td>
                        </tr>
                    @endforelse
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="3" class="total-label">Total facturas</td>
                        <td class="total-value">$ {{ $money($invoiceTotal) }}</td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <div class="footer">
            <table class="footer-table">
                <tr>
                    <td>
                        Este documento es informativo y corresponde a los datos importados del lote de pagos.
                    </td>
                    <td class="footer-right">
                        Generado: {{ optional($generatedAtValue)->format('Y-m-d H:i') }}<br>
                        Comprobante: {{ $receipt->receipt_number }}
                    </td>
                </tr>
            </table>
        </div>
    </body>
</html>
