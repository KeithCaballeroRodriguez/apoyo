# apoyo <img src="https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white" align="right"/>

Paquete R con funciones auxiliares para analistas que trabajan con datos provenientes de **encuestas etiquetadas** (SPSS/Stata vía `haven`) y para la **visualización consistente** de resultados con `ggplot2`.

**Autor:** Keith Caballero Rodriguez — Asociado de Analytics · Estadístico
[![LinkedIn](https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/keith-caballero-rodriguez/)

---

## Instalación

```r
# Instalar desde GitHub
remotes::install_github("KeithCaballeroRodriguez/apoyo")
```

---

## Funciones

### Exploración de datos etiquetados

| Función | Descripción |
|---------|-------------|
| `print_questions(data)` | Extrae y muestra los labels de columna como tibble. Útil para inventariar qué representa cada variable. |
| `print_info(data, like = NULL)` | Muestra metadata detallada: nombre de columna, label de pregunta y mapeos valor → etiqueta. Acepta filtro por nombre de columna. |

```r
# Ver todas las preguntas del dataset
print_questions(encuesta)

# Buscar columnas que contienen "ingreso"
print_info(encuesta, like = "ingreso")
```

### Temas ggplot2

| Función | Descripción |
|---------|-------------|
| `theme_apoyo(fuente = "Roboto")` | Tema basado en `theme_light()`: texto bold 14pt, ejes negros, sin gridlines ni bordes de panel. |
| `theme_keith(fuente = "Roboto")` | Variante personal del tema con la misma estructura. |

```r
ggplot(data, aes(x, y)) +
  geom_bar(stat = "identity") +
  theme_apoyo()
```

### Visualización con doble eje

| Función | Descripción |
|---------|-------------|
| `qdoubleaxis(data, x_axis, y_axis, y2_axis, ...)` | Gráfico de líneas con eje Y doble. Maneja el escalado automáticamente. |
| `transformer_dual_y_axis(...)` | Función interna de escalado utilizada por `qdoubleaxis`. |

```r
qdoubleaxis(
  data = df,
  x_axis = "mes",
  y_axis = "ventas",
  y2_axis = "precio",
  t1 = "Ventas (miles)",
  t2 = "Precio promedio"
)
```

### Datos incluidos

| Dataset | Descripción |
|---------|-------------|
| `paleta_apoyo` | Paleta de colores nombrada para uso consistente en gráficos. |

---

## Dependencias

`dplyr`, `ggplot2`, `haven`, `tidyr`, `purrr`, `scales`, `tidyselect`, `extrafont`

---

## Contexto

Desarrollado durante proyectos de análisis de encuestas en sectores de banca, consumo masivo y pesca. Las funciones `print_questions` / `print_info` resuelven el flujo de exploración típico al trabajar con archivos SPSS importados via `haven`, donde los labels son metadata crítica para entender el cuestionario.
