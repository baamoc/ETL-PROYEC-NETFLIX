# Avance 2026-05-25 - ETL Fact Ingresos

Fecha: 2026-05-25

## Resultado

`07_ETL_FACT_INGRESOS.hpl` quedo validado. La carga final en `dm_streaming.fact_ingresos` dejo `2500` registros, un ingreso total de `31271.00`, `0` duplicados y `0` filas con nulos en las claves o en la medida principal.

## Objetivo de la jornada

- Construir, ejecutar y validar `07_ETL_FACT_INGRESOS.hpl`.
- Cargar hechos de ingresos con las claves de usuario, suscripcion, dispositivo, pais y tiempo.
- Confirmar que la carga conserve el total monetario del origen y no genere duplicados.

## Contexto importante

La validacion se hizo respetando la arquitectura oficial del proyecto:

- los datos parten desde `staging`
- Apache Hop realiza la transformacion y la carga
- DBeaver se uso solo para auditoria, conteos y consultas de validacion

No se insertaron datos manualmente en `dm_streaming`.

## Pipeline validado

- Archivo: `pipelines/07_ETL_FACT_INGRESOS.hpl`
- Origen principal: `staging.stg_netflix_userbase`
- Dimensiones enlazadas: `dm_streaming.dim_usuario`, `dm_streaming.dim_suscripcion`, `dm_streaming.dim_dispositivo`, `dm_streaming.dim_pais`, `dm_streaming.dim_tiempo`
- Destino: `dm_streaming.fact_ingresos`
- Medida cargada: `ingreso_mensual`

## Grano de la tabla de hechos

La tabla `fact_ingresos` representa un hecho economico asociado a un usuario, una suscripcion, un dispositivo, un pais y una fecha determinada.

Campos validados para la carga:

- `id_usuario`
- `id_suscripcion`
- `id_dispositivo`
- `id_pais`
- `id_tiempo`
- `ingreso_mensual`

La carga no inserta manualmente `id_ingreso`, porque PostgreSQL lo genera automaticamente mediante secuencia.

Validacion de estructura:

```sql
SELECT column_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'dm_streaming'
  AND table_name = 'fact_ingresos'
  AND column_name = 'id_ingreso';
```

Resultado validado:

- `column_name = id_ingreso`
- `is_nullable = NO`
- `column_default = nextval('dm_streaming.fact_ingresos_id_ingreso_seq'::regclass)`

## Como quedo armado

El pipeline lee `staging.stg_netflix_userbase`, resuelve claves de las dimensiones y luego carga `fact_ingresos` con `Insert / update` usando la combinacion de negocio del hecho.

### Flujo en Apache Hop

- `LEER_INGRESOS_DESDE_STAGING_CON_DIMENSIONES`
- `SELECCIONAR_CAMPOS_FACT_INGRESOS`
- `VALIDAR_CLAVES_FACT_INGRESOS`
- `CARGAR_FACT_INGRESOS`

### Claves de carga usadas por `Insert / update`

- `id_usuario`
- `id_suscripcion`
- `id_dispositivo`
- `id_pais`
- `id_tiempo`

El campo `ingreso_mensual` queda configurado para actualizacion si la combinacion ya existe.

## Validaciones finales

### 1. Correspondencia entre usuarios de origen y dimension

```sql
SELECT
    COUNT(*) AS total_staging,
    COUNT(d.id_usuario) AS usuarios_encontrados,
    COUNT(*) - COUNT(d.id_usuario) AS usuarios_sin_match,
    MIN(s."User ID"::integer) AS user_id_min_staging,
    MAX(s."User ID"::integer) AS user_id_max_staging,
    MIN(d.id_usuario) AS id_usuario_min_dim,
    MAX(d.id_usuario) AS id_usuario_max_dim
FROM staging.stg_netflix_userbase s
LEFT JOIN dm_streaming.dim_usuario d
    ON d.id_usuario = s."User ID"::integer;
```

Resultado obtenido:

- `total_staging = 2500`
- `usuarios_encontrados = 2500`
- `usuarios_sin_match = 0`
- `user_id_min_staging = 1`
- `user_id_max_staging = 2500`
- `id_usuario_min_dim = 1`
- `id_usuario_max_dim = 2500`

Esta validacion confirma que no existen usuarios del origen sin clave correspondiente en la dimension.

### 2. Conteo final y total monetario cargado

```sql
SELECT
    COUNT(*) AS total_actual,
    MIN(id_usuario) AS primer_usuario,
    MAX(id_usuario) AS ultimo_usuario,
    SUM(ingreso_mensual) AS ingreso_total_actual
FROM dm_streaming.fact_ingresos;
```

Resultado obtenido:

- `total_actual = 2500`
- `primer_usuario = 1`
- `ultimo_usuario = 2500`
- `ingreso_total_actual = 31271.00`

Esto confirma que el pipeline cargo los `2500` registros esperados y que el total monetario cargado coincide con el origen.

### 3. Duplicados, nulos y control final del ingreso total

```sql
SELECT
    COUNT(*) AS total_fact_ingresos,
    COUNT(DISTINCT (id_usuario, id_suscripcion, id_dispositivo, id_pais, id_tiempo)) AS combinaciones_unicas,
    COUNT(*) - COUNT(DISTINCT (id_usuario, id_suscripcion, id_dispositivo, id_pais, id_tiempo)) AS posibles_duplicados,
    SUM(ingreso_mensual) AS ingreso_total,
    COUNT(*) FILTER (
        WHERE id_usuario IS NULL
           OR id_suscripcion IS NULL
           OR id_dispositivo IS NULL
           OR id_pais IS NULL
           OR id_tiempo IS NULL
           OR ingreso_mensual IS NULL
    ) AS filas_con_nulos
FROM dm_streaming.fact_ingresos;
```

Resultado validado:

- `total_fact_ingresos = 2500`
- `combinaciones_unicas = 2500`
- `posibles_duplicados = 0`
- `ingreso_total = 31271.00`
- `filas_con_nulos = 0`

## Conclusión de auditoría

`07_ETL_FACT_INGRESOS.hpl` queda validado porque cargo los `2500` registros esperados en `dm_streaming.fact_ingresos`, mantuvo el total de ingresos en `31271.00`, no presento claves nulas y no genero duplicados segun la combinacion de usuario, suscripcion, dispositivo, pais y tiempo.
