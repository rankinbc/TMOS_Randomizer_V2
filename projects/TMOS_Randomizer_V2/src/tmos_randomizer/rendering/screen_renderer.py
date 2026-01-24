"""
Screen rendering module for TMOS Randomizer.

Renders WorldScreen visuals by compositing tile images based on TileSection data.
"""

import os
import logging

logger = logging.getLogger(__name__)
from pathlib import Path
from typing import Optional, Dict, Tuple
from io import BytesIO
import struct

try:
    from PIL import Image
except ImportError:
    Image = None  # Will fail gracefully if PIL not installed


# ROM addresses
TILESECTION_BASE = 0x03C4C7
TILESECTION_OFFSET = 32  # Each TileSection is 32 bytes (0x20), use index * 32 for address

# Tile image dimensions (each tile image is 64x64 pixels - pre-rendered metatiles)
TILE_PIXEL_SIZE = 64

# Screen dimensions in tiles (metatiles)
SCREEN_WIDTH_TILES = 8
SCREEN_HEIGHT_TILES = 6  # 4 top + 2 bottom (bottom rows 2-3 not rendered)

# Full screen pixel dimensions at 1x scale
SCREEN_WIDTH_PX = SCREEN_WIDTH_TILES * TILE_PIXEL_SIZE  # 512 pixels
SCREEN_HEIGHT_PX = SCREEN_HEIGHT_TILES * TILE_PIXEL_SIZE  # 384 pixels

# Tile ID to image filename mapping (from TMOS_Romhack1)
TILE_FILENAME_MAP = {
    0x00: '00', 0x01: '01', 0x02: '02', 0x03: '03', 0x04: '04', 0x05: '05',
    0x06: '0D', 0x0D: '0D', 0x0E: '0D', 0x0F: '0D', 0x10: '0D', 0x14: '0D', 0x15: '0D',
    0x16: '0D', 0x17: '0D', 0x18: '0D', 0x19: '0D', 0x1A: '0D',
    0x07: '08', 0x08: '08', 0x09: '08', 0x0A: '08', 0x11: '08',
    0x0B: '20', 0x20: '20',
    0x0C: '0C', 0x12: '12', 0x1B: '1B', 0x1E: '1E', 0x1F: '1F',
    0x21: '21', 0x22: '22', 0x23: '23',
    0x24: '25', 0x25: '25',
    0x26: '26',
    0x2B: '43', 0x2C: '43', 0x2D: '43', 0x2E: '43', 0x37: '43', 0x38: '43',
    0x39: '43', 0x3A: '43', 0x3B: '43', 0x3C: '43', 0x3D: '43', 0x3E: '43', 0x43: '43',
    0x2F: '3F', 0x30: '3F', 0x3F: '3F',
    0x32: '41', 0x41: '41',
    0x33: '40', 0x34: '40', 0x40: '40',
    0x42: '42', 0x44: '44', 0x47: '47', 0x48: '48', 0x4A: '4A', 0x4C: '4C',
    0x4D: '4D', 0x4E: '4E',
    0x53: '53', 0x54: '54', 0x55: '55', 0x56: '56', 0x57: '57', 0x58: '58',
    0x59: '59', 0x5A: '5A', 0x5B: '5B', 0x5C: '5C', 0x5D: '5D', 0x5E: '5E', 0x5F: '5F',
    0x60: '60', 0x61: '61', 0x62: '62', 0x63: '63', 0x64: '64', 0x65: '65',
    0x67: '67', 0x68: '68', 0x6B: '6B', 0x6F: '6F',
    0x70: '70', 0x71: '71', 0x72: '72',
    0x73: '03', 0xED: '03', 0xF3: '03',
    0x76: '76', 0x77: '77', 0x78: '78', 0x7A: '7A', 0x7B: '7B', 0x7C: '7C', 0x7D: '7D', 0x7F: '7F',
    0x79: '26',
    0x80: '80', 0x81: '81', 0x82: '82', 0x83: '83', 0x84: '84',
    0x86: '86', 0x87: '87', 0x88: '88', 0x89: '89', 0x8A: '8A',
    0x8C: '8C', 0x8D: '8D', 0x8E: '8E', 0x8F: '8F',
    0x92: '92', 0x93: '93', 0x94: '94', 0x95: '95', 0x96: '96', 0x97: '97',
    0x98: '98', 0x99: '99', 0x9A: '9A', 0x9B: '9B', 0x9C: '9C',
    0x9D: '9D', 0x9E: '9E', 0x9F: '9F',
    0xA1: 'A1', 0xA2: 'A2', 0xA3: 'A3', 0xA4: 'A4', 0xA5: 'A5', 0xA6: 'A6', 0xA8: 'A8',
    0xA9: 'A9', 0xE2: 'A9',
    0xAA: 'AA', 0xAB: 'AA', 0xAF: 'AA',
    0xAC: 'AC', 0xAD: 'AD',
    0xB0: 'B0', 0xB1: 'B1', 0xB2: 'B2', 0xB3: 'B3', 0xB5: 'B5',
    0xB8: 'B8', 0xB9: 'B9', 0xBC: 'BC', 0xBD: 'BD', 0xBE: 'BE', 0xBF: 'BF',
    0xC0: 'C0', 0xC1: 'C1', 0xC2: 'C2', 0xC3: 'C3', 0xC4: 'C4', 0xC5: 'C5', 0xC6: 'C6', 0xC7: 'C7',
    0xCF: 'CF', 0xD0: 'D0',
    0xD5: 'D6', 0xD6: 'D6',
    0xDA: 'DA', 0xDC: 'DC', 0xDD: 'DD', 0xDE: 'DE',
    0xE0: 'E0', 0xE1: 'E1', 0xE6: 'E6', 0xE7: 'E7', 0xE9: 'E9', 0xEA: 'EA', 0xEB: 'EB',
    0xEC: 'EC', 0xEE: 'EE', 0xEF: 'EF',
    0xF0: 'F0', 0xF1: 'F1', 0xF2: 'F2', 0xF4: 'F4', 0xF5: 'F5',
    0xF6: 'F6', 0xF7: 'F7', 0xF8: 'F8', 0xF9: 'F9', 0xFA: 'FA', 0xFB: 'FB', 0xFC: 'FC',
    0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF',
}


