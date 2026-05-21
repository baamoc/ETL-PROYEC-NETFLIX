/*
Proyecto: DW Netflix
Archivo: 02_create_staging_tables.sql
Objetivo: Crear las tablas staging con estructura compatible con los CSV originales.

Regla:
- staging conserva nombres crudos/originales cuando sea necesario.
- No se aplican transformaciones analíticas aquí.
*/

CREATE TABLE IF NOT EXISTS staging.stg_netflix_titles (
    show_id VARCHAR(20),
    type VARCHAR(50),
    title TEXT,
    director TEXT,
    cast_members TEXT,
    country TEXT,
    date_added VARCHAR(50),
    release_year INTEGER,
    rating VARCHAR(50),
    duration VARCHAR(50),
    genres TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS staging.stg_netflix_userbase (
    "User ID" INTEGER,
    "Subscription Type" VARCHAR(50),
    "Monthly Revenue" NUMERIC(10,2),
    "Join Date" DATE,
    "Last Payment Date" DATE,
    country VARCHAR(100),
    age INTEGER,
    gender VARCHAR(20),
    device VARCHAR(50),
    "Plan Duration" VARCHAR(50)
);

-- Validaciones recomendadas:
-- SELECT COUNT(*) FROM staging.stg_netflix_titles;
-- SELECT COUNT(*) FROM staging.stg_netflix_userbase;