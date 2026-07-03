"""Chapter progression (completability) analysis.

"Navigable" is not "winnable". This module checks, per chapter, that the
story-critical screens are reachable from the chapter start in an order the
engine's progression system can satisfy:

- the chapter's WISEMAN (the NPC whose bank 2 $BC35 script sets the
  chapter's progress flag $03E0-$03E4),
- the chapter's BOSS phase-1 screen, reachable WITHOUT first crossing the
  phase-2 screen (phase order is a data convention the engine never
  enforces — a world that forces phase 2 first soft-locks the story),
- the victory screen after the boss,
- the PAST era, via a time door (present<->past pairing is pure data in
  the $98C0 warp table).

Traversal matches the engine's real transition mechanisms (directional nav
pointers, stairways via Event bit6 + Content destination, $98C0 warp row
opened by any reachable $C0-$DF screen), rooted at the chapter start
screen the password system encodes.

Detection is by CONTENT BYTE, not hardcoded screen indices — the enums'
index tables are ParentWorld-derived and flagged unreliable for Ch5,
while the Content values are code-verified (knowledge/enums/content-types.md).

Sources: randomizer_handoff.md §1-§10, knowledge/systems/
screen-relocation-constraints.md, knowledge/enums/content-types.md.

Deliberately NOT modeled yet (needs RETMOS round 3):
- key/Oprin economy (locked doors gate order only; no documented marker
  identifies WHICH screens are locked doors),
- the 5 VM-script flag IFs' screen sites (wiseman-before-dependent-event
  ordering can't be checked without knowing the dependent screens),
- boss BEATABILITY (stats/allies) as opposed to reachability.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set

from ..core.chapter import Chapter
from ..core.constants import (
    CHAPTER_RESPAWN_SCREENS,
    CHAPTER_START_SCREENS,
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    WARP_DEST_SLOTS_PER_GROUP,
    WARP_DEST_TABLE,
)
from ..core.enums import is_past_screen_index

__all__ = [
    "ProgressionCheck",
    "ProgressionReport",
    "analyze_chapter_progression",
    "analyze_world_progression",
    "WISEMAN_CONTENT_BY_CHAPTER",
    "boss_phase_contents",
]

# Wiseman NPC Content bytes per chapter (code-verified; the wiseman's $BC35
# script sets the chapter's progress flag). Ch4 is MEDIUM confidence.
WISEMAN_CONTENT_BY_CHAPTER: Dict[int, int] = {
    1: 0x85,  # WiseMan Monecom
    2: 0x84,  # Wiseman Raincom
    3: 0x87,  # Wiseman Spricom
    4: 0x86,  # Wiseman (MEDIUM)
    5: 0x80,  # Wiseman Moscom
}

_TIME_DOOR_CONTENTS = {0xC0, 0xC7, 0xD7}

# Content $2B = victory/princess (documented for Ch1; MEDIUM confidence).
_VICTORY_CONTENT = 0x2B


def boss_phase_contents(chapter_num: int) -> tuple[int, int]:
    """(phase-1, phase-2) boss Content bytes native to this chapter.

    $21/$22 Gilga (Ch1) ... $29/$2A GoraGora (Ch5). Chapter-keyed scripts
    and CHR: a boss value outside its native chapter loads the wrong ones.
    """
    p1 = 0x21 + 2 * (chapter_num - 1)
    return p1, p1 + 1


@dataclass
class ProgressionCheck:
    name: str
    passed: bool
    severity: str  # "error" | "warning"
    detail: str


@dataclass
class ProgressionReport:
    chapter_num: int
    checks: List[ProgressionCheck] = field(default_factory=list)

    @property
    def errors(self) -> List[ProgressionCheck]:
        return [c for c in self.checks if not c.passed and c.severity == "error"]

    @property
    def warnings(self) -> List[ProgressionCheck]:
        return [c for c in self.checks if not c.passed and c.severity == "warning"]

    @property
    def ok(self) -> bool:
        return not self.errors

    def _add(self, name: str, passed: bool, severity: str, detail: str) -> None:
        self.checks.append(ProgressionCheck(name, passed, severity, detail))


# ---------------------------------------------------------------------------
# Traversal (engine-true, with root + exclusion support)
# ---------------------------------------------------------------------------

def traverse(
    chapter: Chapter,
    rom_data: Optional[bytes],
    root: int,
    exclude: Optional[Set[int]] = None,
) -> Set[int]:
    """Screens reachable from ``root`` via nav pointers + stairways + the
    $98C0 warp row, never entering (or crossing) ``exclude`` screens.

    ``exclude`` enables ordering proofs: "X reachable without crossing Y".
    An excluded root returns the empty set.
    """
    total = chapter.screen_count
    exclude = exclude or set()
    if total == 0 or not (0 <= root < total) or root in exclude:
        return set()

    warp_row: List[int] = []
    if rom_data:
        off = WARP_DEST_TABLE + (chapter.chapter_num - 1) * WARP_DEST_SLOTS_PER_GROUP
        warp_row = list(rom_data[off : off + WARP_DEST_SLOTS_PER_GROUP])

    reached: Set[int] = {root}
    queue: deque = deque([root])

    def visit(tgt: int) -> None:
        if 0 <= tgt < total and tgt not in reached and tgt not in exclude:
            reached.add(tgt)
            queue.append(tgt)

    while queue:
        idx = queue.popleft()
        scr = chapter.get_screen(idx)
        if scr is None:
            continue
        has_building_nav = False
        for direction in ("right", "left", "down", "up"):
            tgt = getattr(scr, f"screen_index_{direction}")
            if tgt == NAV_BUILDING_ENTRANCE:
                has_building_nav = True
                continue
            if tgt == NAV_BLOCKED:
                continue
            visit(tgt)
        if scr.is_stairway:
            visit(scr.content)
        elif has_building_nav and scr.content < total:
            # Building entrance: a 0xFE nav direction transitions via the
            # screen's Content byte when it holds a valid screen index
            # (vanilla boss approaches and interiors use this).
            visit(scr.content)
        if warp_row and 0xC0 <= scr.content <= 0xDF:
            for dest in warp_row:
                visit(dest)
    return reached


def _screens_with_content(chapter: Chapter, content: int) -> List[int]:
    return [s.relative_index for s in chapter if s.content == content]


# ---------------------------------------------------------------------------
# Analysis
# ---------------------------------------------------------------------------

def analyze_chapter_progression(
    chapter: Chapter,
    rom_data: Optional[bytes] = None,
) -> ProgressionReport:
    """Run every progression check for one chapter."""
    report = ProgressionReport(chapter_num=chapter.chapter_num)
    ch = chapter.chapter_num
    start = CHAPTER_START_SCREENS[ch - 1]
    respawn = CHAPTER_RESPAWN_SCREENS[ch - 1]

    reached = traverse(chapter, rom_data, start)

    # --- Root sanity -------------------------------------------------------
    report._add(
        "respawn_reachable",
        respawn in reached,
        "error",
        f"respawn screen 0x{respawn:02X} "
        f"{'reachable' if respawn in reached else 'NOT reachable'} "
        f"from chapter start 0x{start:02X}",
    )

    # --- Wiseman -----------------------------------------------------------
    wiseman_content = WISEMAN_CONTENT_BY_CHAPTER[ch]
    wisemen = _screens_with_content(chapter, wiseman_content)
    report._add(
        "wiseman_present",
        bool(wisemen),
        "error",
        f"wiseman content 0x{wiseman_content:02X} on screens "
        f"{[hex(i) for i in wisemen]}" if wisemen else
        f"no screen carries wiseman content 0x{wiseman_content:02X}",
    )
    if wisemen:
        reachable_wisemen = [i for i in wisemen if i in reached]
        report._add(
            "wiseman_reachable",
            bool(reachable_wisemen),
            "error",
            f"wiseman screen(s) {[hex(i) for i in reachable_wisemen]} reachable"
            if reachable_wisemen else
            f"wiseman screen(s) {[hex(i) for i in wisemen]} unreachable from start",
        )

    # --- Boss phases -------------------------------------------------------
    p1_content, p2_content = boss_phase_contents(ch)
    p1_screens = _screens_with_content(chapter, p1_content)
    p2_screens = _screens_with_content(chapter, p2_content)

    report._add(
        "boss_phase1_present",
        bool(p1_screens),
        "error",
        f"phase-1 boss (0x{p1_content:02X}) on {[hex(i) for i in p1_screens]}"
        if p1_screens else f"no screen carries phase-1 boss content 0x{p1_content:02X}",
    )
    report._add(
        "boss_phase2_present",
        bool(p2_screens),
        "error",
        f"phase-2 boss (0x{p2_content:02X}) on {[hex(i) for i in p2_screens]}"
        if p2_screens else f"no screen carries phase-2 boss content 0x{p2_content:02X}",
    )

    if p1_screens:
        report._add(
            "boss_phase1_reachable",
            any(i in reached for i in p1_screens),
            "error",
            "phase-1 boss reachable from start"
            if any(i in reached for i in p1_screens)
            else "phase-1 boss unreachable from start",
        )
    # Phase-2 is script-entered (the phase-1 fight transitions into it);
    # it is nav-isolated even in vanilla, so only its PRESENCE is checked.
    # Phase ORDER only matters when the randomized graph makes phase-2
    # walkable: then the player must still be able to reach phase 1
    # without crossing it (the engine never enforces the order itself).
    if p1_screens and p2_screens and any(i in reached for i in p2_screens):
        without_p2 = traverse(chapter, rom_data, start, exclude=set(p2_screens))
        ordered = any(i in without_p2 for i in p1_screens)
        report._add(
            "boss_phase_order",
            ordered,
            "error",
            "phase-1 boss reachable without crossing walkable phase-2"
            if ordered else
            "phase-2 became walkable and every route to phase-1 crosses it",
        )

    # --- Victory (script-entered after the boss; presence only) -------------
    victory = _screens_with_content(chapter, _VICTORY_CONTENT)
    if ch < 5:  # Ch5 ends the game; no victory screen documented.
        report._add(
            "victory_present",
            bool(victory),
            "warning",
            f"victory content 0x{_VICTORY_CONTENT:02X} on "
            f"{[hex(i) for i in victory]}" if victory else
            f"no screen carries victory content 0x{_VICTORY_CONTENT:02X}",
        )

    # --- Time doors + era coverage ------------------------------------------
    doors = [s.relative_index for s in chapter if s.content in _TIME_DOOR_CONTENTS]
    present_doors = [i for i in doors if not is_past_screen_index(ch, i)]
    past_doors = [i for i in doors if is_past_screen_index(ch, i)]
    report._add(
        "time_door_pair",
        bool(present_doors) and bool(past_doors),
        "warning",
        f"time doors: {len(present_doors)} PRESENT + {len(past_doors)} PAST",
    )

    # Era coverage is a WARNING: vanilla Ch5's dark world is reached via
    # mechanisms this traversal doesn't model (RING teleport), so an
    # absolute "must reach PAST" bar would flag the stock game. The organic
    # pipeline's pristine-baseline gate already protects against era
    # coverage REGRESSIONS.
    past_screens = [
        s.relative_index for s in chapter
        if is_past_screen_index(ch, s.relative_index)
    ]
    if past_screens:
        past_reached = [i for i in past_screens if i in reached]
        report._add(
            "past_era_reachable",
            bool(past_reached),
            "warning",
            f"{len(past_reached)}/{len(past_screens)} PAST screens reachable"
            if past_reached else
            f"none of the {len(past_screens)} PAST screens reachable via "
            "nav/stairs/warps (vanilla Ch5 relies on RING teleport here)",
        )

    # --- Warp table sanity ---------------------------------------------------
    if rom_data:
        off = WARP_DEST_TABLE + (ch - 1) * WARP_DEST_SLOTS_PER_GROUP
        row = list(rom_data[off : off + WARP_DEST_SLOTS_PER_GROUP])
        bad = [d for d in row if d != 0 and d >= chapter.screen_count]
        report._add(
            "warp_destinations_valid",
            not bad,
            "warning",
            "all $98C0 warp destinations in range" if not bad else
            f"$98C0 destinations out of range for chapter: {[hex(d) for d in bad]}",
        )

    return report


def analyze_world_progression(
    chapters: Dict[int, Chapter],
    rom_data: Optional[bytes] = None,
) -> Dict[int, ProgressionReport]:
    return {
        num: analyze_chapter_progression(chapter, rom_data)
        for num, chapter in sorted(chapters.items())
    }
