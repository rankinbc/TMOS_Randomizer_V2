"""Regression: sprite atlas must be converted to RGBA at load.

Palette-mode ("P") PNGs passed as ``paste(mask=…)`` silently produce wrong
colors in Pillow 10+. The Lab atlas loader is expected to call ``.convert("RGBA")``
so cached tiles always have an alpha channel regardless of source mode.
"""
from __future__ import annotations


from PIL import Image

from tmos_strategy_lab.viz.tile_render import _TileCache


def test_palette_mode_source_gets_converted_to_rgba(tmp_path):
    # Build a fake "atlas" directory with a palette-mode PNG (mode "P").
    atlas = tmp_path / "atlas"
    atlas.mkdir()
    # Make a P-mode image; the exact palette doesn't matter — we just want to
    # assert the loader promoted the mode.
    palette_img = Image.new("P", (64, 64), color=3)
    palette_img.save(atlas / "2A.png")
    assert Image.open(atlas / "2A.png").mode == "P", "test fixture must be palette-mode"

    cache = _TileCache(atlas)
    loaded = cache.get(0x2A)
    assert loaded.mode == "RGBA", (
        "tile cache must promote palette-mode sources to RGBA — otherwise "
        "PIL.Image.paste(mask=tile) silently picks up palette indices as luminance."
    )


def test_missing_tile_falls_back_to_solid_rgba(tmp_path):
    atlas = tmp_path / "atlas"
    atlas.mkdir()
    cache = _TileCache(atlas)
    fallback = cache.get(0xFF)
    assert fallback.mode == "RGBA"
    assert fallback.size == (64, 64)
