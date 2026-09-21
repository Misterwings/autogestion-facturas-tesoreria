<script setup>
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import logoUrl from '../../logo_mw.png';

defineProps({
    title: {
        type: String,
        required: true,
    },
});

const page = usePage();

const navItems = [
    { href: '/', label: 'Inicio' },
    { href: '/admin/catalog', label: 'Catalogo' },
    { href: '/admin/imports', label: 'Importaciones' },
];

const isActive = (href) => {
    if (href === '/') {
        return page.url === '/';
    }

    return page.url?.startsWith(href);
};

const logout = () => {
    router.post('/logout');
};
</script>

<template>
    <Head :title="title" />

    <main class="page-shell">
        <div class="brand-orb -left-16 top-16 h-56 w-56 bg-mw-red/25 animate-soft-float" />
        <div class="brand-orb right-0 top-0 h-72 w-72 bg-mw-blue/35 animate-soft-float" style="animation-delay: -3s" />

        <header class="shell-content border-b border-white/10 bg-slate-950/70 backdrop-blur-2xl">
            <div class="mx-auto flex max-w-7xl flex-col gap-5 px-5 py-5 sm:px-6 lg:flex-row lg:items-center lg:justify-between">
                <div class="flex items-center gap-4">
                    <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-[1.35rem] border border-white/10 bg-white p-2 shadow-brand-glow">
                        <img :src="logoUrl" alt="Mister Wings" class="max-h-full max-w-full object-contain">
                    </div>

                    <div>
                        <p class="brand-chip">Payment Receipts AG</p>
                        <h1 class="mt-3 text-2xl font-black tracking-tight text-white sm:text-3xl">{{ title }}</h1>
                    </div>
                </div>

                <nav class="flex flex-wrap items-center gap-2 text-sm" aria-label="Navegacion administrativa">
                    <Link
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="rounded-full border px-4 py-2 font-bold transition hover:-translate-y-0.5 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-mw-cream"
                        :class="isActive(item.href) ? 'border-mw-red/60 bg-mw-red/15 text-rose-100 shadow-lg shadow-mw-red/10' : 'border-white/10 bg-slate-900/60 text-slate-300 hover:border-sky-300/60 hover:text-sky-100'"
                    >
                        {{ item.label }}
                    </Link>

                    <span v-if="page.props.auth?.user" class="rounded-full border border-white/10 bg-white/5 px-3 py-2 text-xs font-semibold text-slate-400">
                        {{ page.props.auth.user.email }}
                    </span>

                    <button type="button" class="btn-danger rounded-full px-4 py-2" @click="logout">
                        Salir
                    </button>
                </nav>
            </div>
        </header>

        <section class="shell-content mx-auto max-w-7xl px-5 py-8 sm:px-6">
            <Transition name="fade-slide" mode="out-in">
                <div v-if="page.props.flash?.success" key="success" class="mb-5 rounded-2xl border border-emerald-300/30 bg-emerald-400/10 px-5 py-4 text-sm font-semibold text-emerald-100 shadow-lg shadow-emerald-950/20" role="status">
                    {{ page.props.flash.success }}
                </div>
                <div v-else-if="page.props.flash?.error" key="error" class="mb-5 rounded-2xl border border-rose-300/30 bg-rose-400/10 px-5 py-4 text-sm font-semibold text-rose-100 shadow-lg shadow-rose-950/20" role="alert">
                    {{ page.props.flash.error }}
                </div>
            </Transition>

            <div class="animate-panel-in">
                <slot />
            </div>
        </section>
    </main>
</template>
