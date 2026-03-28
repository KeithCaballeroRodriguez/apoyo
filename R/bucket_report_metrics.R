#' Reporte de métricas de regresión por bucket de valor
#'
#' Equivalente a bucket_report_metrics() de Python.
#'
#' @param df data.frame con los datos.
#' @param y_true Character. Nombre de la columna real (denominador).
#' @param y_pred Character. Nombre de la columna predicha.
#' @param bins Numeric vector. Límites de los buckets. Por defecto rangos monetarios estándar.
#' @param labels Character vector. Etiquetas para cada bucket.
#' @param thr Numeric. Umbral de precisión (default 0.25 = ±25\%).
#' @param by Character vector. Columnas adicionales para desagregar.
#' @param bucket_on Character. "real" o "pred" (columna sobre la que se calculan los buckets).
#' @param add_metrics Logical. Si TRUE agrega MAPE y RMSE.
#' @param mape_scale Numeric. Multiplicador del MAPE (default 100 → porcentaje).
#'
#' @return data.frame con n, p_under, p_preci, p_over (y opcionalmente mape, rmse) por bucket.
#'
#' @importFrom dplyr select all_of mutate across if_else group_by summarise rename any_of n
#' @importFrom tidyr drop_na
#' @export
bucket_report_metrics <- function(
  df,
  y_true,
  y_pred,
  bins      = NULL,
  labels    = NULL,
  thr       = 0.25,
  by        = NULL,
  bucket_on = "real",
  add_metrics = FALSE,
  mape_scale  = 100
) {
  if (is.null(bins))   bins   <- c(-Inf, 60e3, 120e3, 300e3, 720e3, 1200e3, Inf)
  if (is.null(labels)) labels <- c("1__60k","2__60-120k","3__120-300k","4__300-720k","5__720-1.2M","6__1.2M+")

  by <- if (!is.null(by)) as.character(by) else character(0)

  if (!bucket_on %in% c("real", "pred"))
    stop("bucket_on debe ser 'real' o 'pred'")

  base_col <- if (bucket_on == "real") y_true else y_pred

  x <- df |>
    dplyr::select(dplyr::all_of(c(y_true, y_pred, by))) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(c(y_true, y_pred)), as.numeric)) |>
    tidyr::drop_na(dplyr::all_of(c(y_true, y_pred))) |>
    dplyr::mutate(
      .err    = .data[[y_pred]] - .data[[y_true]],
      .e      = dplyr::if_else(.data[[y_true]] != 0,
                               .data[[y_pred]] / .data[[y_true]] - 1,
                               NA_real_),
      .bucket = cut(.data[[base_col]],
                    breaks = bins, labels = labels,
                    include.lowest = TRUE, ordered_result = TRUE),
      .p      = abs(.e) <= thr,
      .su     = .e < -thr,
      .so     = .e >  thr
    )

  .do_summarise <- function(data, group_vars) {
    res <- data |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) |>
      dplyr::summarise(
        n       = dplyr::n(),
        p_under = mean(.su, na.rm = TRUE),
        p_preci = mean(.p,  na.rm = TRUE),
        p_over  = mean(.so, na.rm = TRUE),
        .mape_  = mean(abs(.e), na.rm = TRUE) * mape_scale,
        .rmse_  = sqrt(mean(.err^2, na.rm = TRUE)),
        .groups = "drop"
      )
    if (add_metrics) {
      res <- dplyr::rename(res, mape = .mape_, rmse = .rmse_)
    } else {
      res <- dplyr::select(res, -dplyr::any_of(c(".mape_", ".rmse_")))
    }
    res
  }

  agg <- .do_summarise(x, c(by, ".bucket")) |>
    dplyr::rename(bucket = .bucket)

  if (length(by) > 0) {
    tot <- .do_summarise(x, by) |>
      dplyr::mutate(bucket = "Total")
    agg <- dplyr::bind_rows(agg, tot[names(agg)])
  } else {
    tot <- .do_summarise(x, character(0)) |>
      dplyr::mutate(bucket = "Total")
    agg <- dplyr::bind_rows(agg, tot[names(agg)])
  }

  agg
}
