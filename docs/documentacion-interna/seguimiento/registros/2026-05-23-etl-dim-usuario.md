# Avance 2026-05-23 - ETL Dim Usuario (en progreso)

Fecha: 2026-05-23

## Objetivo de la jornada

- Construir y ejecutar `03_ETL_DIM_USUARIO.hpl` contra Neon.
- Validar carga en `dm_streaming.dim_usuario`.

## Validaciones previas (Neon)

```sql
SELECT COUNT(*) AS total_userbase
FROM staging.stg_netflix_userbase;

SELECT COUNT(DISTINCT "User ID") AS usuarios_unicos
FROM staging.stg_netflix_userbase;

SELECT DISTINCT gender
FROM staging.stg_netflix_userbase
ORDER BY gender;
```

## Pipeline objetivo

- Archivo: `pipelines/03_ETL_DIM_USUARIO.hpl`
- Origen: `staging.stg_netflix_userbase`
- Destino: `dm_streaming.dim_usuario`

Campos:

- "User ID" -> id_usuario
- age -> edad
- gender -> genero

Nota: `id_usuario` NO es autogenerado.

## Flujo ETL usado

1. Table input
2. Select values
3. String operations
4. Filter rows
5. Sort rows
6. Unique rows
7. Insert / update

## Observacion de ejecucion

- La carga avanzo por lotes (commit size 100).
- El conteo parcial fue normal mientras seguia ejecutando.

## Validaciones finales

Ejecutado al finalizar:

```sql
SELECT COUNT(*) AS total_usuarios
FROM dm_streaming.dim_usuario;

SELECT *
FROM dm_streaming.dim_usuario
ORDER BY id_usuario
LIMIT 20;
```

Resultado:

- total_usuarios = 2500
