"""Spoiler log generation for randomized ROMs.

Generates both human-readable text and machine-readable JSON formats.
Design based on: docs/planning/spoiler-log.md
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

from ..core.chapter import Chapter, GameWorld
from ..core.enums import SectionType
from ..core.shop_inventory import (
    ChapterShopData,
    ShopInventory as CoreShopInventory,
)
from ..io.config_loader import RandomizerConfig


# =============================================================================
# Spoiler Log Data Structures
# =============================================================================

@dataclass
class ItemLocation:
    """Location of an item in the game."""

    item_name: str
    chapter: int
    screen: int
    location_desc: str
    requirements: List[str] = field(default_factory=list)
    is_key_item: bool = False

    def to_dict(self) -> Dict[str, Any]:
        return {
            "item": self.item_name,
            "chapter": self.chapter,
            "screen": self.screen,
            "location": self.location_desc,
            "requirements": self.requirements,
            "is_key_item": self.is_key_item,
        }


@dataclass
class AllyLocation:
    """Location of an ally NPC."""

    name: str
    chapter: int
    screen: int
    location_desc: str
    requirements: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "name": self.name,
            "chapter": self.chapter,
            "screen": self.screen,
            "location": self.location_desc,
            "requirements": self.requirements,
        }


@dataclass
class ShopInventory:
    """Contents of a shop."""

    chapter: int
    screen: int
    shop_type: str  # "weapon", "item", "magic"
    location_desc: str
    items: List[Dict[str, Any]] = field(default_factory=list)  # {"name": str, "price": int}

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter": self.chapter,
            "screen": self.screen,
            "shop_type": self.shop_type,
            "location": self.location_desc,
            "items": self.items,
        }


@dataclass
class SectionInfo:
    """Information about a map section."""

    section_type: str
    screen_count: int
    shape: str
    screens: List[int] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "type": self.section_type,
            "screen_count": self.screen_count,
            "shape": self.shape,
            "screens": self.screens,
        }


@dataclass
class ConnectionInfo:
    """Connection between sections."""

    from_section: str
    to_section: str
    method: str  # "edge", "portal", "cave", etc.
    screen: int

    def to_dict(self) -> Dict[str, Any]:
        return {
            "from": self.from_section,
            "to": self.to_section,
            "method": self.method,
            "screen": self.screen,
        }


@dataclass
class ChapterMapInfo:
    """Map layout information for a chapter."""

    chapter_num: int
    screen_count: int
    sections: List[SectionInfo] = field(default_factory=list)
    connections: List[ConnectionInfo] = field(default_factory=list)
    topology: str = "branching"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "chapter": self.chapter_num,
            "screen_count": self.screen_count,
            "sections": [s.to_dict() for s in self.sections],
            "connections": [c.to_dict() for c in self.connections],
            "topology": self.topology,
        }


@dataclass
class Sphere:
    """A sphere in logic - items available at a progression point."""

    sphere_num: int
    unlocked_by: List[str]  # What unlocked this sphere
    items: List[str] = field(default_factory=list)
    locations: List[str] = field(default_factory=list)
    allies: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "sphere": self.sphere_num,
            "unlocked_by": self.unlocked_by,
            "items": self.items,
            "locations": self.locations,
            "allies": self.allies,
        }


@dataclass
class PlaythroughStep:
    """A step in the playthrough."""

    chapter: int
    step_num: int
    action: str
    location: str
    screen: Optional[int] = None

    def to_dict(self) -> Dict[str, Any]:
        result = {
            "chapter": self.chapter,
            "step": self.step_num,
            "action": self.action,
            "location": self.location,
        }
        if self.screen is not None:
            result["screen"] = self.screen
        return result


@dataclass
class SpecialNote:
    """A special note or warning about the seed."""

    category: str  # "warning", "interesting", "difficulty"
    message: str

    def to_dict(self) -> Dict[str, Any]:
        return {
            "category": self.category,
            "message": self.message,
        }


# =============================================================================
# Main Spoiler Log Class
# =============================================================================

@dataclass
class SpoilerLog:
    """Complete spoiler log for a randomized ROM."""

    # Metadata
    seed: int
    generated: datetime
    version: str = "2.0.0"
    preset: str = "standard"
    rom_sha256: str = ""

    # Settings used
    settings: Dict[str, Any] = field(default_factory=dict)

    # Content
    key_items: List[ItemLocation] = field(default_factory=list)
    all_items: List[ItemLocation] = field(default_factory=list)
    allies: List[AllyLocation] = field(default_factory=list)
    shops: List[ShopInventory] = field(default_factory=list)
    map_layout: List[ChapterMapInfo] = field(default_factory=list)
    spheres: List[Sphere] = field(default_factory=list)
    playthrough: List[PlaythroughStep] = field(default_factory=list)
    special_notes: List[SpecialNote] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "meta": {
                "seed": self.seed,
                "generated": self.generated.isoformat(),
                "version": self.version,
                "preset": self.preset,
                "rom_sha256": self.rom_sha256,
            },
            "settings": self.settings,
            "key_items": [i.to_dict() for i in self.key_items],
            "all_items": [i.to_dict() for i in self.all_items],
            "allies": [a.to_dict() for a in self.allies],
            "shops": [s.to_dict() for s in self.shops],
            "map": {f"chapter_{m.chapter_num}": m.to_dict() for m in self.map_layout},
            "spheres": [s.to_dict() for s in self.spheres],
            "playthrough": [p.to_dict() for p in self.playthrough],
            "special_notes": [n.to_dict() for n in self.special_notes],
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "SpoilerLog":
        """Create from dictionary."""
        meta = data.get("meta", {})
        log = cls(
            seed=meta.get("seed", 0),
            generated=datetime.fromisoformat(meta.get("generated", datetime.now().isoformat())),
            version=meta.get("version", "2.0.0"),
            preset=meta.get("preset", "standard"),
            rom_sha256=meta.get("rom_sha256", ""),
            settings=data.get("settings", {}),
        )

        # Load key items
        for item_data in data.get("key_items", []):
            log.key_items.append(ItemLocation(
                item_name=item_data["item"],
                chapter=item_data["chapter"],
                screen=item_data["screen"],
                location_desc=item_data["location"],
                requirements=item_data.get("requirements", []),
                is_key_item=True,
            ))

        # Load all items
        for item_data in data.get("all_items", []):
            log.all_items.append(ItemLocation(
                item_name=item_data["item"],
                chapter=item_data["chapter"],
                screen=item_data["screen"],
                location_desc=item_data["location"],
                requirements=item_data.get("requirements", []),
                is_key_item=item_data.get("is_key_item", False),
            ))

        # Load allies
        for ally_data in data.get("allies", []):
            log.allies.append(AllyLocation(
                name=ally_data["name"],
                chapter=ally_data["chapter"],
                screen=ally_data["screen"],
                location_desc=ally_data["location"],
                requirements=ally_data.get("requirements", []),
            ))

        # Load shops
        for shop_data in data.get("shops", []):
            log.shops.append(ShopInventory(
                chapter=shop_data["chapter"],
                screen=shop_data["screen"],
                shop_type=shop_data["shop_type"],
                location_desc=shop_data["location"],
                items=shop_data.get("items", []),
            ))

        # Load map layout
        for key, map_data in data.get("map", {}).items():
            sections = [
                SectionInfo(
                    section_type=s["type"],
                    screen_count=s["screen_count"],
                    shape=s["shape"],
                    screens=s.get("screens", []),
                )
                for s in map_data.get("sections", [])
            ]
            connections = [
                ConnectionInfo(
                    from_section=c["from"],
                    to_section=c["to"],
                    method=c["method"],
                    screen=c["screen"],
                )
                for c in map_data.get("connections", [])
            ]
            log.map_layout.append(ChapterMapInfo(
                chapter_num=map_data["chapter"],
                screen_count=map_data["screen_count"],
                sections=sections,
                connections=connections,
                topology=map_data.get("topology", "branching"),
            ))

        # Load spheres
        for sphere_data in data.get("spheres", []):
            log.spheres.append(Sphere(
                sphere_num=sphere_data["sphere"],
                unlocked_by=sphere_data.get("unlocked_by", []),
                items=sphere_data.get("items", []),
                locations=sphere_data.get("locations", []),
                allies=sphere_data.get("allies", []),
            ))

        # Load playthrough
        for step_data in data.get("playthrough", []):
            log.playthrough.append(PlaythroughStep(
                chapter=step_data["chapter"],
                step_num=step_data["step"],
                action=step_data["action"],
                location=step_data["location"],
                screen=step_data.get("screen"),
            ))

        # Load special notes
        for note_data in data.get("special_notes", []):
            log.special_notes.append(SpecialNote(
                category=note_data["category"],
                message=note_data["message"],
            ))

        return log


# =============================================================================
# Text Format Generation
# =============================================================================

SEPARATOR = "=" * 80
DASH_LINE = "-" * 40


def _center(text: str, width: int = 80) -> str:
    """Center text within width."""
    return text.center(width)


def generate_text_spoiler(log: SpoilerLog, include_sections: Optional[Dict[str, bool]] = None) -> str:
    """Generate human-readable text spoiler log.

    Args:
        log: SpoilerLog to format
        include_sections: Which sections to include (all by default)

    Returns:
        Formatted text string
    """
    if include_sections is None:
        include_sections = {
            "header": True,
            "key_items": True,
            "all_items": True,
            "allies": True,
            "shops": True,
            "map_layout": True,
            "spheres": True,
            "playthrough": True,
            "special_notes": True,
        }

    lines = []

    # Header
    if include_sections.get("header", True):
        lines.extend(_generate_header(log))

    # Key Items
    if include_sections.get("key_items", True) and log.key_items:
        lines.extend(_generate_key_items_section(log))

    # All Items
    if include_sections.get("all_items", True) and log.all_items:
        lines.extend(_generate_all_items_section(log))

    # Allies
    if include_sections.get("allies", True) and log.allies:
        lines.extend(_generate_allies_section(log))

    # Shops
    if include_sections.get("shops", True) and log.shops:
        lines.extend(_generate_shops_section(log))

    # Map Layout
    if include_sections.get("map_layout", True) and log.map_layout:
        lines.extend(_generate_map_section(log))

    # Spheres
    if include_sections.get("spheres", True) and log.spheres:
        lines.extend(_generate_spheres_section(log))

    # Playthrough
    if include_sections.get("playthrough", True) and log.playthrough:
        lines.extend(_generate_playthrough_section(log))

    # Special Notes
    if include_sections.get("special_notes", True) and log.special_notes:
        lines.extend(_generate_special_notes_section(log))

    # Footer
    lines.extend(_generate_footer())

    return "\n".join(lines)


def _generate_header(log: SpoilerLog) -> List[str]:
    """Generate header section."""
    lines = [
        SEPARATOR,
        _center("THE MAGIC OF SCHEHERAZADE - RANDOMIZER"),
        _center("SPOILER LOG"),
        SEPARATOR,
        "",
        f"Seed:           {log.seed}",
        f"Generated:      {log.generated.strftime('%Y-%m-%d %H:%M:%S')}",
        f"Version:        TMOS Randomizer V{log.version}",
        f"Preset:         {log.preset.title()}",
    ]

    if log.settings:
        lines.append("")
        lines.append("Settings:")
        for key, value in log.settings.items():
            if isinstance(value, bool):
                value_str = "Yes" if value else "No"
            else:
                value_str = str(value)
            lines.append(f"  - {key.replace('_', ' ').title()}: {value_str}")

    if log.rom_sha256:
        lines.append("")
        lines.append(f"SHA256: {log.rom_sha256[:16]}...")

    lines.append("")
    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_key_items_section(log: SpoilerLog) -> List[str]:
    """Generate key items section."""
    lines = [
        SEPARATOR,
        _center("KEY ITEM LOCATIONS"),
        SEPARATOR,
        "",
    ]

    # Group by chapter
    by_chapter: Dict[int, List[ItemLocation]] = {}
    for item in log.key_items:
        by_chapter.setdefault(item.chapter, []).append(item)

    for chapter in sorted(by_chapter.keys()):
        lines.append(f"CHAPTER {chapter}")
        lines.append("-" * 9)
        for item in by_chapter[chapter]:
            item_str = f"  {item.item_name:.<30} {item.location_desc}"
            if item.requirements:
                item_str += f" (Requires: {', '.join(item.requirements)})"
            lines.append(item_str)
        lines.append("")

    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_all_items_section(log: SpoilerLog) -> List[str]:
    """Generate all items section."""
    lines = [
        SEPARATOR,
        _center("COMPLETE ITEM LOCATIONS"),
        SEPARATOR,
        "",
    ]

    # Group by category (could be inferred from item name or stored)
    for item in log.all_items:
        item_str = f"  {item.item_name:.<30} Chapter {item.chapter}, {item.location_desc}"
        lines.append(item_str)

    lines.append("")
    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_allies_section(log: SpoilerLog) -> List[str]:
    """Generate allies section."""
    lines = [
        SEPARATOR,
        _center("ALLY LOCATIONS"),
        SEPARATOR,
        "",
        f"{'ALLY':<20} {'CHAPTER':<10} {'LOCATION':<30} {'REQUIREMENTS'}",
        f"{'----':<20} {'-------':<10} {'--------':<30} {'------------'}",
    ]

    for ally in log.allies:
        req_str = ", ".join(ally.requirements) if ally.requirements else "None"
        lines.append(f"{ally.name:<20} {ally.chapter:<10} {ally.location_desc:<30} {req_str}")

    lines.append("")
    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_shops_section(log: SpoilerLog) -> List[str]:
    """Generate shops section."""
    lines = [
        SEPARATOR,
        _center("SHOP INVENTORIES"),
        SEPARATOR,
        "",
    ]

    # Group by chapter
    by_chapter: Dict[int, List[ShopInventory]] = {}
    for shop in log.shops:
        by_chapter.setdefault(shop.chapter, []).append(shop)

    for chapter in sorted(by_chapter.keys()):
        lines.append(f"CHAPTER {chapter}")
        lines.append("-" * 9)
        lines.append("")

        for shop in by_chapter[chapter]:
            lines.append(f"  {shop.location_desc} - {shop.shop_type.title()} Shop (Screen {shop.screen}):")
            for item in shop.items:
                lines.append(f"    - {item['name']:.<20} {item['price']} gold")
            lines.append("")

    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_map_section(log: SpoilerLog) -> List[str]:
    """Generate map layout section."""
    lines = [
        SEPARATOR,
        _center("MAP LAYOUT"),
        SEPARATOR,
        "",
    ]

    for chapter_map in log.map_layout:
        lines.append(f"CHAPTER {chapter_map.chapter_num} ({chapter_map.screen_count} screens)")
        lines.append("-" * 25)
        lines.append("")

        lines.append("  Sections:")
        for section in chapter_map.sections:
            lines.append(f"    - {section.section_type.title()}: {section.screen_count} screens ({section.shape} shape)")

        lines.append("")
        lines.append("  Connections:")
        for conn in chapter_map.connections:
            lines.append(f"    {conn.from_section} -> {conn.to_section} ({conn.method})")

        lines.append("")
        lines.append(f"  Topology: {chapter_map.topology.title()}")
        lines.append("")

    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_spheres_section(log: SpoilerLog) -> List[str]:
    """Generate sphere analysis section."""
    lines = [
        SEPARATOR,
        _center("SPHERE ANALYSIS"),
        SEPARATOR,
        "",
    ]

    for sphere in log.spheres:
        if sphere.sphere_num == 0:
            lines.append(f"SPHERE 0 (Available from start):")
        else:
            unlock_str = ", ".join(sphere.unlocked_by) if sphere.unlocked_by else "Previous sphere"
            lines.append(f"SPHERE {sphere.sphere_num} (After getting: {unlock_str}):")

        if sphere.locations:
            lines.append(f"  - Locations: {', '.join(sphere.locations)}")
        if sphere.items:
            lines.append(f"  - Items: {', '.join(sphere.items)}")
        if sphere.allies:
            lines.append(f"  - Allies: {', '.join(sphere.allies)}")

        lines.append("")

    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_playthrough_section(log: SpoilerLog) -> List[str]:
    """Generate playthrough section."""
    lines = [
        SEPARATOR,
        _center("PLAYTHROUGH (CRITICAL PATH)"),
        SEPARATOR,
        "",
        "This is one possible route to beat the game:",
        "",
    ]

    current_chapter = 0
    for step in log.playthrough:
        if step.chapter != current_chapter:
            current_chapter = step.chapter
            lines.append(f"CHAPTER {current_chapter}:")

        screen_str = f" (Screen {step.screen})" if step.screen is not None else ""
        lines.append(f"  {step.step_num}. {step.action} - {step.location}{screen_str}")

    lines.append("")
    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_special_notes_section(log: SpoilerLog) -> List[str]:
    """Generate special notes section."""
    lines = [
        SEPARATOR,
        _center("SPECIAL NOTES"),
        SEPARATOR,
        "",
    ]

    # Group by category
    by_category: Dict[str, List[str]] = {}
    for note in log.special_notes:
        by_category.setdefault(note.category, []).append(note.message)

    category_titles = {
        "warning": "WARNINGS",
        "interesting": "INTERESTING PLACEMENTS",
        "difficulty": "DIFFICULTY NOTES",
    }

    for category, messages in by_category.items():
        title = category_titles.get(category, category.upper())
        lines.append(f"{title}:")
        for msg in messages:
            lines.append(f"  - {msg}")
        lines.append("")

    lines.append(SEPARATOR)
    lines.append("")

    return lines


def _generate_footer() -> List[str]:
    """Generate footer section."""
    return [
        SEPARATOR,
        "",
        "This spoiler log was generated by TMOS Randomizer V2",
        "",
        "Race rules: Do not share this log until race is complete!",
        "",
        SEPARATOR,
    ]


# =============================================================================
# JSON Format Generation
# =============================================================================

def generate_json_spoiler(log: SpoilerLog, pretty: bool = True) -> str:
    """Generate machine-readable JSON spoiler log.

    Args:
        log: SpoilerLog to format
        pretty: If True, format with indentation

    Returns:
        JSON string
    """
    data = log.to_dict()
    if pretty:
        return json.dumps(data, indent=2, ensure_ascii=False)
    return json.dumps(data, ensure_ascii=False)


# =============================================================================
# File Writing
# =============================================================================

def write_spoiler_log(
    log: SpoilerLog,
    output_dir: Union[str, Path],
    text_filename: str = "spoiler.txt",
    json_filename: str = "spoiler.json",
    write_text: bool = True,
    write_json: bool = True,
    include_sections: Optional[Dict[str, bool]] = None,
) -> Dict[str, Path]:
    """Write spoiler log files.

    Args:
        log: SpoilerLog to write
        output_dir: Directory to write files to
        text_filename: Name for text file
        json_filename: Name for JSON file
        write_text: Whether to write text format
        write_json: Whether to write JSON format
        include_sections: Which sections to include in text format

    Returns:
        Dict mapping format name to file path
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    written = {}

    if write_text:
        text_path = output_dir / text_filename
        text_content = generate_text_spoiler(log, include_sections)
        text_path.write_text(text_content, encoding="utf-8")
        written["text"] = text_path

    if write_json:
        json_path = output_dir / json_filename
        json_content = generate_json_spoiler(log)
        json_path.write_text(json_content, encoding="utf-8")
        written["json"] = json_path

    return written


