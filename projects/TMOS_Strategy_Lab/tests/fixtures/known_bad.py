"""Hand-crafted broken Candidate for metric-negative tests.

Each ``make_*`` helper returns a minimal ``Candidate`` / ``LabContext`` pair
where exactly one metric is expected to fail, with everything else PASS or
not-applicable. Tests reach for these instead of a full ROM parse.
"""
from __future__ import annotations

from typing import Any

from tmos_strategy_lab._v2_compat.parsers import Chapter, GameWorld, WorldScreen
from tmos_strategy_lab.context import LabContext
from tmos_strategy_lab.models import Candidate


def _blank_screen(ch: int, rel: int, global_index: int, **overrides: Any) -> WorldScreen:
    base = dict(
        global_index=global_index,
        chapter=ch,
        relative_index=rel,
        parent_world=0x40,  # OVERWORLD_GREEN
        ambient_sound=0,
        content=0,
        objectset=0,
        screen_index_right=0xFF,
        screen_index_left=0xFF,
        screen_index_down=0xFF,
        screen_index_up=0xFF,
        datapointer=0x00,
        exit_position=0,
        top_tiles=0,
        bottom_tiles=0,
        worldscreen_color=0,
        sprites_color=0,
        unknown=0,
        event=0,
    )
    base.update(overrides)
    return WorldScreen(**base)


def _wrap_candidate(screens: list[WorldScreen], ch: int = 1) -> Candidate:
    return Candidate(
        strategy_id="known_bad@test",
        strategy_version="0.0.0",
        seed=0,
        chapters={ch: [s.to_dict() for s in screens]},
        repairs=[],
        breadcrumbs={},
    )


def _stub_ctx() -> LabContext:
    """LabContext with an empty game_world — metrics don't need the stock
    baseline, they only care about the Candidate's dict form."""
    world = GameWorld()
    world.add_chapter(Chapter(chapter_num=1))
    return LabContext(
        game_world=world,
        rom_bytes=None,
        source="test:known_bad",
        rom_md5=None,
    )


# -----------------------------------------------------------------------------
# Known-bad generators (one per metric)
# -----------------------------------------------------------------------------

def make_broken_reachability() -> tuple[Candidate, LabContext]:
    """A randomizable screen with zero in-edges and zero out-edges → reachability FAIL.

    Construction: two screens, the first is a two-way loop with itself (points
    back and forth at the nav layer so it has at least one live edge), and the
    second is a fully-blocked randomizable screen nothing points at.
    """
    # s0 has a self-loop-ish edge (right=0, left=0). It's technically its own
    # neighbor after the filter, which `get_connected_screens` allows — so s0
    # has_out=True and has_in=True (via its own references).
    s0 = _blank_screen(1, 0, global_index=100000, screen_index_right=0, screen_index_left=0)
    # s1: all 0xFF, and no other screen mentions it → pure orphan.
    s1 = _blank_screen(1, 1, global_index=100001)
    return _wrap_candidate([s0, s1]), _stub_ctx()


def make_broken_bidirectional() -> tuple[Candidate, LabContext]:
    """Screen 0 → 1 without 1 → 0 (both OVERWORLD, no MAZE or event)."""
    s0 = _blank_screen(1, 0, global_index=100000, screen_index_right=1)
    s1 = _blank_screen(1, 1, global_index=100001, screen_index_left=0xFF, screen_index_up=0)
    # s1 points UP to s0 (which is fine, makes reachability pass), but left is
    # 0xFF so s1→0 via left doesn't exist. But we need the failure to be a
    # missing reverse edge specifically. Easier construction:
    s0 = _blank_screen(1, 0, global_index=100000, screen_index_right=1, screen_index_left=1)
    s1 = _blank_screen(1, 1, global_index=100001, screen_index_left=0xFF, screen_index_up=0, screen_index_down=0)
    # s0.right = 1 ; s1.left = 0xFF → violation
    return _wrap_candidate([s0, s1]), _stub_ctx()


def make_broken_stairway() -> tuple[Candidate, LabContext]:
    """Screen with Event=0x40 pointing at a non-stairway destination."""
    # s0 is a stairway pointing at s1 (rel=1), but s1 is NOT a stairway.
    s0 = _blank_screen(1, 0, global_index=100000, event=0x40, content=1)
    s1 = _blank_screen(1, 1, global_index=100001, screen_index_up=0)  # non-stairway
    return _wrap_candidate([s0, s1]), _stub_ctx()


def make_broken_datapointer() -> tuple[Candidate, LabContext]:
    """ObjectSet incompatible with DataPointer."""
    # CHR bank 0x0E is in the V2 OBJECTSET_COMPATIBILITY table; ObjectSet 0xFF
    # is NOT in its compatible set.
    s0 = _blank_screen(1, 0, global_index=100000,
                       datapointer=0x0E,
                       objectset=0xFF,
                       screen_index_right=1)
    s1 = _blank_screen(1, 1, global_index=100001,
                       datapointer=0x0E,
                       objectset=0x01,
                       screen_index_left=0)
    return _wrap_candidate([s0, s1]), _stub_ctx()


def make_broken_softlock() -> tuple[Candidate, LabContext]:
    """Screen pointed at by another but has zero outgoing edges."""
    # s0 → s1 (right). s1 has all 0xFF outgoing. s1 section is OVERWORLD (not
    # in softlock exemption set), event=0, gidx 100001 (not in
    # DO_NOT_RANDOMIZE).
    s0 = _blank_screen(1, 0, global_index=100000, screen_index_right=1, screen_index_left=1)
    s1 = _blank_screen(1, 1, global_index=100001)
    return _wrap_candidate([s0, s1]), _stub_ctx()


def make_known_good() -> tuple[Candidate, LabContext]:
    """Two screens in a bidirectional link with matching DP/ObjectSet."""
    s0 = _blank_screen(1, 0, global_index=100000,
                       datapointer=0x0E, objectset=0x11,  # 0x11 is in CHR 0x0E's compat set
                       screen_index_right=1)
    s1 = _blank_screen(1, 1, global_index=100001,
                       datapointer=0x0E, objectset=0x11,  # 0x11 is in CHR 0x0E's compat set
                       screen_index_left=0)
    return _wrap_candidate([s0, s1]), _stub_ctx()


__all__ = [
    "make_broken_reachability",
    "make_broken_bidirectional",
    "make_broken_stairway",
    "make_broken_datapointer",
    "make_broken_softlock",
    "make_known_good",
]
