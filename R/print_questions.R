#' @title Printing questions
#' @description This function takes data from labelled columns
#'
#' @param data Data with labelled column types
#'
#' @return
#' @export
#'
#' @examples
#' print_questions(mtcars)
#'
print_questions <- function(data) {
  tibble(
    variable = data %>%
      colnames()
  ) %>%
    mutate(
      questions = map(
        variable,
        ~attr(pull(data,all_of(.)),"label")
      )
    ) %>%
    unnest(questions,keep_empty = TRUE) %>%
    print(n=Inf)
}
