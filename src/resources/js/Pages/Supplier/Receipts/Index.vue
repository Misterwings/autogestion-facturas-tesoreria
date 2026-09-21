<script setup>
import { Head, Link, router, useForm, usePage } from '@inertiajs/vue3';
import logoUrl from '../../../../logo_mw.png';

const props = defineProps({
    supplier: { type: Object, required: true },
    filters: { type: Object, required: true },
    branches: { type: Array, required: true },
    receipts: { type: Object, required: true },
    totals: { type: Object, required: true },
});

const page = usePage();
const filterForm = useForm({
    payment_date: props.filters.payment_date ?? '',
    branch_id: props.filters.branch_id ?? '',
});

const formatMoney = (value) => new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    currencyDisplay: 'code',
    maximumFractionDigits: 2,
}).format(Number(value ?? 0));

const paginationLabel = (label) => label
    .replace('&laquo;', '‹')
    .replace('&raquo;', '›')
    .replace('Previous', 'Anterior')
    .replace('Next', 'Siguiente');

const logout = () => {
    router.post('/proveedor/logout');
};

const submitFilters = () => {
    filterForm.get('/proveedor/comprobantes', {
        preserveScroll: true,
        preserveState: true,
        replace: true,
    });
};

const clearFilters = () => {
    filterForm.reset('payment_date', 'branch_id');
    router.get('/proveedor/comprobantes', {}, {
        preserveScroll: true,
        replace: true,
    });
};
</script>

