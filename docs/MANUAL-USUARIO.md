# Manual de usuario

## 1. Objetivo

Este manual explica cómo utilizar Payment Receipts AG para:

- administrar el catálogo de terceros y sus cuentas;
- cargar un Excel semanal de pagos;
- revisar advertencias y aprobar lotes;
- descargar archivos TXT para el banco;
- consultar o descargar comprobantes PDF;
- permitir que cada proveedor consulte sus propios comprobantes.

El sistema tiene dos perfiles operativos:

| Perfil | Puede hacer |
|---|---|
| Administrador | Gestionar catálogo, importar lotes, revisar advertencias, aprobar, eliminar lotes y descargar TXT/PDF. |
| Proveedor | Consultar sus comprobantes y descargar sus PDF; no puede modificar datos ni ver información de otros proveedores. |

## 2. Acceso al sistema

En el entorno local, la aplicación está disponible en:

```text
http://localhost:8000
```

Las entradas visibles son:

- `/`: inicio.
- `/login`: acceso administrativo.
- `/proveedor`: portal de proveedores.

Si aparece una pantalla de error o no carga la aplicación, contactar al responsable técnico antes de repetir una importación.

## 3. Acceso administrativo

### 3.1 Iniciar sesión

1. Abrir `http://localhost:8000/login`.
2. Escribir el correo de la cuenta administrativa.
3. Escribir la contraseña.
4. Marcar `Recordar sesión` solo si el equipo es confiable.
5. Pulsar `Ingresar`.

La aplicación muestra `Ingresando...` mientras procesa el acceso. Por seguridad, la contraseña se limpia al finalizar la solicitud.

Después del acceso se llega a `Importaciones de pagos` o a la página que se intentó abrir antes de iniciar sesión.

El sistema limita los intentos fallidos a cinco por minuto por identidad e IP. Si se alcanza el límite, esperar antes de volver a intentar.

### 3.2 Navegación administrativa

El menú superior contiene:

- `Inicio`.
- `Catálogo`.
- `Importaciones`.
- correo del administrador conectado.
- `Salir`.

Los mensajes verdes indican éxito. Los mensajes rojos indican un error o una acción pendiente.

### 3.3 Cerrar sesión

Pulsar `Salir` en el menú superior. La sesión se invalida y se regresa al acceso administrativo.

## 4. Administrar el catálogo

El catálogo contiene terceros, bancos, cuentas bancarias y, opcionalmente, las contraseñas de acceso al portal.

Abrir:

```text
/admin/catalog
```

### 4.1 Cargar una hoja `MODELO`

Usar esta función para crear o actualizar terceros, bancos y cuentas a partir de un Excel.

1. Ir a `Catálogo`.
2. Seleccionar un archivo `.xlsx` que contenga la hoja `MODELO`.
3. Pulsar `Actualizar catálogo`.
4. Esperar a que finalice la barra de progreso.
5. Confirmar el mensaje `Catálogo actualizado`.
6. Buscar uno o más NIT/DNI para verificar el resultado.

La carga web actualiza el catálogo sin borrar los registros anteriores. Un tercero con el mismo NIT/DNI no se duplica.

La hoja debe tener, desde la columna A hasta la G:

| Columna | Dato esperado | Valores o ejemplo |
|---|---|---|
| A | NIT/DNI | `900123456` |
| B | Tipo de persona | `1` jurídica, `2` natural |
| C | Número de cuenta | `1234567890` |
| D | Tipo de cuenta | `CA` ahorro, `CC` corriente |
| E | Código bancario | Código usado por el banco |
| F | Nombre del banco | `Banco de ejemplo` |
| G | Nombre del tercero | Nombre legal o comercial |

La fila 1 se considera encabezado y se omite. Los campos de NIT/DNI, tipos, cuenta y código bancario deben ser válidos. Los nombres del banco y del tercero pueden quedar vacíos, aunque se recomienda completarlos para facilitar la consulta y la conciliación.

Si se muestra `El archivo no contiene la hoja MODELO`, seleccionar otro archivo o corregir el nombre exacto de la hoja. Los nombres distinguen espacios y deben ser exactamente `MODELO`.

### 4.2 Consultar el directorio

El directorio muestra únicamente terceros activos y permite buscar por NIT/DNI parcial.

