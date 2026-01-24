"""Enemy difficulty classification for ObjectSet randomization.

This module provides:
- DifficultyTier enum for categorizing enemies/ObjectSets
- Enemy difficulty scores based on threat level
- ObjectSetInfo dataclass for ObjectSet metadata
- Functions to calculate threat scores and classify difficulty
"""

from dataclasses import dataclass, field
from enum import IntEnum
from typing import List, Set


class DifficultyTier(IntEnum):
    """Difficulty tier for enemies and ObjectSets."""

    EASY = 1
    MEDIUM = 2
    HARD = 3


# Enemy difficulty scores (1-5 scale)
# Based on HP, damage, movement patterns, and player threat level
ENEMY_DIFFICULTY_SCORES: dict[int, int] = {
    # Easy enemies (score 1-2)
    0x01: 2,  # TransformedPlayer - jumps around
    0x1D: 1,  # Bee/GiantWasp - basic flyer
    0x11: 2,  # Robber/Thief - ambush enemy
    0x15: 2,  # DesertCrab - jumping crab
    0x13: 2,  # MazeThings - maze enemies
    # Medium enemies (score 3)
    0x14: 3,  # KillerFlower - plant enemy (stationary)
    0x16: 3,  # SineWave - sine wave movement
    0x17: 3,  # WormHouse - overflow spawn
    0x18: 3,  # Gargoyle - flying
    0x19: 3,  # SwampSplitter - splits in swamp
    0x1A: 3,  # JumpAttacker - leaping attack
    0x22: 3,  # LionHose - lion with hose
    0x23: 3,  # BlueDancer - orbiting projectiles
    0x35: 3,  # SlowMover - big projectiles
    0x36: 3,  # CenterBigThing - center screen
    0x37: 3,  # ScreenMoves - "sucked in" death
    # Hard enemies (score 4-5)
    0x20: 5,  # RedGrimReaper - high HP, drops money
    0x28: 4,  # Changarl - wizard type
    0x30: 4,  # Mardul - wizard type
    0x31: 4,  # Barzil - wizard type
    0x34: 5,  # Spawner - spawns enemies
    0x39: 5,  # ScreenFireballs - high damage
}

# Default score for unknown enemies
DEFAULT_ENEMY_SCORE = 2


@dataclass
class ObjectSetInfo:
    """Metadata for an ObjectSet (enemy spawn configuration).

    Attributes:
        objectset_id: The ObjectSet ID (byte value)
        chapter: Chapter number (1-5)
        enemy_types: List of enemy type IDs in this set
        enemy_count: Number of enemies in this set
        threat_score: Calculated threat score (0.0 - 1.0)
        difficulty_tier: Classified difficulty tier
        chr_indices: Set of compatible CHR bank indices
        category: Category string ("enemies", "town_npc", "spawner", "special")
    """

    objectset_id: int
    chapter: int
    enemy_types: List[int] = field(default_factory=list)
    enemy_count: int = 0
    threat_score: float = 0.0
    difficulty_tier: DifficultyTier = DifficultyTier.MEDIUM
    chr_indices: Set[int] = field(default_factory=set)
    category: str = "enemies"

    def is_randomizable(self) -> bool:
        """Check if this ObjectSet can be used for randomization."""
        return self.category == "enemies"


def calculate_threat_score(enemy_types: List[int]) -> float:
    """Calculate aggregate threat score for an ObjectSet.

    The threat score combines:
    - Average enemy difficulty (40%)
    - Maximum enemy difficulty (40%)
    - Enemy count factor (20%)

    Args:
        enemy_types: List of enemy type IDs

    Returns:
        Normalized threat score (0.0 - 1.0)
    """
    if not enemy_types:
        return 0.0

    scores = [
        ENEMY_DIFFICULTY_SCORES.get(etype, DEFAULT_ENEMY_SCORE)
        for etype in enemy_types
    ]

    if not scores:
        return 0.0

    avg_score = sum(scores) / len(scores)
    max_score = max(scores)
    count_factor = min(1.0, len(scores) / 5.0)  # Caps at 5 enemies

    # Weighted combination, normalized to 0.0 - 1.0
    raw_score = avg_score * 0.4 + max_score * 0.4 + count_factor * 5 * 0.2
    return raw_score / 5.0


def classify_difficulty(threat_score: float, enemy_count: int) -> DifficultyTier:
    """Classify ObjectSet into difficulty tier.

    Args:
        threat_score: Calculated threat score (0.0 - 1.0)
        enemy_count: Number of enemies in the ObjectSet

    Returns:
        DifficultyTier classification
    """
    # Easy: low threat or few enemies
    if threat_score < 0.35 or enemy_count <= 2:
        return DifficultyTier.EASY

    # Hard: high threat with many enemies
    if threat_score >= 0.65 and enemy_count > 3:
        return DifficultyTier.HARD

    # Medium: everything else
    return DifficultyTier.MEDIUM


def create_objectset_info(
    objectset_id: int,
    chapter: int,
    enemy_types: List[int],
    chr_indices: Set[int],
    category: str = "enemies",
) -> ObjectSetInfo:
    """Create an ObjectSetInfo with calculated difficulty.

    Args:
        objectset_id: The ObjectSet ID
        chapter: Chapter number (1-5)
        enemy_types: List of enemy type IDs
        chr_indices: Set of compatible CHR bank indices
        category: Category string

    Returns:
        Fully populated ObjectSetInfo
    """
    threat_score = calculate_threat_score(enemy_types)
    difficulty_tier = classify_difficulty(threat_score, len(enemy_types))

    return ObjectSetInfo(
        objectset_id=objectset_id,
        chapter=chapter,
        enemy_types=enemy_types,
        enemy_count=len(enemy_types),
        threat_score=threat_score,
        difficulty_tier=difficulty_tier,
        chr_indices=chr_indices,
        category=category,
    )


# Difficulty presets for configuration
DIFFICULTY_PRESETS: dict[str, dict[str, float]] = {
    "casual": {"easy": 0.50, "medium": 0.35, "hard": 0.15},
    "balanced": {"easy": 0.30, "medium": 0.45, "hard": 0.25},
    "challenging": {"easy": 0.15, "medium": 0.40, "hard": 0.45},
    "brutal": {"easy": 0.05, "medium": 0.25, "hard": 0.70},
}

# Default distribution per section type
DEFAULT_DISTRIBUTION: dict[str, dict[str, float]] = {
    "overworld": {"easy": 0.35, "medium": 0.45, "hard": 0.20},
    "dungeon": {"easy": 0.20, "medium": 0.40, "hard": 0.40},
    "maze": {"easy": 0.25, "medium": 0.50, "hard": 0.25},
    "special": {"easy": 0.30, "medium": 0.40, "hard": 0.30},
}
