"""Randomization strategy package.

Importing this module triggers registration of the built-in strategies.
"""

from .base import RandomizationStrategy
from .classic import ClassicStrategy
from .lab_adapter import IdentityAdapter, LabAdapterStrategy, TileShuffleAdapter
from .organic import OrganicStrategy
from .registry import get_strategy, list_strategies, register_strategy

__all__ = [
    "ClassicStrategy",
    "IdentityAdapter",
    "LabAdapterStrategy",
    "OrganicStrategy",
    "RandomizationStrategy",
    "TileShuffleAdapter",
    "get_strategy",
    "list_strategies",
    "register_strategy",
]
