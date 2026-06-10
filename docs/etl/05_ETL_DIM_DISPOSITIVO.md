# 05_ETL_DIM_DISPOSITIVO

## Propósito
Extrae los tipos de dispositivo de reproducción registrados en la base de usuarios, los normaliza a formato título y los carga como dimensión en el Data Mart.

## Tabla destino
`dm_streaming.dim_dispositivo` — dimensión de dispositivo con el nombre normalizado del tipo de dispositivo.

## Fuente de datos
`staging.stg_netflix_userbase` — columna `device`. Solo se incluyen filas donde `device` no es nulo.

## Flujo de transformación

| # | Transform | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | `Leer_STG_Dispositivos` | TableInput | Extrae la columna `device` sin transformaciones en SQL. |
| 2 | `Sel_Campos_Dispositivo` | SelectValues | Conserva únicamente el campo `device` del stream. |
| 3 | `Limpiar_Textos_Dispositivo` | StringOperations | Aplica trim (both) al campo `device` para eliminar espacios sobrantes. |
| 4 | `Corregir_Textos_Dispositivo` | ReplaceString | Reemplaza strings vacíos (`^\s*$`) en `device` por `Sin dato`. |
| 5 | `JS_Normalizar_Dispositivo` | ScriptValueMod | Convierte el nombre del dispositivo a formato título palabra por palabra y produce `nombre_dispositivo` (String). |
| 6 | `Sel_Campos_Final` | SelectValues | Conserva únicamente `nombre_dispositivo` con el nombre del modelo DM. |
| 7 | `Ordenar_Dispositivos` | SortRows | Ordena ascendentemente por `nombre_dispositivo` para habilitar la deduplicación. |
| 8 | `Eliminar_Duplicados` | Unique | Elimina dispositivos duplicados usando `nombre_dispositivo` como clave. |
| 9 | `Validar_Dispositivo` | FilterRows | Descarta registros donde `nombre_dispositivo` quedó nulo tras la normalización; la flecha verde continúa hacia la carga. |
| 10 | `Cargar_DIM_Dispositivo` | TableOutput | Inserta los registros válidos en `dm_streaming.dim_dispositivo` mediante bulk insert con batch de 1000. |

## Lógica destacada

### SQL de extracción
```sql
SELECT device
FROM staging.stg_netflix_userbase
WHERE device IS NOT NULL
```

### Transformación JS
El script aplica proper case palabra por palabra sobre el valor de `device`, manejando el caso en que el campo llegue como `Sin dato` o nulo:

```javascript
var nombre_dispositivo = 'Sin dato';
if (device != null && device.trim() != '' && device.trim() != 'Sin dato') {
  var words = device.trim().split(' ');
  var result = [];
  for (var i = 0; i < words.length; i++) {
    if (words[i].length > 0) {
      result.push(words[i].charAt(0).toUpperCase() + words[i].substring(1).toLowerCase());
    }
  }
  nombre_dispositivo = result.join(' ');
}
```

Produce el campo:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `nombre_dispositivo` | String | Nombre del dispositivo normalizado (ej. `Smart Tv`, `Laptop`, `Tablet`, `Smartphone`). |

### Criterio de carga
Se utiliza **TableOutput** con `use_batch=Y` y `commit=1000`. Configurado con `truncate=N`; la dimensión se carga en cada ejecución del workflow maestro. Dado el volumen reducido de tipos de dispositivo distintos, el bulk insert es suficiente y más eficiente que InsertUpdate en Neon.

## Resultado
Carga los tipos de dispositivo únicos presentes en el dataset de usuarios; se esperan entre 4 y 5 registros distintos (Smartphone, Laptop, Smart Tv, Tablet y similares).
