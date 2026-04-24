"""Identity strategy — returns world unchanged.

Baseline control: proves the batch pipeline end-to-end and guarantees zero
validation deltas vs pristine (a hard gate in PRPs/v1).
"""
from __future__ import annotations

import random
from dataclasses import dataclass
from typing import Any

from components.randomization_lab.strategies._registry import register


@dataclass(frozen=True)
class StrategyMeta:
    name: str
    version: str
    default_seed: int


def identity_strategy(world: Any, seed: int = 0) -> Any:
    """Return world unchanged. Seed is accepted but irrelevant (no randomness)."""
    # Seeded INSIDE the callable, not at module import (CLAUDE.md gotcha).
    random.seed(seed)
    return world


identity_strategy.meta = StrategyMeta(name="identity", version="1.0", default_seed=0)

register("identity", identity_strategy)
