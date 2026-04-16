"""Tests for spoiler log generation."""

import json
import tempfile
from datetime import datetime
from pathlib import Path

import pytest

from tmos_randomizer.output.spoiler_log import (
    ItemLocation,
    AllyLocation,
    ShopInventory,
    SectionInfo,
    ConnectionInfo,
    ChapterMapInfo,
    Sphere,
    PlaythroughStep,
    SpecialNote,
    SpoilerLog,
    SpoilerLogBuilder,
    generate_text_spoiler,
    generate_json_spoiler,
    write_spoiler_log,
    load_spoiler_log,
)


# =============================================================================
# Data Structure Tests
# =============================================================================

class TestItemLocation:
    """Tests for ItemLocation dataclass."""

    def test_basic_creation(self):
        """Test creating an ItemLocation."""
        item = ItemLocation(
            item_name="Rod of Flames",
            chapter=1,
            screen=12,
            location_desc="Town 1, Chest in Back Room",
        )
        assert item.item_name == "Rod of Flames"
        assert item.chapter == 1
        assert item.screen == 12
        assert item.location_desc == "Town 1, Chest in Back Room"
        assert item.requirements == []
        assert item.is_key_item is False

    def test_with_requirements(self):
        """Test ItemLocation with requirements."""
        item = ItemLocation(
            item_name="Legend Sword",
            chapter=5,
            screen=100,
            location_desc="Sabaron's Castle",
            requirements=["Light Armor", "All Allies"],
            is_key_item=True,
        )
        assert item.requirements == ["Light Armor", "All Allies"]
        assert item.is_key_item is True

    def test_to_dict(self):
        """Test serialization to dict."""
        item = ItemLocation(
            item_name="Rod of Flames",
            chapter=1,
            screen=12,
            location_desc="Town 1, Chest",
            requirements=["Coronya"],
            is_key_item=True,
        )
        data = item.to_dict()
        assert data["item"] == "Rod of Flames"
        assert data["chapter"] == 1
        assert data["screen"] == 12
        assert data["location"] == "Town 1, Chest"
        assert data["requirements"] == ["Coronya"]
        assert data["is_key_item"] is True


class TestAllyLocation:
    """Tests for AllyLocation dataclass."""

    def test_basic_creation(self):
        """Test creating an AllyLocation."""
        ally = AllyLocation(
            name="Coronya",
            chapter=1,
            screen=10,
            location_desc="Town 1, Main Building",
        )
        assert ally.name == "Coronya"
        assert ally.chapter == 1
        assert ally.screen == 10
        assert ally.requirements == []

    def test_to_dict(self):
        """Test serialization."""
        ally = AllyLocation(
            name="Faruk",
            chapter=1,
            screen=78,
            location_desc="Dungeon, Screen 78",
            requirements=["Rod of Flames"],
        )
        data = ally.to_dict()
        assert data["name"] == "Faruk"
        assert data["requirements"] == ["Rod of Flames"]


class TestShopInventory:
    """Tests for ShopInventory dataclass."""

    def test_basic_creation(self):
        """Test creating a ShopInventory."""
        shop = ShopInventory(
            chapter=1,
            screen=14,
            shop_type="item",
            location_desc="Town 1",
            items=[
                {"name": "Bread", "price": 50},
                {"name": "Magic Potion", "price": 100},
            ],
        )
        assert shop.chapter == 1
        assert shop.shop_type == "item"
        assert len(shop.items) == 2
        assert shop.items[0]["name"] == "Bread"


class TestChapterMapInfo:
    """Tests for ChapterMapInfo dataclass."""

    def test_creation_with_sections(self):
        """Test creating ChapterMapInfo with sections."""
        sections = [
            SectionInfo("overworld", 28, "blob", [1, 2, 3]),
            SectionInfo("town", 6, "linear", [30, 31, 32]),
        ]
        connections = [
            ConnectionInfo("start", "overworld", "spawn", 0),
            ConnectionInfo("overworld", "town", "edge", 28),
        ]
        chapter_map = ChapterMapInfo(
            chapter_num=1,
            screen_count=131,
            sections=sections,
            connections=connections,
            topology="branching",
        )
        assert chapter_map.chapter_num == 1
        assert len(chapter_map.sections) == 2
        assert len(chapter_map.connections) == 2

    def test_to_dict(self):
        """Test serialization."""
        chapter_map = ChapterMapInfo(
            chapter_num=1,
            screen_count=131,
            topology="hub",
        )
        data = chapter_map.to_dict()
        assert data["chapter"] == 1
        assert data["screen_count"] == 131
        assert data["topology"] == "hub"


