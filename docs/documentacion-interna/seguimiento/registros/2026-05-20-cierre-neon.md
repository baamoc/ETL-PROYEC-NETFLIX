\# Cierre de jornada - GitHub y Neon



Fecha: 2026-05-20



\## Proyecto



DW Netflix - Data Warehouse Streaming



Repositorio GitHub:



https://github.com/baamoc/ETL-PROYEC-NETFLIX.git



Carpeta local del proyecto:



D:\\UNIVERSIDAD\\BBDD\\hopavance\\proyecto



\## Objetivo de la jornada



Preparar el proyecto para trabajo colaborativo usando:



\- Git

\- GitHub

\- Neon PostgreSQL

\- Apache Hop

\- DBeaver

\- scripts SQL reproducibles

\- documentación base



El objetivo fue dejar una base ordenada para que los compañeros puedan continuar el trabajo sin depender de una sola computadora local.



\## Estado antes de iniciar



Ya existía un proyecto local de Apache Hop en:



D:\\UNIVERSIDAD\\BBDD\\hopavance\\proyecto



Ese proyecto contenía:



\- datasets

\- metadata

\- pipelines

\- workflows

\- project-config.json



También ya existía un pipeline oficial terminado:



\- pipelines/01\_ETL\_DIM\_DISPOSITIVO.hpl



Ese pipeline carga:



\- Origen: staging.stg\_netflix\_userbase.device

\- Destino: dm\_streaming.dim\_dispositivo.nombre\_dispositivo



Resultado esperado:



\- Laptop

\- Smart TV

\- Smartphone

\- Tablet



\## Trabajo realizado en GitHub



Se inicializó Git en la carpeta del proyecto.



Rama principal:



\- main



Se creó el primer commit del proyecto.



Se conectó el repositorio local con GitHub:



\- https://github.com/baamoc/ETL-PROYEC-NETFLIX.git



Se realizó push correctamente a GitHub.



Validación final:



\- La rama local main quedó sincronizada con origin/main.

\- El working tree quedó limpio.

\- No quedaron cambios pendientes.



\## Estructura creada en el proyecto



Se agregaron archivos y carpetas para ordenar el trabajo:



\- README.md

\- .gitignore

\- .env.example

\- sql/

\- docs/

\- dashboard/

\- data/



\## Scripts SQL creados



Se crearon los siguientes scripts:



\- sql/01\_create\_schemas.sql

\- sql/02\_create\_staging\_tables.sql

\- sql/03\_create\_dm\_streaming\_tables.sql

\- sql/04\_validaciones\_iniciales.sql

\- sql/90\_validaciones\_finales.sql



Uso previsto:



1\. 01\_create\_schemas.sql  

&#x20;  Crea los esquemas staging y dm\_streaming.



2\. 02\_create\_staging\_tables.sql  

&#x20;  Crea las tablas staging.



3\. 03\_create\_dm\_streaming\_tables.sql  

&#x20;  Crea las dimensiones y hechos del DataMart.



4\. 04\_validaciones\_iniciales.sql  

&#x20;  Valida encoding, esquemas, tablas y conteos iniciales.



5\. 90\_validaciones\_finales.sql  

&#x20;  Se usará después de cargar staging y ejecutar pipelines ETL.



\## Documentación creada



Se crearon los documentos equivalentes actuales:



\- docs/documentacion-interna/seguimiento/resumen-avance.md

\- docs/documentacion-interna/reglas/decisiones-tecnicas.md

\- docs/documentacion-interna/guias/guia-colaboracion.md



Objetivo:



\- Dejar reglas claras para el equipo.

\- Evitar cargas manuales en dm\_streaming.

\- Documentar el uso de Apache Hop como ETL oficial.

\- Explicar qué debe entregar cada compañero por pipeline.



\## Seguridad aplicada en Git



No se subió la conexión real de Apache Hop a PostgreSQL.



Se excluyó del repositorio:



\- metadata/rdbms/



Motivo:



Esa carpeta puede contener configuración local de conexión, usuario, host y contraseña encriptada.



Regla:



No subir archivos con contraseñas, conexiones reales ni archivos .env reales.



\## Trabajo realizado en Neon



Se creó una organización en Neon.



Se creó un proyecto Neon llamado:



\- dw-netflix



Neon creó una base PostgreSQL en la nube:



\- neondb



Se configuró una conexión desde DBeaver hacia Neon con:



\- Host de Neon

\- Puerto 5432

\- Base neondb

\- Usuario neondb\_owner

\- SSL mode require



La prueba de conexión fue exitosa.



Resultado:



\- DBeaver conectó correctamente a Neon.

\- Neon usa PostgreSQL 17.

\- El encoding validado fue UTF8.



\## Scripts ejecutados en Neon



En la base Neon neondb se ejecutaron:



1\. sql/01\_create\_schemas.sql

