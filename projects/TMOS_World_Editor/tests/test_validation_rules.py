"""Per-rule happy-path + violation tests for R-001..R-018."""
from __future__ import annotations

from src.tmos_world.model import Section
from src.tmos_world.rom.constants import EVENT_STAIRWAY, NAV_BLOCKED
from src.tmos_world.validation import validate_world
from tests.fixtures import (
    collidable_rom_bytes,
    make_screen,
    make_single_chapter_world,
)


def _issues_for(world, rule_id: str):
    return [i for i in validate_world(world) if i.rule_id == rule_id]


# ---------------------------------------------------------------------------
# R-001 — nav byte in valid range
# ---------------------------------------------------------------------------
def test_r001_pass():
    screens = [
        make_screen(nav_right=1, nav_left=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED),
        make_screen(nav_left=0, nav_right=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED),
    ]
    world = make_single_chapter_world(screens)
    assert _issues_for(world, "R-001") == []


def test_r001_violation_out_of_range():
    screens = [
        make_screen(nav_right=5, nav_left=NAV_BLOCKED),  # 5 >= screen_count=2
        make_screen(nav_left=0),
    ]
    world = make_single_chapter_world(screens)
    issues = _issues_for(world, "R-001")
    assert len(issues) == 1
    assert issues[0].severity == "ERROR"


# ---------------------------------------------------------------------------
# R-017 — blocked edge must have nav = 0xFF
# ---------------------------------------------------------------------------
def test_r017_pass_all_walkable():
    # default fixture ROM is all grass (walkable). Blocked nav on walkable edge
    # is not an R-017 violation.
    world = make_single_chapter_world([make_screen(nav_right=NAV_BLOCKED)])
    assert _issues_for(world, "R-017") == []


def test_r017_violation_collidable_edge_with_nonblocked_nav():
    rom = collidable_rom_bytes()
    # Edge is all trees → nav_right=0 (valid index) violates R-017.
    screens = [
        make_screen(nav_right=1, nav_left=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED),
        make_screen(nav_left=NAV_BLOCKED, nav_right=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED),
    ]
    world = make_single_chapter_world(screens, rom_bytes=rom)
    issues = _issues_for(world, "R-017")
    # All four edges of screen 0 + all four of screen 1 would fire except where already NAV_BLOCKED.
    # At minimum, nav_right=1 on screen 0 is a violation.
    assert any(i.screen_index == 0 and "nav_right" in i.message for i in issues)


# ---------------------------------------------------------------------------
# R-018 — grid-adjacent section mates must have matching nav
# ---------------------------------------------------------------------------
def test_r018_pass_matching_nav():
    s0 = make_screen(nav_right=1, nav_left=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED)
    s1 = make_screen(nav_left=0, nav_right=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED)
    world = make_single_chapter_world([s0, s1])
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (1, 0)})
    ]
    assert _issues_for(world, "R-018") == []


def test_r018_violation_mismatched_nav():
    s0 = make_screen(nav_right=NAV_BLOCKED, nav_left=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED)
    s1 = make_screen(nav_left=0, nav_right=NAV_BLOCKED, nav_up=NAV_BLOCKED, nav_down=NAV_BLOCKED)
    world = make_single_chapter_world([s0, s1])
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (1, 0)})
    ]
    issues = _issues_for(world, "R-018")
    assert len(issues) >= 1
    assert issues[0].severity == "ERROR"


# ---------------------------------------------------------------------------
# R-003 — reachability ≥95%
# ---------------------------------------------------------------------------
def test_r003_pass():
    screens = [
        make_screen(nav_right=1),
        make_screen(nav_left=0),
    ]
    world = make_single_chapter_world(screens)
    assert _issues_for(world, "R-003") == []


def test_r003_violation_isolated_screens():
    # 10 screens, only screen 0 reachable from itself (no nav anywhere).
    screens = [make_screen() for _ in range(10)]
    screens[0].nav_right = 1  # 1 edge -> 2 reachable / 10 = 20% → ERROR
    screens[1].nav_left = 0
    world = make_single_chapter_world(screens)
    issues = _issues_for(world, "R-003")
    assert len(issues) == 1
    assert issues[0].severity == "ERROR"


# ---------------------------------------------------------------------------
# R-004 — single connected component
# ---------------------------------------------------------------------------
def test_r004_pass():
    screens = [make_screen(nav_right=1), make_screen(nav_left=0)]
    world = make_single_chapter_world(screens)
    assert _issues_for(world, "R-004") == []


def test_r004_violation_two_components():
    screens = [
        make_screen(nav_right=1),
        make_screen(nav_left=0),
        make_screen(nav_right=3),
        make_screen(nav_left=2),
    ]
    world = make_single_chapter_world(screens)
    issues = _issues_for(world, "R-004")
    assert len(issues) == 1


