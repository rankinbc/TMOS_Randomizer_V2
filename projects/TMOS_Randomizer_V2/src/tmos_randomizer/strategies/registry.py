"""Registry for randomization strategies.

Strategies self-register via ``register_strategy`` (typically as a class
decorator). Consumers look them up by name via ``get_strategy`` or discover
available options via ``list_strategies``.
"""

from __future__ import annotations

from typing import Dict, List, Type

from .base import RandomizationStrategy

_REGISTRY: Dict[str, Type[RandomizationStrategy]] = {}


def register_strategy(cls: Type[RandomizationStrategy]) -> Type[RandomizationStrategy]:
    """Register a strategy class under its ``name`` attribute.

    Usable as a decorator. Raises if ``name`` is empty or already taken —
    silent overwrites would make debugging an unexpected strategy choice
    painful.
    """
    if not cls.name:
        raise ValueError(f"Strategy {cls.__name__} must define a non-empty `name`")
    if cls.name in _REGISTRY and _REGISTRY[cls.name] is not cls:
        raise ValueError(
            f"Strategy name '{cls.name}' already registered to "
            f"{_REGISTRY[cls.name].__name__}"
        )
    _REGISTRY[cls.name] = cls
    return cls


def get_strategy(name: str) -> Type[RandomizationStrategy]:
    """Look up a registered strategy class by name."""
    if name not in _REGISTRY:
        available = ", ".join(sorted(_REGISTRY)) or "<none>"
        raise KeyError(f"Unknown strategy '{name}'. Available: {available}")
    return _REGISTRY[name]


def list_strategies() -> List[str]:
    """Return registered strategy names in sorted order."""
    return sorted(_REGISTRY)
