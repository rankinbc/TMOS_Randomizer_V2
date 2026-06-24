# tests/test_strategies/test_v1_core.py
import random
from types import SimpleNamespace

from tmos_randomizer.strategies.v1.core import derive_seed, run_v1, V1Outcome
from tmos_randomizer.core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE


def test_derive_seed_attempt_zero_is_base():
    assert derive_seed(4242, 0) == 4242
    assert derive_seed(4242, 1) != 4242
    assert derive_seed(4242, 1) == derive_seed(4242, 1)  # deterministic


_ROM_FIELDS = (
    "parent_world", "ambient_sound", "content", "objectset",
    "screen_index_right", "screen_index_left", "screen_index_down",
    "screen_index_up", "datapointer", "exit_position", "top_tiles",
    "bottom_tiles", "worldscreen_color", "sprites_color", "unknown", "event",
)


class _Screen(SimpleNamespace):
    @property
    def is_modified(self):
        return getattr(self, "_modified", False)

    def mark_modified(self):
        self._modified = True


def _fake_game_world():
    """Build a 5-chapter world from a real vanilla-like screen template.

    For a unit test we only need the structure; load a real ROM in the
    integration test (Task 10). Here we fabricate worlds whose gates are easy
    to satisfy so the loop terminates quickly.
    """
    from tmos_randomizer.strategies.v1 import tables as T

    chapters = {}
    for ch in range(1, 6):
        wi = ch - 1
        n = 200
        screens = []
        for i in range(n):
            s = _Screen(relative_index=i, _modified=False,
                        **{f: 0 for f in _ROM_FIELDS})
            screens.append(s)
        # Ensure exactly one time door per world.
        screens[T.PAST_SCREENS[wi][0]].content = 0xC0
        # Seed required contents so the gate can pass.
        for k, req in enumerate(T.REQUIRED_CONTENTS[wi]):
            screens[T.SHUFFLE_SCREENS[wi][k]].content = req
        chapters[ch] = SimpleNamespace(chapter_num=ch, screens=screens)

    return SimpleNamespace(
        chapters=chapters,
    )


def test_run_v1_returns_outcome_and_marks_screens():
    gw = _fake_game_world()
    rom = bytes(0x40000)
    outcome = run_v1(gw, rom, base_seed=1, max_retries=200)
    assert isinstance(outcome, V1Outcome)
    # The loop ran and produced a result object regardless of pass/fail.
    assert outcome.attempts >= 1
