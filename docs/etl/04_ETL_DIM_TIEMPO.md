# 04_ETL_DIM_TIEMPO

## Propósito
Consolida todas las fechas presentes en el dataset (fechas de registro, último pago y fecha de incorporación de títulos) y las carga en la dimensión de tiempo del Data Mart con sus partes calendario desglosadas.

## Tabla destino
`dm_streaming.dim_tiempo` — dimensión de tiempo con fecha completa y sus componentes día, mes y año.

## Fuente de datos
Tres columnas de dos tablas de staging unidas con `UNION ALL`:
- `staging.stg_netflix_userbase` → columnas `join_date` y `last_payment_date` (formato `DD-MM-YY`)
- `staging.stg_netflix_titles` → columna `date_added` (formato `DD-Mon-YY`, e.g. `14-Aug-20`)

Solo se incluyen filas donde el campo de fecha no es nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | `Leer_Todas_Fechas` | TableInput | Extrae las tres columnas de fecha como un único campo `fecha_raw` mediante `UNION ALL`. |
| 2 | `Sel_Fecha_Raw` | SelectValues | Conserva únicamente el campo `fecha_raw` del stream combinado. |
| 3 | `Limpiar_Fecha` | StringOperations | Aplica trim (both) al campo `fecha_raw` para eliminar espacios sobrantes. |
| 4 | `Corregir_Fecha` | ReplaceString | Reemplaza strings vacíos (`^\s*$`) en `fecha_raw` por `Sin dato` para identificarlos en el JS. |
| 5 | `JS_Parsear_Fecha` | ScriptValueMod | Detecta el formato de la fecha y produce `fecha_completa` (Date), `dia`, `mes` y `anio` (Integer). |
| 6 | `Sel_Campos_Final` | SelectValues | Conserva los cuatro campos generados por el JS y descarta `fecha_raw`. |
| 7 | `Ordenar_Fechas` | SortRows | Ordena ascendentemente por `fecha_completa` para habilitar la deduplicación. |
| 8 | `Eliminar_Duplicados` | Unique | Elimina fechas duplicadas usando `fecha_completa` como clave. |
| 9 | `Validar_Fecha` | FilterRows | Descarta registros donde `fecha_completa` es nula (falla de parseo); la flecha verde continúa hacia la carga. |
| 10 | `Cargar_DIM_Tiempo` | TableOutput | Inserta los registros válidos en `dm_streaming.dim_tiempo` mediante bulk insert con batch de 1000. |

## Lógica destacada

### SQL de extracción
```sql
SELECT join_date AS fecha_raw
FROM staging.stg_netflix_userbase
WHERE join_date IS NOT NULL
UNION ALL
SELECT last_payment_date AS fecha_raw
FROM staging.stg_netflix_userbase
WHERE last_payment_date IS NOT NULL
UNION ALL
SELECT date_added AS fecha_raw
FROM staging.stg_netflix_titles
WHERE date_added IS NOT NULL
```

### Transformación JS
El script detecta automáticamente el formato del string recibido:

- **Formato `DD-MM-YY`** (userbase): el segundo segmento al hacer `split('-')` es numérico → se usa directamente como mes.
- **Formato `DD-Mon-YY`** (titles): el segundo segmento no es numérico → se normaliza a título (`charAt(0).toUpperCase() + ...toLowerCase()`) y se resuelve contra un mapa `{ 'Jan': 1, ..., 'Dec': 12 }`.

El año de dos dígitos se expande siempre a `2000 + yy`. Si el parseo es exitoso, se construye un objeto `java.util.Calendar` y se asigna a `fecha_completa` (tipo Date). Los campos producidos son:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `fecha_completa` | Date | Fecha normalizada sin hora. |
| `dia` | Integer | Día del mes (1–31). |
| `mes` | Integer | Número de mes (1–12). |
| `anio` | Integer | Año de cuatro dígitos (ej. 2022). |

### Criterio de carga
Se utiliza **TableOutput** con `use_batch=Y` y `commit=1000`. No aplica truncate previo (configurado como `truncate=N`); la dimensión se repopula en cada ejecución del workflow maestro. Al tratarse de una tabla de dimensión estática para este dataset, el bulk insert es más eficiente que InsertUpdate en la instancia Neon.

## Resultado
Carga aproximadamente **1822 fechas únicas** correspondientes al universo de fechas presentes en el dataset de usuarios y catálogo de títulos.
