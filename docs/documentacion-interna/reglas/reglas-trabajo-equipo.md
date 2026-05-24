# Reglas de trabajo en equipo

## Que se puede cambiar

- Scripts SQL en `sql/` con cambios estructurales.
- Pipelines en `pipelines/` con evidencias.
- Documentacion en `docs/`.

## Que NO se debe hacer

- No insertar datos manualmente en `dm_streaming`.
- No ejecutar `DROP`, `DELETE` o `TRUNCATE` sin autorizacion.
- No subir conexiones reales ni contrasenas.
- No modificar nombres de tablas finales sin aprobacion.

## Flujo de trabajo recomendado

1. Anunciar en el grupo que archivo vas a editar.
2. Trabajar en una tarea a la vez.
3. Dejar la validacion importante registrada en `docs/documentacion-interna/seguimiento/registros/`.
4. Actualizar `seguimiento/resumen-avance.md` si el avance cambia.
5. Registrar la actividad en el archivo del dia dentro de `seguimiento/registros/`.

## Tareas generales del equipo

1. Mantener actualizados los registros de pipelines terminados.
2. Confirmar que la carga a `staging` esta validada con conteos.
3. Actualizar `seguimiento/resumen-avance.md` con el estado real.

## Evidencias minimas por pipeline

- Archivo `.hpl`.
- Captura del pipeline completo.
- Capturas de configuracion de pasos importantes.
- Log de ejecucion.
- Consulta SQL de validacion.
- Captura del resultado de validacion.

## Regla de nombres en transformaciones

- Las transformaciones de Apache Hop (las "cajitas") deben tener nombres descriptivos segun la accion que realizan.
- Evitar nombres genericos como `Transform 1`, `Paso 2` o similares.

## Reglas de documentacion y carga

- Mantener siempre la documentacion actualizada, agregando solo la informacion importante y relevante del avance.
- Todo ETL que inserte datos debe evitar duplicados: un mismo dato no debe insertarse dos veces y la carga debe quedar protegida con la estrategia adecuada (`Unique rows`, `Insert / update`, claves naturales o control equivalente).
