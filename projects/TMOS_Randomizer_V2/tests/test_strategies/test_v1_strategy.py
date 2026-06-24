from tmos_randomizer.strategies import list_strategies, get_strategy


def test_v1_is_registered():
    assert "tmos_randomizer_v1" in list_strategies()


def test_v1_class_metadata():
    cls = get_strategy("tmos_randomizer_v1")
    assert cls.name == "tmos_randomizer_v1"
    assert cls.description  # non-empty


# ---------------------------------------------------------------------------
# create_plan test (Task 8)
# ---------------------------------------------------------------------------

from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.validation.config import ValidationConfig
from tmos_randomizer.validation import ValidationRunner


def _make_strategy():
    cls = get_strategy("tmos_randomizer_v1")
    config = get_default_config()
    vconfig = ValidationConfig()
    runner = ValidationRunner(vconfig)
    return cls(config, vconfig, runner)


def test_create_plan_builds_valid_shell():
    strat = _make_strategy()
    plan = strat.create_plan(seed=12345)
    assert plan.seed == 12345
    assert plan.strategy_name == "tmos_randomizer_v1"
    assert plan.world_plan is not None
    assert plan.world_connections is not None
