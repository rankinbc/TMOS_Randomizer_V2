"""Shared screen-edge extraction with a loud failure path.

Replaces three identical `_cached_edges` copies (navigation/placement/repair)
whose bare `except Exception: return None` silently turned any extraction
failure into a permanent phantom wall: a None edge reads as "not walkably
aligned", so both nav directions get NAV_BLOCKED and repair counts the pair
as broken forever.
"""

from __future__ import annotations

import logging
from typing import Dict, Optional

from ...core.worldscreen import WorldScreen
from ...validation.tiles.edges import ScreenEdges, extract_edges

logger = logging.getLogger(__name__)

# Screens already warned about this run — one log line per screen, not per
# lookup (the caches are per-call-site, so a failing screen is retried a lot).
_warned: set = set()


def cached_edges(
    screen: WorldScreen,
    rom_data: bytes,
    cache: Dict[int, ScreenEdges],
) -> Optional[ScreenEdges]:
    """Extract (and cache) a screen's edge tiles.

    Returns None only when extraction genuinely fails — and says so in the
    log with enough detail to reproduce, because a None here becomes a
    NAV_BLOCKED wall downstream.
    """
    cached = cache.get(screen.relative_index)
    if cached is not None:
        return cached
    try:
        edges = extract_edges(
            rom_data,
            screen.relative_index,
            screen.top_tiles,
            screen.bottom_tiles,
            screen.datapointer,
        )
    except Exception:
        key = (screen.chapter, screen.relative_index)
        if key not in _warned:
            _warned.add(key)
            logger.warning(
                "edge extraction failed for ch%s screen 0x%02X "
                "(top_tiles=0x%02X bottom_tiles=0x%02X datapointer=0x%02X) — "
                "this screen will read as fully blocked",
                screen.chapter,
                screen.relative_index,
                screen.top_tiles,
                screen.bottom_tiles,
                screen.datapointer,
                exc_info=True,
            )
        return None
    cache[screen.relative_index] = edges
    return edges
