"""Phase 7: Content Placement - Place items, allies, shops, and NPCs.

This phase places game content into the randomized world:

1. Ally Placement - Place recruitable party members in appropriate locations
2. Shop Configuration - Set up shop inventories and prices
3. NPC Placement - Place NPCs with dialogue and functions
4. Time Door Placement - Ensure time doors are properly linked
5. Special Content - Boss screens, victory screens, etc.

Input:
- WorldPopulation (from Phase 4)
- WorldNavigation (from Phase 5)
- GameWorld (modified)

Output:
- WorldContent with all placement decisions
- Modified GameWorld with Content bytes updated
"""

from __future__ import annotations

import random
from collections import defaultdict
from dataclasses import dataclass, field
from enum import IntEnum
from typing import Any, Dict, List, Optional, Set, Tuple, TYPE_CHECKING

from ..core.chapter import Chapter, GameWorld
from ..core.worldscreen import WorldScreen
from ..core.enums import SectionType, ContentType, PARENTWORLD_TO_SECTION

if TYPE_CHECKING:
    from .phase1_planning import WorldPlan, ChapterPlan
    from .phase4_population import WorldPopulation, ChapterPopulation


# =============================================================================
# Content Type Constants
# =============================================================================

class AllyId(IntEnum):
    """Ally identifiers."""
    CORONYA = 0
    FARUK = 1
    KEBABU = 2
    GUNMECA = 3
    SUPICA = 4
    EPIN = 5
    PUKIN = 6
    MUSTAFA = 7
    GUBIBI = 8
    RAINY = 9
    HASSAN = 10


class ShopType(IntEnum):
    """Shop type identifiers."""
    ITEM_SHOP = 0x60
    MAGIC_SHOP = 0x75
    FORMATION_SHOP = 0x78
    MIXED_SHOP = 0x79
    MOSQUE = 0x7E
    TROOPERS = 0x7F


class HotelPrice(IntEnum):
    """Hotel price levels."""
    CHEAP = 0xA0    # 10 rupias
    MEDIUM = 0xA3   # ~50 rupias
    EXPENSIVE = 0xB0  # 169 rupias


# Chapter-specific ally content values
# Maps: chapter -> ally_name -> content_value
ALLY_CONTENT_VALUES: Dict[int, Dict[str, int]] = {
    1: {
        'jad': 0x80,
        'faruk': 0x81,
        'dogos': 0x82,
        'kebabu': 0x83,
        'gun_meca': 0x89,
    },
    2: {
        'gun_meca': 0x80,
        'lah': 0x81,
        'supica': 0x82,
        'epin': 0x83,
    },
    3: {
        'supapa': 0x82,
        'mustafa': 0x84,
    },
    4: {
        'gubibi': 0x80,
        'rainy': 0x81,
    },
    5: {
        'hassan': 0x81,
        'kaji': 0x82,
    },
}

# Allies that must be recruited per chapter for progression
REQUIRED_ALLIES: Dict[int, List[str]] = {
    1: ['coronya', 'faruk'],  # Faruk needed for dungeons
    2: ['supica'],  # Supica for maze guidance
    3: ['pukin'],   # Pukin from Cimaron tree
    4: ['rainy'],   # Rainy for rain spell
    5: ['hassan'],  # Hassan for final battle
}


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class AllyPlacement:
    """Placement of a recruitable ally."""
    ally_id: str
    ally_name: str
    chapter: int
    section_id: int
    screen_index: int
    content_value: int
    join_method: str
    requirements: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "ally_id": self.ally_id,
            "ally_name": self.ally_name,
            "chapter": self.chapter,
            "section_id": self.section_id,
            "screen_index": self.screen_index,
            "content_value": self.content_value,
            "join_method": self.join_method,
            "requirements": self.requirements,
        }


@dataclass
class ShopPlacement:
    """Placement and inventory of a shop."""
    shop_id: str
    shop_type: int
    chapter: int
    section_id: int
    screen_index: int
    items: List[str] = field(default_factory=list)
    prices: List[int] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "shop_id": self.shop_id,
            "shop_type": self.shop_type,
            "chapter": self.chapter,
            "section_id": self.section_id,
            "screen_index": self.screen_index,
            "items": self.items,
            "prices": self.prices,
        }


@dataclass
class NPCPlacement:
    """Placement of a named NPC."""
    npc_id: str
    npc_name: str
    chapter: int
    section_id: int
    screen_index: int
    content_value: int
    function: str  # 'talk', 'give_item', 'quest', etc.

    def to_dict(self) -> Dict[str, Any]:
        return {
            "npc_id": self.npc_id,
            "npc_name": self.npc_name,
            "chapter": self.chapter,
            "section_id": self.section_id,
            "screen_index": self.screen_index,
            "content_value": self.content_value,
            "function": self.function,
        }


