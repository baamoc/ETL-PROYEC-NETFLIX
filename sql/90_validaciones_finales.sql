/*
Proyecto: DW Netflix
Archivo: 90_validaciones_finales.sql
Objetivo: Validar el estado final del DataMart después de ejecutar los pipelines ETL.

Este script NO modifica datos.
Solo consulta.
*/

-- 1. Validar encoding
SHOW server_encoding;

-- 2. Conteo final de tablas principales
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

-- 3. Validar dim_dispositivo
SELECT *
FROM dm_streaming.dim_dispositivo
ORDER BY id_dispositivo;

-- 4. Validar dim_suscripcion
SELECT *
FROM dm_streaming.dim_suscripcion
ORDER BY id_suscripcion;

-- 5. Validar dim_usuario
SELECT *
FROM dm_streaming.dim_usuario
ORDER BY id_usuario
LIMIT 20;

-- 6. Validar dim_pais
SELECT *
FROM dm_streaming.dim_pais
ORDER BY nombre_pais
LIMIT 50;

-- 7. Validar dim_tiempo
SELECT *
FROM dm_streaming.dim_tiempo
ORDER BY fecha_completa
LIMIT 50;

-- 8. Validar dim_contenido
SELECT *
FROM dm_streaming.dim_contenido
ORDER BY id_contenido
LIMIT 20;

-- 9. Validar fact_ingresos con dimensiones
SELECT
    u.id_usuario,
    u.edad,
    u.genero,
    s.tipo_suscripcion,
    s.duracion_plan,
    d.nombre_dispositivo,
    p.nombre_pais,
    t.fecha_completa,
    f.ingreso_mensual
FROM dm_streaming.fact_ingresos f
INNER JOIN dm_streaming.dim_usuario u
    ON f.id_usuario = u.id_usuario
INNER JOIN dm_streaming.dim_suscripcion s
    ON f.id_suscripcion = s.id_suscripcion
INNER JOIN dm_streaming.dim_dispositivo d
    ON f.id_dispositivo = d.id_dispositivo
INNER JOIN dm_streaming.dim_pais p
    ON f.id_pais = p.id_pais
INNER JOIN dm_streaming.dim_tiempo t
    ON f.id_tiempo = t.id_tiempo
LIMIT 50;

-- 10. Validar fact_consumo con dimensiones
SELECT
    u.id_usuario,
    c.titulo,
    c.tipo_contenido,
    p.nombre_pais,
    t.fecha_completa,
    f.cantidad_visualizaciones
FROM dm_streaming.fact_consumo f
INNER JOIN dm_streaming.dim_usuario u
    ON f.id_usuario = u.id_usuario
INNER JOIN dm_streaming.dim_contenido c
    ON f.id_contenido = c.id_contenido
INNER JOIN dm_streaming.dim_pais p
    ON f.id_pais = p.id_pais
INNER JOIN dm_streaming.dim_tiempo t
    ON f.id_tiempo = t.id_tiempo
LIMIT 50;

-- 11. Reporte OLAP: ingresos por tipo de suscripción
SELECT
    s.tipo_suscripcion,
    s.duracion_plan,
    SUM(f.ingreso_mensual) AS total_ingresos
FROM dm_streaming.fact_ingresos f
INNER JOIN dm_streaming.dim_suscripcion s
    ON f.id_suscripcion = s.id_suscripcion
GROUP BY s.tipo_suscripcion, s.duracion_plan
ORDER BY total_ingresos DESC;

-- 12. Reporte OLAP: ingresos por dispositivo
SELECT
    d.nombre_dispositivo,
    SUM(f.ingreso_mensual) AS total_ingresos
FROM dm_streaming.fact_ingresos f
INNER JOIN dm_streaming.dim_dispositivo d
    ON f.id_dispositivo = d.id_dispositivo
GROUP BY d.nombre_dispositivo
ORDER BY total_ingresos DESC;

-- 13. Reporte OLAP: consumo por contenido
SELECT
    c.titulo,
    c.tipo_contenido,
    SUM(f.cantidad_visualizaciones) AS total_visualizaciones
FROM dm_streaming.fact_consumo f
INNER JOIN dm_streaming.dim_contenido c
    ON f.id_contenido = c.id_contenido
GROUP BY c.titulo, c.tipo_contenido
ORDER BY total_visualizaciones DESC
LIMIT 20;

-- 14. Reporte OLAP: consumo por país
SELECT
    p.nombre_pais,
    SUM(f.cantidad_visualizaciones) AS total_visualizaciones
FROM dm_streaming.fact_consumo f
INNER JOIN dm_streaming.dim_pais p
    ON f.id_pais = p.id_pais
GROUP BY p.nombre_pais
ORDER BY total_visualizaciones DESC
LIMIT 20;