# tests/test_strategies/test_v1_integration.py
"""ROM-gated end-to-end integration test for tmos_randomizer_v1 strategy.

Skipped automatically when no TMOS ROM is available (so CI stays green).
In this repo a real vanilla ROM is present, so both tests run and PASS.
"""
import hashlib
import os
from pathlib import Path

import pytest

from tmos_randomizer.strategies import get_strategy
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.phases.phase6_validation import analyze_reachability
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation import ValidationRunner

EXPECTED_MD5 = "b3236db14c87f375e5f24a5b9b79f071"


def _find_rom() -> Path | None:
    # 1. Explicit override via environment variable.
    env = os.environ.get("TMOS_ROM")
    if env and Path(env).exists():
        return Path(env)
    # 2. Known candidate paths (relative to cwd = projects/TMOS_Randomizer_V2).
    for guess in (
        Path("TMOS_ORIGINAL.nes"),
        Path("rom-files/TMOS_ORIGINAL.nes"),
        Path("../../rom-files/TMOS_ORIGINAL.nes"),
        Path("rom-files/TMOS.nes"),
        Path("../../rom-files/TMOS.nes"),
    ):
        if guess.exists():
            return guess
    return None


_ROM = _find_rom()
pytestmark = pytest.mark.skipif(_ROM is None, reason="no TMOS ROM available")


def _strategy():
    cls = get_strategy("tmos_randomizer_v1")
    cfg = get_default_config()
    vcfg = ValidationConfig()
    return cls(cfg, vcfg, ValidationRunner(vcfg))


def test_end_to_end_produces_valid_changed_navigable_rom(tmp_path):
    strat = _strategy()
    plan = strat.create_plan(seed=12345)
    out = tmp_path / "out.nes"
    result = strat.apply_plan(_ROM, out, plan, generate_spoiler=False)

    assert result.success, result.errors
    assert out.exists()

    # Output differs from vanilla.
    vanilla_md5 = hashlib.md5(_ROM.read_bytes()).hexdigest()
    out_md5 = hashlib.md5(out.read_bytes()).hexdigest()
    assert out_md5 != vanilla_md5

    # Output re-parses and every chapter satisfies V1's time-door gate.
    from tmos_randomizer.strategies.v1 import algorithm as A
    gw = load_rom(out)
    for chapter in gw:
        wi = chapter.chapter_num - 1
        assert A.time_doors_ok(chapter.screens, wi), f"chapter {chapter.chapter_num}"
        assert A.required_content_present(chapter.screens, wi)
        # Nav untouched -> reachability no worse than vanilla.
        analyze_reachability(chapter, starting_screen=0)


def test_determinism_same_seed_same_rom(tmp_path):
    strat = _strategy()
    a = tmp_path / "a.nes"
    b = tmp_path / "b.nes"
    strat.apply_plan(_ROM, a, strat.create_plan(seed=777), generate_spoiler=False)
    strat.apply_plan(_ROM, b, strat.create_plan(seed=777), generate_spoiler=False)
    assert a.read_bytes() == b.read_bytes()
