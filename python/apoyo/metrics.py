import numpy as np
import pandas as pd


def bucket_report_metrics(
    df, y_true, y_pred,
    bins=None, labels=None,
    thr=0.25,
    by=None,
    bucket_on="real",
    add_metrics=False,
    mape_scale=100
):
    """
    Reporte de métricas de regresión por bucket de valor.

    Parameters
    ----------
    df : pd.DataFrame
    y_true : str
        Columna con valores reales (denominador siempre).
    y_pred : str
        Columna con valores predichos.
    bins : list, optional
        Límites de los buckets. Por defecto rangos monetarios estándar.
    labels : list, optional
        Etiquetas para cada bucket.
    thr : float
        Umbral de precisión (default 0.25 = ±25%).
    by : list of str, optional
        Columnas adicionales para desagregar.
    bucket_on : {'real', 'pred'}
        Columna sobre la que se calculan los buckets.
    add_metrics : bool
        Si True, agrega MAPE y RMSE.
    mape_scale : float
        Multiplicador del MAPE (default 100 → porcentaje).

    Returns
    -------
    pd.DataFrame
        Tabla con n, p_under, p_preci, p_over (y opcionalmente mape, rmse)
        por bucket y grupo.
    """
    bins = bins or [-np.inf, 60_000, 120_000, 300_000, 720_000, 1_200_000, np.inf]
    labels = labels or [
        "1__60k", "2__60-120k", "3__120-300k",
        "4__300-720k", "5__720-1.2M", "6__1.2M+"
    ]

    by = list(by) if by else []

    x = df[[y_true, y_pred] + by].copy()
    x[y_true] = pd.to_numeric(x[y_true], errors="coerce")
    x[y_pred] = pd.to_numeric(x[y_pred], errors="coerce")
    x = x.dropna(subset=[y_true, y_pred])

    x["err"] = x[y_pred] - x[y_true]
    x["e"] = x[y_pred] / x[y_true].replace(0, np.nan) - 1

    if bucket_on == "real":
        base_bucket = x[y_true]
    elif bucket_on == "pred":
        base_bucket = x[y_pred]
    else:
        raise ValueError("bucket_on debe ser 'real' o 'pred'")

    x["bucket"] = pd.cut(
        base_bucket,
        bins=bins,
        labels=labels,
        include_lowest=True,
        ordered=True
    )

    x["p"] = x["e"].abs() <= thr
    x["su"] = x["e"] < -thr
    x["so"] = x["e"] > thr

    g = by + ["bucket"]

    agg_dict = dict(
        n=("e", "count"),
        p_under=("su", "mean"),
        p_preci=("p", "mean"),
        p_over=("so", "mean"),
    )

    if add_metrics:
        agg_dict.update({
            "mape": ("e", lambda s: float(np.nanmean(np.abs(s))) * mape_scale),
            "rmse": ("err", lambda s: float(np.sqrt(np.mean(np.square(s)))))
        })

    agg = (
        x.groupby(g, dropna=False)
         .agg(**agg_dict)
         .reset_index()
    )

    if by:
        tot = (
            x.groupby(by, dropna=False)
             .agg(**agg_dict)
             .reset_index()
        )
        tot["bucket"] = "Total"
        agg = pd.concat([agg, tot[agg.columns]], ignore_index=True)
    else:
        base_total = {
            "bucket": ["Total"],
            "n": [x["e"].count()],
            "p_under": [x["su"].mean()],
            "p_preci": [x["p"].mean()],
            "p_over": [x["so"].mean()],
        }
        if add_metrics:
            base_total.update({
                "mape": [float(np.nanmean(np.abs(x["e"]))) * mape_scale],
                "rmse": [float(np.sqrt(np.mean(np.square(x["err"]))))]
            })

        agg = pd.concat(
            [agg, pd.DataFrame(base_total).reindex(columns=agg.columns)],
            ignore_index=True
        )

    return agg
