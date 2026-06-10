# ETL Netflix — Documentación Técnica

## Contexto del proyecto

Este proyecto implementa un Data Warehouse para analizar el catálogo y la base de usuarios de Netflix. Los datos provienen de dos archivos CSV cargados en un esquema de staging en PostgreSQL. El proceso ETL fue desarrollado con Apache Hop y carga un Data Mart estrella en el esquema `dm_streaming` de una base de datos PostgreSQL alojada en Neon.

- **Herramienta ETL**: Apache Hop
- **Base de datos**: PostgreSQL (Neon) — conexión `Proyecto-Neonbd`
- **Esquema staging**: `staging` (datos crudos, sin transformar)
- **Esquema destino**: `dm_streaming` (Data Mart estrella)

## Arquitectura del Data Mart

### Esquema staging — fuentes de datos

El esquema `staging` contiene las tablas intermedias cargadas directamente desde los CSV originales, sin transformaciones. Sirven como única fuente de verdad para todos los pipelines ETL.

| Tabla staging | Dataset origen | Registros |
|---------------|---------------|-----------|
| `stg_netflix_userbase` | `Netflix Userbase.csv` | 2500 |
| `stg_netflix_titles` | `NetFlix.csv` | ~8000 |

### Esquema dm_streaming — Data Mart estrella

El esquema `dm_streaming` implementa un modelo estrella con seis dimensiones y dos tablas de hechos.

### Tablas del Data Mart

| Tabla | Tipo | Registros cargados | Descripción |
|-------|------|--------------------|-------------|
| `dim_suscripcion` | Dimensión | 3 | Tipos de plan: Basic, Standard y Premium |
| `dim_usuario` | Dimensión | 2500 | Datos demográficos y de cuenta de cada usuario |
| `dim_pais` | Dimensión | 10 | Países únicos de los usuarios |
| `dim_tiempo` | Dimensión | 1822 | Fechas únicas del dataset con atributos de calendario |
| `dim_dispositivo` | Dimensión | 4 | Dispositivos de acceso: Laptop, Smartphone, Smart TV, Tablet |
| `dim_contenido` | Dimensión | 7787 | Títulos del catálogo Netflix con tipo, género y duración |
| `fact_ingresos` | Hecho | 2500 | Ingreso mensual por usuario con sus FKs dimensionales |
| `fact_consumo` | Hecho | 5000 | Eventos de consumo derivados del cruce usuario-título por país |

## Pipelines ETL

| Pipeline | Tabla destino | Descripción |
|----------|--------------|-------------|
| `UTIL_TRUNCATE_DM` | — | Trunca todas las tablas del DM con CASCADE antes de cada carga completa |
| `01_ETL_DIM_SUSCRIPCION` | `dim_suscripcion` | Extrae los tres tipos de suscripción únicos desde userbase |
| `02_ETL_DIM_USUARIO` | `dim_usuario` | Carga los 2500 usuarios con normalización de nombres y fechas |
| `03_ETL_DIM_PAIS` | `dim_pais` | Deduplica los 10 países únicos del dataset de usuarios |
| `04_ETL_DIM_TIEMPO` | `dim_tiempo` | Genera la dimensión calendario a partir de las fechas del dataset |
| `05_ETL_DIM_DISPOSITIVO` | `dim_dispositivo` | Deduplica los cuatro tipos de dispositivo del dataset |
| `06_ETL_DIM_CONTENIDO` | `dim_contenido` | Carga los ~7787 títulos del catálogo con sus atributos |
| `07_ETL_FACT_INGRESOS` | `fact_ingresos` | Une userbase con 4 dimensiones via StreamLookup; carga 2500 hechos de ingreso |
| `08_ETL_FACT_CONSUMO` | `fact_consumo` | Cruza usuarios y títulos por país; carga 5000 hechos de consumo |

## Workflow maestro

`WF_MASTER_ETL` ejecuta los 9 pipelines en secuencia estricta mediante hops on-success. Si cualquier pipeline falla, el workflow se detiene para proteger la integridad referencial. Duración total observada: ~85 segundos (1 minuto 24 segundos).

Orden de ejecución: `UTIL_TRUNCATE_DM` → dimensiones (01 a 06) → hechos (07 y 08).

## Fuentes de datos

| Dataset | Tabla staging | Registros |
|---------|--------------|-----------|
| `Netflix Userbase.csv` | `staging.stg_netflix_userbase` | 2500 |
| `NetFlix.csv` | `staging.stg_netflix_titles` | ~8000 |

## Índice de documentación

- [UTIL_TRUNCATE_DM](UTIL_TRUNCATE_DM.md)
- [01 - DIM Suscripcion](01_ETL_DIM_SUSCRIPCION.md)
- [02 - DIM Usuario](02_ETL_DIM_USUARIO.md)
- [03 - DIM Pais](03_ETL_DIM_PAIS.md)
- [04 - DIM Tiempo](04_ETL_DIM_TIEMPO.md)
- [05 - DIM Dispositivo](05_ETL_DIM_DISPOSITIVO.md)
- [06 - DIM Contenido](06_ETL_DIM_CONTENIDO.md)
- [07 - FACT Ingresos](07_ETL_FACT_INGRESOS.md)
- [08 - FACT Consumo](08_ETL_FACT_CONSUMO.md)
- [Workflow Master](WF_MASTER_ETL.md)
