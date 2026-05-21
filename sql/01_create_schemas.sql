/*
Proyecto: DW Netflix
Archivo: 01_create_schemas.sql
Objetivo: Crear los esquemas principales del proyecto.

IMPORTANTE:
- Este script NO borra datos.
- Solo crea los esquemas si no existen.
*/

CREATE SCHEMA IF NOT EXISTS staging;

CREATE SCHEMA IF NOT EXISTS dm_streaming;

-- Validación recomendada:
-- SELECT schema_name
-- FROM information_schema.schemata
-- WHERE schema_name IN ('staging', 'dm_streaming')
-- ORDER BY schema_name;


