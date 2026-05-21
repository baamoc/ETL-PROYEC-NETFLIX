/*
Proyecto: DW Netflix
Archivo: 03_create_dm_streaming_tables.sql
Objetivo: Crear el modelo físico del DataMart dm_streaming.

IMPORTANTE:
- Este script crea las dimensiones y hechos.
- No inserta datos.
- La carga oficial se hace mediante Apache Hop.
*/

CREATE TABLE IF NOT EXISTS dm_streaming.dim_usuario (
    id_usuario INTEGER PRIMARY KEY,
    edad INTEGER,
    genero VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dm_streaming.dim_pais (
    id_pais SERIAL PRIMARY KEY,
    nombre_pais VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dm_streaming.dim_tiempo (
    id_tiempo SERIAL PRIMARY KEY,
    fecha_completa DATE NOT NULL UNIQUE,
    dia INTEGER,
    mes INTEGER,
    anio INTEGER
);

CREATE TABLE IF NOT EXISTS dm_streaming.dim_contenido (
    id_contenido VARCHAR(20) PRIMARY KEY,
    titulo VARCHAR(255),
    tipo_contenido VARCHAR(50),
    director TEXT,
    elenco TEXT,
    clasificacion VARCHAR(50),
    duracion VARCHAR(50),
    genero TEXT,
    descripcion TEXT,
    anio_lanzamiento INTEGER
);

CREATE TABLE IF NOT EXISTS dm_streaming.dim_suscripcion (
    id_suscripcion SERIAL PRIMARY KEY,
    tipo_suscripcion VARCHAR(50) NOT NULL,
    duracion_plan VARCHAR(50),
    CONSTRAINT uq_dim_suscripcion UNIQUE (tipo_suscripcion, duracion_plan)
);

CREATE TABLE IF NOT EXISTS dm_streaming.dim_dispositivo (
    id_dispositivo SERIAL PRIMARY KEY,
    nombre_dispositivo VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dm_streaming.fact_consumo (
    id_consumo SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    id_contenido VARCHAR(20) NOT NULL,
    id_pais INTEGER NOT NULL,
    id_tiempo INTEGER NOT NULL,
    cantidad_visualizaciones INTEGER NOT NULL,

    CONSTRAINT fk_consumo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dm_streaming.dim_usuario(id_usuario),

    CONSTRAINT fk_consumo_contenido
        FOREIGN KEY (id_contenido)
        REFERENCES dm_streaming.dim_contenido(id_contenido),

    CONSTRAINT fk_consumo_pais
        FOREIGN KEY (id_pais)
        REFERENCES dm_streaming.dim_pais(id_pais),

    CONSTRAINT fk_consumo_tiempo
        FOREIGN KEY (id_tiempo)
        REFERENCES dm_streaming.dim_tiempo(id_tiempo)
);

CREATE TABLE IF NOT EXISTS dm_streaming.fact_ingresos (
    id_ingreso SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    id_suscripcion INTEGER NOT NULL,
    id_dispositivo INTEGER NOT NULL,
    id_pais INTEGER NOT NULL,
    id_tiempo INTEGER NOT NULL,
    ingreso_mensual NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_ingresos_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dm_streaming.dim_usuario(id_usuario),

    CONSTRAINT fk_ingresos_suscripcion
        FOREIGN KEY (id_suscripcion)
        REFERENCES dm_streaming.dim_suscripcion(id_suscripcion),

    CONSTRAINT fk_ingresos_dispositivo
        FOREIGN KEY (id_dispositivo)
        REFERENCES dm_streaming.dim_dispositivo(id_dispositivo),

    CONSTRAINT fk_ingresos_pais
        FOREIGN KEY (id_pais)
        REFERENCES dm_streaming.dim_pais(id_pais),

    CONSTRAINT fk_ingresos_tiempo
        FOREIGN KEY (id_tiempo)
        REFERENCES dm_streaming.dim_tiempo(id_tiempo)
);

CREATE INDEX IF NOT EXISTS idx_fact_consumo_usuario
ON dm_streaming.fact_consumo(id_usuario);

CREATE INDEX IF NOT EXISTS idx_fact_consumo_contenido
ON dm_streaming.fact_consumo(id_contenido);

CREATE INDEX IF NOT EXISTS idx_fact_ingresos_usuario
ON dm_streaming.fact_ingresos(id_usuario);

CREATE INDEX IF NOT EXISTS idx_fact_ingresos_tiempo
ON dm_streaming.fact_ingresos(id_tiempo);