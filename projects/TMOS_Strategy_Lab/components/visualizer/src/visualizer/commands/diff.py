"""diff — side-by-side Candidate diff with per-screen tinting."""
from __future__ import annotations

import json
from datetime import date
from pathlib import Path

import click
from tmos_strategy_lab.models import Candidate
from tmos_strategy_lab.viz.diff import render_diff

COMPONENT_DIR = Path(__file__).parents[3]
PROJECT_ROOT = COMPONENT_DIR.parents[1]
OUTPUT_BASE = PROJECT_ROOT / "output" / "visualizer"


@click.command("diff")
@click.argument("candidate_a", type=click.Path(exists=True, dir_okay=False, path_type=Path))
@click.argument("candidate_b", type=click.Path(exists=True, dir_okay=False, path_type=Path))
@click.option("--rom", "rom_path",
              type=click.Path(exists=True, dir_okay=False, path_type=Path),
              default=None,
              help="ROM path for real tile rendering (both halves share the same ROM).")
@click.option("--svg", is_flag=True, default=False,
              help="Also write an SVG for zoom-friendly diffs.")
@click.option("--run-label", default="diff", help="Label appended to the output dir.")
@click.option("--out-dir", default=None, type=click.Path(path_type=Path))
def cmd(candidate_a: Path, candidate_b: Path, rom_path: Path | None, svg: bool,
        run_label: str, out_dir: Path | None) -> None:
    """Side-by-side tile diff of two Candidates with per-cell coloring."""
    a = Candidate.from_json_dict(json.loads(candidate_a.read_text(encoding="utf-8")))
    b = Candidate.from_json_dict(json.loads(candidate_b.read_text(encoding="utf-8")))
    rom_bytes = rom_path.read_bytes() if rom_path else None

    if out_dir is None:
        out_dir = OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"
    out_dir.mkdir(parents=True, exist_ok=True)

    click.echo(f"diff: A={candidate_a.name} B={candidate_b.name} -> {out_dir}", err=True)
    img = render_diff(a, b, rom_bytes_a=rom_bytes, rom_bytes_b=rom_bytes)
    png = out_dir / "diff.png"
    img.save(png)
    click.echo(str(png))

    if svg:
        # PIL doesn't emit SVG; fall back to matplotlib for a vector export.
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(
            figsize=(img.width / 100.0, img.height / 100.0),
            constrained_layout=True,
        )
        ax.imshow(img)
        ax.axis("off")
        svg_path = out_dir / "diff.svg"
        fig.savefig(svg_path, format="svg")
        plt.close(fig)
        click.echo(str(svg_path))


__all__ = ["cmd"]