<template>
    <Head title="Comprobantes de pago" />

    <main class="page-shell">
        <div class="brand-orb -left-16 top-16 h-56 w-56 bg-mw-red/20 animate-soft-float" />
        <div class="brand-orb right-0 top-0 h-72 w-72 bg-mw-blue/30 animate-soft-float" style="animation-delay: -3s" />

        <header class="shell-content border-b border-white/10 bg-slate-950/70 backdrop-blur-2xl">
            <div class="mx-auto flex max-w-7xl flex-col gap-5 px-5 py-5 sm:px-6 lg:flex-row lg:items-center lg:justify-between">
                <div class="flex items-center gap-4">
                    <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-[1.35rem] border border-white/10 bg-white p-2 shadow-brand-glow">
                        <img :src="logoUrl" alt="Mister Wings" class="max-h-full max-w-full object-contain">
                    </div>
                    <div>
                        <p class="brand-chip">Proveedor</p>
                        <h1 class="mt-3 text-2xl font-black tracking-tight text-white sm:text-3xl">Comprobantes de pago</h1>
                        <p class="mt-1 text-sm text-slate-400">{{ supplier.document_number }} - {{ supplier.name }}</p>
                    </div>
                </div>

                <nav class="flex flex-wrap items-center gap-3 text-sm">
                    <Link href="/" class="btn-ghost rounded-full px-4 py-2">Inicio</Link>
                    <button type="button" class="btn-danger rounded-full px-4 py-2" @click="logout">Salir</button>
                </nav>
            </div>
        </header>

        <section class="shell-content mx-auto max-w-7xl px-5 py-8 sm:px-6">
            <Transition name="fade-slide" mode="out-in">
                <div v-if="page.props.flash?.success" key="success" class="mb-5 rounded-2xl border border-emerald-300/30 bg-emerald-400/10 px-5 py-4 text-sm font-semibold text-emerald-100" role="status">
                    {{ page.props.flash.success }}
                </div>
                <div v-else-if="page.props.flash?.error" key="error" class="mb-5 rounded-2xl border border-rose-300/30 bg-rose-400/10 px-5 py-4 text-sm font-semibold text-rose-100" role="alert">
                    {{ page.props.flash.error }}
                </div>
            </Transition>

            <div class="grid gap-4 md:grid-cols-2">
                <article class="stat-card rounded-3xl p-5">
                    <p class="text-sm font-semibold text-slate-400">Comprobantes disponibles</p>
                    <p class="mt-3 text-3xl font-black text-white">{{ totals.receipts_count }}</p>
                </article>
                <article class="stat-card rounded-3xl p-5">
                    <p class="text-sm font-semibold text-slate-400">Total pagado</p>
                    <p class="mt-3 text-3xl font-black text-sky-100">{{ formatMoney(totals.amount_total) }}</p>
                </article>
            </div>

            <section class="glass-panel mt-8 rounded-[2rem] p-6 sm:p-7">
                <div class="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
                    <div>
                        <p class="brand-chip">Descargas</p>
                        <h2 class="mt-4 text-2xl font-black tracking-tight text-white">Mis comprobantes</h2>
                        <p class="mt-2 text-sm text-slate-400">Descarga los comprobantes PDF relacionados con tu NIT/DNI.</p>
                    </div>
                </div>

                <form class="mt-6 grid gap-4 rounded-3xl border border-white/10 bg-slate-950/50 p-4 md:grid-cols-[1fr_1fr_auto] md:items-end" @submit.prevent="submitFilters">
                    <label class="block">
                        <span class="text-sm font-medium text-slate-200">Fecha de pago</span>
                        <input
                            v-model="filterForm.payment_date"
                            type="date"
                            class="form-field mt-2"
                        >
                        <span v-if="filterForm.errors.payment_date" class="mt-2 block text-sm text-rose-300">{{ filterForm.errors.payment_date }}</span>
                    </label>

                    <label class="block">
                        <span class="text-sm font-medium text-slate-200">Sede</span>
                        <select
                            v-model="filterForm.branch_id"
                            class="form-field mt-2"
                        >
                            <option value="">Todas las sedes</option>
                            <option v-for="branch in branches" :key="branch.id" :value="String(branch.id)">
                                {{ branch.name }}
                            </option>
                        </select>
                        <span v-if="filterForm.errors.branch_id" class="mt-2 block text-sm text-rose-300">{{ filterForm.errors.branch_id }}</span>
                    </label>

                    <div class="flex flex-wrap gap-3">
                        <button
                            type="submit"
                            :disabled="filterForm.processing"
                            class="btn-primary"
                        >
                            Filtrar
                        </button>
                        <button
                            type="button"
                            class="btn-ghost"
                            @click="clearFilters"
                        >
                            Limpiar
                        </button>
                    </div>
                </form>

                <div class="mt-6 overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Comprobante</th>
                                <th>Fecha</th>
                                <th>Sede</th>
                                <th class="text-right">Facturas</th>
                                <th class="text-right">Valor</th>
                                <th />
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="receipt in receipts.data" :key="receipt.id" class="text-slate-200">
                                <td>
                                    <p class="font-black text-sky-100">{{ receipt.receipt_number }}</p>
                                    <p class="mt-1 max-w-sm truncate text-xs text-slate-500">{{ receipt.concept ?? receipt.batch?.source_file_name }}</p>
                                </td>
                                <td>{{ receipt.payment_date ?? 'Sin fecha' }}</td>
                                <td class="text-slate-300">{{ receipt.branch ?? 'Sin sede' }}</td>
                                <td class="text-right text-slate-300">{{ receipt.invoices_count }}</td>
                                <td class="text-right font-semibold text-white">{{ formatMoney(receipt.amount) }}</td>
                                <td class="text-right">
                                    <a :href="`/proveedor/comprobantes/${receipt.id}/pdf`" class="btn-ghost rounded-full px-4 py-2 text-xs text-sky-100">PDF</a>
                                </td>
                            </tr>
                            <tr v-if="receipts.data.length === 0">
                                <td colspan="6" class="py-10 text-center text-slate-400">No hay comprobantes disponibles para este NIT/DNI.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <nav v-if="receipts.links?.length > 3" class="mt-6 flex flex-wrap gap-2" aria-label="Paginacion de comprobantes">
                    <component
                        :is="link.url ? Link : 'span'"
                        v-for="(link, index) in receipts.links"
                        :key="`${link.label}-${index}`"
                        :href="link.url"
                        :aria-current="link.active ? 'page' : undefined"
                        :aria-disabled="link.url ? undefined : 'true'"
                        class="rounded-full border px-3 py-1 text-sm font-semibold transition"
                        :class="link.active
                            ? 'border-mw-red bg-mw-red text-white'
                            : link.url
                                ? 'border-white/10 bg-white/5 text-slate-300 hover:border-sky-300/50 hover:text-sky-100'
                                : 'cursor-not-allowed border-white/5 bg-white/[0.02] text-slate-600'"
                    >
                        {{ paginationLabel(link.label) }}
                    </component>
                </nav>
            </section>
        </section>
    </main>
</template>
