"""Randomization strategy package.

Importing this module triggers registration of the built-in strategies.
"""

from .base import RandomizationStrategy
from .classic import ClassicStrategy
from .lab_adapter import (
    GrowAdapter,
    IdentityAdapter,
    LabAdapterStrategy,
    TileShuffleAdapter,
)
from .organic import OrganicStrategy
from .v1 import TmosRandomizerV1
from .registry import get_strategy, list_strategies, register_strategy

__all__ = [
    "ClassicStrategy",
    "GrowAdapter",
    "IdentityAdapter",
    "LabAdapterStrategy",
    "OrganicStrategy",
    "RandomizationStrategy",
    "TileShuffleAdapter",
    "TmosRandomizerV1",
    "get_strategy",
    "list_strategies",
    "register_strategy",
]
