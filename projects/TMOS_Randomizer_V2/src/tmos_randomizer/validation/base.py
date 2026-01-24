"""Base classes for the validation framework.

This module provides the foundation for all validators:
- Validator: Abstract base class for validators
- ValidatorRegistry: Central registry for validator discovery
- ValidationIssue: Data class for validation findings
- Severity: Enum for issue severity levels
- ValidationPhase: Enum for when validators can run
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Any, Dict, List, Optional, Set, Type, TYPE_CHECKING

if TYPE_CHECKING:
    from ..core.chapter import Chapter, GameWorld


class ValidationPhase(Enum):
    """When a validator can run in the randomization pipeline."""

    DURING_PLANNING = auto()      # Phase 1: Before any changes
    DURING_SHAPING = auto()       # Phase 2: After section shapes defined
    DURING_CONNECTION = auto()    # Phase 3: After connections established
    DURING_POPULATION = auto()    # Phase 4: After screen assignments
    DURING_NAVIGATION = auto()    # Phase 5: After navigation rewritten
    FINAL = auto()                # Phase 6: Final validation pass
    ANY = auto()                  # Can run at any phase


class Severity(Enum):
    """Validation issue severity levels."""

    ERROR = "error"         # Breaks the game - must fix
    WARNING = "warning"     # May cause problems - should review
    INFO = "info"           # Informational only

    @classmethod
    def from_string(cls, value: str) -> "Severity":
        """Parse severity from string.

        Args:
            value: Severity string ("error", "warning", "info")

        Returns:
            Corresponding Severity enum value
        """
        value_lower = value.lower()
        for severity in cls:
            if severity.value == value_lower:
                return severity
        return cls.ERROR  # Default to ERROR if unknown


@dataclass(frozen=True)
class ValidationIssue:
    """A single validation finding.

    Attributes:
        validator_id: Which validator found this issue
        severity: How serious the issue is
        message: Human-readable description
        screen_index: Screen index where issue was found (optional)
        chapter_num: Chapter where issue was found (optional)
        category: Sub-category within the validator (optional)
        direction: Navigation direction related to issue (optional)
        details: Additional debugging information
    """

    validator_id: str
    severity: Severity
    message: str

    # Location context (all optional)
    screen_index: Optional[int] = None
    chapter_num: Optional[int] = None
    category: Optional[str] = None
    direction: Optional[str] = None

    # Additional context for debugging
    details: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization."""
        return {
            "validator_id": self.validator_id,
            "severity": self.severity.value,
            "message": self.message,
            "category": self.category,
            "chapter_num": self.chapter_num,
            "screen_index": self.screen_index,
            "direction": self.direction,
            "details": self.details,
        }

    def __str__(self) -> str:
        """Human-readable string representation."""
        location = ""
        if self.chapter_num is not None:
            location = f"[Ch{self.chapter_num}"
            if self.screen_index is not None:
                location += f" Scr{self.screen_index}"
            if self.direction:
                location += f" {self.direction}"
            location += "] "
        return f"{self.severity.value.upper()}: {location}{self.message}"


@dataclass
class ValidatorConfig:
    """Configuration for a single validator.

    Attributes:
        enabled: Whether this validator should run
        severity_override: Override the validator's default severity
        parameters: Validator-specific configuration parameters
    """

    enabled: bool = True
    severity_override: Optional[Severity] = None
    parameters: Dict[str, Any] = field(default_factory=dict)


