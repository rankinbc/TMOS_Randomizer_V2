"""V1 randomizer ported as a V2 strategy. See
docs/superpowers/specs/2026-06-24-tmos-randomizer-v1-strategy-design.md.
"""
from __future__ import annotations

from pathlib import Path

from ..base import RandomizationStrategy
from ..registry import register_strategy
from ...plan import RandomizationPlan, RandomizationResult


@register_strategy
class TmosRandomizerV1(RandomizationStrategy):
    name = "tmos_randomizer_v1"
    description = (
        "Original V1 randomizer: content / object-set / encounter shuffle with "
        "brute-force validity gates. Reliable playable baseline."
    )

    def create_plan(self, seed: int) -> RandomizationPlan:  # pragma: no cover - Task 9
        raise NotImplementedError

    def apply_plan(  # pragma: no cover - Task 9
        self,
        input_rom: Path,
        output_rom: Path,
        plan: RandomizationPlan,
        generate_spoiler: bool,
    ) -> RandomizationResult:
        raise NotImplementedError
