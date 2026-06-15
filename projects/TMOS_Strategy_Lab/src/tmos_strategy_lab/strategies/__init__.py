"""Lab strategy package.

Each subpackage owns a strategy and registers it via ``@register_strategy`` at
import time. Adding a new strategy = adding a subpackage here and making sure
it's listed below.
"""
from __future__ import annotations

from . import (
    graph_mutate,  # noqa: F401 — side-effect register
    grow,  # noqa: F401 — side-effect register
    identity,  # noqa: F401 — side-effect register
    organic_port,  # noqa: F401 — side-effect register
    tileshuffle,  # noqa: F401 — side-effect register
)

__all__ = ["graph_mutate", "grow", "identity", "organic_port", "tileshuffle"]
