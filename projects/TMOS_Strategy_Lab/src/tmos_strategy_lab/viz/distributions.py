"""Metric-distribution plots from benchmark output.

Histogram + exact ECDF per metric, side-by-side. Input: either
``summary.json`` (aggregated) or ``per_seed.ndjson`` (raw — preferred, more
data to plot).

Key constraints (REQUIREMENTS.md and PRP gotchas):
- matplotlib >= 3.8 for ``Axes.ecdf``.
- ``constrained_layout=True`` on ``plt.subplots`` — never ``tight_layout()``.
- seaborn ``multiple='layer'`` with ``kde=True`` — never ``'stack'`` (seaborn #2882).
"""
from __future__ import annotations

import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import pandas as pd  # noqa: E402
import seaborn as sns  # noqa: E402

# Columns that don't make distribution sense (identifiers, strings).
_SKIP_COLUMNS = {"seed", "strategy_id", "passed", "error"}


def _load_dataframe(path: Path) -> pd.DataFrame:
    if path.suffix == ".ndjson":
        return pd.read_json(path, lines=True)
    payload = json.loads(path.read_text(encoding="utf-8"))
    # summary.json: {"strategies": {"<strategy_id>": {metric: stat}}} — expand to flat rows.
    rows = []
    for strategy_id, stats in payload.get("strategies", {}).items():
        row = {"strategy_id": strategy_id}
        for k, v in stats.items():
            if isinstance(v, (int, float)):
                row[k] = v
        rows.append(row)
    return pd.DataFrame(rows)


def plot_metric_distributions(
    summary_or_ndjson: Path,
    out_dir: Path,
    dpi: int = 120,
) -> list[Path]:
    """For each numeric metric column in the input, render a (hist, ECDF) PNG.

    Returns the list of PNG paths written. Figure count == numeric-metric count.
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    df = _load_dataframe(Path(summary_or_ndjson))
    if df.empty:
        return []

    # Preserve strategy_id as a hue column if present.
    hue = "strategy_id" if "strategy_id" in df.columns else None

    written: list[Path] = []
    for col in df.columns:
        if col in _SKIP_COLUMNS:
            continue
        if not pd.api.types.is_numeric_dtype(df[col]):
            continue
        series = df[col].dropna()
        if series.empty:
            continue

        fig, (ax_hist, ax_ecdf) = plt.subplots(
            1, 2, figsize=(10, 4), constrained_layout=True
        )
        # KDE breaks on constant / very-low-variance columns (seaborn bug #2882
        # plus a numerical singularity in gaussian_kde). Disable it when the
        # data can't support a smooth estimate.
        kde_ok = series.nunique() >= 2 and float(series.std(ddof=0)) > 1e-12
        sns.histplot(
            data=df,
            x=col,
            hue=hue,
            multiple="layer",
            kde=kde_ok,
            ax=ax_hist,
        )
        ax_hist.set_title(f"{col} — histogram{' + KDE' if kde_ok else ''}")

        if hue is not None:
            for strategy_id, group in df.groupby(hue):
                values = group[col].dropna()
                if not values.empty:
                    ax_ecdf.ecdf(values, label=str(strategy_id))
            ax_ecdf.legend(loc="lower right")
        else:
            ax_ecdf.ecdf(series)
        ax_ecdf.set_title(f"{col} — exact ECDF")
        ax_ecdf.set_xlabel(col)
        ax_ecdf.set_ylabel("F(x)")

        out_path = out_dir / f"{col}.png"
        fig.savefig(out_path, dpi=dpi)
        plt.close(fig)
        written.append(out_path)

    return written


__all__ = ["plot_metric_distributions"]
