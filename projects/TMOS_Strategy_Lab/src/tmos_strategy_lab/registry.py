"""LabStrategy registry.

Lab's strategy interface is intentionally thinner than V2's — one method,
one context in, one Candidate out. Strategies register at module-import time
via the ``@register_strategy`` decorator; discovery is a dict lookup.
"""
from __future__ import annotations

from typing import Protocol, runtime_checkable

from .context import LabContext
from .models import Candidate


@runtime_checkable
class LabStrategy(Protocol):
    name: str
    description: str

    def generate(self, ctx: LabContext, seed: int) -> Candidate:
        ...


_REGISTRY: dict[str, type] = {}


def register_strategy(cls: type) -> type:
    """Register a strategy class. Raises on empty / duplicate names."""
    name = getattr(cls, "name", "")
    if not name:
        raise ValueError(
            f"Strategy class {cls.__name__} must define a non-empty class attribute 'name'."
        )
    if name in _REGISTRY:
        raise ValueError(
            f"Strategy name collision: '{name}' already registered by "
            f"{_REGISTRY[name].__name__}; refusing to overwrite with {cls.__name__}."
        )
    _REGISTRY[name] = cls
    return cls


def get_strategy(name: str) -> type:
    if name not in _REGISTRY:
        available = ", ".join(sorted(_REGISTRY.keys())) or "<none>"
        raise KeyError(f"Unknown strategy '{name}'. Available: {available}")
    return _REGISTRY[name]


def list_strategies() -> list[str]:
    return sorted(_REGISTRY.keys())


__all__ = ["LabStrategy", "register_strategy", "get_strategy", "list_strategies"]
