"""Validation runner that orchestrates all validators.

The ValidationRunner is responsible for:
- Creating validator instances based on configuration
- Running validators at appropriate phases
- Collecting and organizing validation results
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, TYPE_CHECKING

from .base import (
    Validator,
    ValidatorRegistry,
    ValidatorConfig,
    ValidationIssue,
    ValidationPhase,
    Severity,
)
from .config import ValidationConfig

if TYPE_CHECKING:
    from ..core.chapter import Chapter, GameWorld


@dataclass
class ValidationResult:
    """Result of running validation.

    Contains all issues found and metadata about the validation run.

    Attributes:
        issues: All validation issues found
        validators_run: IDs of validators that were run
        validators_skipped: IDs of validators that were skipped
        phase: Which phase the validation was run at
    """

    issues: List[ValidationIssue] = field(default_factory=list)
    validators_run: List[str] = field(default_factory=list)
    validators_skipped: List[str] = field(default_factory=list)
    phase: Optional[ValidationPhase] = None

    @property
    def is_valid(self) -> bool:
        """Check if no errors were found."""
        return not any(i.severity == Severity.ERROR for i in self.issues)

    @property
    def error_count(self) -> int:
        """Count of ERROR severity issues."""
        return sum(1 for i in self.issues if i.severity == Severity.ERROR)

    @property
    def warning_count(self) -> int:
        """Count of WARNING severity issues."""
        return sum(1 for i in self.issues if i.severity == Severity.WARNING)

    @property
    def info_count(self) -> int:
        """Count of INFO severity issues."""
        return sum(1 for i in self.issues if i.severity == Severity.INFO)

    @property
    def errors(self) -> List[ValidationIssue]:
        """Get all ERROR severity issues."""
        return [i for i in self.issues if i.severity == Severity.ERROR]

    @property
    def warnings(self) -> List[ValidationIssue]:
        """Get all WARNING severity issues."""
        return [i for i in self.issues if i.severity == Severity.WARNING]

    def get_issues_by_validator(self) -> Dict[str, List[ValidationIssue]]:
        """Group issues by validator ID.

        Returns:
            Dictionary of validator_id -> list of issues
        """
        by_validator: Dict[str, List[ValidationIssue]] = {}
        for issue in self.issues:
            if issue.validator_id not in by_validator:
                by_validator[issue.validator_id] = []
            by_validator[issue.validator_id].append(issue)
        return by_validator

    def get_issues_by_chapter(self) -> Dict[int, List[ValidationIssue]]:
        """Group issues by chapter number.

        Returns:
            Dictionary of chapter_num -> list of issues
        """
        by_chapter: Dict[int, List[ValidationIssue]] = {}
        for issue in self.issues:
            ch = issue.chapter_num or 0
            if ch not in by_chapter:
                by_chapter[ch] = []
            by_chapter[ch].append(issue)
        return by_chapter

    def get_issues_by_severity(self) -> Dict[Severity, List[ValidationIssue]]:
        """Group issues by severity.

        Returns:
            Dictionary of severity -> list of issues
        """
        by_severity: Dict[Severity, List[ValidationIssue]] = {}
        for issue in self.issues:
            if issue.severity not in by_severity:
                by_severity[issue.severity] = []
            by_severity[issue.severity].append(issue)
        return by_severity

    def merge(self, other: "ValidationResult") -> None:
        """Merge another result into this one.

        Args:
            other: ValidationResult to merge
        """
        self.issues.extend(other.issues)
        self.validators_run.extend(
            v for v in other.validators_run if v not in self.validators_run
        )
        self.validators_skipped.extend(
            v for v in other.validators_skipped if v not in self.validators_skipped
        )

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization.

        Returns:
            Dictionary representation
        """
        return {
            "is_valid": self.is_valid,
            "error_count": self.error_count,
            "warning_count": self.warning_count,
            "info_count": self.info_count,
            "phase": self.phase.name if self.phase else None,
            "issues": [i.to_dict() for i in self.issues],
            "validators_run": self.validators_run,
            "validators_skipped": self.validators_skipped,
        }

    def __str__(self) -> str:
        """Human-readable summary."""
        status = "VALID" if self.is_valid else "INVALID"
        return (
            f"ValidationResult({status}: "
            f"{self.error_count} errors, "
            f"{self.warning_count} warnings, "
            f"{self.info_count} info)"
        )


