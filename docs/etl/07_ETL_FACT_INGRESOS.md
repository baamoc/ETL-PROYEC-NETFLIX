# 07_ETL_FACT_INGRESOS

## Propósito

Carga la tabla de hechos `fact_ingresos` uniendo los datos de userbase con cuatro dimensiones mediante StreamLookup para registrar el ingreso mensual de cada usuario junto con sus claves foráneas de suscripción, dispositivo, país y tiempo.

## Tabla destino

`dm_streaming.fact_ingresos` — tabla de hechos que almacena el ingreso mensual por usuario con sus cinco claves foráneas dimensionales.

## Fuente de datos

Extrae datos de `staging.stg_netflix_userbase`. SQL real del TableInput:

```sql
SELECT user_id, subscription_type, device, country, last_payment_date, monthly_revenue
FROM staging.stg_netflix_userbase
WHERE user_id IS NOT NULL
```

Las dimensiones se leen en paralelo para los StreamLookups:

| Tabla dimensión | SQL de lectura |
|-----------------|---------------|
| `dm_streaming.dim_suscripcion` | `SELECT id_suscripcion, tipo_suscripcion FROM dm_streaming.dim_suscripcion` |
| `dm_streaming.dim_dispositivo` | `SELECT id_dispositivo, nombre_dispositivo FROM dm_streaming.dim_dispositivo` |
| `dm_streaming.dim_pais` | `SELECT id_pais, nombre_pais FROM dm_streaming.dim_pais` |
| `dm_streaming.dim_tiempo` | `SELECT id_tiempo, fecha_completa FROM dm_streaming.dim_tiempo` |

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | `Leer_STG_Ingresos` | TableInput | Extrae seis campos de `stg_netflix_userbase`; sin transformaciones en SQL |
| 2 | `Sel_Campos_Ingresos` | SelectValues | Selecciona los seis campos fuente para fact_ingresos |
| 3 | `Limpiar_Textos_Ingresos` | StringOperations | Trim en ambos extremos para todos los campos string |
| 4 | `Corregir_Textos_Ingresos` | ReplaceString | Reemplaza cadenas vacías (`^\s*$`) por `Sin dato` en `subscription_type`, `device` y `country` |
| 5 | `JS_Preparar_Ingresos` | ScriptValueMod | Convierte tipos y normaliza formato (detalle en sección Lógica JS) |
| 6 | `Sel_Campos_Preparados` | SelectValues | Conserva solo los seis campos generados por el JS, descarta los campos fuente originales |
| 7 | `Filtrar_Registros_Validos` | FilterRows | Descarta filas donde `id_usuario`, `fecha_pago` o `ingreso_mensual` sean nulos |
| 8 | `SL_Buscar_id_suscripcion` | StreamLookup | Resuelve `id_suscripcion` desde `dim_suscripcion` por `tipo_suscripcion_norm` |
| 9 | `SL_Buscar_id_dispositivo` | StreamLookup | Resuelve `id_dispositivo` desde `dim_dispositivo` por `nombre_dispositivo_norm` |
| 10 | `SL_Buscar_id_pais` | StreamLookup | Resuelve `id_pais` desde `dim_pais` por `nombre_pais_norm` |
| 11 | `SL_Buscar_id_tiempo` | StreamLookup | Resuelve `id_tiempo` desde `dim_tiempo` por `fecha_pago` |
| 12 | `Sel_Campos_Final` | SelectValues | Conserva solo las cinco FKs más `ingreso_mensual`; descarta campos intermedios |
| 13 | `Cargar_FACT_Ingresos` | TableOutput | Inserta en `dm_streaming.fact_ingresos` con commit=1000 y use_batch=Y |

## StreamLookups — resolución de claves foráneas

| Lookup | Dimensión fuente | Campo de búsqueda (stream) | Campo de matching (dim) | FK obtenida |
|--------|-----------------|---------------------------|------------------------|-------------|
| `SL_Buscar_id_suscripcion` | `dim_suscripcion` | `tipo_suscripcion_norm` | `tipo_suscripcion` | `id_suscripcion` (Integer) |
| `SL_Buscar_id_dispositivo` | `dim_dispositivo` | `nombre_dispositivo_norm` | `nombre_dispositivo` | `id_dispositivo` (Integer) |
| `SL_Buscar_id_pais` | `dim_pais` | `nombre_pais_norm` | `nombre_pais` | `id_pais` (Integer) |
| `SL_Buscar_id_tiempo` | `dim_tiempo` | `fecha_pago` | `fecha_completa` | `id_tiempo` (Integer) |

## Lógica JS

El transform `JS_Preparar_Ingresos` (ScriptValueMod) produce los siguientes campos de salida:

| Campo de salida | Tipo Hop | Descripción de la transformación |
|----------------|----------|----------------------------------|
| `id_usuario` | Integer | Parseo de `user_id` (String) a entero; descarta si <= 0 o no numérico |
| `tipo_suscripcion_norm` | String | Proper case de `subscription_type` (ej. `basic` → `Basic`) |
| `nombre_dispositivo_norm` | String | Proper case palabra por palabra de `device` (ej. `smart tv` → `Smart Tv`) |
| `nombre_pais_norm` | String | Proper case palabra por palabra de `country` (ej. `united states` → `United States`) |
| `fecha_pago` | Date | Parseo de `last_payment_date` formato `DD-MM-YY` a `java.util.Date`; años de dos dígitos se convierten sumando 2000 |
| `ingreso_mensual` | Number (10,2) | Parseo de `monthly_revenue` (String) a decimal; descarta si es negativo o no numérico |

## Criterio de carga

`TableOutput` con `commit=1000`, `use_batch=Y` y `truncate=N`. El truncate previo es responsabilidad exclusiva del pipeline `UTIL_TRUNCATE_DM`, que se ejecuta antes en el workflow maestro. Esto garantiza que la tabla esté vacía sin duplicar la lógica de limpieza en cada pipeline de hechos.

## Resultado

2500 registros cargados en `dm_streaming.fact_ingresos`. Cada fila representa el ingreso mensual de un usuario de Netflix, con sus claves foráneas hacia las dimensiones de suscripción, dispositivo, país y tiempo.
