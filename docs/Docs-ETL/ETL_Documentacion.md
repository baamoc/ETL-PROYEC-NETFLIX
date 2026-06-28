# Procesos ETL — Data Mart Netflix

Documentación del flujo de extracción, transformación y carga que alimenta el Data Mart
`dm_streaming` desde los datasets públicos de Netflix. Cubre la arquitectura completa,
las herramientas utilizadas y las transformaciones aplicadas en cada pipeline.

---

## 1. Herramientas y entorno

| Componente | Detalle |
|------------|---------|
| Herramienta ETL | Apache Hop |
| Motor de base de datos | PostgreSQL (Neon serverless) |
| Conexión configurada | `Proyecto-Neonbd` |
| Esquema de staging | `staging` |
| Esquema de destino | `dm_streaming` |
| Datasets fuente | `Netflix Userbase.csv` / `NetFlix.csv` |

---

## 2. Flujo de datos

```
[ Datasets CSV ]
       │
       ▼
[ staging.stg_netflix_userbase ]   [ staging.stg_netflix_titles ]
  2 500 registros                    ~8 000 registros
       │                                     │
       └──────────────┬──────────────────────┘
                      ▼
          [ Pipelines ETL — Apache Hop ]
                      │
       ┌──────────────┼──────────────┐
       ▼              ▼              ▼
  Dimensiones     dim_tiempo     dim_contenido
  (01, 03,        (04)           (06)
   05, 01)
       │
       └────────────────┐
                        ▼
                 [ Hechos ]
            fact_ingresos (07)
            fact_consumo  (08)
```

El flujo tiene tres capas:

1. **Staging** — carga directa desde CSV sin transformaciones.
2. **Dimensiones** — limpieza, normalización y deduplicación; se cargan antes que los hechos.
3. **Hechos** — resolución de claves foráneas via StreamLookup contra las dimensiones ya cargadas.

---

## 3. Fuentes de datos

### Netflix Userbase.csv → `staging.stg_netflix_userbase`

| Campo fuente | Descripción |
|---|---|
| `user_id` | Identificador de usuario (String numérico) |
| `subscription_type` | Tipo de plan: Basic / Standard / Premium |
| `monthly_revenue` | Ingreso mensual en USD (String decimal) |
| `join_date` | Fecha de alta del usuario (formato DD-MM-YY) |
| `last_payment_date` | Fecha del último pago (formato DD-MM-YY) |
| `country` | País del usuario |
| `age` | Edad (String numérico) |
| `gender` | Género declarado |
| `device` | Dispositivo de acceso |
| `plan_duration` | Duración del plan |

### NetFlix.csv → `staging.stg_netflix_titles`

| Campo fuente | Descripción |
|---|---|
| `show_id` | Identificador único del título (ej. `s1`) |
| `type` | Tipo: Movie / TV Show |
| `title` | Nombre del título |
| `director` | Director(es) |
| `cast` | Elenco |
| `country` | País(es) de producción |
| `date_added` | Fecha de agregado al catálogo (DD-Mon-YY) |
| `release_year` | Año de estreno (String numérico) |
| `rating` | Clasificación de contenido |
| `duration` | Duración (minutos o temporadas) |
| `listed_in` | Géneros |
| `description` | Sinopsis |

---

## 4. Patrón de transformación estándar

Todos los pipelines siguen una secuencia de pasos definida que hace visible cada etapa de la
transformación dentro del canvas de Apache Hop. No se aplican transformaciones ocultas en SQL.

### Patrón para dimensiones (9 pasos)

