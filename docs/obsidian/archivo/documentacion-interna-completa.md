# Documentación interna del proyecto DW Netflix

**Proyecto:** DW Netflix - Data Warehouse Streaming  
**Fecha base:** 2026-05-20  
**Propósito del documento:** reunir en un solo archivo la información operativa, técnica y colaborativa más importante del proyecto, sin modificar la documentación oficial de entrega.

---

## 1. Contexto general del proyecto

El proyecto DW Netflix consiste en el diseño e implementación de un Data Warehouse orientado al análisis de usuarios, contenido e ingresos en una plataforma de streaming tipo Netflix.

Actualmente, el proyecto se encuentra en una etapa de preparación e implementación técnica para trabajar de forma colaborativa con GitHub, Neon PostgreSQL, Apache Hop y DBeaver. La prioridad es dejar una estructura ordenada, reproducible y segura, de manera que cualquier integrante del equipo pueda continuar el desarrollo sin depender de una sola computadora local y sin alterar incorrectamente la base de datos.

El trabajo actual se concentra principalmente en la parte de implementación física y procesos ETL, es decir, en cargar los datos desde los archivos CSV hacia tablas staging, transformarlos mediante Apache Hop y llevarlos finalmente al esquema analítico `dm_streaming`.

---

## 2. Herramientas oficiales del proyecto

Las herramientas definidas para el desarrollo del proyecto son las siguientes:

| Área | Herramienta oficial | Uso principal |
|---|---|---|
| Base de datos | PostgreSQL | Motor de base de datos del Data Warehouse |
| Cliente SQL | DBeaver | Validar datos, ejecutar consultas y revisar resultados |
| ETL | Apache Hop | Construcción y ejecución de pipelines ETL |
| Repositorio | GitHub | Control de versiones y trabajo colaborativo |
| Base compartida | Neon PostgreSQL | PostgreSQL en la nube para trabajo en equipo |

DBeaver no se considera herramienta ETL oficial. Su uso queda limitado a la administración, validación, revisión y auditoría de los datos. La carga hacia el esquema final `dm_streaming` debe realizarse mediante Apache Hop.

---

## 3. Arquitectura oficial del flujo de datos

La arquitectura definida para el proyecto es:

