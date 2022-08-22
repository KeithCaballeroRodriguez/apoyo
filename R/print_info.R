#' @title Printing questions and labelled categories
#' @description This function takes data from labelled column types and print
#' information from each column.
#'
#' @param data Data with labelled column types
#'
#' @return
#' @export
#'
#' @examples
#' print_info(mtcars)
#'
print_info <- function(data,like=""){

  columnas <- colnames(data %>% select(where(is.labelled)))

  columnas <- columnas[str_detect(columnas,like)]

  for(i in columnas){

    col <- pull(data,all_of(i))

    pregunta <- attr(col, "label")

    etiq_v <- attr(col,"labels")

    etiq_n <- attr(etiq_v ,"names") # levels(col)

    cat(i,": ",pregunta,"\n")
    for(v in 1:length(etiq_v)){
      cat("\t",etiq_v[v]," - ",etiq_n[v],"\n")
    }

    cat(rep("_",30),"\n")
  }

}
