# Evidencia ETL - Dimension Suscripcion

Pipeline:

- 02_ETL_DIM_SUSCRIPCION.hpl

Origen:

- staging.stg_netflix_userbase

Campos origen:

- "Subscription Type"
- "Plan Duration"

Destino:

- dm_streaming.dim_suscripcion

Campos destino:

- tipo_suscripcion
- duracion_plan

Flujo:

- Table input
- Select values
- String operations
- Filter rows
- Sort rows
- Unique rows
- Insert / update

Validacion SQL:

```sql
SELECT *
FROM dm_streaming.dim_suscripcion
ORDER BY id_suscripcion;
```

Resultado:

- 1 | Basic | 1 Month
- 2 | Premium | 1 Month
- 3 | Standard | 1 Month

Conteo:

```sql
SELECT COUNT(*) AS total_suscripciones
FROM dm_streaming.dim_suscripcion;
```

Resultado:

- total_suscripciones = 3

Conclusion:

La dimension suscripcion fue cargada correctamente mediante Apache Hop contra Neon.
