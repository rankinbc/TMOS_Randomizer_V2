from tmos_randomizer.core.enums import CRASH_ENEMY_IDS, CONSERVATIVE_DANGER_ENEMY_IDS


def test_hard_crash_enemy_ids():
    # 0x0B and 0x0C hard-crash the game if loaded in an encounter.
    assert CRASH_ENEMY_IDS == {0x0B, 0x0C}


def test_conservative_danger_ids_superset_of_crash():
    # Unknown-status IDs are treated conservatively as dangerous.
    assert CRASH_ENEMY_IDS.issubset(CONSERVATIVE_DANGER_ENEMY_IDS)
    assert {0x0F, 0x17, 0x25}.issubset(CONSERVATIVE_DANGER_ENEMY_IDS)
