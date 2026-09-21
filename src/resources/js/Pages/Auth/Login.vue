<script setup>
import { Head, Link, useForm } from '@inertiajs/vue3';
import logoUrl from '../../../logo_mw.png';

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post('/login', {
        onFinish: () => form.reset('password'),
    });
};
</script>

<template>
    <Head title="Acceso administrativo" />

    <main class="page-shell flex items-center justify-center px-5 py-10 sm:px-6">
        <div class="brand-orb left-1/2 top-8 h-64 w-64 -translate-x-1/2 bg-mw-blue/30 animate-soft-float" />
        <div class="brand-orb bottom-12 left-12 h-48 w-48 bg-mw-red/20 animate-soft-float" style="animation-delay: -4s" />

        <section class="shell-content glass-panel animate-panel-in w-full max-w-md rounded-[2rem] p-7 sm:p-8">
            <div class="flex items-center gap-4">
                <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl border border-white/10 bg-white p-2 shadow-brand-glow">
                    <img :src="logoUrl" alt="Mister Wings" class="max-h-full max-w-full object-contain">
                </div>
                <div>
                    <p class="brand-chip">Admin</p>
                    <h1 class="mt-3 text-2xl font-black tracking-tight text-white">Acceso administrativo</h1>
                </div>
            </div>
            <p class="mt-5 text-sm leading-6 text-slate-400">Ingresa con una cuenta autorizada para gestionar importaciones, catalogos y archivos bancarios.</p>

            <form class="mt-8 space-y-5" @submit.prevent="submit">
                <label class="block">
                    <span class="text-sm font-medium text-slate-200">Correo</span>
                    <input
                        v-model="form.email"
                        type="email"
                        autocomplete="username"
                        required
                        class="form-field mt-2"
                    >
                    <span v-if="form.errors.email" class="mt-2 block text-sm text-rose-300">{{ form.errors.email }}</span>
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

                <label class="flex items-center gap-3 text-sm text-slate-300">
                    <input v-model="form.remember" type="checkbox" class="rounded border-slate-700 bg-slate-950 text-mw-red focus:ring-mw-red">
                    Recordar sesion
                </label>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="btn-primary w-full"
                >
                    <span>{{ form.processing ? 'Ingresando...' : 'Ingresar' }}</span>
                </button>
            </form>

            <div class="mt-6 flex justify-between gap-4 text-sm font-semibold text-slate-400">
                <Link href="/" class="transition hover:text-sky-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream">Volver al inicio</Link>
                <Link href="/proveedor" class="transition hover:text-sky-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream">Portal proveedores</Link>
            </div>
        </section>
    </main>
</template>