1. Escribir el dato en `Buscar por NIT / DNI`.
2. Pulsar `Buscar`.
3. Usar `Limpiar` para volver al listado completo.

La tabla muestra:

- NIT/DNI.
- nombre principal;
- nombre alterno;
- tipo de persona;
- estado de acceso;
- banco;
- tipo y número de cuenta;
- acciones disponibles.

En pantallas pequeñas la misma información aparece como tarjetas.

### 4.3 Editar un tercero

Editar permite corregir datos y configurar el acceso del proveedor.

1. Pulsar `Editar` en el tercero.
2. Revisar o cambiar `Nombre`.
3. Opcionalmente completar `Nombre alterno` para facilitar la conciliación.
4. Elegir `Jurídica` o `Natural`.
5. Confirmar el código del banco.
6. Elegir `Ahorro (CA)` o `Corriente (CC)`.
7. Confirmar el número de cuenta.
8. Si se necesita acceso de proveedor, escribir una contraseña de al menos ocho caracteres y repetirla.
9. Si no se desea cambiar la contraseña, dejar ambos campos vacíos.
10. Pulsar `Guardar cambios`.

Al guardar la cuenta indicada se convierte en la cuenta primaria del tercero. Las demás cuentas dejan de ser primarias. El banco se crea automáticamente si no existía, usando inicialmente un nombre provisional basado en el código.

### 4.4 Activar el acceso de un proveedor

Un tercero puede aparecer como `Sin contraseña` aunque esté activo en el catálogo.

1. Abrir `Editar`.
2. Escribir una contraseña de al menos ocho caracteres.
3. Confirmarla.
4. Guardar.
5. Entregar la contraseña al proveedor por un canal seguro, nunca en un canal público.

El sistema almacena la contraseña de forma hasheada. Administración no puede consultar la contraseña existente; solo puede reemplazarla.

### 4.5 Desactivar un tercero

1. Pulsar `Eliminar` en la fila del tercero.
2. Confirmar el mensaje que muestra nombre y NIT/DNI.

`Eliminar` es una desactivación lógica:

- conserva el historial de pagos;
- desactiva el tercero;
- elimina su contraseña de proveedor;
- impide nuevos accesos al portal.

## 5. Importar el archivo semanal

### 5.1 Preparar el archivo

Antes de cargarlo, verificar:

- formato `.xlsx`;
- tamaño máximo aproximado de 50 MB;
- presencia de al menos una hoja de sede admitida;
- filas de datos a partir de la fila 7;
- bloques de facturas en B:H;
- bloques bancarios en I:O;
- comprobantes identificados por `PEL` en la columna B;
- importes con máximo dos decimales;
- NIT/DNI, cuenta, tipo de cuenta y banco válidos;
- que el contenido no sea exactamente igual a un archivo ya importado.

Las sedes que el sistema reconoce actualmente son:

```text
CIUDAD JARDIN
UNICENTRO
JARDIN PLAZA
PANCE
BOCHALEMA
OFICINA
MERCADEO
GRANADA
```

Las hojas con otros nombres se ignoran. La hoja `MODELO` es opcional en el archivo semanal.

Consultar [Formato de Excel y archivos de salida](FORMATO-EXCEL-Y-SALIDAS.md) para el detalle de cada columna.

### 5.2 Cargar el archivo

1. Ir a `Importaciones`.
2. En `Cargar Excel semanal`, seleccionar el archivo `.xlsx`.
3. Opcionalmente indicar la `Fecha`.
4. Pulsar `Importar pagos`.
5. Esperar a que desaparezca el estado `Importando...`.
6. Revisar el detalle del lote que se abre automáticamente.

Si no se indica fecha, el sistema usa la fecha del primer comprobante que encuentre. Si se indica, debe tener formato `AAAA-MM-DD`.

El aviso de catálogo informa si ya existen terceros activos. El archivo puede crear catálogo desde `MODELO` o desde líneas bancarias válidas, incluso si no había catálogo previo.

### 5.3 Qué sucede durante la importación

El sistema:

1. valida el archivo;
2. verifica si su contenido ya fue importado;
3. lee `MODELO` si existe;
4. procesa cada sede configurada;
5. importa líneas bancarias, comprobantes y facturas;
6. intenta conciliar comprobantes con líneas bancarias;
7. usa la cuenta primaria como fallback cuando una sede no tiene líneas bancarias válidas;
8. calcula totales;
9. crea el TXT automáticamente si no hay advertencias;
10. deja el lote pendiente si hay advertencias.

