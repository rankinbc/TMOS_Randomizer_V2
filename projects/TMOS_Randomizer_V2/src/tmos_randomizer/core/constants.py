"""ROM addresses and chapter offsets for TMOS.

Data sourced from knowledge base:
- knowledge/memory/rom-map.md
- knowledge/systems/chapter-indexing.md
- knowledge/structures/worldscreen.md
"""

from typing import Tuple

# =============================================================================
# WorldScreen Constants
# =============================================================================

WORLDSCREEN_SIZE = 16  # bytes per screen

# ROM base addresses for WorldScreen data (per chapter)
# Source: knowledge/structures/worldscreen.md
CHAPTER_BASES: dict[int, int] = {
    1: 0x039695,  # Chapter 1: 131 screens
    2: 0x039EC5,  # Chapter 2: 137 screens
    3: 0x03A755,  # Chapter 3: 153 screens
    4: 0x03B0E5,  # Chapter 4: 164 screens
    5: 0x03BB25,  # Chapter 5: 154 screens
}

# Chapter offsets for global <-> relative index conversion
# (global_start, screen_count)
# Source: knowledge/systems/chapter-indexing.md
CHAPTER_OFFSETS: dict[int, Tuple[int, int]] = {
    1: (0, 131),
    2: (131, 137),
    3: (268, 153),
    4: (421, 164),
    5: (585, 154),
}

# Total screen count
TOTAL_SCREENS = sum(count for _, count in CHAPTER_OFFSETS.values())  # 739

# =============================================================================
# Inventory-Pickup Tables (Bank 3) — corrected 2026-04-16
#
# CORRECTION: previously labeled SHOP_*. Per RE answer
# (TMOS_AI/docs/human/items-economy-re-answers.md), these tables live in
# Bank 3 (NOT Bank 6) and are used by the chest/drop pickup handler at
# Bank 3 $94B0, NOT by any shop code. The data at 0xD544 is an inventory
# CAP table, not a shop slot table. Real shop data: flat tables in Bank 1
# ($94ED/$94FD) — see the Shop Tables section below (resolved 2026-07-02;
# the earlier "undecoded Bank 2 bytecode" theory was disproven).
#
# NES MMC1 PRG bank size = 16 KB (0x4000), NOT 8 KB. The original comment
# claimed 8 KB but the math (16 + 6*0x2000) coincidentally landed in Bank 3.
# =============================================================================

# Bank 3 starts at file 0x0C010 = iNES header (16) + 3 banks * 0x4000.
# Bank 3 is the RPG battle engine.
BANK_3_FILE_OFFSET = 0xC010

# Bank 3 $9524 — 16-byte randomization indexer for inv_pickup_handler.
# 4 groups x 4 selectors. NOT a shop-id-to-slot map.
# File offset = 0xC010 + (0x9524 - 0x8000) = 0xD534
INV_PICKUP_INDEXER = 0xD534

# Bank 3 $9534 — 8-entry x 4-byte inventory cap table.
# Each entry: [ram_addr_lo, 0x03, max_cap, slot_idx].
# Byte 0+1 form a $03xx RAM pointer; byte 2 is the cap; byte 3 is a
# party-slot mirror index. NOT shop slots.
# File offset = 0xC010 + (0x9534 - 0x8000) = 0xD544
INV_CAP_TABLE = 0xD544

# Bank 3 $95D0 — 12 bytes immediately after inv_pickup_handler.
# Purpose unknown (no readers found in xref). Was misnamed SHOP_PRICE_TABLE.
INV_PICKUP_AUX_DATA = 0xD5E0

# Shop Content byte ranges (from WorldScreen byte 2). These are the actual
# in-game shop entry points; shop id = Content & 0x1F into SHOP_POINTER_TABLE.
GENERAL_SHOP_CONTENT_MIN = 0x60
GENERAL_SHOP_CONTENT_MAX = 0x66
MAGIC_SHOP_CONTENT_MIN = 0x75
MAGIC_SHOP_CONTENT_MAX = 0x79

# =============================================================================
# Shop Tables (Bank 1) — resolved 2026-07-02
#
# Source: RETMOS REVERSE.md "Shop Tables WRITE Spec"; byte-verified against
# TMOS_ORIGINAL.nes. Authoritative doc: knowledge/systems/shops-and-economy.md
# =============================================================================

# Bank 1 starts at file 0x04010 = iNES header (16) + 1 bank * 0x4000.
BANK_1_FILE_OFFSET = 0x04010

# Bank 1 $94ED — shop pointer table: 8 x u16 LE (CPU addrs in $8000-$BFFF),
# indexed by shop id ($04E1 = Content & 0x1F). Repointable.
SHOP_POINTER_TABLE = 0x054FD   # BANK_1_FILE_OFFSET + (0x94ED - 0x8000)
SHOP_POINTER_COUNT = 8

