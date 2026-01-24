"""WorldScreen data model - represents a single screen in the game world.

Each WorldScreen is 16 bytes in ROM. Screens form a graph structure
connected via directional pointers.

Data sourced from: knowledge/structures/worldscreen.md
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional

from .enums import (
    SectionType,
    ContentType,
    EventType,
    SpritesColor,
    PARENTWORLD_TO_SECTION,
    BOSS_CONTENT_RANGE,
    SHOP_CONTENT_RANGE,
    NPC_CONTENT_RANGE,
    HOTEL_CONTENT_RANGE,
    ENEMY_DOOR_PAIRS,
    NAV_BUILDING_ENTRANCE,
    NAV_BLOCKED,
    is_stairway_event,
)


@dataclass
class WorldScreen:
    """Represents a single screen in the game world.

    Attributes:
        global_index: Global screen index (0-738)
        chapter: Chapter number (1-5)
        relative_index: Screen index within chapter

        # 16 ROM bytes
        parent_world: Music/section ID (byte 0)
        ambient_sound: Ambient sound effect ID (byte 1)
        content: Building type, boss stage, etc. (byte 2)
        objectset: Enemy spawn configuration (byte 3)
        screen_index_right: Screen when walking right (byte 4)
        screen_index_left: Screen when walking left (byte 5)
        screen_index_down: Screen when walking down (byte 6)
        screen_index_up: Screen when walking up (byte 7)
        datapointer: Tile bank selector (byte 8)
        exit_position: Player spawn position (byte 9)
        top_tiles: TileSection index for top 4 rows (byte 10)
        bottom_tiles: TileSection index for bottom 3 rows (byte 11)
        worldscreen_color: Background color palette (byte 12)
        sprites_color: Sprite color palette (byte 13)
        unknown: Unknown purpose (byte 14)
        event: Dialog/event trigger ID (byte 15)
    """

    # Identity
    global_index: int
    chapter: int
    relative_index: int

    # ROM data (16 bytes)
    parent_world: int = 0
    ambient_sound: int = 0
    content: int = 0
    objectset: int = 0
    screen_index_right: int = 0xFF
    screen_index_left: int = 0xFF
    screen_index_down: int = 0xFF
    screen_index_up: int = 0xFF
    datapointer: int = 0
    exit_position: int = 0
    top_tiles: int = 0
    bottom_tiles: int = 0
    worldscreen_color: int = 0
    sprites_color: int = 0
    unknown: int = 0
    event: int = 0

    # Metadata (not from ROM, for randomizer tracking)
    _modified: bool = field(default=False, repr=False)
    _original_bytes: Optional[bytes] = field(default=None, repr=False)

    # =========================================================================
    # Serialization (for UI consumption)
    # =========================================================================

    def to_dict(self) -> dict[str, Any]:
        """Serialize to dictionary for JSON/UI consumption."""
        return {
            "global_index": self.global_index,
            "chapter": self.chapter,
            "relative_index": self.relative_index,
            "parent_world": self.parent_world,
            "ambient_sound": self.ambient_sound,
            "content": self.content,
            "objectset": self.objectset,
            "screen_index_right": self.screen_index_right,
            "screen_index_left": self.screen_index_left,
            "screen_index_down": self.screen_index_down,
            "screen_index_up": self.screen_index_up,
            "datapointer": self.datapointer,
            "exit_position": self.exit_position,
            "top_tiles": self.top_tiles,
            "bottom_tiles": self.bottom_tiles,
            "worldscreen_color": self.worldscreen_color,
            "sprites_color": self.sprites_color,
            "unknown": self.unknown,
            "event": self.event,
            # Computed properties for UI
            "section_type": self.section_type.name,
            "is_town": self.is_town,
            "is_boss_screen": self.is_boss_screen,
            "has_building_entrance": self.has_building_entrance,
            "is_stairway": self.is_stairway,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> WorldScreen:
        """Deserialize from dictionary."""
        return cls(
            global_index=data["global_index"],
            chapter=data["chapter"],
            relative_index=data["relative_index"],
            parent_world=data["parent_world"],
            ambient_sound=data["ambient_sound"],
            content=data["content"],
            objectset=data["objectset"],
            screen_index_right=data["screen_index_right"],
            screen_index_left=data["screen_index_left"],
            screen_index_down=data["screen_index_down"],
            screen_index_up=data["screen_index_up"],
            datapointer=data["datapointer"],
            exit_position=data["exit_position"],
            top_tiles=data["top_tiles"],
            bottom_tiles=data["bottom_tiles"],
            worldscreen_color=data["worldscreen_color"],
            sprites_color=data["sprites_color"],
            unknown=data["unknown"],
            event=data["event"],
        )

    def to_bytes(self) -> bytes:
        """Convert to 16-byte ROM representation."""
        return bytes([
            self.parent_world,
            self.ambient_sound,
            self.content,
            self.objectset,
            self.screen_index_right,
            self.screen_index_left,
            self.screen_index_down,
            self.screen_index_up,
            self.datapointer,
            self.exit_position,
            self.top_tiles,
            self.bottom_tiles,
            self.worldscreen_color,
            self.sprites_color,
            self.unknown,
            self.event,
        ])

    @classmethod
    def from_bytes(
        cls,
        data: bytes,
        global_index: int,
        chapter: int,
        relative_index: int,
    ) -> WorldScreen:
        """Create from 16-byte ROM data."""
        if len(data) != 16:
            raise ValueError(f"Expected 16 bytes, got {len(data)}")

        screen = cls(
            global_index=global_index,
            chapter=chapter,
            relative_index=relative_index,
            parent_world=data[0],
            ambient_sound=data[1],
            content=data[2],
            objectset=data[3],
            screen_index_right=data[4],
            screen_index_left=data[5],
            screen_index_down=data[6],
            screen_index_up=data[7],
            datapointer=data[8],
            exit_position=data[9],
            top_tiles=data[10],
            bottom_tiles=data[11],
            worldscreen_color=data[12],
            sprites_color=data[13],
            unknown=data[14],
            event=data[15],
        )
        screen._original_bytes = data
        return screen

    # =========================================================================
    # Screen Type Detection Properties
    # =========================================================================

    @property
    def section_type(self) -> SectionType:
        """Get the section type based on ParentWorld."""
        return PARENTWORLD_TO_SECTION.get(self.parent_world, SectionType.UNKNOWN)

    @property
    def is_town(self) -> bool:
        """Check if this is a town screen (SpritesColor == 0x12)."""
        return self.sprites_color == SpritesColor.TOWN

    @property
    def is_boss_screen(self) -> bool:
        """Check if this is a boss encounter screen (Content 0x21-0x2A)."""
        return self.content in BOSS_CONTENT_RANGE

    @property
    def is_victory_screen(self) -> bool:
        """Check if this is a victory screen (Content == 0x2B)."""
        return self.content == ContentType.VICTORY

    @property
    def is_wizard_screen(self) -> bool:
        """Check if this triggers a wizard battle (Content == 0x01)."""
        return self.content == ContentType.WIZARD_BATTLE

    @property
    def is_shop(self) -> bool:
        """Check if this is a shop screen."""
        return self.content in SHOP_CONTENT_RANGE

    @property
    def is_mosque(self) -> bool:
        """Check if this is a mosque."""
        return self.content == ContentType.MOSQUE

    @property
    def has_time_door(self) -> bool:
        """Check if this screen has a time door (Content == 0xC0)."""
        return self.content == ContentType.TIME_DOOR

    @property
    def is_stairway(self) -> bool:
        """Check if this is a stairway screen (Event == 0x40)."""
        return is_stairway_event(self.event)

    @property
    def stairway_destination(self) -> Optional[int]:
        """Get stairway destination screen (chapter-relative), or None."""
        if self.is_stairway:
            return self.content
        return None

    @property
    def has_building_entrance(self) -> bool:
        """Check if any direction leads to a building entrance (0xFE)."""
        return (
            self.screen_index_up == NAV_BUILDING_ENTRANCE
            or self.screen_index_down == NAV_BUILDING_ENTRANCE
            or self.screen_index_left == NAV_BUILDING_ENTRANCE
            or self.screen_index_right == NAV_BUILDING_ENTRANCE
        )

    @property
    def is_enemy_door_screen(self) -> bool:
        """Check if this is an enemy door screen."""
        return (self.parent_world, self.objectset) in ENEMY_DOOR_PAIRS

    @property
    def has_inaccessible_content(self) -> bool:
        """Check if Content requires Oprin spell to access.

        Content > 0x34 AND not using Content for building entrance
        AND not a stairway.
        """
        return (
            self.content > 0x34
            and self.content != 0xFF
            and not self.is_stairway
            and not self.has_building_entrance
        )

    @property
    def has_oprin_door(self) -> bool:
        """Check if this screen has an Oprin-revealed door."""
        return self.event == EventType.OPRIN_DOOR or self.has_inaccessible_content

    # =========================================================================
    # Navigation Helpers
    # =========================================================================

    def get_neighbor(self, direction: str) -> Optional[int]:
        """Get neighbor screen index for a direction.

        Args:
            direction: One of 'up', 'down', 'left', 'right'

        Returns:
            Screen index (chapter-relative), or None if blocked/building
        """
        nav_map = {
            "up": self.screen_index_up,
            "down": self.screen_index_down,
            "left": self.screen_index_left,
            "right": self.screen_index_right,
        }
        value = nav_map.get(direction.lower())
        if value is None or value in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
            return None
        return value

    def get_all_neighbors(self) -> dict[str, Optional[int]]:
        """Get all neighbor screen indices.

        Returns:
            Dict mapping direction to screen index (or None)
        """
        return {
            "up": self.get_neighbor("up"),
            "down": self.get_neighbor("down"),
            "left": self.get_neighbor("left"),
            "right": self.get_neighbor("right"),
        }

    def get_connected_screens(self) -> list[int]:
        """Get list of all connected screen indices (chapter-relative)."""
        return [idx for idx in self.get_all_neighbors().values() if idx is not None]

    def is_blocked(self, direction: str) -> bool:
        """Check if a direction is blocked (0xFF)."""
        nav_map = {
            "up": self.screen_index_up,
            "down": self.screen_index_down,
            "left": self.screen_index_left,
            "right": self.screen_index_right,
        }
        return nav_map.get(direction.lower()) == NAV_BLOCKED

    def is_building_entrance(self, direction: str) -> bool:
        """Check if a direction is a building entrance (0xFE)."""
        nav_map = {
            "up": self.screen_index_up,
            "down": self.screen_index_down,
            "left": self.screen_index_left,
            "right": self.screen_index_right,
        }
        return nav_map.get(direction.lower()) == NAV_BUILDING_ENTRANCE

    # =========================================================================
    # CHR/DataPointer Helpers
    # =========================================================================

    @property
    def chr_index(self) -> int:
        """Extract CHR bank index from DataPointer (bits 0-5)."""
        return self.datapointer & 0x3F

    @property
    def top_tile_bank(self) -> int:
        """Get top TileSection bank based on DataPointer bit 7."""
        return (self.datapointer >> 7) & 1

    @property
    def bottom_tile_bank(self) -> int:
        """Get bottom TileSection bank based on DataPointer bit 6."""
        return (self.datapointer >> 6) & 1

    # =========================================================================
    # Modification Tracking
    # =========================================================================

    def mark_modified(self) -> None:
        """Mark this screen as modified."""
        self._modified = True

    @property
    def is_modified(self) -> bool:
        """Check if this screen has been modified."""
        return self._modified

    def get_changes(self) -> dict[str, tuple[int, int]]:
        """Get dict of changed fields: {field: (original, new)}.

        Only works if original bytes were stored.
        """
        if self._original_bytes is None:
            return {}

        original = WorldScreen.from_bytes(
            self._original_bytes,
            self.global_index,
            self.chapter,
            self.relative_index,
        )
        changes = {}
        fields = [
            "parent_world", "ambient_sound", "content", "objectset",
            "screen_index_right", "screen_index_left", "screen_index_down",
            "screen_index_up", "datapointer", "exit_position", "top_tiles",
            "bottom_tiles", "worldscreen_color", "sprites_color", "unknown", "event"
        ]
        for field_name in fields:
            orig_val = getattr(original, field_name)
            new_val = getattr(self, field_name)
            if orig_val != new_val:
                changes[field_name] = (orig_val, new_val)
        return changes

    # =========================================================================
    # Randomization Methods (Navigation)
    # =========================================================================

    def set_navigation(
        self,
        right: Optional[int] = None,
        left: Optional[int] = None,
        down: Optional[int] = None,
        up: Optional[int] = None,
    ) -> None:
        """Set navigation pointers.

        Args:
            right: Screen index for right, or None to keep current
            left: Screen index for left, or None to keep current
            down: Screen index for down, or None to keep current
            up: Screen index for up, or None to keep current
        """
        if right is not None:
            self.screen_index_right = right
        if left is not None:
            self.screen_index_left = left
        if down is not None:
            self.screen_index_down = down
        if up is not None:
            self.screen_index_up = up
        self.mark_modified()

    def set_tiles(self, top: Optional[int] = None, bottom: Optional[int] = None) -> None:
        """Set TileSection indices.

        Args:
            top: TileSection index for top half, or None to keep current
            bottom: TileSection index for bottom half, or None to keep current
        """
        if top is not None:
            self.top_tiles = top
        if bottom is not None:
            self.bottom_tiles = bottom
        self.mark_modified()

    def set_stairway_destination(self, destination: int) -> None:
        """Set stairway destination screen.

        Args:
            destination: Chapter-relative screen index

        Note: Also sets Event to 0x40 (stairway)
        """
        self.event = EventType.STAIRWAY
        self.content = destination
        self.mark_modified()

    # =========================================================================
    # Randomization Methods - Placeholders for Future Features
    # =========================================================================

    def randomize_objectset(
        self,
        objectset: int,
        validate_chr: bool = True,
    ) -> bool:
        """Set ObjectSet for enemy spawns with CHR compatibility validation.

        Args:
            objectset: New ObjectSet ID
            validate_chr: If True, validate CHR compatibility

        Returns:
            True if assignment was valid, False if validation failed

        Raises:
            ValueError: If validate_chr is True and ObjectSet is incompatible
        """
        if validate_chr:
            from .constants import get_compatible_objectsets

            compatible = get_compatible_objectsets(self.datapointer)
            if objectset not in compatible:
                raise ValueError(
                    f"ObjectSet {objectset:#x} incompatible with "
                    f"DataPointer {self.datapointer:#x} (CHR {self.chr_index:#x}). "
                    f"Compatible: {sorted(compatible)}"
                )

        self.objectset = objectset
        self.mark_modified()
        return True

    def randomize_content(
        self,
        content: int,
        preserve_stairway: bool = True,
    ) -> None:
        """Set Content byte.

        Args:
            content: New Content value
            preserve_stairway: If True and screen is stairway, don't change

        TODO: Add validation for Content byte meaning conflicts
        """
        if preserve_stairway and self.is_stairway:
            # Don't overwrite stairway destination
            return
        self.content = content
        self.mark_modified()

    def randomize_colors(
        self,
        worldscreen_color: Optional[int] = None,
        sprites_color: Optional[int] = None,
    ) -> None:
        """Set color palettes.

        Args:
            worldscreen_color: Background color palette
            sprites_color: Sprite color palette

        TODO: Add validation for color compatibility
        """
        if worldscreen_color is not None:
            self.worldscreen_color = worldscreen_color
        if sprites_color is not None:
            self.sprites_color = sprites_color
        self.mark_modified()

    def randomize_datapointer(
        self,
        datapointer: int,
        update_objectset: bool = False,
    ) -> None:
        """Set DataPointer (CHR bank selector).

        WARNING: Changing DataPointer can corrupt sprite rendering!
        Only use if you understand CHR bank compatibility.

        Args:
            datapointer: New DataPointer value
            update_objectset: If True, also update ObjectSet for compatibility

        TODO: Implement CHR bank compatibility checking
        """
        self.datapointer = datapointer
        self.mark_modified()

    def copy_from(self, other: WorldScreen, copy_navigation: bool = False) -> None:
        """Copy visual properties from another screen.

        Args:
            other: Source WorldScreen
            copy_navigation: If True, also copy navigation pointers
        """
        self.parent_world = other.parent_world
        self.ambient_sound = other.ambient_sound
        self.datapointer = other.datapointer
        self.top_tiles = other.top_tiles
        self.bottom_tiles = other.bottom_tiles
        self.worldscreen_color = other.worldscreen_color
        self.sprites_color = other.sprites_color

        if copy_navigation:
            self.screen_index_right = other.screen_index_right
            self.screen_index_left = other.screen_index_left
            self.screen_index_down = other.screen_index_down
            self.screen_index_up = other.screen_index_up

        self.mark_modified()

    # =========================================================================
    # Debug/Display
    # =========================================================================

    def __repr__(self) -> str:
        """Detailed representation for debugging."""
        return (
            f"WorldScreen(global={self.global_index}, ch{self.chapter}:{self.relative_index}, "
            f"PW=0x{self.parent_world:02X}, type={self.section_type.name})"
        )

    def summary(self) -> str:
        """Human-readable summary."""
        nav = f"R:{self._nav_str(self.screen_index_right)} "
        nav += f"L:{self._nav_str(self.screen_index_left)} "
        nav += f"D:{self._nav_str(self.screen_index_down)} "
        nav += f"U:{self._nav_str(self.screen_index_up)}"

        flags = []
        if self.is_town:
            flags.append("TOWN")
        if self.is_boss_screen:
            flags.append("BOSS")
        if self.is_stairway:
            flags.append(f"STAIR→{self.content}")
        if self.has_building_entrance:
            flags.append("BLDG")

        flag_str = f" [{', '.join(flags)}]" if flags else ""
        return (
            f"Screen {self.global_index} (Ch{self.chapter}:{self.relative_index}) "
            f"| {self.section_type.name} | {nav}{flag_str}"
        )

    def _nav_str(self, value: int) -> str:
        """Format navigation value for display."""
        if value == NAV_BLOCKED:
            return "X"
        if value == NAV_BUILDING_ENTRANCE:
            return "B"
        return f"{value:02X}"
