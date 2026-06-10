# 08_ETL_FACT_CONSUMO

## Propósito

Carga la tabla de hechos `fact_consumo` derivando registros de consumo a partir del cruce entre los usuarios y los títulos disponibles en su país, y resolviendo las claves foráneas de país y tiempo mediante StreamLookup.

## Tabla destino

`dm_streaming.fact_consumo` — tabla de hechos que almacena cada evento de consumo (visualización de un título por un usuario) con sus cuatro claves foráneas dimensionales y la cantidad de visualizaciones.

## Fuente de datos

A diferencia de `fact_ingresos`, esta tabla de hechos no existe como tal en el dataset original: se **deriva** mediante un INNER JOIN entre `stg_netflix_userbase` y `stg_netflix_titles` relacionando a cada usuario con los títulos disponibles en su país. SQL real del TableInput:

```sql
SELECT u.user_id, c.show_id, u.country, u.join_date
FROM staging.stg_netflix_userbase u
INNER JOIN staging.stg_netflix_titles c
    ON LOWER(TRIM(c.country)) LIKE '%' || LOWER(TRIM(u.country)) || '%'
WHERE u.user_id IS NOT NULL
  AND u.country IS NOT NULL
  AND c.show_id IS NOT NULL
  AND c.country IS NOT NULL
ORDER BY u.user_id, c.show_id
LIMIT 5000
```

Las dimensiones se leen en paralelo para los StreamLookups:

| Tabla dimensión | SQL de lectura |
|-----------------|---------------|
| `dm_streaming.dim_pais` | `SELECT id_pais, nombre_pais FROM dm_streaming.dim_pais` |
| `dm_streaming.dim_tiempo` | `SELECT id_tiempo, fecha_completa FROM dm_streaming.dim_tiempo` |

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | `Leer_STG_Consumo` | TableInput | Cruza `stg_netflix_userbase` con `stg_netflix_titles` por país; limitado a 5000 filas para el demo |
| 2 | `Sel_Campos_Consumo` | SelectValues | Selecciona los cuatro campos fuente del cruce: `user_id`, `show_id`, `country`, `join_date` |
| 3 | `Limpiar_Textos_Consumo` | StringOperations | Trim en ambos extremos para todos los campos string |
| 4 | `Corregir_Textos_Consumo` | ReplaceString | Reemplaza cadenas vacías (`^\s*$`) por `Sin dato` en `country` |
| 5 | `JS_Preparar_Consumo` | ScriptValueMod | Convierte tipos, normaliza formato y fija la métrica (detalle en sección Lógica JS) |
| 6 | `Sel_Campos_Preparados` | SelectValues | Conserva los cinco campos generados por el JS, descarta los campos fuente originales |
| 7 | `Filtrar_Registros_Validos` | FilterRows | Descarta filas donde `id_usuario`, `id_contenido` o `fecha_consumo` sean nulos |
| 8 | `SL_Buscar_id_pais` | StreamLookup | Resuelve `id_pais` desde `dim_pais` por `nombre_pais_norm` |
| 9 | `SL_Buscar_id_tiempo` | StreamLookup | Resuelve `id_tiempo` desde `dim_tiempo` por `fecha_consumo` |
| 10 | `Sel_Campos_Final` | SelectValues | Conserva las cuatro FKs más `cantidad_visualizaciones`; descarta campos intermedios |
| 11 | `Cargar_FACT_Consumo` | TableOutput | Inserta en `dm_streaming.fact_consumo` con commit=1000 y use_batch=Y |

## StreamLookups — resolución de claves foráneas

| Lookup | Dimensión fuente | Campo de búsqueda (stream) | Campo de matching (dim) | FK obtenida |
|--------|-----------------|---------------------------|------------------------|-------------|
| `SL_Buscar_id_pais` | `dim_pais` | `nombre_pais_norm` | `nombre_pais` | `id_pais` (Integer) |
| `SL_Buscar_id_tiempo` | `dim_tiempo` | `fecha_consumo` | `fecha_completa` | `id_tiempo` (Integer) |

Nota: `id_usuario` e `id_contenido` no requieren StreamLookup. `id_usuario` se obtiene directamente convirtiendo `user_id` a Integer en el JS. `id_contenido` corresponde a `show_id`, que es la clave natural de `dim_contenido` y se pasa directamente como String.

## Lógica JS

El transform `JS_Preparar_Consumo` (ScriptValueMod) produce los siguientes campos de salida:

| Campo de salida | Tipo Hop | Descripción de la transformación |
|----------------|----------|----------------------------------|
| `id_usuario` | Integer | Parseo de `user_id` (String) a entero; descarta si <= 0 o no numérico |
| `id_contenido` | String | Copia directa de `show_id` con trim; es la clave natural de `dim_contenido` |
| `nombre_pais_norm` | String | Proper case palabra por palabra de `country` (ej. `united states` → `United States`) |
| `fecha_consumo` | Date | Parseo de `join_date` formato `DD-MM-YY` a `java.util.Date`; años de dos dígitos se convierten sumando 2000 |
| `cantidad_visualizaciones` | Integer | Constante fija `1` por fila; cada registro del cruce cuenta como una visualización |

## Criterio de carga

`TableOutput` con `commit=1000`, `use_batch=Y` y `truncate=N`. El truncate previo es responsabilidad exclusiva del pipeline `UTIL_TRUNCATE_DM`. El LIMIT 5000 en el SQL de extracción es una restricción deliberada para el demo del proyecto.

## Resultado

5000 registros cargados en `dm_streaming.fact_consumo`. Cada fila representa la visualización de un título de Netflix por parte de un usuario, derivada del cruce geográfico entre el país del usuario y los países de disponibilidad del título. La métrica `cantidad_visualizaciones` es siempre 1 por fila.
