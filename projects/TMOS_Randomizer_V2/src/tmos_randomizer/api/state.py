"""Canonical mutable application state for the TMOS Randomizer API.

Every piece of cross-endpoint mutable state lives here as a module attribute.

CRITICAL usage rule: readers and writers must use attribute access on this
module (``from . import state`` then ``state._rom_data``), NEVER
``from .state import _rom_data`` — a from-import copies the binding and
silently stops observing later assignments.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, Optional

# Import rendering module (optional - gracefully handle if PIL not installed)
try:
    from ..rendering import ScreenRenderer
    from ..rendering.screen_renderer import build_screen_tile_grid
    RENDERING_AVAILABLE = True
except ImportError:
    ScreenRenderer = None
    build_screen_tile_grid = None
    RENDERING_AVAILABLE = False


# Global state
_current_plan: Optional[Any] = None  # RandomizationPlan
_randomizer: Optional[Any] = None  # Randomizer
_game_world: Optional[Any] = None  # GameWorld
_rom_path: Optional[Path] = None
_rom_filename: Optional[str] = None
_rom_data: Optional[bytes] = None  # Raw ROM bytes for rendering (mutated by edits)
_rom_vanilla: Optional[bytes] = None  # Snapshot of ROM as uploaded (never mutated)
_screen_renderer: Optional[Any] = None  # ScreenRenderer instance

# Cache for the per-section walkability table (pure function of the loaded ROM).
_ts_walk_cache: dict | None = None
_ts_walk_cache_key: int | None = None

# Cache for the per-section theme table (pure function of the loaded ROM).
_ts_theme_cache: dict | None = None
_ts_theme_cache_key: int | None = None

# ── Async apply-preview job registry ───────────────────────────────────────
# apply-preview is CPU-bound and can run for minutes on small cloud tiers,
# where a single synchronous request looks hung and risks gateway timeouts.
# The async endpoint runs the same work in a background thread and exposes a
# pollable status, so the request returns immediately and never times out.
# Single-process, in-memory; this is a single-user editing tool.
_preview_jobs: Dict[str, Dict[str, Any]] = {}
_PREVIEW_JOBS_MAX = 12

# Per-chapter warp-aware reachability of the pristine ROM, keyed by ROM path.
_baseline_reach_cache: tuple = (None, {})

# Asset paths (will be configured at startup)
ASSET_PATHS: Dict[str, Path] = {}
