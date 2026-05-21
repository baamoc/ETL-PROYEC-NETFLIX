\# Guía para compañeros - DW Netflix



\## Objetivo



Esta guía explica cómo colaborar en el proyecto DW Netflix sin romper la base de datos ni alterar el flujo oficial.



\## Reglas obligatorias



1\. No insertar datos manualmente en `dm\_streaming`.

2\. No ejecutar DROP, DELETE ni TRUNCATE sin autorización.

3\. Todo pipeline debe partir desde `staging`.

4\. Todo cambio estructural debe ir en un script SQL.

5\. No modificar nombres de tablas finales sin aprobación.

6\. No tocar tablas de hechos si las dimensiones necesarias no están validadas.

7\. Todo pipeline debe tener evidencia.

8\. Todo cambio debe subirse a Git.

9\. No subir contraseñas.

10\. No subir archivos `.env` reales.

11\. No subir backups pesados.

12\. No subir datasets grandes sin autorización.



\## Estructura del proyecto



Carpetas principales:



\- sql: scripts de creación y validación.

\- pipelines: pipelines de Apache Hop.

\- workflows: workflows de Apache Hop.

\- docs: documentación del proyecto.

\- docs/evidencias: capturas y pruebas.

\- dashboard: archivos del dashboard.

\- data: datos de ejemplo o referencias.

\- datasets: datasets usados localmente, no necesariamente subidos a Git.



\## Entrega obligatoria por pipeline



Cada compañero debe entregar:



1\. Archivo `.hpl`.

2\. Captura del pipeline completo.

3\. Capturas de configuración de los pasos importantes.

4\. Log de ejecución.

5\. Consulta SQL de validación.

6\. Captura del resultado de la validación.



\## Pipelines asignables



Primera ronda:



\- 02\_ETL\_DIM\_SUSCRIPCION.hpl

\- 03\_ETL\_DIM\_USUARIO.hpl

\- 04\_ETL\_DIM\_TIEMPO.hpl

\- 05\_ETL\_DIM\_PAIS.hpl



Segunda ronda:



\- 06\_ETL\_DIM\_CONTENIDO.hpl

\- 07\_ETL\_FACT\_INGRESOS.hpl

\- 08\_ETL\_FACT\_CONSUMO.hpl

\- 00\_RUN\_ETL\_COMPLETO.hwf



\## Estándar visual de pipeline



Cuando aplique, usar este flujo:



1\. Table input

2\. Select values

3\. String operations

4\. Filter rows

5\. Sort rows

6\. Unique rows

7\. Insert / update



Para tablas de hechos puede variar, porque probablemente se usarán búsquedas o joins con dimensiones.



\## Validación mínima



Cada pipeline debe tener una consulta SQL de validación.



Ejemplo para dim\_dispositivo:



SELECT \*

FROM dm\_streaming.dim\_dispositivo

ORDER BY id\_dispositivo;



\## Advertencia sobre dim\_pais



No cargar directamente países múltiples en una sola fila.



Si el campo contiene:



Argentina, Brazil, France



debe separarse en registros individuales.



\## Advertencia sobre fact\_consumo



No existe relación natural entre usuarios y contenidos.



La lógica de consumo debe ser simulada/controlada y documentada.

