# Proyecto Data Warehouse Netflix — BD3

**Herramienta ETL**: Apache Hop  
**Base de datos**: PostgreSQL (Neon serverless) — conexión `Proyecto-Neonbd`  
**Esquemas**: `staging` (datos crudos) · `dm_streaming` (Data Mart final)

---

## Estado del proyecto

| Punto | Descripción | Estado |
|-------|-------------|--------|
| 1–5 | Modelo de datos, consigna, diseño del DW | ✅ Completo (Presentación 1) |
| 6 | Pipelines ETL + Workflow maestro | ✅ Completo (Presentación 2) |
| 7–10 | Pendientes | 🔲 |

---

## Estructura del repositorio

```
├── datasets/                    # Fuentes de datos originales
│   ├── NetFlix.csv              # Títulos Netflix (~8000 registros)
│   └── Netflix Userbase.csv    # Usuarios (~2500 registros)
│
├── pipelines/                   # Pipelines Apache Hop (.hpl)
│   ├── UTIL_TRUNCATE_DM.hpl    # Trunca todas las tablas del DM
│   ├── 01_ETL_DIM_SUSCRIPCION.hpl
│   ├── 02_ETL_DIM_USUARIO.hpl
│   ├── 03_ETL_DIM_PAIS.hpl
│   ├── 04_ETL_DIM_TIEMPO.hpl
│   ├── 05_ETL_DIM_DISPOSITIVO.hpl
│   ├── 06_ETL_DIM_CONTENIDO.hpl
│   ├── 07_ETL_FACT_INGRESOS.hpl
│   └── 08_ETL_FACT_CONSUMO.hpl
│
├── workflows/
│   └── WF_MASTER_ETL.hwf       # Workflow maestro — ejecuta todo en orden
│
├── docs/
│   ├── etl/                    # Documentación técnica del ETL (punto 6)
│   │   ├── 00_RESUMEN_GENERAL.md
│   │   ├── UTIL_TRUNCATE_DM.md
│   │   ├── 01_ETL_DIM_SUSCRIPCION.md
│   │   ├── 02_ETL_DIM_USUARIO.md
│   │   ├── 03_ETL_DIM_PAIS.md
│   │   ├── 04_ETL_DIM_TIEMPO.md
│   │   ├── 05_ETL_DIM_DISPOSITIVO.md
│   │   ├── 06_ETL_DIM_CONTENIDO.md
│   │   ├── 07_ETL_FACT_INGRESOS.md
│   │   ├── 08_ETL_FACT_CONSUMO.md
│   │   ├── WF_MASTER_ETL.md
│   │   └── verificar_dm_streaming.sql  # Consultas de verificación
│   ├── modelos/                # Modelo de referencia del DW
│   └── Imagenes-Referencia/    # Imágenes de referencia del licenciado
│
└── metadata/                   # Configuración Apache Hop
```

---

## Data Mart — Tablas y registros

| Tabla | Tipo | Registros | Descripción |
|-------|------|-----------|-------------|
| `dim_suscripcion` | Dimensión | 3 | Tipos de plan: Basic, Standard, Premium |
| `dim_usuario` | Dimensión | 2500 | Usuarios con edad y país |
| `dim_pais` | Dimensión | 10 | Países únicos normalizados |
| `dim_tiempo` | Dimensión | 1822 | Fechas únicas con día, mes y año |
| `dim_dispositivo` | Dimensión | 4 | Smartphone, Tablet, Smart TV, Laptop |
| `dim_contenido` | Dimensión | 7787 | Títulos Netflix con tipo y año |
| `fact_ingresos` | Hecho | 2500 | Un registro por usuario — ingreso mensual |
| `fact_consumo` | Hecho | 5000 | Visualizaciones derivadas por coincidencia de país |

---

## Cómo ejecutar el ETL

1. Abrir Apache Hop
2. Abrir `workflows/WF_MASTER_ETL.hwf`
3. Presionar **Play**

El workflow ejecuta automáticamente los 9 pipelines en orden correcto.  
Duración total aproximada: **~85 segundos**.

---

## Cómo verificar los datos

Ejecutar `docs/etl/verificar_dm_streaming.sql` en la consola de Neon (neon.tech):

- **Sección 1**: conteo general de todas las tablas
- **Sección 2**: muestra de datos por dimensión
- **Sección 3**: muestra de hechos con JOINs a dimensiones
- **Sección 4**: verificación de integridad referencial (debe devolver 0 en todo)
- **Sección 5**: consultas de análisis de negocio

---

## Documentación técnica

Ver [`docs/etl/00_RESUMEN_GENERAL.md`](docs/etl/00_RESUMEN_GENERAL.md) como punto de entrada.
