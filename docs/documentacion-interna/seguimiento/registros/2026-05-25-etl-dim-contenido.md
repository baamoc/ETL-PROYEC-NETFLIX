# Avance 2026-05-25 - ETL Dim Contenido

Fecha: 2026-05-25

## Objetivo de la jornada

- Construir, ejecutar y validar `06_ETL_DIM_CONTENIDO.hpl`.
- Cargar contenidos en `dm_streaming.dim_contenido` sin duplicados.
- Confirmar que no existan faltantes ni valores nulos/vacios en los campos clave.

## Estado actual

- Estado: validado
- Validacion en base: completada
- Archivo: `pipelines/06_ETL_DIM_CONTENIDO.hpl`
- Origen: `staging.stg_netflix_titles`
- Destino: `dm_streaming.dim_contenido`

## Como quedo armado

El pipeline toma los campos principales del catalogo de titulos y los adapta al modelo dimensional de contenido.

Consulta base configurada en `Table input`:

```sql
SELECT
    show_id,
    title,
    type,
    director,
    cast_members,
    rating,
    duration,
    genres,
    description,
    release_year
FROM staging.stg_netflix_titles;
```

### Flujo en Apache Hop

- `Table input`
- `SV_RENOMBRAR_CAMPOS`
- `SO_LIMPIAR_TEXTO`
- `FR_VALIDAR_CONTENIDO`
- `SR_ORDENAR_CONTENIDO`
- `UR_UNICOS_CONTENIDO`
- `IU_DIM_CONTENIDO`

## Detalle de transformaciones

**1. Table input**

Lee los registros desde `staging.stg_netflix_titles`.

**2. SV_RENOMBRAR_CAMPOS**

Renombra los campos para alinearlos con `dm_streaming.dim_contenido`:

- `show_id` -> `id_contenido`
- `title` -> `titulo`
- `type` -> `tipo_contenido`
- `cast_members` -> `elenco`
- `rating` -> `clasificacion`
- `duration` -> `duracion`
- `genres` -> `genero`
- `description` -> `descripcion`
- `release_year` -> `anio_lanzamiento`

**3. SO_LIMPIAR_TEXTO**

Aplica `trim` a los campos de texto para evitar espacios sobrantes antes de validar y cargar.

**4. FR_VALIDAR_CONTENIDO**

Deja pasar solo filas con estos campos no nulos:

- `id_contenido`
- `titulo`
- `tipo_contenido`

**5. SR_ORDENAR_CONTENIDO**

Ordena por `id_contenido`.

**6. UR_UNICOS_CONTENIDO**

Elimina duplicados usando `id_contenido` como clave.

**7. IU_DIM_CONTENIDO**

Carga en `dm_streaming.dim_contenido` con `Insert / update` usando `id_contenido` como lookup. El resto de los campos queda configurado para actualizacion.

## Validaciones finales

**Conteo de origen**

```sql
SELECT COUNT(*) AS total_staging,
       COUNT(DISTINCT show_id) AS total_ids_unicos,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(show_id)),0)=0 THEN 1 ELSE 0 END) AS ids_nulos,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(title)),0)=0 THEN 1 ELSE 0 END) AS titulos_nulos,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(type)),0)=0 THEN 1 ELSE 0 END) AS tipos_nulos
FROM staging.stg_netflix_titles;
```

Resultado:

- `total_staging = 7787`
- `total_ids_unicos = 7787`
- `ids_nulos = 0`
- `titulos_nulos = 0`
- `tipos_nulos = 0`

**Conteo final en dimension**

```sql
SELECT COUNT(*) AS total_dim,
       COUNT(DISTINCT id_contenido) AS total_ids_dim,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(id_contenido)),0)=0 THEN 1 ELSE 0 END) AS ids_nulos_dim,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(titulo)),0)=0 THEN 1 ELSE 0 END) AS titulos_nulos_dim,
       SUM(CASE WHEN COALESCE(LENGTH(BTRIM(tipo_contenido)),0)=0 THEN 1 ELSE 0 END) AS tipos_nulos_dim
FROM dm_streaming.dim_contenido;
```

Resultado:

- `total_dim = 7787`
- `total_ids_dim = 7787`
- `ids_nulos_dim = 0`
- `titulos_nulos_dim = 0`
- `tipos_nulos_dim = 0`

**Duplicados**

```sql
SELECT id_contenido, COUNT(*) AS repeticiones
FROM dm_streaming.dim_contenido
GROUP BY id_contenido
HAVING COUNT(*) > 1;
```

Resultado: `0 filas`

**Faltantes respecto a staging**

```sql
SELECT COUNT(*) AS ids_faltantes
FROM (
    SELECT DISTINCT BTRIM(show_id) AS show_id
    FROM staging.stg_netflix_titles
    WHERE COALESCE(LENGTH(BTRIM(show_id)),0) > 0
      AND COALESCE(LENGTH(BTRIM(title)),0) > 0
      AND COALESCE(LENGTH(BTRIM(type)),0) > 0
) s
LEFT JOIN dm_streaming.dim_contenido d
       ON d.id_contenido = s.show_id
WHERE d.id_contenido IS NULL;
```

Resultado: `ids_faltantes = 0`

**Distribucion por tipo**

```sql
SELECT tipo_contenido, COUNT(*) AS total
FROM dm_streaming.dim_contenido
GROUP BY tipo_contenido
ORDER BY tipo_contenido;
```

Resultado:

- `Movie = 5377`
- `TV Show = 2410`

## Resultado final

`06_ETL_DIM_CONTENIDO.hpl` quedo validado con `7787` contenidos cargados en `dm_streaming.dim_contenido`, sin duplicados, sin faltantes respecto a staging y sin nulos/vacios en los campos clave.
