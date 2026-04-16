"""Phase A — Extract section templates from the original ROM.

A ``ChapterTemplate`` is the spatial skeleton we derived from the unrandomized
chapter: which section components exist, what shape each has on the chapter
grid, what screens were fixed (boss/victory/time door), what inter-section
connections existed, and what exit mask each grid position originally had.

The extraction is deterministic — same ROM in, same template out.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

from ...core.chapter import Chapter, GameWorld
from ...core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from ...core.enums import (
    PARENTWORLD_TO_SECTION,
    SectionType,
    is_past_screen_index,
)
from ...core.worldscreen import WorldScreen
from ...logic.exclusions import is_excluded
from ...logic.navigation import DIRECTIONS


DIRECTION_DELTAS: Dict[str, Tuple[int, int]] = {
    "right": (1, 0),
    "left": (-1, 0),
    "down": (0, 1),
    "up": (0, -1),
}

TIME_DOOR_CONTENTS = {0xC0, 0xC7, 0xD7}


@dataclass(frozen=True)
class InterSectionEdge:
    """A directional link between two sections in the original ROM."""
    from_section_id: int
    from_screen: int
    direction: str
    to_section_id: int
    to_screen: int


@dataclass
class SectionTemplate:
    """Spatial template for one section of one chapter.

    ``positions`` gives the (x, y) grid coordinate of every screen that was
    part of this component in the original ROM. ``original_exit_mask`` says
    which of the four directions each grid position had a real exit in —
    placement + nav-write uses this so we never light up a direction that
    the original tileset blocked on that screen.
    """
    section_id: int
    section_type: SectionType
    is_past: bool
    # original rel_index -> (x, y)
    positions: Dict[int, Tuple[int, int]]
    fixed_screens: FrozenSet[int] = frozenset()
    time_door_id: Optional[int] = None
    stairway_pairs: List[Tuple[int, int]] = field(default_factory=list)
    building_entrance_screens: FrozenSet[int] = frozenset()
    # grid position -> set of directions that had valid exits
    original_exit_mask: Dict[Tuple[int, int], FrozenSet[str]] = field(default_factory=dict)

    @property
    def size(self) -> int:
        return len(self.positions)

    @property
    def grid_to_screen(self) -> Dict[Tuple[int, int], int]:
        """Inverse of ``positions`` — (x, y) → original screen idx."""
        return {pos: idx for idx, pos in self.positions.items()}


@dataclass
class ChapterTemplate:
    """Templates for every section in a single chapter."""
    chapter_num: int
    sections: List[SectionTemplate]
    inter_section_edges: List[InterSectionEdge]
    time_door_pair: Optional[Tuple[int, int]] = None  # (present_idx, past_idx)

    def section_of(self, screen_idx: int) -> Optional[SectionTemplate]:
        for sec in self.sections:
            if screen_idx in sec.positions:
                return sec
        return None


# =============================================================================
# Extraction
# =============================================================================

def extract_chapter_template(chapter: Chapter) -> ChapterTemplate:
    """Build a ChapterTemplate from an unrandomized Chapter.

    Screens are grouped into connected components by walking the original
    navigation pointers, but only across screens that share
    ``(section_type, is_past)``. Each resulting component is one section.
    """
    ch_num = chapter.chapter_num
    visited: Set[int] = set()
    sections: List[SectionTemplate] = []
    next_section_id = 1

    for screen in chapter:
        if screen.relative_index in visited:
            continue
        if is_excluded(screen):
            # Excluded screens (original bosses, victory, etc.) still belong
            # to *some* component, but we skip them as seeds so they don't
            # pull random neighbours through an excluded hub.
            continue

        component = _bfs_component(chapter, screen, visited)
        if not component:
            continue

        sections.append(_build_section_template(
            chapter, component, section_id=next_section_id
        ))
        next_section_id += 1

    # Sweep up any excluded screens that weren't absorbed into a component
    # via the BFS (isolated boss/victory screens) — each becomes its own
    # singleton section so the navigation writer knows not to overwrite them.
    for screen in chapter:
        if screen.relative_index in visited:
            continue
        component = {screen.relative_index}
        visited.add(screen.relative_index)
        sections.append(_build_section_template(
            chapter, component, section_id=next_section_id
        ))
        next_section_id += 1

    inter = _extract_inter_section_edges(chapter, sections)
    td_pair = _find_time_door_pair(chapter)

    return ChapterTemplate(
        chapter_num=ch_num,
        sections=sections,
        inter_section_edges=inter,
        time_door_pair=td_pair,
    )


def extract_world_templates(game_world: GameWorld) -> Dict[int, ChapterTemplate]:
    """Extract ChapterTemplates for every chapter in the game world."""
    return {
        chapter.chapter_num: extract_chapter_template(chapter)
        for chapter in game_world
    }


# =============================================================================
# Internals
# =============================================================================

def _classify(chapter: Chapter, screen: WorldScreen) -> Tuple[SectionType, bool]:
    """Classify a screen as (section_type, is_past)."""
    section_type = PARENTWORLD_TO_SECTION.get(screen.parent_world, SectionType.UNKNOWN)
    past = is_past_screen_index(chapter.chapter_num, screen.relative_index)
    return section_type, past


def _bfs_component(
    chapter: Chapter,
    seed_screen: WorldScreen,
    visited: Set[int],
) -> Set[int]:
    """Grow a connected component starting from seed_screen.

    Crosses only screens sharing the seed's (section_type, is_past). Skips
    excluded (do-not-randomize) screens — they anchor in place but don't
    participate in content shuffle.
    """
    seed_class = _classify(chapter, seed_screen)
    component: Set[int] = set()
    queue: deque[int] = deque([seed_screen.relative_index])

    while queue:
        idx = queue.popleft()
        if idx in visited:
            continue
        scr = chapter.get_screen(idx)
        if scr is None:
            continue
        if is_excluded(scr):
            continue
        if _classify(chapter, scr) != seed_class:
            continue

        visited.add(idx)
        component.add(idx)

        for direction in DIRECTIONS:
            neighbor = getattr(scr, f"screen_index_{direction}")
            if neighbor in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if neighbor >= chapter.screen_count:
                continue
            if neighbor in visited:
                continue
            queue.append(neighbor)

    return component


def _build_section_template(
    chapter: Chapter,
    screen_indices: Set[int],
    section_id: int,
) -> SectionTemplate:
    """Lay out a component on a 2-D grid and record its metadata."""
    if not screen_indices:
        return SectionTemplate(
            section_id=section_id,
            section_type=SectionType.UNKNOWN,
            is_past=False,
            positions={},
        )

    anchor_idx = min(screen_indices)
    anchor = chapter.get_screen(anchor_idx)
    section_type, is_past = _classify(chapter, anchor) if anchor else (SectionType.UNKNOWN, False)

    positions = _layout_grid(chapter, screen_indices, start=anchor_idx)

    fixed = frozenset(
        idx for idx in screen_indices
        if _is_fixed_screen(chapter.get_screen(idx))
    )

    td_id: Optional[int] = None
    building_entrances: Set[int] = set()
    stairway_pairs: List[Tuple[int, int]] = []
    exit_mask: Dict[Tuple[int, int], FrozenSet[str]] = {}

    seen_stairway: Set[int] = set()
    for idx in screen_indices:
        scr = chapter.get_screen(idx)
        if scr is None:
            continue
        if scr.content in TIME_DOOR_CONTENTS:
            td_id = idx
        if scr.has_building_entrance:
            building_entrances.add(idx)
        if scr.is_stairway and idx not in seen_stairway:
            dest = scr.stairway_destination
            if (
                dest is not None
                and dest in screen_indices
                and dest != idx
                and dest not in seen_stairway
            ):
                stairway_pairs.append((idx, dest))
                seen_stairway.add(idx)
                seen_stairway.add(dest)

        pos = positions.get(idx)
        if pos is not None:
            exit_mask[pos] = _exit_directions_for(scr, chapter.screen_count)

    return SectionTemplate(
        section_id=section_id,
        section_type=section_type,
        is_past=is_past,
        positions=positions,
        fixed_screens=fixed,
        time_door_id=td_id,
        stairway_pairs=stairway_pairs,
        building_entrance_screens=frozenset(building_entrances),
        original_exit_mask=exit_mask,
    )


def _is_fixed_screen(screen: Optional[WorldScreen]) -> bool:
    """Screens that must keep their original index after randomization."""
    if screen is None:
        return False
    if is_excluded(screen):
        return True
    if screen.content in TIME_DOOR_CONTENTS:
        return True
    return False


def _exit_directions_for(screen: WorldScreen, chapter_screen_count: int) -> FrozenSet[str]:
    """Directions the original screen has a valid exit in.

    Building-entrance (0xFE) counts as an exit slot — the nav writer must
    preserve it regardless of grid neighbours.
    """
    result: Set[str] = set()
    for direction in DIRECTIONS:
        target = getattr(screen, f"screen_index_{direction}")
        if target == NAV_BUILDING_ENTRANCE:
            result.add(direction)
            continue
        if target == NAV_BLOCKED:
            continue
        if target >= chapter_screen_count:
            continue
        result.add(direction)
    return frozenset(result)


def _layout_grid(
    chapter: Chapter,
    screen_indices: Set[int],
    start: int,
) -> Dict[int, Tuple[int, int]]:
    """BFS-lay every screen in the component onto a 2-D grid."""
    positions: Dict[int, Tuple[int, int]] = {start: (0, 0)}
    occupied: Dict[Tuple[int, int], int] = {(0, 0): start}
    queue: deque[int] = deque([start])
    visited_local: Set[int] = {start}

    while queue:
        idx = queue.popleft()
        scr = chapter.get_screen(idx)
        if scr is None:
            continue

        x, y = positions[idx]
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            neighbor = getattr(scr, f"screen_index_{direction}")
            if neighbor in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if neighbor >= chapter.screen_count:
                continue
            if neighbor not in screen_indices:
                continue
            if neighbor in visited_local:
                continue

            pos = (x + dx, y + dy)
            if pos in occupied:
                # Two different neighbours claim the same spot. Keep the
                # first-seen assignment; the late arrival is still logged as
                # part of the section (via a free position) so it can host
                # a screen.
                pos = _first_free_near(pos, occupied)

            positions[neighbor] = pos
            occupied[pos] = neighbor
            visited_local.add(neighbor)
            queue.append(neighbor)

    # Any unreachable screens (shouldn't happen for true connected components
    # but guard anyway): park them at a fresh row beneath the rest.
    if len(positions) != len(screen_indices):
        next_y = max(p[1] for p in positions.values()) + 2
        x = 0
        for idx in sorted(screen_indices):
            if idx in positions:
                continue
            while (x, next_y) in occupied:
                x += 1
            positions[idx] = (x, next_y)
            occupied[(x, next_y)] = idx
            x += 1

    return positions


def _first_free_near(
    target: Tuple[int, int],
    occupied: Dict[Tuple[int, int], int],
) -> Tuple[int, int]:
    """Find the nearest empty grid cell to ``target`` via expanding rings."""
    if target not in occupied:
        return target
    for radius in range(1, 50):
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                if abs(dx) != radius and abs(dy) != radius:
                    continue
                candidate = (target[0] + dx, target[1] + dy)
                if candidate not in occupied:
                    return candidate
    # Fallback — extremely unlikely to hit.
    return (target[0] + 1000, target[1] + 1000)


def _extract_inter_section_edges(
    chapter: Chapter,
    sections: List[SectionTemplate],
) -> List[InterSectionEdge]:
    """Find directional edges that cross section boundaries.

    These are permitted cross-section connections — e.g., the overworld screen
    whose right edge enters a town. We record them so the nav writer can
    re-establish the link against the *placed* screens in each section.

    Cross-time-period edges (PRESENT↔PAST) are dropped here — the only
    sanctioned cross-time traversal is the Time Door pair, handled separately
    by the nav writer. Keeping them would re-seed the exact bug this whole
    strategy exists to prevent.
    """
    owner: Dict[int, int] = {}
    section_past: Dict[int, bool] = {}
    for sec in sections:
        section_past[sec.section_id] = sec.is_past
        for idx in sec.positions:
            owner[idx] = sec.section_id
        for idx in sec.fixed_screens:
            owner.setdefault(idx, sec.section_id)

    edges: List[InterSectionEdge] = []
    for screen in chapter:
        src_sec = owner.get(screen.relative_index)
        if src_sec is None:
            continue
        for direction in DIRECTIONS:
            target = getattr(screen, f"screen_index_{direction}")
            if target in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if target >= chapter.screen_count:
                continue
            tgt_sec = owner.get(target)
            if tgt_sec is None or tgt_sec == src_sec:
                continue
            # Drop cross-time links — only Time Doors bridge eras and they're
            # handled by the nav writer's TD-pair step.
            if section_past.get(src_sec) != section_past.get(tgt_sec):
                continue
            edges.append(InterSectionEdge(
                from_section_id=src_sec,
                from_screen=screen.relative_index,
                direction=direction,
                to_section_id=tgt_sec,
                to_screen=target,
            ))
    return edges


def _find_time_door_pair(chapter: Chapter) -> Optional[Tuple[int, int]]:
    """Return (present_td_idx, past_td_idx) if both exist."""
    present: Optional[int] = None
    past: Optional[int] = None
    for screen in chapter:
        if screen.content not in TIME_DOOR_CONTENTS:
            continue
        if is_past_screen_index(chapter.chapter_num, screen.relative_index):
            past = screen.relative_index
        else:
            present = screen.relative_index
    if present is None or past is None:
        return None
    return (present, past)
