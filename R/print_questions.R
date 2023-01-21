
print_questions <- function(data,save=F,printed=F) {
  re <- tibble(
    variable = data %>%
      colnames()
  ) %>%
    mutate(
      questions = map(
        variable,
        ~attr(pull(data,all_of(.)),"label")
      )
    ) %>%
    unnest(questions,keep_empty = TRUE)
  if(save){
    return(re)
  }else{
    re %>% print(n=Inf)
  }
}