# =============================================================================
# SpoilerLog Tests
# =============================================================================

class TestSpoilerLog:
    """Tests for SpoilerLog class."""

    def test_basic_creation(self):
        """Test creating a basic SpoilerLog."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        assert log.seed == 12345
        assert log.version == "2.0.0"
        assert log.key_items == []
        assert log.allies == []

    def test_to_dict(self):
        """Test serialization to dict."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
            preset="hard",
            rom_sha256="abc123",
        )
        log.key_items.append(ItemLocation("Rod", 1, 10, "Town", is_key_item=True))
        log.allies.append(AllyLocation("Coronya", 1, 5, "Town"))

        data = log.to_dict()
        assert data["meta"]["seed"] == 12345
        assert data["meta"]["preset"] == "hard"
        assert len(data["key_items"]) == 1
        assert len(data["allies"]) == 1

    def test_from_dict(self):
        """Test deserialization from dict."""
        data = {
            "meta": {
                "seed": 99999,
                "generated": "2026-01-24T12:00:00",
                "version": "2.0.0",
                "preset": "normal",
                "rom_sha256": "def456",
            },
            "settings": {"shuffle_overworld": True},
            "key_items": [
                {"item": "Rod of Ice", "chapter": 2, "screen": 50, "location": "Cave", "requirements": []}
            ],
            "all_items": [],
            "allies": [
                {"name": "Supica", "chapter": 2, "screen": 60, "location": "Town", "requirements": []}
            ],
            "shops": [],
            "map": {},
            "spheres": [],
            "playthrough": [],
            "special_notes": [],
        }

        log = SpoilerLog.from_dict(data)
        assert log.seed == 99999
        assert log.preset == "normal"
        assert len(log.key_items) == 1
        assert log.key_items[0].item_name == "Rod of Ice"
        assert len(log.allies) == 1
        assert log.allies[0].name == "Supica"

    def test_round_trip(self):
        """Test serialization round-trip."""
        log = SpoilerLog(
            seed=54321,
            generated=datetime(2026, 1, 24, 10, 0, 0),
            settings={"mode": "shuffle"},
        )
        log.key_items.append(ItemLocation("Test Item", 1, 1, "Test Location", is_key_item=True))
        log.spheres.append(Sphere(0, [], ["Starting Sword"], ["Town 1"], []))

        data = log.to_dict()
        restored = SpoilerLog.from_dict(data)

        assert restored.seed == log.seed
        assert len(restored.key_items) == len(log.key_items)
        assert restored.key_items[0].item_name == log.key_items[0].item_name
        assert len(restored.spheres) == len(log.spheres)


# =============================================================================
# SpoilerLogBuilder Tests
# =============================================================================

