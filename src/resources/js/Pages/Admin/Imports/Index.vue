<script setup>
import { Link, router, useForm } from '@inertiajs/vue3';
import { ref } from 'vue';
import AdminLayout from '../../../Layouts/AdminLayout.vue';
import { confirmBatchDeletion } from '../../../Support/confirmBatchDeletion.js';

const props = defineProps({
    batches: {
        type: Object,
        required: true,
    },
    catalogCount: {
        type: Number,
        required: true,
    },
});

const form = useForm({
    file: null,
    payment_date: '',
});
const deletingBatchId = ref(null);

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

const submit = () => {
    form.post('/admin/imports', {
        forceFormData: true,
        preserveScroll: true,
    });
};

const deleteBatch = async (batch) => {
    if (!await confirmBatchDeletion(batch)) {
        return;
    }

    router.delete(`/admin/imports/${batch.id}`, {
        preserveScroll: true,
        onStart: () => {
            deletingBatchId.value = batch.id;
        },
        onFinish: () => {
            deletingBatchId.value = null;
        },
    });
};
</script>

<template>
    <AdminLayout title="Importaciones de pagos">
        <div>
            <section class="glass-panel rounded-[2rem] p-6 sm:p-7">
                <div class="grid gap-6 xl:grid-cols-[1fr_1.1fr] xl:items-end">
                    <div>
                        <p class="brand-chip">Operacion</p>
                        <h2 class="mt-4 text-2xl font-black tracking-tight text-white">Cargar Excel semanal</h2>

                        <div class="mt-5 rounded-2xl border px-4 py-3 text-sm font-semibold" :class="catalogCount > 0 ? 'border-emerald-400/30 bg-emerald-400/10 text-emerald-200' : 'border-sky-400/30 bg-sky-400/10 text-sky-200'">
                            <template v-if="catalogCount > 0">
                                Catalogo activo: {{ catalogCount }} terceros registrados.
                            </template>
                            <template v-else>
                                Sin catalogo previo. Si el archivo trae MODELO o bloque bancario valido, se creara durante la importacion.
                            </template>
                        </div>

                        <p class="mt-4 text-sm leading-6 text-slate-400">
                            Sube el archivo de pagos. Si contiene hoja MODELO, se usara para crear o actualizar terceros, bancos y cuentas antes de importar las sedes.
                        </p>
                    </div>

                    <form class="rounded-3xl border border-white/10 bg-slate-950/50 p-4" @submit.prevent="submit">
                        <div class="grid gap-4 lg:grid-cols-[1fr_0.7fr_auto] lg:items-end">
                            <label class="block min-w-0">
                                <span class="text-sm font-medium text-slate-200">Archivo .xlsx</span>
                                <input
                                    type="file"
                                    accept=".xlsx"
                                    class="form-field mt-2"
                                    @input="form.file = $event.target.files[0]"
                                >
                                <span v-if="form.errors.file" class="mt-2 block text-sm text-rose-300">{{ form.errors.file }}</span>
                            </label>

                            <label class="block">
                                <span class="text-sm font-medium text-slate-200">Fecha opcional</span>
                                <input
                                    v-model="form.payment_date"
                                    type="date"
                                    class="form-field mt-2"
                                >
                                <span v-if="form.errors.payment_date" class="mt-2 block text-sm text-rose-300">{{ form.errors.payment_date }}</span>
                            </label>

                            <button
                                type="submit"
                                :disabled="form.processing"
                                class="btn-primary w-full lg:w-auto"
                            >
                                {{ form.processing ? 'Importando...' : 'Importar pagos' }}
                            </button>
                        </div>

                        <Transition name="fade-slide">
                            <div
                                v-if="form.progress"
                                class="mt-4 h-2 overflow-hidden rounded-full bg-slate-800"
                                role="progressbar"
                                aria-label="Progreso de carga"
                                aria-valuemin="0"
                                aria-valuemax="100"
                                :aria-valuenow="form.progress.percentage"
                                :aria-valuetext="`${form.progress.percentage}% completado`"
                            >
                                <div class="h-full rounded-full bg-gradient-to-r from-mw-red to-sky-300 transition-all duration-300" :style="{ width: `${form.progress.percentage}%` }" />
                            </div>
                        </Transition>
                    </form>
                </div>
            </section>

            <section class="glass-panel mt-6 rounded-[2rem] p-6 sm:p-7">
                <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                    <div>
                        <p class="brand-chip">Historial</p>
                        <h2 class="mt-4 text-2xl font-black tracking-tight text-white">Lotes importados</h2>
                        <p class="mt-2 text-sm text-slate-400">Ultimos lotes, totales bancarios y alertas de validacion.</p>
                    </div>
                </div>

                <div class="mt-6 overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Lote</th>
                                <th>Archivo</th>
                                <th>Fecha</th>
                                <th class="text-right">Banco</th>
                                <th class="text-right">Facturas</th>
                                <th class="text-right">Alertas</th>
                                <th />
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="batch in batches.data" :key="batch.id" class="text-slate-200">
                                <td class="font-black text-white">#{{ batch.id }}</td>
                                <td class="max-w-xs">
                                    <p class="truncate font-semibold text-slate-100">{{ batch.source_file_name }}</p>
                                    <p class="mt-1 text-xs text-slate-500">{{ batch.has_model_sheet ? 'Con MODELO' : 'Sin MODELO' }}</p>
                                </td>
                                <td>{{ batch.payment_date ?? 'Sin fecha' }}</td>
                                <td class="text-right font-semibold text-sky-100">{{ formatMoney(batch.bank_payment_total) }}</td>
                                <td class="text-right">{{ batch.invoices_count }}</td>
                                <td class="text-right">
                                    <span class="rounded-full px-3 py-1 text-xs font-black" :class="batch.import_errors_count > 0 ? 'bg-amber-400/10 text-amber-200' : 'bg-emerald-400/10 text-emerald-200'">
                                        {{ batch.import_errors_count }}
                                    </span>
                                </td>
                                <td class="text-right">
                                    <div class="flex justify-end gap-2">
                                        <Link :href="`/admin/imports/${batch.id}`" class="btn-ghost rounded-full px-4 py-2 text-xs text-sky-100">Ver</Link>
                                        <button
                                            v-if="batch.can_delete"
                                            type="button"
                                            class="btn-danger rounded-full px-3 py-2 text-xs"
                                            :disabled="deletingBatchId === batch.id"
                                            @click="deleteBatch(batch)"
                                        >
                                            {{ deletingBatchId === batch.id ? 'Eliminando...' : 'Eliminar' }}
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <tr v-if="batches.data.length === 0">
                                <td colspan="7" class="py-10 text-center text-slate-400">No hay importaciones registradas.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <nav v-if="batches.links?.length > 3" class="mt-6 flex flex-wrap gap-2" aria-label="Paginacion del historial de importaciones">
                    <component
                        :is="link.url ? Link : 'span'"
                        v-for="(link, index) in batches.links"
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
        </div>
    </AdminLayout>
</template>
