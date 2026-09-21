<script setup>
import { Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';
import AdminLayout from '../../../Layouts/AdminLayout.vue';
import { confirmBatchDeletion } from '../../../Support/confirmBatchDeletion.js';

const props = defineProps({
    batch: { type: Object, required: true },
    branchTotals: { type: Array, required: true },
    errors: { type: [Array, Object], required: true },
    bankPaymentLines: { type: [Array, Object], required: true },
    receipts: { type: [Array, Object], required: true },
});

const formatMoney = (value) => new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    currencyDisplay: 'code',
    maximumFractionDigits: 2,
}).format(Number(value ?? 0));

const approving = ref(false);
const deleting = ref(false);
const pageRows = (page) => (Array.isArray(page) ? page : page.data ?? []);
const pageLinks = (page) => (Array.isArray(page) ? [] : page.links ?? []);
const errorRows = computed(() => pageRows(props.errors));
const errorLinks = computed(() => pageLinks(props.errors));
const receiptRows = computed(() => pageRows(props.receipts));
const receiptLinks = computed(() => pageLinks(props.receipts));
const bankLineRows = computed(() => pageRows(props.bankPaymentLines));
const bankLineLinks = computed(() => pageLinks(props.bankPaymentLines));
const paginationLabel = (label) => label
    .replace('&laquo;', '‹')
    .replace('&raquo;', '›')
    .replace('Previous', 'Anterior')
    .replace('Next', 'Siguiente');

const statusLabels = {
    approved: 'Aprobado',
    generation_failed: 'Fallo al generar',
    imported: 'Importado',
    importing: 'Importando',
    needs_review: 'Pendiente de revision',
    generating: 'Generando archivos',
    ready: 'Listo',
    validated: 'Validado',
};

const statusLabel = (status) => statusLabels[status] ?? status ?? 'Sin estado';
const statusClass = (status) => ({
    approved: 'bg-emerald-400/10 text-emerald-200',
    generation_failed: 'bg-rose-400/10 text-rose-200',
    imported: 'bg-sky-400/10 text-sky-200',
    importing: 'bg-amber-400/10 text-amber-200',
    needs_review: 'bg-purple-400/10 text-purple-200',
    generating: 'bg-amber-400/10 text-amber-200',
    ready: 'bg-emerald-400/10 text-emerald-200',
    validated: 'bg-sky-400/10 text-sky-200',
}[status] ?? 'bg-white/5 text-slate-300');

const severityClass = (severity) => ({
    error: 'bg-rose-400/10 text-rose-200',
    info: 'bg-sky-400/10 text-sky-200',
    warning: 'bg-amber-400/10 text-amber-200',
}[severity] ?? 'bg-white/5 text-slate-300');

const approveBatch = () => {
    router.post(`/admin/imports/${props.batch.id}/approve`, {}, {
        preserveScroll: true,
        onStart: () => {
            approving.value = true;
        },
        onFinish: () => {
            approving.value = false;
        },
    });
};