No cerrar el navegador ni iniciar una segunda importación mientras la primera está procesándose.

## 6. Revisar el detalle de un lote

Cada lote tiene una URL similar a:

```text
/admin/imports/123
```

La cabecera muestra:

- nombre del archivo;
- número de lote;
- estado;
- fecha de pago;
- si tenía `MODELO`;
- fecha de importación.

### 6.1 Estados visibles

| Estado | Qué significa | Acción |
|---|---|---|
| `Validado` | No se detectaron advertencias. | Confirmar totales y descargar salidas. |
| `Pendiente de revisión` | Hay advertencias. | Leerlas, comparar con el Excel y aprobar solo si son aceptables. |
| `Aprobado` | Se registró la aprobación. | Esperar o verificar generación. |
| `Generando archivos` | Se están escribiendo los TXT. | No eliminar ni repetir la generación. |
| `Listo` | Los archivos bancarios están publicados. | Descargar y verificar. |
| `Fallo al generar` | La importación existe, pero la salida falló. | Contactar soporte para revisar logs y regenerar. |

### 6.2 Tarjetas de resumen

Comparar estas cifras con el Excel de origen:

- `Líneas referencia (I:N)`;
- `Comprobantes`;
- `Facturas (B:H)`;
- `Alertas`;
- `Total facturas (B:H)`;
- `Total referencia bancaria (I:N)`.

El total bancario se calcula desde las líneas I:N. El total de facturas incluye notas crédito negativas y puede no coincidir con el total bancario si hay diferencias o pagos sin detalle.

### 6.3 Totales por sede

En `Totales por sede` se muestra:

- nombre de la sede;
- cantidad de líneas;
- total de la sede;
- botón `Descargar TXT sede`.

El consolidado principal excluye `GRANADA`. Granada tiene un archivo independiente cuando contiene líneas bancarias.

## 7. Revisar y resolver advertencias

La sección `Advertencias de importación` muestra código, severidad, mensaje, hoja y fila de origen.

### 7.1 Advertencias que requieren revisar Excel

- `invalid_invoice_amount`: revisar importe de factura en G.
- `invalid_receipt_amount`: revisar importe del `PEL` en G.
- `receipt_without_invoices`: revisar que haya facturas válidas antes del `PEL`.
- `receipt_amount_differs_from_invoice_total`: comparar el total del `PEL` contra sus facturas.
- `invalid_invoice_row`: completar columnas obligatorias o retirar filas de resumen mal formadas.
- `invoices_without_receipt`: añadir o corregir el `PEL` que cierra el bloque.

### 7.2 Advertencias bancarias

- `invalid_bank_identity`: corregir NIT/DNI o tipo de persona en I:J.
- `invalid_bank_account`: corregir número/tipo de cuenta en K:L.
- `invalid_bank_code`: corregir código en M.
- `invalid_bank_amount`: corregir importe en N.
- `invalid_bank_third_party_name`: limpiar caracteres no visibles en O.

### 7.3 Advertencias de conciliación

- `bank_payment_line_not_found`: comparar el importe del comprobante con N.
- `bank_payment_line_identity_mismatch`: revisar NIT/DNI y nombre del tercero.
- `ambiguous_bank_payment_line_match`: hay varias líneas con el mismo importe; completar identidad.
- `bank_payment_line_without_invoice_detail`: confirmar que el pago sin facturas sea intencional.
- `bank_payment_line_missing_third_party`: completar catálogo o datos de identidad.
- `bank_payment_line_missing_primary_account`: configurar una cuenta primaria activa.
- `ambiguous_third_party_name_match`: usar un documento o corregir nombres alternos.

### 7.4 Aprobar un lote con advertencias

Aprobar no elimina ni corrige las advertencias. Significa que el administrador decidió continuar con los datos importados.

1. Leer todas las páginas de advertencias.
2. Comparar cantidades y totales contra el archivo original.
3. Confirmar con el responsable de tesorería cualquier pago sin detalle o diferencia de importe.
4. Pulsar `Aprobar lote`.
5. Esperar el mensaje de resultado.
6. Confirmar que el estado final sea `Listo`.

Si la generación falla después de aprobar, conservar el lote y contactar soporte. No eliminarlo ni volver a cargar el mismo archivo: el hash lo marcará como duplicado.

