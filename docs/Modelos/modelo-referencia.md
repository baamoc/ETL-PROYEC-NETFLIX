# Modelo de Referencia — Data Mart Netflix

Extraído de los tres diagramas aprobados por el profesor.
Este archivo es la fuente de verdad para estructuras y relaciones.

---

## DIMENSIONES

### dim_usuario
| Columna    | Tipo        | Constraint |
|------------|-------------|------------|
| id_usuario | INT         | PK         |
| edad       | INT         |            |
| genero     | VARCHAR(20) |            |

### dim_pais
| Columna    | Tipo         | Constraint |
|------------|--------------|------------|
| id_pais    | INT          | PK         |
| nombre_pais| VARCHAR(100) |            |

### dim_tiempo
| Columna       | Tipo | Constraint |
|---------------|------|------------|
| id_tiempo     | INT  | PK         |
| fecha_completa| DATE |            |
| dia           | INT  |            |
| mes           | INT  |            |
| anio          | INT  |            |

### dim_suscripcion
| Columna         | Tipo        | Constraint |
|-----------------|-------------|------------|
| id_suscripcion  | INT         | PK         |
| tipo_suscripcion| VARCHAR(30) |            |
| duracion_plan   | VARCHAR(30) |            |

### dim_dispositivo
| Columna           | Tipo        | Constraint |
|-------------------|-------------|------------|
| id_dispositivo    | INT         | PK         |
| nombre_dispositivo| VARCHAR(30) |            |

### dim_contenido
| Columna         | Tipo         | Constraint |
|-----------------|--------------|------------|
| id_contenido    | VARCHAR(20)  | PK         |
| titulo          | VARCHAR(255) |            |
| tipo_contenido  | VARCHAR(20)  |            |
| director        | VARCHAR(255) |            |
| elenco          | TEXT         |            |
| clasificacion   | VARCHAR(20)  |            |
| duracion        | VARCHAR(50)  |            |
| genero          | VARCHAR(255) |            |
| descripcion     | TEXT         |            |
| anio_lanzamiento| INT          |            |

---

## HECHOS

### fact_consumo
| Columna                 | Tipo        | Constraint                          |
|-------------------------|-------------|-------------------------------------|
| id_consumo              | INT         | PK                                  |
| id_usuario              | INT         | FK → dim_usuario.id_usuario         |
| id_contenido            | VARCHAR(20) | FK → dim_contenido.id_contenido     |
| id_pais                 | INT         | FK → dim_pais.id_pais               |
| id_tiempo               | INT         | FK → dim_tiempo.id_tiempo           |
| cantidad_visualizaciones| INT         |                                     |

### fact_ingresos
| Columna        | Tipo         | Constraint                              |
|----------------|--------------|-----------------------------------------|
| id_ingreso     | INT          | PK                                      |
| id_usuario     | INT          | FK → dim_usuario.id_usuario             |
| id_suscripcion | INT          | FK → dim_suscripcion.id_suscripcion     |
| id_dispositivo | INT          | FK → dim_dispositivo.id_dispositivo     |
| id_pais        | INT          | FK → dim_pais.id_pais                   |
| id_tiempo      | INT          | FK → dim_tiempo.id_tiempo               |
| ingreso_mensual| DECIMAL(10,2)|                                         |

---

## RELACIONES RESUMIDAS

```
dim_usuario      ──< fact_consumo
dim_contenido    ──< fact_consumo
dim_pais         ──< fact_consumo
dim_tiempo       ──< fact_consumo

dim_usuario      ──< fact_ingresos
dim_suscripcion  ──< fact_ingresos
dim_dispositivo  ──< fact_ingresos
dim_pais         ──< fact_ingresos
dim_tiempo       ──< fact_ingresos
```

---

## ORIGEN DE DATOS POR TABLA

| Tabla             | Dataset fuente                  |
|-------------------|---------------------------------|
| dim_usuario       | Netflix Userbase.csv            |
| dim_suscripcion   | Netflix Userbase.csv            |
| dim_dispositivo   | Netflix Userbase.csv            |
| dim_pais          | Ambos datasets                  |
| dim_tiempo        | Ambos datasets (fechas)         |
| dim_contenido     | NetFlix.csv                     |
| fact_ingresos     | Netflix Userbase.csv            |
| fact_consumo      | Ambos (derivado por país+fecha) |
