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
3. Guardar evidencias en `docs/evidencias/`.
4. Actualizar `resumen-avance.md` si el avance cambia.
5. Registrar la actividad en la bitacora del dia.

## Evidencias minimas por pipeline

- Archivo `.hpl`.
- Captura del pipeline completo.
- Capturas de configuracion de pasos importantes.
- Log de ejecucion.
- Consulta SQL de validacion.
- Captura del resultado de validacion.