class ValidationRunner:
    """Runs validators according to configuration.

    The runner creates validator instances, runs them at appropriate
    phases, and collects results.

    Example:
        config = ValidationConfig()
        runner = ValidationRunner(config)

        # Run all validators
        result = runner.run_all(game_world, context)

        # Run at specific phase
        result = runner.run_for_phase(
            ValidationPhase.DURING_NAVIGATION,
            game_world,
            context
        )
    """

    def __init__(self, config: ValidationConfig):
        """Initialize the validation runner.

        Args:
            config: Validation configuration
        """
        self.config = config
        self._validators: List[Validator] = []
        self._setup_validators()

    def _setup_validators(self) -> None:
        """Create validator instances based on configuration."""
        all_validators = ValidatorRegistry.get_all_validators()

        for validator_id, validator_class in all_validators.items():
            # Check if validator should be enabled
            if not self.config.is_validator_enabled(validator_id):
                continue

            # Build validator config
            validator_config = ValidatorConfig(
                enabled=True,
                severity_override=self.config.get_severity_override(validator_id),
                parameters=self.config.get_validator_parameters(validator_id),
            )

            # Create instance
            self._validators.append(validator_class(validator_config))

    def get_validators(self) -> List[Validator]:
        """Get all configured validator instances.

        Returns:
            List of validator instances
        """
        return self._validators.copy()

    def run_for_phase(
        self,
        phase: ValidationPhase,
        game_world: "GameWorld",
        context: Optional[Dict[str, Any]] = None,
    ) -> ValidationResult:
        """Run validators applicable to a specific phase.

        Args:
            phase: The validation phase to run
            game_world: Game world to validate
            context: Optional context (rom_data, world_plan, etc.)

        Returns:
            ValidationResult with all findings
        """
        result = ValidationResult(phase=phase)

        for validator in self._validators:
            if not validator.can_run_at_phase(phase):
                result.validators_skipped.append(validator.VALIDATOR_ID)
                continue

            # Run validator
            validator.clear_issues()
            issues = validator.validate_world(game_world, context)

            # Limit issues per validator
            if self.config.max_issues_per_validator > 0:
                issues = issues[:self.config.max_issues_per_validator]

            result.issues.extend(issues)
            result.validators_run.append(validator.VALIDATOR_ID)

            # Stop early if configured
            if self.config.stop_on_first_error:
                if any(i.severity == Severity.ERROR for i in issues):
                    break

        return result

    def run_all(
        self,
        game_world: "GameWorld",
        context: Optional[Dict[str, Any]] = None,
    ) -> ValidationResult:
        """Run all enabled validators (final validation).

        Args:
            game_world: Game world to validate
            context: Optional context (rom_data, world_plan, etc.)

        Returns:
            ValidationResult with all findings
        """
        return self.run_for_phase(ValidationPhase.FINAL, game_world, context)

    def run_for_chapter(
        self,
        chapter: "Chapter",
        phase: ValidationPhase = ValidationPhase.FINAL,
        context: Optional[Dict[str, Any]] = None,
    ) -> ValidationResult:
        """Run validators for a single chapter.

        Args:
            chapter: Chapter to validate
            phase: Which phase to run at
            context: Optional context

        Returns:
            ValidationResult with findings for this chapter
        """
        result = ValidationResult(phase=phase)

        for validator in self._validators:
            if not validator.can_run_at_phase(phase):
                continue

            # Run validator for single chapter
            validator.clear_issues()
            issues = validator.validate_chapter(chapter, context)

            # Limit issues
            if self.config.max_issues_per_validator > 0:
                issues = issues[:self.config.max_issues_per_validator]

            result.issues.extend(issues)
            result.validators_run.append(validator.VALIDATOR_ID)

        return result

    def validate_incrementally(
        self,
        phase: ValidationPhase,
        game_world: "GameWorld",
        context: Optional[Dict[str, Any]] = None,
    ) -> ValidationResult:
        """Run incremental validation if enabled.

        Only runs if config.run_incremental is True.

        Args:
            phase: Current randomization phase
            game_world: Game world to validate
            context: Optional context

        Returns:
            ValidationResult (empty if incremental disabled)
        """
        if not self.config.run_incremental:
            return ValidationResult(phase=phase)

        return self.run_for_phase(phase, game_world, context)

    def validate_final(
        self,
        game_world: "GameWorld",
        context: Optional[Dict[str, Any]] = None,
    ) -> ValidationResult:
        """Run final validation if enabled.

        Only runs if config.run_final is True.

        Args:
            game_world: Game world to validate
            context: Optional context

        Returns:
            ValidationResult (empty if final disabled)
        """
        if not self.config.run_final:
            return ValidationResult(phase=ValidationPhase.FINAL)

        return self.run_all(game_world, context)
