# Proyecto Data Warehouse Netflix — Reglas de trabajo

## Regla principal: siempre trabajar con datos reales

Antes de proponer cualquier estructura, columna, transformación o valor:

1. Verificar contra `datasets/NetFlix.csv` y `datasets/Netflix Userbase.csv`
2. Verificar contra `docs/Nexflix-Estructura-del-proyecto.md` (modelo aprobado por el profesor)

**No inventar nada.** Si un dato no está en los CSVs o en el documento, no se asume.

## Fuentes de verdad

| Qué | Dónde |
|-----|-------|
| Estructura del DW (dimensiones, hechos, columnas) | `docs/modelos/modelo-referencia.md` (fuente principal) |
| Modelos aprobados (imágenes originales) | `docs/Modelos/` |
| Pipelines de referencia del licenciado | `docs/Imagenes-Referencia/` (1.png–7.png + Workflow.png) |
| Datos de contenido Netflix | `datasets/NetFlix.csv` |
| Datos de usuarios | `datasets/Netflix Userbase.csv` |
| Consigna del proyecto | `docs/Consigna_Proyecto_Base_de_Datos_3.md` |

## Estándar de pipelines Apache Hop

### Patrón obligatorio para pipelines de DIMENSIONES (9 pasos mínimo)

Cada pipeline de dimensión debe seguir este orden exacto de transforms visibles.
No meter lógica de transformación dentro del SQL del TableInput — eso hace el pipeline invisible.

1. **`TableInput`** — Extracción desde staging. SQL simple: SELECT campos FROM staging.tabla WHERE campo IS NOT NULL. Sin CAST, sin cálculos.
2. **`SelectValues`** — Seleccionar solo los campos necesarios para esa dimensión.
3. **`StringOperations`** — Limpieza visible: trim en todos los campos string. Paso separado, no en SQL.
4. **`ReplaceString`** — Corrección de valores: reemplazar nulos o strings vacíos por "Sin dato" en campos opcionales.
5. **`ScriptValueMod`** — Transformación JS (cajita verde JS): normalización de formato (proper case), conversión de tipos (String→Integer), parsing de fechas, cálculo de campos derivados. **Obligatorio en todos los pipelines.**
6. **`SelectValues`** — Conservar solo los campos generados por el JS y renombrarlos a los nombres del modelo DM.
7. **`SortRows`** — Ordenar por clave natural antes de deduplicar.
8. **`Unique`** — Eliminar duplicados. Requiere que el stream venga ordenado.
9. **`FilterRows`** — Validar que el campo clave no sea nulo. Flecha verde al paso de carga.
10. **`InsertUpdate`** — Upsert usando la clave natural de la dimensión.

### Patrón obligatorio para pipelines de HECHOS

Los pipelines de hechos son más complejos. Basado en `docs/Imagenes-Referencia/7.png`:

1. **`TableInput`** — Extracción desde staging.
2. **`SelectValues`** — Seleccionar campos del hecho.
3. **`StringOperations`** — Trim de campos string.
4. **`ReplaceString`** — Corregir textos (ej: vacíos → "Sin dato").
5. **`IfNull`** o **`ReplaceString`** — Reemplazar nulos en campos de medida por valor por defecto.
6. **`FilterRows`** — Filtrar registros válidos (rango de fechas, campos obligatorios). Flecha verde continúa.
7. **`StreamLookup`** × N — Un Stream Lookup por cada FK: buscar id_usuario, id_suscripcion, id_dispositivo, id_pais, id_tiempo buscando en las dimensiones ya cargadas.
8. **`Calculator`** — Calcular campos derivados (totales, IDs compuestos, extracción de partes de fecha).
9. **`SelectValues`** — Conservar solo los campos finales del hecho.
10. **`InsertUpdate`** — Insertar en la tabla de hechos.

### Naming de transforms

- Nombres descriptivos, en español, separados por `_`
- Seguir el estilo de los ejemplos del licenciado:
  - Extracción: `Leer_STG_Usuario`, `CSV_Ventas`
  - Limpieza: `Limpiar_Textos_Usuario`, `Corregir_Textos_Suscripcion`
  - JS: `JS_Normalizar_Suscripcion`, `JS_Fecha`, `JS_Convertir_Usuario`
  - Lookups: `Buscar_id_pais`, `Buscar_id_tiempo`, `SL_Suscripcion`
  - Cálculo: `Calcular_Partes_Fecha`, `Calcular_ingreso_mensual`
  - Carga: `Cargar_DIM_Suscripcion`, `Cargar_FACT_Ingresos`

### Comentarios en pipelines

- Usar el campo `<description>` en cada transform para explicar qué hace
- Obligatorio en: FilterRows (qué filtra), ScriptValueMod (qué transforma), StreamLookup (qué dimensión busca)
- No comentar cajitas triviales (SelectValues de solo rename)

### TableOutput vs InsertUpdate

- **Staging (00_LOAD_*)**: usar `TableOutput` con `truncate=Y`, `use_batch=Y`, `commit=1000` — carga rápida sin lookup
- **Dimensiones (01-06)**: usar `InsertUpdate` con clave natural como lookup key — upsert seguro
- **Hechos (07-08)**: usar `InsertUpdate` — upsert por combinación de FKs

## Workflow maestro

El entregable final del punto 6 es un **workflow** que:
- Tiene un `Start` inicial
- Verifica condición previa (ej: `File exists` o similar)
- Ejecuta los pipelines en orden: dims primero, hechos al final
- Maneja errores (rama naranja/roja para fallos)
- Ver referencia: `docs/Imagenes-Referencia/Workflow.png`

## Contexto del proyecto

- **Herramienta ETL**: Apache Hop
- **Base de datos**: PostgreSQL en Neon (`neondb`)
- **Esquemas**: `staging` (datos crudos) y `dm_streaming` (Data Mart final)
- **Conexión**: `Proyecto-Neonbd`
- **Presentación 1** (puntos 1-5): COMPLETA — modelos aprobados
- **Presentación 2** (puntos 6-10): EN CURSO
  - Punto 6 (ETL): EN PROGRESO — staging cargado, dims en construcción
  - Puntos 7-10: pendientes
