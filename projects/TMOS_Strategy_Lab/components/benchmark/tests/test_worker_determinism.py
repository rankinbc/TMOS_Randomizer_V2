"""Two sweeps over the same seed set produce matching per_seed.ndjson rows (minus wall-clock)."""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[3]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"
BENCH_SCRIPT = PROJECT_ROOT / "components" / "benchmark" / "scripts" / "run.py"


pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason="Stock ROM not staged.",
)


# Fields whose values are wall-clock-derived and are allowed to vary.
_TIMING_FIELDS = {"generation_time_s", "generation_time_value"}


def _run_sweep(label: str, out_dir: Path) -> list[dict]:
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    subprocess.run(
        [
            sys.executable, str(BENCH_SCRIPT),
            "--strategy", "identity",
            "--seeds", "3",
            "--workers", "2",
            "--run-label", label,
            "--output-dir", str(out_dir),
        ],
        env=env, capture_output=True, text=True, check=True,
    )
    ndjson = out_dir / "per_seed.ndjson"
    rows = [json.loads(line) for line in ndjson.read_text().splitlines()]
    rows.sort(key=lambda r: r["seed"])
    for row in rows:
        for k in _TIMING_FIELDS:
            row.pop(k, None)
    return rows


def test_two_sweeps_same_seeds_match(tmp_path):
    r1 = _run_sweep("det1", tmp_path / "det1")
    r2 = _run_sweep("det2", tmp_path / "det2")
    assert r1 == r2, f"rows drifted:\nr1={r1}\nr2={r2}"
