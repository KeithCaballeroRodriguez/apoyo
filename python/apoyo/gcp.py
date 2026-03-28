from io import BytesIO

import pandas as pd
from google.cloud import storage


def _parse_gcp_path(gcp_path: str) -> tuple[str, str]:
    """Separa un path GCS en (bucket_name, prefix)."""
    parts = gcp_path.split("/", 1)
    bucket_name = parts[0]
    prefix = parts[1] if len(parts) > 1 else ""
    return bucket_name, prefix


def read_parquet_gcp(gcp_path: str) -> pd.DataFrame:
    """
    Lee un archivo Parquet desde GCS.

    Parameters
    ----------
    gcp_path : str
        Path en formato 'bucket/path/to/file.parquet'.

    Returns
    -------
    pd.DataFrame
    """
    bucket_name, prefix = _parse_gcp_path(gcp_path)
    cli = storage.Client()
    data = cli.bucket(bucket_name).get_blob(prefix).download_as_bytes()
    return pd.read_parquet(BytesIO(data))


def write_parquet_gcp(df: pd.DataFrame, gcp_path: str) -> None:
    """
    Escribe un DataFrame como Parquet en GCS.

    Parameters
    ----------
    df : pd.DataFrame
    gcp_path : str
        Path destino en formato 'bucket/path/to/file.parquet'.
    """
    bucket_name, prefix = _parse_gcp_path(gcp_path)
    buf = BytesIO()
    df.to_parquet(buf, engine="pyarrow")
    buf.seek(0)
    storage.Client().bucket(bucket_name).blob(prefix).upload_from_file(buf)


def list_files_gcp(gcp_path: str, kwd: str = None) -> list[str]:
    """
    Lista archivos en un path de GCS, con filtro opcional por keyword.

    Parameters
    ----------
    gcp_path : str
        Path en formato 'bucket/prefijo/'.
    kwd : str, optional
        Si se indica, retorna solo los archivos cuyo nombre contiene kwd.

    Returns
    -------
    list[str]
        Lista de nombres de blob.
    """
    bucket_name, prefix = _parse_gcp_path(gcp_path)
    blobs = storage.Client().bucket(bucket_name).list_blobs(prefix=prefix)
    names = [b.name for b in blobs]
    if kwd:
        names = [n for n in names if kwd in n]
    return names