2\. sql/02\_create\_staging\_tables.sql

3\. sql/03\_create\_dm\_streaming\_tables.sql

4\. sql/04\_validaciones\_iniciales.sql



Resultado:



Se crearon correctamente los esquemas:



\- staging

\- dm\_streaming



Se crearon correctamente las tablas staging:



\- staging.stg\_netflix\_titles

\- staging.stg\_netflix\_userbase



Se crearon correctamente las tablas finales:



\- dm\_streaming.dim\_usuario

\- dm\_streaming.dim\_pais

\- dm\_streaming.dim\_tiempo

\- dm\_streaming.dim\_contenido

\- dm\_streaming.dim\_suscripcion

\- dm\_streaming.dim\_dispositivo

\- dm\_streaming.fact\_consumo

\- dm\_streaming.fact\_ingresos



\## Estado actual de Neon



Neon ya tiene la estructura del Data Warehouse creada.



Actualmente Neon tiene:



\- esquemas creados;

\- tablas staging creadas;

\- tablas dm\_streaming creadas;

\- conexión DBeaver funcional;

\- encoding UTF8 validado.



\## Qué NO se hizo todavía



No se cargaron todavía los CSV en Neon.



No se ejecutaron pipelines Apache Hop contra Neon.



No se creó todavía una conexión Hop oficial hacia Neon.



No se cargó dim\_dispositivo en Neon mediante Hop.



No se cargó dim\_suscripcion.



No se cargaron las demás dimensiones.



No se cargaron las tablas de hechos.



No se ejecutó 90\_validaciones\_finales.sql.



No se creó dashboard.



No se crearon reportes finales.



No se crearon cubos OLAP.



No se invitó todavía a compañeros a Neon.



\## Próximo paso recomendado



Mañana, continuar en este orden:



1\. Abrir DBeaver.

2\. Conectarse a Neon.

3\. Importar CSV a staging.

4\. Validar conteos de staging.

5\. Crear conexión de Apache Hop hacia Neon.

6\. Probar pipeline 01\_ETL\_DIM\_DISPOSITIVO.hpl contra Neon.

7\. Validar dim\_dispositivo en Neon.

8\. Crear pipeline 02\_ETL\_DIM\_SUSCRIPCION.hpl.

9\. Documentar evidencias.



\## Carga pendiente a staging en Neon



Se deben importar los CSV a:



\### Tabla 1



Destino:



\- staging.stg\_netflix\_titles



Columnas esperadas:



\- show\_id

\- type

\- title

\- director

\- cast\_members

\- country

\- date\_added

\- release\_year

\- rating

\- duration

\- genres

\- description



Conteo esperado aproximado:



\- 7787 registros



\### Tabla 2



Destino:



\- staging.stg\_netflix\_userbase



Columnas esperadas:



\- "User ID"

\- "Subscription Type"

\- "Monthly Revenue"

\- "Join Date"

\- "Last Payment Date"

\- country

\- age

\- gender

\- device

\- "Plan Duration"



Conteo esperado aproximado:



\- 2500 registros



\## Validaciones recomendadas después de cargar staging



Ejecutar en Neon:



SELECT COUNT(\*) AS total\_titles

FROM staging.stg\_netflix\_titles;



SELECT COUNT(\*) AS total\_userbase

FROM staging.stg\_netflix\_userbase;



SELECT DISTINCT device

FROM staging.stg\_netflix\_userbase

ORDER BY device;



SELECT DISTINCT

&#x20;   "Subscription Type",

&#x20;   "Plan Duration"

FROM staging.stg\_netflix\_userbase

ORDER BY "Subscription Type", "Plan Duration";



Resultados esperados para dispositivos:



\- Laptop

\- Smart TV

\- Smartphone

\- Tablet



Resultados esperados para suscripción:



\- Basic | 1 Month

\- Premium | 1 Month

\- Standard | 1 Month



\## Reglas obligatorias para compañeros



1\. No insertar manualmente en dm\_streaming.

2\. DBeaver solo se usa para validar, auditar y cargar staging.

3\. Apache Hop es el ETL oficial hacia dm\_streaming.

4\. Todo pipeline debe salir desde staging.

5\. No ejecutar DROP, DELETE ni TRUNCATE sin autorización.

6\. No cambiar estructura sin script SQL.

7\. No subir contraseñas.

8\. No subir archivos .env reales.

9\. No subir metadata/rdbms.

10\. Toda validacion relevante debe quedar documentada en la documentacion interna del proyecto.

11\. No tocar hechos hasta validar dimensiones.

12\. Todo cambio debe subirse a GitHub.



\## Decisión final de la jornada



El proyecto quedó en buen estado para continuar mañana.



GitHub está listo.



Neon está creado y conectado.



La estructura del Data Warehouse ya existe en Neon.



Lo pendiente principal es cargar staging en Neon y luego ejecutar ETL oficial con Apache Hop.