# Bank 1 $94FD — shop data: 8 shops x 4 slots x [code, price]. Fixed slot
# count, no sentinel.
SHOP_DATA_TABLE = 0x0550D      # BANK_1_FILE_OFFSET + (0x94FD - 0x8000)
SHOP_COUNT = 8
SHOP_SLOTS_PER_SHOP = 4
SHOP_SLOT_SIZE = 2             # [code, price]

# Slot code legality: hi-nibble must be 1, 3, or 5 (bank 1 $8746 state-command
# namespace). Other hi4 values are password opcodes — writing them into shop
# slots lets a purchase mutate arbitrary game state.
SHOP_CODE_LEGAL_HI4 = frozenset({0x1, 0x3, 0x5})

# Codes appearing in vanilla shops. $10/$11 have an unresolved RAM-target
# conflict ($0300 vs $0308 door keys) — do not emit NEW $10/$11 slots until
# emulator-verified.
SHOP_CODES_VERIFIED = frozenset({0x33, 0x34, 0x51, 0x52, 0x53, 0x58})
SHOP_CODES_UNVERIFIED = frozenset({0x10, 0x11})

# Bank 1 $8AAC — magic-shop base prices: 11 bytes, indexed by code lo4,
# charged as base * (chapter + 1). Magic shops IGNORE the slot price byte.
MAGIC_SHOP_BASE_PRICES = 0x04ABC   # BANK_1_FILE_OFFSET + (0x8AAC - 0x8000)
MAGIC_SHOP_BASE_PRICE_COUNT = 11

# Gold is 3-digit BCD: price * max quantity must stay <= 999.
GOLD_MAX = 999

# Bank 1 free space (zero-filled) usable for repointed/expanded shop data.
BANK_1_FREE_SPACE_START = 0x05741  # CPU $9731
BANK_1_FREE_SPACE_END = 0x05910    # CPU $9900 (exclusive), 463 bytes

# =============================================================================
# Warp / Time-Door Destination Table (Bank 6) — resolved 2026-07-02
#
# Bank 6 $98C0: 5 chapter-groups x 8 door sub-indices -> destination screen
# index. THE only present<->past pairing mechanism (pure data). Randomizer
# must patch this table when moving/re-indexing any destination screen.
# Authoritative doc: knowledge/systems/screen-relocation-constraints.md
# =============================================================================

BANK_6_FILE_OFFSET = 0x18010

WARP_DEST_TABLE = 0x198D0      # BANK_6_FILE_OFFSET + (0x98C0 - 0x8000)
WARP_DEST_GROUPS = 5
WARP_DEST_SLOTS_PER_GROUP = 8

# Bank 6 $90D1 secret event: `CMP #$1A` — requires screen 0x1A. The immediate
# operand lives at this file offset; pin screen 0x1A or patch this byte.
SECRET_EVENT_SCREEN_IMM = 0x190E2
SECRET_EVENT_SCREEN = 0x1A

# Chapter start screens (warp data $BB1F record 0). Password system encodes
# these — pin them (do not relocate).
CHAPTER_START_SCREENS = (4, 9, 14, 19, 24)

# Bank 4 $8136 — chapter start/respawn screen table, loaded at EVERY
# level-start setup ($E282). Screen indices per chapter. If the randomizer
# moves these screens it must patch this table or respawn breaks.
CHAPTER_RESPAWN_TABLE = 0x10146    # BANK_4 0x10010 + (0x8136 - 0x8000)
CHAPTER_RESPAWN_SCREENS = (0x63, 0x09, 0x01, 0x26, 0x20)

# Bank 1 $8E92 — chapter-intro display screens, 2 sets of 5 (toggle $049F).
# Display-only during intro mode; keep renderable, patch if moved.
INTRO_SCREEN_TABLE = 0x04EA2       # BANK_1_FILE_OFFSET + (0x8E92 - 0x8000)
INTRO_SCREEN_COUNT = 10

# Inventory-cap table layout
INV_CAP_SLOT_SIZE = 4
INV_CAP_SLOT_COUNT = 8


# =============================================================================
# ObjectSet Pointer Tables
# =============================================================================

# Per-chapter ObjectSet pointer tables
# Source: knowledge/systems/chapter-indexing.md
OBJECTSET_PTR_TABLES: dict[int, int] = {
    1: 0x38933,
    2: 0x389A9,
    3: 0x38A1F,
    4: 0x38A95,
    5: 0x38B0B,
}

OBJECTSET_BASE = 0x37000  # Base address for ObjectSet data

# =============================================================================
# TileSection Constants
# =============================================================================

# TileSection data start
# Source: knowledge/memory/rom-map.md
TILESECTION_START = 0x03C4C7
TILESECTION_SIZE = 32  # bytes per TileSection (4 rows x 8 tiles)
TILESECTION_OVERLAP_OFFSET = 8  # TileSections are 8 bytes apart (not 32)
TILESECTION_COUNT = 471

