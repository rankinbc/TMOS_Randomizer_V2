"""Failure detector — v4 organic strategy.

Runs over the current placement + templates + abstract flow plan and reports
hard-rule violations:

* **Unreachable screens** — screens not reachable from the chapter's starting
  screen by following navigation pointers. These block gameplay.
* **Disconnected sections** — one section whose placed cells form multiple
  walkable-connected components.
* **Stray templates** — template sections (by (type, era)) that exceed the
  count declared in the abstract flow plan.
* **Non-spatial nav pointers** — pointers that target a screen which is not
  the grid-adjacent cell of the source, excluding building entrance,
  blocked, and Time-Door pairs.

The detector is read-only: it does not mutate placement or screens.
"""

from __future__ import annotations

from collections import defaultdict, deque
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple

from ...core.chapter import Chapter
from ...core.constants import NAV_BLOCKED, NAV_BUILDING_ENTRANCE
from ...core.enums import SectionType
from ...logic.navigation import DIRECTIONS
from ...plan import RandomizationPlan
from ...validation.tiles.edges import ScreenEdges
from .placement import ChapterPlacement
from .repair import _edges_aligned
from .template import DIRECTION_DELTAS, ChapterTemplate, SectionTemplate


# =============================================================================
# Data
# =============================================================================

@dataclass
class FailureReport:
    chapter_num: int
    unreachable_screens: List[int] = field(default_factory=list)
    # (section_id, list of walkable-connected blobs; the largest blob is first)
    disconnected_sections: List[Tuple[int, List[Set[Tuple[int, int]]]]] = field(default_factory=list)
    stray_template_ids: List[int] = field(default_factory=list)
    spatial_nav_mismatches: List[Tuple[int, str, int]] = field(default_factory=list)

    @property
    def is_critical(self) -> bool:
        return bool(self.unreachable_screens) or bool(self.disconnected_sections)

    def summary(self) -> Dict[str, int]:
        return {
            "unreachable": len(self.unreachable_screens),
            "disconnected_sections": len(self.disconnected_sections),
            "stray_templates": len(self.stray_template_ids),
            "spatial_mismatches": len(self.spatial_nav_mismatches),
        }


# =============================================================================
# Entry points
# =============================================================================

def detect_chapter_failures(
    *,
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    plan: RandomizationPlan,
    rom_data: bytes,
    edge_cache: Optional[Dict[int, ScreenEdges]] = None,
    pristine_reachable: Optional[Set[int]] = None,
) -> FailureReport:
    """Produce a full failure report for one chapter.

    ``pristine_reachable`` — set of screen indices reachable from screen 0
    in the unrandomized ROM. Any screen in this set that is now unreachable
    is a regression. If omitted, the detector falls back to simple 0xFE
    filtering (less accurate).
    """
    report = FailureReport(chapter_num=chapter.chapter_num)
    edge_cache = edge_cache if edge_cache is not None else {}

    report.disconnected_sections = _find_disconnected_sections(
        chapter, template, placement, rom_data, edge_cache,
    )
    report.unreachable_screens = _find_unreachable_screens(chapter, pristine_reachable)
    report.stray_template_ids = _find_stray_templates(template, plan)
    report.spatial_nav_mismatches = _find_spatial_mismatches(
        chapter, template, placement,
    )
    return report


def detect_world_failures(
    *,
    chapters: Dict[int, Chapter],
    templates: Dict[int, ChapterTemplate],
    placements: Dict[int, ChapterPlacement],
    plan: RandomizationPlan,
    rom_data: bytes,
    pristine_reachable_by_chapter: Optional[Dict[int, Set[int]]] = None,
) -> Dict[int, FailureReport]:
    reports: Dict[int, FailureReport] = {}
    baseline = pristine_reachable_by_chapter or {}
    for chapter_num in sorted(chapters):
        chapter = chapters[chapter_num]
        template = templates.get(chapter_num)
        placement = placements.get(chapter_num)
        if template is None or placement is None:
            continue
        reports[chapter_num] = detect_chapter_failures(
            chapter=chapter,
            template=template,
            placement=placement,
            plan=plan,
            rom_data=rom_data,
            pristine_reachable=baseline.get(chapter_num),
        )
    return reports


def compute_pristine_reachable(chapters: Dict[int, Chapter]) -> Dict[int, Set[int]]:
    """Run nav-BFS from screen 0 on the unrandomized chapters. Produces a
    per-chapter set that any post-randomization run must preserve."""
    out: Dict[int, Set[int]] = {}
    for chapter_num, chapter in chapters.items():
        out[chapter_num] = _nav_reachable(chapter)
    return out


def _nav_reachable(chapter: Chapter) -> Set[int]:
    total = chapter.screen_count
    if total == 0:
        return set()
    reached: Set[int] = {0}
    queue: deque = deque([0])
    while queue:
        idx = queue.popleft()
        scr = chapter.get_screen(idx)
        if scr is None:
            continue
        for direction in DIRECTIONS:
            tgt = getattr(scr, f"screen_index_{direction}")
            if tgt in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if tgt < 0 or tgt >= total:
                continue
            if tgt in reached:
                continue
            reached.add(tgt)
            queue.append(tgt)
    return reached


# =============================================================================
# Rule 1 — disconnected sections
# =============================================================================

