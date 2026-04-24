"""per_seed.ndjson must be parseable as NDJSON even mid-stream."""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pandas as pd
import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[3]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"
BENCH_SCRIPT = PROJECT_ROOT / "components" / "benchmark" / "scripts" / "run.py"


pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason="Stock ROM not staged.",
)


def test_ndjson_streamable_and_complete(tmp_path):
    out_dir = tmp_path / "sweep"
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    completed = subprocess.run(
        [
            sys.executable, str(BENCH_SCRIPT),
            "--strategy", "identity",
            "--seeds", "3",
            "--workers", "2",
            "--run-label", "ndjson_test",
            "--output-dir", str(out_dir),
        ],
        env=env, capture_output=True, text=True, check=True,
    )
    ndjson = out_dir / "per_seed.ndjson"
    assert ndjson.exists(), completed.stderr

    # Stream parse.
    rows = []
    with ndjson.open() as fh:
        for line in fh:
            rows.append(json.loads(line))
    assert len(rows) == 3
    assert all("seed" in row and "strategy_id" in row for row in rows)

    # pandas also parses it.
    df = pd.read_json(ndjson, lines=True)
    assert len(df) == 3
