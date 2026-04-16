"""Tests for EdgeAlignmentValidator.

We monkeypatch ``extract_edges`` so tests can supply precise edge tiles
per-screen without needing to craft a real ROM. Tile IDs: 0x80 is a known
walkable grass tile (category WALKABLE); 0x22 is a tree (COLLIDABLE).
"""

from __future__ import annotations

from typing import Dict, List

import pytest

from tmos_randomizer.core.chapter import Chapter
from tmos_randomizer.core.worldscreen import WorldScreen
from tmos_randomizer.validation.base import Severity
from tmos_randomizer.validation.config import EdgeAlignmentConfig
from tmos_randomizer.validation.tiles.categories import is_walkable
from tmos_randomizer.validation.tiles.edges import ScreenEdges
from tmos_randomizer.validation.validators import edge_alignment as edge_alignment_module
from tmos_randomizer.validation.validators.edge_alignment import EdgeAlignmentValidator


# 0x20 is WALKABLE (grass), 0x22 is a tree (COLLIDABLE) — verify here so
# downstream assumptions don't silently rot.
def _sanity_check_tile_categories():
    assert is_walkable(0x20)
    assert not is_walkable(0x22)


_sanity_check_tile_categories()


WALK = 0x20
TREE = 0x22
CH = 2


def _screen(relative_index: int, **nav) -> WorldScreen:
    defaults = dict(
        global_index=relative_index,
        chapter=CH,
        relative_index=relative_index,
        screen_index_right=0xFF,
        screen_index_left=0xFF,
        screen_index_down=0xFF,
        screen_index_up=0xFF,
    )
    defaults.update(nav)
    return WorldScreen(**defaults)


def _chapter(*screens: WorldScreen) -> Chapter:
    return Chapter(chapter_num=CH, screens=list(screens))


def _install_edges(monkeypatch, edges_by_index: Dict[int, ScreenEdges]) -> None:
    """Patch ``extract_edges`` inside the edge_alignment module.

    Returns precooked ScreenEdges per screen index; other indices raise to
    force test authors to be explicit.
    """
    def _fake_extract(rom_data, screen_index, top_tiles, bottom_tiles, datapointer):
        if screen_index not in edges_by_index:
            raise KeyError(f"Test did not provide edges for screen {screen_index:#x}")
        return edges_by_index[screen_index]

    monkeypatch.setattr(edge_alignment_module, "extract_edges", _fake_extract)


def _edges(index: int, *, top=None, bottom=None, left=None, right=None) -> ScreenEdges:
    # Defaults: 8-tile horizontal edges + 6-tile vertical edges. All WALK
    # unless overridden.
    return ScreenEdges(
        screen_index=index,
        top=list(top) if top is not None else [WALK] * 8,
        bottom=list(bottom) if bottom is not None else [WALK] * 8,
        left=list(left) if left is not None else [WALK] * 6,
        right=list(right) if right is not None else [WALK] * 6,
    )


# ----------------------------------------------------------------------
# Horizontal edge alignment (right ↔ left)
# ----------------------------------------------------------------------


class TestHorizontalAlignment:
    def test_flags_disjoint_walkable_columns(self, monkeypatch):
        """A's right edge has WALK at row 0 only; B's left edge at row 5 only."""
        a = _screen(0x0C, screen_index_right=0x5E)
        b = _screen(0x5E)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x0C: _edges(0x0C, right=[WALK, TREE, TREE, TREE, TREE, TREE]),
            0x5E: _edges(0x5E, left=[TREE, TREE, TREE, TREE, TREE, WALK]),
        })

        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert len(issues) == 1
        issue = issues[0]
        assert issue.severity == Severity.ERROR
        assert issue.screen_index == 0x0C
        assert issue.direction == "right"
        assert issue.details["aligned_indices"] == []
        assert issue.details["source_walkable_indices"] == [0]
        assert issue.details["target_walkable_indices"] == [5]

    def test_passes_when_walkable_aligns(self, monkeypatch):
        a = _screen(0x0C, screen_index_right=0x5E)
        b = _screen(0x5E)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x0C: _edges(0x0C, right=[WALK, WALK, TREE, TREE, TREE, TREE]),
            0x5E: _edges(0x5E, left=[WALK, TREE, TREE, TREE, TREE, TREE]),
        })

        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert issues == []

    def test_left_direction_also_checked(self, monkeypatch):
        a = _screen(0x01, screen_index_left=0x02)
        b = _screen(0x02)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x01: _edges(0x01, left=[TREE] * 6),
            0x02: _edges(0x02, right=[WALK] * 6),
        })

        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert len(issues) == 1
        assert issues[0].direction == "left"


# ----------------------------------------------------------------------
# Vertical edge alignment (down ↔ up)
# ----------------------------------------------------------------------


class TestVerticalAlignment:
    def test_flags_tree_row_bottom(self, monkeypatch):
        """Matches the user-reported bug: screen A's bottom row is trees,
        so walking down into screen B is blocked despite B's top being open.
        """
        a = _screen(0x0C, screen_index_down=0x5C)
        b = _screen(0x5C)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x0C: _edges(0x0C, bottom=[TREE] * 8),
            0x5C: _edges(0x5C, top=[WALK] * 8),
        })

        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert len(issues) == 1
        assert issues[0].direction == "down"
        assert issues[0].details["aligned_indices"] == []


# ----------------------------------------------------------------------
# Config knobs
# ----------------------------------------------------------------------


class TestConfig:
    def test_min_aligned_walkable_can_be_raised(self, monkeypatch):
        """Require >=2 aligned walkable tiles — a single aligned tile fails."""
        a = _screen(0x0C, screen_index_right=0x5E)
        b = _screen(0x5E)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x0C: _edges(0x0C, right=[WALK, TREE, TREE, TREE, TREE, TREE]),
            0x5E: _edges(0x5E, left=[WALK, TREE, TREE, TREE, TREE, TREE]),
        })

        validator = EdgeAlignmentValidator(EdgeAlignmentConfig(min_aligned_walkable=2))
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert len(issues) == 1

    def test_disabling_horizontal_check(self, monkeypatch):
        a = _screen(0x0C, screen_index_right=0x5E)
        b = _screen(0x5E)
        chapter = _chapter(a, b)

        _install_edges(monkeypatch, {
            0x0C: _edges(0x0C, right=[TREE] * 6),
            0x5E: _edges(0x5E, left=[TREE] * 6),
        })

        validator = EdgeAlignmentValidator(EdgeAlignmentConfig(check_horizontal=False))
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})

        assert issues == []

    def test_requires_rom_data(self):
        chapter = _chapter(_screen(0x0C))
        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={})
        assert len(issues) == 1
        assert issues[0].severity == Severity.WARNING
        assert "ROM data" in issues[0].message

    def test_disabled_validator_returns_empty(self, monkeypatch):
        chapter = _chapter(_screen(0x0C, screen_index_right=0x5E), _screen(0x5E))
        validator = EdgeAlignmentValidator(EdgeAlignmentConfig(enabled=False))
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})
        assert issues == []

    def test_ignores_blocked_and_building_nav(self, monkeypatch):
        a = _screen(0x0C, screen_index_right=0xFF, screen_index_down=0xFE)
        chapter = _chapter(a)

        # Patch even though we don't expect calls — if the validator wrongly
        # tries to resolve 0xFF/0xFE it'll fail loudly.
        _install_edges(monkeypatch, {0x0C: _edges(0x0C)})

        validator = EdgeAlignmentValidator()
        issues = validator.validate_chapter(chapter, context={"rom_data": b"dummy"})
        assert issues == []