@dataclass
class ChapterContent:
    """Content placements for a chapter."""
    chapter_num: int
    allies: List[AllyPlacement] = field(default_factory=list)
    shops: List[ShopPlacement] = field(default_factory=list)
    npcs: List[NPCPlacement] = field(default_factory=list)
    hotels: List[Tuple[int, int]] = field(default_factory=list)  # (screen_index, price_value)
    time_doors: List[Tuple[int, int]] = field(default_factory=list)  # (entrance_screen, exit_screen)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter_num": self.chapter_num,
            "allies": [a.to_dict() for a in self.allies],
            "shops": [s.to_dict() for s in self.shops],
            "npcs": [n.to_dict() for n in self.npcs],
            "hotels": [{"screen": s, "price": p} for s, p in self.hotels],
            "time_doors": [{"entrance": e, "exit": x} for e, x in self.time_doors],
        }


@dataclass
class WorldContent:
    """Content placements for all chapters."""
    chapters: List[ChapterContent] = field(default_factory=list)
    seed: int = 0

    def get_chapter(self, chapter_num: int) -> Optional[ChapterContent]:
        for chapter in self.chapters:
            if chapter.chapter_num == chapter_num:
                return chapter
        return None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "seed": self.seed,
            "chapters": [c.to_dict() for c in self.chapters],
        }


# =============================================================================
# Placement Logic
# =============================================================================

def get_valid_content_screens(
    chapter: Chapter,
    section_screens: List[int],
    required_section_type: Optional[SectionType] = None,
) -> List[int]:
    """Get screens that can have content placed.

    Args:
        chapter: Chapter data
        section_screens: Screen indices to consider
        required_section_type: If set, only include screens of this type

    Returns:
        List of valid screen indices
    """
    valid = []

    for screen_idx in section_screens:
        screen = chapter.get_screen(screen_idx)
        if screen is None:
            continue

        # Skip screens that already have special content
        if screen.content not in (0x00, 0xFF):
            continue

        # Skip boss screens
        if screen.is_boss_screen:
            continue

        # Check section type if required
        if required_section_type is not None:
            if screen.section_type != required_section_type:
                continue

        valid.append(screen_idx)

    return valid


def place_allies(
    chapter: Chapter,
    chapter_content: ChapterContent,
    population: "ChapterPopulation",
    rng: random.Random,
) -> None:
    """Place allies in town screens.

    Args:
        chapter: Chapter data
        chapter_content: Content to populate
        population: Population data for section assignments
        rng: Random number generator
    """
    chapter_num = chapter.chapter_num
    ally_values = ALLY_CONTENT_VALUES.get(chapter_num, {})

    if not ally_values:
        return

    # Get town section screens
    town_screens = []
    for section_id, screens in population.screen_assignments.items():
        # Check if this is a town section
        if screens:
            first_screen = chapter.get_screen(screens[0])
            if first_screen and first_screen.section_type == SectionType.TOWN:
                town_screens.extend(screens)

    if not town_screens:
        return

    # Filter to screens that can have content
    valid_screens = get_valid_content_screens(chapter, town_screens, SectionType.TOWN)

    if not valid_screens:
        return

    # Shuffle for random placement
    rng.shuffle(valid_screens)

    # Place required allies first
    required = REQUIRED_ALLIES.get(chapter_num, [])
    placed_count = 0

    for ally_name in required:
        if ally_name in ally_values and placed_count < len(valid_screens):
            screen_idx = valid_screens[placed_count]
            content_value = ally_values[ally_name]

            # Apply to screen
            screen = chapter.get_screen(screen_idx)
            if screen:
                screen.content = content_value
                screen.mark_modified()

            # Record placement
            chapter_content.allies.append(AllyPlacement(
                ally_id=ally_name,
                ally_name=ally_name.replace('_', ' ').title(),
                chapter=chapter_num,
                section_id=0,  # TODO: get actual section ID
                screen_index=screen_idx,
                content_value=content_value,
                join_method="Talk to NPC",
                requirements=[],
            ))

            placed_count += 1

    # Place optional allies
    for ally_name, content_value in ally_values.items():
        if ally_name in required:
            continue  # Already placed

        if placed_count >= len(valid_screens):
            break

        screen_idx = valid_screens[placed_count]

        # Apply to screen
        screen = chapter.get_screen(screen_idx)
        if screen:
            screen.content = content_value
            screen.mark_modified()

        chapter_content.allies.append(AllyPlacement(
            ally_id=ally_name,
            ally_name=ally_name.replace('_', ' ').title(),
            chapter=chapter_num,
            section_id=0,
            screen_index=screen_idx,
            content_value=content_value,
            join_method="Talk to NPC",
            requirements=[],
        ))

        placed_count += 1


