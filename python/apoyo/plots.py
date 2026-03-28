import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd


def theme_apoyo(font_size: int = 14) -> None:
    """
    Aplica el estilo apoyo a matplotlib: ejes limpios, texto bold, sin grid.
    Equivalente a theme_apoyo() de ggplot2.

    Parameters
    ----------
    font_size : int
        Tamaño base de fuente (default 14).

    Examples
    --------
    >>> from apoyo.plots import theme_apoyo
    >>> theme_apoyo()
    >>> plt.plot([1, 2, 3], [1, 4, 9])
    """
    mpl.rcParams.update({
        "font.size":          font_size,
        "font.weight":        "bold",
        "axes.titlesize":     font_size,
        "axes.titleweight":   "bold",
        "axes.labelsize":     font_size - 1,
        "axes.labelweight":   "bold",
        "xtick.labelsize":    font_size - 3,
        "ytick.labelsize":    font_size - 3,
        "xtick.color":        "black",
        "ytick.color":        "black",
        "axes.edgecolor":     "black",
        "axes.spines.top":    False,
        "axes.spines.right":  False,
        "axes.grid":          False,
        "axes.titlelocation": "center",
    })


def plot_dual_axis(
    df: pd.DataFrame,
    x: str,
    y1: str,
    y2: str,
    label1: str = "",
    label2: str = "",
    color1: str = "#1f497d",
    color2: str = "#4ba3e7",
    include_zero: bool = False,
    figsize: tuple = (12, 5),
) -> tuple[plt.Figure, tuple[plt.Axes, plt.Axes]]:
    """
    Gráfico de líneas con doble eje Y.
    Equivalente a plot_dual_axis() de ggplot2.

    Parameters
    ----------
    df : pd.DataFrame
    x : str
        Columna para el eje X.
    y1 : str
        Columna para el eje Y izquierdo.
    y2 : str
        Columna para el eje Y derecho.
    label1, label2 : str
        Etiquetas de los ejes Y.
    color1, color2 : str
        Colores de cada línea.
    include_zero : bool
        Si True, fuerza el origen en 0 en ambos ejes.
    figsize : tuple

    Returns
    -------
    fig : plt.Figure
    (ax1, ax2) : tuple of plt.Axes

    Examples
    --------
    >>> from apoyo.plots import plot_dual_axis, theme_apoyo
    >>> theme_apoyo()
    >>> fig, (ax1, ax2) = plot_dual_axis(df, "fecha", "ventas", "tasa", "Ventas", "Tasa (%)")
    >>> plt.show()
    """
    fig, ax1 = plt.subplots(figsize=figsize)
    ax2 = ax1.twinx()

    ax1.plot(df[x], df[y1], color=color1, linewidth=1.2, alpha=0.8)
    ax2.plot(df[x], df[y2], color=color2, linewidth=1.2, alpha=0.8)

    ax1.set_ylabel(label1, color=color1)
    ax2.set_ylabel(label2, color=color2)
    ax1.tick_params(axis="y", colors=color1)
    ax2.tick_params(axis="y", colors=color2)

    ax2.spines["right"].set_visible(True)
    ax2.spines["top"].set_visible(False)

    if include_zero:
        ax1.set_ylim(bottom=0)
        ax2.set_ylim(bottom=0)

    fig.tight_layout()
    return fig, (ax1, ax2)
