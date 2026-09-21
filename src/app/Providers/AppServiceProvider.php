<?php

namespace App\Providers;

use App\Models\User;
use App\Payments\Contracts\BankPaymentFileFormatterInterface;
use App\Payments\Contracts\ExcelWorkbookReaderFactoryInterface;
use App\Payments\Excel\XlsxWorkbookReaderFactory;
use App\Payments\Formatters\TabDelimitedBankPaymentFileFormatter;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(ExcelWorkbookReaderFactoryInterface::class, XlsxWorkbookReaderFactory::class);
        $this->app->bind(BankPaymentFileFormatterInterface::class, TabDelimitedBankPaymentFileFormatter::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::define('manage-payments', fn ($user): bool => $user instanceof User);

        RateLimiter::for('login', function (Request $request): Limit {
            $identity = mb_strtolower((string) ($request->input('email') ?? $request->input('document_number') ?? 'guest'));

            return Limit::perMinute(5)->by($identity.'|'.$request->ip());
        });
    }
}
