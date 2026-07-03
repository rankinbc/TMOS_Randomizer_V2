"""Randomizer.apply post-pass: enemy/encounter randomization on the output ROM.

Same stub-strategy shape as test_shop_randomization_hook.py — the hook is
strategy-agnostic and only needs a success result with an output path.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest

from tmos_randomizer.core.encounter_groups import (
    ENTRY_SIZE,
    GROUP_BASE,
    GROUP_COUNT,
)
from tmos_randomizer.core.encounter_lineups import (
    LINEUP_BASE,
    LINEUP_COUNT,
    LINEUP_SIZE,
    SLOTS_PER_LINEUP,
)
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.phases.phase1_planning import WorldPlan
from tmos_randomizer.phases.phase2_shaping import WorldShape
from tmos_randomizer.phases.phase3_connection import WorldConnections
from tmos_randomizer.plan import RandomizationPlan, RandomizationResult
from tmos_randomizer.randomizer import Randomizer
from tmos_randomizer.strategies.base import RandomizationStrategy
from tmos_randomizer.validation import ValidationConfig

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


def _run(tmp_path, *, enabled: bool, seed: int = 77, **options):
    config = get_default_config()
    # Isolate the enemy hook: shops off.
    config.difficulty.shop_randomization.enabled = False
    ec = config.difficulty.enemy_randomization
    ec.enabled = enabled
    for key, value in options.items():
        setattr(ec, key, value)
    rnd = Randomizer(config, strategy=_CopyStrategy(config, ValidationConfig(), None))
    plan = rnd.create_plan(seed)
    out = tmp_path / "out.nes"
    result = rnd.apply(ROM_PATH, out, plan, generate_spoiler=False)
    return result, out


def _battle_table_bytes() -> set[int]:
    allowed: set[int] = set()
    for chapter in LINEUP_BASE:
        for lineup_idx in range(LINEUP_COUNT[chapter]):
            base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
            allowed.update(range(base + 1, base + 1 + SLOTS_PER_LINEUP))
    for chapter in GROUP_BASE:
        for entry_idx in range(GROUP_COUNT[chapter]):
            base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
            allowed.add(base + 1)
            allowed.add(base + 2)
    return allowed


def test_hook_writes_only_battle_regions(tmp_path):
    result, out = _run(
        tmp_path, enabled=True, reassign_groups=True, reward_jitter=True
    )
    assert result.success
    vanilla = ROM_PATH.read_bytes()
    patched = out.read_bytes()
    diff = {i for i, (a, b) in enumerate(zip(vanilla, patched)) if a != b}
    assert diff, "enemy randomization enabled but ROM unchanged"
    assert diff <= _battle_table_bytes(), (
        f"bytes outside battle tables changed: {sorted(diff - _battle_table_bytes())[:10]}"
    )
    assert result.rom_sha256 == hashlib.sha256(patched).hexdigest()
    assert "enemies" in result.stats
    assert result.stats["enemies"]["spoiler"]["lineups"]


def test_hook_disabled_leaves_rom_untouched(tmp_path):
    result, out = _run(tmp_path, enabled=False)
    assert result.success
    assert out.read_bytes() == ROM_PATH.read_bytes()
    assert "enemies" not in result.stats


def test_hook_deterministic_per_seed(tmp_path):
    _, out_a = _run(tmp_path, enabled=True, seed=123)
    a = out_a.read_bytes()
    (tmp_path / "out.nes").unlink()
    _, out_b = _run(tmp_path, enabled=True, seed=123)
    assert out_b.read_bytes() == a


def test_shop_and_enemy_hooks_compose(tmp_path):
    """Both post-passes on: diff confined to shop + magic + battle regions
    and the final hash reflects both."""
    from tmos_randomizer.core.constants import (
        MAGIC_SHOP_BASE_PRICES,
        MAGIC_SHOP_BASE_PRICE_COUNT,
        SHOP_DATA_TABLE,
    )

    config = get_default_config()
    config.difficulty.shop_randomization.enabled = True
    config.difficulty.enemy_randomization.enabled = True
    rnd = Randomizer(config, strategy=_CopyStrategy(config, ValidationConfig(), None))
    plan = rnd.create_plan(7)
    out = tmp_path / "out.nes"
    result = rnd.apply(ROM_PATH, out, plan, generate_spoiler=False)

    vanilla = ROM_PATH.read_bytes()
    patched = out.read_bytes()
    allowed = (
        _battle_table_bytes()
        | set(range(SHOP_DATA_TABLE, SHOP_DATA_TABLE + 64))
        | set(range(
            MAGIC_SHOP_BASE_PRICES,
            MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT,
        ))
    )
    diff = {i for i, (a, b) in enumerate(zip(vanilla, patched)) if a != b}
    assert diff <= allowed
    assert result.rom_sha256 == hashlib.sha256(patched).hexdigest()
    assert "shops" in result.stats
    assert "enemies" in result.stats
