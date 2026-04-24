"""Registry storage for randomization strategies — kept separate to avoid circular imports."""
from __future__ import annotations

from typing import Any, Callable

StrategyFn = Callable[..., Any]

REGISTRY: dict[str, StrategyFn] = {}


def register(name: str, fn: StrategyFn) -> None:
    REGISTRY[name] = fn
