"""plot-metrics — histogram + exact ECDF per metric from benchmark output.

Accepts either a per_seed.ndjson (preferred — raw distribution) or a
summary.json (aggregated — coarser distribution).
"""
from __future__ import annotations

from datetime import date
from pathlib import Path

import click
from tmos_strategy_lab.viz.distributions import plot_metric_distributions

COMPONENT_DIR = Path(__file__).parents[3]
PROJECT_ROOT = COMPONENT_DIR.parents[1]
OUTPUT_BASE = PROJECT_ROOT / "output" / "visualizer"


@click.command("plot-metrics")
@click.argument("summary_json_or_ndjson",
                type=click.Path(exists=True, dir_okay=False, path_type=Path))
@click.option("--run-label", default="metrics", help="Label appended to the output dir.")
@click.option("--dpi", default=120, show_default=True, type=int)
@click.option("--out-dir", default=None, type=click.Path(path_type=Path))
def cmd(summary_json_or_ndjson: Path, run_label: str, dpi: int, out_dir: Path | None) -> None:
    """Plot metric distributions (histogram + ECDF) per metric column."""
    if out_dir is None:
        out_dir = OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"
    out_dir.mkdir(parents=True, exist_ok=True)

    click.echo(f"plot-metrics: {summary_json_or_ndjson.name} -> {out_dir}", err=True)
    paths = plot_metric_distributions(summary_json_or_ndjson, out_dir, dpi=dpi)
    if not paths:
        click.echo(
            "no numeric columns to plot (input had no metric data)", err=True,
        )
        return
    for p in paths:
        click.echo(str(p))


__all__ = ["cmd"]
