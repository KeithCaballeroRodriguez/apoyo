#' Normaliza un texto a snake_case sin acentos ni caracteres especiales
#'
#' Equivalente a clean_string() de Python.
#'
#' @param txt Character. Texto a normalizar.
#' @return Character en snake_case minúsculas.
#'
#' @examples
#' clean_string("  Hola Mundo! ")   # "hola_mundo"
#' clean_string("Ñoño & Co.")       # "nono_&_co"
#'
#' @importFrom stringi stri_trans_general
#' @importFrom stringr str_replace_all str_squish
#' @export
clean_string <- function(txt) {
  txt <- as.character(txt)
  txt <- stringi::stri_trans_general(txt, "Latin-ASCII")
  txt <- stringr::str_replace_all(txt, "[^0-9a-zA-Z&_.]+", " ")
  txt <- stringr::str_squish(txt)
  txt <- stringr::str_replace_all(tolower(txt), " ", "_")
  txt
}
