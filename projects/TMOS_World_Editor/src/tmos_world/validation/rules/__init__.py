"""Validation rule registry (see world-editor-spec §10).

Individual rule modules call ``register(...)`` when imported. The
``_registry`` submodule owns the dict to keep import cycles broken.
"""
from __future__ import annotations

from src.tmos_world.validation.rules._registry import REGISTRY, RuleFn, register

# Import rule modules so their register(...) calls execute.
from src.tmos_world.validation.rules import (  # noqa: E402, F401
    edge_compat,
    nav_bytes,
    reachability,
    sections,
    stairways,
    time_doors,
)

__all__ = ["REGISTRY", "RuleFn", "register"]