## 8. Descargar archivos bancarios

### 8.1 Archivo por sede

En la sección `Totales por sede`:

1. Identificar la sede.
2. Pulsar `Descargar TXT sede`.
3. Guardar el archivo con el nombre recibido.

Si se muestra `El archivo de esta sede no existe`, el lote debe regenerarse o debe revisarlo soporte.

### 8.2 Archivo consolidado

El endpoint administrativo del consolidado es:

```text
/admin/imports/{id}/bank-file
```

La pantalla de detalle actual puede no mostrar un botón visible para este archivo. Si se tiene el ID del lote, se puede abrir la ruta directamente en una sesión administrativa. También se puede usar la consola:

```bash
docker compose run --rm app php artisan payments:bank-file ID
```

El nombre descargado es `payment-batch-{id}.txt`.

### 8.3 Archivo de Granada

El endpoint es:

```text
/admin/imports/{id}/granada-file
```

Solo existe si `GRANADA` tuvo líneas bancarias. El nombre descargado es `payment-batch-{id}-granada.txt`.

### 8.4 Verificación antes de entregar al banco

Abrir el TXT con un editor que no reemplace tabuladores por espacios y confirmar:

- no hay encabezado;
- cada fila tiene seis campos;
- los campos están separados por tabulador;
- el importe no tiene decimales ni separadores de miles;
- el NIT/DNI, cuenta y banco corresponden al lote;
- el consolidado no incluye Granada;
- los archivos por sede corresponden a sus totales;
- se conservaron los originales y el ID del lote.

No editar manualmente un TXT generado sin registrar el cambio y sin conservar el archivo original.

## 9. Consultar comprobantes PDF como administrador

En la sección `Comprobantes con detalle` del lote:

1. localizar el comprobante;
2. revisar sede, tercero, cantidad de facturas y valor;
3. pulsar `PDF`;
4. guardar el archivo descargado.

El administrador puede descargar cualquier comprobante del sistema.

El PDF muestra la cuenta enmascarada, con solo los últimos cuatro dígitos visibles. También muestra por separado `Total pagado` y `Total facturas`.

## 10. Portal de proveedores

### 10.1 Preparación del acceso

El administrador debe:

1. abrir `Catálogo`;
2. buscar el NIT/DNI;
3. pulsar `Editar`;
4. asignar una contraseña de al menos ocho caracteres;
5. guardar;
6. entregar al proveedor la URL, el NIT/DNI y la contraseña mediante un canal seguro.

El tercero debe estar activo. Si se desactiva o se cambia su contraseña, las sesiones anteriores dejan de ser válidas.

### 10.2 Iniciar sesión como proveedor

1. Abrir `/proveedor`.
2. Escribir el NIT/DNI registrado.
3. Escribir la contraseña asignada.
4. Pulsar `Ingresar`.

El sistema normaliza espacios del NIT/DNI. Si las credenciales no son correctas, muestra `El NIT/DNI o la contraseña no son correctos.`

### 10.3 Consultar comprobantes

La pantalla muestra:

- NIT/DNI y nombre conectado;
- cantidad de comprobantes disponibles;
- total pagado según los filtros actuales;
- lista paginada de comprobantes;
- fecha, sede, cantidad de facturas, valor y botón PDF.

Para filtrar:

1. elegir una `Fecha de pago`, si se necesita;
2. elegir una `Sede` o dejar `Todas las sedes`;
3. pulsar `Filtrar`.

Para quitar los filtros, pulsar `Limpiar`.

Las páginas mantienen los filtros activos. El proveedor solo ve comprobantes asociados a su propio NIT/DNI.

### 10.4 Descargar un PDF propio

1. localizar el comprobante;
2. confirmar fecha, sede y valor;
3. pulsar `PDF`.

Intentar abrir el PDF de otro proveedor devuelve `404` y no revela el documento.

### 10.5 Cerrar sesión

Pulsar `Salir` en la esquina superior. La sesión se cierra y se regresa al login del proveedor.

## 11. Solución de problemas

