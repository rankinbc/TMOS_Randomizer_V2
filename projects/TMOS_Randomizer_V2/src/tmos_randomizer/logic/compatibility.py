"""DataPointer and ObjectSet compatibility logic.

Ensures enemies render correctly by matching ObjectSet to CHR bank.
Data sourced from: knowledge/systems/datapointer-objectset.md
"""

from __future__ import annotations

from typing import FrozenSet, Optional, Set

from ..core.worldscreen import WorldScreen


# =============================================================================
# CHR Bank Compatibility Data
# =============================================================================

# ObjectSets compatible with each CHR index
# Based on manual testing and ROM analysis
OBJECTSET_COMPATIBILITY: dict[int, FrozenSet[int]] = {
    # 0x0F - Overworld/Dungeon (most common)
    0x0F: frozenset({
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
        0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x12, 0x13, 0x14,
        0x36, 0x37, 0xA8, 0xA9, 0xAA, 0xAC, 0xAD, 0xAF, 0xB3, 0xB7
    }),

    # 0x13 - Town interiors
    0x13: frozenset(range(0x16, 0x32)),

    # 0x16 - Maze areas
    0x16: frozenset({
        0x00, 0x11, 0x12, 0x34, 0x44, 0x46, 0x77, 0x84, 0x85, 0x86,
        0xA0, 0xA1, 0xA7, 0xAE, 0xB9, 0xBB, 0xDC, 0xE2, 0xE4, 0xE8, 0xFA
    }),

    # 0x17 - Underwater/Cave
    0x17: frozenset({
        0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
        0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x15, 0x37, 0x39, 0x3B, 0x3D,
        0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x47, 0x73, 0x78, 0x79,
        0x7A, 0x7B, 0x7C, 0x7D
    }),

    # 0x11 - Title/Special
    0x11: frozenset({
        0x00, 0x11, 0x12, 0x34, 0x44, 0x46, 0x4D, 0x77, 0x84, 0x85,
        0x86, 0x9E, 0xA1, 0xA7, 0xAE, 0xB9, 0xBB, 0xC0, 0xCC, 0xDC,
        0xE0, 0xE2, 0xE4, 0xE8, 0xFA
    }),

    # 0x0E - Desert
    0x0E: frozenset({
        0x11, 0x12, 0x17, 0x44, 0x46, 0x77, 0x84, 0x85, 0x86, 0x9E,
        0xA0, 0xAE
    }),

    # 0x18 - Boss areas
    0x18: frozenset({
        0x02, 0x03, 0x04, 0x07, 0x0B, 0x0C, 0x0F, 0x10, 0x3B, 0x41,
        0x42, 0x43, 0x45, 0x47, 0x4D, 0x72, 0x79, 0x7A, 0x7E, 0x83,
        0x9E, 0xA6, 0xAF, 0xB3, 0xB5, 0xB8, 0xC1, 0xC2, 0xC9, 0xCC
    }),
}

# Default ObjectSet for unknown CHR indices
DEFAULT_COMPATIBLE_OBJECTSETS: FrozenSet[int] = frozenset({0x00})

# Area type names for CHR indices
CHR_AREA_NAMES: dict[int, str] = {
    0x0F: "Overworld/Dungeon",
    0x13: "Town Interior",
    0x16: "Maze",
    0x17: "Underwater/Cave",
    0x11: "Special",
    0x0E: "Desert",
    0x18: "Boss",
}


# =============================================================================
# Core Functions
# =============================================================================

def get_chr_index(datapointer: int) -> int:
    """Extract CHR bank index from DataPointer (bits 0-5).

    Args:
        datapointer: DataPointer byte value (0-255)

    Returns:
        CHR bank index (0-63)
    """
    return datapointer & 0x3F


def get_tile_banks(datapointer: int) -> tuple[int, int]:
    """Extract tile bank selection from DataPointer (bits 7-6).

    Args:
        datapointer: DataPointer byte value

    Returns:
        Tuple of (top_bank, bottom_bank) where each is 0 or 1
    """
    bits = (datapointer >> 6) & 0x03
    top_bank = (bits >> 1) & 1
    bottom_bank = bits & 1
    return (top_bank, bottom_bank)


def get_all_valid_datapointers(chr_index: int) -> list[int]:
    """Get all 4 valid DataPointer values for a CHR index.

    Each CHR index has 4 valid DataPointers (varying tile bank bits).

    Args:
        chr_index: CHR bank index (0-63)

    Returns:
        List of 4 DataPointer values

    Example:
        >>> get_all_valid_datapointers(0x0F)
        [0x0F, 0x4F, 0x8F, 0xCF]
    """
    return [chr_index + (i * 0x40) for i in range(4)]


def get_compatible_objectsets(datapointer: int) -> FrozenSet[int]:
    """Get all ObjectSets compatible with a DataPointer.

    Args:
        datapointer: DataPointer byte value

    Returns:
        FrozenSet of compatible ObjectSet IDs
    """
    chr_index = get_chr_index(datapointer)
    return OBJECTSET_COMPATIBILITY.get(chr_index, DEFAULT_COMPATIBLE_OBJECTSETS)


