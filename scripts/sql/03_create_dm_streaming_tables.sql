-- ============================================================
-- Script 03: Create Data Mart tables (dimensions + facts)
-- Schema: dm_streaming
-- Based on: Modelo Físico del Data Mart (professor-approved)
-- ============================================================

-- ------------------------------------------------------------
-- DIMENSIONS
-- ------------------------------------------------------------

-- dim_dispositivo
-- Source: stg_netflix_userbase.device
-- Known values from data: Laptop, Smart TV, Smartphone, Tablet
DROP TABLE IF EXISTS dm_streaming.dim_dispositivo CASCADE;
CREATE TABLE dm_streaming.dim_dispositivo (
    id_dispositivo     SERIAL PRIMARY KEY,
    nombre_dispositivo VARCHAR(30) NOT NULL UNIQUE
);

-- dim_suscripcion
-- Source: stg_netflix_userbase (subscription_type, plan_duration)
-- Known values from data: Basic, Standard, Premium — plan always "1 Month"
DROP TABLE IF EXISTS dm_streaming.dim_suscripcion CASCADE;
CREATE TABLE dm_streaming.dim_suscripcion (
    id_suscripcion   SERIAL PRIMARY KEY,
    tipo_suscripcion VARCHAR(30) NOT NULL,
    duracion_plan    VARCHAR(30) NOT NULL
);

-- dim_usuario
-- Source: stg_netflix_userbase (user_id, age, gender)
-- id_usuario is the natural key from source (1..2500)
DROP TABLE IF EXISTS dm_streaming.dim_usuario CASCADE;
CREATE TABLE dm_streaming.dim_usuario (
    id_usuario INTEGER PRIMARY KEY,
    edad       INTEGER NOT NULL,
    genero     VARCHAR(20) NOT NULL
);

-- dim_pais
-- Source: both datasets
-- Userbase: Australia, Brazil, Canada, France, Germany,
--           Italy, Mexico, Spain, United Kingdom, United States
-- Titles: global catalog countries
DROP TABLE IF EXISTS dm_streaming.dim_pais CASCADE;
CREATE TABLE dm_streaming.dim_pais (
    id_pais     SERIAL PRIMARY KEY,
    nombre_pais VARCHAR(100) NOT NULL UNIQUE
);

-- dim_tiempo
-- Source: dates from stg_netflix_userbase (join_date, last_payment_date)
--         and stg_netflix_titles (date_added)
DROP TABLE IF EXISTS dm_streaming.dim_tiempo CASCADE;
CREATE TABLE dm_streaming.dim_tiempo (
    id_tiempo      SERIAL PRIMARY KEY,
    fecha_completa DATE NOT NULL UNIQUE,
    dia            INTEGER NOT NULL,
    mes            INTEGER NOT NULL,
    anio           INTEGER NOT NULL
);

-- dim_contenido
-- Source: stg_netflix_titles
-- id_contenido = show_id from source (e.g. s1, s10, s100) — VARCHAR(20) PK
DROP TABLE IF EXISTS dm_streaming.dim_contenido CASCADE;
CREATE TABLE dm_streaming.dim_contenido (
    id_contenido     VARCHAR(20) PRIMARY KEY,
    titulo           VARCHAR(255) NOT NULL,
    tipo_contenido   VARCHAR(20) NOT NULL,
    director         VARCHAR(255),
    elenco           TEXT,
    clasificacion    VARCHAR(20),
    duracion         VARCHAR(50),
    genero           VARCHAR(255),
    descripcion      TEXT,
    anio_lanzamiento INTEGER
);

-- ------------------------------------------------------------
-- FACT TABLES
-- ------------------------------------------------------------

-- fact_consumo
-- Grain: one record per user per content item per country per date
-- Derived: content added to Netflix on or before user's join_date
--          from the user's country
DROP TABLE IF EXISTS dm_streaming.fact_consumo CASCADE;
CREATE TABLE dm_streaming.fact_consumo (
    id_consumo               SERIAL PRIMARY KEY,
    id_usuario               INTEGER NOT NULL REFERENCES dm_streaming.dim_usuario(id_usuario),
    id_contenido             VARCHAR(20) NOT NULL REFERENCES dm_streaming.dim_contenido(id_contenido),
    id_pais                  INTEGER NOT NULL REFERENCES dm_streaming.dim_pais(id_pais),
    id_tiempo                INTEGER NOT NULL REFERENCES dm_streaming.dim_tiempo(id_tiempo),
    cantidad_visualizaciones INTEGER NOT NULL DEFAULT 1
);

-- fact_ingresos
-- Grain: one revenue record per user per last payment date
-- Source: stg_netflix_userbase
DROP TABLE IF EXISTS dm_streaming.fact_ingresos CASCADE;
CREATE TABLE dm_streaming.fact_ingresos (
    id_ingreso      SERIAL PRIMARY KEY,
    id_usuario      INTEGER NOT NULL REFERENCES dm_streaming.dim_usuario(id_usuario),
    id_suscripcion  INTEGER NOT NULL REFERENCES dm_streaming.dim_suscripcion(id_suscripcion),
    id_dispositivo  INTEGER NOT NULL REFERENCES dm_streaming.dim_dispositivo(id_dispositivo),
    id_pais         INTEGER NOT NULL REFERENCES dm_streaming.dim_pais(id_pais),
    id_tiempo       INTEGER NOT NULL REFERENCES dm_streaming.dim_tiempo(id_tiempo),
    ingreso_mensual DECIMAL(10,2) NOT NULL
);
