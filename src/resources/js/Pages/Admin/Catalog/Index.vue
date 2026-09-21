<script setup>
import { Link, router, useForm } from '@inertiajs/vue3';
import { computed, nextTick, onBeforeUnmount, ref } from 'vue';
import AdminLayout from '../../../Layouts/AdminLayout.vue';

const props = defineProps({
    thirdParties: { type: [Array, Object], required: true },
    stats: { type: Object, required: true },
    filters: { type: Object, default: () => ({ search: '' }) },
});

const thirdPartyRows = computed(() => (
    Array.isArray(props.thirdParties) ? props.thirdParties : props.thirdParties.data ?? []
));
const thirdPartyLinks = computed(() => (
    Array.isArray(props.thirdParties) ? [] : props.thirdParties.links ?? []
));
const thirdPartyTotal = computed(() => (
    Array.isArray(props.thirdParties) ? props.thirdParties.length : props.thirdParties.total ?? thirdPartyRows.value.length
));

const seedForm = useForm({ file: null });
const searchForm = useForm({ search: props.filters.search ?? '' });

const editing = ref(false);
const editNameInput = ref(null);
const editDialog = ref(null);
const previouslyFocusedElement = ref(null);
const editForm = useForm({
    name: '',
    alternate_name: '',
    person_type: '1',
    bank_account_number: '',
    bank_account_type: 'CA',
    bank_code: '',
    password: '',
    password_confirmation: '',
});

const openEdit = (tp) => {
    previouslyFocusedElement.value = document.activeElement instanceof HTMLElement
        ? document.activeElement
        : null;
    editing.value = tp;
    editForm.name = tp.name;
    editForm.alternate_name = tp.alternate_name ?? '';
    editForm.person_type = tp.person_type;
    editForm.bank_account_number = tp.bank_account ?? '';
    editForm.bank_account_type = tp.bank_account_type ?? 'CA';
    editForm.bank_code = tp.bank_code ?? '';
    editForm.password = '';
    editForm.password_confirmation = '';
    editForm.clearErrors();
    document.addEventListener('keydown', handleModalKeydown);
    nextTick(() => editNameInput.value?.focus());
};

const closeEdit = () => {
    if (!editing.value) {
        return;
    }

    editing.value = false;
    document.removeEventListener('keydown', handleModalKeydown);

    const elementToRestore = previouslyFocusedElement.value;
    previouslyFocusedElement.value = null;
    nextTick(() => elementToRestore?.focus());
};

function handleModalKeydown(event) {
    if (event.key === 'Escape') {
        closeEdit();
        return;
    }

    if (event.key === 'Tab' && editDialog.value) {
        const focusable = [...editDialog.value.querySelectorAll(
            'button:not([disabled]), input:not([disabled]), select:not([disabled]), [href], [tabindex]:not([tabindex="-1"])',
        )];
        const first = focusable[0];
        const last = focusable.at(-1);

        if (event.shiftKey && document.activeElement === first) {
            event.preventDefault();
            last?.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first?.focus();
        }
    }
}

const paginationLabel = (label) => label
    .replace('&laquo;', '‹')
    .replace('&raquo;', '›')
    .replace('Previous', 'Anterior')
    .replace('Next', 'Siguiente');

const editErrorAttributes = (field) => ({
    'aria-invalid': Boolean(editForm.errors[field]),
    'aria-describedby': editForm.errors[field] ? `edit-${field}-error` : undefined,
});

onBeforeUnmount(() => document.removeEventListener('keydown', handleModalKeydown));

const submitSeed = () => {
    seedForm.post('/admin/catalog/seed', {
        forceFormData: true,
        preserveScroll: true,
    });
};

const submitSearch = () => {
    searchForm.get('/admin/catalog', {
        preserveState: true,
        preserveScroll: true,
        replace: true,
    });
};

const clearSearch = () => {
    searchForm.search = '';
    router.get('/admin/catalog', {}, {
        preserveState: true,
        preserveScroll: true,
        replace: true,
    });
};