| Paso | Tipo de transform | Función |
|------|-------------------|---------|
| 1 | `TableInput` | Extracción desde staging. SQL simple: `SELECT` sin cálculos. |
| 2 | `SelectValues` | Proyección — conserva solo los campos necesarios. |
| 3 | `StringOperations` | Limpieza — trim visible en todos los campos String. |
| 4 | `ReplaceString` | Corrección — cadenas vacías (`^\s*$`) → `Sin dato`. |
| 5 | `ScriptValueMod` | Transformación JS — conversiones de tipo, proper case, parseo de fechas. |
| 6 | `SelectValues` | Proyección final — conserva campos del JS con nombres del modelo DM. |
| 7 | `SortRows` | Ordenamiento por clave natural (requisito para deduplicación). |
| 8 | `Unique` | Deduplicación — elimina filas repetidas sobre la clave natural. |
| 9 | `FilterRows` | Validación — descarta registros con clave nula; los válidos pasan a carga. |
| 10 | **Carga** | `InsertUpdate` (dims pequeñas) o `StreamLookup + FilterRows + TableOutput` (dims grandes). |

### Estrategia de carga — dimensiones pequeñas vs. grandes

| Criterio | Dimensiones pequeñas | Dimensiones grandes |
|----------|---------------------|---------------------|
| Pipelines | 01, 03, 05 (≤ 10 filas) | 02, 04, 06 (> 100 filas) |
| Transform | `InsertUpdate` | `StreamLookup + FilterRows + TableOutput` |
| Mecanismo | Upsert fila por fila | 1 SELECT → hash en RAM → INSERT masivo |
| Deduplicación | La clave natural en InsertUpdate | `Leer_DIM_Existente` → `SL_Verificar_Existente` → filtra IS NULL |
| Commit | 100 (pocos registros, irrelevante) | 1000 (batch) |

El patrón StreamLookup se eligió para dimensiones grandes porque `InsertUpdate` genera una
consulta SELECT + INSERT/UPDATE por fila. En una conexión serverless con ~50 ms de latencia
por round trip, eso produce tiempos de carga de varios minutos. StreamLookup carga todas
las claves existentes en memoria en un único SELECT y realiza los lookups sin acceder a la red,
reduciendo el tiempo de carga a segundos.

### Patrón para hechos

Los pipelines de hechos extienden el patrón de dimensiones agregando una cadena de
StreamLookups para resolver claves foráneas antes de la carga:

```
Staging → Limpieza → JS → Filtrar válidos
    → SL_Buscar_FK1 ← dim_X
    → SL_Buscar_FK2 ← dim_Y
    → SL_Buscar_FK3 ← dim_Z
    → SL_Verificar_Existente ← fact_tabla (anti-duplicado)
    → Filtrar_Nuevos (IS NULL)
    → TableOutput (INSERT masivo)
```

---

## 5. Pipelines ETL — Dimensiones

### 01 — DIM Suscripcion

**Destino:** `dm_streaming.dim_suscripcion` | **Registros:** 3 | **Carga:** InsertUpdate

**Fuente:**
```sql
SELECT subscription_type, plan_duration
FROM staging.stg_netflix_userbase
WHERE subscription_type IS NOT NULL AND plan_duration IS NOT NULL
```

| Transform | Tipo | Descripción |
|-----------|------|-------------|
| `Leer_STG_Suscripcion` | TableInput | Extrae tipo y duración de plan. |
| `Limpiar_Strings_Suscripcion` | StringOperations | Trim en ambos campos. |
| `JS_Normalizar_Suscripcion` | ScriptValueMod | Proper case en `subscription_type` → `tipo_suscripcion`. |
| `Eliminar_Duplicados` | Unique | Deduplica por `tipo_suscripcion` + `duracion_plan`. |
| `Validar_Tipo_Suscripcion` | FilterRows | Descarta nulos. |
| `Cargar_DIM_Suscripcion` | InsertUpdate | Upsert por clave natural `(tipo_suscripcion, duracion_plan)`. |

---

### 02 — DIM Usuario

**Destino:** `dm_streaming.dim_usuario` | **Registros:** 2 500 | **Carga:** StreamLookup + TableOutput

**Fuente:**
```sql
SELECT user_id, age, gender
FROM staging.stg_netflix_userbase
WHERE user_id IS NOT NULL
```

