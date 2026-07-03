"""Enemy/encounter randomization against the real bank 3 tables
(core/encounter_lineups.py + core/encounter_groups.py, ROM_VERIFIED offsets).
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tmos_randomizer.core.encounter_groups import (
    ENTRY_SIZE,
    GROUP_BASE,
    GROUP_COUNT,
    read_chapter_groups,
)
from tmos_randomizer.core.encounter_lineups import (
    LINEUP_BASE,
    LINEUP_COUNT,
    LINEUP_SIZE,
    SLOTS_PER_LINEUP,
)
from tmos_randomizer.core.enemies import is_special_slot
from tmos_randomizer.logic.enemy_randomization import create_enemy_plan

ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"

pytestmark = pytest.mark.skipif(not ROM_PATH.exists(), reason="ROM not found")


@pytest.fixture(scope="module")
def rom() -> bytes:
    return ROM_PATH.read_bytes()


def _chapter_enemy_multiset(rom: bytes, chapter: int) -> list[int]:
    ids = []
    for lineup_idx in range(LINEUP_COUNT[chapter]):
        base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
        for i in range(SLOTS_PER_LINEUP):
            b = rom[base + 1 + i]
            if not is_special_slot(b):
                ids.append(b)
    return sorted(ids)


def test_plan_is_deterministic(rom):
    a = create_enemy_plan(rom, 555, shuffle_lineups=True, reassign_groups=True, reward_jitter=True)
    b = create_enemy_plan(rom, 555, shuffle_lineups=True, reassign_groups=True, reward_jitter=True)
    assert a.lineup_slots == b.lineup_slots
    assert a.group_bytes == b.group_bytes
    assert a.reward_bytes == b.reward_bytes


def test_shuffle_preserves_per_chapter_enemy_multiset(rom):
    """Within-chapter shuffle only: same enemies per chapter, never moved
    across chapters (bank 3 stats/CHR are chapter-keyed)."""
    plan = create_enemy_plan(rom, 42, shuffle_lineups=True)
    out = bytearray(rom)
    plan.apply(out)
    for chapter in LINEUP_BASE:
        assert _chapter_enemy_multiset(bytes(out), chapter) == \
            _chapter_enemy_multiset(rom, chapter)


def test_empty_and_crash_slots_never_move(rom):
    """Slot positions holding 0x00/0xFF/0x0B/0x0C keep those exact bytes."""
    plan = create_enemy_plan(rom, 17, shuffle_lineups=True)
    out = bytearray(rom)
    plan.apply(out)
    for chapter in LINEUP_BASE:
        for lineup_idx in range(LINEUP_COUNT[chapter]):
            base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
            for i in range(SLOTS_PER_LINEUP):
                if is_special_slot(rom[base + 1 + i]):
                    assert out[base + 1 + i] == rom[base + 1 + i]


def test_start_bytes_untouched(rom):
    plan = create_enemy_plan(rom, 23, shuffle_lineups=True, reassign_groups=True, reward_jitter=True)
    out = bytearray(rom)
    plan.apply(out)
    for chapter in LINEUP_BASE:
        for lineup_idx in range(LINEUP_COUNT[chapter]):
            base = LINEUP_BASE[chapter] + lineup_idx * LINEUP_SIZE
            assert out[base] == rom[base]


def test_group_reassignment_all_chapters_within_vanilla_pool(rom):
    """RETMOS round 3: the low-7 selector is a GLOBAL lineup index (0-17)
    shared by all chapters; re-rolls stay within the lineup set the
    chapter's own entries use in the source ROM."""
    from tmos_randomizer.logic.enemy_randomization import vanilla_lineup_pool

    plan = create_enemy_plan(rom, 88, shuffle_lineups=False, reassign_groups=True)
    assert set(plan.group_bytes) == {1, 2, 3, 4, 5}
    out = bytearray(rom)
    plan.apply(out)
    for chapter in range(1, 6):
        allowed = set(vanilla_lineup_pool(rom, chapter))
        assert allowed <= set(range(18))
        for entry in read_chapter_groups(bytes(out), chapter)["entries"]:
            assert entry["monster_group_low"] in allowed
        # High bit preserved per entry.
        for entry_idx, new_byte in plan.group_bytes[chapter].items():
            base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
            assert (new_byte & 0x80) == (rom[base + 1] & 0x80)


def test_reward_jitter_bounded(rom):
    plan = create_enemy_plan(rom, 3, shuffle_lineups=False, reward_jitter=True)
    for chapter, entries in plan.reward_bytes.items():
        for entry_idx, new_reward in entries.items():
            base = GROUP_BASE[chapter] + entry_idx * ENTRY_SIZE
            old = rom[base + 2]
            assert 0 <= new_reward <= 3
            assert abs(new_reward - old) <= 1


def test_apply_writes_only_battle_table_regions(rom):
    """Byte diff confined to the lineup slot bytes + group entry bytes."""
    plan = create_enemy_plan(rom, 7, shuffle_lineups=True, reassign_groups=True, reward_jitter=True)
    out = bytearray(rom)
    plan.apply(out)

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

    diff = {i for i, (a, b) in enumerate(zip(rom, out)) if a != b}
    assert diff, "plan with all options on should change something"
    assert diff <= allowed


def test_disabled_options_write_nothing(rom):
    plan = create_enemy_plan(
        rom, 7, shuffle_lineups=False, reassign_groups=False, reward_jitter=False
    )
    out = bytearray(rom)
    written = plan.apply(out)
    # shuffle_lineups=False leaves no lineup entries; group/rate dicts empty.
    assert bytes(out) == rom
    assert written == 0


def test_spoiler_shape(rom):
    plan = create_enemy_plan(rom, 11, shuffle_lineups=True, reassign_groups=True)
    sp = plan.to_spoiler()
    assert sp["seed"] == 11
    assert sp["lineups"], "expected lineup entries"
    for entry in sp["lineups"]:
        assert 1 <= entry["chapter"] <= 5
        for slot in entry["slots"]:
            assert slot["name"] != "-"
