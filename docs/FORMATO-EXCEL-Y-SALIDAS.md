# Formato de Excel y archivos de salida

Este documento es la referencia de datos para las personas que construyen el Excel semanal, revisan una importación o validan los archivos que se entregarán al banco.

## 1. Reglas generales del libro

- El archivo debe ser `.xlsx`.
- La carga web acepta como máximo 51.200 KB.
- El lector interno también limita el contenido descomprimido del ZIP a 100 MiB, cada entrada a 50 MiB, la cantidad de entradas a 1.000 y la relación de compresión a 200:1.
- Los nombres de hojas se comparan exactamente.
- Las hojas no configuradas se ignoran.
- Una hoja puede contener simultáneamente un bloque de facturas B:H y un bloque bancario I:O en la misma fila física.
- Las filas 1 a 6 de las hojas de sede se ignoran.
- La fila 1 de `MODELO` se ignora.
- No usar fórmulas que el lector no pueda entregar como valores; el parser recibe el valor serializado del XLSX, no calcula fórmulas.
- No agregar separadores de miles a los importes.
- Usar máximo dos decimales.
- Mantener los ceros iniciales de NIT/DNI, cuentas y códigos cuando sean significativos.

## 2. Hojas admitidas

El listado actual está en `src/config/payment_import.php`:

| Hoja | Uso |
|---|---|
| `MODELO` | Catálogo opcional de terceros, bancos y cuentas. |
| `CIUDAD JARDIN` | Pagos de la sede. |
| `UNICENTRO` | Pagos de la sede. |
| `JARDIN PLAZA` | Pagos de la sede. |
| `PANCE` | Pagos de la sede. |
| `BOCHALEMA` | Pagos de la sede. |
| `OFICINA` | Pagos de la sede. |
| `MERCADEO` | Pagos de la sede. |
| `GRANADA` | Pagos de la sede y salida bancaria separada. |

Si el archivo tiene una hoja llamada `Granada`, `GRANADA ` o con otra variación, no se procesa como `GRANADA`.

## 3. Hoja `MODELO`

### 3.1 Columnas

Los datos comienzan en la fila 2:

| Columna | Nombre lógico | Obligatorio | Validación |
|---|---|---:|---|
| A | NIT/DNI | Sí | Letras ASCII, números, punto o guion; máximo 50 caracteres. |
| B | Tipo de persona | Sí | `1` o `2`. |
| C | Número de cuenta | Sí | Letras ASCII, números, punto o guion; máximo 50 caracteres. |
| D | Tipo de cuenta | Sí | `CA` o `CC`, sin distinguir minúsculas al leer. |
| E | Código de banco | Sí | Letras ASCII, números, punto o guion; máximo 20 caracteres. |
| F | Nombre del banco | Recomendado | Si existe, no debe contener caracteres de control. |
| G | Nombre del tercero | Recomendado | Si existe, no debe contener caracteres de control. |

Ejemplo conceptual:

| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| NIT/DNI | Tipo | Cuenta | Tipo | Código | Banco | Tercero |
| 900123456 | 1 | 1234567890 | CA | 001 | Banco de ejemplo | Proveedor Ejemplo SAS |

### 3.2 Comportamiento al cargar

Cada fila de `MODELO`:

- crea o actualiza un banco por código;
- crea o actualiza un tercero por NIT/DNI;
- marca el tercero como activo;
- actualiza el nombre y tipo de persona;
- crea o actualiza la cuenta;
- marca esa cuenta como primaria;
- desmarca las cuentas anteriores como primarias.

La carga web no elimina registros que no estén en el nuevo archivo. La opción destructiva `payments:seed-catalog --clear` solo está disponible por consola.

Una fila inválida en los identificadores, tipos o código bancario hace fallar la carga completa de `MODELO`; no se importa parcialmente. F y G pueden llegar vacíos, pero se recomienda completarlos para que el catálogo y la conciliación sean claros.

## 4. Hojas de sedes: bloque B:H

### 4.1 Columnas