| Transform | Tipo | Descripción |
|-----------|------|-------------|
| `Leer_STG_Usuario` | TableInput | Extrae `user_id`, `age`, `gender`. |
| `Limpiar_Textos_Usuario` | StringOperations | Trim en los tres campos. |
| `Corregir_Textos_Usuario` | ReplaceString | Cadenas vacías en `gender` → `Sin dato`. |
| `JS_Convertir_Usuario` | ScriptValueMod | `user_id` → Integer (`id_usuario`); `age` → Integer (`edad`); proper case en `gender` → `genero`. |
| `Ordenar_Usuario` / `Eliminar_Duplicados` | SortRows / Unique | Deduplicación por `id_usuario`. |
| `Validar_id_Usuario` | FilterRows | Descarta registros con `id_usuario` nulo. |
| `Leer_DIM_Existente` | TableInput | `SELECT id_usuario FROM dm_streaming.dim_usuario`. |
| `SL_Verificar_Existente` | StreamLookup | Busca `id_usuario` en el hash en RAM; retorna `id_existe`. |
| `Filtrar_Nuevos` | FilterRows | Solo pasan filas donde `id_existe IS NULL`. |
| `Cargar_DIM_Usuario` | TableOutput | INSERT masivo: `id_usuario`, `edad`, `genero`. commit=1000. |

---

### 03 — DIM Pais

**Destino:** `dm_streaming.dim_pais` | **Registros:** ~10 | **Carga:** InsertUpdate

**Fuente:** Países únicos de `stg_netflix_userbase` con `country IS NOT NULL`.

| Transform | Descripción |
|-----------|-------------|
| `Leer_STG_Pais` | Extrae `country`. |
| `JS_Normalizar_Pais` | Proper case palabra por palabra → `nombre_pais`. |
| `Eliminar_Duplicados` | Deduplica por `nombre_pais`. |
| `Cargar_DIM_Pais` | InsertUpdate por `nombre_pais` (UNIQUE en la tabla). |

---

### 04 — DIM Tiempo

**Destino:** `dm_streaming.dim_tiempo` | **Registros:** 1 822 | **Carga:** StreamLookup + TableOutput

El pipeline consolida fechas de tres orígenes distintos en un único stream y las parsea a un
tipo `Date` con atributos de calendario.

**Fuente — tres fuentes unidas con UNION ALL:**
```sql
SELECT join_date AS fecha_raw FROM staging.stg_netflix_userbase WHERE join_date IS NOT NULL
UNION ALL
SELECT last_payment_date FROM staging.stg_netflix_userbase WHERE last_payment_date IS NOT NULL
UNION ALL
SELECT date_added FROM staging.stg_netflix_titles WHERE date_added IS NOT NULL
```

| Transform | Tipo | Descripción |
|-----------|------|-------------|
| `Leer_Todas_Fechas` | TableInput | UNION ALL de las tres columnas de fecha. |
| `Limpiar_Fecha` | StringOperations | Trim del string `fecha_raw`. |
| `Corregir_Fecha` | ReplaceString | Cadenas vacías → `Sin dato`. |
| `JS_Parsear_Fecha` | ScriptValueMod | Detecta formato `DD-MM-YY` o `DD-Mon-YY`; produce `fecha_completa` (Date), `dia`, `mes`, `anio` (Integer). Años de 2 dígitos → 20xx. |
| `Ordenar_Fechas` / `Eliminar_Duplicados` | SortRows / Unique | Deduplicación por `fecha_completa`. |
| `Validar_Fecha` | FilterRows | Descarta registros donde `fecha_completa` quedó nula. |
| `Leer_DIM_Existente` | TableInput | `SELECT fecha_completa FROM dm_streaming.dim_tiempo`. |
| `SL_Verificar_Existente` | StreamLookup | Lookup por `fecha_completa`; retorna `fecha_existe`. |
| `Filtrar_Nuevos` | FilterRows | Solo pasan fechas donde `fecha_existe IS NULL`. |
| `Cargar_DIM_Tiempo` | TableOutput | INSERT: `fecha_completa`, `dia`, `mes`, `anio`. `id_tiempo` es SERIAL, no se incluye. commit=1000. |

