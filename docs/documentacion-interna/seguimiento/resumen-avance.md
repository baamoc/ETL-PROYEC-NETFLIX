# Resumen de avance del proyecto DW Netflix

Resumen corto y operativo del estado real del proyecto para continuar rapido sin recorrer toda la documentacion historica.

## Fecha de corte

- 2026-05-25

## Estado general

- El proyecto ya tiene `staging` y `dm_streaming` definidos.
- La carga inicial de ambos datasets a `staging` ya esta hecha.
- El equipo ya completo y valido los pipelines `01`, `02`, `03`, `04`, `05`, `06`, `07` y `08`.

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
| `06_ETL_DIM_CONTENIDO.hpl`         | Validado  | Carga `7787` contenidos sin duplicados ni faltantes          |
| `07_ETL_FACT_INGRESOS.hpl`         | Validado  | Carga `2500` hechos con total `31271.00` y sin duplicados     |
| `08_ETL_FACT_CONSUMO.hpl`          | Validado  | Carga `2500` consumos simulados y `7500` visualizaciones      |
| `00_RUN_ETL_COMPLETO.hwf`          | Pendiente | Workflow final                                                |

## Dimensiones y hechos validados

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

### 05_ETL_DIM_PAIS  
  
- Origen: `staging.stg_netflix_userbase.country` y `staging.stg_netflix_titles.country`  
- Destino: `dm_streaming.dim_pais.nombre_pais`  
- Transformación principal: separación de países múltiples por coma desde `stg_netflix_titles.country`  
- Resultado validado: `117` países únicos  
- Validación de calidad: `0` duplicados  
- Validación de calidad: `0` países nulos o vacíos

### 06_ETL_DIM_CONTENIDO

- Origen: `staging.stg_netflix_titles`
- Destino: `dm_streaming.dim_contenido`
- Clave de carga: `id_contenido` a partir de `show_id`
- Flujo principal: renombrado de campos, limpieza de texto, filtro de nulos, ordenamiento, deduplicacion e `Insert / update`
- Resultado validado: `7787` filas y `7787` IDs unicos
- Validacion de calidad: `0` duplicados
- Validacion de calidad: `0` IDs faltantes respecto a `staging.stg_netflix_titles`
- Validacion de calidad: `0` nulos o vacios en `id_contenido`, `titulo` y `tipo_contenido`
- Distribucion validada: `5377` `Movie` y `2410` `TV Show`

### 07_ETL_FACT_INGRESOS

- Origen: `staging.stg_netflix_userbase`
- Dimensiones enlazadas: `dim_usuario`, `dim_suscripcion`, `dim_dispositivo`, `dim_pais`, `dim_tiempo`
- Destino: `dm_streaming.fact_ingresos`
- Grano: una fila por combinacion de `id_usuario`, `id_suscripcion`, `id_dispositivo`, `id_pais`, `id_tiempo`
- Medida principal: `ingreso_mensual`
- Resultado validado: `2500` filas
- Validacion de calidad: `2500` combinaciones unicas y `0` duplicados
- Validacion de calidad: `0` filas con nulos en claves o en `ingreso_mensual`
- Validacion de conciliacion: ingreso total `31271.00`
- Validacion de correspondencia: `0` usuarios sin match entre `staging.stg_netflix_userbase` y `dm_streaming.dim_usuario`

### 08_ETL_FACT_CONSUMO

- Origen: `staging.stg_netflix_userbase`
- Dimensiones enlazadas: `dim_usuario`, `dim_contenido`, `dim_pais`, `dim_tiempo`
- Destino: `dm_streaming.fact_consumo`
- Grano: una fila por combinacion de `id_usuario`, `id_contenido`, `id_pais`, `id_tiempo`
- Logica controlada: `1 usuario = 1 consumo simulado`
- Asignacion de contenido: rotacion controlada sobre `dim_contenido` segun el orden de `id_contenido`
- Medida principal: `cantidad_visualizaciones`
- Regla de generacion: `((User ID - 1) % 5) + 1`
- Resultado validado: `2500` filas
- Validacion de calidad: `2500` combinaciones unicas y `0` duplicados
- Validacion de calidad: `0` filas con nulos en claves o en `cantidad_visualizaciones`
- Validacion de conciliacion: `7500` visualizaciones totales
- Distribucion validada: `500` filas por cada valor de `cantidad_visualizaciones` entre `1` y `5`

## Riesgos abiertos

- `dim_pais` no puede cargarse directo si el campo `country` trae varios paises en una sola fila.
- `fact_consumo` no tiene relacion natural directa entre datasets; por eso se resolvio con una logica simulada/controlada que debe mantenerse documentada.


## Siguiente paso recomendado

1. Construir y validar `00_RUN_ETL_COMPLETO.hwf`.
2. Mantener primero el bloque de hechos con validacion documentada en cada cierre.
3. Si se ajusta `fact_consumo`, conservar documentada la logica simulada/controlada.