| Columna | Uso en una fila de factura | Uso en una fila `PEL` |
|---|---|---|
| B | Fecha Excel serial | Identificador del comprobante que contiene `PEL`. |
| C | Número de documento de detalle | No es necesario para detectar el `PEL`. |
| D | Nombre del tercero | No es necesario para detectar el `PEL`. |
| E | Documento soporte | No es necesario para detectar el `PEL`. |
| F | Documento de causación | No es necesario para detectar el `PEL`. |
| G | Importe de factura | Importe del comprobante. |
| H | Concepto | Concepto del comprobante. |

### 4.2 Fila de factura válida

Una fila se interpreta como factura si cumple simultáneamente:

- B es numérica y se puede convertir a fecha Excel;
- C no está vacío;
- E no está vacío;
- F no está vacío;
- G es numérico.

D puede estar vacío para efectos de detección, aunque se recomienda completarlo porque el nombre ayuda a conciliar el tercero.

Los importes de factura pueden ser positivos o negativos. Esto permite representar notas crédito. No se aceptan cero, más de dos decimales, separadores de miles ni notación científica.

### 4.3 Fila de comprobante

La columna B se reconoce como comprobante cuando contiene `PEL` rodeado por inicio/fin de texto, espacio, guion o guion bajo. La comparación no distingue mayúsculas.

Ejemplos reconocidos:

```text
PEL-1
PEL_1
005-PEL-02607006
pel 002
```

Ejemplos que no deben usarse como marcador aislado:

```text
PELTOTAL
APELADO
```

El parser asocia al comprobante todas las facturas válidas pendientes desde el `PEL` anterior o desde el comienzo de la sede. Al encontrar un `PEL`, limpia el conjunto de facturas pendientes para iniciar el siguiente bloque.

El importe de la fila `PEL` debe ser positivo y válido. La fecha efectiva del comprobante es la fecha de la primera factura del bloque, salvo que el usuario fuerce una fecha al importar.

### 4.4 Filas de resumen

El parser no genera `invalid_invoice_row` para filas cuyo valor B sea, sin distinguir mayúsculas:

```text
gran total
total
```

También reconoce como resumen una fila cuyo valor F sea `pago total`.

Se recomienda mantener las filas de resumen fuera de las columnas B:H o usar estos textos exactamente para evitar warnings innecesarios.

## 5. Hojas de sedes: bloque I:O

### 5.1 Columnas

| Columna | Nombre lógico | Obligatorio |
|---|---|---:|
| I | NIT/DNI | Sí |
| J | Tipo de persona | Sí |
| K | Número de cuenta | Sí |
| L | Tipo de cuenta | Sí |
| M | Código bancario | Sí |
| N | Importe | Sí |
| O | Nombre del tercero | No |

Ejemplo conceptual:

| I | J | K | L | M | N | O |
|---|---|---|---|---|---|---|
| NIT/DNI | Tipo | Cuenta | Tipo | Banco | Importe | Tercero |
| 900123456 | 1 | 1234567890 | CA | 001 | 1500000.00 | Proveedor Ejemplo SAS |

### 5.2 Validaciones

Una fila con cualquier dato en I:O es candidata bancaria. Se descarta con warning si:

- I no es un identificador seguro o J no es `1`/`2`;
- K no es un identificador seguro o L no es `CA`/`CC`;
- M no es un identificador seguro o supera 20 caracteres;
- N no es un importe positivo válido;
- O contiene caracteres de control.

El nombre O es opcional. Si existe, ayuda a la conciliación y puede actualizar el nombre de un tercero creado desde la línea bancaria.

## 6. Importes y fechas

### 6.1 Valores aceptados

El sistema convierte coma decimal a punto, por lo que puede leer, por ejemplo:

```text
1500000
1500000.00
1500000,00
```

No usar:

```text
1.500.000,00
1,500,000.00
1e6
0
```

El parser de facturas permite valores negativos; el parser de comprobantes y el bancario no.

### 6.2 Fechas Excel

Las fechas numéricas se interpretan con el origen serial `1899-12-30`. La parte decimal se descarta, por lo que se conserva la fecha pero no la hora.

