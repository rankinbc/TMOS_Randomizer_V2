"""
RunWriter — owns the output path layout for a single batch run.

Output root: <project_root>/output/randomization_lab/<YYYY-MM-DD>_<desc>[-<uuid6>]/
  run_manifest.json
  summary.md
  <strategy_name>/
    screenshot.png
    world.json
    validation_report.json
    diff_vs_pristine.json

# TODO: /execute-prp fills in the real write methods.
"""

from __future__ import annotations
from pathlib import Path
from datetime import date
import uuid

COMPONENT_DIR = Path(__file__).parent
PROJECT_ROOT = COMPONENT_DIR.parent.parent
OUTPUT_BASE = PROJECT_ROOT / "output" / "randomization_lab"


class RunWriter:
    def __init__(self, desc: str) -> None:
        slug = f"{date.today().isoformat()}_{desc}"
        run_dir = OUTPUT_BASE / slug
        if run_dir.exists():
            run_dir = OUTPUT_BASE / f"{slug}-{uuid.uuid4().hex[:6]}"
        self.run_dir = run_dir
        # TODO: /execute-prp fills in mkdir + write helpers.

    def strategy_dir(self, strategy_name: str) -> Path:
        """Return (and create) the per-strategy subdirectory."""
        d = self.run_dir / strategy_name
        d.mkdir(parents=True, exist_ok=True)
        return d
