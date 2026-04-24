"""V2 screen renderer re-exports with PIL fallback flag.

The Lab's tile_render primitive delegates to V2's compositor when available
(it has the full tile atlas + ROM CHR-bank logic). When V2 is unreachable or
Pillow import fails, the flag flips and tile_render falls back to a pure-PIL
sprite-paste path.
"""
from __future__ import annotations

from . import V2_AVAILABLE

try:
    if V2_AVAILABLE:
        from tmos_randomizer.rendering.screen_renderer import (  # type: ignore[import-untyped]
            SCREEN_HEIGHT_PX,
            SCREEN_HEIGHT_TILES,
            SCREEN_WIDTH_PX,
            SCREEN_WIDTH_TILES,
            TILE_PIXEL_SIZE,
            ScreenRenderer,
        )

        V2_RENDERER_AVAILABLE = True
    else:
        raise ImportError("V2 sibling not available")
except Exception:  # noqa: BLE001
    V2_RENDERER_AVAILABLE = False
    TILE_PIXEL_SIZE = 64
    SCREEN_WIDTH_TILES = 8
    SCREEN_HEIGHT_TILES = 6
    SCREEN_WIDTH_PX = SCREEN_WIDTH_TILES * TILE_PIXEL_SIZE
    SCREEN_HEIGHT_PX = SCREEN_HEIGHT_TILES * TILE_PIXEL_SIZE
    ScreenRenderer = None  # type: ignore[assignment]


__all__ = [
    "SCREEN_HEIGHT_PX",
    "SCREEN_HEIGHT_TILES",
    "SCREEN_WIDTH_PX",
    "SCREEN_WIDTH_TILES",
    "TILE_PIXEL_SIZE",
    "ScreenRenderer",
    "V2_RENDERER_AVAILABLE",
]
