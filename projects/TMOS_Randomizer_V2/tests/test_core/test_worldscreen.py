"""Tests for core/worldscreen.py"""

import pytest

from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import SectionType, ContentType, EventType


class TestWorldScreenCreation:
    """Test WorldScreen creation and basic properties."""

    def test_create_default(self):
        """Create WorldScreen with minimal args."""
        screen = WorldScreen(global_index=0, chapter=1, relative_index=0)
        assert screen.global_index == 0
        assert screen.chapter == 1
        assert screen.relative_index == 0

    def test_from_bytes(self):
        """Create WorldScreen from ROM bytes."""
        # Example data from knowledge/structures/worldscreen.md
        # Screen 0: 40 00 00 00 01 FF FF 60 D1 78 0D 11 29 00 00 00
        data = bytes([
            0x40, 0x00, 0x00, 0x00,  # ParentWorld, AmbientSound, Content, ObjectSet
            0x01, 0xFF, 0xFF, 0x60,  # Navigation (R, L, D, U)
            0xD1, 0x78, 0x0D, 0x11,  # DataPointer, ExitPos, TopTiles, BottomTiles
            0x29, 0x00, 0x00, 0x00,  # Colors, Unknown, Event
        ])
        screen = WorldScreen.from_bytes(data, global_index=0, chapter=1, relative_index=0)

        assert screen.parent_world == 0x40
        assert screen.content == 0x00
        assert screen.objectset == 0x00
        assert screen.screen_index_right == 0x01
        assert screen.screen_index_left == 0xFF
        assert screen.screen_index_down == 0xFF
        assert screen.screen_index_up == 0x60
        assert screen.datapointer == 0xD1
        assert screen.top_tiles == 0x0D
        assert screen.bottom_tiles == 0x11

    def test_from_bytes_wrong_size(self):
        """from_bytes should raise on wrong size."""
        with pytest.raises(ValueError, match="Expected 16 bytes"):
            WorldScreen.from_bytes(bytes(15), 0, 1, 0)

    def test_to_bytes_roundtrip(self):
        """to_bytes should return same data as from_bytes input."""
        original = bytes(range(16))  # Arbitrary 16 bytes
        screen = WorldScreen.from_bytes(original, 0, 1, 0)
        assert screen.to_bytes() == original


class TestWorldScreenSerialization:
    """Test JSON serialization."""

    def test_to_dict(self):
        """to_dict should include all properties."""
        screen = WorldScreen(
            global_index=5,
            chapter=1,
            relative_index=5,
            parent_world=0x20,
            content=0x7E,
        )
        d = screen.to_dict()

        assert d["global_index"] == 5
        assert d["chapter"] == 1
        assert d["parent_world"] == 0x20
        assert d["content"] == 0x7E
        assert d["section_type"] == "TOWN"
        assert "is_town" in d
        assert "is_boss_screen" in d

    def test_from_dict_roundtrip(self):
        """from_dict(to_dict()) should return equivalent screen."""
        original = WorldScreen(
            global_index=10,
            chapter=1,
            relative_index=10,
            parent_world=0x40,
            content=0x21,
            objectset=0x05,
            screen_index_right=11,
            screen_index_left=9,
        )
        d = original.to_dict()
        restored = WorldScreen.from_dict(d)

        assert restored.global_index == original.global_index
        assert restored.parent_world == original.parent_world
        assert restored.content == original.content
        assert restored.screen_index_right == original.screen_index_right


class TestScreenTypeDetection:
    """Test screen type detection properties."""

    def test_section_type_overworld(self):
        """ParentWorld 0x40 should be OVERWORLD."""
        screen = WorldScreen(0, 1, 0, parent_world=0x40)
        assert screen.section_type == SectionType.OVERWORLD

    def test_section_type_town(self):
        """ParentWorld 0x20 should be TOWN."""
        screen = WorldScreen(0, 1, 0, parent_world=0x20)
        assert screen.section_type == SectionType.TOWN

    def test_section_type_dungeon(self):
        """ParentWorld 0xD0 should be DUNGEON."""
        screen = WorldScreen(0, 1, 0, parent_world=0xD0)
        assert screen.section_type == SectionType.DUNGEON

    def test_is_town_by_sprites_color(self):
        """is_town checks SpritesColor == 0x12."""
        screen = WorldScreen(0, 1, 0, sprites_color=0x12)
        assert screen.is_town is True

        screen2 = WorldScreen(0, 1, 0, sprites_color=0x00)
        assert screen2.is_town is False

    def test_is_boss_screen(self):
        """Content 0x21-0x2A indicates boss screen."""
        for content in range(0x21, 0x2B):
            screen = WorldScreen(0, 1, 0, content=content)
            assert screen.is_boss_screen is True

        screen = WorldScreen(0, 1, 0, content=0x20)
        assert screen.is_boss_screen is False

    def test_is_wizard_screen(self):
        """Content 0x01 indicates wizard battle."""
        screen = WorldScreen(0, 1, 0, content=0x01)
        assert screen.is_wizard_screen is True

    def test_is_shop(self):
        """Content 0x60-0x7D indicates shop."""
        screen = WorldScreen(0, 1, 0, content=0x65)
        assert screen.is_shop is True

    def test_is_mosque(self):
        """Content 0x7E indicates mosque."""
        screen = WorldScreen(0, 1, 0, content=0x7E)
        assert screen.is_mosque is True

    def test_has_time_door(self):
        """Content 0xC0 indicates time door."""
        screen = WorldScreen(0, 1, 0, content=0xC0)
        assert screen.has_time_door is True

    def test_is_stairway(self):
        """Event 0x40 indicates stairway."""
        screen = WorldScreen(0, 1, 0, event=0x40, content=5)
        assert screen.is_stairway is True
        assert screen.stairway_destination == 5