# =============================================================================
# Tile Table Constants
# =============================================================================

# Tile Table - 256 tiles, each 4 bytes (2x2 MiniTile IDs)
# Source: knowledge/structures/tilesection.md
TILE_TABLE_ADDR = 0x011B0B
TILE_COUNT = 256
TILE_SIZE = 4  # bytes per tile (4 MiniTile IDs: TL, TR, BL, BR)

# =============================================================================
# Encounter Tables
# =============================================================================

# Random encounter group tables (per chapter)
# Source: knowledge/memory/rom-map.md
ENCOUNTER_GROUP_TABLES: dict[int, int] = {
    1: 0x00C02A,
    2: 0x00C058,
    3: 0x00C089,
    4: 0x00C0BD,
    5: 0x00C100,
}

# Random encounter lineup tables (per chapter)
ENCOUNTER_LINEUP_TABLES: dict[int, int] = {
    1: 0x00C211,
    2: 0x00C241,
    3: 0x00C271,
    4: 0x00C2C1,
    5: 0x00C301,
}

# EXP tier lookup table (action-mode overworld kills).
# Stride-2: game reads rom[EXP_TABLE_OFFSET + index * EXP_TABLE_STRIDE].
# Indices 0-6 are the seven main tiers used by Ch1-2; 7-9 are special tiers.
# Indices 10+ map to 0 in vanilla and represent "no EXP" / encounter-only.
# Source: GameAnalysis2 raw_research/exp_tables.md (ROM_VERIFIED).
EXP_TABLE_OFFSET = 0x174AA
EXP_TABLE_STRIDE = 2
EXP_TABLE_COUNT = 10

# =============================================================================
# World Enemy Set Pointers
# =============================================================================

# Per-chapter enemy set pointers
# Source: knowledge/memory/rom-map.md
WORLD_ENEMY_SET_PTRS: dict[int, int] = {
    1: 0x3701E,
    2: 0x37020,
    3: 0x37022,
    4: 0x37024,
    5: 0x37026,
}

# =============================================================================
# Special Navigation Values
# =============================================================================

NAV_BUILDING_ENTRANCE = 0xFE  # Walk up triggers Content behavior
NAV_BLOCKED = 0xFF  # Cannot exit in this direction

# =============================================================================
# DataPointer / CHR Bank Constants
# =============================================================================

# Extract CHR bank index from DataPointer (bits 0-5)
CHR_INDEX_MASK = 0x3F

# =============================================================================
# ObjectSet Compatibility
# =============================================================================

# Mapping of CHR bank index to compatible ObjectSet IDs
# Source: knowledge/systems/datapointer-objectset.md
# ObjectSets must match the screen's CHR bank or graphics will corrupt
OBJECTSET_COMPATIBILITY: dict[int, set[int]] = {
    # 0x0F - Overworld/Dungeon (Primary) - 79 screens in Chapter 1
    0x0F: {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
        0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x12, 0x13, 0x14,
        0x36, 0x37, 0xA8, 0xA9, 0xAA, 0xAC, 0xAD, 0xAF, 0xB3, 0xB7,
    },
    # 0x13 - Town Interiors - 27 screens (shops, houses, indoor areas)
    0x13: set(range(0x16, 0x32)),
    # 0x16 - Maze - 7 screens (labyrinth areas)
    0x16: {
        0x00, 0x11, 0x12, 0x34, 0x44, 0x46, 0x77, 0x84, 0x85, 0x86,
        0xA0, 0xA1, 0xA7, 0xAE, 0xB9, 0xBB, 0xDC, 0xE2, 0xE4, 0xE8, 0xFA,
    },
    # 0x17 - Underwater/Cave - 18 screens (water and cave areas)
    0x17: {
        0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
        0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x15, 0x37, 0x39, 0x3B, 0x3D,
        0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x47, 0x73, 0x78, 0x79,
        0x7A, 0x7B, 0x7C, 0x7D,
    },
    # 0x11 - Title/Special - 6 screens (title screen, special areas)
    0x11: {
        0x00, 0x11, 0x12, 0x34, 0x44, 0x46, 0x4D, 0x77, 0x84, 0x85,
        0x86, 0x9E, 0xA1, 0xA7, 0xAE, 0xB9, 0xBB, 0xC0, 0xCC, 0xDC,
        0xE0, 0xE2, 0xE4, 0xE8, 0xFA,
    },
    # 0x0E - Desert - 3 screens (desert areas)
    0x0E: {
        0x11, 0x12, 0x17, 0x44, 0x46, 0x77, 0x84, 0x85, 0x86, 0x9E,
        0xA0, 0xAE,
    },
    # 0x18 - Boss Areas - 1 screen (boss encounters)
    0x18: {
        0x02, 0x03, 0x04, 0x07, 0x0B, 0x0C, 0x0F, 0x10, 0x3B, 0x41,
        0x42, 0x43, 0x45, 0x47, 0x4D, 0x72, 0x79, 0x7A, 0x7E, 0x83,
        0x9E, 0xA6, 0xAF, 0xB3, 0xB5, 0xB8, 0xC1, 0xC2, 0xC9, 0xCC,
    },
}


