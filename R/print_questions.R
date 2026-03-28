
#' Retorna o imprime el mapeo variable -> pregunta/descripción
#'
#' Equivalente a get_variable_labels() de Python.
#' Antes llamado \code{print_questions}.
#'
#' @param data data.frame con columnas labelled (leído con haven).
#' @param save Logical. Si TRUE retorna un tibble; si FALSE imprime en consola.
#' @return tibble con columnas \code{variable} y \code{questions}, o NULL si \code{save = FALSE}.
#'
#' @importFrom dplyr tibble mutate
#' @importFrom purrr map
#' @importFrom tidyr unnest
#' @export
get_variable_labels <- function(data, save = FALSE) {
  re <- dplyr::tibble(variable = colnames(data)) |>
    dplyr::mutate(
      questions = purrr::map(variable, ~ attr(dplyr::pull(data, dplyr::all_of(.)), "label"))
    ) |>
    tidyr::unnest(questions, keep_empty = TRUE)

  if (save) re else print(re, n = Inf)
}
