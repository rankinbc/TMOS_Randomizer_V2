"""R-003, R-004 — reachability & connectivity.

R-003: at least 95% of screens are reachable from screen 0 via nav bytes,
       stairways, and time doors. ERROR when below 50%, WARNING from 50–94%.
R-004: the chapter is a single connected component (undirected) via those
       same edges.
"""
from __future__ import annotations

from collections import deque

from src.tmos_world.model import Chapter, World, WorldScreen
from src.tmos_world.rom.constants import (
    EVENT_STAIRWAY,
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    TIME_DOOR_CONTENTS,
)
from src.tmos_world.validation.issue import ValidationIssue
from src.tmos_world.validation.rules._registry import register


_NAV_FIELDS = ("nav_right", "nav_left", "nav_down", "nav_up")


def _out_edges(chapter: Chapter, idx: int) -> list[int]:
    """Edges from screen idx (directed). Nav bytes, stairway pair, time door pair."""
    out: list[int] = []
    screen: WorldScreen = chapter.screens[idx]
    for f in _NAV_FIELDS:
        v = getattr(screen, f)
        if v in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
            continue
        if v < chapter.screen_count:
            out.append(v)
    if screen.event == EVENT_STAIRWAY and screen.content < chapter.screen_count:
        out.append(screen.content)
    if screen.content in TIME_DOOR_CONTENTS:
        # Time doors are paired across period — find the other time-door
        # screen in the chapter and add it as a reachability edge.
        for j, other in enumerate(chapter.screens):
            if j == idx:
                continue
            if other.content in TIME_DOOR_CONTENTS:
                out.append(j)
    return out


def _undirected_adj(chapter: Chapter) -> dict[int, set[int]]:
    adj: dict[int, set[int]] = {i: set() for i in range(chapter.screen_count)}
    for i in range(chapter.screen_count):
        for j in _out_edges(chapter, i):
            adj[i].add(j)
            adj[j].add(i)
    return adj


def _bfs(start: int, adj: dict[int, set[int]]) -> set[int]:
    seen: set[int] = {start}
    q: deque[int] = deque([start])
    while q:
        cur = q.popleft()
        for nxt in adj.get(cur, ()):
            if nxt not in seen:
                seen.add(nxt)
                q.append(nxt)
    return seen


def check_r003(world: World, chapter: Chapter) -> list[ValidationIssue]:
    if chapter.screen_count == 0:
        return []
    adj = _undirected_adj(chapter)
    reached = _bfs(0, adj)
    ratio = len(reached) / chapter.screen_count
    if ratio >= 0.95:
        return []
    severity = "ERROR" if ratio < 0.50 else "WARNING"
    return [
        ValidationIssue(
            "R-003",
            severity,
            chapter.number,
            None,
            f"only {len(reached)}/{chapter.screen_count} screens reachable from entry "
            f"({ratio:.1%}); require ≥95% (ERROR below 50%)",
        )
    ]


def check_r004(world: World, chapter: Chapter) -> list[ValidationIssue]:
    if chapter.screen_count == 0:
        return []
    adj = _undirected_adj(chapter)
    seen: set[int] = set()
    components = 0
    for start in range(chapter.screen_count):
        if start in seen:
            continue
        components += 1
        seen |= _bfs(start, adj)
    if components <= 1:
        return []
    return [
        ValidationIssue(
            "R-004",
            "ERROR",
            chapter.number,
            None,
            f"chapter has {components} disconnected components; must be 1",
        )
    ]


register("R-003", check_r003)
register("R-004", check_r004)