class TestSpoilerLogBuilder:
    """Tests for SpoilerLogBuilder class."""

    def test_basic_building(self):
        """Test basic builder usage."""
        builder = SpoilerLogBuilder(seed=11111)
        log = builder.build()
        assert log.seed == 11111
        assert log.version == "2.0.0"

    def test_chained_building(self):
        """Test chained builder methods."""
        log = (
            SpoilerLogBuilder(seed=22222)
            .set_rom_hash("abc")
            .set_settings({"test": True})
            .add_key_item("Rod", 1, 10, "Town")
            .add_ally("Coronya", 1, 5, "Building")
            .add_warning("Test warning")
            .build()
        )

        assert log.rom_sha256 == "abc"
        assert log.settings["test"] is True
        assert len(log.key_items) == 1
        assert len(log.allies) == 1
        assert len(log.special_notes) == 1
        assert log.special_notes[0].category == "warning"

    def test_add_shop(self):
        """Test adding shop inventory."""
        builder = SpoilerLogBuilder(seed=33333)
        builder.add_shop(
            chapter=1,
            screen=14,
            shop_type="weapon",
            location_desc="Town 1",
            items=[{"name": "Sword", "price": 500}],
        )
        log = builder.build()
        assert len(log.shops) == 1
        assert log.shops[0].shop_type == "weapon"

    def test_add_shop_inventory_raises(self):
        """Disabled in Phase 0: consumes the broken CoreShopInventory model."""
        from tmos_randomizer.core.shop_inventory import (
            ShopInventory as CoreShopInventory,
            ShopSlot,
        )
        from tmos_randomizer.core.shop_items import (
            ShopItem, ShopType, ItemCategory,
        )
        item = ShopItem(
            item_id=1, name="Bread", base_price=20,
            category=ItemCategory.CONSUMABLE,
            shop_types=frozenset({ShopType.GENERAL}),
        )
        inv = CoreShopInventory(
            content_value=0x60, chapter=1, screen_index=0,
            shop_type=ShopType.GENERAL,
            items=[ShopSlot(item=item, price=20, quantity=0, slot_index=0)],
        )
        builder = SpoilerLogBuilder(seed=12345)
        with pytest.raises(NotImplementedError) as excinfo:
            builder.add_shop_inventory(inv)
        assert "items-economy-re-answers.md" in str(excinfo.value)

    def test_add_chapter_shops_raises(self):
        """Disabled in Phase 0: consumes the broken ChapterShopData model."""
        from tmos_randomizer.core.shop_inventory import ChapterShopData
        builder = SpoilerLogBuilder(seed=12345)
        with pytest.raises(NotImplementedError) as excinfo:
            builder.add_chapter_shops(ChapterShopData(chapter_num=1, inventories=[]))
        assert "items-economy-re-answers.md" in str(excinfo.value)

    def test_shop_section_emits_not_supported_notice(self):
        """The spoiler text must carry the fixed 'not yet supported' notice,
        not fabricated shop inventory data."""
        builder = SpoilerLogBuilder(seed=12345)
        builder.set_rom_hash("abc")
        log = builder.build()
        text = generate_text_spoiler(log)
        assert "SHOP INVENTORIES" in text
        assert "Shop randomization is not yet supported" in text
        # Must NOT contain the old fabricated output like "Sword Level 2 ... 500 gold"
        assert " gold" not in text.split("SHOP INVENTORIES")[1].split("MAP LAYOUT")[0]

    def test_add_chapter_map(self):
        """Test adding chapter map info."""
        builder = SpoilerLogBuilder(seed=44444)
        builder.add_chapter_map(1, 131, "branching")
        builder.add_section_to_chapter(1, "overworld", 28, "blob", [1, 2, 3])
        builder.add_connection_to_chapter(1, "start", "overworld", "spawn", 0)

        log = builder.build()
        assert len(log.map_layout) == 1
        assert log.map_layout[0].chapter_num == 1
        assert len(log.map_layout[0].sections) == 1
        assert len(log.map_layout[0].connections) == 1

    def test_add_sphere(self):
        """Test adding sphere analysis."""
        builder = SpoilerLogBuilder(seed=55555)
        builder.add_sphere(
            sphere_num=0,
            items=["Starting Sword"],
            locations=["Town 1"],
            allies=["Coronya"],
        )
        builder.add_sphere(
            sphere_num=1,
            unlocked_by=["Coronya"],
            items=["Rod of Flames"],
            locations=["Overworld A"],
        )

        log = builder.build()
        assert len(log.spheres) == 2
        assert log.spheres[0].sphere_num == 0
        assert log.spheres[1].unlocked_by == ["Coronya"]

    def test_add_playthrough_step(self):
        """Test adding playthrough steps."""
        builder = SpoilerLogBuilder(seed=66666)
        builder.add_playthrough_step(1, 1, "Start in Town 1", "Town 1")
        builder.add_playthrough_step(1, 2, "Get Coronya", "Main Building", screen=5)

        log = builder.build()
        assert len(log.playthrough) == 2
        assert log.playthrough[1].screen == 5

    def test_special_notes(self):
        """Test different special note types."""
        builder = SpoilerLogBuilder(seed=77777)
        builder.add_warning("Time Door hard to reach")
        builder.add_interesting("All rods in Chapter 1")
        builder.add_difficulty_note("High-level enemies in dungeon")

        log = builder.build()
        assert len(log.special_notes) == 3
        categories = [n.category for n in log.special_notes]
        assert "warning" in categories
        assert "interesting" in categories
        assert "difficulty" in categories


# =============================================================================
# Text Generation Tests
# =============================================================================