def _find_disconnected_sections(
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> List[Tuple[int, List[Set[Tuple[int, int]]]]]:
    out: List[Tuple[int, List[Set[Tuple[int, int]]]]] = []
    for section in template.sections:
        if section.size < 2:
            continue
        placed = placement.section_positions(section.section_id)
        if len(placed) < 2:
            continue
        blobs = _walkable_components(chapter, placed, rom_data, edge_cache)
        if len(blobs) > 1:
            blobs.sort(key=len, reverse=True)
            out.append((section.section_id, blobs))
    return out


def _walkable_components(
    chapter: Chapter,
    placed: Dict[Tuple[int, int], int],
    rom_data: bytes,
    edge_cache: Dict[int, ScreenEdges],
) -> List[Set[Tuple[int, int]]]:
    """Partition placed cells into walkable-connected blobs using grid adjacency."""
    remaining: Set[Tuple[int, int]] = set(placed.keys())
    components: List[Set[Tuple[int, int]]] = []
    while remaining:
        seed = min(remaining)
        comp: Set[Tuple[int, int]] = {seed}
        queue: deque = deque([seed])
        while queue:
            pos = queue.popleft()
            idx = placed[pos]
            for direction, (dx, dy) in DIRECTION_DELTAS.items():
                npos = (pos[0] + dx, pos[1] + dy)
                if npos not in placed or npos in comp:
                    continue
                if _edges_aligned(
                    chapter=chapter,
                    src_idx=idx,
                    direction=direction,
                    dst_idx=placed[npos],
                    rom_data=rom_data,
                    edge_cache=edge_cache,
                ):
                    comp.add(npos)
                    queue.append(npos)
        components.append(comp)
        remaining -= comp
    return components


# =============================================================================
# Unreachable screens — follow placed-screen nav pointers chapter-wide
# =============================================================================

def _find_unreachable_screens(
    chapter: Chapter,
    pristine_reachable: Optional[Set[int]] = None,
) -> List[int]:
    """Screens the player cannot reach from the starting screen via nav
    pointers in the CURRENT (post-randomization) state.

    When ``pristine_reachable`` is provided, only report screens that WERE
    reachable in the unrandomized ROM but are no longer — actual regressions
    rather than sub-world interiors.
    """
    current = _nav_reachable(chapter)
    if pristine_reachable is not None:
        return sorted(idx for idx in pristine_reachable if idx not in current)

    # Fallback — no baseline. Skip building-entrance hubs as a crude proxy.
    unreachable: List[int] = []
    for screen in chapter:
        idx = screen.relative_index
        if idx in current:
            continue
        if screen.has_building_entrance:
            continue
        unreachable.append(idx)
    return unreachable


# =============================================================================
# Rule 3 — stray templates vs flow plan counts
# =============================================================================

def _find_stray_templates(
    template: ChapterTemplate,
    plan: RandomizationPlan,
) -> List[int]:
    """Template section IDs that exceed the flow plan's declared count for
    their (type, era) bucket.

    Singleton boss/victory/specials (size==1) aren't counted as strays —
    they're always stand-alone even in the flow plan.
    """
    if plan.world_plan is None:
        return []

    # Flow plan counts by (SectionType, is_past).
    flow_counts: Dict[Tuple[SectionType, bool], int] = defaultdict(int)
    for chap in plan.world_plan.chapters:
        if chap.chapter_num != template.chapter_num:
            continue
        for sec in chap.sections:
            flow_counts[(sec.section_type, sec.is_past)] += 1
        break

    # Template counts by (SectionType, is_past), skipping singletons.
    template_buckets: Dict[Tuple[SectionType, bool], List[SectionTemplate]] = defaultdict(list)
    for sec in template.sections:
        if sec.size <= 1:
            continue
        template_buckets[(sec.section_type, sec.is_past)].append(sec)

    strays: List[int] = []
    for key, secs in template_buckets.items():
        allowed = flow_counts.get(key, 1)
        if len(secs) <= allowed:
            continue
        # Keep the largest `allowed` sections; the rest are strays.
        secs_sorted = sorted(secs, key=lambda s: s.size, reverse=True)
        for stray in secs_sorted[allowed:]:
            strays.append(stray.section_id)
    return strays


# =============================================================================
# Rule 2 — non-spatial nav pointers
# =============================================================================

def _find_spatial_mismatches(
    chapter: Chapter,
    template: ChapterTemplate,
    placement: ChapterPlacement,
) -> List[Tuple[int, str, int]]:
    """Intra-section pointers where ``screen[dir]`` targets a screen that is
    in the same section but is not the grid-adjacent cell.

    Cross-section warps are legitimate (overworld → town entrance, etc.) and
    excluded here. Building entrance, blocked, and TD-pair pointers are also
    excluded.
    """
    td_pair: Set[int] = set()
    if template.time_door_pair is not None:
        td_pair = set(template.time_door_pair)

    placement_by_idx: Dict[int, Tuple[int, Tuple[int, int]]] = {}
    section_grids: Dict[int, Dict[Tuple[int, int], int]] = {}
    for sec in template.sections:
        placements = placement.section_positions(sec.section_id)
        section_grids[sec.section_id] = placements
        for pos, idx in placements.items():
            placement_by_idx[idx] = (sec.section_id, pos)

    mismatches: List[Tuple[int, str, int]] = []
    for screen in chapter:
        info = placement_by_idx.get(screen.relative_index)
        if info is None:
            continue
        section_id, pos = info
        grid = section_grids[section_id]
        for direction, (dx, dy) in DIRECTION_DELTAS.items():
            val = getattr(screen, f"screen_index_{direction}")
            if val in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if screen.relative_index in td_pair and val in td_pair:
                continue
            # Cross-section warp — not a bug, just a designed teleport.
            tgt_info = placement_by_idx.get(val)
            if tgt_info is None or tgt_info[0] != section_id:
                continue
            expected_pos = (pos[0] + dx, pos[1] + dy)
            if grid.get(expected_pos) == val:
                continue
            mismatches.append((screen.relative_index, direction, val))
    return mismatches