const submitEdit = () => {
    editForm.put(`/admin/catalog/${editing.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            editForm.reset('password', 'password_confirmation');
            closeEdit();
        },
    });
};

const destroy = (thirdParty) => {
    if (!confirm(`Eliminar a ${thirdParty.name} (${thirdParty.document_number}) del catalogo?`)) {
        return;
    }

    router.delete(`/admin/catalog/${thirdParty.id}`, { preserveScroll: true });
};
</script>

<template>
    <AdminLayout title="Catalogo de terceros">
        <section class="glass-panel rounded-[2rem] p-6 sm:p-7">
            <div class="grid gap-6 xl:grid-cols-[1fr_1.1fr] xl:items-end">
                <div>
                    <p class="brand-chip">Catalogo</p>
                    <h2 class="mt-4 text-2xl font-black tracking-tight text-white">Cargar hoja MODELO</h2>
                    <p class="mt-2 max-w-3xl text-sm leading-6 text-slate-400">
                        Sube un archivo Excel que contenga la hoja MODELO con los terceros y sus cuentas bancarias. Esta informacion es requisito previo para importar pagos.
                    </p>

                    <div class="mt-4 grid gap-3 sm:grid-cols-3">
                        <div class="stat-card rounded-2xl p-4 text-center">
                            <p class="text-2xl font-black text-white">{{ stats.third_parties_count }}</p>
                            <p class="mt-1 text-xs text-slate-400">Terceros</p>
                        </div>
                        <div class="stat-card rounded-2xl p-4 text-center">
                            <p class="text-2xl font-black text-white">{{ stats.banks_count }}</p>
                            <p class="mt-1 text-xs text-slate-400">Bancos</p>
                        </div>
                        <div class="stat-card rounded-2xl p-4 text-center">
                            <p class="text-2xl font-black text-white">{{ stats.accounts_count }}</p>
                            <p class="mt-1 text-xs text-slate-400">Cuentas</p>
                        </div>
                    </div>
                </div>

                <form class="rounded-3xl border border-white/10 bg-slate-950/50 p-4" @submit.prevent="submitSeed">
                    <div class="grid gap-4 lg:grid-cols-[1fr_auto] lg:items-end">
                        <label class="block min-w-0">
                            <span class="text-sm font-medium text-slate-200">Archivo .xlsx con hoja MODELO</span>
                            <input
                                id="seed-file"
                                type="file"
                                accept=".xlsx"
                                class="form-field mt-2"
                                :aria-invalid="Boolean(seedForm.errors.file)"
                                :aria-describedby="seedForm.errors.file ? 'seed-file-error' : undefined"
                                @input="seedForm.file = $event.target.files[0]"
                            >
                            <span v-if="seedForm.errors.file" id="seed-file-error" class="mt-2 block text-sm text-rose-300">{{ seedForm.errors.file }}</span>
                        </label>

                        <button
                            type="submit"
                            :disabled="seedForm.processing"
                            class="btn-primary w-full lg:w-auto"
                        >
                            {{ seedForm.processing ? 'Procesando...' : 'Actualizar catalogo' }}
                        </button>
                    </div>

                    <Transition name="fade-slide">
                        <div
                            v-if="seedForm.progress"
                            class="mt-4 h-2 overflow-hidden rounded-full bg-slate-800"
                            role="progressbar"
                            aria-label="Progreso de carga"
                            aria-valuemin="0"
                            aria-valuemax="100"
                            :aria-valuenow="seedForm.progress.percentage"
                            :aria-valuetext="`${seedForm.progress.percentage}% completado`"
                        >
                            <div class="h-full rounded-full bg-gradient-to-r from-mw-red to-sky-300 transition-all duration-300" :style="{ width: `${seedForm.progress.percentage}%` }" />
                        </div>
                    </Transition>

                    <p class="mt-4 text-xs leading-5 text-slate-500">
                        Al cargar un nuevo archivo MODELO se actualiza el catalogo existente sin duplicar terceros con el mismo NIT.
                    </p>
                </form>
            </div>
        </section>

        <section class="glass-panel mt-6 min-w-0 overflow-hidden rounded-[2rem] p-6 sm:p-7">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div>
                    <p class="brand-chip">Directorio</p>
                    <h2 class="mt-4 text-2xl font-black tracking-tight text-white">Terceros registrados</h2>
                    <p class="mt-2 text-sm text-slate-400">
                        {{ thirdPartyTotal }} {{ filters.search ? 'resultados encontrados.' : 'registros en el catalogo.' }}
                    </p>
                </div>

                <form class="w-full sm:max-w-md" role="search" @submit.prevent="submitSearch">
                    <label for="catalog-search" class="text-sm font-medium text-slate-200">Buscar por NIT / DNI</label>
                    <div class="mt-2 flex flex-col gap-2 sm:flex-row">
                        <input
                            id="catalog-search"
                            v-model="searchForm.search"
                            type="search"
                            inputmode="search"
                            maxlength="50"
                            class="form-field min-w-0 flex-1 font-mono"
                            placeholder="Ej. 900123"
                            autocomplete="off"
                            :aria-invalid="Boolean(searchForm.errors.search)"
                            :aria-describedby="searchForm.errors.search ? 'catalog-search-error' : undefined"
                        >
                        <button type="submit" class="btn-primary" :disabled="searchForm.processing">
                            Buscar
                        </button>
                        <button v-if="filters.search" type="button" class="btn-ghost" @click="clearSearch">
                            Limpiar
                        </button>
                    </div>
                    <p v-if="searchForm.errors.search" id="catalog-search-error" class="mt-2 text-sm text-rose-300" role="alert">
                        {{ searchForm.errors.search }}
                    </p>
                </form>
            </div>

            <div class="mt-6 hidden max-w-full overflow-x-auto rounded-3xl border border-white/10 bg-slate-950/40 lg:block">
                <table class="data-table min-w-[1040px]">
                    <thead>
                        <tr>
                            <th>NIT / DNI</th>
                            <th>Nombre</th>
                            <th>Nombre alterno</th>
                            <th>Tipo</th>
                            <th>Acceso</th>
                            <th>Banco</th>
                            <th>Cuenta</th>
                            <th />
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="tp in thirdPartyRows" :key="tp.id" class="text-slate-200">
                            <td class="font-mono font-black text-sky-100">{{ tp.document_number }}</td>
                            <td class="max-w-xs font-semibold text-slate-100">{{ tp.name }}</td>
                            <td class="max-w-xs text-slate-300">{{ tp.alternate_name ?? 'Sin alterno' }}</td>
                            <td>
                                <span class="rounded-full px-2 py-0.5 text-xs font-black" :class="tp.person_type === '1' ? 'bg-purple-400/10 text-purple-200' : 'bg-blue-400/10 text-blue-200'">
                                    {{ tp.person_type === '1' ? 'Juridica' : 'Natural' }}
                                </span>
                            </td>
                            <td>
                                <span class="rounded-full px-2 py-0.5 text-xs font-black" :class="tp.has_password ? 'bg-emerald-400/10 text-emerald-200' : 'bg-amber-400/10 text-amber-200'">
                                    {{ tp.has_password ? 'Activo' : 'Sin contrasena' }}
                                </span>
                            </td>
                            <td class="text-slate-300">{{ tp.bank_name ?? tp.bank_code }}</td>
                            <td class="font-mono text-slate-300">{{ tp.bank_account_type }} {{ tp.bank_account }}</td>
                            <td class="text-right">
                                <div class="flex justify-end gap-2">
                                    <button
                                        class="btn-ghost rounded-full px-3 py-1 text-xs text-sky-100"
                                        @click="openEdit(tp)"
                                    >
                                        Editar
                                    </button>
                                    <button
                                        class="btn-danger rounded-full px-3 py-1 text-xs"
                                        @click="destroy(tp)"
                                    >
                                        Eliminar
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="thirdPartyRows.length === 0">
                            <td colspan="8" class="py-10 text-center text-slate-400">
                                {{ filters.search ? 'No se encontraron terceros con ese NIT / DNI.' : 'No hay terceros en el catalogo. Carga un archivo MODELO.' }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="mt-6 grid gap-3 lg:hidden">
                <article v-for="tp in thirdPartyRows" :key="tp.id" class="feature-card rounded-3xl p-4">
                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0">
                            <p class="font-mono text-sm font-black text-sky-100">{{ tp.document_number }}</p>
                            <h3 class="mt-1 break-words text-base font-black text-white">{{ tp.name }}</h3>
                            <p class="mt-1 break-words text-sm text-slate-400">{{ tp.alternate_name ?? 'Sin alterno' }}</p>
                        </div>
                        <span class="shrink-0 rounded-full px-2 py-0.5 text-xs font-black" :class="tp.has_password ? 'bg-emerald-400/10 text-emerald-200' : 'bg-amber-400/10 text-amber-200'">
                            {{ tp.has_password ? 'Activo' : 'Sin clave' }}
                        </span>
                    </div>

                    <dl class="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                        <div>
                            <dt class="text-xs font-bold uppercase tracking-wider text-slate-500">Tipo</dt>
                            <dd class="mt-1 text-slate-200">{{ tp.person_type === '1' ? 'Juridica' : 'Natural' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs font-bold uppercase tracking-wider text-slate-500">Banco</dt>
                            <dd class="mt-1 break-words text-slate-200">{{ tp.bank_name ?? tp.bank_code ?? 'Sin banco' }}</dd>
                        </div>
                        <div class="sm:col-span-2">
                            <dt class="text-xs font-bold uppercase tracking-wider text-slate-500">Cuenta</dt>
                            <dd class="mt-1 break-all font-mono text-slate-200">{{ tp.bank_account_type }} {{ tp.bank_account ?? 'Sin cuenta' }}</dd>
                        </div>
                    </dl>

                    <div class="mt-4 flex flex-wrap justify-end gap-2">
                        <button
                            class="btn-ghost rounded-full px-3 py-2 text-xs text-sky-100"
                            @click="openEdit(tp)"
                        >
                            Editar
                        </button>
                        <button
                            class="btn-danger rounded-full px-3 py-2 text-xs"
                            @click="destroy(tp)"
                        >
                            Eliminar
                        </button>
                    </div>
                </article>

                <div v-if="thirdPartyRows.length === 0" class="rounded-3xl border border-white/10 bg-slate-950/40 p-8 text-center text-sm text-slate-400">
                    {{ filters.search ? 'No se encontraron terceros con ese NIT / DNI.' : 'No hay terceros en el catalogo. Carga un archivo MODELO.' }}
                </div>
            </div>

            <nav v-if="thirdPartyLinks.length > 3" class="mt-6 flex flex-wrap gap-2" aria-label="Paginacion del catalogo">
                <component
                    :is="link.url ? Link : 'span'"
                    v-for="(link, index) in thirdPartyLinks"
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

        <Teleport to="body">
            <Transition name="modal-pop">
                <div v-if="editing" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 p-4 backdrop-blur-sm" @click.self="closeEdit">
                    <div
                        ref="editDialog"
                        class="glass-panel max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-[2rem] p-6 shadow-2xl"
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="edit-third-party-title"
                    >
                        <div class="flex items-center justify-between gap-4">
                            <div>
                                <p class="brand-chip">Edicion</p>
                                <h3 id="edit-third-party-title" class="mt-3 text-xl font-black tracking-tight text-white">Editar tercero</h3>
                            </div>
                            <button class="rounded-full border border-white/10 bg-white/5 p-2 text-slate-400 transition hover:text-slate-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream" aria-label="Cerrar modal" @click="closeEdit">
                                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                            </button>
                        </div>

                        <p class="mt-3 text-sm text-slate-400">NIT: <span class="font-mono font-semibold text-slate-200">{{ editing.document_number }}</span></p>

                        <form class="mt-6 space-y-4" @submit.prevent="submitEdit">
                            <label class="block">
                                <span class="text-sm font-medium text-slate-200">Nombre</span>
                                <input
                                    id="edit-name"
                                    ref="editNameInput"
                                    v-model="editForm.name"
                                    type="text"
                                    required
                                    class="form-field mt-2"
                                    v-bind="editErrorAttributes('name')"
                                >
                                <span v-if="editForm.errors.name" id="edit-name-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.name }}</span>
                            </label>

                            <label class="block">
                                <span class="text-sm font-medium text-slate-200">Nombre alterno</span>
                                <input
                                    id="edit-alternate_name"
                                    v-model="editForm.alternate_name"
                                    type="text"
                                    class="form-field mt-2"
                                    placeholder="Opcional"
                                    v-bind="editErrorAttributes('alternate_name')"
                                >
                                <span v-if="editForm.errors.alternate_name" id="edit-alternate_name-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.alternate_name }}</span>
                            </label>

                            <label class="block">
                                <span class="text-sm font-medium text-slate-200">Tipo de persona</span>
                                <select
                                    id="edit-person_type"
                                    v-model="editForm.person_type"
                                    class="form-field mt-2"
                                    v-bind="editErrorAttributes('person_type')"
                                >
                                    <option value="1">Juridica</option>
                                    <option value="2">Natural</option>
                                </select>
                                <span v-if="editForm.errors.person_type" id="edit-person_type-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.person_type }}</span>
                            </label>

                            <div class="grid gap-4 sm:grid-cols-2">
                                <label class="block">
                                    <span class="text-sm font-medium text-slate-200">Codigo banco</span>
                                    <input
                                        id="edit-bank_code"
                                        v-model="editForm.bank_code"
                                        type="text"
                                        required
                                        class="form-field mt-2 font-mono"
                                        v-bind="editErrorAttributes('bank_code')"
                                    >
                                    <span v-if="editForm.errors.bank_code" id="edit-bank_code-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.bank_code }}</span>
                                </label>

                                <label class="block">
                                    <span class="text-sm font-medium text-slate-200">Tipo de cuenta</span>
                                    <select
                                        id="edit-bank_account_type"
                                        v-model="editForm.bank_account_type"
                                        class="form-field mt-2"
                                        v-bind="editErrorAttributes('bank_account_type')"
                                    >
                                        <option value="CA">Ahorro (CA)</option>
                                        <option value="CC">Corriente (CC)</option>
                                    </select>
                                    <span v-if="editForm.errors.bank_account_type" id="edit-bank_account_type-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.bank_account_type }}</span>
                                </label>
                            </div>

                            <label class="block">
                                <span class="text-sm font-medium text-slate-200">Numero de cuenta</span>
                                <input
                                    id="edit-bank_account_number"
                                    v-model="editForm.bank_account_number"
                                    type="text"
                                    required
                                    class="form-field mt-2 font-mono"
                                    v-bind="editErrorAttributes('bank_account_number')"
                                >
                                <span v-if="editForm.errors.bank_account_number" id="edit-bank_account_number-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.bank_account_number }}</span>
                            </label>

                            <div class="rounded-2xl border border-white/10 bg-slate-950/60 p-4">
                                <h4 class="text-sm font-black text-sky-100">Acceso de proveedor</h4>
                                <p class="mt-1 text-xs leading-5 text-slate-500">Deja estos campos vacios para conservar la contrasena actual. Minimo 8 caracteres.</p>

                                <div class="mt-4 grid gap-4 md:grid-cols-2">
                                    <label class="block">
                                        <span class="text-sm font-medium text-slate-200">Nueva contrasena</span>
                                        <input
                                            id="edit-password"
                                            v-model="editForm.password"
                                            type="password"
                                            autocomplete="new-password"
                                            class="form-field mt-2"
                                            v-bind="editErrorAttributes('password')"
                                        >
                                        <span v-if="editForm.errors.password" id="edit-password-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.password }}</span>
                                    </label>

                                    <label class="block">
                                        <span class="text-sm font-medium text-slate-200">Confirmar</span>
                                        <input
                                            id="edit-password_confirmation"
                                            v-model="editForm.password_confirmation"
                                            type="password"
                                            autocomplete="new-password"
                                            class="form-field mt-2"
                                            v-bind="editErrorAttributes('password_confirmation')"
                                        >
                                        <span v-if="editForm.errors.password_confirmation" id="edit-password_confirmation-error" class="mt-2 block text-sm text-rose-300">{{ editForm.errors.password_confirmation }}</span>
                                    </label>
                                </div>
                            </div>

                            <div class="flex justify-end gap-3 pt-2">
                                <button
                                    type="button"
                                    class="btn-ghost"
                                    @click="closeEdit"
                                >
                                    Cancelar
                                </button>
                                <button
                                    type="submit"
                                    :disabled="editForm.processing"
                                    class="btn-primary"
                                >
                                    {{ editForm.processing ? 'Guardando...' : 'Guardar cambios' }}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </Transition>
        </Teleport>
    </AdminLayout>
</template>
