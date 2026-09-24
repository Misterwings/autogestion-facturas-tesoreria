# Documentación de Payment Receipts AG

Payment Receipts AG es una plataforma para recibir archivos semanales de pagos a proveedores, interpretar sus hojas de Excel, conciliar comprobantes con referencias bancarias, generar archivos TXT para el banco y publicar comprobantes PDF para los proveedores.

Esta carpeta describe el comportamiento implementado en el código actual. No es una especificación de funcionalidades futuras. Cuando una sección identifica una limitación o un riesgo, significa que el comportamiento existe o se deduce directamente de la implementación y debe tenerse en cuenta en la operación.

## Documentos

| Documento | Audiencia | Contenido |
|---|---|---|
| [Documentación técnica y de operación](DOCUMENTACION-TECNICA.md) | Desarrollo, infraestructura, soporte y responsables de operación | Arquitectura, flujo de datos, reglas de importación, base de datos, rutas, comandos, despliegue, seguridad, backups, pruebas y limitaciones. |
| [Manual de usuario](MANUAL-USUARIO.md) | Administradores y proveedores | Acceso al sistema, carga de catálogo, importación semanal, revisión de advertencias, descargas, PDFs, portal de proveedores y solución de problemas. |
| [Formato de Excel y archivos de salida](FORMATO-EXCEL-Y-SALIDAS.md) | Personas que preparan Excel, soporte y tesorería | Contrato de las hojas, columnas, tipos de dato, reglas de validación, códigos de advertencia y formato exacto de los TXT y PDF. |

## Lectura recomendada

1. Para utilizar el sistema sin desarrollar: comenzar por el [manual de usuario](MANUAL-USUARIO.md).
2. Para preparar o validar un archivo de pagos: consultar [Formato de Excel y archivos de salida](FORMATO-EXCEL-Y-SALIDAS.md).
3. Para instalar, desplegar, respaldar o mantener la aplicación: consultar la [documentación técnica](DOCUMENTACION-TECNICA.md).

## Alcance documentado

La documentación cubre:

- Panel administrativo protegido por sesión.
- Catálogo de terceros, bancos y cuentas bancarias.
- Carga opcional de la hoja `MODELO`.
- Importación de las hojas de sedes configuradas.
- Lectura del detalle de facturas y comprobantes (`B:H`).
- Lectura de referencias bancarias (`I:O`).
- Conciliación por importe e identidad del tercero.
- Uso de la cuenta primaria como fallback.
- Estados del lote y proceso de aprobación.
- Generación consolidada, por `GRANADA` y por sede.
- Comprobantes PDF para administración y proveedores.
- Portal de proveedores con filtros por fecha y sede.
- Operación mediante Docker Compose y comandos Artisan.

## Fuente de verdad

La fuente de verdad funcional es el código de `src/`. Las referencias principales son:

- `src/routes/web.php` y `src/routes/console.php`: interfaces web y comandos.
- `src/config/payment_import.php`: hojas de sedes admitidas.
- `src/app/Payments/`: lectura, parseo, conciliación, persistencia y generación de archivos.
- `src/app/Http/Controllers/`: validaciones y permisos de cada flujo.
- `src/database/migrations/`: esquema de base de datos.
- `src/resources/js/Pages/`: pantallas de usuario.
- `src/tests/Feature/`: comportamiento cubierto por pruebas.

## Convenciones de esta documentación

- `NIT/DNI` identifica el número de documento del tercero.
- `PEL` identifica una fila de comprobante dentro de una hoja de sede.
- `MODELO` es la hoja opcional que precarga o actualiza el catálogo.
- `I:N` se refiere a las columnas bancarias principales; `O` contiene el nombre opcional del tercero.
- `B:H` se refiere al bloque de facturas y comprobantes.
- `lote` y `payment batch` significan el mismo registro en `payment_batches`.
- Las rutas de archivos privadas son relativas a `src/storage/app/private/`.

## Estado del documento

Esta documentación fue elaborada a partir de la estructura y el código disponible en el repositorio. Debe actualizarse junto con cualquier cambio en:

- Hojas o columnas del Excel.
- Estados del lote.
- Reglas de conciliación.
- Formato bancario.
- Rutas o permisos.
- Campos de catálogo o credenciales de proveedores.