def load_spoiler_log(json_path: Union[str, Path]) -> SpoilerLog:
    """Load a spoiler log from JSON file.

    Args:
        json_path: Path to JSON spoiler log

    Returns:
        SpoilerLog object
    """
    json_path = Path(json_path)
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return SpoilerLog.from_dict(data)


# =============================================================================
# Spoiler Log Builder (for use during randomization)
# =============================================================================

class SpoilerLogBuilder:
    """Helper class to build a spoiler log during randomization."""

    def __init__(
        self,
        seed: int,
        version: str = "2.0.0",
        preset: str = "standard",
    ):
        """Initialize builder.

        Args:
            seed: Randomization seed
            version: Randomizer version
            preset: Preset name
        """
        self._log = SpoilerLog(
            seed=seed,
            generated=datetime.now(),
            version=version,
            preset=preset,
        )

    @property
    def log(self) -> SpoilerLog:
        """Get the built spoiler log."""
        return self._log

    def set_rom_hash(self, sha256: str) -> "SpoilerLogBuilder":
        """Set ROM SHA256 hash."""
        self._log.rom_sha256 = sha256
        return self

    def set_settings(self, settings: Dict[str, Any]) -> "SpoilerLogBuilder":
        """Set randomization settings."""
        self._log.settings = settings
        return self

    def add_key_item(
        self,
        item_name: str,
        chapter: int,
        screen: int,
        location_desc: str,
        requirements: Optional[List[str]] = None,
    ) -> "SpoilerLogBuilder":
        """Add a key item location."""
        self._log.key_items.append(ItemLocation(
            item_name=item_name,
            chapter=chapter,
            screen=screen,
            location_desc=location_desc,
            requirements=requirements or [],
            is_key_item=True,
        ))
        return self

    def add_item(
        self,
        item_name: str,
        chapter: int,
        screen: int,
        location_desc: str,
        requirements: Optional[List[str]] = None,
        is_key_item: bool = False,
    ) -> "SpoilerLogBuilder":
        """Add an item location."""
        self._log.all_items.append(ItemLocation(
            item_name=item_name,
            chapter=chapter,
            screen=screen,
            location_desc=location_desc,
            requirements=requirements or [],
            is_key_item=is_key_item,
        ))
        return self

    def add_ally(
        self,
        name: str,
        chapter: int,
        screen: int,
        location_desc: str,
        requirements: Optional[List[str]] = None,
    ) -> "SpoilerLogBuilder":
        """Add an ally location."""
        self._log.allies.append(AllyLocation(
            name=name,
            chapter=chapter,
            screen=screen,
            location_desc=location_desc,
            requirements=requirements or [],
        ))
        return self

    def add_shop(
        self,
        chapter: int,
        screen: int,
        shop_type: str,
        location_desc: str,
        items: Optional[List[Dict[str, Any]]] = None,
    ) -> "SpoilerLogBuilder":
        """Add a shop inventory."""
        self._log.shops.append(ShopInventory(
            chapter=chapter,
            screen=screen,
            shop_type=shop_type,
            location_desc=location_desc,
            items=items or [],
        ))
        return self

    def add_shop_inventory(
        self,
        inventory: CoreShopInventory,
        location_desc: Optional[str] = None,
    ) -> "SpoilerLogBuilder":
        """Add a shop inventory from the core shop_inventory module.

        Args:
            inventory: CoreShopInventory object from shop randomization
            location_desc: Optional location description (auto-generated if not provided)

        Returns:
            Self for chaining
        """
        # Convert items to spoiler log format
        items = [
            {"name": slot.item.name, "price": slot.price}
            for slot in inventory.items
        ]

        # Generate location description if not provided
        if location_desc is None:
            location_desc = f"Screen {inventory.screen_index}"

        self._log.shops.append(ShopInventory(
            chapter=inventory.chapter,
            screen=inventory.screen_index,
            shop_type=inventory.shop_type.name.lower(),
            location_desc=location_desc,
            items=items,
        ))
        return self

    def add_chapter_shops(
        self,
        chapter_data: ChapterShopData,
    ) -> "SpoilerLogBuilder":
        """Add all shops from a chapter's shop data.

        Args:
            chapter_data: ChapterShopData from shop randomization

        Returns:
            Self for chaining
        """
        for inventory in chapter_data.inventories:
            self.add_shop_inventory(inventory)
        return self

    def add_chapter_map(
        self,
        chapter_num: int,
        screen_count: int,
        topology: str = "branching",
    ) -> "SpoilerLogBuilder":
        """Add chapter map info."""
        self._log.map_layout.append(ChapterMapInfo(
            chapter_num=chapter_num,
            screen_count=screen_count,
            topology=topology,
        ))
        return self

    def add_section_to_chapter(
        self,
        chapter_num: int,
        section_type: str,
        screen_count: int,
        shape: str,
        screens: Optional[List[int]] = None,
    ) -> "SpoilerLogBuilder":
        """Add a section to a chapter's map info."""
        for chapter_map in self._log.map_layout:
            if chapter_map.chapter_num == chapter_num:
                chapter_map.sections.append(SectionInfo(
                    section_type=section_type,
                    screen_count=screen_count,
                    shape=shape,
                    screens=screens or [],
                ))
                break
        return self

    def add_connection_to_chapter(
        self,
        chapter_num: int,
        from_section: str,
        to_section: str,
        method: str,
        screen: int,
    ) -> "SpoilerLogBuilder":
        """Add a connection to a chapter's map info."""
        for chapter_map in self._log.map_layout:
            if chapter_map.chapter_num == chapter_num:
                chapter_map.connections.append(ConnectionInfo(
                    from_section=from_section,
                    to_section=to_section,
                    method=method,
                    screen=screen,
                ))
                break
        return self

    def add_sphere(
        self,
        sphere_num: int,
        unlocked_by: Optional[List[str]] = None,
        items: Optional[List[str]] = None,
        locations: Optional[List[str]] = None,
        allies: Optional[List[str]] = None,
    ) -> "SpoilerLogBuilder":
        """Add a sphere to the analysis."""
        self._log.spheres.append(Sphere(
            sphere_num=sphere_num,
            unlocked_by=unlocked_by or [],
            items=items or [],
            locations=locations or [],
            allies=allies or [],
        ))
        return self

    def add_playthrough_step(
        self,
        chapter: int,
        step_num: int,
        action: str,
        location: str,
        screen: Optional[int] = None,
    ) -> "SpoilerLogBuilder":
        """Add a playthrough step."""
        self._log.playthrough.append(PlaythroughStep(
            chapter=chapter,
            step_num=step_num,
            action=action,
            location=location,
            screen=screen,
        ))
        return self

    def add_note(
        self,
        category: str,
        message: str,
    ) -> "SpoilerLogBuilder":
        """Add a special note."""
        self._log.special_notes.append(SpecialNote(
            category=category,
            message=message,
        ))
        return self

    def add_warning(self, message: str) -> "SpoilerLogBuilder":
        """Add a warning note."""
        return self.add_note("warning", message)

    def add_interesting(self, message: str) -> "SpoilerLogBuilder":
        """Add an interesting placement note."""
        return self.add_note("interesting", message)

    def add_difficulty_note(self, message: str) -> "SpoilerLogBuilder":
        """Add a difficulty note."""
        return self.add_note("difficulty", message)

    def build(self) -> SpoilerLog:
        """Build and return the spoiler log."""
        return self._log

    def write(
        self,
        output_dir: Union[str, Path],
        text_filename: str = "spoiler.txt",
        json_filename: str = "spoiler.json",
        write_text: bool = True,
        write_json: bool = True,
    ) -> Dict[str, Path]:
        """Write the spoiler log to files."""
        return write_spoiler_log(
            self._log,
            output_dir,
            text_filename,
            json_filename,
            write_text,
            write_json,
        )


