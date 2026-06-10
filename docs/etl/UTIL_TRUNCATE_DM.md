# UTIL_TRUNCATE_DM

## Propósito
Utilidad de mantenimiento que trunca todas las tablas del Data Mart en el orden correcto (tablas de hechos primero, luego dimensiones) para permitir una recarga completa sin violar restricciones de clave foránea.

## Tabla destino
`dm_streaming.*` — aplica sobre las tablas `fact_consumo`, `fact_ingresos`, `dim_usuario`, `dim_pais`, `dim_dispositivo`, `dim_tiempo`, `dim_contenido` y `dim_suscripcion`.

## Fuente de datos
No aplica — este pipeline no lee datos de origen. Genera una fila vacía de forma interna para disparar la ejecución del script SQL.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | Generar_Fila | RowGenerator | Genera una única fila vacía para activar el paso siguiente. |
| 2 | Truncar_Tablas_DM | ExecSQL | Ejecuta un TRUNCATE sobre las ocho tablas del DM con CASCADE en una sola sentencia. |

## Lógica destacada

### SQL de ejecución

```sql
TRUNCATE dm_streaming.fact_consumo,
         dm_streaming.fact_ingresos,
         dm_streaming.dim_usuario,
         dm_streaming.dim_pais,
         dm_streaming.dim_dispositivo,
         dm_streaming.dim_tiempo,
         dm_streaming.dim_contenido,
         dm_streaming.dim_suscripcion
CASCADE
```

### Criterio de carga
No realiza carga de datos. Utiliza `ExecSQL` configurado con `execute_each_row=N`, por lo que la sentencia se ejecuta una sola vez independientemente del número de filas entrantes. La opción `CASCADE` garantiza que las dependencias de clave foránea no bloqueen el truncado.

## Resultado
Al finalizar, todas las tablas del esquema `dm_streaming` quedan vacías y listas para recibir una nueva carga ETL completa.