def get_area_name(datapointer: int) -> str:
    """Get human-readable area name for a DataPointer.

    Args:
        datapointer: DataPointer byte value

    Returns:
        Area type name (e.g., "Overworld/Dungeon")
    """
    chr_index = get_chr_index(datapointer)
    return CHR_AREA_NAMES.get(chr_index, f"Unknown (0x{chr_index:02X})")


# =============================================================================
# Validation Functions
# =============================================================================

def is_objectset_compatible(datapointer: int, objectset: int) -> bool:
    """Check if ObjectSet is valid for DataPointer.

    Args:
        datapointer: DataPointer byte value
        objectset: ObjectSet ID to check

    Returns:
        True if ObjectSet is compatible with the CHR bank
    """
    compatible = get_compatible_objectsets(datapointer)
    return objectset in compatible


def can_swap_screens(screen_a: WorldScreen, screen_b: WorldScreen) -> bool:
    """Check if two screens can be swapped without CHR corruption.

    Screens can only be safely swapped if their DataPointer CHR indices match.

    Args:
        screen_a: First WorldScreen
        screen_b: Second WorldScreen

    Returns:
        True if screens have matching CHR indices
    """
    return get_chr_index(screen_a.datapointer) == get_chr_index(screen_b.datapointer)


def can_swap_datapointers(dp_a: int, dp_b: int) -> bool:
    """Check if two DataPointer values have matching CHR indices.

    Args:
        dp_a: First DataPointer
        dp_b: Second DataPointer

    Returns:
        True if CHR indices match
    """
    return get_chr_index(dp_a) == get_chr_index(dp_b)


def validate_screen_compatibility(screen: WorldScreen) -> tuple[bool, Optional[str]]:
    """Validate that a screen's ObjectSet is compatible with its DataPointer.

    Args:
        screen: WorldScreen to validate

    Returns:
        Tuple of (is_valid, error_message or None)
    """
    if is_objectset_compatible(screen.datapointer, screen.objectset):
        return (True, None)

    chr_index = get_chr_index(screen.datapointer)
    compatible = get_compatible_objectsets(screen.datapointer)
    return (
        False,
        f"ObjectSet 0x{screen.objectset:02X} incompatible with "
        f"CHR index 0x{chr_index:02X}. Valid: {sorted(compatible)[:5]}..."
    )


# =============================================================================
# Randomization Helpers
# =============================================================================

def find_compatible_objectsets_for_area(
    datapointer: int,
    exclude: Optional[Set[int]] = None,
) -> list[int]:
    """Get list of compatible ObjectSets, optionally excluding some.

    Useful for randomization when certain ObjectSets shouldn't be used.

    Args:
        datapointer: DataPointer byte value
        exclude: Optional set of ObjectSets to exclude

    Returns:
        Sorted list of compatible ObjectSet IDs
    """
    compatible = get_compatible_objectsets(datapointer)
    if exclude:
        compatible = compatible - exclude
    return sorted(compatible)


def get_shared_compatible_objectsets(
    datapointer_a: int,
    datapointer_b: int,
) -> FrozenSet[int]:
    """Get ObjectSets compatible with both DataPointers.

    Useful when wanting to use same enemies across different areas.

    Args:
        datapointer_a: First DataPointer
        datapointer_b: Second DataPointer

    Returns:
        FrozenSet of ObjectSets valid for both
    """
    compat_a = get_compatible_objectsets(datapointer_a)
    compat_b = get_compatible_objectsets(datapointer_b)
    return compat_a & compat_b


def suggest_datapointer_for_objectset(objectset: int) -> list[int]:
    """Find DataPointers that support a given ObjectSet.

    Args:
        objectset: ObjectSet ID to find compatible DataPointers for

    Returns:
        List of CHR indices that support this ObjectSet
    """
    compatible_chr = []
    for chr_index, objectsets in OBJECTSET_COMPATIBILITY.items():
        if objectset in objectsets:
            compatible_chr.append(chr_index)
    return sorted(compatible_chr)


# =============================================================================
# ObjectSet Categories (for randomization pools)
# =============================================================================

# Enemy ObjectSets - safe to randomize
ENEMY_OBJECTSETS: FrozenSet[int] = frozenset(
    set(range(0x03, 0x10)) |  # Standard enemies
    set(range(0x35, 0x40))    # Enemy variants
)

# Town/NPC ObjectSets - do NOT randomize
TOWN_NPC_OBJECTSETS: FrozenSet[int] = frozenset(
    set(range(0x16, 0x2E)) |  # Town NPCs
    {0x33}
)

# Dungeon/Maze ObjectSets - randomize with care
DUNGEON_OBJECTSETS: FrozenSet[int] = frozenset({0x01, 0x02, 0x10, 0x13, 0x14})


def categorize_objectset(objectset: int) -> str:
    """Categorize an ObjectSet for randomization decisions.

    Args:
        objectset: ObjectSet ID

    Returns:
        Category name: "enemy", "town_npc", "dungeon", or "other"
    """
    if objectset in ENEMY_OBJECTSETS:
        return "enemy"
    if objectset in TOWN_NPC_OBJECTSETS:
        return "town_npc"
    if objectset in DUNGEON_OBJECTSETS:
        return "dungeon"
    return "other"
