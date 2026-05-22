\# Estado actual del proyecto DW Netflix



Fecha: 2026-05-22



\## Estado general



El proyecto DW Netflix se encuentra en fase de preparación colaborativa para trabajar con GitHub, Neon PostgreSQL y Apache Hop.



El objetivo actual es dejar el proyecto reproducible, documentado y seguro para que otros compañeros puedan colaborar sin romper la base ni cargar datos manualmente.



\## Base local actual



Base de datos:



\- dw\_netflix



Esquemas:



\- staging

\- dm\_streaming



Encoding oficial esperado:



\- UTF8



Validación:



\- SHOW server\_encoding;



\## Tablas staging actuales



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



Nota: el CSV original tenía la columna `cast`, pero se renombró a `cast\_members` por conflicto SQL.

Conteo validado (2026-05-22): 7787



\### staging.stg\_netflix\_userbase



Columnas:



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



Regla: staging conserva nombres crudos/originales del CSV.

Conteo validado (2026-05-22): 2500



\## Tablas finales actuales en dm\_streaming



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



\## Pipeline ya completado



Pipeline:



\- 01\_ETL\_DIM\_DISPOSITIVO.hpl



Origen:



\- staging.stg\_netflix\_userbase.device



Destino:



\- dm\_streaming.dim\_dispositivo.nombre\_dispositivo



Flujo usado:



\- Table input

\- Select values

\- String operations

\- Filter rows

\- Sort rows

\- Unique rows

\- Insert / update



Resultado validado:



\- 1 | Laptop

\- 2 | Smart TV

\- 3 | Smartphone

\- 4 | Tablet



Conteo final:



\- 4 dispositivos



\## Pendiente



Pipelines pendientes:



\- 02\_ETL\_DIM\_SUSCRIPCION.hpl

\- 03\_ETL\_DIM\_USUARIO.hpl

\- 04\_ETL\_DIM\_TIEMPO.hpl

\- 05\_ETL\_DIM\_PAIS.hpl

\- 06\_ETL\_DIM\_CONTENIDO.hpl

\- 07\_ETL\_FACT\_INGRESOS.hpl

\- 08\_ETL\_FACT\_CONSUMO.hpl

\- 00\_RUN\_ETL\_COMPLETO.hwf



\## Próximo pipeline recomendado



\- 02\_ETL\_DIM\_SUSCRIPCION.hpl



Origen esperado:



\- "Subscription Type"

\- "Plan Duration"



Destino:



\- dm\_streaming.dim\_suscripcion



Campos destino:



\- tipo\_suscripcion

\- duracion\_plan



Regla:



\- No insertar id\_suscripcion manualmente, porque PostgreSQL lo genera automáticamente.
