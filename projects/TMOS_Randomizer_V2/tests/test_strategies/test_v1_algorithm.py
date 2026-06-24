# tests/test_strategies/test_v1_algorithm.py
import random
from types import SimpleNamespace

from tmos_randomizer.strategies.v1 import algorithm as A
from tmos_randomizer.strategies.v1 import tables as T


def _mk(content=0x00, objectset=0x00, datapointer=0x00, parent_world=0x00,
        event=0x00, sprites_color=0x00, nav=0x00):
    return SimpleNamespace(
        content=content, objectset=objectset, datapointer=datapointer,
        parent_world=parent_world, event=event, sprites_color=sprites_color,
        screen_index_right=nav, screen_index_left=nav,
        screen_index_down=nav, screen_index_up=nav,
        relative_index=0, _modified=False,
    )


def _world(n):
    screens = [_mk() for _ in range(n)]
    for i, s in enumerate(screens):
        s.relative_index = i
    return screens


def test_shuffle_contents_is_a_permutation_of_shuffled_screens():
    n = 200
    screens = _world(n)
    # Give each shuffleable screen a distinct content so we can track the multiset.
    for k, idx in enumerate(T.SHUFFLE_SCREENS[0]):
        screens[idx].content = 0x40 + k
    originals = [_mk(content=s.content) for s in screens]
    for i, o in enumerate(originals):
        o.relative_index = i

    before = sorted(screens[idx].content for idx in T.SHUFFLE_SCREENS[0])
    A.shuffle_contents(screens, originals, 0, random.Random(1))
    after = sorted(screens[idx].content for idx in T.SHUFFLE_SCREENS[0])
    assert before == after  # same multiset, just rearranged


def test_time_doors_ok_requires_exactly_one():
    screens = _world(200)
    # zero time doors -> not ok
    assert A.time_doors_ok(screens, 0) is False
    # exactly one in a past screen -> ok
    screens[T.PAST_SCREENS[0][0]].content = 0xC0
    assert A.time_doors_ok(screens, 0) is True
    # two -> not ok
    screens[T.PAST_SCREENS[0][1]].content = 0xC0
    assert A.time_doors_ok(screens, 0) is False


def test_required_content_present():
    screens = _world(200)
    assert A.required_content_present(screens, 1) is False  # needs 0x83 somewhere
    screens[5].content = 0x83
    assert A.required_content_present(screens, 1) is True


def test_other_problems_flags_blank_entrance():
    screens = _world(200)
    originals = _world(200)
    s = screens[10]
    s.screen_index_down = 0xFE   # an entrance screen
    s.content = 0xFF             # blanked -> problem
    assert A.other_problems_ok(screens, originals, 0) is False
