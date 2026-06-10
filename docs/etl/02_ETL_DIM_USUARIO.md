# 02_ETL_DIM_USUARIO

## Propósito
Extrae los atributos demográficos de los usuarios desde el staging, convierte los identificadores y edades de texto a entero, normaliza el género y carga la dimensión de usuarios en el Data Mart.

## Tabla destino
`dm_streaming.dim_usuario` — dimensión que contiene el identificador del usuario, su edad y su género; la clave `id_usuario` proviene directamente del sistema fuente (no es surrogada).

## Fuente de datos
`staging.stg_netflix_userbase` — extrae `user_id`, `age` y `gender`, excluyendo registros donde `user_id` sea nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | Leer_STG_Usuario | TableInput | Extrae `user_id`, `age` y `gender` desde staging filtrando nulos en `user_id`. |
| 2 | Sel_Campos_Usuario | SelectValues | Proyecta únicamente los tres campos necesarios para la dimensión. |
| 3 | Limpiar_Textos_Usuario | StringOperations | Aplica trim (ambos lados) a `user_id`, `age` y `gender`. |
| 4 | Corregir_Textos_Usuario | ReplaceString | Reemplaza cadenas vacías en `gender` por el literal `Sin dato` mediante regex `^\s*$`. |
| 5 | JS_Convertir_Usuario | ScriptValueMod | Convierte `user_id` y `age` de String a Integer con validación de rango; normaliza `gender` a formato título. |
| 6 | Sel_Campos_Final | SelectValues | Conserva solo los campos producidos por el JS (`id_usuario`, `edad`, `genero`). |
| 7 | Ordenar_Usuario | SortRows | Ordena ascendentemente por `id_usuario` para habilitar deduplicación. |
| 8 | Eliminar_Duplicados | Unique | Elimina registros duplicados por `id_usuario`. |
| 9 | Validar_id_Usuario | FilterRows | Descarta registros donde `id_usuario` quedó nulo por falla de conversión en JS; los válidos pasan a la carga. |
| 10 | Cargar_DIM_Usuario | TableOutput | Inserción masiva (bulk insert) en `dm_streaming.dim_usuario` con commit cada 1000 filas. |

## Lógica destacada

### SQL de extracción

```sql
SELECT user_id, age, gender
FROM staging.stg_netflix_userbase
WHERE user_id IS NOT NULL
```

### Transformación JS

El script `JS_Convertir_Usuario` produce tres campos:

- `id_usuario` (Integer): convierte `user_id` de String a entero mediante `parseInt`. Si el resultado no es un número válido o es menor o igual a cero, el campo queda en `null`.
- `edad` (Integer): convierte `age` de String a entero con validación de rango (1–149). Si la conversión falla o el valor queda fuera de rango, el campo queda en `null`.
- `genero` (String): normaliza `gender` a formato título (primera letra mayúscula, resto minúscula). Si el campo es vacío o ya contiene `Sin dato`, mantiene el literal `Sin dato`.

### Criterio de carga
Utiliza `TableOutput` con `use_batch=Y` y commit cada 1000 registros. La opción `truncate` está en `N`, por lo que la tabla debe ser vaciada previamente mediante `UTIL_TRUNCATE_DM` antes de la carga. No realiza upsert; inserta directamente todas las filas que superan la validación.

## Resultado
Carga un registro por cada usuario único identificado en staging. El número de filas corresponde a la cantidad de `user_id` distintos y válidos presentes en `stg_netflix_userbase`.
