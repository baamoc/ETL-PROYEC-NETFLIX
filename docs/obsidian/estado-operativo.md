# 001 - Documentación interna del proyecto DW Netflix

**Proyecto:** DW Netflix - Data Warehouse Streaming  
**Fecha base:** 2026-05-20  
**Última actualización operativa:** 2026-05-21  
**Propósito:** registrar de forma breve y ordenada el estado real del proyecto, las decisiones técnicas, los avances ETL y los próximos pasos, sin modificar la documentación oficial de entrega.

---

## 1. Contexto actual

El proyecto DW Netflix consiste en implementar un Data Warehouse para analizar usuarios, contenido e ingresos en una plataforma de streaming tipo Netflix.

Actualmente el equipo se encuentra trabajando en la segunda etapa del proyecto, correspondiente a los **procesos ETL**, usando Apache Hop como herramienta oficial para cargar datos desde archivos CSV hacia PostgreSQL.

La documentación oficial debe conservar su estructura de entrega. Este archivo funciona como documentación interna de trabajo y control operativo.

---

## 2. Herramientas oficiales

| Área | Herramienta | Uso |
|---|---|---|
| Base de datos | PostgreSQL | Motor del Data Warehouse |
| Base compartida | Neon PostgreSQL | Base en la nube para trabajo colaborativo |
| Cliente SQL | DBeaver | Validación, auditoría y consultas |
| ETL | Apache Hop | Carga y transformación oficial de datos |
| Control de versiones | GitHub | Repositorio del proyecto |

Regla importante: **DBeaver no se usa como herramienta ETL oficial**. DBeaver se usa para revisar, validar y ejecutar consultas SQL. Las cargas de datos deben realizarse mediante Apache Hop.

---

## 3. Arquitectura oficial del flujo de datos

```text
CSV Kaggle
   ↓
Apache Hop
   ↓
staging
   ↓
Apache Hop ETL
   ↓
dm_streaming
   ↓
Consultas OLAP
   ↓
Reportes
   ↓
Dashboard / KPIs
```

El esquema `staging` recibe los datos crudos provenientes de los CSV. El esquema `dm_streaming` contiene las dimensiones y hechos finales del Data Mart.

---

## 4. Estado actual de Neon

Neon ya cuenta con la estructura principal del Data Warehouse creada.

Se encuentran creados:

```text
staging
dm_streaming
```

Tablas staging:

```text
staging.stg_netflix_titles
staging.stg_netflix_userbase
```

Tablas finales:

```text
dm_streaming.dim_usuario
dm_streaming.dim_pais
dm_streaming.dim_tiempo
dm_streaming.dim_contenido
dm_streaming.dim_suscripcion
dm_streaming.dim_dispositivo
dm_streaming.fact_consumo
dm_streaming.fact_ingresos
```

También se validó la conexión a Neon y el encoding esperado:

```sql
SHOW server_encoding;
```

Resultado esperado:

```text
UTF8
```

---

## 5. Scripts SQL del proyecto

Scripts definidos para crear y validar la estructura:

| Script | Función |
|---|---|
| `01_create_schemas.sql` | Crea los esquemas `staging` y `dm_streaming` |
| `02_create_staging_tables.sql` | Crea las tablas staging |
| `03_create_dm_streaming_tables.sql` | Crea dimensiones y hechos |
| `04_validaciones_iniciales.sql` | Valida estructura inicial |
| `90_validaciones_finales.sql` | Validaciones posteriores a la carga ETL |

En Neon ya se ejecutaron los scripts de creación de estructura.

---

## 6. Repositorio y estructura de trabajo

Repositorio GitHub:

```text
https://github.com/baamoc/ETL-PROYEC-NETFLIX.git
```

Carpeta local del proyecto:

```text
D:\UNIVERSIDAD\BBDD\hopavance\proyecto
```

Estructura principal:

```text
sql/
pipelines/
workflows/
docs/
docs/evidencias/
dashboard/
data/
datasets/
```

Reglas de seguridad:

```text
No subir contraseñas.
No subir archivos .env reales.
No subir metadata/rdbms/.
No subir backups pesados.
No subir datasets grandes sin autorización.
```

---

## 7. Carga de CSV a staging con Apache Hop

Se decidió realizar la carga inicial de CSV hacia `staging` usando Apache Hop, no DBeaver.

### 7.1 Pipeline de carga de Netflix Titles

Pipeline creado:

```text
00_LOAD_STG_NETFLIX_TITLES.hpl
```

Flujo:

```text
CSV file input
   ↓
Select values
   ↓
Table output
```

