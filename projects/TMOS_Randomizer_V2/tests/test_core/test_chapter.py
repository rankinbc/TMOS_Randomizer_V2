"""Tests for core/chapter.py"""

import pytest

from tmos_randomizer.core.chapter import Chapter, GameWorld
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.core.enums import SectionType


class TestChapterCreation:
    """Test Chapter creation and validation."""

    def test_create_chapter(self):
        """Create empty chapter."""
        chapter = Chapter(chapter_num=1)
        assert chapter.chapter_num == 1
        assert chapter.screen_count == 0

    def test_invalid_chapter_number(self):
        """Invalid chapter number should raise."""
        with pytest.raises(ValueError):
            Chapter(chapter_num=0)
        with pytest.raises(ValueError):
            Chapter(chapter_num=6)

    def test_add_screen(self):
        """Add screen to chapter."""
        chapter = Chapter(chapter_num=1)
        screen = WorldScreen(global_index=0, chapter=1, relative_index=0)
        chapter.add_screen(screen)

        assert chapter.screen_count == 1
        assert chapter[0] == screen

    def test_add_wrong_chapter_screen(self):
        """Adding screen from wrong chapter should raise."""
        chapter = Chapter(chapter_num=1)
        screen = WorldScreen(global_index=131, chapter=2, relative_index=0)

        with pytest.raises(ValueError, match="belongs to chapter"):
            chapter.add_screen(screen)


class TestChapterProperties:
    """Test Chapter property accessors."""

    def test_expected_count(self):
        """expected_count returns correct value per chapter."""
        assert Chapter(1).expected_count == 131
        assert Chapter(2).expected_count == 137
        assert Chapter(3).expected_count == 153
        assert Chapter(4).expected_count == 164
        assert Chapter(5).expected_count == 154

    def test_global_offset(self):
        """global_offset returns correct value per chapter."""
        assert Chapter(1).global_offset == 0
        assert Chapter(2).global_offset == 131
        assert Chapter(3).global_offset == 268
        assert Chapter(4).global_offset == 421
        assert Chapter(5).global_offset == 585

    def test_is_complete(self):
        """is_complete checks against expected count."""
        chapter = Chapter(chapter_num=1)
        assert chapter.is_complete is False

        # Add all 131 screens
        for i in range(131):
            chapter.add_screen(WorldScreen(i, 1, i))

        assert chapter.is_complete is True


class TestChapterScreenAccess:
    """Test screen access methods."""

    @pytest.fixture
    def sample_chapter(self):
        """Create chapter with a few screens."""
        chapter = Chapter(chapter_num=1)
        for i in range(10):
            screen = WorldScreen(
                global_index=i,
                chapter=1,
                relative_index=i,
                parent_world=0x40 if i < 5 else 0x20,  # Mix overworld and town
            )
            chapter.add_screen(screen)
        return chapter

    def test_getitem(self, sample_chapter):
        """Index access by relative index."""
        assert sample_chapter[0].relative_index == 0
        assert sample_chapter[5].relative_index == 5

    def test_getitem_out_of_range(self, sample_chapter):
        """Out of range index should raise."""
        with pytest.raises(IndexError):
            _ = sample_chapter[100]

    def test_len(self, sample_chapter):
        """len() returns screen count."""
        assert len(sample_chapter) == 10

    def test_iter(self, sample_chapter):
        """iter() returns all screens."""
        screens = list(sample_chapter)
        assert len(screens) == 10

    def test_get_by_global(self, sample_chapter):
        """get_by_global finds screen by global index."""
        screen = sample_chapter.get_by_global(5)
        assert screen is not None
        assert screen.global_index == 5

        # Non-existent global
        assert sample_chapter.get_by_global(999) is None


class TestSectionQueries:
    """Test section type queries."""

    @pytest.fixture
    def mixed_chapter(self):
        """Create chapter with different section types."""
        chapter = Chapter(chapter_num=1)

        # 5 overworld screens (0x40)
        for i in range(5):
            chapter.add_screen(WorldScreen(i, 1, i, parent_world=0x40))

        # 3 town screens (0x20)
        for i in range(5, 8):
            chapter.add_screen(WorldScreen(i, 1, i, parent_world=0x20))

        # 2 dungeon screens (0xD0)
        for i in range(8, 10):
            chapter.add_screen(WorldScreen(i, 1, i, parent_world=0xD0))

        return chapter

    def test_get_by_section_type(self, mixed_chapter):
        """get_by_section_type filters correctly."""
        overworld = mixed_chapter.get_by_section_type(SectionType.OVERWORLD)
        assert len(overworld) == 5

        town = mixed_chapter.get_by_section_type(SectionType.TOWN)
        assert len(town) == 3

        dungeon = mixed_chapter.get_by_section_type(SectionType.DUNGEON)
        assert len(dungeon) == 2

    def test_convenience_methods(self, mixed_chapter):
        """Test convenience methods for section queries."""
        assert len(mixed_chapter.get_overworld_screens()) == 5
        assert len(mixed_chapter.get_town_screens()) == 3
        assert len(mixed_chapter.get_dungeon_screens()) == 2

    def test_get_section_breakdown(self, mixed_chapter):
        """get_section_breakdown returns counts by type."""
        breakdown = mixed_chapter.get_section_breakdown()
        assert breakdown[SectionType.OVERWORLD] == 5
        assert breakdown[SectionType.TOWN] == 3
        assert breakdown[SectionType.DUNGEON] == 2


