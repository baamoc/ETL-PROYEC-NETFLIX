-- ============================================================
-- VERIFICACION DEL DATA MART dm_streaming
-- Proyecto: ETL Netflix - Base de Datos 3
-- Ejecutar en: Neon console (neon.tech) o cualquier cliente PostgreSQL
-- ============================================================


-- ------------------------------------------------------------
-- 1. CONTEO GENERAL DE TODAS LAS TABLAS
--    Resultado esperado al final del proceso ETL completo
-- ------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM dm_streaming.dim_suscripcion)  AS dim_suscripcion,   -- esperado: 3
    (SELECT COUNT(*) FROM dm_streaming.dim_usuario)      AS dim_usuario,        -- esperado: 2500
    (SELECT COUNT(*) FROM dm_streaming.dim_pais)         AS dim_pais,           -- esperado: 10
    (SELECT COUNT(*) FROM dm_streaming.dim_tiempo)       AS dim_tiempo,         -- esperado: 1822
    (SELECT COUNT(*) FROM dm_streaming.dim_dispositivo)  AS dim_dispositivo,    -- esperado: 4
    (SELECT COUNT(*) FROM dm_streaming.dim_contenido)    AS dim_contenido,      -- esperado: 7787
    (SELECT COUNT(*) FROM dm_streaming.fact_ingresos)    AS fact_ingresos,      -- esperado: 2500
    (SELECT COUNT(*) FROM dm_streaming.fact_consumo)     AS fact_consumo;       -- esperado: 5000


-- ------------------------------------------------------------
-- 2. VERIFICAR DIMENSIONES (muestra de datos)
-- ------------------------------------------------------------

-- Tipos de suscripcion disponibles
SELECT * FROM dm_streaming.dim_suscripcion ORDER BY id_suscripcion;

-- Muestra de 5 usuarios
SELECT * FROM dm_streaming.dim_usuario LIMIT 5;

-- Todos los paises cargados
SELECT * FROM dm_streaming.dim_pais ORDER BY nombre_pais;

-- Todos los dispositivos
SELECT * FROM dm_streaming.dim_dispositivo ORDER BY nombre_dispositivo;

-- Rango de fechas en dim_tiempo
SELECT
    MIN(fecha_completa) AS fecha_minima,
    MAX(fecha_completa) AS fecha_maxima,
    COUNT(*)            AS total_fechas
FROM dm_streaming.dim_tiempo;

-- Muestra de 5 contenidos
SELECT * FROM dm_streaming.dim_contenido LIMIT 5;


-- ------------------------------------------------------------
-- 3. VERIFICAR HECHOS (muestra con claves foraneas resueltas)
-- ------------------------------------------------------------

-- fact_ingresos: muestra con nombres de dimension
SELECT
    u.user_id,
    s.tipo_suscripcion,
    s.duracion_plan,
    d.nombre_dispositivo,
    p.nombre_pais,
    t.fecha_completa     AS fecha_pago,
    fi.ingreso_mensual
FROM dm_streaming.fact_ingresos fi
JOIN dm_streaming.dim_usuario      u ON fi.id_usuario      = u.user_id
JOIN dm_streaming.dim_suscripcion  s ON fi.id_suscripcion  = s.id_suscripcion
JOIN dm_streaming.dim_dispositivo  d ON fi.id_dispositivo  = d.id_dispositivo
JOIN dm_streaming.dim_pais         p ON fi.id_pais         = p.id_pais
JOIN dm_streaming.dim_tiempo       t ON fi.id_tiempo       = t.id_tiempo
LIMIT 10;

-- fact_consumo: muestra con nombres de dimension
SELECT
    u.user_id,
    c.titulo            AS contenido,
    c.tipo              AS tipo_contenido,
    p.nombre_pais,
    t.fecha_completa    AS fecha_consumo,
    fc.cantidad_visualizaciones
FROM dm_streaming.fact_consumo fc
JOIN dm_streaming.dim_usuario   u ON fc.id_usuario   = u.user_id
JOIN dm_streaming.dim_contenido c ON fc.id_contenido = c.show_id
JOIN dm_streaming.dim_pais      p ON fc.id_pais      = p.id_pais
JOIN dm_streaming.dim_tiempo    t ON fc.id_tiempo    = t.id_tiempo
LIMIT 10;


