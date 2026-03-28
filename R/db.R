#' Crea una conexión DBI a PostgreSQL
#'
#' Equivalente a create_pg_engine() de Python (SQLAlchemy).
#'
#' @param config Named list o vector con las claves: USER, PWD, HOST, PORT, DBNAME.
#'   Puede cargarse con \code{dotenv::dotenv()} o \code{Sys.getenv()}.
#' @return Objeto de conexión DBI.
#'
#' @examples
#' \dontrun{
#' dotenv::load_dot_env(".env")
#' con <- pg_connect(list(
#'   USER   = Sys.getenv("USER"),
#'   PWD    = Sys.getenv("PWD"),
#'   HOST   = Sys.getenv("HOST"),
#'   PORT   = Sys.getenv("PORT"),
#'   DBNAME = Sys.getenv("DBNAME")
#' ))
#' DBI::dbGetQuery(con, "SELECT 1")
#' DBI::dbDisconnect(con)
#' }
#'
#' @importFrom DBI dbConnect
#' @importFrom RPostgres Postgres
#' @export
pg_connect <- function(config) {
  DBI::dbConnect(
    RPostgres::Postgres(),
    user     = config[["USER"]],
    password = config[["PWD"]],
    host     = config[["HOST"]],
    port     = as.integer(config[["PORT"]]),
    dbname   = config[["DBNAME"]]
  )
}
