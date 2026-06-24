from tmos_randomizer.strategies import list_strategies, get_strategy


def test_v1_is_registered():
    assert "tmos_randomizer_v1" in list_strategies()


def test_v1_class_metadata():
    cls = get_strategy("tmos_randomizer_v1")
    assert cls.name == "tmos_randomizer_v1"
    assert cls.description  # non-empty