class TestTextGeneration:
    """Tests for text spoiler generation."""

    def test_basic_text_generation(self):
        """Test generating basic text spoiler."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        text = generate_text_spoiler(log)

        assert "THE MAGIC OF SCHEHERAZADE" in text
        assert "SPOILER LOG" in text
        assert "12345" in text
        assert "2026-01-24" in text

    def test_text_with_key_items(self):
        """Test text generation with key items."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        log.key_items.append(ItemLocation("Rod of Flames", 1, 10, "Town Chest", is_key_item=True))

        text = generate_text_spoiler(log)
        assert "KEY ITEM LOCATIONS" in text
        assert "Rod of Flames" in text
        assert "CHAPTER 1" in text

    def test_text_with_allies(self):
        """Test text generation with allies."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        log.allies.append(AllyLocation("Coronya", 1, 5, "Town Building"))

        text = generate_text_spoiler(log)
        assert "ALLY LOCATIONS" in text
        assert "Coronya" in text

    def test_text_section_filtering(self):
        """Test filtering which sections to include."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        log.key_items.append(ItemLocation("Test", 1, 1, "Test", is_key_item=True))

        # Include only header
        text = generate_text_spoiler(log, include_sections={"header": True, "key_items": False})
        assert "THE MAGIC OF SCHEHERAZADE" in text
        assert "KEY ITEM LOCATIONS" not in text


# =============================================================================
# JSON Generation Tests
# =============================================================================

class TestJsonGeneration:
    """Tests for JSON spoiler generation."""

    def test_basic_json_generation(self):
        """Test generating basic JSON spoiler."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        json_str = generate_json_spoiler(log)
        data = json.loads(json_str)

        assert data["meta"]["seed"] == 12345
        assert "2026-01-24" in data["meta"]["generated"]

    def test_json_pretty_formatting(self):
        """Test pretty vs compact JSON."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )

        pretty = generate_json_spoiler(log, pretty=True)
        compact = generate_json_spoiler(log, pretty=False)

        assert len(pretty) > len(compact)
        assert "\n" in pretty
        assert "\n" not in compact


# =============================================================================
# File I/O Tests
# =============================================================================

class TestFileIO:
    """Tests for file reading/writing."""

    def test_write_spoiler_log(self):
        """Test writing spoiler log to files."""
        log = SpoilerLog(
            seed=12345,
            generated=datetime(2026, 1, 24, 15, 30, 0),
        )
        log.key_items.append(ItemLocation("Test Item", 1, 1, "Test", is_key_item=True))

        with tempfile.TemporaryDirectory() as tmpdir:
            written = write_spoiler_log(log, tmpdir)

            assert "text" in written
            assert "json" in written
            assert written["text"].exists()
            assert written["json"].exists()

            # Verify text content
            text_content = written["text"].read_text()
            assert "THE MAGIC OF SCHEHERAZADE" in text_content

            # Verify JSON content
            json_content = written["json"].read_text()
            data = json.loads(json_content)
            assert data["meta"]["seed"] == 12345

    def test_write_only_json(self):
        """Test writing only JSON format."""
        log = SpoilerLog(seed=12345, generated=datetime.now())

        with tempfile.TemporaryDirectory() as tmpdir:
            written = write_spoiler_log(log, tmpdir, write_text=False)

            assert "json" in written
            assert "text" not in written

    def test_load_spoiler_log(self):
        """Test loading spoiler log from JSON."""
        log = SpoilerLog(
            seed=99999,
            generated=datetime(2026, 1, 24, 12, 0, 0),
        )
        log.allies.append(AllyLocation("Coronya", 1, 5, "Town"))

        with tempfile.TemporaryDirectory() as tmpdir:
            write_spoiler_log(log, tmpdir, write_text=False)
            loaded = load_spoiler_log(Path(tmpdir) / "spoiler.json")

            assert loaded.seed == 99999
            assert len(loaded.allies) == 1
            assert loaded.allies[0].name == "Coronya"

    def test_custom_filenames(self):
        """Test custom output filenames."""
        log = SpoilerLog(seed=12345, generated=datetime.now())

        with tempfile.TemporaryDirectory() as tmpdir:
            written = write_spoiler_log(
                log,
                tmpdir,
                text_filename="custom_spoiler.txt",
                json_filename="custom_data.json",
            )

            assert written["text"].name == "custom_spoiler.txt"
            assert written["json"].name == "custom_data.json"


# =============================================================================
# Builder File Writing Tests
# =============================================================================

class TestBuilderWrite:
    """Tests for SpoilerLogBuilder.write() method."""

    def test_builder_write(self):
        """Test writing directly from builder."""
        with tempfile.TemporaryDirectory() as tmpdir:
            written = (
                SpoilerLogBuilder(seed=88888)
                .add_key_item("Test Rod", 1, 10, "Test Location")
                .write(tmpdir)
            )

            assert written["text"].exists()
            assert written["json"].exists()

            # Verify content
            loaded = load_spoiler_log(written["json"])
            assert loaded.seed == 88888
            assert len(loaded.key_items) == 1
