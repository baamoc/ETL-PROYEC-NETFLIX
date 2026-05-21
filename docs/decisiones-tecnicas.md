\# Decisiones técnicas del proyecto DW Netflix



\## 1. Herramientas oficiales



Base de datos:



\- PostgreSQL



Cliente SQL:



\- DBeaver



ETL oficial:



\- Apache Hop



Repositorio:



\- GitHub



Base compartida:



\- Neon PostgreSQL



\## 2. Arquitectura oficial



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



\## 3. Regla sobre DBeaver



DBeaver solo se usa para:



\- validar datos;

\- ejecutar consultas SQL;

\- revisar resultados;

\- auditar conteos;

\- administrar PostgreSQL.



DBeaver no se considera herramienta ETL oficial.



No se deben insertar manualmente datos en `dm\_streaming` desde DBeaver.



\## 4. Regla sobre Apache Hop



Apache Hop es la herramienta oficial para cargar datos hacia `dm\_streaming`.



Todo pipeline debe partir desde `staging`.



Todo pipeline debe tener evidencia:



\- captura del pipeline completo;

\- capturas de configuración;

\- log de ejecución;

\- consulta SQL de validación;

\- captura del resultado.



\## 5. Regla sobre staging



El esquema `staging` conserva datos crudos de los CSV.



Se permite que staging tenga nombres originales, incluso con espacios, como:



\- "User ID"

\- "Subscription Type"

\- "Monthly Revenue"

\- "Join Date"

\- "Last Payment Date"

\- "Plan Duration"



\## 6. Regla sobre dm\_streaming



El esquema `dm\_streaming` debe contener nombres limpios, consistentes y orientados al análisis.



Ejemplos:



\- tipo\_suscripcion

\- duracion\_plan

\- nombre\_dispositivo

\- nombre\_pais

\- fecha\_completa



\## 7. Decisión sobre fact\_consumo



Los datasets Netflix Titles y Netflix Userbase no tienen una relación directa natural.



Por eso `fact\_consumo` será construido mediante una lógica simulada/controlada y documentada.



No se debe inventar una relación sin dejar evidencia y explicación.



\## 8. Decisión sobre dim\_pais



El campo `country` puede tener varios países en una sola celda.



Ejemplo:



\- Argentina, Brazil, France



Por eso `dim\_pais` debe cargarse separando países mediante Apache Hop.



No se debe cargar directamente el campo completo sin separar.



\## 9. Decisión sobre Neon



Neon será usado como PostgreSQL compartido.



No se debe migrar de forma improvisada.



Ruta recomendada:



1\. Crear scripts SQL reproducibles.

2\. Crear Neon vacío.

3\. Ejecutar scripts SQL en Neon.

4\. Cargar staging.

5\. Ejecutar pipelines Hop contra Neon.

6\. Validar resultados.



\## 10. Decisión sobre Docker e IA



Docker queda como opción posterior.



IA/MCP queda como extra futuro.



La prioridad actual es:



1\. ETL correcto.

2\. Base reproducible.

3\. GitHub ordenado.

4\. Neon controlado.

5\. Documentación.

6\. Reportes y dashboard.

