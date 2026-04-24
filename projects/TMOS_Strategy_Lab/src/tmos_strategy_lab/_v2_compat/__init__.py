"""Path-import adapter for the V2 sibling (TMOS_Randomizer_V2).

Rules:
- Import-time sys.path mutation only (function-scope inserts don't work:
  Python caches module lookups at first import).
- No copy-paste of V2 code — every V2 consumer goes through the submodules
  here so a V2 refactor only requires updating the adapter.
- Missing V2 is degraded, not fatal: ``V2_AVAILABLE`` flag lets callers
  branch. Metrics that strictly require V2 tile pathfinding will report
  informational-only results when V2 is absent.
"""
from __future__ import annotations

import logging
import pathlib
import sys

_log = logging.getLogger(__name__)


def _resolve_v2_src() -> pathlib.Path | None:
    """Locate the V2 source tree. Sibling to this Lab project under projects/."""
    here = pathlib.Path(__file__).resolve()
    # __file__ => .../TMOS_Strategy_Lab/src/tmos_strategy_lab/_v2_compat/__init__.py
    # parents[4] => .../TMOS_AI/projects/
    candidates = [
        here.parents[4] / "TMOS_Randomizer_V2" / "src",
        # Fallback: relative to project root when Lab lives at a different depth
        here.parents[3] / ".." / "TMOS_Randomizer_V2" / "src",
    ]
    for c in candidates:
        c = c.resolve()
        if (c / "tmos_randomizer" / "__init__.py").exists():
            return c
    return None


_V2_SRC = _resolve_v2_src()
if _V2_SRC is not None and str(_V2_SRC) not in sys.path:
    sys.path.insert(0, str(_V2_SRC))

V2_AVAILABLE: bool = False
try:
    import tmos_randomizer  # noqa: F401

    V2_AVAILABLE = True
except Exception as exc:  # noqa: BLE001 — we genuinely want any import failure to be degraded
    _log.warning(
        "V2 sibling unavailable at %s: %s — metrics that use V2 tile pathfinding "
        "will report degraded results.",
        _V2_SRC,
        exc,
    )


__all__ = ["V2_AVAILABLE", "_V2_SRC"]
