# Repository Instructions

## Layout
- The repo root is a Docker wrapper; the Laravel app, lockfiles, tests, and source live in `src/`.
- Run Composer, NPM, and Artisan from `src/`, or from the root with Docker Compose service `app` for Composer/Artisan and `node` for NPM.
- Ignore generated `src/vendor`, `src/node_modules`, `src/bootstrap/cache`, `src/storage`, and `src/public/build` in source searches and edits.

## Setup And Runtime
- Prefer Docker unless intentionally matching local versions: PHP 8.4, Laravel 13, Node 22, PostgreSQL 17.
- Root `.env.example` only sets `COMPOSE_PROJECT_NAME`; Laravel env defaults live in `src/.env.example`, and `src/.env` is needed before `key:generate`.
- Fresh setup from the repo root:

```bash
cp src/.env.example src/.env
docker compose build app
docker compose run --rm app composer install
docker compose run --rm node npm install
docker compose up -d postgres
docker compose run --rm app php artisan key:generate --force
docker compose run --rm app php artisan migrate --force
docker compose run --rm app php artisan admin:user admin@example.com --password=change-this-password
```

- Web development runs `docker compose up app node postgres`; Laravel serves `http://localhost:8000`, Vite serves `http://localhost:5173`, and the `node` service runs `npm install && npm run dev` on startup.

## Verification
- Full verification from the repo root:

```bash
docker compose run --rm app php artisan test
docker compose run --rm app ./vendor/bin/pint --test
docker compose run --rm app composer validate --strict
docker compose run --rm node npm run build
```

- Focus PHP tests with `docker compose run --rm app php artisan test --filter=TestName` or `--testsuite=Feature`.
- `src/phpunit.xml` and `tests/TestCase.php` force sqlite `:memory:`, array cache/session, and sync queue, so PHPUnit does not need Postgres.
- Frontend scripts are only `npm run dev` and `npm run build`; no JS lint or typecheck script is defined.

## Entrypoints
- Closure Artisan commands live in `src/routes/console.php`: `admin:user`, `payments:seed-catalog`, `payments:inspect`, `payments:import`, and `payments:bank-file`.
- Web routes live in `src/routes/web.php`; `/` renders Inertia `Welcome`, `/login` is guest-only, and every `/admin/*` route, including PDF/TXT downloads, uses `auth`.
- Payment import/generation code is concentrated in `src/app/Payments`: `Actions` orchestrate, `Parsers` read Excel sections, `Importers` persist, DTOs carry parsed data, and `Formatters` produce external files.
- Interface bindings for the custom XLSX reader and bank TXT formatter are in `src/app/Providers/AppServiceProvider.php`.

## Payment Import Rules
- Only branch sheets listed in `src/config/payment_import.php` are imported; update that config when adding a branch sheet.
- `MODELO` is optional. When present it seeds third parties, banks, and accounts; `payments:seed-catalog FILE --clear` wipes existing catalog tables before seeding.
- The XLSX reader in `src/app/Payments/Excel` is custom `ZipArchive`/`SimpleXML`; PhpSpreadsheet is not installed.
- Branch parsing skips rows 1-6. Invoice details use columns `B:H`; receipt rows are detected by `PEL` in column `B`; bank lines use `I:N` plus optional third-party name in `O`.
- If a branch sheet has no valid bank block, import falls back to the matched third party's active primary bank account; missing matches/accounts become `import_errors` warnings.
- `payments:import FILE` generates bank files unless `--no-bank-file` is passed; use `--date=YYYY-MM-DD` to override the date inferred from invoice rows.
- Bank TXT files are generated from `bank_payment_lines`, including lines without invoice detail, not from receipt or invoice totals.
- TXT rows group by `nit + person_type + bank_account_number + bank_account_type + bank_code`, round totals to whole pesos, have no header, and are tab-delimited.
- Bank file outputs are under `src/storage/app/private/bank-payment-files/`: consolidated non-GRANADA `payment-batch-{id}.txt`, optional `payment-batch-{id}-granada.txt`, and per-branch `payment-batch-{id}-branch-{branch_id}-{slug}.txt`.

## Frontend
- Vite inputs are `resources/css/app.css` and `resources/js/app.js`; Inertia page names resolve from `resources/js/Pages/**/*.vue`.
- Tailwind is v4 through `@tailwindcss/vite` and CSS `@import 'tailwindcss'`; there is no `tailwind.config.js`.
