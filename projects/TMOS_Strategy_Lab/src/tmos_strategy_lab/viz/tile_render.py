"""Tile-art rendering for Candidate maps.

Uses V2's ``ScreenRenderer`` when both V2 and its sprite atlas are available
(preferred — it has the full CHR-bank + fallback logic). Otherwise falls
back to a pure-PIL per-tile compositor that loads individual tile PNGs
from a staged atlas directory.

Gotcha: all tile images are ``.convert("RGBA")`` at load time. Palette-mode
sources produce silently-wrong colors when used as ``paste()`` masks — Pillow
10+ tightened this, Pillow 11 is stricter still.
"""
from __future__ import annotations

import logging
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from .._v2_compat.parsers import WorldScreen
from .._v2_compat.renderer import (
    SCREEN_HEIGHT_PX,
    SCREEN_WIDTH_PX,
    TILE_PIXEL_SIZE,
    V2_RENDERER_AVAILABLE,
    ScreenRenderer,
)
from ..models import Candidate

_log = logging.getLogger(__name__)


def _default_atlas_dir() -> Path:
    """Locate the V2 sprite atlas (sibling project)."""
    here = Path(__file__).resolve()
    # src/tmos_strategy_lab/viz/tile_render.py
    # parents[4] = projects/
    cand = here.parents[4] / "TMOS_Randomizer_V2" / "ui" / "public" / "tiles"
    return cand


class _TileCache:
    """Tiny palette-safe tile cache for the PIL fallback path."""

    def __init__(self, atlas_dir: Path):
        self.atlas_dir = atlas_dir
        self._cache: dict[int, Image.Image] = {}

    def get(self, tile_id: int) -> Image.Image:
        if tile_id in self._cache:
            return self._cache[tile_id]
        path = self.atlas_dir / f"{tile_id:02X}.png"
        if path.exists():
            img = Image.open(path).convert("RGBA")  # GOTCHA: palette-mode → wrong colors
        else:
            # Deterministic fallback tile — a solid color derived from the id.
            r = (tile_id * 37) % 256
            g = (tile_id * 73) % 256
            b = (tile_id * 113) % 256
            img = Image.new("RGBA", (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), (r, g, b, 255))
        if img.size != (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE):
            img = img.resize((TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), Image.NEAREST)
        self._cache[tile_id] = img
        return img


def _render_screen_fallback(
    top_tiles: int,
    bottom_tiles: int,
    _datapointer: int,
    cache: _TileCache,
) -> Image.Image:
    """Pure-PIL fallback that paints a flat colored square per 'tile slot'.

    Without ROM-side TileSection parsing we can't reconstruct the real 8×6
    grid — the fallback paints the top_tiles / bottom_tiles IDs as banded
    color blocks so differences between candidates are still visible when V2
    is unreachable. Runnable tile rendering requires V2.
    """
    img = Image.new("RGBA", (SCREEN_WIDTH_PX, SCREEN_HEIGHT_PX), (40, 40, 40, 255))
    # top 4 rows
    top_tile = cache.get(top_tiles)
    for row in range(4):
        for col in range(8):
            img.paste(top_tile, (col * TILE_PIXEL_SIZE, row * TILE_PIXEL_SIZE), top_tile)
    # bottom 2 rows
    bot_tile = cache.get(bottom_tiles)
    for row in range(4, 6):
        for col in range(8):
            img.paste(bot_tile, (col * TILE_PIXEL_SIZE, row * TILE_PIXEL_SIZE), bot_tile)
    return img


