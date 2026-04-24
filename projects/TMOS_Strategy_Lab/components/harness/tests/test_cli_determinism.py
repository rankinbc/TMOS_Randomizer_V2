"""Determinism: two runs with the same seed produce byte-identical JSON."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[3]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason=f"Stock ROM not staged at {ROM} — see CLAUDE.md aggregate-gate setup.",
)


def _run(tmp_path: Path, label: str) -> tuple[Path, Path]:
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "42"
    out_dir = tmp_path / label
    cmd = [
        sys.executable, "-m", "harness", "run",
        "--strategy", "identity",
        "--seed", "42",
        "--input", str(ROM),
        "--output-dir", str(out_dir),
    ]
    completed = subprocess.run(cmd, env=env, capture_output=True, text=True, check=True)
    assert completed.returncode == 0, completed.stderr
    return out_dir / "report.json", out_dir / "candidate.json"


def test_two_runs_same_seed_byte_identical(tmp_path):
    r1, c1 = _run(tmp_path, "run1")
    r2, c2 = _run(tmp_path, "run2")
    assert r1.read_bytes() == r2.read_bytes(), "report.json drifted across runs"
    assert c1.read_bytes() == c2.read_bytes(), "candidate.json drifted across runs"