```text
CSV Kaggle
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

Esta arquitectura separa claramente la carga inicial, la transformación de datos y la explotación analítica. El esquema `staging` recibe los datos crudos de los CSV. Luego, Apache Hop aplica limpieza, selección, filtrado, eliminación de duplicados y carga controlada hacia el esquema `dm_streaming`. Finalmente, las consultas OLAP, reportes y dashboards se construyen sobre las tablas finales del Data Mart.

---

## 4. Estado actual de la base de datos

### 4.1 Base local

La base local actual es:

```text
dw_netflix
```

Los esquemas principales son:

```text
staging
dm_streaming
```

El encoding oficial esperado es:

```sql
SHOW server_encoding;
```

Resultado esperado:

```text
UTF8
```

---

### 4.2 Base compartida en Neon

Se creó una base compartida en Neon PostgreSQL para que el proyecto pueda trabajarse de forma colaborativa.

Datos principales:

| Elemento | Valor |
|---|---|
| Proyecto Neon | `dw-netflix` |
| Base creada por Neon | `neondb` |
| Motor | PostgreSQL 17 |
| Puerto | `5432` |
| SSL | `require` |
| Encoding validado | `UTF8` |

La conexión desde DBeaver hacia Neon fue probada correctamente. Actualmente Neon ya tiene creada la estructura del Data Warehouse, pero todavía falta cargar los CSV y ejecutar los pipelines ETL contra Neon.

---

## 5. Estructura actual de esquemas y tablas

### 5.1 Esquema `staging`

El esquema `staging` almacena los datos crudos provenientes de los archivos CSV. En este esquema se permite conservar los nombres originales de las columnas, incluso si tienen espacios o mayúsculas.

#### Tabla `staging.stg_netflix_titles`

Esta tabla almacena los datos del catálogo de Netflix.

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

Nota importante: en el CSV original la columna se llamaba `cast`, pero fue renombrada a `cast_members` para evitar conflictos SQL.

Conteo esperado aproximado:

```text
7787 registros
```

#### Tabla `staging.stg_netflix_userbase`

Esta tabla almacena los datos relacionados con usuarios, suscripciones, pagos, países, edad, género y dispositivos.

Columnas esperadas:

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

Conteo esperado aproximado:

```text
2500 registros
```

---

### 5.2 Esquema `dm_streaming`

El esquema `dm_streaming` contiene las tablas finales del Data Mart. A diferencia de `staging`, aquí los nombres deben estar limpios, normalizados y orientados al análisis.

Dimensiones actuales:

```text
dim_usuario
dim_pais
dim_tiempo
dim_contenido
dim_suscripcion
dim_dispositivo
```

Tablas de hechos actuales:

```text
fact_consumo
fact_ingresos
```

Ejemplos de nombres correctos para `dm_streaming`:

```text
tipo_suscripcion
duracion_plan
nombre_dispositivo
nombre_pais
fecha_completa
```

---

## 6. Scripts SQL del proyecto

Se definieron scripts SQL para que la estructura del proyecto sea reproducible tanto en local como en Neon.

| Script | Función |
|---|---|
| `sql/01_create_schemas.sql` | Crea los esquemas `staging` y `dm_streaming` |
| `sql/02_create_staging_tables.sql` | Crea las tablas del esquema `staging` |
| `sql/03_create_dm_streaming_tables.sql` | Crea dimensiones y hechos del Data Mart |
| `sql/04_validaciones_iniciales.sql` | Valida encoding, esquemas, tablas y conteos iniciales |
| `sql/90_validaciones_finales.sql` | Se usará después de cargar staging y ejecutar los pipelines ETL |

En Neon ya se ejecutaron los scripts del `01` al `04`, por lo que la estructura del Data Warehouse ya existe en la nube.

---

## 7. Repositorio GitHub y estructura del proyecto

El proyecto fue subido a GitHub para facilitar el trabajo colaborativo.

Repositorio:

```text
https://github.com/baamoc/ETL-PROYEC-NETFLIX.git
```

Carpeta local del proyecto:

```text
D:\UNIVERSIDAD\BBDD\hopavance\proyecto
```

Rama principal:

```text
main
```

Estado final registrado:

```text
La rama local main quedó sincronizada con origin/main.
El working tree quedó limpio.
No quedaron cambios pendientes.
```

Estructura principal creada:

```text
README.md
.gitignore
.env.example
sql/
docs/
docs/evidencias/
dashboard/
data/
datasets/
pipelines/
workflows/
```

Uso recomendado de carpetas:

| Carpeta | Uso |
|---|---|
| `sql/` | Scripts de creación, carga y validación |
| `pipelines/` | Pipelines de Apache Hop `.hpl` |
| `workflows/` | Workflows de Apache Hop `.hwf` |
| `docs/` | Documentación interna y técnica |
| `docs/evidencias/` | Capturas, logs y pruebas |
| `dashboard/` | Archivos del dashboard |
| `data/` | Datos de ejemplo o referencias livianas |
| `datasets/` | Datasets usados localmente, no necesariamente subidos a Git |

---

## 8. Seguridad aplicada en Git

Por seguridad, no se debe subir al repositorio información sensible ni archivos pesados innecesarios.

No se debe subir:

```text
contraseñas
archivos .env reales
conexiones reales de Apache Hop
metadata/rdbms/
backups pesados
datasets grandes sin autorización
```

La carpeta `metadata/rdbms/` fue excluida porque puede contener configuración local de conexión, usuario, host y contraseña encriptada.

Regla general: todo archivo que contenga credenciales reales debe quedarse fuera de GitHub. Para mostrar la estructura esperada se debe usar un archivo de ejemplo como `.env.example`, sin datos privados.

---

## 9. Reglas obligatorias de trabajo

Estas reglas deben respetarse para evitar errores, pérdida de datos o inconsistencias en el Data Warehouse.

1. No insertar datos manualmente en `dm_streaming`.
2. No ejecutar `DROP`, `DELETE` ni `TRUNCATE` sin autorización.
3. Todo pipeline debe partir desde `staging`.
4. Todo cambio estructural debe ir en un script SQL.
5. No modificar nombres de tablas finales sin aprobación.
6. No tocar tablas de hechos si las dimensiones necesarias no están validadas.
7. Todo pipeline debe tener evidencia.
8. Todo cambio debe subirse a Git.
9. No subir contraseñas.
10. No subir archivos `.env` reales.
11. No subir backups pesados.
12. No subir datasets grandes sin autorización.

---

## 10. Uso correcto de DBeaver

DBeaver se debe usar para:

```text
validar datos
ejecutar consultas SQL
revisar resultados
auditar conteos
administrar PostgreSQL
importar CSV hacia staging cuando corresponda
```

DBeaver no debe usarse para cargar manualmente datos en `dm_streaming`. La carga hacia el Data Mart debe realizarse con Apache Hop, para que el proceso ETL quede documentado, sea repetible y pueda evidenciarse.

---

## 11. Uso correcto de Apache Hop

Apache Hop es la herramienta oficial para cargar datos hacia `dm_streaming`.

Todo pipeline debe cumplir tres condiciones básicas:

1. Debe partir desde una tabla del esquema `staging`.
2. Debe aplicar las transformaciones necesarias.
3. Debe cargar los datos hacia una tabla del esquema `dm_streaming`.

Además, cada pipeline debe tener evidencia completa:

```text
archivo .hpl
captura del pipeline completo
capturas de configuración de pasos importantes
log de ejecución
consulta SQL de validación
captura del resultado de la validación
```

---

## 12. Flujo estándar de pipelines ETL

Para las dimensiones, el flujo visual estándar recomendado en Apache Hop es:

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

Explicación de cada paso:

| Paso | Función |
|---|---|
| `Table input` | Lee los datos desde una tabla de `staging` |
| `Select values` | Selecciona, renombra o ajusta campos |
| `String operations` | Limpia espacios y normaliza textos |
| `Filter rows` | Filtra nulos, vacíos o registros no válidos |
| `Sort rows` | Ordena datos antes de eliminar duplicados |
| `Unique rows` | Conserva registros únicos para dimensiones |
| `Insert / update` | Inserta o actualiza datos en `dm_streaming` |

Para las tablas de hechos, el flujo puede variar porque probablemente se necesitarán búsquedas, joins o consultas contra dimensiones ya cargadas.

---

## 13. Pipeline completado

### 13.1 `01_ETL_DIM_DISPOSITIVO.hpl`

El primer pipeline oficial completado corresponde a la carga de la dimensión dispositivo.

Datos del pipeline:

| Elemento | Detalle |
|---|---|
| Pipeline | `01_ETL_DIM_DISPOSITIVO.hpl` |
| Origen | `staging.stg_netflix_userbase.device` |
| Destino | `dm_streaming.dim_dispositivo.nombre_dispositivo` |
| Herramienta | Apache Hop |
| Estado | Completado en entorno local |

Flujo usado:

```text
Table input
Select values
String operations
Filter rows
Sort rows
Unique rows
Insert / update
```

Resultado validado:

```text
1 | Laptop
2 | Smart TV
3 | Smartphone
4 | Tablet
```

Conteo final:

```text
4 dispositivos
```

Nota: este pipeline todavía debe probarse contra Neon después de cargar los CSV en `staging` y crear la conexión oficial de Apache Hop hacia Neon.

---

## 14. Pipelines pendientes

Los pipelines pendientes se organizaron en dos rondas de trabajo.

### 14.1 Primera ronda

```text
02_ETL_DIM_SUSCRIPCION.hpl
03_ETL_DIM_USUARIO.hpl
04_ETL_DIM_TIEMPO.hpl
05_ETL_DIM_PAIS.hpl
```

### 14.2 Segunda ronda

```text
06_ETL_DIM_CONTENIDO.hpl
07_ETL_FACT_INGRESOS.hpl
08_ETL_FACT_CONSUMO.hpl
00_RUN_ETL_COMPLETO.hwf
```

El próximo pipeline recomendado es:

```text
02_ETL_DIM_SUSCRIPCION.hpl
```

Origen esperado:

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

Regla importante: no insertar `id_suscripcion` manualmente, porque PostgreSQL lo genera automáticamente.

---

## 15. Reglas especiales de transformación

### 15.1 Regla para `dim_pais`

El campo `country` puede contener varios países en una sola celda.

Ejemplo:

```text
Argentina, Brazil, France
```

Por esa razón, la dimensión país no debe cargarse copiando el campo completo como si fuera un solo país. Debe separarse cada país y cargarse como un registro individual.

Forma incorrecta:

```text
Argentina, Brazil, France
```

Forma correcta:

```text
Argentina
Brazil
France
```

Esta transformación debe realizarse mediante Apache Hop y quedar documentada con evidencia.

---

### 15.2 Regla para `fact_consumo`

Los datasets Netflix Titles y Netflix Userbase no tienen una relación directa natural entre usuarios y contenidos.

Por este motivo, `fact_consumo` debe construirse mediante una lógica simulada o controlada. No se debe inventar una relación sin explicar el criterio utilizado.

La documentación de `fact_consumo` debe aclarar:

```text
qué criterio se usó para relacionar usuarios y contenidos;
por qué se usó ese criterio;
qué limitaciones tiene la simulación;
qué campos intervienen en la carga;
qué validaciones confirman que la carga fue correcta.
```

---

## 16. Validaciones recomendadas

Después de cargar los CSV en `staging`, se deben ejecutar validaciones básicas antes de continuar con los pipelines ETL.

### 16.1 Validar cantidad de registros en títulos

```sql
SELECT COUNT(*) AS total_titles
FROM staging.stg_netflix_titles;
```

Resultado esperado aproximado:

```text
7787 registros
```

### 16.2 Validar cantidad de registros en usuarios

```sql
SELECT COUNT(*) AS total_userbase
FROM staging.stg_netflix_userbase;
```

Resultado esperado aproximado:

```text
2500 registros
```

### 16.3 Validar dispositivos disponibles

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

### 16.4 Validar tipos de suscripción

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

### 16.5 Validación mínima de una dimensión cargada

Ejemplo para `dim_dispositivo`:

```sql
SELECT *
FROM dm_streaming.dim_dispositivo
ORDER BY id_dispositivo;
```

---

## 17. Estado actual de Neon

Neon ya tiene la estructura del Data Warehouse creada.

Actualmente Neon cuenta con:

```text
esquemas creados
tablas staging creadas
tablas dm_streaming creadas
conexión DBeaver funcional
encoding UTF8 validado
```

Todavía no se realizó:

```text
carga de CSV en Neon
ejecución de pipelines Apache Hop contra Neon
creación de conexión Hop oficial hacia Neon
carga de dim_dispositivo en Neon mediante Hop
carga de dim_suscripcion
carga de las demás dimensiones
carga de tablas de hechos
ejecución de 90_validaciones_finales.sql
creación de dashboard
creación de reportes finales
creación de cubos OLAP
invitación de compañeros a Neon
```

---

## 18. Próximo orden recomendado de trabajo

El orden recomendado para continuar es:

1. Abrir DBeaver.
2. Conectarse a Neon.
3. Importar los CSV a las tablas del esquema `staging`.
4. Validar conteos de `staging`.
5. Crear conexión de Apache Hop hacia Neon.
6. Probar `01_ETL_DIM_DISPOSITIVO.hpl` contra Neon.
7. Validar `dim_dispositivo` en Neon.
8. Crear `02_ETL_DIM_SUSCRIPCION.hpl`.
9. Documentar evidencias del pipeline.
10. Continuar con las demás dimensiones.
11. Recién después de validar dimensiones, trabajar las tablas de hechos.
12. Ejecutar validaciones finales.
13. Avanzar con cubos OLAP, reportes y dashboard.

---

## 19. Entrega obligatoria por cada pipeline

Cada compañero debe entregar por pipeline:

| N.º | Evidencia requerida |
|---|---|
| 1 | Archivo `.hpl` |
| 2 | Captura del pipeline completo |
| 3 | Capturas de configuración de pasos importantes |
| 4 | Log de ejecución |
| 5 | Consulta SQL de validación |
| 6 | Captura del resultado de la validación |

Estas evidencias deben guardarse preferentemente en:

```text
docs/evidencias/
```

---

## 20. Resumen ejecutivo del avance

Hasta el momento, el proyecto ya cuenta con una base técnica ordenada para continuar la fase ETL. Se definieron herramientas oficiales, reglas de seguridad, arquitectura de datos, scripts SQL reproducibles, estructura en GitHub y una base compartida en Neon PostgreSQL.

El modelo físico ya se encuentra creado en Neon mediante scripts SQL. Sin embargo, todavía falta completar la carga de datos en `staging`, conectar Apache Hop con Neon y ejecutar los pipelines ETL oficiales hacia `dm_streaming`.

El único pipeline completado hasta ahora es `01_ETL_DIM_DISPOSITIVO.hpl`, validado en entorno local con cuatro dispositivos únicos: Laptop, Smart TV, Smartphone y Tablet. El siguiente paso recomendado es reproducir esta carga en Neon y continuar con `02_ETL_DIM_SUSCRIPCION.hpl`.

---

## 21. Nota para el equipo

Este documento no reemplaza la documentación oficial de entrega. Su función es servir como guía interna del estado real del proyecto, las decisiones técnicas tomadas y las reglas que deben seguirse para continuar el desarrollo sin afectar la estructura principal del Data Warehouse.

La documentación oficial debe mantenerse ordenada según la consigna del licenciado. Este archivo puede usarse como respaldo, guía de trabajo y fuente para actualizar secciones técnicas cuando corresponda.