class TestNavigationQueries:
    """Test navigation-related queries."""

    @pytest.fixture
    def connected_chapter(self):
        """Create chapter with connected screens."""
        chapter = Chapter(chapter_num=1)

        # Screen 0 -> Screen 1 (bidirectional)
        chapter.add_screen(WorldScreen(0, 1, 0, screen_index_right=1))
        chapter.add_screen(WorldScreen(1, 1, 1, screen_index_left=0, screen_index_right=2))
        chapter.add_screen(WorldScreen(2, 1, 2, screen_index_left=1))

        # Screen 3 is isolated
        chapter.add_screen(WorldScreen(3, 1, 3))

        return chapter

    def test_build_navigation_graph(self, connected_chapter):
        """build_navigation_graph creates adjacency list."""
        graph = connected_chapter.build_navigation_graph()

        assert 1 in graph[0]  # 0 -> 1
        assert 0 in graph[1]  # 1 -> 0
        assert 2 in graph[1]  # 1 -> 2
        assert 1 in graph[2]  # 2 -> 1
        assert graph[3] == []  # 3 is isolated

    def test_find_connected_components(self, connected_chapter):
        """find_connected_components groups connected screens."""
        components = connected_chapter.find_connected_components()

        assert len(components) == 2
        # One component with 0, 1, 2 and one with just 3
        sizes = sorted(len(c) for c in components)
        assert sizes == [1, 3]

    def test_get_stairway_pairs(self):
        """get_stairway_pairs finds bidirectional stairways."""
        chapter = Chapter(chapter_num=1)

        # Screens 0 and 1 are stairway pair
        chapter.add_screen(WorldScreen(0, 1, 0, event=0x40, content=1))
        chapter.add_screen(WorldScreen(1, 1, 1, event=0x40, content=0))
        # Screen 2 is not a stairway
        chapter.add_screen(WorldScreen(2, 1, 2))

        pairs = chapter.get_stairway_pairs()
        assert len(pairs) == 1
        assert pairs[0][0].relative_index in (0, 1)
        assert pairs[0][1].relative_index in (0, 1)


class TestModificationQueries:
    """Test modification tracking queries."""

    def test_get_modified_screens(self):
        """get_modified_screens returns only modified screens."""
        chapter = Chapter(chapter_num=1)
        chapter.add_screen(WorldScreen(0, 1, 0))
        chapter.add_screen(WorldScreen(1, 1, 1))

        assert len(chapter.get_modified_screens()) == 0

        chapter[0].mark_modified()
        modified = chapter.get_modified_screens()
        assert len(modified) == 1
        assert modified[0].relative_index == 0

    def test_has_modifications(self):
        """has_modifications returns True if any screen modified."""
        chapter = Chapter(chapter_num=1)
        chapter.add_screen(WorldScreen(0, 1, 0))

        assert chapter.has_modifications() is False

        chapter[0].mark_modified()
        assert chapter.has_modifications() is True


class TestChapterSerialization:
    """Test Chapter serialization."""

    @pytest.fixture
    def sample_chapter(self):
        """Create chapter for serialization tests."""
        chapter = Chapter(chapter_num=2)
        for i in range(5):
            chapter.add_screen(WorldScreen(131 + i, 2, i, parent_world=0xE0))
        return chapter

    def test_to_dict(self, sample_chapter):
        """to_dict produces valid dict."""
        d = sample_chapter.to_dict()

        assert d["chapter_num"] == 2
        assert d["screen_count"] == 5
        assert len(d["screens"]) == 5
        assert "section_breakdown" in d

    def test_from_dict_roundtrip(self, sample_chapter):
        """from_dict(to_dict()) produces equivalent chapter."""
        d = sample_chapter.to_dict()
        restored = Chapter.from_dict(d)

        assert restored.chapter_num == sample_chapter.chapter_num
        assert restored.screen_count == sample_chapter.screen_count


class TestGameWorld:
    """Test GameWorld container."""

    @pytest.fixture
    def sample_world(self):
        """Create GameWorld with partial data."""
        world = GameWorld()
        for ch_num in [1, 2]:
            chapter = Chapter(chapter_num=ch_num)
            for i in range(5):
                global_idx = (ch_num - 1) * 131 + i
                chapter.add_screen(WorldScreen(global_idx, ch_num, i))
            world.add_chapter(chapter)
        return world

    def test_getitem(self, sample_world):
        """Index access by chapter number."""
        ch1 = sample_world[1]
        assert ch1.chapter_num == 1

    def test_getitem_missing(self, sample_world):
        """Missing chapter raises KeyError."""
        with pytest.raises(KeyError):
            _ = sample_world[5]

    def test_iter(self, sample_world):
        """iter() returns chapters in order."""
        chapters = list(sample_world)
        assert len(chapters) == 2
        assert chapters[0].chapter_num == 1
        assert chapters[1].chapter_num == 2

    def test_total_screens(self, sample_world):
        """total_screens sums all chapters."""
        assert sample_world.total_screens == 10

    def test_is_complete(self, sample_world):
        """is_complete checks all chapters exist and are complete."""
        assert sample_world.is_complete is False  # Only 2 chapters, not complete

    def test_get_screen_by_global(self, sample_world):
        """get_screen_by_global finds screen across chapters."""
        screen = sample_world.get_screen_by_global(0)
        assert screen is not None
        assert screen.chapter == 1

        screen2 = sample_world.get_screen_by_global(131)
        assert screen2 is not None
        assert screen2.chapter == 2