Si se usa el campo `Fecha opcional` del panel o `--date=YYYY-MM-DD` en consola, esa fecha reemplaza la fecha de comprobantes y facturas del lote.

## 7. Identidad y conciliación

El importe es necesario, pero no suficiente. La aplicación busca una coincidencia única usando:

1. NIT/DNI de la línea contra documentos de detalle de las facturas;
2. nombre del tercero de la factura;
3. nombre de la línea bancaria;
4. nombre principal del catálogo;
5. nombre alterno del catálogo.

Para comparar nombres se eliminan mayúsculas/minúsculas, tildes, espacios, signos y se considera también la parte anterior a `/`.

Ejemplo de nombres que pueden coincidir:

```text
ATLANTIC FS SAS / NUEVA CUENTA
Atlantic F.S. S.A.S.
```

Si hay dos líneas con el mismo importe y ninguna identidad única, el comprobante queda sin línea asociada y se crea `ambiguous_bank_payment_line_match`.

## 8. Fallback de cuenta primaria

El fallback se usa únicamente si una sede completa no tiene líneas bancarias válidas.

Para cada comprobante de esa sede:

1. se resuelve el tercero por documento o nombre;
2. se busca una cuenta primaria activa;
3. se crea una línea bancaria con el importe del comprobante;
4. se guardan los datos bancarios como instantánea del recibo.

Si el tercero no se encuentra, se registra `bank_payment_line_missing_third_party`. Si no tiene cuenta primaria activa, se registra `bank_payment_line_missing_primary_account`.

Importante: si la sede sí tiene una o más líneas bancarias válidas, un comprobante que no concilie no recibe fallback individual.

## 9. Códigos de advertencia

| Código | Grupo | Interpretación |
|---|---|---|
| `invalid_invoice_amount` | Factura | G inválido, cero o con demasiados decimales. |
| `invalid_receipt_amount` | Comprobante | G del `PEL` inválido o no positivo. |
| `receipt_without_invoices` | Comprobante | `PEL` sin facturas válidas anteriores. |
| `receipt_amount_differs_from_invoice_total` | Comprobante | G del `PEL` no coincide con la suma de facturas. |
| `invalid_invoice_row` | Factura | Hay datos parciales en B:H, pero falta un campo obligatorio. |
| `invoices_without_receipt` | Factura | Facturas pendientes sin `PEL` posterior. |
| `invalid_bank_identity` | Banco | I o J inválidos. |
| `invalid_bank_account` | Banco | K o L inválidos. |
| `invalid_bank_code` | Banco | M inválido. |
| `invalid_bank_amount` | Banco | N inválido o no positivo. |
| `invalid_bank_third_party_name` | Banco | O contiene caracteres de control. |
| `bank_payment_line_not_found` | Conciliación | Ninguna línea coincide por importe. |
| `bank_payment_line_identity_mismatch` | Conciliación | Una línea coincide por importe, pero no por identidad. |
| `ambiguous_bank_payment_line_match` | Conciliación | Varias líneas coinciden por importe sin identidad única. |
| `bank_payment_line_without_invoice_detail` | Conciliación | Línea bancaria no utilizada por un comprobante. |
| `bank_payment_line_missing_third_party` | Fallback | No se pudo resolver tercero. |
| `bank_payment_line_missing_primary_account` | Fallback | No existe cuenta primaria activa. |
| `ambiguous_third_party_name_match` | Catálogo | El nombre corresponde a varios terceros. |

Cualquier advertencia deja el lote en `needs_review` hasta que un administrador apruebe o elimine el lote.

## 10. Archivos TXT bancarios

### 10.1 Origen

Los TXT se construyen exclusivamente desde `bank_payment_lines`, incluidos registros con `has_invoice_detail=false`.

### 10.2 Agrupación

Se suman filas que tengan la misma combinación:

```text
nit
person_type
bank_account_number
bank_account_type
bank_code
```

El total se redondea a pesos completos:

| Valor acumulado | Valor exportado |
|---:|---:|
| `100.49` | `100` |
| `100.50` | `101` |
| `100.99` | `101` |

