"""Strategy registry for randomization_lab.

Usage:
    from components.randomization_lab.strategies import REGISTRY, register

The registry is a plain dict; each built-in strategy module calls
``register(...)`` at import time — explicit, not decorator-based.
"""
from __future__ import annotations

from components.randomization_lab.strategies._registry import REGISTRY, StrategyFn, register

# Import built-in strategies so they self-register.
from components.randomization_lab.strategies import identity  # noqa: E402, F401

__all__ = ["REGISTRY", "StrategyFn", "register"]
