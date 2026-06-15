"""Environment / menu palette colors — RAM palette shadow ($04A0 page).

DISPLAY-ONLY. These are NOT ROM file offsets.

VERDICT (verified against GameAnalysis2/analysis_games/TMOS):
  $04A0 is the 32-byte *palette shadow RAM* page. Each frame, when the NMI
  status byte $1C bit2 is set, the game uploads $04A0..$04BF to PPU $3F00
  (the active palette). The individual environment/menu colors the planner
  listed as "$04A1-$04AB" are bytes *inside that RAM page*, populated at
  runtime (RESET seeds $04A1-A3=$20; per-screen world/level code overwrites
  them). They are reused as general scratch RAM (e.g. sprite-assignment
  `$04A1,X`), confirming they are not a dedicated palette mirror.

  Sources:
    - game_specs/systems/ui/README.md:34   ($04A1 = Menu border color, RAM)
    - game_specs/systems/ui/README.md:50-57 (environment/town/character colors)
    - game_specs/systems/ui/README.md:29    ($0400 "Menu text area (RAM)" — same page)
    - analysis/2026-06-12_rom_re/labels.csv:11
        "*,04A0,PaletteShadow,32 bytes -> $3F00 when $1C b2"
    - analysis/2026-06-12_rom_re/REVERSE.md:968,978,983 (shadow seed + upload)
    - analysis/2026-06-12_rom_re/REVERSE.md:193 ($04A1,X reused as scratch)

  Because there is NO confirmed ROM data table backing these colors, there is
  no safe ROM write target. Per the project TIER RULE (RAM / no offset =>
  display), every field is tier="display" and this module is READ-ONLY. It
  does not (and cannot correctly) persist edits to the ROM file. No write_*
  function is provided.

  (Contrast: the *hero* palette IS ROM-backed at $1ED05.. / $CA72.. per
  ui/README.md:59-61 — that is a separate, editable concern, not this module.)

Each color byte is an NES master-palette index, 0x00-0x3F (the high two bits
are unused by the PPU). Reads are surfaced from a snapshot of the $04A0 RAM
page (e.g. a save-state or emulator RAM dump), not the ROM file.
"""

from __future__ import annotations

from typing import TypedDict

# Tier for every field in this module. RAM-only => not ROM-writable.
TIER = "display"

# Base of the 32-byte palette shadow page in CPU RAM.
PALETTE_SHADOW_BASE = 0x04A0
PALETTE_SHADOW_SIZE = 32  # uploaded to PPU $3F00 each flagged frame

# Valid NES master-palette index range for any single color byte.
COLOR_MIN = 0x00
COLOR_MAX = 0x3F

# Environment / menu colors the planner referenced as "$04A1-$04AB".
# (RAM address, field key, human label, one-line tooltip from the knowledge base)
ENVIRONMENT_COLORS: tuple[tuple[int, str, str, str], ...] = (
    (0x04A1, "menu_border", "Menu Border",
     "Menu/dialog border color (RAM palette shadow $04A1)."),
    (0x04A2, "overworld_text", "Overworld Text",
     "Overworld text color (RAM palette shadow $04A2)."),
    (0x04A3, "secondary_icon", "Secondary Icon",
     "Secondary icon color (RAM palette shadow $04A3)."),
    (0x04A5, "tree_trunk", "Tree Trunk",
     "Tree trunk color (RAM palette shadow $04A5)."),
    (0x04A6, "tree_damage", "Tree Damage",
     "Damaged-tree color (RAM palette shadow $04A6)."),
    (0x04A7, "background", "Background",
     "Overworld background color (RAM palette shadow $04A7)."),
    (0x04A9, "water", "Water",
     "Water color (RAM palette shadow $04A9)."),
    (0x04AA, "water_ripple", "Water Ripple",
     "Water ripple color (RAM palette shadow $04AA)."),
    (0x04AB, "water_corner", "Water Corner",
     "Water corner color (RAM palette shadow $04AB)."),
)


class PaletteColorDTO(TypedDict):
    key: str
    label: str
    ram_address: str   # CPU RAM address, e.g. "0x04A1"
    rom_offset: None    # always None: RAM, no ROM file offset exists
    tier: str           # always "display"
    color_index: int    # NES palette index 0x00-0x3F
    color_index_hex: str
    valid_min: int
    valid_max: int
    tooltip: str


def _page_index(ram_address: int) -> int:
    """Offset of a $04A0-page address within a 32-byte shadow snapshot."""
    idx = ram_address - PALETTE_SHADOW_BASE
    if not 0 <= idx < PALETTE_SHADOW_SIZE:
        raise ValueError(
            f"address 0x{ram_address:04X} is outside the palette shadow page "
            f"0x{PALETTE_SHADOW_BASE:04X}..0x{PALETTE_SHADOW_BASE + PALETTE_SHADOW_SIZE - 1:04X}"
        )
    return idx


def _read_one(
    palette_ram: bytes, ram_address: int, key: str, label: str, tooltip: str
) -> PaletteColorDTO:
    raw = palette_ram[_page_index(ram_address)]
    return {
        "key": key,
        "label": label,
        "ram_address": f"0x{ram_address:04X}",
        "rom_offset": None,
        "tier": TIER,
        "color_index": raw & COLOR_MAX,  # mask unused high bits to a real index
        "color_index_hex": f"0x{raw & COLOR_MAX:02X}",
        "valid_min": COLOR_MIN,
        "valid_max": COLOR_MAX,
        "tooltip": tooltip,
    }


def read_palette_color(palette_ram: bytes, key: str) -> PaletteColorDTO:
    """Read one environment color from a 32-byte $04A0 RAM shadow snapshot.

    `palette_ram` is the 32 bytes of the $04A0 palette shadow page (e.g. from a
    save-state / RAM dump), NOT the ROM file. Read-only by design.
    """
    for addr, fkey, label, tip in ENVIRONMENT_COLORS:
        if fkey == key:
            return _read_one(palette_ram, addr, fkey, label, tip)
    raise ValueError(f"unknown palette color key: {key!r}")


def read_all_palette_colors(palette_ram: bytes) -> list[PaletteColorDTO]:
    """Read all environment colors from a 32-byte $04A0 RAM shadow snapshot."""
    return [
        _read_one(palette_ram, addr, fkey, label, tip)
        for addr, fkey, label, tip in ENVIRONMENT_COLORS
    ]


def palette_color_fields() -> list[dict]:
    """Static field metadata for UI rendering (no RAM/ROM required)."""
    return [
        {
            "key": fkey,
            "label": label,
            "ram_address": f"0x{addr:04X}",
            "rom_offset": None,
            "tier": TIER,
            "valid_min": COLOR_MIN,
            "valid_max": COLOR_MAX,
            "tooltip": tip,
        }
        for addr, fkey, label, tip in ENVIRONMENT_COLORS
    ]