-- ------------------------------------------------------------
-- 4. VERIFICACION DE INTEGRIDAD REFERENCIAL
--    Todas estas consultas deben devolver 0 filas
-- ------------------------------------------------------------

-- FKs huerfanas en fact_ingresos
SELECT 'fact_ingresos - id_usuario huerfano'    AS check_name, COUNT(*) AS total FROM dm_streaming.fact_ingresos fi WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_usuario u WHERE u.user_id = fi.id_usuario)
UNION ALL
SELECT 'fact_ingresos - id_suscripcion huerfano', COUNT(*) FROM dm_streaming.fact_ingresos fi WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_suscripcion s WHERE s.id_suscripcion = fi.id_suscripcion)
UNION ALL
SELECT 'fact_ingresos - id_dispositivo huerfano', COUNT(*) FROM dm_streaming.fact_ingresos fi WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_dispositivo d WHERE d.id_dispositivo = fi.id_dispositivo)
UNION ALL
SELECT 'fact_ingresos - id_pais huerfano',        COUNT(*) FROM dm_streaming.fact_ingresos fi WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_pais p WHERE p.id_pais = fi.id_pais)
UNION ALL
SELECT 'fact_ingresos - id_tiempo huerfano',      COUNT(*) FROM dm_streaming.fact_ingresos fi WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_tiempo t WHERE t.id_tiempo = fi.id_tiempo)
UNION ALL
-- FKs huerfanas en fact_consumo
SELECT 'fact_consumo - id_usuario huerfano',      COUNT(*) FROM dm_streaming.fact_consumo fc WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_usuario u WHERE u.user_id = fc.id_usuario)
UNION ALL
SELECT 'fact_consumo - id_contenido huerfano',    COUNT(*) FROM dm_streaming.fact_consumo fc WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_contenido c WHERE c.show_id = fc.id_contenido)
UNION ALL
SELECT 'fact_consumo - id_pais huerfano',         COUNT(*) FROM dm_streaming.fact_consumo fc WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_pais p WHERE p.id_pais = fc.id_pais)
UNION ALL
SELECT 'fact_consumo - id_tiempo huerfano',       COUNT(*) FROM dm_streaming.fact_consumo fc WHERE NOT EXISTS (SELECT 1 FROM dm_streaming.dim_tiempo t WHERE t.id_tiempo = fc.id_tiempo);


-- ------------------------------------------------------------
-- 5. ANALISIS DE NEGOCIO (consultas de ejemplo)
-- ------------------------------------------------------------

-- Ingresos totales por tipo de suscripcion
SELECT
    s.tipo_suscripcion,
    COUNT(*)                    AS cantidad_usuarios,
    SUM(fi.ingreso_mensual)     AS ingreso_total,
    AVG(fi.ingreso_mensual)     AS ingreso_promedio
FROM dm_streaming.fact_ingresos fi
JOIN dm_streaming.dim_suscripcion s ON fi.id_suscripcion = s.id_suscripcion
GROUP BY s.tipo_suscripcion
ORDER BY ingreso_total DESC;

-- Usuarios por pais
SELECT
    p.nombre_pais,
    COUNT(DISTINCT fi.id_usuario) AS cantidad_usuarios,
    SUM(fi.ingreso_mensual)       AS ingreso_total
FROM dm_streaming.fact_ingresos fi
JOIN dm_streaming.dim_pais p ON fi.id_pais = p.id_pais
GROUP BY p.nombre_pais
ORDER BY cantidad_usuarios DESC;

-- Contenido mas consumido (top 10)
SELECT
    c.titulo,
    c.tipo,
    COUNT(*) AS cantidad_visualizaciones
FROM dm_streaming.fact_consumo fc
JOIN dm_streaming.dim_contenido c ON fc.id_contenido = c.show_id
GROUP BY c.titulo, c.tipo
ORDER BY cantidad_visualizaciones DESC
LIMIT 10;
