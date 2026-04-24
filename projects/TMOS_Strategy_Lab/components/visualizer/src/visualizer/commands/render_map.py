"""render-map — tile-art grid image from a Candidate JSON.

Loads the Candidate, calls ``tmos_strategy_lab.viz.tile_render.render_candidate``,
saves the PIL image to disk at 1:1 pixel accuracy.
"""
from __future__ import annotations

import json
from datetime import date
from pathlib import Path

import click
from tmos_strategy_lab.models import Candidate
from tmos_strategy_lab.viz.tile_render import render_candidate

COMPONENT_DIR = Path(__file__).parents[3]
PROJECT_ROOT = COMPONENT_DIR.parents[1]
OUTPUT_BASE = PROJECT_ROOT / "output" / "visualizer"


@click.command("render-map")
@click.argument("candidate_json", type=click.Path(exists=True, dir_okay=False, path_type=Path))
@click.option("--rom", "rom_path",
              type=click.Path(exists=True, dir_okay=False, path_type=Path),
              default=None,
              help="Optional ROM path; enables the V2 renderer (real tile art). "
                   "Without it the PIL fallback is used.")
@click.option("--run-label", default="render", help="Label appended to the output dir.")
@click.option("--scale", default=1, show_default=True, type=int)
@click.option("--out-dir", default=None, type=click.Path(path_type=Path),
              help="Override output directory.")
def cmd(candidate_json: Path, rom_path: Path | None, run_label: str, scale: int,
        out_dir: Path | None) -> None:
    """Render a Candidate as a per-chapter tile-art grid PNG."""
    candidate = Candidate.from_json_dict(json.loads(candidate_json.read_text(encoding="utf-8")))

    if out_dir is None:
        out_dir = OUTPUT_BASE / f"{date.today().isoformat()}_{run_label}"
    out_dir.mkdir(parents=True, exist_ok=True)

    rom_bytes = rom_path.read_bytes() if rom_path else None
    click.echo(f"render-map: {candidate_json.name} -> {out_dir}", err=True)

    img = render_candidate(candidate, rom_bytes=rom_bytes, scale=scale)
    out_path = out_dir / "candidate_map.png"
    # PIL save for 1:1 pixel accuracy — NOT matplotlib (fig.savefig rescales).
    img.save(out_path)
    click.echo(str(out_path))


__all__ = ["cmd"]
