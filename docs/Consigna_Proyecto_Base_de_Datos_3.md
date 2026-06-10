# Consigna del Proyecto Base de Datos 3: Implementación de un Data Warehouse

## Primera Presentación (Desde el punto 1 hasta el punto 5) 

1. **Tema del Proyecto:** * Seleccionar un tema de interés basado en un conjunto de datos disponible públicamente, preferentemente desde la plataforma en Kaggle.  
   * El tema elegido debe permitir aplicar técnicas de análisis de datos y modelado dimensional para la construcción de un Data Warehouse. 

2. **Objetivos del Data Warehouse:** * Definir con claridad los objetivos del análisis a realizar mediante el Data Warehouse. Los objetivos deben estar alineados con los datos disponibles y permitir una explotación analítica significativa.: 
     * Identificar patrones de comportamiento de los clientes. 
     * Analizar tendencias de ventas por producto y región. 
   * Los objetivos deben estar alineados con los datos seleccionados y permitir un análisis profundo mediante el Data Warehouse. 

3. **Modelado Conceptual del DataMart:** * Cada grupo deberá identificar tres posibles DataMarts relacionados con el tema, de los cuales se deberá desarrollar e implementar aquel que aporte mayor valor a la unidad de negocio simulada (DataSets Kaggle ). 
   * Diseñar un modelo conceptual del DataMart que incluya las principales entidades y relaciones necesarias para alcanzar los objetivos planteados. Este modelo debe detallar las dimensiones y hechos de la base de datos. 

4. **Modelado Lógico del DataMart:** * Elaborar el modelo lógico, incluyendo detalles sobre los atributos de las dimensiones y los hechos. 
   * Establecer las claves primarias y foráneas en las tablas de dimensiones y hechos, así como las relaciones necesarias. 

5. **Modelado Físico del DataMart:** * Implementar el modelo físico en DBMS, creando las tablas de dimensiones y hechos con sus respectivos índices y relaciones. 
   * Asegurarse de que la estructura de la base de datos sea óptima para consultas de análisis. 

**Observación:** La primera presentación deben enviar en formato PDF 

---

## Segunda Presentación (Desde el punto 6 hasta el punto 10) 

6. **Procesos ETL (Extract, Transform, Load):** * Desarrollar los procesos ETL necesarios para cargar los datos en el Data Warehouse. 
   * Documentar el flujo de datos desde las fuentes originales hasta el DataMart, incluyendo cualquier transformación que se realice. 
   * Implementar el proceso ETL en Pentaho PDI y realizar la carga completa de los datos. 

7. **Cubos OLAP:** * Crear cubos OLAP para el análisis multidimensional de los datos. 
   * Implementar agregaciones y niveles de detalle que permitan realizar análisis desde diferentes perspectivas, como por fecha, ubicación y categoría de producto. 

8. **Reportes:** * Desarrollar al menos cuatro (3) reportes detallados basados en los cubos y datos del DataMart. 
   * Los reportes deben responder a los objetivos planteados y presentar información en formatos visuales (tablas, gráficos) que faciliten la interpretación de los resultados. 

9. **Cuadros de Mando:** * Diseñar cuadros de mando que presenten los indicadores clave de rendimiento (KPIs) definidos en los objetivos del proyecto. 
   * Los cuadros de mando deben ser interactivos y permitir una navegación intuitiva entre diferentes niveles de detalle y filtros. 

10. **Documentación y Entrega:** * Presentar un informe detallado que incluya: 
      * Diseño: Modelos conceptual, lógico y físico del DataMart. 
      * Procesos ETL: Documentación del flujo ETL, herramientas utilizadas y transformación de datos. 
      * Cubos OLAP: Detalles de los cubos y dimensiones utilizadas. 
      * Reportes y Cuadros de Mando: Capturas de pantalla y explicación de los reportes y KPIs. 
    * Entregar el proyecto en formato digital, incluyendo scripts SQL, configuración de ETL, archivos de reportes y documentación en PDF. 

---

## Evaluación 

La evaluación se basará en: 
* **Calidad del Diseño (10%):** Definición del objetivo general, objetivos específicos, modelo conceptual, modelo lógico, tabla de hecho, dimensiones, métricas y grano. 
* **Carga del DataMart (30%):** Procesos ETL. 
* **Cubos y Reportes (30%):** Funcionalidad y utilidad de los cubos OLAP y reportes. 
* **Interactividad y Cuadros de Mando (30%):** Diseño y efectividad de los cuadros de mando.