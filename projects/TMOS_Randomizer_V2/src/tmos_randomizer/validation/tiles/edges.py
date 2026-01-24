"""Edge extraction from TileSections for compatibility validation.

This module provides utilities to extract edge tiles from screens
for edge compatibility checking.

Screen Layout (8 tiles wide × 6 tiles tall):
    Row 0: [T0] [T1] [T2] [T3] [T4] [T5] [T6] [T7]  ← Top TileSection row 0
    Row 1: [T0] [T1] [T2] [T3] [T4] [T5] [T6] [T7]  ← Top TileSection row 1
    Row 2: [T0] [T1] [T2] [T3] [T4] [T5] [T6] [T7]  ← Top TileSection row 2
    Row 3: [T0] [T1] [T2] [T3] [T4] [T5] [T6] [T7]  ← Top TileSection row 3
    Row 4: [B0] [B1] [B2] [B3] [B4] [B5] [B6] [B7]  ← Bottom TileSection row 0
    Row 5: [B0] [B1] [B2] [B3] [B4] [B5] [B6] [B7]  ← Bottom TileSection row 1

Edge Sizes:
    - Left/Right edges: 6 tiles (column 0 or 7, rows 0-5)
    - Top/Bottom edges: 8 tiles (row 0 or 5, columns 0-7)
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Tuple, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from ...core.worldscreen import WorldScreen

# Constants from screen_renderer.py
TILESECTION_BASE = 0x03C4C7
TILESECTION_OFFSET = 32  # Each TileSection is 32 bytes


@dataclass
class ScreenEdges:
    """Edge tiles for a screen.

    Attributes:
        screen_index: The screen this edge data belongs to
        top: 8 tiles (row 0, columns 0-7)
        bottom: 8 tiles (row 5, columns 0-7)
        left: 6 tiles (column 0, rows 0-5)
        right: 6 tiles (column 7, rows 0-5)
    """

    screen_index: int
    top: List[int]      # 8 tiles (row 0)
    bottom: List[int]   # 8 tiles (row 5)
    left: List[int]     # 6 tiles (column 0)
    right: List[int]    # 6 tiles (column 7)

    def get_edge(self, direction: str) -> List[int]:
        """Get edge tiles for a direction.

        Args:
            direction: One of "up", "down", "left", "right"

        Returns:
            List of tile IDs for that edge
        """
        if direction == "up":
            return self.top
        elif direction == "down":
            return self.bottom
        elif direction == "left":
            return self.left
        elif direction == "right":
            return self.right
        else:
            return []


def get_bank_offset(datapointer: int) -> Tuple[int, int]:
    """Get TileSection bank offsets based on DataPointer value ranges.

    The DataPointer value determines which TileSection bank to use
    for the top and bottom halves of the screen.

    Args:
        datapointer: DataPointer byte from WorldScreen

    Returns:
        Tuple of (top_bank_offset, bottom_bank_offset)
    """
    if datapointer >= 0xC0:
        # Both banks use Bank 1 (offset 0x100 = 256 TileSections)
        return (256, 256)
    elif datapointer >= 0x8F and datapointer < 0xA0:
        # Top uses Bank 1, bottom uses Bank 0
        return (256, 0)
    elif datapointer >= 0x40 and datapointer < 0x8F:
        # Top uses Bank 0, bottom uses Bank 1
        return (0, 256)
    else:
        # Both banks use Bank 0
        return (0, 0)


def read_tilesection(rom_data: bytes, index: int) -> bytes:
    """Read a TileSection (32 bytes) from ROM at given index.

    Args:
        rom_data: Full ROM data
        index: TileSection index (with bank offset applied)

    Returns:
        32 bytes of TileSection data
    """
    address = TILESECTION_BASE + (index * TILESECTION_OFFSET)
    return rom_data[address:address + 32]


def get_tilesection_grid(tilesection_data: bytes) -> List[List[int]]:
    """Convert TileSection bytes to 8x4 grid of tile IDs.

    TileSection layout: 4 rows of 8 tiles each = 32 bytes

    Args:
        tilesection_data: 32 bytes of TileSection data

    Returns:
        4 rows of 8 tile IDs each
    """
    grid = []
    for row in range(4):
        row_tiles = []
        for col in range(8):
            idx = row * 8 + col
            row_tiles.append(tilesection_data[idx] if idx < len(tilesection_data) else 0)
        grid.append(row_tiles)
    return grid


def build_tile_grid(
    rom_data: bytes,
    top_tiles: int,
    bottom_tiles: int,
    datapointer: int,
) -> List[List[int]]:
    """Build 8x6 tile grid from TileSection indices.

    Screen composition:
        - Rows 0-3: All 4 rows from TopTiles TileSection
        - Rows 4-5: First 2 rows from BottomTiles TileSection

    Args:
        rom_data: Full ROM data
        top_tiles: TileSection index for top (byte 10)
        bottom_tiles: TileSection index for bottom (byte 11)
        datapointer: DataPointer value (byte 8) for bank selection

    Returns:
        8x6 grid (list of 6 rows, each with 8 tile IDs)
    """
    # Get bank offsets
    top_offset, bottom_offset = get_bank_offset(datapointer)

    # Read TileSections with bank offsets
    top_section = read_tilesection(rom_data, top_tiles + top_offset)
    bottom_section = read_tilesection(rom_data, bottom_tiles + bottom_offset)

    # Convert to grids
    top_grid = get_tilesection_grid(top_section)      # 4 rows
    bottom_grid = get_tilesection_grid(bottom_section)  # 4 rows, but only use first 2

    # Combine: 4 rows from top + 2 rows from bottom = 6 rows
    grid = top_grid + bottom_grid[:2]

    return grid


def extract_edges(
    rom_data: bytes,
    screen_index: int,
    top_tiles: int,
    bottom_tiles: int,
    datapointer: int,
) -> ScreenEdges:
    """Extract all edge tiles from a screen.

    Args:
        rom_data: Full ROM data
        screen_index: Screen index for identification
        top_tiles: TileSection index for top
        bottom_tiles: TileSection index for bottom
        datapointer: DataPointer value

    Returns:
        ScreenEdges with all four edges
    """
    grid = build_tile_grid(rom_data, top_tiles, bottom_tiles, datapointer)

    return ScreenEdges(
        screen_index=screen_index,
        top=[grid[0][col] for col in range(8)],       # Row 0, all columns
        bottom=[grid[5][col] for col in range(8)],    # Row 5, all columns
        left=[grid[row][0] for row in range(6)],      # Column 0, all rows
        right=[grid[row][7] for row in range(6)],     # Column 7, all rows
    )


def extract_edges_from_screen(
    rom_data: bytes,
    screen: "WorldScreen",
) -> ScreenEdges:
    """Extract edges from a WorldScreen object.

    Args:
        rom_data: Full ROM data
        screen: WorldScreen object

    Returns:
        ScreenEdges with all four edges
    """
    return extract_edges(
        rom_data,
        screen.relative_index,
        screen.top_tiles,
        screen.bottom_tiles,
        screen.datapointer,
    )


# Direction mappings for edge comparison
OPPOSITE_DIRECTIONS = {
    "up": "down",
    "down": "up",
    "left": "right",
    "right": "left",
}


def get_connecting_edges(
    screen_a_edges: ScreenEdges,
    screen_b_edges: ScreenEdges,
    direction: str,
) -> Tuple[List[int], List[int]]:
    """Get the edges that connect two screens.

    When screen A connects to screen B in a direction,
    we compare A's edge in that direction with B's opposite edge.

    Example: A→right→B means compare A's right edge with B's left edge.

    Args:
        screen_a_edges: Edges of screen A
        screen_b_edges: Edges of screen B
        direction: Direction from A to B ("up", "down", "left", "right")

    Returns:
        Tuple of (edge_a, edge_b) to compare
    """
    opposite = OPPOSITE_DIRECTIONS.get(direction, "")
    edge_a = screen_a_edges.get_edge(direction)
    edge_b = screen_b_edges.get_edge(opposite)
    return (edge_a, edge_b)
