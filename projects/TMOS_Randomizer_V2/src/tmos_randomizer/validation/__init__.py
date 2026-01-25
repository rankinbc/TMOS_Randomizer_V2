"""TMOS Randomizer Validation Framework.

This package provides a modular, configurable validation system
for ensuring randomized maps are playable.

Main Components:
- Validator: Base class for all validators
- ValidatorRegistry: Central registry for validator discovery
- ValidationRunner: Orchestrates validators
- ValidationConfig: Configuration for the framework

Example:
    from tmos_randomizer.validation import (
        ValidationRunner,
        ValidationConfig,
        ValidationPhase,
    )

    # Create runner with default config
    config = ValidationConfig()
    runner = ValidationRunner(config)

    # Run all validators
    result = runner.run_all(game_world, {"rom_data": rom_bytes})

    if not result.is_valid:
        for issue in result.errors:
            print(issue)
"""

from .base import (
    Validator,
    ValidatorRegistry,
    ValidatorConfig,
    ValidationIssue,
    ValidationPhase,
    Severity,
    register_validator,
)
from .config import (
    ValidationConfig,
    EdgeCompatibilityConfig,
    ScreenTraversabilityConfig,
    DataPointerObjectSetConfig,
    NavigationConfig,
    ReachabilityConfig,
    SectionFlowConfig,
)
from .runner import ValidationRunner, ValidationResult

# Import validators to register them with the registry
# (imports trigger the @register_validator decorator)
from . import validators

__all__ = [
    # Base classes
    "Validator",
    "ValidatorRegistry",
    "ValidatorConfig",
    "ValidationIssue",
    "ValidationPhase",
    "Severity",
    "register_validator",
    # Configuration
    "ValidationConfig",
    "EdgeCompatibilityConfig",
    "ScreenTraversabilityConfig",
    "DataPointerObjectSetConfig",
    "NavigationConfig",
    "ReachabilityConfig",
    "SectionFlowConfig",
    # Runner
    "ValidationRunner",
    "ValidationResult",
]
