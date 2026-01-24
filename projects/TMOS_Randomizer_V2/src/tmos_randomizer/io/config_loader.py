"""Configuration loading and validation.

Loads YAML configuration files with defaults and validation.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Union

import yaml

from ..validation.config import (
    ValidationConfig,
    EdgeCompatibilityConfig,
    ScreenTraversabilityConfig,
    DataPointerObjectSetConfig,
    NavigationConfig,
    ReachabilityConfig,
)


# =============================================================================
# Configuration Dataclasses
# =============================================================================

@dataclass
class GeneralConfig:
    """General randomizer settings."""
    seed: int = 0
    chapters: List[int] = field(default_factory=lambda: [1, 2, 3, 4, 5])
    mode: str = "shuffle"


@dataclass
class ShufflingConfig:
    """Section shuffling settings."""
    enabled: bool = True
    shape: str = "blob"
    min_width: int = 3
    connectivity: float = 0.3


@dataclass
class ConnectivityConfig:
    """Section connectivity settings."""
    dungeon_last: bool = True
    order_randomization: bool = True
    topology: str = "branching"
    enforce_bidirectional: bool = True


@dataclass
class TileSectionConfig:
    """TileSection handling settings."""
    mode: str = "preserve"
    within_chapter: bool = True
    cross_chapter: bool = False
    match_terrain: bool = True
    strict_edge_match: bool = True


@dataclass
class CriticalPathConfig:
    """Critical path and progression settings."""
    enabled: bool = True
    mode: str = "beatable"
    enforce_time_doors: bool = True
    max_shuffle_attempts: int = 1000


@dataclass
class ExclusionConfigData:
    """Exclusion settings."""
    boss_screens: bool = True
    victory_screens: bool = True
    wizard_battles: bool = True
    special_events: bool = True
    enemy_doors: bool = True
    dangerous_events: bool = True
    custom_exclude: Set[int] = field(default_factory=set)
    force_include: Set[int] = field(default_factory=set)


@dataclass
class ObjectSetScatterConfig:
    """ObjectSet scatter enforcement settings."""
    enabled: bool = True
    max_consecutive_same_difficulty: int = 2


@dataclass
class ObjectSetRandomizationConfig:
    """ObjectSet randomization settings.

    Controls how enemies are distributed across screens with difficulty tiers.
    """
    enabled: bool = True
    distribution: Dict[str, Dict[str, float]] = field(default_factory=lambda: {
        "overworld": {"easy": 0.35, "medium": 0.45, "hard": 0.20},
        "dungeon": {"easy": 0.20, "medium": 0.40, "hard": 0.40},
        "maze": {"easy": 0.25, "medium": 0.50, "hard": 0.25},
        "special": {"easy": 0.30, "medium": 0.40, "hard": 0.30},
    })
    scatter: ObjectSetScatterConfig = field(default_factory=ObjectSetScatterConfig)
    pool_mixing: str = "within_chapter"  # none, within_chapter, cross_chapter
    preset: Optional[str] = None  # casual, balanced, challenging, brutal


@dataclass
class ShopRandomizationConfig:
    """Shop inventory randomization settings.

    Controls how items and prices are randomized across shops.
    """
    enabled: bool = True

    # Inventory settings
    randomize_items: bool = True
    preserve_shop_types: bool = True  # Keep general vs magic distinction

    # Price settings
    randomize_prices: bool = True
    price_variance: float = 0.25  # +/- 25% from base price
    price_multiplier: float = 1.0  # Global price multiplier

    # Progression settings
    exclude_progression_items: bool = True  # Exclude swords/rods from shops

    # Required items
    ensure_bread_available: bool = True
    ensure_mashroob_available: bool = True
    ensure_keys_available: bool = True


@dataclass
class DifficultyConfig:
    """Difficulty and balance settings."""
    preset: str = "normal"
    enemy_hp_multiplier: float = 1.0
    enemy_damage_multiplier: float = 1.0
    shop_price_multiplier: float = 1.0
    starting_gold: int = 0
    key_item_bias: str = "balanced"
    objectset_randomization: ObjectSetRandomizationConfig = field(
        default_factory=ObjectSetRandomizationConfig
    )
    shop_randomization: ShopRandomizationConfig = field(
        default_factory=ShopRandomizationConfig
    )


@dataclass
class OutputConfig:
    """Output settings."""
    filename: str = "TMOS_Randomized.nes"
    spoiler_log_enabled: bool = True
    spoiler_text_filename: str = "spoiler.txt"
    spoiler_json_filename: str = "spoiler.json"
    validation_report: bool = True


@dataclass
class RandomizerConfig:
    """Complete randomizer configuration."""
    general: GeneralConfig = field(default_factory=GeneralConfig)
    shuffling: Dict[str, ShufflingConfig] = field(default_factory=dict)
    connectivity: ConnectivityConfig = field(default_factory=ConnectivityConfig)
    tilesections: TileSectionConfig = field(default_factory=TileSectionConfig)
    critical_path: CriticalPathConfig = field(default_factory=CriticalPathConfig)
    exclusions: ExclusionConfigData = field(default_factory=ExclusionConfigData)
    difficulty: DifficultyConfig = field(default_factory=DifficultyConfig)
    output: OutputConfig = field(default_factory=OutputConfig)

    # Raw YAML data for custom access
    _raw: Dict[str, Any] = field(default_factory=dict, repr=False)

    def get(self, path: str, default: Any = None) -> Any:
        """Get a nested config value by dot-separated path.

        Args:
            path: Dot-separated path like "shuffling.overworld.enabled"
            default: Value to return if path not found

        Returns:
            Configuration value or default
        """
        keys = path.split(".")
        value = self._raw
        for key in keys:
            if isinstance(value, dict) and key in value:
                value = value[key]
            else:
                return default
        return value


# =============================================================================
# Loading Functions
# =============================================================================

def load_config(config_path: Union[str, Path]) -> RandomizerConfig:
    """Load configuration from YAML file.

    Args:
        config_path: Path to YAML configuration file

    Returns:
        RandomizerConfig with loaded values

    Raises:
        FileNotFoundError: If config file doesn't exist
        yaml.YAMLError: If YAML is invalid
    """
    config_path = Path(config_path)
    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found: {config_path}")

    with open(config_path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f) or {}

    return _parse_config(raw)


def load_config_with_defaults(
    config_path: Optional[Union[str, Path]] = None,
    overrides: Optional[Dict[str, Any]] = None,
) -> RandomizerConfig:
    """Load configuration with default fallbacks.

    Args:
        config_path: Optional path to user config (merged over defaults)
        overrides: Optional dict of overrides (merged over loaded config)

    Returns:
        RandomizerConfig with merged values
    """
    # Start with defaults
    config = get_default_config()

    # Load and merge user config if provided
    if config_path:
        user_config = load_config(config_path)
        config = _merge_configs(config, user_config)

    # Apply overrides
    if overrides:
        config._raw = _deep_merge(config._raw, overrides)
        config = _parse_config(config._raw)

    return config


def get_default_config() -> RandomizerConfig:
    """Get the default configuration.

    Returns:
        RandomizerConfig with all default values
    """
    # Try to load from bundled default.yaml
    default_path = Path(__file__).parent.parent.parent.parent / "config" / "default.yaml"
    if default_path.exists():
        return load_config(default_path)

    # Return programmatic defaults
    return RandomizerConfig()


# =============================================================================
# Parsing Functions
# =============================================================================

def _parse_config(raw: Dict[str, Any]) -> RandomizerConfig:
    """Parse raw YAML dict into RandomizerConfig.

    Args:
        raw: Dictionary from YAML loading

    Returns:
        Populated RandomizerConfig
    """
    config = RandomizerConfig()
    config._raw = raw

    # General
    if "general" in raw:
        g = raw["general"]
        config.general = GeneralConfig(
            seed=g.get("seed", 0),
            chapters=g.get("chapters", [1, 2, 3, 4, 5]),
            mode=g.get("mode", "shuffle"),
        )

    # Shuffling (per-section)
    if "shuffling" in raw:
        for section, settings in raw["shuffling"].items():
            if isinstance(settings, dict):
                config.shuffling[section] = ShufflingConfig(
                    enabled=settings.get("enabled", True),
                    shape=settings.get("shape", "blob"),
                    min_width=settings.get("min_width", 3),
                    connectivity=settings.get("connectivity", 0.3),
                )

    # Connectivity
    if "connectivity" in raw:
        c = raw["connectivity"]
        config.connectivity = ConnectivityConfig(
            dungeon_last=c.get("dungeon_last", True),
            order_randomization=c.get("order_randomization", True),
            topology=c.get("topology", "branching"),
            enforce_bidirectional=c.get("bidirectional", {}).get("enforce", True),
        )

    # TileSections
    if "tilesections" in raw:
        t = raw["tilesections"]
        shuffle = t.get("shuffle", {})
        edges = t.get("edges", {})
        config.tilesections = TileSectionConfig(
            mode=t.get("mode", "preserve"),
            within_chapter=shuffle.get("within_chapter", True),
            cross_chapter=shuffle.get("cross_chapter", False),
            match_terrain=shuffle.get("match_terrain", True),
            strict_edge_match=edges.get("strict_match", True),
        )

    # Critical Path
    if "critical_path" in raw:
        cp = raw["critical_path"]
        td = cp.get("time_doors", {})
        config.critical_path = CriticalPathConfig(
            enabled=cp.get("enabled", True),
            mode=cp.get("mode", "beatable"),
            enforce_time_doors=td.get("enforce_single_in_past", True),
            max_shuffle_attempts=td.get("max_shuffle_attempts", 1000),
        )

    # Exclusions
    if "exclusions" in raw:
        e = raw["exclusions"]
        config.exclusions = ExclusionConfigData(
            boss_screens=e.get("boss_screens", True),
            victory_screens=e.get("victory_screens", True),
            wizard_battles=e.get("wizard_battles", True),
            special_events=e.get("special_events", True),
            enemy_doors=e.get("enemy_doors", True),
            dangerous_events=e.get("dangerous_events", True),
            custom_exclude=set(e.get("custom_exclude", [])),
            force_include=set(e.get("force_include", [])),
        )

    # Difficulty
    if "difficulty" in raw:
        d = raw["difficulty"]
        combat = d.get("combat", {})
        economy = d.get("economy", {})
        progression = d.get("progression", {})

        # Parse ObjectSet randomization config
        osr = d.get("objectset_randomization", {})
        osr_scatter = osr.get("scatter", {})
        objectset_config = ObjectSetRandomizationConfig(
            enabled=osr.get("enabled", True),
            distribution=osr.get("distribution", {
                "overworld": {"easy": 0.35, "medium": 0.45, "hard": 0.20},
                "dungeon": {"easy": 0.20, "medium": 0.40, "hard": 0.40},
                "maze": {"easy": 0.25, "medium": 0.50, "hard": 0.25},
                "special": {"easy": 0.30, "medium": 0.40, "hard": 0.30},
            }),
            scatter=ObjectSetScatterConfig(
                enabled=osr_scatter.get("enabled", True),
                max_consecutive_same_difficulty=osr_scatter.get(
                    "max_consecutive_same_difficulty", 2
                ),
            ),
            pool_mixing=osr.get("pool_mixing", "within_chapter"),
            preset=osr.get("preset"),
        )

        # Parse Shop randomization config
        sr = d.get("shop_randomization", {})
        shop_config = ShopRandomizationConfig(
            enabled=sr.get("enabled", True),
            randomize_items=sr.get("randomize_items", True),
            preserve_shop_types=sr.get("preserve_shop_types", True),
            randomize_prices=sr.get("randomize_prices", True),
            price_variance=sr.get("price_variance", 0.25),
            price_multiplier=sr.get("price_multiplier", 1.0),
            exclude_progression_items=sr.get("exclude_progression_items", True),
            ensure_bread_available=sr.get("ensure_bread_available", True),
            ensure_mashroob_available=sr.get("ensure_mashroob_available", True),
            ensure_keys_available=sr.get("ensure_keys_available", True),
        )

        config.difficulty = DifficultyConfig(
            preset=d.get("preset", "normal"),
            enemy_hp_multiplier=combat.get("enemy_hp_multiplier", 1.0),
            enemy_damage_multiplier=combat.get("enemy_damage_multiplier", 1.0),
            shop_price_multiplier=economy.get("shop_price_multiplier", 1.0),
            starting_gold=economy.get("starting_gold", 0),
            key_item_bias=progression.get("key_item_bias", "balanced"),
            objectset_randomization=objectset_config,
            shop_randomization=shop_config,
        )

    # Output
    if "output" in raw:
        o = raw["output"]
        spoiler = o.get("spoiler_log", {})
        config.output = OutputConfig(
            filename=o.get("filename", "TMOS_Randomized.nes"),
            spoiler_log_enabled=spoiler.get("enabled", True),
            spoiler_text_filename=spoiler.get("text_filename", "spoiler.txt"),
            spoiler_json_filename=spoiler.get("json_filename", "spoiler.json"),
            validation_report=o.get("validation_report", True),
        )

    return config


def _merge_configs(base: RandomizerConfig, override: RandomizerConfig) -> RandomizerConfig:
    """Merge two configs, with override taking precedence."""
    merged_raw = _deep_merge(base._raw, override._raw)
    return _parse_config(merged_raw)


def _deep_merge(base: Dict, override: Dict) -> Dict:
    """Deep merge two dictionaries."""
    result = base.copy()
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = _deep_merge(result[key], value)
        else:
            result[key] = value
    return result


def parse_validation_config(raw: Dict[str, Any]) -> ValidationConfig:
    """Parse validation config from raw YAML dict.

    Args:
        raw: Raw config dictionary (full config or just validation section)

    Returns:
        ValidationConfig with parsed values
    """
    # If raw is the full config, extract validation section
    if "validation" in raw:
        raw = raw["validation"]

    config = ValidationConfig()

    # Global settings
    if "stop_on_first_error" in raw:
        config.stop_on_first_error = raw["stop_on_first_error"]
    if "max_issues_per_validator" in raw:
        config.max_issues_per_validator = raw["max_issues_per_validator"]
    if "run_incremental" in raw:
        config.run_incremental = raw["run_incremental"]
    if "run_final" in raw:
        config.run_final = raw["run_final"]

    # Edge Compatibility
    if "edge_compatibility" in raw:
        ec = raw["edge_compatibility"]
        config.edge_compatibility = EdgeCompatibilityConfig(
            enabled=ec.get("enabled", True),
            severity=ec.get("severity", "error"),
            max_issues=ec.get("max_issues", 100),
            min_walkable_tiles=ec.get("min_walkable_tiles", 1),
            check_horizontal=ec.get("check_horizontal", True),
            check_vertical=ec.get("check_vertical", True),
            allow_hazard_to_hazard=ec.get("allow_hazard_to_hazard", True),
            allow_collidable_to_collidable=ec.get("allow_collidable_to_collidable", True),
        )

    # Screen Traversability
    if "screen_traversability" in raw:
        st = raw["screen_traversability"]
        config.screen_traversability = ScreenTraversabilityConfig(
            enabled=st.get("enabled", True),
            severity=st.get("severity", "warning"),
            max_issues=st.get("max_issues", 100),
            algorithm=st.get("algorithm", "bfs"),
            require_entry_to_exit=st.get("require_entry_to_exit", True),
            allow_partial_exits=st.get("allow_partial_exits", True),
            treat_hazards_as_blocking=st.get("treat_hazards_as_blocking", False),
        )

    # DataPointer-ObjectSet
    if "datapointer_objectset" in raw:
        dpo = raw["datapointer_objectset"]
        config.datapointer_objectset = DataPointerObjectSetConfig(
            enabled=dpo.get("enabled", True),
            severity=dpo.get("severity", "error"),
            max_issues=dpo.get("max_issues", 100),
            strict_mode=dpo.get("strict_mode", True),
            allow_unknown_chr=dpo.get("allow_unknown_chr", False),
        )

    # Navigation
    if "navigation" in raw:
        nav = raw["navigation"]
        config.navigation = NavigationConfig(
            enabled=nav.get("enabled", True),
            severity=nav.get("severity", "error"),
            require_bidirectional=nav.get("require_bidirectional", True),
            allow_one_way_maze=nav.get("allow_one_way_maze", True),
        )

    # Reachability
    if "reachability" in raw:
        reach = raw["reachability"]
        config.reachability = ReachabilityConfig(
            enabled=reach.get("enabled", True),
            severity=reach.get("severity", "error"),
            min_reachability_percent=reach.get("min_reachability_percent", 100.0),
            check_critical_locations=reach.get("check_critical_locations", True),
        )

    return config


def load_validation_config(config_path: Union[str, Path]) -> ValidationConfig:
    """Load validation configuration from YAML file.

    Args:
        config_path: Path to YAML configuration file

    Returns:
        ValidationConfig with loaded values
    """
    config_path = Path(config_path)
    if not config_path.exists():
        return ValidationConfig()

    with open(config_path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f) or {}

    return parse_validation_config(raw)


def get_default_validation_config() -> ValidationConfig:
    """Get the default validation configuration.

    Returns:
        ValidationConfig with default values
    """
    default_path = Path(__file__).parent.parent.parent.parent / "config" / "default.yaml"
    if default_path.exists():
        return load_validation_config(default_path)
    return ValidationConfig()


# =============================================================================
# Validation
# =============================================================================

def validate_config(config: RandomizerConfig) -> List[str]:
    """Validate configuration for consistency.

    Args:
        config: Configuration to validate

    Returns:
        List of validation error messages (empty if valid)
    """
    errors = []

    # Check chapters
    for ch in config.general.chapters:
        if ch not in range(1, 6):
            errors.append(f"Invalid chapter: {ch} (must be 1-5)")

    # Check mode
    if config.general.mode not in ("shuffle", "generate"):
        errors.append(f"Invalid mode: {config.general.mode}")

    # Check multipliers
    for mult_name, mult_val in [
        ("enemy_hp_multiplier", config.difficulty.enemy_hp_multiplier),
        ("enemy_damage_multiplier", config.difficulty.enemy_damage_multiplier),
        ("shop_price_multiplier", config.difficulty.shop_price_multiplier),
    ]:
        if mult_val < 0 or mult_val > 10:
            errors.append(f"Invalid {mult_name}: {mult_val} (must be 0-10)")

    # Check connectivity
    if config.connectivity.topology not in ("linear", "hub", "branching", "freeform"):
        errors.append(f"Invalid topology: {config.connectivity.topology}")

    return errors
