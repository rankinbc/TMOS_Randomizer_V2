"""ObjectSet ↔ DataPointer compatibility (§4.1 D-4).

The ``get_compatible_objectsets(datapointer) -> set[int]`` table lives in V2
core.constants; re-exported here so Lab metrics import from one place.
"""
from __future__ import annotations

from . import V2_AVAILABLE

if V2_AVAILABLE:
    from tmos_randomizer.core.constants import (  # type: ignore[import-untyped]
        OBJECTSET_COMPATIBILITY,
        get_chr_index,
        get_compatible_objectsets,
        validate_objectset_compatibility,
    )
else:  # pragma: no cover
    OBJECTSET_COMPATIBILITY: dict[int, set[int]] = {}

    def get_chr_index(datapointer: int) -> int:
        return datapointer & 0x3F

    def get_compatible_objectsets(datapointer: int) -> set[int]:
        return {0x00}

    def validate_objectset_compatibility(datapointer: int, objectset: int) -> bool:
        return True


__all__ = [
    "OBJECTSET_COMPATIBILITY",
    "get_chr_index",
    "get_compatible_objectsets",
    "validate_objectset_compatibility",
]