def get_compatible_objectsets(datapointer: int) -> set[int]:
    """Get all ObjectSets compatible with this DataPointer.

    Args:
        datapointer: DataPointer byte value

    Returns:
        Set of compatible ObjectSet IDs, or {0x00} if unknown
    """
    chr_index = get_chr_index(datapointer)
    return OBJECTSET_COMPATIBILITY.get(chr_index, {0x00})


def validate_objectset_compatibility(datapointer: int, objectset: int) -> bool:
    """Check if ObjectSet is valid for DataPointer.

    Args:
        datapointer: DataPointer byte value
        objectset: ObjectSet ID to validate

    Returns:
        True if compatible, False otherwise
    """
    compatible = get_compatible_objectsets(datapointer)
    return objectset in compatible

# =============================================================================
# Screen RAM Mirror
# =============================================================================

# When a screen is loaded, its 16 bytes are copied to RAM
# Source: knowledge/structures/worldscreen.md
WORLDSCREEN_RAM_MIRROR = 0x00B0  # $00B0-$00BF

# Current chapter tracking
CHAPTER_RAM = 0x0082  # Current chapter (0-4, add 1 for display)
CURRENT_SCREEN_RAM = 0x00AB  # Current screen index (chapter-relative)
PREVIOUS_SCREEN_RAM = 0x0094  # Previous screen index

# =============================================================================
# Helper Functions
# =============================================================================


def relative_to_global(chapter: int, relative_index: int) -> int:
    """Convert chapter-relative screen index to global index.

    Args:
        chapter: Chapter number (1-5)
        relative_index: Screen index within the chapter

    Returns:
        Global screen index (0-738)

    Raises:
        ValueError: If chapter is invalid or index exceeds chapter count
    """
    if chapter not in CHAPTER_OFFSETS:
        raise ValueError(f"Invalid chapter {chapter}, must be 1-5")

    global_start, count = CHAPTER_OFFSETS[chapter]
    if relative_index < 0 or relative_index >= count:
        raise ValueError(
            f"Index {relative_index} out of range for chapter {chapter} "
            f"(max {count - 1})"
        )

    return global_start + relative_index


def global_to_relative(global_index: int) -> Tuple[int, int]:
    """Convert global screen index to (chapter, relative_index).

    Args:
        global_index: Global screen index (0-738)

    Returns:
        Tuple of (chapter_number, relative_index)

    Raises:
        ValueError: If global_index is out of range
    """
    for chapter, (start, count) in CHAPTER_OFFSETS.items():
        if start <= global_index < start + count:
            return (chapter, global_index - start)

    raise ValueError(f"Invalid global index {global_index} (max {TOTAL_SCREENS - 1})")


def get_worldscreen_address(chapter: int, relative_index: int) -> int:
    """Get ROM address for a WorldScreen.

    Args:
        chapter: Chapter number (1-5)
        relative_index: Screen index within the chapter

    Returns:
        ROM file offset for the WorldScreen data

    Raises:
        ValueError: If chapter is invalid or index exceeds chapter count
    """
    if chapter not in CHAPTER_BASES:
        raise ValueError(f"Invalid chapter {chapter}, must be 1-5")

    _, count = CHAPTER_OFFSETS[chapter]
    if relative_index < 0 or relative_index >= count:
        raise ValueError(
            f"Index {relative_index} out of range for chapter {chapter} "
            f"(max {count - 1})"
        )

    return CHAPTER_BASES[chapter] + (relative_index * WORLDSCREEN_SIZE)


def get_chr_index(datapointer: int) -> int:
    """Extract CHR bank index from DataPointer (bits 0-5).

    Args:
        datapointer: DataPointer byte value

    Returns:
        CHR bank index (0-63)
    """
    return datapointer & CHR_INDEX_MASK


def get_all_valid_datapointers(chr_index: int) -> list[int]:
    """Get all 4 valid DataPointer values for a CHR index.

    The top 2 bits of DataPointer control TileSection bank selection,
    so each CHR index has 4 possible DataPointer values.

    Args:
        chr_index: CHR bank index (0-63)

    Returns:
        List of 4 DataPointer values with same CHR index

    Example:
        >>> get_all_valid_datapointers(0x0F)
        [0x0F, 0x4F, 0x8F, 0xCF]
    """
    return [chr_index + (i * 0x40) for i in range(4)]
