"""Chapter- and world-level PIL composites."""
from __future__ import annotations

from typing import Iterable

from PIL import Image

from src.tmos_world.analysis.tiles import screen_tile_grid
from src.tmos_world.model import Chapter, World, WorldScreen
from src.tmos_world.rendering.tile_palette import TILE_PIXEL_SIZE, get_tile_image

# Default thumb tile dimensions for chapter-overview composites. 8×6 tiles per
# screen × 8 px tile = 64×48 px per screen thumbnail.
THUMB_TILE_PX = 8

# Full-resolution per-screen dimensions (for the edit view).
SCREEN_FULL_W = 8 * TILE_PIXEL_SIZE  # 512 px
SCREEN_FULL_H = 6 * TILE_PIXEL_SIZE  # 384 px

# Default grid shapes per chapter (columns wide). Simple row-major layout —
# works fine for an overview thumbnail; actual nav topology is displayed via
# overlays (nav arrows).
CHAPTER_GRID_SHAPES: dict[int, int] = {
    1: 16,
    2: 16,
    3: 16,
    4: 16,
    5: 16,
}


def render_screen(
    world: World,
    screen: WorldScreen,
    *,
    tile_px: int = TILE_PIXEL_SIZE,
) -> Image.Image:
    """Render a single screen's 8×6 tile grid to a PIL image (8*tile_px × 6*tile_px)."""
    grid = screen_tile_grid(world, screen)
    w = 8 * tile_px
    h = 6 * tile_px
    out = Image.new("RGB", (w, h), (0, 0, 0))
    for row_idx, row in enumerate(grid):
        for col_idx, tile_id in enumerate(row):
            tile_img = get_tile_image(tile_id)
            if tile_px != TILE_PIXEL_SIZE:
                tile_img = tile_img.resize((tile_px, tile_px), Image.NEAREST)
            out.paste(tile_img, (col_idx * tile_px, row_idx * tile_px))
    return out


def _chapter_grid_layout(chapter: Chapter, cols: int) -> dict[int, tuple[int, int]]:
    """Return screen_index -> (col, row) for a simple row-major layout."""
    return {i: (i % cols, i // cols) for i in range(chapter.screen_count)}


def render_chapter_map(
    world: World,
    chapter_idx: int,
    overlays: Iterable[str] | None = None,
    *,
    tile_px: int = THUMB_TILE_PX,
    cols: int | None = None,
) -> Image.Image:
    """Render a chapter navigation map.

    Args:
        world: parsed world.
        chapter_idx: 0-based chapter index (0..4).
        overlays: set of overlay keys — any of
            ``{"collision_edges", "nav_arrows", "content_bytes", "section_outlines"}``.
        tile_px: per-tile pixel size (default small for overview).
        cols: number of columns for the grid layout (defaults to CHAPTER_GRID_SHAPES).

    Returns a PIL.Image.
    """
    chapter = world.chapters[chapter_idx]
    cols = cols or CHAPTER_GRID_SHAPES.get(chapter.number, 16)
    rows = (chapter.screen_count + cols - 1) // cols
    screen_w = 8 * tile_px
    screen_h = 6 * tile_px
    canvas = Image.new("RGB", (cols * screen_w, rows * screen_h), (0, 0, 0))

    layout = _chapter_grid_layout(chapter, cols)
    for screen_idx, (c, r) in layout.items():
        screen = chapter.screens[screen_idx]
        tile_img = render_screen(world, screen, tile_px=tile_px)
        canvas.paste(tile_img, (c * screen_w, r * screen_h))

    overlays_set = set(overlays or ())
    if overlays_set:
        # Lazy import to avoid a circular between rendering.compose and
        # rendering.overlays when overlays eventually import compose helpers.
        from src.tmos_world.rendering.overlays import apply_overlays

        canvas = apply_overlays(canvas, world, chapter_idx, overlays_set, layout, tile_px)
    return canvas


def render_world_overview(world: World, *, tile_px: int = THUMB_TILE_PX) -> Image.Image:
    """Stack all 5 chapter maps vertically into a single PIL image."""
    per_chapter = [render_chapter_map(world, i, overlays=None, tile_px=tile_px) for i in range(len(world.chapters))]
    max_w = max(img.width for img in per_chapter)
    total_h = sum(img.height for img in per_chapter)
    canvas = Image.new("RGB", (max_w, total_h), (0, 0, 0))
    y = 0
    for img in per_chapter:
        canvas.paste(img, (0, y))
        y += img.height
        img.close()
    return canvas
