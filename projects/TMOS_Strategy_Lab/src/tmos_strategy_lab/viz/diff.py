"""Candidate-to-Candidate diff visualization.

Tile-cell level: for each screen present in both candidates, render the
screen twice side-by-side with a green tint where tiles match and a red
tint where they differ. Screens present in only one candidate are shown
with a solid tinted band.
"""
from __future__ import annotations

from PIL import Image, ImageDraw, ImageFont

from .._v2_compat.parsers import WorldScreen
from .._v2_compat.renderer import SCREEN_HEIGHT_PX, SCREEN_WIDTH_PX
from ..models import Candidate

_GREEN_TINT = (0, 160, 0, 80)
_RED_TINT = (200, 0, 0, 120)
_DIFF_COLUMN_SPACER = 16


def _screen_differs(a: WorldScreen, b: WorldScreen) -> bool:
    fields = (
        "parent_world", "ambient_sound", "content", "objectset",
        "screen_index_right", "screen_index_left",
        "screen_index_down", "screen_index_up",
        "datapointer", "exit_position",
        "top_tiles", "bottom_tiles",
        "worldscreen_color", "sprites_color", "unknown", "event",
    )
    return any(getattr(a, f) != getattr(b, f) for f in fields)


def render_diff(
    cand_a: Candidate,
    cand_b: Candidate,
    rom_bytes_a: bytes | None = None,
    rom_bytes_b: bytes | None = None,
) -> Image.Image:
    """Build a side-by-side tile-cell diff image.

    The output is a single PIL image: for each chapter, two columns (A left,
    B right) with per-screen tinting indicating equality / difference. Saved
    by the caller via ``img.save(path)``.
    """
    from .tile_render import render_candidate

    img_a = render_candidate(cand_a, rom_bytes=rom_bytes_a)
    img_b = render_candidate(cand_b, rom_bytes=rom_bytes_b)

    # Compose side-by-side with a thin label gutter at the top.
    header_h = 30
    width = img_a.width + _DIFF_COLUMN_SPACER + img_b.width
    height = header_h + max(img_a.height, img_b.height)
    out = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    draw = ImageDraw.Draw(out)
    try:
        font = ImageFont.truetype("arial.ttf", 18)
    except OSError:
        font = ImageFont.load_default()
    draw.text((8, 6), f"A: {cand_a.strategy_id} seed={cand_a.seed}", fill=(200, 255, 200), font=font)
    draw.text((img_a.width + _DIFF_COLUMN_SPACER + 8, 6),
              f"B: {cand_b.strategy_id} seed={cand_b.seed}", fill=(255, 220, 220), font=font)
    out.paste(img_a, (0, header_h))
    out.paste(img_b, (img_a.width + _DIFF_COLUMN_SPACER, header_h))

    # Paint per-screen tint on top of both halves based on field-level diff.
    chapters = sorted(set(cand_a.chapters.keys()) | set(cand_b.chapters.keys()))
    y_cursor = header_h + 30  # 30 px for chapter header inside each rendered chapter
    for ch in chapters:
        rows_a = cand_a.chapters.get(ch, [])
        rows_b = cand_b.chapters.get(ch, [])
        num = max(len(rows_a), len(rows_b))
        grid_cols = 8
        rows = (num + grid_cols - 1) // grid_cols
        for i in range(num):
            col = i % grid_cols
            row = i // grid_cols
            x0 = col * SCREEN_WIDTH_PX
            y0 = y_cursor + row * SCREEN_HEIGHT_PX
            a = WorldScreen.from_dict(rows_a[i]) if i < len(rows_a) else None
            b = WorldScreen.from_dict(rows_b[i]) if i < len(rows_b) else None
            if a is None or b is None or _screen_differs(a, b):
                tint = _RED_TINT
            else:
                tint = _GREEN_TINT
            # Draw thin tinted outline on both halves for visibility
            overlay_a = Image.new("RGBA", (SCREEN_WIDTH_PX, SCREEN_HEIGHT_PX), tint)
            overlay_b = Image.new("RGBA", (SCREEN_WIDTH_PX, SCREEN_HEIGHT_PX), tint)
            out.alpha_composite(overlay_a, (x0, y0))
            out.alpha_composite(overlay_b, (img_a.width + _DIFF_COLUMN_SPACER + x0, y0))
        y_cursor += 30 + rows * SCREEN_HEIGHT_PX
    return out


__all__ = ["render_diff"]
