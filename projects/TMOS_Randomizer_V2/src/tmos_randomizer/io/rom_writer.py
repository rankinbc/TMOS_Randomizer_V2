"""ROM writer - writes modified WorldScreen data back to ROM.

Supports writing individual screens, chapters, or full world.
"""

from __future__ import annotations

from pathlib import Path
from typing import Dict, List, Optional, Union

from ..core.constants import (
    CHAPTER_BASES,
    SHOP_ITEM_TABLE,
    SHOP_ENTRY_SIZE,
    WORLDSCREEN_SIZE,
)
from ..core.shop_inventory import ChapterShopData, ShopInventory
from ..core.worldscreen import WorldScreen
from ..core.chapter import Chapter, GameWorld


class ROMWriter:
    """Writes modified TMOS data back to ROM.

    Creates a copy of the original ROM with modifications applied.
    Never modifies the original ROM file.
    """

    def __init__(self, rom_data: bytes) -> None:
        """Initialize with original ROM data.

        Args:
            rom_data: Original ROM bytes (typically from ROMReader)
        """
        self._data = bytearray(rom_data)
        self._modifications: List[tuple[int, bytes, str]] = []  # (address, old_data, description)

    @property
    def data(self) -> bytes:
        """Get current ROM data (with modifications)."""
        return bytes(self._data)

    @property
    def modification_count(self) -> int:
        """Number of modifications made."""
        return len(self._modifications)

    def write_bytes(self, address: int, data: bytes, description: str = "") -> None:
        """Write raw bytes to ROM at given file offset.

        Args:
            address: File offset (including iNES header)
            data: Bytes to write
            description: Optional description for logging
        """
        if address < 0 or address + len(data) > len(self._data):
            raise ValueError(
                f"Address 0x{address:X} + {len(data)} out of ROM bounds"
            )

        # Store original data for undo/logging
        old_data = bytes(self._data[address : address + len(data)])
        self._modifications.append((address, old_data, description))

        # Apply modification
        self._data[address : address + len(data)] = data

    def write_worldscreen(self, screen: WorldScreen) -> None:
        """Write a WorldScreen back to ROM.

        Args:
            screen: WorldScreen object to write
        """
        address = CHAPTER_BASES[screen.chapter] + (
            screen.relative_index * WORLDSCREEN_SIZE
        )
        data = screen.to_bytes()
        self.write_bytes(
            address,
            data,
            f"WorldScreen Ch{screen.chapter}:{screen.relative_index}",
        )

    def write_chapter(self, chapter: Chapter, modified_only: bool = True) -> int:
        """Write a chapter back to ROM.

        Args:
            chapter: Chapter object to write
            modified_only: If True, only write modified screens

        Returns:
            Number of screens written
        """
        written = 0
        for screen in chapter:
            if modified_only and not screen.is_modified:
                continue
            self.write_worldscreen(screen)
            written += 1
        return written

    def write_game_world(self, world: GameWorld, modified_only: bool = True) -> int:
        """Write entire game world back to ROM.

        Args:
            world: GameWorld object to write
            modified_only: If True, only write modified screens

        Returns:
            Number of screens written
        """
        written = 0
        for chapter in world:
            written += self.write_chapter(chapter, modified_only)
        return written

    def write_shop_inventory(self, inventory: ShopInventory, shop_index: int) -> None:
        """Write a single shop's inventory to ROM.

        Args:
            inventory: ShopInventory object with randomized items
            shop_index: Index of shop in the shop table (0-based)
        """
        address = SHOP_ITEM_TABLE + (shop_index * SHOP_ENTRY_SIZE)
        data = inventory.to_rom_bytes()
        self.write_bytes(
            address,
            data,
            f"Shop {shop_index} (Ch{inventory.chapter}:Scr{inventory.screen_index})",
        )

    def write_chapter_shops(
        self,
        chapter_data: ChapterShopData,
        start_index: int = 0,
    ) -> int:
        """Write all shop inventories for a chapter.

        Args:
            chapter_data: ChapterShopData with randomized shop inventories
            start_index: Starting shop index in the ROM table

        Returns:
            Number of shops written
        """
        for i, inventory in enumerate(chapter_data.inventories):
            self.write_shop_inventory(inventory, start_index + i)
        return len(chapter_data.inventories)

    def write_all_shops(
        self,
        all_chapter_data: Dict[int, ChapterShopData],
    ) -> int:
        """Write all shop inventories for all chapters.

        Args:
            all_chapter_data: Dict mapping chapter number to ChapterShopData

        Returns:
            Total number of shops written
        """
        written = 0
        shop_index = 0

        # Write shops in chapter order
        for chapter_num in sorted(all_chapter_data.keys()):
            chapter_data = all_chapter_data[chapter_num]
            count = self.write_chapter_shops(chapter_data, shop_index)
            shop_index += count
            written += count

        return written

    def save(self, output_path: Union[str, Path]) -> None:
        """Save modified ROM to file.

        Args:
            output_path: Path for output ROM file
        """
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, "wb") as f:
            f.write(self._data)

    def get_modification_log(self) -> List[dict]:
        """Get log of all modifications made.

        Returns:
            List of modification records with address, old data, description
        """
        return [
            {
                "address": f"0x{addr:X}",
                "size": len(old_data),
                "description": desc,
            }
            for addr, old_data, desc in self._modifications
        ]

    def undo_all(self) -> None:
        """Undo all modifications, restoring original ROM data."""
        # Apply modifications in reverse order
        for address, old_data, _ in reversed(self._modifications):
            self._data[address : address + len(old_data)] = old_data
        self._modifications.clear()


def patch_rom(
    original_path: Union[str, Path],
    output_path: Union[str, Path],
    world: GameWorld,
    shop_data: Optional[Dict[int, ChapterShopData]] = None,
) -> Dict[str, int]:
    """Convenience function to patch a ROM file.

    Args:
        original_path: Path to original ROM
        output_path: Path for patched ROM
        world: GameWorld with modifications
        shop_data: Optional dict mapping chapter number to ChapterShopData

    Returns:
        Dict with counts: {"screens": int, "shops": int}
    """
    with open(original_path, "rb") as f:
        rom_data = f.read()

    writer = ROMWriter(rom_data)
    screens_written = writer.write_game_world(world, modified_only=True)

    shops_written = 0
    if shop_data:
        shops_written = writer.write_all_shops(shop_data)

    writer.save(output_path)

    return {"screens": screens_written, "shops": shops_written}
