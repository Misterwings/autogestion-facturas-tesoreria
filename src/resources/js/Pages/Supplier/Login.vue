<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import logoUrl from '../../../logo_mw.png';

const form = useForm({
    document_number: '',
    password: '',
});

const submit = () => {
    form.post('/proveedor/login', {
        onFinish: () => form.reset('password'),
    });
};
</script>

<template>
    <Head title="Portal de proveedores" />

    <main class="page-shell flex items-center justify-center px-5 py-10 sm:px-6">
        <div class="brand-orb right-8 top-8 h-64 w-64 bg-mw-red/20 animate-soft-float" />
        <div class="brand-orb bottom-8 left-8 h-72 w-72 bg-mw-blue/30 animate-soft-float" style="animation-delay: -3s" />

        <section class="shell-content glass-panel animate-panel-in w-full max-w-md rounded-[2rem] p-7 sm:p-8">
            <div class="flex items-center gap-4">
                <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl border border-white/10 bg-white p-2 shadow-brand-glow">
                    <img :src="logoUrl" alt="Mister Wings" class="max-h-full max-w-full object-contain">
                </div>
                <div>
                    <p class="brand-chip">Proveedor</p>
                    <h1 class="mt-3 text-2xl font-black tracking-tight text-white">Portal de proveedores</h1>
                </div>
            </div>
            <p class="mt-5 text-sm leading-6 text-slate-400">Ingresa con el NIT/DNI registrado en el catalogo y la contrasena asignada por administracion.</p>

            <form class="mt-8 space-y-5" @submit.prevent="submit">
                <label class="block">
                    <span class="text-sm font-medium text-slate-200">NIT / DNI</span>
                    <input
                        v-model="form.document_number"
                        type="text"
                        autocomplete="username"
                        required
                        class="form-field mt-2"
                    >
                    <span v-if="form.errors.document_number" class="mt-2 block text-sm text-rose-300">{{ form.errors.document_number }}</span>
                </label>

                <label class="block">
                    <span class="text-sm font-medium text-slate-200">Contrasena</span>
                    <input
                        v-model="form.password"
                        type="password"
                        autocomplete="current-password"
                        required
                        class="form-field mt-2"
                    >
                    <span v-if="form.errors.password" class="mt-2 block text-sm text-rose-300">{{ form.errors.password }}</span>
                </label>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="btn-primary w-full"
                >
                    {{ form.processing ? 'Ingresando...' : 'Ingresar' }}
                </button>
            </form>

            <div class="mt-6 flex justify-between gap-4 text-sm font-semibold text-slate-400">
                <Link href="/" class="transition hover:text-sky-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream">Volver al inicio</Link>
                <Link href="/login" class="transition hover:text-sky-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream">Acceso administrativo</Link>
            </div>
        </section>
    </main>
</template>
