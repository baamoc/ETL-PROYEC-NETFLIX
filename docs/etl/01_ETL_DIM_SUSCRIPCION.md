# 01_ETL_DIM_SUSCRIPCION

## Propósito
Extrae los tipos y duraciones de planes de suscripción desde el staging, los normaliza y los carga como dimensión en el Data Mart, garantizando que no existan combinaciones duplicadas.

## Tabla destino
`dm_streaming.dim_suscripcion` — catálogo de tipos de suscripción (Basic, Standard, Premium) con su duración de plan; la clave surrogada `id_suscripcion` es generada automáticamente por la base de datos (SERIAL).

## Fuente de datos
`staging.stg_netflix_userbase` — extrae los campos `subscription_type` y `plan_duration`, excluyendo registros donde alguno de los dos sea nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | Leer_STG_Suscripcion | TableInput | Extrae `subscription_type` y `plan_duration` desde staging filtrando nulos. |
| 2 | Sel_Campos_Suscripcion | SelectValues | Proyecta únicamente los dos campos necesarios para la dimensión. |
| 3 | Limpiar_Strings_Suscripcion | StringOperations | Aplica trim (ambos lados) a `subscription_type` y `plan_duration`. |
| 4 | JS_Normalizar_Suscripcion | ScriptValueMod | Normaliza `subscription_type` a formato título y limpia `plan_duration`. |
| 5 | Sel_Campos_Final | SelectValues | Conserva solo los campos producidos por el JS (`tipo_suscripcion`, `duracion_plan`). |
| 6 | Ordenar_Suscripcion | SortRows | Ordena ascendentemente por `tipo_suscripcion` y `duracion_plan` para habilitar deduplicación. |
| 7 | Eliminar_Duplicados | Unique | Elimina combinaciones repetidas de tipo y duración. |
| 8 | Validar_Tipo_Suscripcion | FilterRows | Descarta registros donde `tipo_suscripcion` resultó nulo tras la normalización JS; los válidos pasan a la carga. |
| 9 | Cargar_DIM_Suscripcion | InsertUpdate | Upsert sobre `dm_streaming.dim_suscripcion` usando `tipo_suscripcion` y `duracion_plan` como clave natural. |

## Lógica destacada

### SQL de extracción

```sql
SELECT subscription_type, plan_duration
FROM staging.stg_netflix_userbase
WHERE subscription_type IS NOT NULL
  AND plan_duration IS NOT NULL
```

### Transformación JS

El script `JS_Normalizar_Suscripcion` produce dos campos:

- `tipo_suscripcion` (String): aplica formato título al valor de `subscription_type` (primera letra en mayúscula, el resto en minúscula). Si el valor es nulo o vacío, el campo queda en `null`.
- `duracion_plan` (String): aplica trim al valor de `plan_duration`. Si es nulo o vacío, el campo queda en `null`.

### Criterio de carga
Utiliza `InsertUpdate` con commit cada 100 registros. La clave natural está compuesta por los campos `tipo_suscripcion` y `duracion_plan`. Si la combinación ya existe en la tabla destino, no se actualiza ningún campo (ambos campos tienen `update=N`); si no existe, se inserta una nueva fila y la base de datos asigna el `id_suscripcion`.

## Resultado
Carga un registro por cada combinación única de tipo y duración de plan encontrada en staging. El dataset de origen contiene tres tipos de suscripción (Basic, Standard, Premium), por lo que se esperan pocos registros en esta dimensión (aproximadamente 3 a 6 filas según las duraciones disponibles).
