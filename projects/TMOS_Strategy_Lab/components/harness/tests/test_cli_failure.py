"""Known-bad candidate → exit code 2 and a JSON envelope on stderr when --format json."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import textwrap
from pathlib import Path

import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[3]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"


pytestmark = pytest.mark.skipif(
    not ROM.exists(),
    reason=f"Stock ROM not staged at {ROM}.",
)


def _write_bad_runner_script(tmp_path: Path) -> Path:
    """Stand-alone script: register a broken strategy, invoke pipeline, emit envelope."""
    script = tmp_path / "run_bad.py"
    text = textwrap.dedent("""\
        import json, os, sys
        os.environ["PYTHONHASHSEED"] = "7"
        # ASCII-only to avoid cp1252 issues on Windows.

        import tmos_strategy_lab as t
        from tmos_strategy_lab.registry import register_strategy
        from tmos_strategy_lab.models import Candidate

        @register_strategy
        class BadStrategy:
            name = "__bad__"
            description = "deliberately broken for failure-path testing"

            def generate(self, ctx, seed):
                # One chapter with one screen that is a pure orphan.
                chapters = {
                    1: [{
                        "global_index": 0, "chapter": 1, "relative_index": 0,
                        "parent_world": 0x40, "ambient_sound": 0, "content": 0,
                        "objectset": 0, "screen_index_right": 0xFF, "screen_index_left": 0xFF,
                        "screen_index_down": 0xFF, "screen_index_up": 0xFF,
                        "datapointer": 0, "exit_position": 0,
                        "top_tiles": 0, "bottom_tiles": 0,
                        "worldscreen_color": 0, "sprites_color": 0,
                        "unknown": 0, "event": 0,
                    }],
                }
                return Candidate(
                    strategy_id="__bad__@test",
                    strategy_version="0.0.0",
                    seed=seed,
                    chapters=chapters,
                    repairs=[],
                    breadcrumbs={"source": ctx.source},
                )

        from tmos_strategy_lab.pipeline import run_pipeline, write_artifacts
        rom_path = sys.argv[1]
        out_dir = sys.argv[2]
        artifacts = run_pipeline("__bad__", 7, rom_path)
        write_artifacts(artifacts, out_dir, "both")
        if not artifacts.report.passed:
            envelope = {
                "error": "validation_failed",
                "strategy_id": artifacts.report.strategy_id,
                "seed": artifacts.report.seed,
                "report": artifacts.report.to_dict(),
            }
            sys.stderr.write(json.dumps(envelope, indent=2, sort_keys=True))
            sys.exit(2)
        sys.exit(0)
    """)
    script.write_text(text, encoding="utf-8")
    return script


def test_known_bad_candidate_exits_2_and_emits_json(tmp_path):
    script = _write_bad_runner_script(tmp_path)
    out_dir = tmp_path / "bad_run"
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "7"
    completed = subprocess.run(
        [sys.executable, str(script), str(ROM), str(out_dir)],
        env=env, capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 2, (
        f"expected exit 2, got {completed.returncode}. stderr={completed.stderr!r}"
    )
    envelope = json.loads(completed.stderr)
    assert envelope["error"] == "validation_failed"
    assert envelope["strategy_id"] == "__bad__@test"
    assert any(m["status"] == "fail" for m in envelope["report"]["metrics"])
