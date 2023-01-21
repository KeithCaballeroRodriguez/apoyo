transformer_dual_y_axis <- function(data,
                                    primary_column, secondary_column,
                                    include_y_zero = FALSE) {

  params_tbl <- data %>%
    summarise(
      max_primary   = max({{primary_column}},na.rm = T),
      min_primary   = min({{primary_column}},na.rm = T),
      max_secondary = max({{secondary_column}},na.rm = T),
      min_secondary = min({{secondary_column}},na.rm = T)
    )

  if (include_y_zero) {
    params_tbl$min_primary   <- 0
    params_tbl$min_secondary <- 0
  }

  params_tbl <- params_tbl %>%
    mutate(
      scale = (max_secondary - min_secondary) / (max_primary - min_primary),
      shift = min_primary - min_secondary
    )

  scale_func <- function(x) x * params_tbl$scale - params_tbl$shift

  inv_func <- function(x) (x + params_tbl$shift) / params_tbl$scale

  ret <- list(scale_func = scale_func,inv_func = inv_func,params_tbl = params_tbl)

  return(ret)
}
