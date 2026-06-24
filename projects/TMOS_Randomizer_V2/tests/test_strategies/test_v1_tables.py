from tmos_randomizer.strategies.v1 import tables as T


def test_shuffle_screen_counts():
    assert [len(x) for x in T.SHUFFLE_SCREENS] == [25, 25, 25, 21, 19]


def test_required_content_values():
    assert T.REQUIRED_CONTENTS[0] == [0x81, 0x83, 0x84]      # W1 Faruk/Kebabu/Aqua
    assert T.REQUIRED_CONTENTS[1] == [0x83]                  # W2 Epin
    assert T.REQUIRED_CONTENTS[4] == [0x80, 0x82, 0x83, 0x84, 0x85]  # W5


def test_past_screens_present_for_all_worlds():
    assert len(T.PAST_SCREENS) == 5
    assert all(len(p) > 0 for p in T.PAST_SCREENS)


def test_underwater_screens():
    assert T.UNDERWATER_SCREENS == (0x7A, 0x77, 0x82, 0x79, 0x78)


def test_object_set_groups_shape():
    assert len(T.OBJECT_SET_GROUPS) == 5
    assert len(T.DATAPOINTER_OBJECTSETS) == 5
    # Every allowed datapointer in a group must have an objectset candidate list.
    for wi in range(5):
        for screens, dps in T.OBJECT_SET_GROUPS[wi]:
            for dp in dps:
                assert dp in T.DATAPOINTER_OBJECTSETS[wi], f"world {wi} missing dp {dp:#x}"
