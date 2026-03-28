#' Lee un archivo Parquet desde Google Cloud Storage
#'
#' Equivalente a read_parquet_gcp() de Python.
#'
#' @param gcp_path Character. Path en formato "bucket/path/to/file.parquet".
#' @return data.frame
#'
#' @importFrom googleCloudStorageR gcs_get_object
#' @importFrom arrow read_parquet
#' @export
read_parquet_gcp <- function(gcp_path) {
  parts       <- .parse_gcp_path(gcp_path)
  tmp         <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp))
  googleCloudStorageR::gcs_get_object(
    object_name = parts$prefix,
    bucket      = parts$bucket,
    saveToDisk  = tmp,
    overwrite   = TRUE
  )
  arrow::read_parquet(tmp)
}

#' Escribe un data.frame como Parquet en Google Cloud Storage
#'
#' Equivalente a write_parquet_gcp() de Python.
#'
#' @param df data.frame a guardar.
#' @param gcp_path Character. Path destino en formato "bucket/path/to/file.parquet".
#'
#' @importFrom googleCloudStorageR gcs_upload
#' @importFrom arrow write_parquet
#' @export
write_parquet_gcp <- function(df, gcp_path) {
  parts <- .parse_gcp_path(gcp_path)
  tmp   <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp))
  arrow::write_parquet(df, tmp, compression = "gzip")
  googleCloudStorageR::gcs_upload(tmp, bucket = parts$bucket, name = parts$prefix)
}

#' Lista archivos en un path de Google Cloud Storage
#'
#' Equivalente a list_files_gcp() de Python.
#'
#' @param gcp_path Character. Path en formato "bucket/prefijo/".
#' @param kwd Character. Filtro opcional por keyword en el nombre del archivo.
#' @return Character vector con los nombres de los blobs.
#'
#' @importFrom googleCloudStorageR gcs_list_objects
#' @export
list_files_gcp <- function(gcp_path, kwd = NULL) {
  parts <- .parse_gcp_path(gcp_path)
  files <- googleCloudStorageR::gcs_list_objects(
    bucket = parts$bucket,
    prefix = parts$prefix
  )
  names <- files$name
  if (!is.null(kwd)) names <- names[grepl(kwd, names, fixed = TRUE)]
  names
}

# Helper interno: separa bucket y prefix de un gcp_path
.parse_gcp_path <- function(gcp_path) {
  parts  <- strsplit(gcp_path, "/", fixed = TRUE)[[1]]
  bucket <- parts[1]
  prefix <- paste(parts[-1], collapse = "/")
  list(bucket = bucket, prefix = prefix)
}
