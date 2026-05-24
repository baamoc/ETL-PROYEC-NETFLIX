# Avance 2026-05-24 - ETL Dim Pais

Fecha: 2026-05-24

## Objetivo de la jornada

- Construir, ejecutar y validar `05_ETL_DIM_PAIS.hpl`.
- Cargar paises unicos en `dm_streaming.dim_pais`.
- Separar correctamente paises multiples provenientes del dataset de titulos.
- Confirmar que no existan duplicados ni valores nulos o vacios en la dimension.

## Pipeline validado

- Archivo: `pipelines/05_ETL_DIM_PAIS.hpl`
- Origen 1: `staging.stg_netflix_userbase.country`
- Origen 2: `staging.stg_netflix_titles.country`
- Destino: `dm_streaming.dim_pais.nombre_pais`

## Contexto importante

La dimension pais no podia cargarse directo desde `staging.stg_netflix_titles.country` porque existen registros con varios paises en una sola celda, por ejemplo:

```text
Argentina, Brazil, France
```

Por ese motivo, el pipeline separa por coma antes de insertar en `dm_streaming.dim_pais`.

## Como se hizo

Se unieron ambas fuentes con `UNION ALL`.

```sql
SELECT country AS pais_crudo
FROM staging.stg_netflix_userbase
WHERE country IS NOT NULL

UNION ALL

SELECT country AS pais_crudo
FROM staging.stg_netflix_titles
WHERE country IS NOT NULL;
```

### Flujo en Apache Hop

- TI_STG_PAIS
- SPLIT_PAISES
- SV_RENOMBRAR_CAMPO
- SO_LIMPIAR_TEXTO
- FR_VALIDAR_PAIS
- SR_ORDENAR_PAIS
- UR_UNICOS_PAIS
- IU_DIM_PAIS

### Detalle de transformaciones

**1. TI_STG_PAIS**

Extrae paises desde staging con UNION ALL.

Campo generado: `pais_crudo`

**2. SPLIT_PAISES**

Separa paises multiples por coma.

- Campo a separar: `pais_crudo`
- Delimitador: `,`
- Campo de salida: `pais_separado`

**3. SV_RENOMBRAR_CAMPO**

- `pais_separado` -> `nombre_pais`

**4. SO_LIMPIAR_TEXTO**

- Campo: `nombre_pais`
- Trim type: `both`
- Out stream field: vacio

**5. FR_VALIDAR_PAIS**

Condicion aplicada:

- `nombre_pais IS NOT NULL`

La validacion de vacios se hizo luego con SQL.

**6. SR_ORDENAR_PAIS**

Orden por `nombre_pais ASC`

**7. UR_UNICOS_PAIS**

Elimina repetidos por `nombre_pais`.

**8. IU_DIM_PAIS**

- Tabla: `dm_streaming.dim_pais`
- Lookup: `nombre_pais`
- No insertar `id_pais` (autogenerado)

## Problema encontrado

Error en FR_VALIDAR_PAIS:

```
String : Second meta data (meta2) is null
```

Se elimino la condicion de vacio en Hop y se valido despues con SQL.

## Validaciones finales

**Conteo total**

```sql
SELECT COUNT(*) AS total_paises
FROM dm_streaming.dim_pais;
```

Resultado: `total_paises = 117`

**Revision visual**

```sql
SELECT *
FROM dm_streaming.dim_pais
ORDER BY nombre_pais;
```

**Duplicados**

```sql
SELECT nombre_pais, COUNT(*) AS repeticiones
FROM dm_streaming.dim_pais
GROUP BY nombre_pais
HAVING COUNT(*) > 1;
```

Resultado: `0 filas`

**Nulos o vacios**

```sql
SELECT *
FROM dm_streaming.dim_pais
WHERE nombre_pais IS NULL
   OR TRIM(nombre_pais) = '';
```

Resultado: `0 filas`

## Resultado final

`05_ETL_DIM_PAIS.hpl` cargo 117 paises unicos en `dm_streaming.dim_pais`.



