# Documentacion interna consolidada del proyecto DW Netflix

Este archivo resume el estado tecnico y operativo real del proyecto para que cualquier integrante del equipo pueda ubicarse rapido sin recorrer toda la documentacion.

## 1. Contexto del proyecto

El proyecto consiste en construir un Data Warehouse sobre datos de Netflix para analizar usuarios, contenido, suscripciones, dispositivos, tiempo e ingresos.

La arquitectura oficial se mantiene asi:

```text
CSV Kaggle
   -> staging
   -> Apache Hop ETL
   -> dm_streaming
   -> Consultas OLAP / Reportes / Dashboard
```

Herramientas oficiales:

- PostgreSQL
- Neon PostgreSQL
- DBeaver
- Apache Hop
- GitHub

Regla clave: DBeaver sirve para validar y consultar. La carga al modelo final se hace con Apache Hop.

## 2. Estado actual verificado

| Tema | Estado actual |
| --- | --- |
| Base local | `dw_netflix` |
| Esquemas principales | `staging`, `dm_streaming` |
| Encoding esperado | `UTF8` |
| Base compartida | Neon operativa |
| `stg_netflix_titles` | `7787` registros |
| `stg_netflix_userbase` | `2500` registros |
| ETL validadas | `01`, `02`, `03`, `04` |

## 3. Fuentes y tablas base

Datasets usados:

- `datasets/NetFlix.csv`
- `datasets/Netflix Userbase.csv`

Tablas staging:

- `staging.stg_netflix_titles`
- `staging.stg_netflix_userbase`

Tablas finales previstas en `dm_streaming`:

Dimensiones:

- `dim_usuario`
- `dim_pais`
- `dim_tiempo`
- `dim_contenido`
- `dim_suscripcion`
- `dim_dispositivo`

Hechos:

- `fact_consumo`
- `fact_ingresos`

## 4. Estado de pipelines

| Pipeline | Estado | Resumen |
| --- | --- | --- |
| `00_LOAD_STG_NETFLIX_TITLES.hpl` | Creado | Carga `NetFlix.csv` a `staging.stg_netflix_titles` |
| `00_LOAD_STG_NETFLIX_USERBASE.hpl` | Creado | Carga `Netflix Userbase.csv` a `staging.stg_netflix_userbase` |
| `01_ETL_DIM_DISPOSITIVO.hpl` | Validado | Carga 4 dispositivos unicos a `dim_dispositivo` |
| `02_ETL_DIM_SUSCRIPCION.hpl` | Validado | Carga 3 combinaciones a `dim_suscripcion` |
| `03_ETL_DIM_USUARIO.hpl` | Validado | Carga `2500` usuarios a `dim_usuario` |
| `04_ETL_DIM_TIEMPO.hpl` | Validado | Lee fechas desde `titles` y `userbase` y cargo `1837` fechas unicas en `dim_tiempo` |
| `05_ETL_DIM_PAIS.hpl` | Pendiente | Debe resolver paises multiples por fila |
| `06_ETL_DIM_CONTENIDO.hpl` | Pendiente | No documentado aun |
| `07_ETL_FACT_INGRESOS.hpl` | Pendiente | No documentado aun |
| `08_ETL_FACT_CONSUMO.hpl` | Pendiente | Requiere logica simulada/controlada |
| `00_RUN_ETL_COMPLETO.hwf` | Pendiente | Workflow final |

Notas verificadas:

- `02_ETL_DIM_SUSCRIPCION.hpl` tiene validacion documentada con `3` registros finales.
- `03_ETL_DIM_USUARIO.hpl` tiene validacion documentada con `2500` registros finales.
- `04_ETL_DIM_TIEMPO.hpl` quedo validado con `1837` filas, `1837` fechas unicas y sin nulos en los campos principales.

## 5. Estado documental actual

La documentacion interna quedo ordenada asi:

- `docs/documentacion-interna/indice.md` -> entrada principal
- `docs/documentacion-interna/guias/` -> uso y colaboracion
- `docs/documentacion-interna/reglas/` -> decisiones y reglas del equipo
- `docs/documentacion-interna/seguimiento/resumen-avance.md` -> resumen corto del estado operativo
- `docs/documentacion-interna/seguimiento/registros/` -> registros por fecha
- `docs/documentacion-interna/referencias/` -> consigna, informe oficial y este consolidado
- `docs/informe-oficial/` -> informe base e imagenes del modelo

## 6. Reglas clave para continuar

- No cargar manualmente `dm_streaming`.
- Todo pipeline ETL debe salir desde `staging`.
- `staging` puede conservar nombres crudos del CSV.
- `dm_streaming` debe mantener nombres limpios y orientados al analisis.
- Las transformaciones de Apache Hop deben tener nombres descriptivos.
- No modificar tablas finales ni estructura sin acuerdo del equipo.

## 7. Riesgos y pendientes importantes

### dim_pais

El campo `country` puede traer multiples paises en una sola celda. Antes de cargar `dim_pais`, esos valores deben separarse correctamente.

### fact_consumo

No existe una relacion natural directa entre `NetFlix.csv` y `Netflix Userbase.csv`. La tabla `fact_consumo` necesitara una logica simulada o controlada y eso debe quedar documentado.

## 8. Proximo paso recomendado

1. Construir `05_ETL_DIM_PAIS.hpl` resolviendo paises multiples.
2. Continuar con `06_ETL_DIM_CONTENIDO.hpl`.
3. Cerrar dimensiones antes de pasar a hechos y workflow final.
