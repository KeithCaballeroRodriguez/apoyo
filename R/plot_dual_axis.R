#' Gráfico de líneas con doble eje Y
#'
#' Equivalente a plot_dual_axis() de Python (matplotlib).
#' Antes llamado \code{qdoubleaxis}.
#'
#' @param data data.frame con los datos.
#' @param x_axis Columna para el eje X (unquoted).
#' @param y_axis Columna para el eje Y izquierdo (unquoted).
#' @param y2_axis Columna para el eje Y derecho (unquoted).
#' @param t1 Character. Etiqueta del eje Y izquierdo.
#' @param t2 Character. Etiqueta del eje Y derecho.
#' @param coeff Numeric. Coeficiente de escala (heredado, no usado directamente).
#' @param zero Logical. Si TRUE fuerza el origen en 0 en ambos ejes.
#' @param color1 Color de la línea primaria (default azul oscuro).
#' @param color2 Color de la línea secundaria (default azul claro).
#' @return ggplot object.
#'
#' @importFrom ggplot2 ggplot aes geom_line scale_y_continuous sec_axis
#' @importFrom scales comma_format
#' @export
plot_dual_axis <- function(
  data,
  x_axis, y_axis, y2_axis,
  t1, t2,
  coeff,
  zero   = FALSE,
  color1 = "#1f497d",
  color2 = "#4ba3e7"
) {
  transformer <- .dual_axis_scaler(
    data             = data,
    primary_column   = {{ y_axis }},
    secondary_column = {{ y2_axis }},
    include_y_zero   = zero
  )

  ggplot2::ggplot(data, ggplot2::aes(x = {{ x_axis }})) +
    ggplot2::geom_line(ggplot2::aes(y = {{ y_axis }}),
                       color = color1, linewidth = 1.2, alpha = 0.8) +
    ggplot2::geom_line(ggplot2::aes(y = transformer$inv_func({{ y2_axis }})),
                       color = color2, linewidth = 1.2, alpha = 0.8) +
    ggplot2::scale_y_continuous(
      name     = t1,
      labels   = scales::comma_format(),
      sec.axis = ggplot2::sec_axis(
        trans  = ~ transformer$scale_func(.),
        name   = t2,
        labels = scales::comma_format()
      )
    )
}

# Helper interno: calcula funciones de escala para el doble eje Y
.dual_axis_scaler <- function(data, primary_column, secondary_column, include_y_zero = FALSE) {
  params <- data |>
    dplyr::summarise(
      max_primary   = max({{ primary_column }},   na.rm = TRUE),
      min_primary   = min({{ primary_column }},   na.rm = TRUE),
      max_secondary = max({{ secondary_column }}, na.rm = TRUE),
      min_secondary = min({{ secondary_column }}, na.rm = TRUE)
    )

  if (include_y_zero) {
    params$min_primary   <- 0
    params$min_secondary <- 0
  }

  params <- params |>
    dplyr::mutate(
      scale = (max_secondary - min_secondary) / (max_primary - min_primary),
      shift = min_primary - min_secondary
    )

  list(
    scale_func = function(x) x * params$scale - params$shift,
    inv_func   = function(x) (x + params$shift) / params$scale,
    params     = params
  )
}