# ---------------------------------------------------------------------------
# R-005 — time doors
# ---------------------------------------------------------------------------
def test_r005_pass():
    # One PRESENT time door, one PAST.
    screens = [
        make_screen(content=0xC0),  # present
        make_screen(content=0xC7),  # past
    ]
    world = make_single_chapter_world(screens, past_indices={1})
    assert _issues_for(world, "R-005") == []


def test_r005_violation_no_time_doors():
    world = make_single_chapter_world([make_screen(), make_screen()])
    issues = _issues_for(world, "R-005")
    assert len(issues) == 1


# ---------------------------------------------------------------------------
# R-002 — nav bytes do not cross period
# ---------------------------------------------------------------------------
def test_r002_pass():
    screens = [
        make_screen(nav_right=1),  # present
        make_screen(nav_left=0),   # present
        make_screen(nav_right=3),  # past
        make_screen(nav_left=2),   # past
    ]
    world = make_single_chapter_world(screens, past_indices={2, 3})
    assert _issues_for(world, "R-002") == []


def test_r002_violation_crosses_period():
    screens = [
        make_screen(nav_right=1),  # present -> past (illegal)
        make_screen(nav_left=0),   # past
    ]
    world = make_single_chapter_world(screens, past_indices={1})
    issues = _issues_for(world, "R-002")
    assert len(issues) >= 1


# ---------------------------------------------------------------------------
# R-007 — stairway destination sanity
# ---------------------------------------------------------------------------
def test_r007_pass_paired_stairway():
    screens = [
        make_screen(event=EVENT_STAIRWAY, content=1),
        make_screen(event=EVENT_STAIRWAY, content=0),
    ]
    world = make_single_chapter_world(screens)
    assert _issues_for(world, "R-007") == []


def test_r007_violation_unpaired_stairway():
    screens = [
        make_screen(event=EVENT_STAIRWAY, content=1),
        make_screen(),  # not a stairway — pairing broken
    ]
    world = make_single_chapter_world(screens)
    issues = _issues_for(world, "R-007")
    assert len(issues) == 1


# ---------------------------------------------------------------------------
# R-011 — section is internally connected
# ---------------------------------------------------------------------------
def test_r011_pass():
    screens = [make_screen() for _ in range(3)]
    world = make_single_chapter_world(screens)
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (1, 0), 2: (2, 0)})
    ]
    assert _issues_for(world, "R-011") == []


def test_r011_violation_disconnected():
    screens = [make_screen() for _ in range(3)]
    world = make_single_chapter_world(screens)
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False,
                members={0: (0, 0), 1: (5, 5), 2: (10, 10)})
    ]
    issues = _issues_for(world, "R-011")
    assert len(issues) == 1


# ---------------------------------------------------------------------------
# R-016 — no grid-position collisions in a section
# ---------------------------------------------------------------------------
def test_r016_pass():
    screens = [make_screen(), make_screen()]
    world = make_single_chapter_world(screens)
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (1, 0)})
    ]
    assert _issues_for(world, "R-016") == []


def test_r016_violation_duplicate_position():
    screens = [make_screen(), make_screen()]
    world = make_single_chapter_world(screens)
    world.chapters[0].sections = [
        Section(id=0, type="overworld", is_past=False, members={0: (0, 0), 1: (0, 0)})
    ]
    issues = _issues_for(world, "R-016")
    assert len(issues) == 1


# ---------------------------------------------------------------------------
# R-015 — edge walkable-compat (warning, mixed world)
# ---------------------------------------------------------------------------
def test_r015_warning_on_incompatible_edges():
    """Screen 0 walkable right edge (grass) meets screen 1 collidable left edge (trees)."""
    from src.tmos_world.rom.constants import (
        TILESECTION_BANK1_OFFSET,
        TILESECTION_BASE,
        TILESECTION_STRIDE,
    )

    rom = bytearray(0x50000)
    # tilesection 0 = all grass (walkable)
    for bank in (0, 1):
        off = TILESECTION_BASE + (TILESECTION_BANK1_OFFSET if bank else 0) + 0 * TILESECTION_STRIDE
        for i in range(32):
            rom[off + i] = 0x46
    # tilesection 1 = all trees (collidable)
    for bank in (0, 1):
        off = TILESECTION_BASE + (TILESECTION_BANK1_OFFSET if bank else 0) + 1 * TILESECTION_STRIDE
        for i in range(32):
            rom[off + i] = 0x47

    s0 = make_screen(nav_right=1, top_tiles=0, bottom_tiles=0, datapointer=0x00)
    s1 = make_screen(nav_left=0, top_tiles=1, bottom_tiles=1, datapointer=0x00)
    world = make_single_chapter_world([s0, s1], rom_bytes=bytes(rom))
    issues = _issues_for(world, "R-015")
    assert len(issues) >= 1
    assert issues[0].severity == "WARNING"


def test_r015_pass_same_tile_section():
    s0 = make_screen(nav_right=1)
    s1 = make_screen(nav_left=0)
    world = make_single_chapter_world([s0, s1])
    assert _issues_for(world, "R-015") == []
