# Guia de colaboracion del proyecto DW Netflix

Esta guia resume como trabajar en el proyecto sin romper la base, sin duplicar trabajo y sin dejar pipelines sin contexto.

## 1. Reglas obligatorias

1. No insertar datos manualmente en `dm_streaming`.
2. No ejecutar `DROP`, `DELETE` ni `TRUNCATE` sin autorizacion.
3. Todo pipeline debe partir desde `staging`.
4. Todo cambio estructural debe ir en un script SQL.
5. No modificar nombres de tablas finales sin aprobacion.
6. No tocar tablas de hechos si las dimensiones necesarias no estan validadas.
7. Todo pipeline debe dejar evidencia documentada.
8. Todo cambio debe subirse a Git.
9. No subir contrasenas.
10. No subir archivos `.env` reales.
11. No subir backups pesados.
12. No subir datasets grandes sin autorizacion.

## 2. Estructura del proyecto

| Carpeta | Uso |
| --- | --- |
| `sql/` | Scripts de creacion y validacion |
| `pipelines/` | Pipelines de Apache Hop |
| `workflows/` | Workflows de Apache Hop |
| `docs/documentacion-interna/` | Documentacion operativa del equipo |
| `docs/informe-oficial/` | Informe formal de la presentacion |
| `dashboard/` | Archivos del dashboard |
| `data/` | Datos de ejemplo o referencias |
| `datasets/` | Datasets usados localmente |

## 3. Entrega minima por pipeline

Cada pipeline debe dejar como minimo:

1. Archivo `.hpl`.
2. Captura del pipeline completo.
3. Capturas de configuracion de pasos importantes.
4. Log de ejecucion.
5. Consulta SQL de validacion.
6. Resultado o conteo final.

Si no hay una carpeta separada de evidencias, esa informacion debe quedar documentada en el registro correspondiente dentro de `docs/documentacion-interna/seguimiento/registros/`.

## 4. Estado de trabajo del bloque ETL

Primera ronda:

- `01_ETL_DIM_DISPOSITIVO.hpl` -> validado
- `02_ETL_DIM_SUSCRIPCION.hpl` -> validado
- `03_ETL_DIM_USUARIO.hpl` -> validado
- `04_ETL_DIM_TIEMPO.hpl` -> validado
- `05_ETL_DIM_PAIS.hpl` -> validado
- `06_ETL_DIM_CONTENIDO.hpl` -> validado

Segunda ronda:

- `07_ETL_FACT_INGRESOS.hpl` -> validado
- `08_ETL_FACT_CONSUMO.hpl` -> validado
- `00_RUN_ETL_COMPLETO.hwf`

## 5. Flujo visual recomendado en dimensiones

Cuando aplique, usar este orden:

1. `Table input`
2. `Select values`
3. `String operations`
4. `Filter rows`
5. `Sort rows`
6. `Unique rows`
7. `Insert / update`

Para tablas de hechos el flujo puede variar porque probablemente habra joins, busquedas o logica de negocio adicional.

## 6. Validacion minima

Cada pipeline debe tener una consulta SQL de validacion.

Ejemplo para `dim_dispositivo`:

```sql
SELECT *
FROM dm_streaming.dim_dispositivo
ORDER BY id_dispositivo;
```

## 7. Riesgos conocidos

### dim_pais

No cargar directamente paises multiples en una sola fila.

Si el campo contiene:

- `Argentina, Brazil, France`

entonces hay que separarlo en registros individuales antes de cargar la dimension.

### fact_consumo

No existe una relacion natural entre usuarios y contenidos.

La logica de consumo debe ser simulada, controlada y explicada.
