CREATE SCHEMA IF NOT EXISTS dw_apache_logs;

DROP TABLE IF EXISTS dw_apache_logs.dim_clientes CASCADE;
DROP TABLE IF EXISTS dw_apache_logs.dim_cod_respuesta CASCADE;
DROP TABLE IF EXISTS dw_apache_logs.dim_os CASCADE;
DROP TABLE IF EXISTS dw_apache_logs.dim_recursos CASCADE;
DROP TABLE IF EXISTS dw_apache_logs.dim_respuestas CASCADE;
DROP TABLE IF EXISTS dw_apache_logs.dim_tiempo CASCADE;

CREATE TABLE dw_apache_logs.dim_clientes (
    cliente_id SERIAL NOT NULL,
    ip VARCHAR(50) NULL,
    isp VARCHAR(255) NULL,
    pais VARCHAR(100) NULL,
    ciudad VARCHAR(100) NULL,
    CONSTRAINT dim_clientes_pkey PRIMARY KEY (cliente_id)
);

CREATE TABLE dw_apache_logs.dim_cod_respuesta (
    id_cod SERIAL NOT NULL,
    codigo VARCHAR(10) NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT dim_cod_respuesta_pkey PRIMARY KEY (id_cod)
);

CREATE TABLE dw_apache_logs.dim_os (
    os_id SERIAL NOT NULL,
    nombre VARCHAR(150) NULL,
    version VARCHAR(100) NULL,
    familia VARCHAR(150) NULL,
    CONSTRAINT dim_os_pkey PRIMARY KEY (os_id)
);

CREATE TABLE dw_apache_logs.dim_recursos (
    id_recurso SERIAL NOT NULL,
    direccion TEXT NOT NULL,
    CONSTRAINT dim_recursos_pkey PRIMARY KEY (id_recurso),
    CONSTRAINT dim_recursos_direccion_key UNIQUE (direccion)
);

CREATE TABLE dw_apache_logs.dim_respuestas (
    id_respuesta SERIAL NOT NULL,
    codigo INTEGER NOT NULL,
    descripcion VARCHAR(100) NULL,
    CONSTRAINT dim_respuestas_pkey PRIMARY KEY (id_respuesta),
    CONSTRAINT dim_respuestas_codigo_key UNIQUE (codigo)
);

CREATE TABLE dw_apache_logs.dim_tiempo (
    id_tiempo SERIAL NOT NULL,
    dia INTEGER NULL,
    "año" INTEGER NULL,
    hora INTEGER NULL,
    min INTEGER NULL,
    seg INTEGER NULL,
    mes INTEGER NULL,
    desc_mes VARCHAR(20) NULL,
    semana INTEGER NULL,
    desc_dia VARCHAR(20) NULL,
    dow INTEGER NULL,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP NULL,
    CONSTRAINT dim_tiempo_pkey PRIMARY KEY (id_tiempo),
    CONSTRAINT uk_dim_tiempo UNIQUE ("año", mes, dia, hora, min, seg)
);