Origen:

```text
NetFlix.csv
```

Destino:

```text
staging.stg_netflix_titles
```

Columnas esperadas:

```text
show_id
type
title
director
cast_members
country
date_added
release_year
rating
duration
genres
description
```

Transformación aplicada:

```text
cast → cast_members
```

Motivo: evitar conflicto o ambigüedad con el nombre `cast` en SQL.

Validación esperada:

```sql
SELECT COUNT(*) AS total_titles
FROM staging.stg_netflix_titles;
```

Resultado esperado:

```text
7787 registros
```

### 7.2 Corrección por duplicación de carga

Durante las pruebas, el pipeline de `Netflix Titles` fue ejecutado más de una vez y se duplicaron datos en `staging.stg_netflix_titles`.

Problema identificado:

```text
El Table output insertaba nuevamente todos los registros cada vez que se ejecutaba el pipeline.
```

Corrección aplicada/recomendada:

```text
Activar Truncate table = YES en el paso Table output del pipeline de carga a staging.
```

Regla: esta opción solo debe usarse en pipelines de carga inicial hacia `staging`, no en dimensiones ni hechos de `dm_streaming`.

---

## 8. Carga de Netflix Userbase con Apache Hop

Pipeline creado:

```text
00_LOAD_STG_NETFLIX_USERBASE.hpl
```

Flujo:

```text
CSV file input
   ↓
Select values
   ↓
Table output
```

Origen:

```text
Netflix Userbase.csv
```

Destino:

```text
staging.stg_netflix_userbase
```

Columnas esperadas en staging:

```text
"User ID"
"Subscription Type"
"Monthly Revenue"
"Join Date"
"Last Payment Date"
country
age
gender
device
"Plan Duration"
```

Renombramientos aplicados:

| CSV | staging |
|---|---|
| `Country` | `country` |
| `Age` | `age` |
| `Gender` | `gender` |
| `Device` | `device` |

---

## 9. Error corregido en carga de Userbase

Durante la ejecución del pipeline `00_LOAD_STG_NETFLIX_USERBASE.hpl`, PostgreSQL rechazó la carga porque las columnas de fecha en la tabla staging eran de tipo `date`, pero Hop estaba enviando texto.

Error principal:

```text
ERROR: column "Join Date" is of type date but expression is of type character varying
```

Causa:

```text
Hop estaba leyendo "Join Date" y "Last Payment Date" como String.
PostgreSQL esperaba valores de tipo Date.
```

Corrección aplicada en Apache Hop:

| Campo | Tipo en Hop | Formato |
|---|---|---|
| `Join Date` | Date | `dd-MM-yy` |
| `Last Payment Date` | Date | `dd-MM-yy` |

Después de esta corrección, el pipeline se ejecutó correctamente.

Validación esperada:

```sql
SELECT COUNT(*) AS total_userbase
FROM staging.stg_netflix_userbase;
```

Resultado esperado:

```text
2500 registros
```

---

## 10. Validaciones realizadas después de cargar staging

Validar cantidad de títulos:

```sql
SELECT COUNT(*) AS total_titles
FROM staging.stg_netflix_titles;
```

Validar cantidad de usuarios:

```sql
SELECT COUNT(*) AS total_userbase
FROM staging.stg_netflix_userbase;
```

Validar dispositivos:

```sql
SELECT DISTINCT device
FROM staging.stg_netflix_userbase
ORDER BY device;
```

Resultado esperado:

```text
Laptop
Smart TV
Smartphone
Tablet
```

Validar tipos de suscripción:

```sql
SELECT DISTINCT
    "Subscription Type",
    "Plan Duration"
FROM staging.stg_netflix_userbase
ORDER BY "Subscription Type", "Plan Duration";
```

Resultado esperado:

```text
Basic | 1 Month
Premium | 1 Month
Standard | 1 Month
```

---

## 11. Valores NULL en Netflix Titles

Se identificaron valores `NULL` en algunos campos de `staging.stg_netflix_titles`. Esto no representa un error del pipeline, ya que los datos faltantes provienen del CSV original.

Campos con valores faltantes en el CSV original:

| Campo | Valores faltantes |
|---|---:|
| `director` | 2389 |
| `cast` / `cast_members` | 718 |
| `country` | 507 |
| `date_added` | 10 |
| `rating` | 7 |

Validación recomendada:

