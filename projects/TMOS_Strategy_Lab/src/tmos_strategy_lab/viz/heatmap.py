"""Reachability heatmap overlay for a Candidate.

Per chapter: BFS from screen 0 in the navigation graph and colour each
screen by BFS distance. The overlay is composed over a schematic chapter
grid (one cell per screen).

Gotcha: both imshow calls must share identical ``origin='upper'`` and
``extent=[0, W, H, 0]`` so the overlay registers over the base.
"""
from __future__ import annotations

import math
from collections import deque

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402

from ..models import Candidate  # noqa: E402
from ._shared_viz import chapter_from_candidate  # noqa: E402


def _chapter_distance_matrix(chapter) -> np.ndarray:
    """Return an 8-wide 2D array of BFS distances from screen 0.

    Shape: (rows, 8). Unreached cells = NaN. The 1D relative-index maps to
    (i // 8, i % 8) in the 2D grid.
    """
    n = chapter.screen_count
    rows = int(math.ceil(n / 8.0))
    grid = np.full((rows, 8), np.nan, dtype=float)

    if n == 0:
        return grid

    graph = chapter.build_navigation_graph()
    dist: dict[int, int] = {0: 0}
    q = deque([0])
    while q:
        node = q.popleft()
        for nb in graph.get(node, []):
            if 0 <= nb < n and nb not in dist:
                dist[nb] = dist[node] + 1
                q.append(nb)

    for idx in range(n):
        r, c = divmod(idx, 8)
        if idx in dist:
            grid[r, c] = float(dist[idx])
    return grid


def render_heatmap(candidate: Candidate, cmap: str = "hot_r") -> plt.Figure:
    """One figure per candidate; a vertical stack of per-chapter heatmaps."""
    chapters = sorted(candidate.chapters.keys())
    n = len(chapters)
    fig, axes = plt.subplots(
        n, 1, figsize=(8, max(2 * n, 4)), constrained_layout=True, squeeze=False
    )

    for ax, ch_num in zip(axes[:, 0], chapters, strict=True):
        chapter = chapter_from_candidate(candidate.chapters, ch_num)
        grid = _chapter_distance_matrix(chapter)
        h, w = grid.shape
        extent = [0, w, h, 0]
        # Base: a uniform grid so empty cells don't flash.
        base = np.zeros_like(grid)
        ax.imshow(base, origin="upper", extent=extent, cmap="Greys_r", vmin=0, vmax=1)
        im = ax.imshow(
            grid,
            origin="upper",
            extent=extent,
            cmap=cmap,
            alpha=0.85,
        )
        ax.set_title(f"Chapter {ch_num} — walk-distance from screen 0")
        ax.set_xticks(range(w + 1))
        ax.set_yticks(range(h + 1))
        ax.grid(color="#444", linewidth=0.5)
        fig.colorbar(im, ax=ax, fraction=0.03)

    return fig


__all__ = ["render_heatmap"]
