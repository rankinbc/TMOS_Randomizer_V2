"""Main randomizer orchestrator.

Thin dispatcher around a pluggable ``RandomizationStrategy``. The strategy
(selected by ``config.general.strategy`` or passed explicitly) owns the
actual pipeline — planning, ROM patching, spoiler generation.
"""

from __future__ import annotations

import random
from pathlib import Path
from typing import Optional, Type, Union

from .io.config_loader import RandomizerConfig, get_default_config, load_config
from .plan import RandomizationPlan, RandomizationResult
from .strategies import RandomizationStrategy, get_strategy
from .validation import ValidationConfig, ValidationRunner

__all__ = [
    "RandomizationPlan",
    "RandomizationResult",
    "Randomizer",
    "randomize",
    "preview_randomization",
]


# =============================================================================
# Main Randomizer Class
# =============================================================================

class Randomizer:
    """Main randomizer orchestrator.

    Usage:
        randomizer = Randomizer(config)
        plan = randomizer.create_plan(seed=12345)

        # UI can display plan.to_dict() here

        if plan.is_valid:
            result = randomizer.apply(input_rom, output_rom, plan)
    """

    def __init__(
        self,
        config: Optional[RandomizerConfig] = None,
        validation_config: Optional[ValidationConfig] = None,
        strategy: Optional[Union[str, Type[RandomizationStrategy], RandomizationStrategy]] = None,
    ):
        """Initialize randomizer.

        Args:
            config: Randomization configuration (uses defaults if None).
            validation_config: Validation configuration (uses defaults if None).
            strategy: Override the strategy. Accepts a registered name, a
                ``RandomizationStrategy`` subclass, or an already-instantiated
                strategy. When ``None`` the strategy is looked up by
                ``config.general.strategy``.
        """
        self.config = config or get_default_config()
        self.validation_config = validation_config or ValidationConfig()
        self._validation_runner: Optional[ValidationRunner] = None
        self._strategy = self._resolve_strategy(strategy)

    @property
    def validation_runner(self) -> ValidationRunner:
        """Get the validation runner, creating it if needed."""
        if self._validation_runner is None:
            self._validation_runner = ValidationRunner(self.validation_config)
        return self._validation_runner

    @property
    def strategy(self) -> RandomizationStrategy:
        """Active strategy instance."""
        return self._strategy

    @classmethod
    def from_config_file(cls, config_path: Union[str, Path]) -> "Randomizer":
        """Create randomizer from config file."""
        return cls(load_config(config_path))

    def create_plan(self, seed: Optional[int] = None) -> RandomizationPlan:
        """Create a randomization plan without modifying any ROM."""
        actual_seed = seed if seed and seed != 0 else random.randint(1, 2**31 - 1)
        return self._strategy.create_plan(actual_seed)

    def apply(
        self,
        input_rom: Union[str, Path],
        output_rom: Union[str, Path],
        plan: RandomizationPlan,
        generate_spoiler: bool = True,
    ) -> RandomizationResult:
        """Apply a randomization plan to a ROM."""
        return self._strategy.apply_plan(
            Path(input_rom),
            Path(output_rom),
            plan,
            generate_spoiler,
        )

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    def _resolve_strategy(
        self,
        override: Optional[Union[str, Type[RandomizationStrategy], RandomizationStrategy]],
    ) -> RandomizationStrategy:
        if isinstance(override, RandomizationStrategy):
            return override

        if isinstance(override, type) and issubclass(override, RandomizationStrategy):
            cls = override
        elif isinstance(override, str):
            cls = get_strategy(override)
        else:
            name = getattr(self.config.general, "strategy", "classic") or "classic"
            cls = get_strategy(name)

        return cls(self.config, self.validation_config, self.validation_runner)


# =============================================================================
# Convenience Functions
# =============================================================================

def randomize(
    input_rom: Union[str, Path],
    output_rom: Union[str, Path],
    config: Optional[Union[RandomizerConfig, str, Path]] = None,
    seed: Optional[int] = None,
) -> RandomizationResult:
    """Convenience function to randomize a ROM in one call."""
    if config is None:
        cfg = get_default_config()
    elif isinstance(config, (str, Path)):
        cfg = load_config(config)
    else:
        cfg = config

    randomizer = Randomizer(cfg)
    plan = randomizer.create_plan(seed)
    return randomizer.apply(input_rom, output_rom, plan)


def preview_randomization(
    config: Optional[Union[RandomizerConfig, str, Path]] = None,
    seed: Optional[int] = None,
) -> RandomizationPlan:
    """Preview what randomization would do without modifying any ROM."""
    if config is None:
        cfg = get_default_config()
    elif isinstance(config, (str, Path)):
        cfg = load_config(config)
    else:
        cfg = config

    randomizer = Randomizer(cfg)
    return randomizer.create_plan(seed)
