"""Rendering primitives for the Lab visualizer component.

Four capabilities per REQUIREMENTS.md §4.5:
  * ``tile_render.render_candidate``      — per-chapter tile-art grid
  * ``distributions.plot_metric_distributions`` — histogram + ECDF per metric
  * ``diff.render_diff``                   — side-by-side Candidate diff
  * ``heatmap.render_heatmap``             — reachability walk-distance overlay
"""
from __future__ import annotations

# Lazy re-export — callers import explicit submodules to avoid pulling in
# matplotlib unless they need it.
__all__ = ["tile_render", "distributions", "diff", "heatmap"]