class TestNavigation:
    """Test navigation helper methods."""

    def test_get_neighbor(self):
        """get_neighbor returns correct screen index."""
        screen = WorldScreen(
            0, 1, 0,
            screen_index_right=5,
            screen_index_left=0xFF,
            screen_index_down=0xFE,
            screen_index_up=10,
        )
        assert screen.get_neighbor("right") == 5
        assert screen.get_neighbor("left") is None  # Blocked
        assert screen.get_neighbor("down") is None  # Building entrance
        assert screen.get_neighbor("up") == 10

    def test_get_all_neighbors(self):
        """get_all_neighbors returns dict of all directions."""
        screen = WorldScreen(0, 1, 0, screen_index_right=1, screen_index_up=2)
        neighbors = screen.get_all_neighbors()
        assert neighbors["right"] == 1
        assert neighbors["up"] == 2
        assert neighbors["left"] is None
        assert neighbors["down"] is None

    def test_get_connected_screens(self):
        """get_connected_screens returns list of valid neighbors."""
        screen = WorldScreen(
            0, 1, 0,
            screen_index_right=1,
            screen_index_left=0xFF,
            screen_index_down=0xFE,
            screen_index_up=2,
        )
        connected = screen.get_connected_screens()
        assert set(connected) == {1, 2}

    def test_has_building_entrance(self):
        """has_building_entrance checks for 0xFE navigation."""
        screen = WorldScreen(0, 1, 0, screen_index_up=0xFE)
        assert screen.has_building_entrance is True

        screen2 = WorldScreen(0, 1, 0)
        assert screen2.has_building_entrance is False


class TestChrHelpers:
    """Test CHR/DataPointer helper properties."""

    def test_chr_index(self):
        """chr_index extracts lower 6 bits."""
        screen = WorldScreen(0, 1, 0, datapointer=0xCF)
        assert screen.chr_index == 0x0F

    def test_top_tile_bank(self):
        """top_tile_bank extracts bit 7."""
        screen = WorldScreen(0, 1, 0, datapointer=0x8F)  # bit 7 = 1
        assert screen.top_tile_bank == 1

        screen2 = WorldScreen(0, 1, 0, datapointer=0x4F)  # bit 7 = 0
        assert screen2.top_tile_bank == 0

    def test_bottom_tile_bank(self):
        """bottom_tile_bank extracts bit 6."""
        screen = WorldScreen(0, 1, 0, datapointer=0x4F)  # bit 6 = 1
        assert screen.bottom_tile_bank == 1

        screen2 = WorldScreen(0, 1, 0, datapointer=0x8F)  # bit 6 = 0
        assert screen2.bottom_tile_bank == 0


class TestModificationTracking:
    """Test modification tracking."""

    def test_initially_not_modified(self):
        """New screen should not be modified."""
        screen = WorldScreen(0, 1, 0)
        assert screen.is_modified is False

    def test_mark_modified(self):
        """mark_modified sets flag."""
        screen = WorldScreen(0, 1, 0)
        screen.mark_modified()
        assert screen.is_modified is True

    def test_set_navigation_marks_modified(self):
        """set_navigation marks screen as modified."""
        screen = WorldScreen(0, 1, 0)
        screen.set_navigation(right=5)
        assert screen.is_modified is True
        assert screen.screen_index_right == 5

    def test_set_tiles_marks_modified(self):
        """set_tiles marks screen as modified."""
        screen = WorldScreen(0, 1, 0)
        screen.set_tiles(top=10, bottom=20)
        assert screen.is_modified is True
        assert screen.top_tiles == 10
        assert screen.bottom_tiles == 20

    def test_get_changes(self):
        """get_changes returns modified fields."""
        original = bytes([0x40, 0x00, 0x00, 0x00, 0x01, 0xFF, 0xFF, 0x60,
                         0xD1, 0x78, 0x0D, 0x11, 0x29, 0x00, 0x00, 0x00])
        screen = WorldScreen.from_bytes(original, 0, 1, 0)

        screen.screen_index_right = 0x05
        screen.top_tiles = 0x20

        changes = screen.get_changes()
        assert "screen_index_right" in changes
        assert changes["screen_index_right"] == (0x01, 0x05)
        assert "top_tiles" in changes
        assert changes["top_tiles"] == (0x0D, 0x20)


class TestRandomizationMethods:
    """Test randomization helper methods."""

    def test_set_stairway_destination(self):
        """set_stairway_destination sets Event and Content."""
        screen = WorldScreen(0, 1, 0)
        screen.set_stairway_destination(15)

        assert screen.event == 0x40
        assert screen.content == 15
        assert screen.is_stairway is True
        assert screen.stairway_destination == 15

    def test_randomize_content_preserves_stairway(self):
        """randomize_content should not overwrite stairway destination."""
        screen = WorldScreen(0, 1, 0, event=0x40, content=5)
        screen.randomize_content(0x7E, preserve_stairway=True)

        assert screen.content == 5  # Not changed

    def test_copy_from(self):
        """copy_from copies visual properties."""
        source = WorldScreen(0, 1, 0, parent_world=0x20, top_tiles=0x10, bottom_tiles=0x20)
        target = WorldScreen(1, 1, 1, parent_world=0x40)

        target.copy_from(source)

        assert target.parent_world == 0x20
        assert target.top_tiles == 0x10
        assert target.bottom_tiles == 0x20
        assert target.is_modified is True
