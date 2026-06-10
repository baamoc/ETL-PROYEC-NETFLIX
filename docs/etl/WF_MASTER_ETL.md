# WF_MASTER_ETL

## Propósito

Workflow maestro que ejecuta el proceso ETL completo del Data Mart `dm_streaming` con un solo clic. Trunca todas las tablas del DM y luego carga las seis dimensiones y las dos tablas de hechos en orden estricto de dependencia.

## Secuencia de ejecución

| Orden | Acción | Tipo | Descripción |
|-------|--------|------|-------------|
| 1 | `Start` | SPECIAL | Punto de inicio del workflow |
| 2 | `UTIL_TRUNCATE_DM` | PIPELINE | Trunca todas las tablas del DM con CASCADE antes de recargar |
| 3 | `01_ETL_DIM_SUSCRIPCION` | PIPELINE | Carga la dimensión `dim_suscripcion` |
| 4 | `02_ETL_DIM_USUARIO` | PIPELINE | Carga la dimensión `dim_usuario` |
| 5 | `03_ETL_DIM_PAIS` | PIPELINE | Carga la dimensión `dim_pais` |
| 6 | `04_ETL_DIM_TIEMPO` | PIPELINE | Carga la dimensión `dim_tiempo` |
| 7 | `05_ETL_DIM_DISPOSITIVO` | PIPELINE | Carga la dimensión `dim_dispositivo` |
| 8 | `06_ETL_DIM_CONTENIDO` | PIPELINE | Carga la dimensión `dim_contenido` |
| 9 | `07_ETL_FACT_INGRESOS` | PIPELINE | Carga la tabla de hechos `fact_ingresos` |
| 10 | `08_ETL_FACT_CONSUMO` | PIPELINE | Carga la tabla de hechos `fact_consumo` |

## Tipo de hops

| Hop | Tipo | Comportamiento |
|-----|------|----------------|
| `Start` → `UTIL_TRUNCATE_DM` | Unconditional (`unconditional=Y`) | Se ejecuta siempre, sin evaluar resultado previo |
| `UTIL_TRUNCATE_DM` → `01_ETL_DIM_SUSCRIPCION` | On-success (`unconditional=N`, `evaluation=Y`) | Continúa solo si el paso anterior tuvo éxito |
| Todos los demás hops | On-success (`unconditional=N`, `evaluation=Y`) | Cada paso solo inicia si el anterior finalizó correctamente |

La cadena de on-success garantiza que si cualquier pipeline falla, el workflow se detiene y no ejecuta los pasos siguientes. Esto protege la integridad referencial: los hechos no se cargan si alguna dimensión falló.

## Configuración de ejecución

- **Run configuration**: `local` en todos los pipelines
- **wait_until_finished**: `Y` en todos los pipelines (ejecución estrictamente secuencial)
- **loglevel**: `Basic` en todos los pipelines
- **pass_all_parameters**: `N` (cada pipeline es autónomo, sin parámetros heredados del workflow)
- **Rutas de pipelines**: resueltas mediante la variable `${PROJECT_HOME}`, por ejemplo `${PROJECT_HOME}/pipelines/01_ETL_DIM_SUSCRIPCION.hpl`

## Duración total observada

~85 segundos (1 minuto 24 segundos) en ejecución completa sobre la conexión PostgreSQL en Neon (`Proyecto-Neonbd`).
