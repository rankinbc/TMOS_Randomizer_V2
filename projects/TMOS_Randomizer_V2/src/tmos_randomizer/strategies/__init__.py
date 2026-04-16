"""Randomization strategy package.

Importing this module triggers registration of the built-in strategies.
"""

from .base import RandomizationStrategy
from .classic import ClassicStrategy
from .organic import OrganicStrategy
from .registry import get_strategy, list_strategies, register_strategy

__all__ = [
    "ClassicStrategy",
    "OrganicStrategy",
    "RandomizationStrategy",
    "get_strategy",
    "list_strategies",
    "register_strategy",
]
