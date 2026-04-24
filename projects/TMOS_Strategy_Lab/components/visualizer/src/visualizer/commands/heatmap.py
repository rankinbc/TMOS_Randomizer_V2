"""heatmap — per-tile walk-distance overlay for a Candidate."""
from __future__ import annotations

import json
from datetime import date
from pathlib import Path

import click
from tmos_strategy_lab.models import Candidate
from tmos_strategy_lab.viz.heatmap import render_heatmap

COMPONENT_DIR = Path(__file__).parents[3]
PROJECT_ROOT = COMPONENT_DIR.parents[1]
OUTPUT_BASE = PROJECT_ROOT / "output" / "visualizer"


@click.command("heatmap")
@click.argument("candidate_json", type=click.Path(exists=True, dir_okay=False, path_type=Path))
@click.option("--run-label", default="heatmap", help="Label appended to the output dir.")
@click.option("--colormap", default="hot_r", show_default=True,
              help="matplotlib colormap for walk-distance.")
@click.option("--dpi", default=120, show_default=True, type=int)
@click.option("--out-dir", default=None, type=click.Path(path_type=Path))
def cmd(candidate_json: Path, run_label: str, colormap: str, dpi: int,
        out_dir: Path | None) -> None:
    """Per-tile walk-distance heatmap overlaid on a chapter grid."""
    import matplotlib.pyplot as plt
    cand = Candidate.from_json_dict(json.loads(candidate_json.read_text(encoding="utf-8")))

    if out_dir is None:
        out_dir = OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"
    out_dir.mkdir(parents=True, exist_ok=True)

    click.echo(f"heatmap: {candidate_json.name} -> {out_dir}", err=True)
    fig = render_heatmap(cand, cmap=colormap)
    out_path = out_dir / "heatmap.png"
    fig.savefig(out_path, dpi=dpi)
    plt.close(fig)
    click.echo(str(out_path))


__all__ = ["cmd"]
