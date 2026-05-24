# DW Netflix - Data Warehouse Streaming

Proyecto de Base de Datos 3 orientado al diseno e implementacion de un Data Warehouse para analizar usuarios, contenido, suscripciones, dispositivos, tiempo e ingresos en una plataforma de streaming tipo Netflix.

## Estado actual

- `staging.stg_netflix_titles` cargada y validada con `7787` registros.
- `staging.stg_netflix_userbase` cargada y validada con `2500` registros.
- ETL completadas y validadas: `01_ETL_DIM_DISPOSITIVO.hpl`, `02_ETL_DIM_SUSCRIPCION.hpl`, `03_ETL_DIM_USUARIO.hpl`, `04_ETL_DIM_TIEMPO.hpl`.
- Pendientes funcionales: `05_ETL_DIM_PAIS.hpl`, `06_ETL_DIM_CONTENIDO.hpl`, `07_ETL_FACT_INGRESOS.hpl`, `08_ETL_FACT_CONSUMO.hpl`, `00_RUN_ETL_COMPLETO.hwf`.

## Objetivo

Construir un Data Warehouse reproducible y documentado que permita responder preguntas como estas:

- distribucion de usuarios por edad, genero y pais
- ingresos por tipo de suscripcion
- uso de dispositivos
- evolucion temporal del contenido y de los ingresos
- analisis posterior de hechos de consumo e ingresos

## Arquitectura de datos

```text
CSV Kaggle
   -> staging
   -> Apache Hop ETL
   -> dm_streaming
   -> Consultas OLAP / Reportes / Dashboard
```

## Herramientas oficiales

| Area | Herramienta | Uso |
| --- | --- | --- |
| Base de datos | PostgreSQL | Motor principal del DW |
| Base compartida | Neon PostgreSQL | Trabajo colaborativo |
| Cliente SQL | DBeaver | Validacion y consultas |
| ETL | Apache Hop | Carga y transformacion |
| Versionado | Git / GitHub | Trabajo en equipo |

Regla clave: DBeaver no se usa como herramienta ETL. Las cargas al modelo final se hacen con Apache Hop.

## Estructura funcional actual

### staging

- `staging.stg_netflix_titles`
  Campos principales: `show_id`, `type`, `title`, `director`, `cast_members`, `country`, `date_added`, `release_year`, `rating`, `duration`, `genres`, `description`.
- `staging.stg_netflix_userbase`
  Campos principales: `"User ID"`, `"Subscription Type"`, `"Monthly Revenue"`, `"Join Date"`, `"Last Payment Date"`, `country`, `age`, `gender`, `device`, `"Plan Duration"`.

### dm_streaming

Dimensiones actuales:

- `dim_usuario`
- `dim_pais`
- `dim_tiempo`
- `dim_contenido`
- `dim_suscripcion`
- `dim_dispositivo`

Tablas de hechos actuales:

- `fact_consumo`
- `fact_ingresos`

## Estado ETL por pipeline

| Pipeline | Estado | Observacion |
| --- | --- | --- |
| `00_LOAD_STG_NETFLIX_TITLES.hpl` | Creado | Carga inicial a `staging.stg_netflix_titles` |
| `00_LOAD_STG_NETFLIX_USERBASE.hpl` | Creado | Carga inicial a `staging.stg_netflix_userbase` |
| `01_ETL_DIM_DISPOSITIVO.hpl` | Validado | Resultado final de 4 dispositivos unicos |
| `02_ETL_DIM_SUSCRIPCION.hpl` | Validado | Resultado final de 3 tipos de suscripcion |
| `03_ETL_DIM_USUARIO.hpl` | Validado | Resultado final de `2500` usuarios |
| `04_ETL_DIM_TIEMPO.hpl` | Validado | Carga `1837` fechas unicas en `dm_streaming.dim_tiempo` |
| `05_ETL_DIM_PAIS.hpl` | Pendiente | Requiere separar multiples paises por fila |
| `06_ETL_DIM_CONTENIDO.hpl` | Pendiente | No iniciado en esta documentacion |
| `07_ETL_FACT_INGRESOS.hpl` | Pendiente | No iniciado en esta documentacion |
| `08_ETL_FACT_CONSUMO.hpl` | Pendiente | Requiere logica simulada/controlada |
| `00_RUN_ETL_COMPLETO.hwf` | Pendiente | Orquestacion final |

## Documentacion util

- `docs/documentacion-interna/indice.md` -> mapa rapido de la documentacion interna
- `docs/documentacion-interna/guias/` -> uso del espacio documental y colaboracion
- `docs/documentacion-interna/reglas/` -> reglas y decisiones del proyecto
- `docs/documentacion-interna/seguimiento/` -> resumen operativo y registros por fecha
- `docs/documentacion-interna/referencias/documentacion-interna-completa.md` -> referencia interna consolidada
- `docs/informe-oficial/Netflix-Estructura-del-proyecto.md` -> informe base de la primera presentacion

## Reglas operativas clave

- no insertar manualmente en `dm_streaming`
- todo pipeline debe partir de `staging`
- `staging` puede conservar nombres crudos del CSV
- `dm_streaming` debe usar nombres limpios y orientados al analisis
- no modificar tablas finales sin aprobacion
- las transformaciones de Hop deben tener nombres descriptivos

## Riesgos conocidos

- `dim_pais` no puede cargarse directo desde `country` cuando hay multiples paises en una misma celda.
- `fact_consumo` no tiene relacion natural directa entre los datasets y necesitara una logica controlada y documentada.

## Proximo paso recomendado

1. Continuar con `05_ETL_DIM_PAIS.hpl`.
2. Dejar listo el bloque de dimensiones antes de pasar a hechos.
3. Mantener la validacion documental al dia en `docs/documentacion-interna/seguimiento/registros/`.
