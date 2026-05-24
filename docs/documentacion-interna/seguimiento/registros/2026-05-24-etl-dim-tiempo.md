# Avance 2026-05-24 - ETL Dim Tiempo

Fecha: 2026-05-24

## Objetivo de la jornada

- Ejecutar y validar `04_ETL_DIM_TIEMPO.hpl`.
- Cargar fechas unicas en `dm_streaming.dim_tiempo`.
- Confirmar que no existan duplicados ni valores nulos en los campos principales.

## Pipeline validado

- Archivo: `pipelines/04_ETL_DIM_TIEMPO.hpl`
- Origen: fechas provenientes de `staging.stg_netflix_userbase` y `staging.stg_netflix_titles`
- Destino: `dm_streaming.dim_tiempo`

## Como se hizo

El pipeline toma fechas desde tres fuentes de negocio:

- `"Join Date"` de `staging.stg_netflix_userbase`
- `"Last Payment Date"` de `staging.stg_netflix_userbase`
- `date_added` de `staging.stg_netflix_titles`

Luego aplica este flujo:

1. `Leer_fechas_desde_staging`
2. `Preparar campos tiempo`
3. `Filtrar fechas validas`
4. `Ordenar por fecha`
5. `Eliminar fechas duplicadas`
6. `Cargar dim_tiempo`

Detalles verificados en el pipeline:

- `date_added` se convierte a fecha cuando viene en formatos compatibles.
- Se filtran fechas nulas antes de continuar.
- La carga final usa `Insert / update` con `fecha_completa` como clave de busqueda para evitar duplicados en la dimension.
- Se cargan los campos `fecha_completa`, `dia`, `mes` y `anio`.

## Validaciones finales

```sql
SELECT COUNT(*) AS total_dim_tiempo
FROM dm_streaming.dim_tiempo;
```

Resultado final:

- `total_dim_tiempo = 1837`

```sql
SELECT 
    COUNT(*) AS total_filas,
    COUNT(DISTINCT fecha_completa) AS total_fechas_unicas
FROM dm_streaming.dim_tiempo;
```

Resultado final:

- `total_filas = 1837`
- `total_fechas_unicas = 1837`

```sql
SELECT *
FROM dm_streaming.dim_tiempo
WHERE fecha_completa IS NULL
   OR dia IS NULL
   OR mes IS NULL
   OR anio IS NULL;
```

Resultado final:

- `0 filas`

## Conclusion

El pipeline `04_ETL_DIM_TIEMPO.hpl` fue ejecutado correctamente y cargo `1837` fechas unicas en `dm_streaming.dim_tiempo`.

Se valido que no existen fechas duplicadas, porque el total de filas coincide con el total de fechas unicas. Tambien se comprobo que no existen valores nulos en `fecha_completa`, `dia`, `mes` ni `anio`.
