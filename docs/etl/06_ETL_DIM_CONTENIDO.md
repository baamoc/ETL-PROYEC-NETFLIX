# 06_ETL_DIM_CONTENIDO

## Propósito
Extrae el catálogo completo de títulos de Netflix desde staging, normaliza el tipo de contenido y el año de lanzamiento, y carga cada título como un registro único en la dimensión de contenido del Data Mart.

## Tabla destino
`dm_streaming.dim_contenido` — dimensión de contenido con los atributos descriptivos de cada título del catálogo.

## Fuente de datos
`staging.stg_netflix_titles` — todos los campos de catálogo. Solo se incluyen filas donde `show_id` no es nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | `Leer_STG_Contenido` | TableInput | Extrae los 10 campos de catálogo desde staging sin transformaciones en SQL. |
| 2 | `Sel_Campos_Contenido` | SelectValues | Selecciona los 10 campos necesarios para la dimensión. |
| 3 | `Limpiar_Textos_Contenido` | StringOperations | Aplica trim (both) a los 10 campos para eliminar espacios sobrantes visiblemente. |
| 4 | `Corregir_Textos_Contenido` | ReplaceString | Reemplaza strings vacíos en los 7 campos opcionales (`director`, `elenco`, `rating`, `duration`, `genres`, `description`, `release_year`) por `Sin dato`. |
| 5 | `JS_Normalizar_Contenido` | ScriptValueMod | Normaliza `type` a formato título controlado y convierte `release_year` de String a Integer con validación de rango; produce `tipo_contenido` y `anio_lanzamiento`. |
| 6 | `Sel_Campos_Final` | SelectValues | Renombra los campos de staging a los nombres del modelo DM y descarta campos intermedios. |
| 7 | `Ordenar_Contenido` | SortRows | Ordena ascendentemente por `id_contenido` para habilitar la deduplicación. |
| 8 | `Eliminar_Duplicados` | Unique | Elimina títulos duplicados usando `id_contenido` (originado en `show_id`) como clave. |
| 9 | `Validar_Contenido` | FilterRows | Descarta registros donde `id_contenido` es nulo tras la limpieza; la flecha verde continúa hacia la carga. |
| 10 | `Cargar_DIM_Contenido` | TableOutput | Inserta los registros válidos en `dm_streaming.dim_contenido` mediante bulk insert con batch de 1000. |

## Lógica destacada

### SQL de extracción
```sql
SELECT show_id, title, type, director, elenco, rating, duration, genres, description, release_year
FROM staging.stg_netflix_titles
WHERE show_id IS NOT NULL
```

### Transformación JS
El script realiza dos operaciones independientes:

**1. Normalización de `type` → `tipo_contenido` (String)**

Aplica lógica de formato controlado para preservar correctamente el caso de "TV Show":
- `'TV SHOW'` o `'TVSHOW'` → `'TV Show'`
- `'MOVIE'` → `'Movie'`
- Cualquier otro valor → primer carácter en mayúscula, resto en minúscula.
- Nulo o vacío → `'Sin dato'`.

**2. Conversión de `release_year` → `anio_lanzamiento` (Integer)**

Parsea el string con `parseInt` y aplica validación de rango: solo acepta valores entre 1901 y 2030 (exclusive). Valores fuera de rango o no numéricos producen `null`.

Campos producidos por el JS:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `tipo_contenido` | String | Tipo de contenido normalizado (`Movie` o `TV Show`). |
| `anio_lanzamiento` | Integer | Año de lanzamiento validado (1901–2030); `null` si no es parseable. |

### Mapeo de campos (staging → Data Mart)

| Campo staging | Campo DM | Notas |
|---------------|----------|-------|
| `show_id` | `id_contenido` | Clave natural de la dimensión. |
| `title` | `titulo` | Sin transformación. |
| `tipo_contenido` (JS) | `tipo_contenido` | Generado por el JS. |
| `director` | `director` | `Sin dato` si vacío. |
| `elenco` | `elenco` | `Sin dato` si vacío. |
| `rating` | `clasificacion` | `Sin dato` si vacío. |
| `duration` | `duracion` | `Sin dato` si vacío. |
| `genres` | `genero` | `Sin dato` si vacío. |
| `description` | `descripcion` | `Sin dato` si vacío. |
| `anio_lanzamiento` (JS) | `anio_lanzamiento` | Generado por el JS; puede ser `null`. |

### Criterio de carga
Se utiliza **TableOutput** con `use_batch=Y` y `commit=1000`. Configurado con `truncate=N`; la dimensión se carga en cada ejecución del workflow maestro. La clave natural de deduplicación previa a la carga es `id_contenido` (show_id), gestionada por el paso `Eliminar_Duplicados`.

## Resultado
Carga el catálogo completo de títulos únicos del dataset; se esperan aproximadamente **8800 registros** correspondientes a las películas y series del catálogo de Netflix presentes en `stg_netflix_titles`.