def get_tile_filename(tile_id: int) -> str:
    """Get the image filename for a tile ID using the mapping from TMOS_Romhack1."""
    base = TILE_FILENAME_MAP.get(tile_id)
    if base:
        return f"{base}.png"
    return f"{tile_id:02X}.png"


# Ground color based on WorldScreen color value (from TMOS_Romhack1)
def get_ground_color(ws_color_value: int) -> Tuple[int, int, int]:
    """Get RGB ground color based on WorldScreen color value."""
    hex_val = f"{ws_color_value:02X}"
    color_map = {
        '21': (0, 60, 20), '2A': (0, 60, 20), '32': (0, 60, 20), '45': (0, 60, 20),
        '30': (0, 112, 236), '3B': (0, 112, 236),
        '25': (252, 228, 160), '41': (252, 228, 160), '47': (252, 228, 160),
        '1A': (0, 80, 0),
        '3C': (164, 0, 0), '31': (164, 0, 0),
        '23': (188, 188, 188), '2B': (188, 188, 188), '39': (188, 188, 188),
        '11': (0, 0, 0), '27': (0, 0, 0), '43': (0, 0, 0), '44': (0, 0, 0),
        '4A': (0, 0, 0), '34': (0, 0, 0), '1F': (0, 0, 0), '20': (0, 0, 0),
        '1C': (216, 40, 0), '46': (216, 40, 0), '48': (216, 40, 0),
    }
    return color_map.get(hex_val, (0, 148, 0))




def load_tile_mapping(tiles_txt_path: Optional[str] = None) -> Dict[int, str]:
    """Load tile ID to image filename mapping from tiles.txt or use hardcoded mapping."""
    mapping = {}

    if tiles_txt_path and os.path.exists(tiles_txt_path):
        with open(tiles_txt_path, 'r', encoding='utf-8-sig') as f:
            for line in f:
                line = line.strip()
                if line and ' ' in line:
                    parts = line.split()
                    if len(parts) >= 2:
                        try:
                            tile_id = int(parts[0], 16)
                            image_file = parts[1]
                            mapping[tile_id] = image_file
                        except ValueError:
                            continue

    # Use hardcoded TILE_FILENAME_MAP for any unmapped tiles
    for i in range(256):
        if i not in mapping:
            mapping[i] = get_tile_filename(i)

    return mapping


