"""TMOS Strategy Lab — research sandbox for map-randomization strategies.

Public surface is deliberately small:

- ``LabContext`` wraps a parsed ROM (or snapshot) and hands it to strategies.
- ``Candidate`` is the in-memory output of a strategy (not a ROM).
- ``ValidationReport`` is what the harness emits after running metrics.
- ``register_strategy`` decorates a LabStrategy class so the harness can
  discover it by name.

See ``src/README.md`` for how to add a new strategy in < 30 min.
"""
from __future__ import annotations

__version__ = "0.1.0"

# Import strategies submodule for registration side-effects (registers
# ``identity`` and ``organic_port`` in the global registry).
from . import strategies as _strategies  # noqa: F401 — imported for side effects
from .context import LabContext
from .models import (
    Candidate,
    MetricResult,
    MetricStatus,
    RepairRecord,
    ValidationReport,
)
from .registry import (
    LabStrategy,
    get_strategy,
    list_strategies,
    register_strategy,
)

__all__ = [
    "__version__",
    "LabContext",
    "Candidate",
    "MetricResult",
    "MetricStatus",
    "RepairRecord",
    "ValidationReport",
    "LabStrategy",
    "get_strategy",
    "list_strategies",
    "register_strategy",
]
