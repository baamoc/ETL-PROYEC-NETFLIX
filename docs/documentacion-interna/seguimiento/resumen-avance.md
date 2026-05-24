# Resumen de avance del proyecto DW Netflix

Resumen corto y operativo del estado real del proyecto para continuar rapido sin recorrer toda la documentacion historica.

## Fecha de corte

- 2026-05-24

## Estado general

- El proyecto ya tiene `staging` y `dm_streaming` definidos.
- La carga inicial de ambos datasets a `staging` ya esta hecha.
- El equipo ya completo y valido los pipelines `01`, `02`, `03`, `04` y `05`.

## Base y datos cargados

| Tema | Estado actual |
| --- | --- |
| Base local | `dw_netflix` |
| Esquemas | `staging`, `dm_streaming` |
| Encoding esperado | `UTF8` |
| `staging.stg_netflix_titles` | `7787` registros |
| `staging.stg_netflix_userbase` | `2500` registros |
| Base compartida | Neon operativa |

## Estado de pipelines

| Pipeline                           | Estado    | Nota breve                                                    |
| ---------------------------------- | --------- | ------------------------------------------------------------- |
| `00_LOAD_STG_NETFLIX_TITLES.hpl`   | Creado    | Carga `NetFlix.csv` a `staging.stg_netflix_titles`            |
| `00_LOAD_STG_NETFLIX_USERBASE.hpl` | Creado    | Carga `Netflix Userbase.csv` a `staging.stg_netflix_userbase` |
| `01_ETL_DIM_DISPOSITIVO.hpl`       | Validado  | Carga 4 dispositivos unicos                                   |
| `02_ETL_DIM_SUSCRIPCION.hpl`       | Validado  | Carga 3 tipos de suscripcion                                  |
| `03_ETL_DIM_USUARIO.hpl`           | Validado  | Carga `2500` usuarios                                         |
| `04_ETL_DIM_TIEMPO.hpl`            | Validado  | Carga `1837` fechas unicas en `dm_streaming.dim_tiempo`       |
| `05_ETL_DIM_PAIS.hpl`              | Validado  | Carga `117` países únicos separando países múltiples          |
| `06_ETL_DIM_CONTENIDO.hpl`         | Pendiente | Sin cierre documentado                                        |
| `07_ETL_FACT_INGRESOS.hpl`         | Pendiente | Sin cierre documentado                                        |
| `08_ETL_FACT_CONSUMO.hpl`          | Pendiente | Requiere logica simulada/controlada                           |
| `00_RUN_ETL_COMPLETO.hwf`          | Pendiente | Workflow final                                                |

## Dimensiones ya resueltas

### 01_ETL_DIM_DISPOSITIVO

- Origen: `staging.stg_netflix_userbase.device`
- Destino: `dm_streaming.dim_dispositivo.nombre_dispositivo`
- Resultado validado: `Laptop`, `Smart TV`, `Smartphone`, `Tablet`

### 02_ETL_DIM_SUSCRIPCION

- Origen: `staging.stg_netflix_userbase`
- Destino: `dm_streaming.dim_suscripcion`
- Resultado validado: `3` registros finales

### 03_ETL_DIM_USUARIO

- Origen: `staging.stg_netflix_userbase`
- Destino: `dm_streaming.dim_usuario`
- Resultado validado: `2500` usuarios

### 04_ETL_DIM_TIEMPO

- Origen: fechas de `staging.stg_netflix_userbase` y `staging.stg_netflix_titles`
- Destino: `dm_streaming.dim_tiempo`
- Resultado validado: `1837` filas y `1837` fechas unicas
- Validacion de calidad: `0` filas con nulos en `fecha_completa`, `dia`, `mes` o `anio`

## Riesgos abiertos

- `dim_pais` no puede cargarse directo si el campo `country` trae varios paises en una sola fila.
- `fact_consumo` no tiene relacion natural directa entre datasets y necesitara una logica controlada.



### 05_ETL_DIM_PAIS  
  
- Origen: `staging.stg_netflix_userbase.country` y `staging.stg_netflix_titles.country`  
- Destino: `dm_streaming.dim_pais.nombre_pais`  
- Transformación principal: separación de países múltiples por coma desde `stg_netflix_titles.country`  
- Resultado validado: `117` países únicos  
- Validación de calidad: `0` duplicados  
- Validación de calidad: `0` países nulos o vacíos


## Siguiente paso recomendado

1. Continuar con `06_ETL_DIM_CONTENIDO.hpl`.
2. Validar previamente la estructura de `staging.stg_netflix_titles`.
3. Mantener primero el bloque de dimensiones estable antes de pasar a hechos.
4. No tocar `fact_ingresos` ni `fact_consumo` hasta cerrar `dim_contenido`.
