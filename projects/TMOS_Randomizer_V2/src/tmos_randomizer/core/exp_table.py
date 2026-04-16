"""Direct ROM read/write for the action-mode EXP tier table.

Wraps the EXP_TABLE region (0x174AA, stride 2, 10 entries). Each entry is a
single byte at offset + index*2; the intervening byte is unused/padding.

The seven "main" tiers (indices 0-6) carry the bulk of overworld encounters.
Indices 7-9 are special non-sequential tiers (4, 12, 1 in vanilla). Indices
10+ map to 0 in vanilla and are not populated by encounter screens.

Static usage map below mirrors the per-screen mapping documented in
GameAnalysis2 raw_research/screen_exp_mapping.md so the UI can show
"used by N screens" per tier without recomputing it.
"""

from __future__ import annotations

from typing import TypedDict

from .constants import EXP_TABLE_COUNT, EXP_TABLE_OFFSET, EXP_TABLE_STRIDE


class ExpEntryDTO(TypedDict):
    index: int
    value: int
    rom_offset: str


class ExpUsageEntry(TypedDict):
    chapter: int
    screen_hex: str


def _entry_offset(index: int) -> int:
    return EXP_TABLE_OFFSET + index * EXP_TABLE_STRIDE


def read_exp_entry(rom: bytes, index: int) -> ExpEntryDTO:
    if not 0 <= index < EXP_TABLE_COUNT:
        raise ValueError(f"index must be 0..{EXP_TABLE_COUNT - 1}, got {index}")
    off = _entry_offset(index)
    return {"index": index, "value": rom[off], "rom_offset": f"0x{off:05X}"}


def read_exp_table(rom: bytes) -> list[ExpEntryDTO]:
    return [read_exp_entry(rom, i) for i in range(EXP_TABLE_COUNT)]


def write_exp_entry(rom: bytearray, index: int, value: int) -> ExpEntryDTO:
    if not 0 <= index < EXP_TABLE_COUNT:
        raise ValueError(f"index must be 0..{EXP_TABLE_COUNT - 1}, got {index}")
    if not 0 <= value <= 255:
        raise ValueError(f"value must be 0..255, got {value}")
    off = _entry_offset(index)
    rom[off] = value & 0xFF
    return {"index": index, "value": value, "rom_offset": f"0x{off:05X}"}


# Per-screen mapping of which (chapter, screen_hex) uses each tier.
# Source: GameAnalysis2/analysis_games/TMOS/analysis/2026-03-26_knowledge_build/
#         raw_research/screen_exp_mapping.md (ROM_VERIFIED for Ch1-2;
#         Ch3-5 entries with low_bits 0-9 still index this table).
EXP_USAGE: dict[int, list[ExpUsageEntry]] = {
    0: [  # 2 EXP — weakest tier
        {"chapter": 1, "screen_hex": "0x21"},
        {"chapter": 1, "screen_hex": "0x22"},
        {"chapter": 1, "screen_hex": "0x44"},
        {"chapter": 2, "screen_hex": "0x10"},
        {"chapter": 2, "screen_hex": "0x25"},
        {"chapter": 2, "screen_hex": "0x40"},
    ],
    1: [  # 5 EXP — low tier
        {"chapter": 1, "screen_hex": "0x1B"},
        {"chapter": 1, "screen_hex": "0x1F"},
        {"chapter": 1, "screen_hex": "0x23"},
        {"chapter": 1, "screen_hex": "0x25"},
        {"chapter": 1, "screen_hex": "0x2E"},
        {"chapter": 1, "screen_hex": "0x56"},
        {"chapter": 2, "screen_hex": "0x15"},
        {"chapter": 2, "screen_hex": "0x24"},
    ],
    2: [  # 10 EXP — mid-low tier
        {"chapter": 1, "screen_hex": "0x37"},
        {"chapter": 1, "screen_hex": "0x3B"},
        {"chapter": 1, "screen_hex": "0x5E"},
        {"chapter": 2, "screen_hex": "0x0F"},
    ],
    3: [  # 20 EXP — mid tier
        {"chapter": 1, "screen_hex": "0x47"},
        {"chapter": 1, "screen_hex": "0x48"},
        {"chapter": 1, "screen_hex": "0x4C"},
        {"chapter": 2, "screen_hex": "0x57"},
    ],
    4: [  # 30 EXP — mid-high tier
        {"chapter": 2, "screen_hex": "0x0E"},
        {"chapter": 2, "screen_hex": "0x32"},
        {"chapter": 2, "screen_hex": "0x4A"},
        {"chapter": 2, "screen_hex": "0x6E"},
    ],
    5: [  # 40 EXP — high tier
        {"chapter": 2, "screen_hex": "0x5C"},
        {"chapter": 3, "screen_hex": "0x7C"},
    ],
    6: [  # 50 EXP — very high tier
        {"chapter": 2, "screen_hex": "0x3D"},
        {"chapter": 2, "screen_hex": "0x63"},
        {"chapter": 2, "screen_hex": "0x67"},
    ],
    7: [  # 4 EXP — special low (high-bit-flagged maze entries)
        {"chapter": 2, "screen_hex": "0x56"},
        {"chapter": 3, "screen_hex": "0x75"},
        {"chapter": 3, "screen_hex": "0x7E"},
    ],
    8: [  # 12 EXP — special mid
        {"chapter": 3, "screen_hex": "0x11"},
        {"chapter": 3, "screen_hex": "0x50"},
        {"chapter": 3, "screen_hex": "0x61"},
    ],
    9: [  # 1 EXP — minimal
        {"chapter": 3, "screen_hex": "0x0C"},
        {"chapter": 3, "screen_hex": "0x1A"},
        {"chapter": 3, "screen_hex": "0x22"},
        {"chapter": 3, "screen_hex": "0x28"},
        {"chapter": 3, "screen_hex": "0x4A"},
        {"chapter": 3, "screen_hex": "0x53"},
        {"chapter": 3, "screen_hex": "0x55"},
        {"chapter": 5, "screen_hex": "0x13"},
    ],
}


# Human-readable labels for the UI.
EXP_TIER_LABELS: dict[int, str] = {
    0: "weak",
    1: "low",
    2: "mid-lo",
    3: "mid",
    4: "mid-hi",
    5: "high",
    6: "very high",
    7: "special-lo",
    8: "special-mid",
    9: "minimal",
}
