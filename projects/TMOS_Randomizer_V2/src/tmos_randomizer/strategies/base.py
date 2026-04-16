"""Abstract base class for randomization strategies.

A strategy owns the full randomization pipeline: planning (no ROM mutation)
and application (ROM patching + spoiler generation). Concrete strategies may
reuse phase modules from ``tmos_randomizer.phases`` à la carte or supply
entirely new logic.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from pathlib import Path
from typing import TYPE_CHECKING

from ..plan import RandomizationPlan, RandomizationResult

if TYPE_CHECKING:
    from ..core.chapter import GameWorld
    from ..io.config_loader import RandomizerConfig
    from ..validation import ValidationRunner
    from ..validation.config import ValidationConfig


class RandomizationStrategy(ABC):
    """Abstract base for randomization strategies.

    Subclasses MUST define a non-empty ``name`` class attribute and implement
    ``create_plan`` and ``apply_plan``. The ``description`` is optional and
    surfaced in UI/CLI listings.
    """

    name: str = ""
    description: str = ""

    def __init__(
        self,
        config: "RandomizerConfig",
        validation_config: "ValidationConfig",
        validation_runner: "ValidationRunner",
    ):
        self.config = config
        self.validation_config = validation_config
        self.validation_runner = validation_runner

    @abstractmethod
    def create_plan(self, seed: int) -> RandomizationPlan:
        """Build a RandomizationPlan without modifying any ROM.

        Args:
            seed: Resolved seed (caller guarantees a non-zero int).
        """

    @abstractmethod
    def apply_plan(
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        """Apply a plan to a ROM and produce a RandomizationResult."""

    def preview_plan(
        self,
        plan: RandomizationPlan,
        game_world: "GameWorld",
        rom_data: bytes,
    ) -> None:
        """Apply this strategy's randomization to ``game_world`` in place.

        Unlike ``apply_plan``, this does no disk I/O. The caller already owns
        a loaded GameWorld (typically the server's in-memory copy) and the
        raw ROM bytes. The strategy should mutate ``game_world`` so the UI
        sees the randomized layout, and populate ``plan.world_population`` /
        ``plan.world_navigation`` so the section-map endpoint has data.

        Default implementation raises — subclasses opt in by overriding.
        """
        raise NotImplementedError(
            f"Strategy '{self.name}' does not support in-memory preview."
        )
