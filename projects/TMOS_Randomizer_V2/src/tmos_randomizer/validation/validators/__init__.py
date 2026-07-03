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
- InteriorExteriorSegregationValidator: Coherence L2 -- overworld must not be
  walkable-adjacent to dungeon-interior screens

Import this module to register all validators with the registry.
"""

# Import validators to register them
from .edge_alignment import EdgeAlignmentValidator
from .edge_compatibility import EdgeCompatibilityValidator
from .interior_exterior_segregation import InteriorExteriorSegregationValidator
from .navigation_consistency import NavigationConsistencyValidator
from .objectset import DataPointerObjectSetValidator
from .parent_world_consistency import ParentWorldConsistencyValidator
from .progression import ProgressionValidator
from .section_flow import SectionFlowValidator
from .spatial_consistency import SpatialConsistencyValidator
from .time_period_isolation import TimePeriodIsolationValidator
from .traversability import ScreenTraversabilityValidator

__all__ = [
    "DataPointerObjectSetValidator",
    "EdgeAlignmentValidator",
    "EdgeCompatibilityValidator",
    "InteriorExteriorSegregationValidator",
    "NavigationConsistencyValidator",
    "ParentWorldConsistencyValidator",
    "ProgressionValidator",
    "ScreenTraversabilityValidator",
    "SectionFlowValidator",
    "SpatialConsistencyValidator",
    "TimePeriodIsolationValidator",
]
