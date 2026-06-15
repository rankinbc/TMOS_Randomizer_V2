"""Byte/bank/DataPointer math for editing a WorldScreen's tile sections.

A WorldScreen stores top_tiles/bottom_tiles as 0-255 bytes, but there are
TILESECTION_COUNT (471) sections. Sections >= 256 live in "bank 1". The bank
for each half is selected by the DataPointer via the renderer's value-range
model (get_bank_offset), which is authoritative here. The DataPointer also
carries the CHR bank index in its low 6 bits.

The (top=1, bottom=0) bank combo only exists for DataPointer 0x8F-0x9F, so the
CHR index is constrained to 0x0F-0x1F for that combo. All other combos preserve
the current CHR index.
"""
from __future__ import annotations

from typing import Optional

from ..core.constants import TILESECTION_COUNT


def decompose_section_index(global_index: int) -> tuple[int, int]:
    """Split a global section index (0..470) into (byte, bank)."""
    if global_index < 0 or global_index >= TILESECTION_COUNT:
        raise ValueError(
            f"section index {global_index} out of range [0, {TILESECTION_COUNT})"
        )
    bank = 1 if global_index >= 256 else 0
    byte = global_index - 256 * bank
    return byte, bank


def compute_datapointer(
    top_bank: int, bottom_bank: int, current_chr: int
) -> tuple[int, int]:
    """Return (datapointer, chr_used) realizing the requested bank combo.

    chr_used == current_chr for every combo except (1, 0), where it is clamped
    into 0x0F-0x1F (the only CHR window for which DataPointer yields top-bank-1
    + bottom-bank-0 under get_bank_offset).
    """
    chr_index = current_chr & 0x3F
    combo = (top_bank, bottom_bank)
    if combo == (0, 0):
        return chr_index, chr_index           # dp < 0x40
    if combo == (0, 1):
        return 0x40 | chr_index, chr_index     # 0x40-0x7F
    if combo == (1, 1):
        return 0xC0 | chr_index, chr_index     # 0xC0-0xFF
    # combo == (1, 0): only dp 0x8F-0x9F => chr 0x0F-0x1F
    chr_used = min(max(chr_index, 0x0F), 0x1F)
    return 0x80 | chr_used, chr_used


def resolve_tile_update(
    current_datapointer: int,
    top_index: Optional[int],
    bottom_index: Optional[int],
) -> dict:
    """Resolve a tile-section edit into concrete byte/DataPointer values.

    Args:
        current_datapointer: the screen's current DataPointer byte.
        top_index: new global section index for the top half, or None to keep.
        bottom_index: new global section index for the bottom half, or None.

    Returns dict with: top_tiles (byte|None), bottom_tiles (byte|None),
    datapointer (int), datapointer_changed (bool), chr_changed (bool).
    """
    # Lazy import to avoid a circular import at module load.
    from ..rendering.screen_renderer import get_bank_offset

    cur_top_off, cur_bot_off = get_bank_offset(current_datapointer)
    cur_top_bank = 1 if cur_top_off else 0
    cur_bot_bank = 1 if cur_bot_off else 0
    current_chr = current_datapointer & 0x3F

    top_byte: Optional[int] = None
    bottom_byte: Optional[int] = None
    new_top_bank = cur_top_bank
    new_bot_bank = cur_bot_bank

    if top_index is not None:
        top_byte, new_top_bank = decompose_section_index(top_index)
    if bottom_index is not None:
        bottom_byte, new_bot_bank = decompose_section_index(bottom_index)

    datapointer, chr_used = compute_datapointer(new_top_bank, new_bot_bank, current_chr)

    return {
        "top_tiles": top_byte,
        "bottom_tiles": bottom_byte,
        "datapointer": datapointer,
        "datapointer_changed": datapointer != current_datapointer,
        "chr_changed": chr_used != current_chr,
    }
