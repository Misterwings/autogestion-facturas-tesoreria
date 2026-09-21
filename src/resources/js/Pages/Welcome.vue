<script setup>
import { Head, Link } from '@inertiajs/vue3';
import logoUrl from '../../logo_mw.png';

const features = [
    ['Importacion semanal', 'Lee hojas por sede, detecta MODELO y registra advertencias accionables.'],
    ['TXT bancario', 'Consolida pagos por tercero y cuenta desde bank_payment_lines.'],
    ['Portal proveedor', 'Permite consultar y descargar comprobantes PDF por NIT/DNI.'],
];
</script>

<template>
    <Head title="Inicio" />

    <main class="page-shell px-5 py-8 sm:px-6 lg:py-12">
        <div class="brand-orb left-8 top-10 h-52 w-52 bg-mw-red/25 animate-soft-float" />
        <div class="brand-orb bottom-8 right-8 h-72 w-72 bg-mw-blue/35 animate-soft-float" style="animation-delay: -2.5s" />

        <section class="shell-content mx-auto max-w-5xl">
            <div class="glass-panel animate-panel-in rounded-[2rem] p-7 sm:p-9 lg:p-10">
                <div class="flex flex-col gap-6 sm:flex-row sm:items-center">
                    <div class="flex h-24 w-24 shrink-0 items-center justify-center rounded-[1.8rem] border border-white/10 bg-white p-3 shadow-brand-glow">
                        <img :src="logoUrl" alt="Mister Wings" class="max-h-full max-w-full object-contain">
                    </div>

                    <div>
                        <p class="brand-chip">Payment Receipts AG</p>
                        <p class="mt-3 text-sm font-semibold uppercase tracking-[0.26em] text-slate-400">Mister Wings Backoffice</p>
                    </div>
                </div>

                <h1 class="mt-8 max-w-4xl text-4xl font-black leading-[0.95] tracking-tight text-white sm:text-6xl lg:text-7xl">
                    Autogestion de pagos sin friccion.
                </h1>
                <p class="mt-6 max-w-3xl text-base leading-8 text-slate-300 sm:text-lg">
                    Plataforma Laravel 13 para importar pagos desde Excel, consolidar archivos bancarios y entregar comprobantes PDF a proveedores con una experiencia mas clara y trazable.
                </p>

                <div class="mt-8 flex flex-wrap gap-3">
                    <Link href="/proveedor" class="btn-primary">
                        Portal proveedores
                    </Link>
                    <Link href="/admin/imports" class="btn-secondary">
                        Panel administrativo
                    </Link>
                </div>

                <div class="mt-10 grid gap-4 md:grid-cols-3">
                    <article v-for="feature in features" :key="feature[0]" class="feature-card rounded-3xl p-5">
                        <p class="text-sm font-black text-sky-100">{{ feature[0] }}</p>
                        <p class="mt-3 text-sm leading-6 text-slate-400">{{ feature[1] }}</p>
                    </article>
                </div>
            </div>
        </section>
    </main>
</template>