# =============================================================================
# Helper Functions
# =============================================================================

def create_spoiler_from_config(
    seed: int,
    config: RandomizerConfig,
    rom_sha256: str = "",
) -> SpoilerLogBuilder:
    """Create a spoiler log builder initialized with config settings.

    Args:
        seed: Randomization seed
        config: RandomizerConfig with settings
        rom_sha256: SHA256 of output ROM

    Returns:
        SpoilerLogBuilder ready for use
    """
    builder = SpoilerLogBuilder(
        seed=seed,
        preset=config.difficulty.preset,
    )

    builder.set_rom_hash(rom_sha256)

    # Extract key settings for spoiler log
    settings = {
        "mode": config.general.mode,
        "chapters": config.general.chapters,
        "topology": config.connectivity.topology,
        "exclude_boss_screens": config.exclusions.boss_screens,
        "exclude_wizard_battles": config.exclusions.wizard_battles,
        "enemy_hp_multiplier": config.difficulty.enemy_hp_multiplier,
        "enemy_damage_multiplier": config.difficulty.enemy_damage_multiplier,
        "shop_price_multiplier": config.difficulty.shop_price_multiplier,
    }

    # Add shop randomization settings
    shop_config = config.difficulty.shop_randomization
    settings["shop_randomization_enabled"] = shop_config.enabled
    if shop_config.enabled:
        settings["shop_randomize_items"] = shop_config.randomize_items
        settings["shop_randomize_prices"] = shop_config.randomize_prices
        settings["shop_price_variance"] = shop_config.price_variance
        settings["shop_preserve_types"] = shop_config.preserve_shop_types

    # Add shuffling settings
    for section, shuffle_config in config.shuffling.items():
        settings[f"shuffle_{section}"] = shuffle_config.enabled

    builder.set_settings(settings)

    return builder
