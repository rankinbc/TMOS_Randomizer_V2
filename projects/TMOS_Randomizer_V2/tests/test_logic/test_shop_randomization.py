"""Shop randomization against the real Bank 1 tables (spec:
knowledge/systems/shops-and-economy.md). Replaces the old
test_shop_randomization_disabled.py tripwire — the module is live again,
now targeting the verified offsets instead of the 0xD544 misread.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.constants import (
    MAGIC_SHOP_BASE_PRICES,
    MAGIC_SHOP_BASE_PRICE_COUNT,
    SHOP_CODES_UNVERIFIED,
    SHOP_CODES_VERIFIED,
    SHOP_DATA_TABLE,
)
from tmos_randomizer.core.shop_economy import MAGIC_BASE_PRICE_MAX, read_all_shops
from tmos_randomizer.logic.shop_randomization import create_shop_plan

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")


@pytest.fixture(scope="module")
def rom() -> bytes:
    return ROM_PATH.read_bytes()


def test_plan_is_deterministic(rom):
    a = create_shop_plan(rom, 1234, shuffle_slots=True, price_variance=0.25)
    b = create_shop_plan(rom, 1234, shuffle_slots=True, price_variance=0.25)
    assert a.slot_assignments == b.slot_assignments
    assert a.magic_base_prices == b.magic_base_prices


def test_shuffle_preserves_code_multiset(rom):
    """No codes invented, none lost — $10/$11 stay exactly as prevalent."""
    vanilla = sorted(s["item_code"] for s in read_all_shops(rom))
    plan = create_shop_plan(rom, 42, shuffle_slots=True)
    shuffled = sorted(
        s["item_code"] for slots in plan.slot_assignments for s in slots
    )
    assert shuffled == vanilla


def test_all_planned_codes_known(rom):
    plan = create_shop_plan(rom, 7, shuffle_slots=True, price_variance=1.0)
    known = SHOP_CODES_VERIFIED | SHOP_CODES_UNVERIFIED
    for slots in plan.slot_assignments:
        for s in slots:
            assert s["item_code"] in known


def test_price_bounds_respected_at_max_variance(rom):
    """Even at 100% variance + max multiplier, clamps hold."""
    plan = create_shop_plan(
        rom, 99, shuffle_slots=True, price_variance=1.0, price_multiplier=10.0
    )
    for slots in plan.slot_assignments:
        for s in slots:
            assert 1 <= s["base_price"] <= 255
            if s["item_code"] in (0x33, 0x34):
                assert s["base_price"] <= 99, "qty item price x 10 would exceed 999 gold"


def test_apply_writes_only_shop_and_magic_regions(rom):
    """SHA-style guard: applying the plan changes ONLY the 64-byte shop data
    block and the 11-byte magic price table."""
    plan = create_shop_plan(
        rom, 5, shuffle_slots=True, price_variance=0.5, randomize_magic_prices=True
    )
    patched = bytearray(rom)
    plan.apply(patched)

    allowed = set(range(SHOP_DATA_TABLE, SHOP_DATA_TABLE + 64)) | set(
        range(MAGIC_SHOP_BASE_PRICES, MAGIC_SHOP_BASE_PRICES + MAGIC_SHOP_BASE_PRICE_COUNT)
    )
    diff = {i for i, (a, b) in enumerate(zip(rom, patched)) if a != b}
    assert diff, "plan applied but nothing changed"
    assert diff <= allowed, f"bytes outside shop regions changed: {sorted(diff - allowed)[:10]}"


def test_noop_plan_changes_nothing(rom):
    plan = create_shop_plan(rom, 5, shuffle_slots=False, price_variance=0.0)
    patched = bytearray(rom)
    plan.apply(patched)
    assert bytes(patched) == rom


def test_magic_prices_clamped(rom):
    plan = create_shop_plan(
        rom, 11, price_variance=1.0, price_multiplier=10.0, randomize_magic_prices=True
    )
    assert all(1 <= p <= MAGIC_BASE_PRICE_MAX for p in plan.magic_base_prices)


def test_invalid_options_rejected(rom):
    with pytest.raises(ValueError):
        create_shop_plan(rom, 1, price_variance=1.5)
    with pytest.raises(ValueError):
        create_shop_plan(rom, 1, price_multiplier=0.0)


def test_spoiler_shape(rom):
    plan = create_shop_plan(rom, 3)
    sp = plan.to_spoiler()
    assert len(sp["shops"]) == 8
    assert all(len(s["slots"]) == 4 for s in sp["shops"])
    assert len(sp["magic_base_prices"]) == 11


def test_never_emits_pending_gold_code(rom):
    """Tripwire for the removed sell_keys misfeature: code $18 credits +1
    PENDING GOLD ($0308 — RETMOS round 3), not a key. A '$18 slot' would
    sell 1 gold for the slot price, so no plan may ever emit it."""
    for seed in (1, 21, 99):
        plan = create_shop_plan(
            rom, seed, shuffle_slots=True, price_variance=1.0,
            randomize_magic_prices=True,
        )
        codes = [s["item_code"] for slots in plan.slot_assignments for s in slots]
        assert 0x18 not in codes


def test_sell_keys_parameter_removed(rom):
    with pytest.raises(TypeError):
        create_shop_plan(rom, 1, sell_keys=3)
