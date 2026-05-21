/*
Proyecto: DW Netflix
Archivo: 04_validaciones_iniciales.sql
Objetivo: Validar estado inicial de la base, esquemas, staging y DataMart.

Este script NO modifica datos.
Solo consulta.
*/

-- 1. Validar encoding de la base
SHOW server_encoding;

-- 2. Validar existencia de esquemas
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('staging', 'dm_streaming')
ORDER BY schema_name;

-- 3. Validar tablas staging
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
ORDER BY table_name;

-- 4. Validar tablas dm_streaming
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'dm_streaming'
ORDER BY table_name;

-- 5. Conteo de registros en staging
SELECT 'stg_netflix_titles' AS tabla, COUNT(*) AS total
FROM staging.stg_netflix_titles
UNION ALL
SELECT 'stg_netflix_userbase' AS tabla, COUNT(*) AS total
FROM staging.stg_netflix_userbase;

-- 6. Conteo de registros en dimensiones y hechos
SELECT 'dim_usuario' AS tabla, COUNT(*) AS total FROM dm_streaming.dim_usuario
UNION ALL
SELECT 'dim_pais', COUNT(*) FROM dm_streaming.dim_pais
UNION ALL
SELECT 'dim_tiempo', COUNT(*) FROM dm_streaming.dim_tiempo
UNION ALL
SELECT 'dim_contenido', COUNT(*) FROM dm_streaming.dim_contenido
UNION ALL
SELECT 'dim_suscripcion', COUNT(*) FROM dm_streaming.dim_suscripcion
UNION ALL
SELECT 'dim_dispositivo', COUNT(*) FROM dm_streaming.dim_dispositivo
UNION ALL
SELECT 'fact_consumo', COUNT(*) FROM dm_streaming.fact_consumo
UNION ALL
SELECT 'fact_ingresos', COUNT(*) FROM dm_streaming.fact_ingresos;

-- 7. Validar valores únicos de dispositivos en staging
SELECT DISTINCT device
FROM staging.stg_netflix_userbase
ORDER BY device;

-- 8. Validar valores únicos de suscripción en staging
SELECT DISTINCT
    "Subscription Type",
    "Plan Duration"
FROM staging.stg_netflix_userbase
ORDER BY "Subscription Type", "Plan Duration";