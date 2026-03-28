import sqlalchemy as sa


def create_pg_engine(config: dict) -> sa.engine.Engine:
    """
    Crea un engine de SQLAlchemy para PostgreSQL.

    Parameters
    ----------
    config : dict
        Diccionario con las claves: USER, PWD, HOST, PORT, DBNAME.
        Puede cargarse con dotenv_values() o os.environ.

    Returns
    -------
    sqlalchemy.engine.Engine

    Examples
    --------
    >>> from dotenv import dotenv_values
    >>> from kutils.db import create_pg_engine
    >>> engine = create_pg_engine(dotenv_values(".env"))
    """
    url = "postgresql://{USER}:{PWD}@{HOST}:{PORT}/{DBNAME}".format(**config)
    return sa.create_engine(url)
