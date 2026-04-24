"""runner end-to-end (dry-run + smoke) tests."""
from __future__ import annotations

import json
from pathlib import Path

import pytest

from components.randomization_lab import runner

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
ROM = _PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


def test_dry_run_exits_zero(capsys):
    rc = runner.main(["--dry-run"])
    assert rc == 0
    out = capsys.readouterr().out
    assert "identity" in out


def test_unknown_strategy_returns_nonzero(capsys):
    rc = runner.main(["--dry-run", "--strategies", "no-such-thing"])
    assert rc == 2


@pytest.mark.skipif(not ROM.exists(), reason="ROM not present")
def test_full_identity_run_produces_all_artifacts(tmp_path, monkeypatch):
    # Redirect OUTPUT_BASE to a tmp dir so the test doesn't write into real output/.
    import components.randomization_lab.run_writer as rw

    monkeypatch.setattr(rw, "OUTPUT_BASE", tmp_path)

    desc = "pytest_identity"
    rc = runner.main(["--rom", str(ROM), "--desc", desc, "--strategies", "identity"])
    assert rc == 0

    runs = list(tmp_path.glob(f"*_{desc}*"))
    assert len(runs) == 1
    run_dir = runs[0]
    assert (run_dir / "run_manifest.json").exists()
    assert (run_dir / "summary.md").exists()
    s_dir = run_dir / "identity"
    for name in ("screenshot.png", "world.json", "validation_report.json", "diff_vs_pristine.json"):
        assert (s_dir / name).exists(), f"missing {name}"

    diff = json.loads((s_dir / "diff_vs_pristine.json").read_text())
    # Identity strategy must produce ZERO new validation failures vs pristine.
    assert diff["summary"]["new_count"] == 0
    assert diff["summary"]["resolved_count"] == 0


def test_missing_rom_returns_nonzero(tmp_path):
    missing = tmp_path / "nowhere.nes"
    rc = runner.main(["--rom", str(missing), "--desc", "x", "--strategies", "identity"])
    assert rc == 2
