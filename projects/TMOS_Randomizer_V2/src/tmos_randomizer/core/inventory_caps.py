"""Inventory cap table at file 0xD544 (Bank 3 $9534).

CORRECTION 2026-04-16: this table was previously misinterpreted as a shop
slot table. Per RE answer (TMOS_AI/docs/human/items-economy-re-answers.md),
it's actually the inventory cap lookup used by the chest/drop pickup handler
in Bank 3 ($94B0).

Each of the 8 entries is 4 bytes:

  byte 0 = low byte of a $03xx RAM pointer to an inventory variable
  byte 1 = 0x03 (high byte of the pointer; constant — corruption if changed)
  byte 2 = max cap (the user-meaningful field)
  byte 3 = slot index used for party-slot mirroring at $0515+X

Editing byte 2 raises/lowers the cap for the targeted inventory variable.
Editing bytes 0/1 retargets the slot to a different RAM address (dangerous
unless you know the layout).

Vanilla resolution table (verified against RE answer doc):

  ram_addr -> (label, notes)
"""

from __future__ import annotations

from typing import Optional, TypedDict

from .constants import INV_CAP_TABLE, INV_CAP_SLOT_SIZE, INV_CAP_SLOT_COUNT


# Map of $03xx RAM pointers to human-readable labels.
# Source: TMOS_AI/docs/human/items-economy-re-answers.md tables.
RAM_LABELS: dict[int, dict[str, str]] = {
    0x0300: {"label": "Gortrat bread counter",   "notes": "NOT carried Bread"},
    0x0301: {"label": "Gortrat mashroob counter","notes": "NOT carried Mashroob"},
    0x0302: {"label": "Armor level",              "notes": "0=none, 1=R-Armor (½ dmg), 2=L-Armor (¼ dmg)"},
    0x0303: {"label": "M-Shield",                 "notes": "boolean (0/1)"},
    0x0304: {"label": "M-Boots",                  "notes": "boolean (0/1)"},
    0x0305: {"label": "HolyRobe",                 "notes": "boolean (0/1)"},
    0x0306: {"label": "BREAD",                    "notes": "carried, vanilla cap 10; auto-restores 50 HP on death"},
    0x0307: {"label": "MASHROOB",                 "notes": "carried, vanilla cap 10; auto-restores 50 MP on empty"},
    0x0308: {"label": "KEY",                      "notes": "vanilla cap 9 (cap also enforced in code at $F2CB)"},
    0x0309: {"label": "AMULET",                   "notes": "vanilla cap 9 (cap also enforced in code at $87F4)"},
    0x030E: {"label": "Player level",             "notes": "2..6"},
    0x030F: {"label": "ROD charges",              "notes": "vanilla cap 1 in this table; max 5 in gameplay"},
    0x0310: {"label": "FLAME charges",            "notes": "vanilla cap 1 in this table; max 5 in gameplay"},
    0x0311: {"label": "STARDUST charges",         "notes": "vanilla cap 15"},
    0x0312: {"label": "Max MP / power",           "notes": "vanilla cap 5"},
    0x0322: {"label": "Magic level",              "notes": "2..6"},
    0x0332: {"label": "Equipped sword",           "notes": "written by sword pickup at $8E3D"},
}


class InventoryCapDTO(TypedDict):
    slot_index: int
    rom_offset: str
    ram_addr: int             # 16-bit RAM pointer (byte 0 + byte 1 << 8)
    ram_addr_hex: str
    label: str                # human-readable name of the targeted variable
    notes: str
    max_cap: int              # the editable byte
    raw_byte_3: int           # party-slot mirror index (read-only)
    high_byte_warning: bool   # True if byte 1 != 0x03 (corruption)


def _resolve_label(ram_addr: int) -> tuple[str, str]:
    info = RAM_LABELS.get(ram_addr)
    if info:
        return info["label"], info["notes"]
    return f"Unknown ${ram_addr:04X}", "no documented purpose for this RAM address"


def _read_slot(rom: bytes, slot_idx: int) -> InventoryCapDTO:
    off = INV_CAP_TABLE + slot_idx * INV_CAP_SLOT_SIZE
    addr_lo = rom[off]
    addr_hi = rom[off + 1]
    cap = rom[off + 2]
    b3 = rom[off + 3]
    ram_addr = addr_lo | (addr_hi << 8)
    label, notes = _resolve_label(ram_addr)
    return {
        "slot_index": slot_idx,
        "rom_offset": f"0x{off:05X}",
        "ram_addr": ram_addr,
        "ram_addr_hex": f"${ram_addr:04X}",
        "label": label,
        "notes": notes,
        "max_cap": cap,
        "raw_byte_3": b3,
        "high_byte_warning": addr_hi != 0x03,
    }


def read_caps(rom: bytes) -> list[InventoryCapDTO]:
    return [_read_slot(rom, i) for i in range(INV_CAP_SLOT_COUNT)]


def write_cap(rom: bytearray, slot_idx: int, max_cap: int) -> InventoryCapDTO:
    """Set the cap (byte 2) for one slot. Other bytes are not touched."""
    if not 0 <= slot_idx < INV_CAP_SLOT_COUNT:
        raise ValueError(f"slot_idx must be 0..{INV_CAP_SLOT_COUNT - 1}, got {slot_idx}")
    if not 0 <= max_cap <= 255:
        raise ValueError(f"max_cap must be 0..255, got {max_cap}")
    rom[INV_CAP_TABLE + slot_idx * INV_CAP_SLOT_SIZE + 2] = max_cap
    return _read_slot(bytes(rom), slot_idx)


def write_ram_addr(rom: bytearray, slot_idx: int, ram_addr: int) -> InventoryCapDTO:
    """Retarget a slot to a different $03xx RAM variable.

    DANGEROUS: writing a non-$03xx address corrupts zero-page or other RAM
    when the pickup handler increments through the pointer. Refuses to write
    a high byte other than 0x03 unless you... still refuses, frankly.
    """
    if not 0 <= slot_idx < INV_CAP_SLOT_COUNT:
        raise ValueError(f"slot_idx must be 0..{INV_CAP_SLOT_COUNT - 1}, got {slot_idx}")
    if (ram_addr >> 8) != 0x03:
        raise ValueError(
            f"ram_addr must be in $0300-$03FF (high byte must be 0x03), got ${ram_addr:04X}. "
            "Pointer corruption beyond $03xx is not supported."
        )
    off = INV_CAP_TABLE + slot_idx * INV_CAP_SLOT_SIZE
    rom[off] = ram_addr & 0xFF
    rom[off + 1] = 0x03
    return _read_slot(bytes(rom), slot_idx)
