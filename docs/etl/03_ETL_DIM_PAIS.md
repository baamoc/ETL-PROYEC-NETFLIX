# 03_ETL_DIM_PAIS

## Propósito
Extrae los nombres de país desde el staging, los normaliza a formato título palabra por palabra y carga el catálogo de países único en el Data Mart.

## Tabla destino
`dm_streaming.dim_pais` — catálogo de países con el campo `nombre_pais` normalizado; la clave surrogada es generada por la base de datos.

## Fuente de datos
`staging.stg_netflix_userbase` — extrae el campo `country`, excluyendo registros donde sea nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | Leer_STG_Paises | TableInput | Extrae `country` desde staging filtrando nulos. |
| 2 | Sel_Campos_Pais | SelectValues | Proyecta únicamente el campo `country`. |
| 3 | Limpiar_Textos_Pais | StringOperations | Aplica trim (ambos lados) al campo `country`. |
| 4 | Corregir_Textos_Pais | ReplaceString | Reemplaza cadenas vacías en `country` por el literal `Sin dato` mediante regex `^\s*$`. |
| 5 | JS_Normalizar_Pais | ScriptValueMod | Aplica formato título palabra por palabra a `country` y produce el campo `nombre_pais`. |
| 6 | Sel_Campos_Final | SelectValues | Conserva solo el campo `nombre_pais` producido por el JS. |
| 7 | Ordenar_Paises | SortRows | Ordena ascendentemente por `nombre_pais` para habilitar deduplicación. |
| 8 | Eliminar_Duplicados | Unique | Elimina nombres de país duplicados. |
| 9 | Validar_Pais | FilterRows | Descarta registros donde `nombre_pais` quedó nulo tras la normalización JS; los válidos pasan a la carga. |
| 10 | Cargar_DIM_Pais | TableOutput | Inserción masiva (bulk insert) en `dm_streaming.dim_pais` con commit cada 1000 filas. |

## Lógica destacada

### SQL de extracción

```sql
SELECT country
FROM staging.stg_netflix_userbase
WHERE country IS NOT NULL
```

### Transformación JS

El script `JS_Normalizar_Pais` produce un campo:

- `nombre_pais` (String): divide el valor de `country` en palabras por espacio y aplica formato título a cada una (primera letra mayúscula, resto minúscula), luego las une nuevamente. Esto maneja correctamente nombres compuestos como "United States" o "United Kingdom". Si el valor es nulo, vacío o ya es `Sin dato`, produce el literal `Sin dato`.

### Criterio de carga
Utiliza `TableOutput` con `use_batch=Y` y commit cada 1000 registros. La opción `truncate` está en `N`, por lo que la tabla debe ser vaciada previamente mediante `UTIL_TRUNCATE_DM` antes de la carga. No realiza upsert; inserta directamente todos los países únicos que superan la validación.

## Resultado
Carga un registro por cada nombre de país único encontrado en staging. El número de filas corresponde a la cantidad de países distintos presentes en `stg_netflix_userbase`.
