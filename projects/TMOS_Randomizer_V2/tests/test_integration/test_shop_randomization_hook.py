"""Randomizer.apply post-pass: shop randomization on the output ROM.

Uses a stub strategy so the test doesn't run a full pipeline — the hook is
strategy-agnostic and only needs a success result with an output path.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest

from tmos_randomizer.core.constants import (
    MAGIC_SHOP_BASE_PRICES,
    MAGIC_SHOP_BASE_PRICE_COUNT,
    SHOP_DATA_TABLE,
)
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases.phase1_planning import WorldPlan
from tmos_randomizer.phases.phase2_shaping import WorldShape
from tmos_randomizer.phases.phase3_connection import WorldConnections
from tmos_randomizer.plan import RandomizationPlan, RandomizationResult
from tmos_randomizer.randomizer import Randomizer
from tmos_randomizer.strategies.base import RandomizationStrategy

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")


class _CopyStrategy(RandomizationStrategy):
    """Copies the input ROM to the output path and reports success."""

    name = "copy-stub"
    description = "test stub"

    def create_plan(self, seed):
        return RandomizationPlan(
            seed=seed,
            config=self.config,
            world_plan=WorldPlan(seed=seed, chapters=[]),
            world_shape=WorldShape(seed=seed, chapters=[]),
            world_connections=WorldConnections(seed=seed, chapters=[]),
        )

    def apply_plan(self, input_rom, output_rom, plan, generate_spoiler=True):
        data = Path(input_rom).read_bytes()
        Path(output_rom).write_bytes(data)
        return RandomizationResult(
            success=True,
            seed=plan.seed,
            output_rom_path=Path(output_rom),
            rom_sha256=hashlib.sha256(data).hexdigest(),
        )


def _run(tmp_path, *, enabled: bool, seed: int = 77):
    config = get_default_config()
    config.difficulty.shop_randomization.enabled = enabled
    rnd = Randomizer(config, strategy=_CopyStrategy(config, rnd_validation(), None))
    plan = rnd.create_plan(seed)
    out = tmp_path / "out.nes"
    result = rnd.apply(ROM_PATH, out, plan, generate_spoiler=False)
    return result, out


def rnd_validation():
    from tmos_randomizer.validation import ValidationConfig
    return ValidationConfig()


def test_hook_writes_only_shop_regions(tmp_path):
    result, out = _run(tmp_path, enabled=True)
    assert result.success
    vanilla = ROM_PATH.read_bytes()
    patched = out.read_bytes()
    allowed = set(range(SHOP_DATA_TABLE, SHOP_DATA_TABLE + 64)) | set(
        range(MAGIC_SHOP_BASE_PRICES, MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT)
    )
    diff = {i for i, (a, b) in enumerate(zip(vanilla, patched)) if a != b}
    assert diff, "shop randomization enabled but ROM unchanged"
    assert diff <= allowed, f"bytes outside shop regions changed: {sorted(diff - allowed)[:10]}"
    # sha256 refreshed to match the post-shop bytes
    assert result.rom_sha256 == hashlib.sha256(patched).hexdigest()
    assert "shops" in result.stats
    assert len(result.stats["shops"]["spoiler"]["shops"]) == 8


def test_hook_disabled_leaves_rom_untouched(tmp_path):
    result, out = _run(tmp_path, enabled=False)
    assert result.success
    assert out.read_bytes() == ROM_PATH.read_bytes()
    assert "shops" not in result.stats


def test_hook_deterministic_per_seed(tmp_path):
    _, out_a = _run(tmp_path, enabled=True, seed=123)
    a = out_a.read_bytes()
    (tmp_path / "out.nes").unlink()
    _, out_b = _run(tmp_path, enabled=True, seed=123)
    assert out_b.read_bytes() == a
