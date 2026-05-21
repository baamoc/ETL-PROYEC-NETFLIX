\# DW Netflix - Data Warehouse Streaming



Proyecto de Base de Datos 3 orientado al diseño e implementación de un Data Warehouse para el análisis integrado de usuarios, contenido, ingresos, dispositivos, suscripciones, países, tiempo y consumo en una plataforma de streaming tipo Netflix.



\## Objetivo



Diseñar e implementar un Data Warehouse que permita analizar:



\- Distribución de usuarios por edad, género y país.

\- Ingresos por tipo de suscripción.

\- Uso de dispositivos.

\- Catálogo de contenido por tipo, país y género.

\- Evolución temporal de contenidos e ingresos.

\- Patrones de consumo simulados/controlados.



\## Arquitectura oficial



CSV Kaggle  

↓  

staging  

↓  

Apache Hop ETL  

↓  

dm\_streaming  

↓  

Consultas OLAP  

↓  

Reportes  

↓  

Dashboard / KPIs  



\## Herramientas



\- PostgreSQL

\- DBeaver

\- Apache Hop

\- Git / GitHub

\- Neon PostgreSQL

\- Herramienta de dashboard por definir



\## Base de datos local



Base actual:



\- dw\_netflix



Esquemas:



\- staging

\- dm\_streaming



Encoding esperado:



\- UTF8



Validación:



\- SHOW server\_encoding;



\## Staging



\### staging.stg\_netflix\_titles



Columnas:



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



Nota: en el CSV original existía la columna `cast`, pero se renombró a `cast\_members` por conflicto SQL.



\### staging.stg\_netflix\_userbase



Columnas originales del CSV:



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



Regla: staging conserva nombres crudos del CSV.



\## DataMart final



Esquema:



\- dm\_streaming



Dimensiones:



\- dim\_usuario

\- dim\_pais

\- dim\_tiempo

\- dim\_contenido

\- dim\_suscripcion

\- dim\_dispositivo



Hechos:



\- fact\_consumo

\- fact\_ingresos



\## Estado actual



Completado:



\- Modelo conceptual.

\- Modelo lógico.

\- Modelo físico inicial.

\- PostgreSQL local operativo.

\- DBeaver configurado.

\- Apache Hop configurado.

\- Base UTF8 corregida.

\- staging implementado.

\- CSV reales cargados en staging.

\- dm\_streaming recreado.

\- Primer pipeline oficial ejecutado.



Pipeline completado:



\- 01\_ETL\_DIM\_DISPOSITIVO.hpl



Resultado validado:



\- 1 | Laptop

\- 2 | Smart TV

\- 3 | Smartphone

\- 4 | Tablet



\## Pipelines pendientes



\- 02\_ETL\_DIM\_SUSCRIPCION.hpl

\- 03\_ETL\_DIM\_USUARIO.hpl

\- 04\_ETL\_DIM\_TIEMPO.hpl

\- 05\_ETL\_DIM\_PAIS.hpl

\- 06\_ETL\_DIM\_CONTENIDO.hpl

\- 07\_ETL\_FACT\_INGRESOS.hpl

\- 08\_ETL\_FACT\_CONSUMO.hpl

\- 00\_RUN\_ETL\_COMPLETO.hwf



\## Reglas obligatorias



1\. DBeaver no es ETL oficial.

2\. DBeaver solo se usa para validar, auditar y administrar.

3\. Apache Hop es la herramienta ETL oficial.

4\. No insertar manualmente en `dm\_streaming`.

5\. Todo pipeline debe salir desde `staging`.

6\. staging puede tener nombres crudos.

7\. dm\_streaming debe tener nombres limpios.

8\. No borrar staging.

9\. No ejecutar DROP, DELETE o TRUNCATE sin autorización.

10\. Todo cambio estructural debe ir en script SQL.

11\. Toda carga debe ir en pipeline Hop.

12\. Toda evidencia debe guardarse en `docs/evidencias`.



\## Entrega por pipeline



Cada pipeline debe entregar:



1\. Archivo `.hpl`.

2\. Captura del pipeline completo.

3\. Capturas de configuración.

4\. Log de ejecución.

5\. Consulta SQL de validación.

6\. Captura del resultado.



\## Riesgos importantes



\### fact\_consumo



Los datasets Netflix Titles y Netflix Userbase no tienen una relación natural directa. Por eso `fact\_consumo` debe construirse mediante lógica simulada/controlada y documentada.



\### dim\_pais



El campo `country` de Netflix Titles puede contener múltiples países en una sola celda, por ejemplo:



\- Argentina, Brazil, France



Por eso `dim\_pais` no debe cargarse directamente sin separación previa en Apache Hop.



\## Próximo paso recomendado



Crear y validar:



\- 02\_ETL\_DIM\_SUSCRIPCION.hpl