| Situación | Causa probable | Qué hacer |
|---|---|---|
| No aparece el login | Aplicación o Vite no están levantados. | Contactar a soporte técnico y comprobar `docker compose up app node postgres`. |
| Credenciales administrativas rechazadas | Correo/contraseña incorrectos o límite de intentos. | Verificar datos y esperar un minuto si hubo varios intentos. |
| `El archivo no contiene la hoja MODELO` | El archivo no tiene una hoja con nombre exacto `MODELO`. | Corregir nombre o elegir otro archivo. |
| `No hay importaciones registradas` | Aún no se ha cargado un lote o se está usando otra base. | Confirmar el entorno y el usuario. |
| El lote queda `Pendiente de revisión` | Se generó al menos una advertencia. | Revisar todas las advertencias antes de aprobar. |
| El archivo ya fue importado | El contenido tiene el mismo SHA-256 que un lote existente. | Abrir el lote original; no duplicar la carga. |
| No aparece un TXT consolidado | El lote requiere aprobación, no terminó o no tiene líneas. | Aprobar/revisar estado; si ya estaba aprobado, solicitar regeneración. |
| No hay TXT de Granada | No hubo líneas válidas en la sede `GRANADA`. | Confirmar si la sede debía tener pagos. |
| Una sede no tiene botón descargable | No hay líneas bancarias o el archivo no se publicó. | Revisar totales y el estado; contactar soporte si corresponde. |
| El proveedor no puede entrar | No tiene contraseña, está inactivo o la contraseña cambió. | Administrador debe revisar el catálogo y asignar una nueva contraseña. |
| El proveedor ve cero comprobantes | El lote no resolvió `third_party_id` o el NIT no coincide. | Revisar advertencias, documento y nombre del catálogo. |
| PDF sin datos de banco | No se resolvió cuenta en la importación ni existe cuenta primaria actual. | Completar catálogo y revisar el lote. |
| PDF muestra diferencia entre totales | El total pagado y el total de facturas son datos distintos. | Revisar conciliación y warnings; el PDF no corrige la diferencia. |
| Lote en `Generando archivos` por mucho tiempo | Proceso interrumpido o bloqueo. | No eliminar; soporte debe revisar proceso, logs y estado. |
| Error al cargar archivo grande | Se exceden los 50 MB HTTP o los límites internos del XLSX. | Reducir el archivo o dividir el proceso según el procedimiento de soporte. |

## 12. Reglas de seguridad para usuarios

- No compartir cuentas administrativas.
- No enviar contraseñas por correo abierto, chats grupales ni documentos públicos.
- No descargar archivos bancarios en equipos compartidos sin protección.
- Conservar el ID de lote junto con cada TXT entregado.
- No modificar manualmente importes en un TXT sin autorización y trazabilidad.
- No eliminar lotes para resolver una advertencia sin guardar respaldo.
- Confirmar destinatario, sede y fecha antes de entregar un PDF.
- Cerrar sesión en equipos compartidos.
- Reportar inmediatamente un archivo bancario o PDF descargado por la persona equivocada.

## 13. Checklist semanal del administrador

### Antes de importar

- [ ] El archivo es `.xlsx` y no supera el tamaño permitido.
- [ ] Las hojas tienen los nombres configurados.
- [ ] Las filas de datos empiezan después de la fila 6.
- [ ] `MODELO` está validado si se utilizará.
- [ ] El catálogo tiene cuentas primarias correctas.
- [ ] Los terceros que deben usar el portal tienen contraseña.

### Después de importar

- [ ] Se registró el ID del lote.
- [ ] Se revisó el estado.
- [ ] Se comparó el número de líneas, comprobantes y facturas.
- [ ] Se compararon los totales bancario y de facturas.
- [ ] Se leyeron todas las advertencias.
- [ ] Se revisaron los totales por sede.

### Antes de enviar al banco

- [ ] El lote está aprobado y/o `Listo`.
- [ ] Se descargó el consolidado correcto.
- [ ] Se descargó Granada por separado si aplica.
- [ ] Se descargaron los archivos por sede requeridos.
- [ ] Los TXT tienen seis columnas tabuladas y no tienen encabezado.
- [ ] Se conservaron los archivos y el ID del lote.
- [ ] Se verificaron los checksums si el procedimiento de soporte los proporciona.

### Después de publicar comprobantes

- [ ] Los terceros tienen acceso solo cuando corresponde.
- [ ] Se validó al menos un PDF como administrador.
- [ ] Se informó al proveedor la URL y sus credenciales por canal seguro.
- [ ] Se cerraron sesiones de prueba.
