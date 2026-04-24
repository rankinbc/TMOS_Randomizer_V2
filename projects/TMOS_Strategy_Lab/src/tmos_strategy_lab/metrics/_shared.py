"""Shared helpers used by multiple metrics.

Rebuilds V2 ``Chapter`` / ``WorldScreen`` objects from a Candidate's
dict-form chapters so metrics can use V2's graph helpers directly.
"""
from __future__ import annotations

from typing import Any

from .._v2_compat.parsers import Chapter, WorldScreen


def screens_for_chapter(candidate_chapters: dict[int, list[dict[str, Any]]], ch_num: int) -> list[WorldScreen]:
    rows = candidate_chapters.get(ch_num, [])
    return [WorldScreen.from_dict(row) for row in rows]


def chapter_from_candidate(
    candidate_chapters: dict[int, list[dict[str, Any]]], ch_num: int
) -> Chapter:
    chapter = Chapter(chapter_num=ch_num)
    for screen in screens_for_chapter(candidate_chapters, ch_num):
        chapter.add_screen(screen)
    return chapter


def iter_candidate_chapters(candidate_chapters: dict[int, list[dict[str, Any]]]):
    for ch_num in sorted(candidate_chapters.keys()):
        yield ch_num, chapter_from_candidate(candidate_chapters, ch_num)


__all__ = ["chapter_from_candidate", "iter_candidate_chapters", "screens_for_chapter"]
