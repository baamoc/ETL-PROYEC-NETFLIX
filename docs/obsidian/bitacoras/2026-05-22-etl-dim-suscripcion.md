# Avance 2026-05-22 - ETL Dim Suscripcion y Neon

Fecha: 2026-05-22

## Objetivo de la jornada

- Confirmar trabajo contra Neon.
- Validar staging en Neon.
- Crear y ejecutar `02_ETL_DIM_SUSCRIPCION.hpl`.
- Validar `dm_streaming.dim_suscripcion`.
- Dejar instrucciones para continuar con el siguiente pipeline.

## Estado previo

- Neon operativo con esquemas `staging` y `dm_streaming`.
- Tablas staging y tablas finales creadas.
- `01_ETL_DIM_DISPOSITIVO.hpl` ejecutado previamente.

## Validaciones en staging (Neon)

```sql
SELECT COUNT(*) AS total_userbase
FROM staging.stg_netflix_userbase;
```

Resultado: 2500

```sql
SELECT DISTINCT
    "Subscription Type",
    "Plan Duration"
FROM staging.stg_netflix_userbase
ORDER BY "Subscription Type", "Plan Duration";
```

Resultado esperado:

- Basic | 1 Month
- Premium | 1 Month
- Standard | 1 Month

## Pipeline creado

- Archivo: `pipelines/02_ETL_DIM_SUSCRIPCION.hpl`
- Origen: `staging.stg_netflix_userbase`
- Destino: `dm_streaming.dim_suscripcion`

## Flujo ETL usado

1. Table input
2. Select values
3. String operations (trim)
4. Filter rows (no nulos)
5. Sort rows
6. Unique rows
7. Insert / update

## Detalles importantes

- Renombrado correcto: `Subscription Type` -> `tipo_suscripcion`, `Plan Duration` -> `duracion_plan`.
- En String operations, dejar **Out stream field** vacio para evitar campos duplicados.
- En Insert / update, usar claves naturales: `tipo_suscripcion` + `duracion_plan`.
- No insertar `id_suscripcion` (autogenerado).

## Validacion final

```sql
SELECT *
FROM dm_streaming.dim_suscripcion
ORDER BY id_suscripcion;
```

Resultado:

- 1 | Basic | 1 Month
- 2 | Premium | 1 Month
- 3 | Standard | 1 Month

```sql
SELECT COUNT(*) AS total_suscripciones
FROM dm_streaming.dim_suscripcion;
```

Resultado: 3

## Estado actual

- dim_dispositivo: OK
- dim_suscripcion: OK

Pendiente:

- 03_ETL_DIM_USUARIO.hpl
- 04_ETL_DIM_TIEMPO.hpl
- 05_ETL_DIM_PAIS.hpl
- 06_ETL_DIM_CONTENIDO.hpl
- 07_ETL_FACT_INGRESOS.hpl
- 08_ETL_FACT_CONSUMO.hpl
- 00_RUN_ETL_COMPLETO.hwf

## Siguiente pipeline recomendado

- `03_ETL_DIM_USUARIO.hpl`
- Origen: `staging.stg_netflix_userbase`
- Campos: `"User ID"`, `age`, `gender`
- Destino: `dm_streaming.dim_usuario` (`id_usuario`, `edad`, `genero`)

## Reglas para continuar

- Trabajar contra Neon.
- DBeaver solo para validar.
- No cargar manualmente en `dm_streaming`.
- Guardar evidencias en `docs/evidencias/`.