def get_bank_offset(datapointer: int) -> Tuple[int, int]:
    """
    Get TileSection bank offsets based on DataPointer value ranges.

    Bank selection is determined by DataPointer VALUE RANGES, not individual bits.
    This matches the algorithm from TMOS_Romhack1:

    - 0x00-0x3F: Top Bank 0, Bottom Bank 0
    - 0x40-0x8E: Top Bank 0, Bottom Bank 1
    - 0x8F-0x9F: Top Bank 1, Bottom Bank 0
    - 0xC0+:     Top Bank 1, Bottom Bank 1

    Returns: (top_bank_offset, bottom_bank_offset)
    Where offset is 0 for Bank 0 or 256 for Bank 1.
    (256 index offset * 32 bytes = 0x2000 byte offset)
    """
    if datapointer >= 0xC0:
        # Both banks use Bank 1 (offset 0x2000)
        return (256, 256)
    elif datapointer >= 0x8F and datapointer < 0xA0:
        # Top Bank 1, Bottom Bank 0
        return (256, 0)
    elif datapointer >= 0x40 and datapointer < 0x8F:
        # Top Bank 0, Bottom Bank 1
        return (0, 256)
    else:
        # datapointer < 0x40: Both banks use Bank 0
        return (0, 0)


def read_tilesection(rom_data: bytes, index: int) -> bytes:
    """Read a TileSection (32 bytes) from ROM at given index."""
    address = TILESECTION_BASE + (index * TILESECTION_OFFSET)
    data = rom_data[address:address + 32]
    return data


def get_tilesection_grid(tilesection_data: bytes) -> list:
    """
    Convert TileSection bytes to 8x4 grid of tile IDs.
    Returns list of 4 rows, each row is list of 8 tile IDs.
    """
    grid = []
    for row in range(4):
        row_tiles = []
        for col in range(8):
            idx = row * 8 + col
            row_tiles.append(tilesection_data[idx] if idx < len(tilesection_data) else 0)
        grid.append(row_tiles)
    return grid


def build_screen_tile_grid(
    rom_data: bytes,
    top_tiles: int,
    bottom_tiles: int,
    datapointer: int
) -> list:
    """
    Build the full 8x6 tile grid for a screen.

    Screen composition:
    - Rows 0-3: All 4 rows from TopTiles TileSection
    - Rows 4-5: First 2 rows from BottomTiles TileSection (rows 2-3 not rendered)

    Returns list of 6 rows, each row is list of 8 tile IDs.
    """
    top_offset, bottom_offset = get_bank_offset(datapointer)

    # Read TileSections with bank offsets
    top_section = read_tilesection(rom_data, top_tiles + top_offset)
    bottom_section = read_tilesection(rom_data, bottom_tiles + bottom_offset)

    # Convert to grids
    top_grid = get_tilesection_grid(top_section)  # 4 rows
    bottom_grid = get_tilesection_grid(bottom_section)  # 4 rows, but only use first 2

    # Combine: all 4 top rows + first 2 bottom rows
    full_grid = top_grid + bottom_grid[:2]

    return full_grid