def place_shops(
    chapter: Chapter,
    chapter_content: ChapterContent,
    population: "ChapterPopulation",
    shops_per_town: Tuple[int, int],
    rng: random.Random,
) -> None:
    """Place shops in town screens.

    Args:
        chapter: Chapter data
        chapter_content: Content to populate
        population: Population data
        shops_per_town: (min, max) shops per town
        rng: Random number generator
    """
    # Get town screens
    town_screens = []
    for section_id, screens in population.screen_assignments.items():
        if screens:
            first_screen = chapter.get_screen(screens[0])
            if first_screen and first_screen.section_type == SectionType.TOWN:
                town_screens.extend(screens)

    valid_screens = get_valid_content_screens(chapter, town_screens, SectionType.TOWN)

    if not valid_screens:
        return

    # Determine number of shops
    num_shops = rng.randint(shops_per_town[0], shops_per_town[1])
    num_shops = min(num_shops, len(valid_screens))

    # Shop type rotation
    shop_types = [
        (ShopType.ITEM_SHOP, "Item Shop"),
        (ShopType.MAGIC_SHOP, "Magic Shop"),
        (ShopType.MIXED_SHOP, "Mixed Shop"),
    ]

    rng.shuffle(valid_screens)

    for i in range(num_shops):
        screen_idx = valid_screens[i]
        shop_type, shop_name = shop_types[i % len(shop_types)]

        # Apply to screen
        screen = chapter.get_screen(screen_idx)
        if screen:
            screen.content = shop_type
            screen.mark_modified()

        chapter_content.shops.append(ShopPlacement(
            shop_id=f"shop_{chapter.chapter_num}_{i}",
            shop_type=shop_type,
            chapter=chapter.chapter_num,
            section_id=0,
            screen_index=screen_idx,
            items=[],  # TODO: populate shop inventory
            prices=[],
        ))


def place_hotels(
    chapter: Chapter,
    chapter_content: ChapterContent,
    population: "ChapterPopulation",
    hotels_per_town: Tuple[int, int],
    rng: random.Random,
) -> None:
    """Place hotels in town screens.

    Args:
        chapter: Chapter data
        chapter_content: Content to populate
        population: Population data
        hotels_per_town: (min, max) hotels per town
        rng: Random number generator
    """
    # Get town screens
    town_screens = []
    for section_id, screens in population.screen_assignments.items():
        if screens:
            first_screen = chapter.get_screen(screens[0])
            if first_screen and first_screen.section_type == SectionType.TOWN:
                town_screens.extend(screens)

    valid_screens = get_valid_content_screens(chapter, town_screens, SectionType.TOWN)

    if not valid_screens:
        return

    # Determine number of hotels
    num_hotels = rng.randint(hotels_per_town[0], hotels_per_town[1])
    num_hotels = min(num_hotels, len(valid_screens))

    # Price options
    prices = [HotelPrice.CHEAP, HotelPrice.MEDIUM, HotelPrice.EXPENSIVE]

    rng.shuffle(valid_screens)

    for i in range(num_hotels):
        screen_idx = valid_screens[i]
        price = rng.choice(prices)

        # Apply to screen
        screen = chapter.get_screen(screen_idx)
        if screen:
            screen.content = price
            screen.mark_modified()

        chapter_content.hotels.append((screen_idx, price))


def place_mosques(
    chapter: Chapter,
    chapter_content: ChapterContent,
    population: "ChapterPopulation",
    rng: random.Random,
) -> None:
    """Place mosques in town screens.

    Each town should have at least one mosque for saving/class changes.

    Args:
        chapter: Chapter data
        chapter_content: Content to populate
        population: Population data
        rng: Random number generator
    """
    # Get town screens
    town_screens = []
    for section_id, screens in population.screen_assignments.items():
        if screens:
            first_screen = chapter.get_screen(screens[0])
            if first_screen and first_screen.section_type == SectionType.TOWN:
                town_screens.extend(screens)

    valid_screens = get_valid_content_screens(chapter, town_screens, SectionType.TOWN)

    if not valid_screens:
        return

    # Place one mosque
    screen_idx = rng.choice(valid_screens)

    screen = chapter.get_screen(screen_idx)
    if screen:
        screen.content = ShopType.MOSQUE
        screen.mark_modified()