class Validator(ABC):
    """Abstract base class for all validators.

    Validators check for specific issues in the randomized world.
    Each validator has a unique ID and can run at specific phases.

    Class Attributes:
        VALIDATOR_ID: Unique identifier for this validator
        DISPLAY_NAME: Human-readable name
        DESCRIPTION: What this validator checks
        DEFAULT_SEVERITY: Default severity for issues from this validator
        SUPPORTED_PHASES: When this validator can run

    Example:
        @register_validator
        class MyValidator(Validator):
            VALIDATOR_ID = "my_validator"
            DISPLAY_NAME = "My Validator"
            DEFAULT_SEVERITY = Severity.WARNING
            SUPPORTED_PHASES = {ValidationPhase.FINAL}

            def validate_chapter(self, chapter, context):
                # Check for issues
                return self._issues
    """

    # Class-level metadata (override in subclasses)
    VALIDATOR_ID: str = "base"
    DISPLAY_NAME: str = "Base Validator"
    DESCRIPTION: str = "Base validator class - do not use directly"
    DEFAULT_SEVERITY: Severity = Severity.ERROR
    SUPPORTED_PHASES: Set[ValidationPhase] = {ValidationPhase.FINAL}

    def __init__(self, config: Optional[ValidatorConfig] = None):
        """Initialize the validator.

        Args:
            config: Configuration for this validator
        """
        self.config = config or ValidatorConfig()
        self._issues: List[ValidationIssue] = []

    @property
    def is_enabled(self) -> bool:
        """Check if this validator is enabled."""
        return self.config.enabled

    @property
    def effective_severity(self) -> Severity:
        """Get the effective severity (config override or default)."""
        return self.config.severity_override or self.DEFAULT_SEVERITY

    def add_issue(
        self,
        message: str,
        severity: Optional[Severity] = None,
        screen_index: Optional[int] = None,
        chapter_num: Optional[int] = None,
        category: Optional[str] = None,
        direction: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
    ) -> None:
        """Add a validation issue.

        Args:
            message: Human-readable description of the issue
            severity: Override severity (uses effective_severity if None)
            screen_index: Screen index where issue was found
            chapter_num: Chapter where issue was found
            category: Sub-category within this validator
            direction: Navigation direction related to issue
            details: Additional debugging information
        """
        self._issues.append(ValidationIssue(
            validator_id=self.VALIDATOR_ID,
            severity=severity or self.effective_severity,
            message=message,
            screen_index=screen_index,
            chapter_num=chapter_num,
            category=category,
            direction=direction,
            details=details or {},
        ))

    def clear_issues(self) -> None:
        """Clear all collected issues (for re-running)."""
        self._issues.clear()

    def get_issues(self) -> List[ValidationIssue]:
        """Get all collected issues."""
        return self._issues.copy()

    @abstractmethod
    def validate_chapter(
        self,
        chapter: "Chapter",
        context: Optional[Dict[str, Any]] = None,
    ) -> List[ValidationIssue]:
        """Validate a single chapter.

        Args:
            chapter: Chapter to validate
            context: Optional context from randomization phases
                     (e.g., rom_data, world_plan, world_shape)

        Returns:
            List of ValidationIssue found
        """
        pass

    def validate_world(
        self,
        game_world: "GameWorld",
        context: Optional[Dict[str, Any]] = None,
    ) -> List[ValidationIssue]:
        """Validate entire game world.

        Default implementation calls validate_chapter for each chapter.
        Override for cross-chapter validation.

        Args:
            game_world: Complete game world to validate
            context: Optional context from randomization phases

        Returns:
            List of all ValidationIssue found
        """
        all_issues: List[ValidationIssue] = []
        for chapter in game_world:
            self.clear_issues()
            issues = self.validate_chapter(chapter, context)
            all_issues.extend(issues)
        return all_issues

    def can_run_at_phase(self, phase: ValidationPhase) -> bool:
        """Check if this validator can run at the given phase.

        Args:
            phase: The validation phase to check

        Returns:
            True if this validator supports the given phase
        """
        if ValidationPhase.ANY in self.SUPPORTED_PHASES:
            return True
        return phase in self.SUPPORTED_PHASES


class ValidatorRegistry:
    """Central registry for all validators.

    Validators are registered using the @register_validator decorator.
    The registry provides discovery and instantiation of validators.

    Example:
        # Register a validator
        @register_validator
        class MyValidator(Validator):
            ...

        # Get all registered validators
        all_validators = ValidatorRegistry.get_all_validators()

        # Create an instance
        validator = ValidatorRegistry.create_validator("my_validator", config)
    """

    _validators: Dict[str, Type[Validator]] = {}

    @classmethod
    def register(cls, validator_class: Type[Validator]) -> Type[Validator]:
        """Register a validator class.

        Args:
            validator_class: The validator class to register

        Returns:
            The same class (for use as decorator)
        """
        cls._validators[validator_class.VALIDATOR_ID] = validator_class
        return validator_class

    @classmethod
    def get_validator_class(cls, validator_id: str) -> Optional[Type[Validator]]:
        """Get a validator class by ID.

        Args:
            validator_id: The unique ID of the validator

        Returns:
            The validator class, or None if not found
        """
        return cls._validators.get(validator_id)

    @classmethod
    def get_all_validators(cls) -> Dict[str, Type[Validator]]:
        """Get all registered validator classes.

        Returns:
            Dictionary of validator_id -> validator_class
        """
        return cls._validators.copy()

    @classmethod
    def get_validator_ids(cls) -> List[str]:
        """Get all registered validator IDs.

        Returns:
            List of validator IDs
        """
        return list(cls._validators.keys())

    @classmethod
    def create_validator(
        cls,
        validator_id: str,
        config: Optional[ValidatorConfig] = None,
    ) -> Optional[Validator]:
        """Create a validator instance.

        Args:
            validator_id: The unique ID of the validator
            config: Configuration for the validator

        Returns:
            A new validator instance, or None if not found
        """
        validator_class = cls._validators.get(validator_id)
        if validator_class is None:
            return None
        return validator_class(config)

    @classmethod
    def get_validators_for_phase(
        cls,
        phase: ValidationPhase,
    ) -> List[Type[Validator]]:
        """Get all validators that can run at a given phase.

        Args:
            phase: The validation phase

        Returns:
            List of validator classes that support the phase
        """
        return [
            v for v in cls._validators.values()
            if phase in v.SUPPORTED_PHASES or ValidationPhase.ANY in v.SUPPORTED_PHASES
        ]

    @classmethod
    def clear(cls) -> None:
        """Clear all registered validators (for testing)."""
        cls._validators.clear()


def register_validator(cls: Type[Validator]) -> Type[Validator]:
    """Decorator to register a validator class.

    Example:
        @register_validator
        class MyValidator(Validator):
            VALIDATOR_ID = "my_validator"
            ...
    """
    return ValidatorRegistry.register(cls)
