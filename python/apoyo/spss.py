import gc

import pandas as pd
import pyreadstat

from .text import clean_string


def estandarizacion_metadatos(
    df: pd.DataFrame, meta
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Estandariza un DataFrame leído desde un archivo SAV (SPSS/pyreadstat):
    renombra columnas con clean_string y extrae metadatos de variables y etiquetas.

    Parameters
    ----------
    df : pd.DataFrame
        DataFrame retornado por pyreadstat.
    meta : pyreadstat.metadata_container
        Metadatos retornados por pyreadstat (segundo elemento de la tupla).

    Returns
    -------
    df : pd.DataFrame
        DataFrame con columnas renombradas.
    df_variables : pd.DataFrame
        Tabla con name, description, measure, name_origin, data_type por variable.
    df_etiquetas : pd.DataFrame
        Tabla con name, label_value, label_meaning (exploded).
    """
    nuevos_nombres = []
    metadata_variables = []
    metadata_etiquetas = []

    for col in meta.column_names:
        name = clean_string(col)
        nuevos_nombres.append(name)

        metadata_variables.append({
            'name': name,
            'description': meta.column_names_to_labels[col],
            'measure': meta.variable_measure[col],
            'name_origin': col,
            'data_type': meta.readstat_variable_types[col],
        })

        labels = meta.variable_value_labels.get(col)
        if labels:
            metadata_etiquetas.append({
                'name': name,
                'label_value': list(labels.keys()),
                'label_meaning': list(labels.values()),
            })

    df.columns = nuevos_nombres
    df_variables = pd.DataFrame(metadata_variables)
    df_etiquetas = (
        pd.DataFrame(metadata_etiquetas)
        .explode(['label_value', 'label_meaning'])
        .reset_index(drop=True)
        if metadata_etiquetas
        else pd.DataFrame(columns=['name', 'label_value', 'label_meaning'])
    )

    return df, df_variables, df_etiquetas


def sav_to_parquet(
    sav_file: str,
    nombre_base: str,
    path_dir_data: str,
    path_dir_meta: str = None,
) -> None:
    """
    Lee un archivo SAV, estandariza metadatos y guarda data + metadatos como Parquet.

    Genera tres archivos:
        {path_dir_data}/{nombre_base}.parquet
        {path_dir_meta}/{nombre_base}.meta_columns.parquet
        {path_dir_meta}/{nombre_base}.meta_labels.parquet

    Parameters
    ----------
    sav_file : str
        Ruta al archivo .sav.
    nombre_base : str
        Nombre base para los archivos de salida (sin extensión).
    path_dir_data : str
        Directorio donde se guarda el parquet de datos.
    path_dir_meta : str, optional
        Directorio donde se guardan los parquets de metadatos.
        Si no se indica, se usa path_dir_data.

    Examples
    --------
    >>> from kutils.spss import sav_to_parquet
    >>> sav_to_parquet("encuesta.sav", "encuesta_2024", "data/", "data/meta/")
    """
    if path_dir_meta is None:
        path_dir_meta = path_dir_data

    gc.collect()
    df, meta = pyreadstat.read_sav(sav_file)
    df_trans, mv, ml = estandarizacion_metadatos(df, meta)

    parquet_kwargs = dict(index=False, compression="gzip", engine="pyarrow")
    df_trans.to_parquet(f"{path_dir_data}/{nombre_base}.parquet", **parquet_kwargs)
    mv.to_parquet(f"{path_dir_meta}/{nombre_base}.meta_columns.parquet", **parquet_kwargs)
    ml.to_parquet(f"{path_dir_meta}/{nombre_base}.meta_labels.parquet", **parquet_kwargs)


def print_variable_info(
    df_variables: pd.DataFrame,
    df_etiquetas: pd.DataFrame,
    like: str = "",
) -> None:
    """
    Imprime en consola el detalle de cada variable y sus etiquetas de valor.
    Equivalente a print_info() de R (haven/labelled).

    Parameters
    ----------
    df_variables : pd.DataFrame
        Tabla de variables retornada por estandarizacion_metadatos.
    df_etiquetas : pd.DataFrame
        Tabla de etiquetas retornada por estandarizacion_metadatos.
    like : str
        Filtro por nombre de variable (búsqueda por substring).

    Examples
    --------
    >>> df, df_vars, df_labels = estandarizacion_metadatos(df, meta)
    >>> print_variable_info(df_vars, df_labels, like="edad")
    """
    vars_df = df_variables.copy()
    if like:
        vars_df = vars_df[vars_df["name"].str.contains(like, case=False)]

    for _, row in vars_df.iterrows():
        print(f"{row['name']}: {row['description']}")
        etiq = df_etiquetas[df_etiquetas["name"] == row["name"]]
        for _, lrow in etiq.iterrows():
            print(f"\t{lrow['label_value']} - {lrow['label_meaning']}")
        print("_" * 30)


def get_variable_labels(
    df_variables: pd.DataFrame,
    as_dataframe: bool = True,
) -> pd.DataFrame | None:
    """
    Retorna o imprime el mapeo variable → descripción/pregunta.
    Equivalente a get_variable_labels() de R (rename de print_questions).

    Parameters
    ----------
    df_variables : pd.DataFrame
        Tabla de variables retornada por estandarizacion_metadatos.
    as_dataframe : bool
        Si True (default), retorna DataFrame. Si False, imprime en consola.

    Returns
    -------
    pd.DataFrame | None
        Columnas: name, description.

    Examples
    --------
    >>> df_labels = get_variable_labels(df_vars)
    >>> get_variable_labels(df_vars, as_dataframe=False)
    """
    result = df_variables[["name", "description"]].copy()
    if as_dataframe:
        return result
    for _, row in result.iterrows():
        print(f"{row['name']}: {row['description']}")
