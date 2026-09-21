# Payment Receipts AG

Plataforma Laravel 13 para importar pagos semanales a proveedores, generar el archivo bancario consolidado por tercero y preparar la consulta de facturas/comprobantes.

## Stack

- PHP 8.4
- Laravel 13
- Vue 3 + Inertia + Vite
- PostgreSQL 17
- Docker Compose

## Estructura

- `src/`: aplicacion Laravel.
- `docker/`: imagen PHP 8.4 para la aplicacion.
- `docker-compose.yml`: servicios `app`, `node`, `postgres` y `pgadmin`.

## Levantar El Entorno

```bash
docker compose build app
docker compose run --rm app composer install
docker compose run --rm node npm install
docker compose up -d postgres
docker compose run --rm app php artisan key:generate --force
docker compose run --rm app php artisan migrate --force
docker compose run --rm app php artisan admin:user admin@example.com --password=change-this-password
```

Para desarrollo web:

```bash
docker compose up app node postgres
```

La aplicacion queda disponible en `http://localhost:8000`.

Para levantar pgAdmin 4:

```bash
docker compose up -d pgadmin
```

pgAdmin queda disponible en `http://localhost:5050`. Credenciales por defecto: `admin@example.com` / `change-this-password`. El servidor `postgres` queda preconfigurado como `Payment Receipts PostgreSQL`; la clave de la base de datos es `secret`.

## Panel Administrativo

Rutas disponibles:

```txt
/admin/imports
/admin/imports/{paymentBatch}
/admin/imports/{paymentBatch}/bank-file
/admin/payment-receipts/{paymentReceipt}/pdf
```

Desde `/admin/imports` se puede:

- Cargar un Excel semanal `.xlsx`.
- Opcionalmente forzar la fecha de pago.
- Importar el lote y generar el TXT consolidado.
- Revisar y aprobar manualmente los lotes que tengan advertencias antes de generar el TXT.
- Ver historial de lotes.
- Entrar al detalle de cada lote.
- Descargar el TXT bancario.
- Revisar advertencias de importacion.
- Ver lineas bancarias y comprobantes.
- Descargar PDF por comprobante.

## Importar Un Excel Semanal

Para inspeccionar nombres de hojas y una muestra de filas antes de importar:

```bash
docker compose run --rm -v "/ruta/local/de/excels:/imports:ro" app php artisan payments:inspect "/imports/archivo.xlsx" --sheet=MERCADEO
```

El comando principal es:

```bash
docker compose run --rm -v "/ruta/local/de/excels:/imports:ro" app php artisan payments:import "/imports/archivo.xlsx"
```

Ejemplo con el archivo de julio:

```bash
docker compose run --rm -v "/mnt/c/Users/COORD. DE SISTEMAS/Downloads/ARCHIVOS PAGOS A PROVEEDORES 2 DE JULIO 2026:/imports:ro" app php artisan payments:import "/imports/RELACION PAGOS 02 DE JULIO DEL 2026.xlsx"
```

Opciones:

```bash
--date=2026-07-02
--no-bank-file
--approve-warnings
```

## Generar O Regenerar El TXT Bancario

```bash
docker compose run --rm app php artisan payments:bank-file 1
```

El archivo consolidado queda en:

```txt
src/storage/app/private/bank-payment-files/payment-batch-{id}.txt
```

Formato del TXT, sin encabezado y separado por tabulaciones:

```txt
NIT/DNI	tipo_persona	cuenta_bancaria	tipo_cuenta	id_banco	valor_total
```

Reglas:

- Se mantiene un archivo consolidado por lote semanal/dia y tambien se generan archivos separados por sede.
- La fuente del TXT es `bank_payment_lines`, importada desde el bloque bancario `I:N` de cada sede.
- Se incluyen pagos aunque no tengan factura detallada o comprobante asociado.
- Se agrupa por `NIT/DNI + tipo persona + cuenta + tipo cuenta + banco`.
- El valor se suma, se redondea al peso mas cercano y se exporta sin separadores ni decimales.

## Archivos Con Y Sin MODELO

- Si existe la hoja `MODELO`, se usa para crear/actualizar terceros, bancos y cuentas.
- Si no existe `MODELO`, se omite y los terceros/cuentas se toman del bloque bancario de cada sede.
- Las facturas se leen desde el detalle `B:H` y se agrupan por comprobante `PEL`.
- Los terceros pueden tener `nombre alterno`; la conciliacion por nombre valida contra nombre principal o alterno.
- Un archivo ya importado no puede procesarse de nuevo: se identifica mediante SHA-256.
- Las coincidencias de comprobantes requieren importe e identidad del tercero; el importe por si solo no es suficiente.
- Los lotes con advertencias quedan en `needs_review` hasta que un administrador los aprueba.

## Comprobantes PDF

Ruta base disponible para comprobantes importados:

```txt
/admin/payment-receipts/{paymentReceipt}/pdf
```

Las rutas `/admin/*`, incluyendo PDFs y descargas TXT, requieren autenticacion administrativa. Crea o actualiza el primer usuario con:

```bash
docker compose run --rm app php artisan admin:user admin@example.com --password=change-this-password
```

## Verificaciones

```bash
docker compose run --rm app php artisan test
docker compose run --rm app ./vendor/bin/pint --test
docker compose run --rm app composer validate --strict
docker compose run --rm node npm run build
```

## Diseno SOLID

- `Actions`: casos de uso como importar lote, generar TXT y PDF.
- `Parsers`: interpretan secciones concretas del Excel.
- `Importers`: persisten catalogos, lineas bancarias, facturas y comprobantes.
- `DTO`: transportan datos parseados sin acoplarlos a Eloquent.
- `Contracts`: abstraen lectura de Excel y formato de salida.
- `Formatters`: generan representaciones externas como el TXT tabulado.