```sql
SELECT
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE director IS NULL) AS director_null,
    COUNT(*) FILTER (WHERE cast_members IS NULL) AS cast_members_null,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_null,
    COUNT(*) FILTER (WHERE date_added IS NULL) AS date_added_null,
    COUNT(*) FILTER (WHERE rating IS NULL) AS rating_null
FROM staging.stg_netflix_titles;
```

Decisión: los `NULL` se conservan en `staging` porque esta capa almacena datos crudos. El tratamiento de nulos se realizará posteriormente en los pipelines hacia `dm_streaming`.

---

## 12. Carga de dimensión dispositivo en Neon

Pipeline ejecutado y validado:

```text
01_ETL_DIM_DISPOSITIVO.hpl
```

Flujo usado:

```text
Table input
   ↓
Select values
   ↓
String operations
   ↓
Filter rows
   ↓
Sort rows
   ↓
Unique rows
   ↓
Insert / update
```

Origen:

```text
staging.stg_netflix_userbase.device
```

Destino:

```text
dm_streaming.dim_dispositivo.nombre_dispositivo
```

Configuraciones importantes:

```text
String operations: Trim type = both sobre nombre_dispositivo.
Filter rows: nombre_dispositivo IS NOT NULL.
Insert / update: búsqueda por nombre_dispositivo.
No se inserta id_dispositivo manualmente.
```

Resultado validado en DBeaver:

```text
Laptop
Smart TV
Smartphone
Tablet
```

Consulta de validación:

```sql
SELECT *
FROM dm_streaming.dim_dispositivo
ORDER BY id_dispositivo;
```

Estado: la dimensión `dim_dispositivo` quedó cargada correctamente en Neon.

---

## 13. Estado actual real del avance

Completado:

```text
Conexión a Neon validada.
Esquemas creados.
Tablas staging creadas.
Tablas dm_streaming creadas.
00_LOAD_STG_NETFLIX_TITLES.hpl creado, ejecutado y validado.
Duplicados en titles detectados y controlados usando Truncate table en staging.
00_LOAD_STG_NETFLIX_USERBASE.hpl creado, ejecutado y validado.
Error de fechas corregido con tipo Date y formato dd-MM-yy.
Valores NULL de Netflix Titles identificados como datos faltantes del CSV original.
01_ETL_DIM_DISPOSITIVO.hpl ejecutado contra Neon y validado en DBeaver.
```

Pendiente inmediato:

```text
Guardar evidencias de los pipelines terminados.
Crear 02_ETL_DIM_SUSCRIPCION.hpl.
Validar dm_streaming.dim_suscripcion.
Luego continuar con dim_usuario, dim_tiempo, dim_pais y dim_contenido.
```

---

## 14. Próximo orden recomendado

1. Guardar evidencia de `00_LOAD_STG_NETFLIX_TITLES.hpl`.
2. Guardar evidencia de `00_LOAD_STG_NETFLIX_USERBASE.hpl`.
3. Guardar evidencia de `01_ETL_DIM_DISPOSITIVO.hpl`.
4. Crear el pipeline:

```text
02_ETL_DIM_SUSCRIPCION.hpl
```

Origen esperado:

```text
staging.stg_netflix_userbase
```

Campos origen:

```text
"Subscription Type"
"Plan Duration"
```

Destino:

```text
dm_streaming.dim_suscripcion
```

Campos destino:

```text
tipo_suscripcion
duracion_plan
```

Flujo recomendado:

```text
Table input
   ↓
Select values
   ↓
String operations
   ↓
Filter rows
   ↓
Sort rows
   ↓
Unique rows
   ↓
Insert / update
```

Regla: no insertar manualmente `id_suscripcion`, porque PostgreSQL lo genera automáticamente.

Validación esperada:

```sql
SELECT *
FROM dm_streaming.dim_suscripcion
ORDER BY id_suscripcion;
```

Resultado esperado:

```text
Basic | 1 Month
Premium | 1 Month
Standard | 1 Month
```

---

## 15. Reglas obligatorias para continuar

```text
No insertar manualmente en dm_streaming.
No tocar hechos hasta validar dimensiones.
No ejecutar DROP, DELETE ni TRUNCATE sin autorización.
Todo pipeline debe partir desde staging.
Todo cambio estructural debe ir en script SQL.
Todo pipeline debe tener evidencia.
Todo cambio debe subirse a GitHub.
```

---

## 16. Evidencia mínima por pipeline

Por cada pipeline se debe guardar:

```text
Archivo .hpl
Captura del pipeline completo
Capturas de configuración de pasos importantes
Log de ejecución
Consulta SQL de validación
Captura del resultado de validación
```

Carpeta sugerida:

```text
docs/evidencias/
```