const deleteBatch = async () => {
    if (!await confirmBatchDeletion(props.batch)) {
        return;
    }

    router.delete(`/admin/imports/${props.batch.id}`, {
        onStart: () => {
            deleting.value = true;
        },
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const cards = [
    ['Lineas referencia (I:N)', props.batch.bank_payment_lines_count],
    ['Comprobantes', props.batch.receipts_count],
    ['Facturas (B:H)', props.batch.invoices_count],
    ['Alertas', props.batch.import_errors_count],
];
</script>

<template>
    <AdminLayout :title="`Lote #${batch.id}`">
        <div class="glass-panel mb-6 rounded-[2rem] p-6 sm:p-7">
            <div class="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
                <div class="min-w-0">
                    <Link href="/admin/imports" class="text-sm font-bold text-sky-200 transition hover:text-sky-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream">Volver al historial</Link>
                    <div class="mt-3 flex flex-wrap items-center gap-3">
                        <h2 class="break-words text-3xl font-black tracking-tight text-white">{{ batch.source_file_name }}</h2>
                        <span class="rounded-full px-3 py-1 text-xs font-black" :class="statusClass(batch.status)">
                            {{ statusLabel(batch.status) }}
                        </span>
                    </div>
                    <p class="mt-2 text-sm leading-6 text-slate-400">
                        Fecha: {{ batch.payment_date ?? 'Sin fecha' }} · {{ batch.has_model_sheet ? 'Con MODELO' : 'Sin MODELO' }} · Importado: {{ batch.imported_at }}
                    </p>
                </div>

                <div class="flex flex-wrap gap-3">
                    <button
                        v-if="batch.can_approve"
                        type="button"
                        class="btn-primary"
                        :disabled="approving"
                        @click="approveBatch"
                    >
                        {{ approving ? 'Aprobando...' : 'Aprobar lote' }}
                    </button>
                    <button
                        v-if="batch.can_delete"
                        type="button"
                        class="btn-danger"
                        :disabled="deleting || approving"
                        @click="deleteBatch"
                    >
                        {{ deleting ? 'Eliminando...' : 'Eliminar lote' }}
                    </button>
                </div>
            </div>
        </div>

        <div class="grid gap-4 md:grid-cols-4">
            <article v-for="card in cards" :key="card[0]" class="stat-card rounded-3xl p-5">
                <p class="text-sm font-semibold text-slate-400">{{ card[0] }}</p>
                <p class="mt-3 text-3xl font-black text-white">{{ card[1] }}</p>
            </article>
        </div>

        <div class="mt-6 grid gap-4 md:grid-cols-2">
            <article class="stat-card rounded-3xl p-5">
                <p class="text-sm font-semibold text-slate-400">Total facturas (B:H)</p>
                <p class="mt-3 text-3xl font-black text-white">{{ formatMoney(batch.invoice_total) }}</p>
            </article>
            <article class="stat-card rounded-3xl p-5">
                <p class="text-sm font-semibold text-slate-400">Total referencia bancaria (I:N)</p>
                <p class="mt-3 text-3xl font-black text-sky-100">{{ formatMoney(batch.bank_payment_total) }}</p>
            </article>
        </div>

        <section class="glass-panel mt-8 rounded-[2rem] p-6 sm:p-7">
            <p class="brand-chip">Sedes</p>
            <h3 class="mt-4 text-2xl font-black tracking-tight text-white">Totales por sede</h3>
            <div class="mt-5 grid gap-3 md:grid-cols-4">
                <div v-for="branch in branchTotals" :key="branch.branch" class="feature-card rounded-3xl p-4">
                    <p class="font-black text-sky-100">{{ branch.branch }}</p>
                    <p class="mt-1 text-sm text-slate-400">{{ branch.lines_count }} lineas</p>
                    <p class="mt-3 text-xl font-black text-white">{{ formatMoney(branch.total) }}</p>
                    <a :href="`/admin/imports/${batch.id}/bank-file/branches/${branch.branch_id}`" class="btn-ghost mt-4 rounded-full px-4 py-2 text-xs text-sky-100">
                        Descargar TXT sede
                    </a>
                </div>
                <div v-if="branchTotals.length === 0" class="rounded-3xl border border-white/10 bg-slate-950/40 p-8 text-center text-sm text-slate-400 md:col-span-4">
                    No hay totales bancarios por sede para este lote.
                </div>
            </div>
        </section>

        <section class="glass-panel mt-8 rounded-[2rem] p-6 sm:p-7">
            <p class="brand-chip">Control</p>
            <h3 class="mt-4 text-2xl font-black tracking-tight text-white">Advertencias de importacion</h3>
            <p class="mt-2 text-sm text-slate-400">Resultados paginados de la conciliacion.</p>
            <div class="mt-5 overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Codigo</th>
                            <th>Severidad</th>
                            <th>Mensaje</th>
                            <th>Hoja</th>
                            <th class="text-right">Fila</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="error in errorRows" :key="error.id">
                            <td class="font-black text-amber-200">{{ error.code }}</td>
                            <td>
                                <span class="rounded-full px-3 py-1 text-xs font-black" :class="severityClass(error.severity)">
                                    {{ error.severity ?? 'Sin severidad' }}
                                </span>
                            </td>
                            <td class="text-slate-300">{{ error.message }}</td>
                            <td class="text-slate-300">{{ error.source_sheet }}</td>
                            <td class="text-right text-slate-300">{{ error.source_row }}</td>
                        </tr>
                        <tr v-if="errorRows.length === 0">
                            <td colspan="5" class="py-8 text-center text-slate-400">Sin advertencias.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <nav v-if="errorLinks.length > 3" class="mt-4 flex flex-wrap gap-2" aria-label="Paginacion de advertencias">
                <template v-for="link in errorLinks" :key="link.label">
                    <Link v-if="link.url" :href="link.url" preserve-scroll class="btn-ghost rounded-full px-3 py-1 text-xs" :aria-current="link.active ? 'page' : undefined">{{ paginationLabel(link.label) }}</Link>
                    <span v-else class="rounded-full px-3 py-1 text-xs text-slate-600">{{ paginationLabel(link.label) }}</span>
                </template>
            </nav>
        </section>

        <section class="glass-panel mt-8 rounded-[2rem] p-6 sm:p-7">
            <p class="brand-chip">Comprobantes</p>
            <h3 class="mt-4 text-2xl font-black tracking-tight text-white">Comprobantes con detalle</h3>
            <p class="mt-2 text-sm text-slate-400">Comprobantes paginados del lote.</p>
            <div class="mt-5 overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Comprobante</th>
                            <th>Sede</th>
                            <th>Tercero</th>
                            <th class="text-right">Facturas</th>
                            <th class="text-right">Valor</th>
                            <th />
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="receipt in receiptRows" :key="receipt.id">
                            <td class="font-black text-sky-100">{{ receipt.receipt_number }}</td>
                            <td class="text-slate-300">{{ receipt.branch }}</td>
                            <td class="text-slate-300">{{ receipt.nit }} {{ receipt.third_party }}</td>
                            <td class="text-right text-slate-300">{{ receipt.invoices_count }}</td>
                            <td class="text-right font-semibold text-white">{{ formatMoney(receipt.amount) }}</td>
                            <td class="text-right">
                                <a :href="`/admin/payment-receipts/${receipt.id}/pdf`" class="btn-ghost rounded-full px-4 py-2 text-xs text-sky-100">PDF</a>
                            </td>
                        </tr>
                        <tr v-if="receiptRows.length === 0">
                            <td colspan="6" class="py-8 text-center text-slate-400">No hay comprobantes con detalle para este lote.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <nav v-if="receiptLinks.length > 3" class="mt-4 flex flex-wrap gap-2" aria-label="Paginacion de comprobantes">
                <template v-for="link in receiptLinks" :key="link.label">
                    <Link v-if="link.url" :href="link.url" preserve-scroll class="btn-ghost rounded-full px-3 py-1 text-xs" :aria-current="link.active ? 'page' : undefined">{{ paginationLabel(link.label) }}</Link>
                    <span v-else class="rounded-full px-3 py-1 text-xs text-slate-600">{{ paginationLabel(link.label) }}</span>
                </template>
            </nav>
        </section>

        <section class="glass-panel mt-8 rounded-[2rem] p-6 sm:p-7">
            <p class="brand-chip">Banco</p>
            <h3 class="mt-4 text-2xl font-black tracking-tight text-white">Lineas bancarias (referencia I:N)</h3>
            <p class="mt-2 text-sm text-slate-400">Datos paginados del bloque I:N usados para generar el TXT.</p>
            <div class="mt-5 overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Tercero</th>
                            <th>Cuenta</th>
                            <th>Banco</th>
                            <th>Sede</th>
                            <th class="text-right">Valor</th>
                            <th class="text-right">Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="line in bankLineRows" :key="line.id">
                            <td>
                                <p class="font-black text-slate-100">{{ line.nit }}</p>
                                <p class="mt-1 text-xs text-slate-500">{{ line.third_party_name }}</p>
                            </td>
                            <td class="font-mono text-slate-300">{{ line.bank_account_type }} {{ line.bank_account_number }}</td>
                            <td class="text-slate-300">{{ line.bank_code }}</td>
                            <td class="text-slate-300">{{ line.branch }}</td>
                            <td class="text-right font-semibold text-white">{{ formatMoney(line.amount) }}</td>
                            <td class="text-right">
                                <span class="rounded-full px-3 py-1 text-xs font-black" :class="line.has_invoice_detail ? 'bg-emerald-400/10 text-emerald-200' : 'bg-amber-400/10 text-amber-200'">
                                    {{ line.has_invoice_detail ? 'Con facturas' : 'Sin facturas' }}
                                </span>
                            </td>
                        </tr>
                        <tr v-if="bankLineRows.length === 0">
                            <td colspan="6" class="py-8 text-center text-slate-400">No hay lineas bancarias para este lote.</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <nav v-if="bankLineLinks.length > 3" class="mt-4 flex flex-wrap gap-2" aria-label="Paginacion de lineas bancarias">
                <template v-for="link in bankLineLinks" :key="link.label">
                    <Link v-if="link.url" :href="link.url" preserve-scroll class="btn-ghost rounded-full px-3 py-1 text-xs" :aria-current="link.active ? 'page' : undefined">{{ paginationLabel(link.label) }}</Link>
                    <span v-else class="rounded-full px-3 py-1 text-xs text-slate-600">{{ paginationLabel(link.label) }}</span>
                </template>
            </nav>
        </section>
    </AdminLayout>
</template>
