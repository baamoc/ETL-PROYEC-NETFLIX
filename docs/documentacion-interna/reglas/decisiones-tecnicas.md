# Decisiones tecnicas del proyecto DW Netflix

Este archivo resume las decisiones tecnicas que hoy rigen el proyecto. La idea es que cualquier integrante pueda revisar rapido que herramienta usar, que esta permitido y que riesgos hay que cuidar.

## 1. Herramientas oficiales

| Area | Herramienta oficial | Uso principal |
| --- | --- | --- |
| Base de datos | PostgreSQL | Motor principal del Data Warehouse |
| Base compartida | Neon PostgreSQL | Trabajo colaborativo y validacion compartida |
| Cliente SQL | DBeaver | Consultas, conteos, auditoria y validaciones |
| ETL | Apache Hop | Carga y transformacion oficial |
| Repositorio | GitHub | Control de versiones y trabajo en equipo |

## 2. Arquitectura oficial

```text
CSV Kaggle
   -> staging
   -> Apache Hop ETL
   -> dm_streaming
   -> Consultas OLAP
   -> Reportes
   -> Dashboard / KPIs
```

## 3. Reglas base de trabajo

- DBeaver no se considera herramienta ETL oficial.
- DBeaver se usa para validar datos, ejecutar consultas, revisar resultados y auditar conteos.
- No se deben insertar datos manualmente en `dm_streaming` desde DBeaver.
- Apache Hop es la herramienta oficial para cargar datos hacia `dm_streaming`.
- Todo pipeline ETL debe partir desde `staging`.
- Todo pipeline debe dejar evidencia documentada de configuracion, ejecucion y validacion.

## 4. Decisiones sobre modelado y carga

### staging

El esquema `staging` conserva datos crudos de los CSV. Se permite mantener nombres originales, incluso con espacios o mayusculas, por ejemplo:

- `"User ID"`
- `"Subscription Type"`
- `"Monthly Revenue"`
- `"Join Date"`
- `"Last Payment Date"`
- `"Plan Duration"`

### dm_streaming

El esquema `dm_streaming` debe usar nombres limpios, consistentes y orientados al analisis.

Ejemplos esperados:

- `tipo_suscripcion`
- `duracion_plan`
- `nombre_dispositivo`
- `nombre_pais`
- `fecha_completa`

### fact_consumo

Los datasets `NetFlix.csv` y `Netflix Userbase.csv` no tienen una relacion natural directa.

Por eso `fact_consumo` se construye con una logica simulada o controlada y siempre documentada. La regla aplicada en el estado validado actual es `1 usuario = 1 consumo simulado`, con asignacion controlada de contenido y cantidad de visualizaciones generada de forma reproducible. No se debe inventar una relacion sin explicacion ni evidencia.

### dim_pais

El campo `country` puede contener varios paises en una sola celda.

Ejemplo:

- `Argentina, Brazil, France`

Por eso `dim_pais` no debe cargarse directo desde el valor completo. Antes hay que separar paises correctamente dentro del proceso ETL.

## 5. Decision sobre Neon

Neon se usa como PostgreSQL compartido del proyecto.

Ruta recomendada para trabajar contra Neon:

1. Crear scripts SQL reproducibles.
2. Crear la base o esquema compartido.
3. Ejecutar scripts estructurales.
4. Cargar tablas `staging`.
5. Ejecutar pipelines Hop contra Neon.
6. Validar resultados con SQL.

## 6. Alcance tecnologico actual

- Docker queda como opcion posterior.
- IA/MCP queda como apoyo extra, no como prioridad del proyecto.

## 7. Prioridades actuales

1. ETL correcta.
2. Base reproducible.
3. GitHub ordenado.
4. Neon controlado.
5. Documentacion clara.
6. Reportes y dashboard.