class ScreenRenderer:
    """Renders WorldScreen images from ROM data."""

    def __init__(
        self,
        rom_data: bytes,
        tile_images_path: str,
        tiles_txt_path: Optional[str] = None
    ):
        """
        Initialize renderer.

        Args:
            rom_data: Full ROM file bytes
            tile_images_path: Path to directory containing tile PNG files
            tiles_txt_path: Optional path to tiles.txt mapping file
        """
        if Image is None:
            raise ImportError("PIL/Pillow is required for screen rendering. Install with: pip install Pillow")

        self.rom_data = rom_data
        self.tile_images_path = Path(tile_images_path)
        self.tile_mapping = load_tile_mapping(tiles_txt_path)
        self._tile_cache: Dict[int, Image.Image] = {}

    def _load_tile_image(self, tile_id: int) -> Optional[Image.Image]:
        """Load a tile image (64x64 metatile), with caching."""
        if tile_id in self._tile_cache:
            return self._tile_cache[tile_id]

        # Get image filename from mapping
        filename = self.tile_mapping.get(tile_id, f"{tile_id:02X}.png")
        filepath = self.tile_images_path / filename

        if filepath.exists():
            try:
                img = Image.open(filepath).convert('RGB')
                # Tile images should be 64x64, resize if needed
                if img.size != (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE):
                    img = img.resize((TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), Image.NEAREST)
                self._tile_cache[tile_id] = img
                return img
            except Exception:
                pass

        # Return None for missing tiles
        return None

    def _create_fallback_tile(self, tile_id: int) -> Image.Image:
        """Create a colored fallback tile for missing images."""
        # Use tile ID to generate a deterministic color
        r = (tile_id * 37) % 256
        g = (tile_id * 73) % 256
        b = (tile_id * 113) % 256

        img = Image.new('RGB', (TILE_PIXEL_SIZE, TILE_PIXEL_SIZE), (r, g, b))
        return img

    def render_screen(
        self,
        top_tiles: int,
        bottom_tiles: int,
        datapointer: int,
        scale: int = 1
    ) -> Image.Image:
        """
        Render a complete screen image.

        Args:
            top_tiles: TopTiles TileSection index from WorldScreen
            bottom_tiles: BottomTiles TileSection index from WorldScreen
            datapointer: DataPointer value from WorldScreen (for bank selection)
            scale: Scale factor for output image (1 = 64x56, 2 = 128x112, etc.)

        Returns:
            PIL Image of the rendered screen
        """
        # Build the tile grid
        tile_grid = build_screen_tile_grid(
            self.rom_data,
            top_tiles,
            bottom_tiles,
            datapointer
        )

        # Create output image
        width = SCREEN_WIDTH_PX * scale
        height = SCREEN_HEIGHT_PX * scale
        output = Image.new('RGB', (width, height), (0, 0, 0))

        # Render each tile
        for row_idx, row in enumerate(tile_grid):
            for col_idx, tile_id in enumerate(row):
                tile_img = self._load_tile_image(tile_id)
                if tile_img is None:
                    tile_img = self._create_fallback_tile(tile_id)

                # Scale tile if needed
                if scale > 1:
                    tile_img = tile_img.resize(
                        (TILE_PIXEL_SIZE * scale, TILE_PIXEL_SIZE * scale),
                        Image.NEAREST
                    )

                # Paste tile into output
                x = col_idx * TILE_PIXEL_SIZE * scale
                y = row_idx * TILE_PIXEL_SIZE * scale
                output.paste(tile_img, (x, y))

        return output

    def render_screen_to_bytes(
        self,
        top_tiles: int,
        bottom_tiles: int,
        datapointer: int,
        scale: int = 1,
        format: str = 'PNG'
    ) -> bytes:
        """
        Render a screen and return as bytes (for HTTP response).

        Args:
            top_tiles: TopTiles TileSection index
            bottom_tiles: BottomTiles TileSection index
            datapointer: DataPointer value
            scale: Scale factor
            format: Image format ('PNG', 'JPEG', etc.)

        Returns:
            Image bytes
        """
        img = self.render_screen(top_tiles, bottom_tiles, datapointer, scale)
        buffer = BytesIO()
        img.save(buffer, format=format)
        return buffer.getvalue()


# Convenience function for quick rendering
def render_worldscreen(
    rom_data: bytes,
    worldscreen_data: bytes,
    tile_images_path: str,
    tiles_txt_path: Optional[str] = None,
    scale: int = 1
) -> bytes:
    """
    Render a WorldScreen from its 16-byte data.

    Args:
        rom_data: Full ROM bytes
        worldscreen_data: 16-byte WorldScreen data
        tile_images_path: Path to tile images directory
        tiles_txt_path: Optional path to tiles.txt
        scale: Scale factor

    Returns:
        PNG image bytes
    """
    # Extract relevant bytes from WorldScreen
    datapointer = worldscreen_data[8]
    top_tiles = worldscreen_data[10]
    bottom_tiles = worldscreen_data[11]

    renderer = ScreenRenderer(rom_data, tile_images_path, tiles_txt_path)
    return renderer.render_screen_to_bytes(top_tiles, bottom_tiles, datapointer, scale)
