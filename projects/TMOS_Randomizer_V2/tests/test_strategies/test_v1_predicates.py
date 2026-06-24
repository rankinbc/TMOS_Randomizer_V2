import random

from tmos_randomizer.strategies.v1.predicates import (
    is_demon, is_wizard, is_town, is_enemy_door,
    has_time_door, has_content_entrance, fisher_yates,
)


def test_is_demon_range():
    assert is_demon(0x21) and is_demon(0x2A)
    assert not is_demon(0x20) and not is_demon(0x2B)


def test_is_wizard_and_town_and_timedoor():
    assert is_wizard(0x01) and not is_wizard(0x02)
    assert is_town(0x12) and not is_town(0x11)
    assert has_time_door(0xC0) and not has_time_door(0xC1)


def test_is_enemy_door_known_pairs():
    assert is_enemy_door(0x61, 0x10)
    assert is_enemy_door(0x9F, 0x0D)
    assert not is_enemy_door(0x61, 0x0F)


def test_has_content_entrance():
    assert has_content_entrance(0xFE, 0x00, 0x00, 0x00)
    assert not has_content_entrance(0x00, 0x01, 0x02, 0x03)


def test_fisher_yates_is_deterministic_and_a_permutation():
    a = list(range(20))
    b = list(range(20))
    fisher_yates(a, random.Random(123))
    fisher_yates(b, random.Random(123))
    assert a == b                      # deterministic for a fixed seed
    assert sorted(a) == list(range(20))  # still a permutation
    assert a != list(range(20))         # actually shuffled
