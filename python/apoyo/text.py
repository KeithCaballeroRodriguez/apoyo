import re
import unicodedata


def clean_string(txt: str) -> str:
    """
    Normaliza un texto: elimina acentos, caracteres especiales,
    espacios múltiples y convierte a snake_case en minúsculas.

    Parameters
    ----------
    txt : str
        Texto a normalizar.

    Returns
    -------
    str
        Texto normalizado en snake_case.

    Examples
    --------
    >>> clean_string("  Hola Mundo! ")
    'hola_mundo'
    >>> clean_string("Ñoño & Co.")
    'nono_&_co'
    """
    txt = str(txt).strip()
    txt = unicodedata.normalize('NFKD', txt).encode('ASCII', 'ignore').decode()
    txt = re.sub(r'[^0-9a-zA-Z&_.]+', ' ', txt)
    txt = re.sub(r' +', ' ', txt)
    return txt.strip().lower().replace(" ", '_')