---

### 05 — DIM Dispositivo

**Destino:** `dm_streaming.dim_dispositivo` | **Registros:** 4 | **Carga:** InsertUpdate

**Fuente:** Campo `device` de `stg_netflix_userbase`.

| Transform | Descripción |
|-----------|-------------|
| `JS_Normalizar_Dispositivo` | Proper case palabra por palabra → `nombre_dispositivo`. |
| `Eliminar_Duplicados` | Deduplica por `nombre_dispositivo`. |
| `Cargar_DIM_Dispositivo` | InsertUpdate por `nombre_dispositivo` (UNIQUE en la tabla). |

---

### 06 — DIM Contenido

**Destino:** `dm_streaming.dim_contenido` | **Registros:** ~7 787 | **Carga:** StreamLookup + TableOutput

**Fuente:**
```sql
SELECT show_id, title, type, director, elenco, rating, duration, genres, description, release_year
FROM staging.stg_netflix_titles
WHERE show_id IS NOT NULL
```

| Transform | Tipo | Descripción |
|-----------|------|-------------|
| `Leer_STG_Contenido` | TableInput | Extrae los 10 campos del catálogo. |
| `Limpiar_Textos_Contenido` | StringOperations | Trim en los 10 campos. |
| `Corregir_Textos_Contenido` | ReplaceString | Cadenas vacías → `Sin dato` en `director`, `elenco`, `rating`, `duration`, `genres`, `description`, `release_year`. |
| `JS_Normalizar_Contenido` | ScriptValueMod | Normaliza `type` → `tipo_contenido` (`Movie` / `TV Show`); convierte `release_year` a Integer → `anio_lanzamiento`. |
| `Sel_Campos_Final` | SelectValues | Renombra `show_id` → `id_contenido`, `title` → `titulo`, etc. |
| `Ordenar_Contenido` / `Eliminar_Duplicados` | SortRows / Unique | Deduplicación por `id_contenido`. |
| `Validar_Contenido` | FilterRows | Descarta registros con `id_contenido` nulo. |
| `Leer_DIM_Existente` | TableInput | `SELECT id_contenido FROM dm_streaming.dim_contenido`. |
| `SL_Verificar_Existente` | StreamLookup | Lookup por `id_contenido`; retorna `id_existe`. |
| `Filtrar_Nuevos` | FilterRows | Solo pasan contenidos donde `id_existe IS NULL`. |
| `Cargar_DIM_Contenido` | TableOutput | INSERT de los 10 campos. `id_contenido` es PK natural (VARCHAR). commit=1000. |

---

## 6. Pipelines ETL — Hechos

Los pipelines de hechos se ejecutan después de que todas las dimensiones están cargadas.
Resuelven las claves foráneas mediante StreamLookup en memoria y utilizan `TableOutput` para
la inserción masiva.

### 07 — FACT Ingresos

**Destino:** `dm_streaming.fact_ingresos` | **Registros:** 2 500 | **Carga:** StreamLookup + TableOutput

**Fuente:**
```sql
SELECT user_id, subscription_type, device, country, last_payment_date, monthly_revenue
FROM staging.stg_netflix_userbase
WHERE user_id IS NOT NULL
```

**Transformación JS (`JS_Preparar_Ingresos`):**

| Campo de salida | Tipo | Origen / lógica |
|----------------|------|-----------------|
| `id_usuario` | Integer | `user_id` (String) → parseInt; descarta si no numérico o ≤ 0. |
| `tipo_suscripcion_norm` | String | Proper case de `subscription_type`. |
| `nombre_dispositivo_norm` | String | Proper case palabra por palabra de `device`. |
| `nombre_pais_norm` | String | Proper case palabra por palabra de `country`. |
| `fecha_pago` | Date | `last_payment_date` (DD-MM-YY) → java.util.Date; años 2 dígitos → 20xx. |
| `ingreso_mensual` | Number(10,2) | `monthly_revenue` (String) → parseFloat; descarta negativos. |