def render_candidate(
    candidate: Candidate,
    rom_bytes: bytes | None = None,
    atlas_dir: Path | None = None,
    scale: int = 1,
) -> Image.Image:
    """Render a Candidate as a per-chapter tile-art grid.

    Uses V2's ScreenRenderer (requires ``rom_bytes``) when available; otherwise
    the PIL fallback (coarse, but still produces a PNG). The returned image is
    saved by the caller via ``img.save(path)`` for 1:1 pixel-accurate output —
    do not pass it through matplotlib's savefig.
    """
    atlas_dir = atlas_dir or _default_atlas_dir()
    cache = _TileCache(atlas_dir)

    v2_renderer = None
    if V2_RENDERER_AVAILABLE and rom_bytes is not None and ScreenRenderer is not None:
        try:
            v2_renderer = ScreenRenderer(rom_data=rom_bytes, tile_images_path=str(atlas_dir))
        except Exception as exc:  # noqa: BLE001
            _log.warning("V2 ScreenRenderer init failed, using PIL fallback: %s", exc)

    # Layout: per chapter, lay screens out in a grid by relative index (8 wide).
    grid_cols = 8
    rows_per_chapter: dict[int, int] = {}
    chapter_images: dict[int, Image.Image] = {}
    label_font: ImageFont.ImageFont | ImageFont.FreeTypeFont
    try:
        label_font = ImageFont.truetype("arial.ttf", 20 * scale)
    except OSError:
        label_font = ImageFont.load_default()

    total_height = 0
    max_width = 0

    for ch_num in sorted(candidate.chapters.keys()):
        screens_raw = candidate.chapters[ch_num]
        num = len(screens_raw)
        rows = (num + grid_cols - 1) // grid_cols
        rows_per_chapter[ch_num] = rows

        ch_width = grid_cols * SCREEN_WIDTH_PX * scale
        ch_header = 30 * scale
        ch_height = ch_header + rows * SCREEN_HEIGHT_PX * scale
        img = Image.new("RGBA", (ch_width, ch_height), (20, 20, 20, 255))
        draw = ImageDraw.Draw(img)
        draw.text((8 * scale, 4 * scale), f"Chapter {ch_num}  ({num} screens)", fill=(240, 240, 240, 255), font=label_font)

        for i, srow in enumerate(screens_raw):
            screen = WorldScreen.from_dict(srow)
            col = i % grid_cols
            row = i // grid_cols
            x = col * SCREEN_WIDTH_PX * scale
            y = ch_header + row * SCREEN_HEIGHT_PX * scale
            if v2_renderer is not None:
                try:
                    tile = v2_renderer.render_screen(
                        top_tiles=screen.top_tiles,
                        bottom_tiles=screen.bottom_tiles,
                        datapointer=screen.datapointer,
                        scale=scale,
                        ws_color=screen.worldscreen_color,
                    ).convert("RGBA")
                except Exception as exc:  # noqa: BLE001
                    _log.warning(
                        "V2 render_screen failed for ch%d idx%d: %s — falling back.",
                        ch_num, screen.relative_index, exc,
                    )
                    tile = _render_screen_fallback(screen.top_tiles, screen.bottom_tiles,
                                                   screen.datapointer, cache)
                    if scale != 1:
                        tile = tile.resize(
                            (SCREEN_WIDTH_PX * scale, SCREEN_HEIGHT_PX * scale),
                            Image.NEAREST,
                        )
            else:
                tile = _render_screen_fallback(screen.top_tiles, screen.bottom_tiles,
                                               screen.datapointer, cache)
                if scale != 1:
                    tile = tile.resize(
                        (SCREEN_WIDTH_PX * scale, SCREEN_HEIGHT_PX * scale),
                        Image.NEAREST,
                    )
            img.paste(tile, (x, y))

        chapter_images[ch_num] = img
        max_width = max(max_width, ch_width)
        total_height += ch_height

    # Stack vertically with a separator.
    combined = Image.new("RGBA", (max_width, total_height), (0, 0, 0, 255))
    cursor_y = 0
    for ch_num in sorted(chapter_images.keys()):
        img = chapter_images[ch_num]
        combined.paste(img, (0, cursor_y))
        cursor_y += img.height

    return combined


__all__ = ["render_candidate"]