### 10.3 Archivos creados

```text
src/storage/app/private/bank-payment-files/payment-batch-{id}.txt
src/storage/app/private/bank-payment-files/payment-batch-{id}-granada.txt
src/storage/app/private/bank-payment-files/payment-batch-{id}-branch-{branch_id}-{slug}.txt
```

Reglas:

- el archivo principal excluye `GRANADA`;
- el archivo de Granada solo se crea cuando hay líneas para esa sede;
- cada sede con líneas obtiene un archivo propio;
- el nombre de sede se convierte a slug en el nombre del archivo;
- el lote guarda rutas y checksums SHA-256.

### 10.4 Formato exacto

- Sin encabezado.
- Seis campos.
- Separador: tabulador (`U+0009`).
- Salto entre filas: `LF`.
- Salto de línea final: sí.
- Importe: entero, sin separadores ni decimales.
- No se permiten caracteres de control.

Ejemplo visual. Los símbolos `<TAB>` representan tabuladores reales y no deben escribirse literalmente:

```text
900123456<TAB>1<TAB>1234567890<TAB>CA<TAB>001<TAB>1500000
```

Orden de columnas:

| Posición | Campo |
|---:|---|
| 1 | NIT/DNI |
| 2 | Tipo de persona |
| 3 | Número de cuenta |
| 4 | Tipo de cuenta |
| 5 | Código de banco |
| 6 | Valor total entero |

## 11. Comprobantes PDF

Las rutas son:

```text
/admin/payment-receipts/{id}/pdf
/proveedor/comprobantes/{id}/pdf
```

El nombre descargado es `comprobante-{receipt_number}.pdf`.

Contenido:

- comprobante;
- fecha y sede;
- total pagado;
- tercero y NIT/DNI;
- banco;
- tipo de cuenta y últimos cuatro dígitos de la cuenta;
- concepto;
- documentos soporte y causación;
- detalle y total de facturas;
- fecha de generación.

El PDF usa preferentemente la instantánea histórica `beneficiary_*`. Para recibos antiguos sin esos datos puede consultar el tercero y su cuenta primaria actual.

El administrador puede consultar cualquier comprobante. El proveedor solo puede abrir el suyo.

## 12. Validación antes de importar

### Validación del Excel

- [ ] Los nombres de las hojas coinciden exactamente.
- [ ] Las filas de datos empiezan después de la fila 6.
- [ ] Cada bloque de facturas tiene un `PEL` posterior.
- [ ] B, C, E, F y G están completos en las facturas.
- [ ] Las fechas de B son fechas Excel numéricas.
- [ ] Los importes no tienen separadores de miles.
- [ ] I:N contiene datos bancarios completos.
- [ ] J solo usa `1` o `2`.
- [ ] L solo usa `CA` o `CC`.
- [ ] N es positivo.
- [ ] Los NIT/DNI y cuentas no perdieron ceros iniciales.

### Validación de resultados

- [ ] La cantidad de líneas bancarias coincide con lo esperado.
- [ ] La cantidad de comprobantes coincide con lo esperado.
- [ ] El total bancario coincide con la referencia I:N.
- [ ] Las advertencias fueron leídas y clasificadas.
- [ ] Los pagos sin detalle fueron confirmados.
- [ ] Las diferencias entre PEL y facturas fueron explicadas.
- [ ] Los archivos por sede tienen sentido.
- [ ] Granada fue revisado por separado.

## 13. Inspección desde consola

Para ver hojas y filas de ejemplo:

```bash
docker compose run --rm \
  -v "/ruta/local/excels:/imports:ro" \
  app php artisan payments:inspect "/imports/pagos.xlsx" --sheet=MERCADEO --from=7 --limit=20
```

Para resumen de todas las sedes presentes:

```bash
docker compose run --rm \
  -v "/ruta/local/excels:/imports:ro" \
  app php artisan payments:inspect "/imports/pagos.xlsx" --all
```

La inspección muestra los valores B:O y resume líneas, comprobantes y warnings. No guarda datos ni crea un lote.
