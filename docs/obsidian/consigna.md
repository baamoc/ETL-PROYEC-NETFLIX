# Consigna del proyecto Base de Datos 3

Implementacion de un Data Warehouse

## Primera presentacion (puntos 1 a 5)

1. **Tema del proyecto**
   - Seleccionar un tema de interes basado en un conjunto de datos disponible publicamente, preferentemente desde Kaggle.
   - El tema elegido debe permitir aplicar tecnicas de analisis de datos y modelado dimensional para la construccion de un Data Warehouse.

2. **Objetivos del Data Warehouse**
   - Definir con claridad los objetivos del analisis a realizar mediante el Data Warehouse.
   - Los objetivos deben estar alineados con los datos disponibles y permitir una explotacion analitica significativa.
   - Ejemplos:
     - Identificar patrones de comportamiento de los clientes.
     - Analizar tendencias de ventas por producto y region.

3. **Modelado conceptual del Data Mart**
   - Identificar tres posibles Data Marts relacionados con el tema.
   - Desarrollar e implementar el que aporte mayor valor a la unidad de negocio simulada (datasets Kaggle).
   - Diseñar un modelo conceptual con entidades y relaciones necesarias; detallar dimensiones y hechos.

4. **Modelado logico del Data Mart**
   - Elaborar el modelo logico con atributos de dimensiones y hechos.
   - Establecer claves primarias y foraneas, y las relaciones necesarias.

5. **Modelado fisico del Data Mart**
   - Implementar el modelo fisico en el DBMS.
   - Crear tablas de dimensiones y hechos con indices y relaciones.
   - Asegurar estructura optima para consultas analiticas.

**Observacion:** La primera presentacion debe enviarse en formato PDF.

## Segunda presentacion (puntos 6 a 10)

6. **Procesos ETL (Extract, Transform, Load)**
   - Desarrollar procesos ETL para cargar el Data Warehouse.
   - Documentar el flujo de datos desde fuentes originales hasta el Data Mart.
   - Implementar el proceso ETL en Pentaho PDI y realizar la carga completa de datos.

7. **Cubos OLAP**
   - Crear cubos OLAP para analisis multidimensional.
   - Implementar agregaciones y niveles de detalle (fecha, ubicacion, categoria).

8. **Reportes**
   - Desarrollar al menos cuatro (3) reportes detallados basados en cubos y datos del Data Mart.
   - Los reportes deben responder a los objetivos y presentar informacion en formatos visuales.

9. **Cuadros de mando**
   - Disenar cuadros de mando con KPIs definidos en los objetivos.
   - Deben ser interactivos y permitir navegacion entre niveles de detalle y filtros.

10. **Documentacion y entrega**
   - Presentar un informe detallado que incluya:
     - Diseno: modelos conceptual, logico y fisico.
     - Procesos ETL: flujo, herramientas y transformaciones.
     - Cubos OLAP: detalles de cubos y dimensiones.
     - Reportes y cuadros de mando: capturas y explicacion.
   - Entregar en formato digital con scripts SQL, configuracion ETL, reportes y PDF.

## Evaluacion

- **Calidad del diseno (10%)**: objetivo general, objetivos especificos, modelo conceptual, modelo logico, tabla de hecho, dimensiones, metricas y grano.
- **Carga del Data Mart (30%)**: procesos ETL.
- **Cubos y reportes (30%)**: funcionalidad y utilidad de los cubos OLAP y reportes.
- **Interactividad y cuadros de mando (30%)**: diseno y efectividad de los cuadros de mando.