**Resolución de FKs mediante StreamLookup:**

| Transform | Dimensión fuente | Campo stream | Campo DM | FK resultante |
|-----------|-----------------|--------------|----------|---------------|
| `SL_Buscar_id_suscripcion` | `dim_suscripcion` | `tipo_suscripcion_norm` | `tipo_suscripcion` | `id_suscripcion` |
| `SL_Buscar_id_dispositivo` | `dim_dispositivo` | `nombre_dispositivo_norm` | `nombre_dispositivo` | `id_dispositivo` |
| `SL_Buscar_id_pais` | `dim_pais` | `nombre_pais_norm` | `nombre_pais` | `id_pais` |
| `SL_Buscar_id_tiempo` | `dim_tiempo` | `fecha_pago` | `fecha_completa` | `id_tiempo` |

**Anti-duplicado:** `Leer_FACT_Existente` lee `id_usuario` de `fact_ingresos`; `SL_Verificar_Existente` filtra los ya cargados.

**Carga:** `Cargar_FACT_Ingresos` (TableOutput) inserta `id_usuario`, `id_suscripcion`, `id_dispositivo`, `id_pais`, `id_tiempo`, `ingreso_mensual`. El campo `id_ingreso` es SERIAL y no se incluye. commit=1000.

---

### 08 — FACT Consumo

**Destino:** `dm_streaming.fact_consumo` | **Registros:** 5 000 | **Carga:** StreamLookup + TableOutput

Este pipeline deriva eventos de consumo cruzando usuarios con títulos por país.
No existe una relación directa usuario-título en los datasets originales; los consumos
se infieren mediante un JOIN entre el país del usuario y los países de producción de cada título.

**Fuente — cruce usuario × título:**
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

**Transformación JS (`JS_Preparar_Consumo`):**

| Campo de salida | Tipo | Lógica |
|----------------|------|--------|
| `id_usuario` | Integer | `user_id` → parseInt. |
| `id_contenido` | String | `show_id` trimmed (ya es la clave natural). |
| `nombre_pais_norm` | String | Proper case de `country`. |
| `fecha_consumo` | Date | `join_date` (DD-MM-YY) → java.util.Date. |
| `cantidad_visualizaciones` | Integer | Fijo en `1` por evento derivado. |

**Resolución de FKs:**

| Transform | Dimensión fuente | Campo stream | Campo DM | FK resultante |
|-----------|-----------------|--------------|----------|---------------|
| `SL_Buscar_id_pais` | `dim_pais` | `nombre_pais_norm` | `nombre_pais` | `id_pais` |
| `SL_Buscar_id_tiempo` | `dim_tiempo` | `fecha_consumo` | `fecha_completa` | `id_tiempo` |

**Anti-duplicado:** clave compuesta `(id_usuario, id_contenido)` — `Leer_FACT_Existente` lee ambas columnas; el StreamLookup busca por las dos claves simultáneamente.

**Carga:** `Cargar_FACT_Consumo` inserta `id_usuario`, `id_contenido`, `id_pais`, `id_tiempo`, `cantidad_visualizaciones`. El campo `id_consumo` es SERIAL. commit=1000.

---

## 7. Workflow maestro — WF_MASTER_ETL

El workflow `WF_MASTER_ETL` orquesta la ejecución de los 9 pipelines en secuencia estricta
mediante hops `on-success`. Si cualquier pipeline falla, el workflow se detiene antes de
continuar, lo que protege la integridad referencial: los hechos nunca se intentan cargar si
alguna dimensión falló.

### Orden de ejecución

