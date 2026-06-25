"""Builds field metadata (descriptions, safety tier, enums, warnings) for the UI.

This module is the single source of truth for the 3-tier safety model and the
guided-editing metadata. Tiers and enums derive from core/enums.py, which mirrors
the authoritative GameAnalysis2 knowledgebase.

Tiers (the Expert tab was retired; danger fields are no longer hidden):
    safe    - edit freely on the entity tab.
    caution - editable inline, but validated/warned; controls pre-filtered to valid values.
    danger  - editable inline as well, shown with a prominent warning badge because the
              value is high-risk (can crash or corrupt). No longer gated/hidden.
"""

from __future__ import annotations

from enum import IntEnum
from typing import Any, Dict, List

from .enums import ContentType, EventType, ParentWorld

METADATA_VERSION = "2"


def _enum_options(enum_cls: type[IntEnum]) -> List[Dict[str, Any]]:
    """Render an IntEnum as a list of {value, label} dicts, sorted by value."""
    return [
        {"value": int(member.value), "label": f"{member.name} (0x{int(member.value):02X})"}
        for member in sorted(enum_cls, key=lambda m: int(m.value))
    ]


def _worldscreen_fields() -> Dict[str, Dict[str, Any]]:
    return {
        "parent_world": {
            "label": "Parent World / Music", "byte": 0, "tier": "caution",
            "control": "enum", "enum": _enum_options(ParentWorld),
            "description": "Section type + background music for this screen.",
            "warning": "Must be a valid section-type value or audio/state may glitch.",
            "used_by": ["section classification", "music"],
        },
        "ambient_sound": {
            "label": "Ambient Sound", "byte": 1, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Background ambient sound-effect ID looped on this screen "
                           "(wind, water, town bustle, etc.). Cosmetic — safe to change; "
                           "0 is silence.",
            "warning": "", "used_by": ["ambient audio"],
        },
        "content": {
            "label": "Content / Building", "byte": 2, "tier": "caution",
            "control": "enum", "enum": _enum_options(ContentType),
            "description": "Building, NPC, shop, boss stage, or time door on this screen.",
            "warning": "NPC values 0x80-0x8F summon a different character per chapter; "
                       "do not move such a screen across chapters.",
            "used_by": ["objectset spawn lookup", "NPC dialog"],
        },
        "objectset": {
            "label": "ObjectSet (enemy spawn set)", "byte": 3, "tier": "danger",
            "control": "number", "valid_range": [0, 255],
            "description": "Pointer into the per-chapter enemy spawn table.",
            "warning": "Out-of-range values crash on screen load.",
            "used_by": ["overworld enemy spawns"],
        },
        "screen_index_right": {
            "label": "Exit → Right", "byte": 4, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking right (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_left": {
            "label": "Exit → Left", "byte": 5, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking left (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_down": {
            "label": "Exit → Down", "byte": 6, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking down (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "screen_index_up": {
            "label": "Exit → Up", "byte": 7, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Destination screen when walking up (0xFE=building, 0xFF=blocked).",
            "warning": "Index must be < the chapter's screen count.",
            "used_by": ["navigation graph"],
        },
        "datapointer": {
            "label": "DataPointer / CHR bank", "byte": 8, "tier": "danger",
            "control": "number", "valid_range": [0, 255],
            "description": "Selects CHR graphics bank (bits 0-5) and TileSection bank (bits 6-7).",
            "warning": "Invalid banks corrupt graphics; change only via tile-section swaps.",
            "used_by": ["tile rendering"],
        },
        "exit_position": {
            "label": "Exit Position", "byte": 9, "tier": "danger", "control": "number",
            "valid_range": [0, 255],
            "description": "Player spawn position when entering the screen.",
            "warning": "Bad values can spawn the player out of bounds.",
            "used_by": ["player spawn"],
        },
        "top_tiles": {
            "label": "Top TileSection", "byte": 10, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Index of the TileSection drawn across the top half of the "
                           "screen. Best changed via the Edit-modal tile picker, which keeps "
                           "collision seams and biome/theme coherent — blind index entry can "
                           "mismatch the bottom half.",
            "warning": "", "used_by": ["tile rendering"],
        },
        "bottom_tiles": {
            "label": "Bottom TileSection", "byte": 11, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Index of the TileSection drawn across the bottom half of the "
                           "screen. Best changed via the Edit-modal tile picker (collision/"
                           "theme-aware) rather than raw index entry.",
            "warning": "", "used_by": ["tile rendering"],
        },
        "worldscreen_color": {
            "label": "Background Palette", "byte": 12, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Background color-palette selector for the screen. Also editable "
                           "visually via Graphics → Cosmetic.",
            "warning": "", "used_by": ["palette"],
        },
        "sprites_color": {
            "label": "Sprite Palette", "byte": 13, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Sprite color-palette selector (e.g. 0x12 ≈ town sprites). Also "
                           "editable visually via Graphics → Cosmetic.",
            "warning": "", "used_by": ["palette"],
        },
        "unknown": {
            "label": "Unknown (byte 14)", "byte": 14, "tier": "danger", "control": "number",
            "valid_range": [0, 255],
            "description": "Purpose not yet reverse-engineered.",
            "warning": "Unknown effect — do not modify.",
            "used_by": [],
        },
        "event": {
            "label": "Event byte", "byte": 15, "tier": "danger",
            "control": "enum", "enum": _enum_options(EventType),
            "description": "Dialog/door/transition trigger. Many values are story- or "
                           "navigation-critical.",
            "warning": "Most event values break story/navigation or crash; safe values are "
                       "only 0x00, 0x08, 0x22, 0x40.",
            "used_by": ["story scripting", "stairways", "maze logic"],
        },
    }


def _enemy_fields() -> Dict[str, Dict[str, Any]]:
    """Field metadata for the 10-byte turn-based enemy record (ROM 0xC351).

    Byte semantics are from the GameAnalysis2 TMOS disassembly (authoritative).
    All 10 bytes are editable; the obscure RNG/probability bytes and the unknown
    byte 9 use the `caution` tier (editable but warned), not `danger`.
    """
    crash = "Enemy IDs 0x0B and 0x0C hard-crash the game and are never selectable."
    prob = (" Probability classes are MEDIUM-confidence; extreme values can make "
            "battles unwinnable or trivial.")
    return {
        "ep": {
            "label": "EXP reward", "byte": 0, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Experience awarded when this enemy is defeated.",
            "warning": crash, "used_by": ["levelling"],
        },
        "rupia": {
            "label": "Rupia reward", "byte": 1, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Currency dropped when this enemy is defeated.",
            "warning": crash, "used_by": ["economy"],
        },
        "bribe": {
            "label": "Bribe price", "byte": 2, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Rupia required to bribe/negotiate past this enemy. "
                           "0 = refuses all bribes.",
            "warning": crash, "used_by": ["negotiation"],
        },
        "escape_trigger": {
            "label": "Escape/Trigger chance", "byte": 3, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Probability class gating escape / action triggers. "
                           "0xFF means it (near-)never triggers.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "action_prob": {
            "label": "Special-action chance", "byte": 4, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Probability class gating this enemy's special actions.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "lineup_min": {
            "label": "Lineup minimum", "byte": 5, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Lineup-minimum probability class. Vanilla constant 1 across the roster.",
            "warning": crash + " MEDIUM-confidence; vanilla never varies this (constant 1) — "
                       "effects of changing it are unverified.",
            "used_by": ["battle RNG"],
        },
        "action_prob2": {
            "label": "Special-action chance (2)", "byte": 6, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Second action-probability byte, paired with byte 4 in the RNG gate.",
            "warning": crash + prob, "used_by": ["battle RNG"],
        },
        "hp": {
            "label": "HP (hit points)", "byte": 7, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Hit points in turn-based battle.",
            "warning": crash, "used_by": ["combat"],
        },
        "atk": {
            "label": "Attack power", "byte": 8, "tier": "safe", "control": "number",
            "valid_range": [0, 255],
            "description": "Attack value used for this enemy's special-action damage.",
            "warning": crash, "used_by": ["combat"],
        },
        "byte_9": {
            "label": "Unknown (byte 9)", "byte": 9, "tier": "caution", "control": "number",
            "valid_range": [0, 255],
            "description": "Purpose not located in the disassembly. Vanilla constant 2 across the roster.",
            "warning": crash + " Effect unknown — editing may do nothing or destabilize battles.",
            "used_by": [],
        },
    }


def build_field_metadata() -> Dict[str, Any]:
    """Return the full field-metadata document consumed by the UI."""
    return {
        "version": METADATA_VERSION,
        "generated_from": "tmos_randomizer.core.enums + curated descriptions",
        "entities": {
            "worldscreen": {
                "label": "World Screen",
                "fields": _worldscreen_fields(),
            },
            "enemy": {
                "label": "Battle Enemy",
                "fields": _enemy_fields(),
            },
        },
    }