# =============================================================================
# Main Content Functions
# =============================================================================

def populate_chapter_content(
    chapter: Chapter,
    chapter_plan: "ChapterPlan",
    population: "ChapterPopulation",
    config: "ContentConfig",
    rng: random.Random,
) -> ChapterContent:
    """Populate content for a single chapter.

    Args:
        chapter: Chapter data
        chapter_plan: Plan for this chapter
        population: Population data
        config: Content configuration
        rng: Random number generator

    Returns:
        ChapterContent with all placements
    """
    chapter_content = ChapterContent(chapter_num=chapter.chapter_num)

    # Place allies first (they have fixed content values)
    place_allies(chapter, chapter_content, population, rng)

    # Place mosque (required for saving)
    place_mosques(chapter, chapter_content, population, rng)

    # Place shops
    place_shops(
        chapter,
        chapter_content,
        population,
        config.shops_per_town,
        rng,
    )

    # Place hotels
    place_hotels(
        chapter,
        chapter_content,
        population,
        config.hotels_per_town,
        rng,
    )

    return chapter_content


def populate_world_content(
    game_world: GameWorld,
    world_plan: "WorldPlan",
    world_population: "WorldPopulation",
    config: "ContentConfig",
    seed: int,
) -> WorldContent:
    """Populate content for all chapters.

    Args:
        game_world: Game world data
        world_plan: World plan
        world_population: Population data
        config: Content configuration
        seed: Random seed

    Returns:
        WorldContent with all chapter contents
    """
    rng = random.Random(seed)
    world_content = WorldContent(seed=seed)

    plan_lookup = {ch.chapter_num: ch for ch in world_plan.chapters}

    for chapter_pop in world_population.chapters:
        chapter = game_world.chapters.get(chapter_pop.chapter_num)
        chapter_plan = plan_lookup.get(chapter_pop.chapter_num)

        if chapter is None or chapter_plan is None:
            continue

        chapter_content = populate_chapter_content(
            chapter=chapter,
            chapter_plan=chapter_plan,
            population=chapter_pop,
            config=config,
            rng=rng,
        )

        world_content.chapters.append(chapter_content)

    return world_content


# =============================================================================
# Configuration
# =============================================================================

@dataclass
class ContentConfig:
    """Configuration for content placement."""

    # Town content
    shops_per_town: Tuple[int, int] = (1, 3)
    hotels_per_town: Tuple[int, int] = (1, 2)

    # Ally placement
    shuffle_allies: bool = False  # Keep original chapter assignments

    # Shop configuration
    shop_price_multiplier: float = 1.0

    @classmethod
    def from_randomizer_config(cls, config: "RandomizerConfig") -> "ContentConfig":
        """Create from main randomizer config."""
        content_cfg = config.content_placement
        return cls(
            shops_per_town=(
                content_cfg.get("shops_per_town", {}).get("min", 1),
                content_cfg.get("shops_per_town", {}).get("max", 3),
            ),
            hotels_per_town=(
                content_cfg.get("hotels_per_town", {}).get("min", 1),
                content_cfg.get("hotels_per_town", {}).get("max", 2),
            ),
        )


# =============================================================================
# Validation
# =============================================================================

def validate_content(
    world_content: WorldContent,
    game_world: GameWorld,
) -> List[str]:
    """Validate content placements.

    Args:
        world_content: Content placements
        game_world: Game world

    Returns:
        List of error messages
    """
    errors = []

    for chapter_content in world_content.chapters:
        chapter = game_world.chapters.get(chapter_content.chapter_num)
        if chapter is None:
            errors.append(f"Chapter {chapter_content.chapter_num} not in game world")
            continue

        # Check required allies are placed
        chapter_num = chapter_content.chapter_num
        required = REQUIRED_ALLIES.get(chapter_num, [])
        placed_ally_ids = {a.ally_id for a in chapter_content.allies}

        for ally in required:
            if ally not in placed_ally_ids:
                errors.append(f"Chapter {chapter_num}: Required ally '{ally}' not placed")

        # Check shop placements are valid
        for shop in chapter_content.shops:
            screen = chapter.get_screen(shop.screen_index)
            if screen is None:
                errors.append(f"Chapter {chapter_num}: Shop at invalid screen {shop.screen_index}")
            elif screen.section_type != SectionType.TOWN:
                errors.append(f"Chapter {chapter_num}: Shop at non-town screen {shop.screen_index}")

    return errors
