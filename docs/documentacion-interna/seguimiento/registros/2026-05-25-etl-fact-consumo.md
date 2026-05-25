# Avance 2026-05-25 - ETL Fact Consumo

Fecha: 2026-05-25

## Resultado

`08_ETL_FACT_CONSUMO.hpl` quedo validado. La carga final en `dm_streaming.fact_consumo` dejo `2500` registros, `7500` visualizaciones totales, `0` duplicados y `0` filas con nulos en las claves o en la medida principal.

## Objetivo de la jornada

- Construir, ejecutar y validar `08_ETL_FACT_CONSUMO.hpl`.
- Cargar hechos de consumo con una logica simulada/controlada y documentada.
- Confirmar que la carga deje `1` consumo simulado por usuario sin generar duplicados.

## Contexto importante

La validacion se hizo respetando la arquitectura oficial del proyecto:

- los datos parten desde `staging`
- Apache Hop realiza la transformacion y la carga
- DBeaver se uso solo para auditoria, conteos y consultas de validacion

No se insertaron datos manualmente en `dm_streaming`.

## Pipeline validado

- Archivo: `pipelines/08_ETL_FACT_CONSUMO.hpl`
- Origen principal: `staging.stg_netflix_userbase`
- Dimensiones enlazadas: `dm_streaming.dim_usuario`, `dm_streaming.dim_contenido`, `dm_streaming.dim_pais`, `dm_streaming.dim_tiempo`
- Destino: `dm_streaming.fact_consumo`
- Medida cargada: `cantidad_visualizaciones`

## Logica controlada aplicada

No existe una relacion natural directa entre `NetFlix.csv` y `Netflix Userbase.csv`, por lo que `fact_consumo` se resolvio con una logica simulada/controlada y documentada.

Reglas aplicadas en el pipeline:

- `1 usuario = 1 consumo simulado`
- `id_contenido` se asigna por rotacion controlada sobre `dim_contenido` segun el orden de `id_contenido`
- `cantidad_visualizaciones` se genera con la formula `((User ID - 1) % 5) + 1`

Campos cargados:

- `id_usuario`
- `id_contenido`
- `id_pais`
- `id_tiempo`
- `cantidad_visualizaciones`

## Generacion automatica de `id_consumo`

La carga no inserta manualmente `id_consumo`, porque PostgreSQL lo genera automaticamente mediante secuencia.

Validacion de estructura:

```sql
SELECT column_name, column_default, is_nullable
FROM information_schema.columns
WHERE table_schema = 'dm_streaming'
  AND table_name = 'fact_consumo'
  AND column_name = 'id_consumo';
```

Resultado validado:

- `column_name = id_consumo`
- `column_default = nextval('dm_streaming.fact_consumo_id_consumo_seq'::regclass)`
- `is_nullable = NO`

## Como quedo armado

El pipeline genera una base de usuarios desde `staging.stg_netflix_userbase`, asigna un contenido por rotacion controlada, resuelve pais y tiempo desde dimensiones y luego carga `fact_consumo` con `Insert / update` usando la combinacion de negocio del hecho.

### Flujo en Apache Hop

- `LEER_CONSUMO_SIMULADO_DESDE_STAGING_CON_DIMENSIONES`
- `SELECCIONAR_CAMPOS_FACT_CONSUMO`
- `VALIDAR_CLAVES_FACT_CONSUMO`
- `CARGAR_FACT_CONSUMO`

### Claves de carga usadas por `Insert / update`

- `id_usuario`
- `id_contenido`
- `id_pais`
- `id_tiempo`

El campo `cantidad_visualizaciones` queda configurado para actualizacion si la combinacion ya existe.

## Validaciones finales

### 1. Confirmacion de la base simulada de consumo

```sql
SELECT COUNT(*) AS total_staging_usuarios
FROM staging.stg_netflix_userbase;
```

Resultado obtenido:

- `total_staging_usuarios = 2500`

Esto coincide con la regla aplicada: `1 usuario = 1 consumo simulado`.

### 2. Conteo final y total de visualizaciones

```sql
SELECT
    COUNT(*) AS total_actual,
    MIN(id_usuario) AS primer_usuario,
    MAX(id_usuario) AS ultimo_usuario,
    SUM(cantidad_visualizaciones) AS total_visualizaciones
FROM dm_streaming.fact_consumo;
```

Resultado obtenido:

- `total_actual = 2500`
- `primer_usuario = 1`
- `ultimo_usuario = 2500`
- `total_visualizaciones = 7500`

### 3. Duplicados, nulos y control final de la medida

```sql
SELECT
    COUNT(*) AS total_fact_consumo,
    COUNT(DISTINCT (id_usuario, id_contenido, id_pais, id_tiempo)) AS combinaciones_unicas,
    COUNT(*) - COUNT(DISTINCT (id_usuario, id_contenido, id_pais, id_tiempo)) AS posibles_duplicados,
    SUM(cantidad_visualizaciones) AS total_visualizaciones,
    COUNT(*) FILTER (
        WHERE id_usuario IS NULL
           OR id_contenido IS NULL
           OR id_pais IS NULL
           OR id_tiempo IS NULL
           OR cantidad_visualizaciones IS NULL
    ) AS filas_con_nulos
FROM dm_streaming.fact_consumo;
```

Resultado validado:

- `total_fact_consumo = 2500`
- `combinaciones_unicas = 2500`
- `posibles_duplicados = 0`
- `total_visualizaciones = 7500`
- `filas_con_nulos = 0`

### 4. Distribucion de visualizaciones simuladas

```sql
SELECT cantidad_visualizaciones, COUNT(*) AS total
FROM dm_streaming.fact_consumo
GROUP BY cantidad_visualizaciones
ORDER BY cantidad_visualizaciones;
```

Resultado validado:

- `1 -> 500`
- `2 -> 500`
- `3 -> 500`
- `4 -> 500`
- `5 -> 500`

Esta distribucion confirma que la formula de simulacion quedo aplicada de forma controlada y reproducible.

## Conclusion de auditoria

`08_ETL_FACT_CONSUMO.hpl` queda validado porque cargo `2500` registros en `dm_streaming.fact_consumo`, genero consumos simulados de forma controlada, no presento claves nulas, no genero duplicados y mantuvo un total de `7500` visualizaciones segun la regla definida.
