"""Validator implementations.

This package contains all concrete validator implementations:
- EdgeCompatibilityValidator: Validates edge walkability matching
- EdgeAlignmentValidator: Requires walkable tiles to align across connected edges
- ScreenTraversabilityValidator: Validates within-screen paths
- DataPointerObjectSetValidator: Validates CHR bank compatibility
- NavigationConsistencyValidator: Validates navigation bidirectionality
- SectionFlowValidator: Validates planned section flow matches actual result
- SpatialConsistencyValidator: Validates navigation grid has no spatial conflicts
- TimePeriodIsolationValidator: Flags cross-time navigation without Time Doors
- ItemGatingValidator: Reports item-gated winnability per chapter (INFO only)

Import this module to register all validators with the registry.
"""

# Import validators to register them
from .edge_alignment import EdgeAlignmentValidator
from .edge_compatibility import EdgeCompatibilityValidator
from .navigation_consistency import NavigationConsistencyValidator
from .objectset import DataPointerObjectSetValidator
from .section_flow import SectionFlowValidator
from .spatial_consistency import SpatialConsistencyValidator
from .time_period_isolation import TimePeriodIsolationValidator
from .traversability import ScreenTraversabilityValidator

# Item-gating winnability detector (INFO-only; never fail-closes). Lives in its
# own package; imported here so it registers alongside the core validators.
from ..item_gating.validator import ItemGatingValidator

__all__ = [
    "DataPointerObjectSetValidator",
    "EdgeAlignmentValidator",
    "EdgeCompatibilityValidator",
    "ItemGatingValidator",
    "NavigationConsistencyValidator",
    "ScreenTraversabilityValidator",
    "SectionFlowValidator",
    "SpatialConsistencyValidator",
    "TimePeriodIsolationValidator",
]
