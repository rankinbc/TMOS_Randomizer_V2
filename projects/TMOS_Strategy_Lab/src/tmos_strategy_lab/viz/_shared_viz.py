"""Internal helpers shared by viz primitives.

Imports from ``metrics._shared`` so viz modules don't reach into metrics directly.
"""
from __future__ import annotations

from ..metrics._shared import chapter_from_candidate

__all__ = ["chapter_from_candidate"]