```
START
  │
  ▼
UTIL_TRUNCATE_DM          ← Trunca todas las tablas DM con CASCADE
  │
  ▼
01_ETL_DIM_SUSCRIPCION
  │
  ▼
02_ETL_DIM_USUARIO
  │
  ▼
03_ETL_DIM_PAIS
  │
  ▼
04_ETL_DIM_TIEMPO
  │
  ▼
05_ETL_DIM_DISPOSITIVO
  │
  ▼
06_ETL_DIM_CONTENIDO
  │
  ▼
07_ETL_FACT_INGRESOS
  │
  ▼
08_ETL_FACT_CONSUMO
  │
  ▼
END
```

### Consideraciones de diseño

- **Truncate previo:** `UTIL_TRUNCATE_DM` vacía todas las tablas con `TRUNCATE … CASCADE` antes de cada carga completa. Esto simplifica la lógica de cada pipeline: los StreamLookup de anti-duplicado siempre arrancan contra tablas vacías en una carga limpia.
- **Dependencia dimensional:** los pipelines 07 y 08 leen las dimensiones ya cargadas mediante StreamLookup. Por eso las dimensiones se ejecutan primero.
- **Manejo de errores:** Apache Hop detendrá el workflow en el primer hop `on-failure` activado. No hay reintentos automáticos; una recarga completa desde `UTIL_TRUNCATE_DM` es suficiente para recuperarse.

---

## 8. Resultados de carga

| Pipeline | Tabla destino | Registros cargados | Tiempo aprox. |
|----------|---------------|--------------------|---------------|
| 01 | `dim_suscripcion` | 3 | < 1 seg |
| 02 | `dim_usuario` | 2 500 | ~3 seg |
| 03 | `dim_pais` | 10 | < 1 seg |
| 04 | `dim_tiempo` | 1 822 | ~4 seg |
| 05 | `dim_dispositivo` | 4 | < 1 seg |
| 06 | `dim_contenido` | 7 787 | ~8 seg |
| 07 | `fact_ingresos` | 2 500 | ~5 seg |
| 08 | `fact_consumo` | 5 000 | ~6 seg |
| **Total** | | **~19 626 registros** | **~85 seg** |

---

## 9. Transformaciones aplicadas — resumen

| Tipo de transformación | Pipelines | Herramienta Hop | Detalle |
|------------------------|-----------|-----------------|---------|
| Trim de espacios | Todos | `StringOperations` | Aplicado a todos los campos String antes de cualquier otra transformación. |
| Valores vacíos → `Sin dato` | Todos | `ReplaceString` | Regex `^\s*$` → `"Sin dato"` en campos opcionales. |
| Proper case | 01, 02, 03, 05, 07, 08 | `ScriptValueMod` (JS) | Primera letra mayúscula, resto minúscula. Palabra por palabra en campos multipalabra. |
| Conversión String → Integer | 02, 04, 06, 07, 08 | `ScriptValueMod` (JS) | `parseInt()` con validación de rango; nulos si falla el parseo. |
| Parseo de fechas DD-MM-YY | 04, 07, 08 | `ScriptValueMod` (JS) | `java.util.Calendar`; años 2 dígitos → 20xx. |
| Parseo de fechas DD-Mon-YY | 04 | `ScriptValueMod` (JS) | Mapeo de abreviatura inglesa (`Jan`–`Dec`) a número de mes. |
| Conversión String → Number | 07 | `ScriptValueMod` (JS) | `parseFloat()` para `monthly_revenue`; valida ≥ 0. |
| Deduplicación | Todos | `SortRows` + `Unique` | Requiere stream ordenado por la clave natural. |
| Resolución de FKs | 07, 08 | `StreamLookup` | Hash en RAM construido desde la dimensión ya cargada; O(1) por fila. |
| Derivación de consumos | 08 | SQL (JOIN en staging) | JOIN por similitud de país entre usuarios y títulos. `cantidad_visualizaciones = 1` por evento. |
