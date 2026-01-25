#!/usr/bin/env python3
"""Standalone script to test section structure validation.

Usage:
    python test_section_validation.py [seed]

Example:
    python test_section_validation.py 12345
"""

import sys
import json
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from tmos_randomizer.io.rom_reader import load_rom
from tmos_randomizer.io.config_loader import get_default_config
from tmos_randomizer.randomizer import Randomizer
from tmos_randomizer.phases.phase4_population import populate_world
from tmos_randomizer.phases.phase5_navigation import rewrite_world_navigation
from tmos_randomizer.logic.navigation import find_components_in_subset, find_connected_components


def validate_section_structure(chapter, chapter_plan, chapter_pop, chapter_conn):
    """Validate that randomization output matches the plan."""
    issues = []
    section_details = []

    # Track which sections actually have screens assigned
    active_sections = set(chapter_pop.screen_assignments.keys())

    # Analyze each planned section
    for section_plan in chapter_plan.sections:
        section_id = section_plan.section_id
        section_type = section_plan.section_type.name
        planned_screens = section_plan.target_screen_count

        # Get assigned screens from population
        assigned_screens = chapter_pop.screen_assignments.get(section_id, [])
        assigned_count = len(assigned_screens)

        # Find connected components WITHIN this section's screens
        screen_set = set(assigned_screens)
        internal_components = find_components_in_subset(chapter, screen_set)
        component_count = len(internal_components)
        component_sizes = sorted([len(c) for c in internal_components], reverse=True)

        # Determine status
        # Skip checking preserved sections - they keep their original ROM structure
        if section_plan.preserve_original:
            if assigned_count == 0:
                status = "SKIPPED"  # Preserved section with no matching screens - expected
            else:
                status = "PRESERVED"  # Preserved section with original navigation - don't check fragmentation
        elif assigned_count == 0:
            status = "EMPTY"
            issues.append(f"Section {section_id} ({section_type}): No screens assigned")
        elif component_count > 1:
            status = "FRAGMENTED"
            issues.append(f"Section {section_id} ({section_type}): Fragmented into {component_count} components {component_sizes}")
        else:
            status = "OK"

        section_details.append({
            "section_id": section_id,
            "type": section_type,
            "planned": planned_screens,
            "assigned": assigned_count,
            "components": component_count,
            "sizes": component_sizes[:5],  # First 5 sizes
            "status": status,
        })

    # Identify preserved sections (no shape)
    preserved_sections = set()
    for sp in chapter_plan.sections:
        if sp.preserve_original:
            preserved_sections.add(sp.section_id)

    # Analyze inter-section connections
    connection_details = []
    if chapter_conn:
        for conn in chapter_conn.connections:
            from_section = conn.from_section_id
            to_section = conn.to_section_id

            from_screens = chapter_pop.screen_assignments.get(from_section, [])
            to_screens = chapter_pop.screen_assignments.get(to_section, [])

            # Skip connections involving sections with no assigned screens
            # (preserved sections that don't exist in this chapter)
            if not from_screens or not to_screens:
                connection_details.append({
                    "from": from_section,
                    "to": to_section,
                    "connected": None,  # N/A - section doesn't exist
                })
                continue

            # Skip checking connections FROM preserved sections
            # (they keep their original navigation which may not point to randomized sections)
            if from_section in preserved_sections:
                connection_details.append({
                    "from": from_section,
                    "to": to_section,
                    "connected": None,  # N/A - preserved section keeps original exits
                })
                continue

            # Check if ANY screen from from_section connects to ANY screen in to_section
            connected = False
            for from_idx in from_screens:
                screen = chapter.get_screen(from_idx)
                if screen is None:
                    continue

                for direction in ["right", "left", "down", "up"]:
                    attr = f"screen_index_{direction}"
                    target = getattr(screen, attr)
                    if target in to_screens:
                        connected = True
                        break
                if connected:
                    break

            if not connected:
                issues.append(f"Connection {from_section} -> {to_section}: MISSING")

            connection_details.append({
                "from": from_section,
                "to": to_section,
                "connected": connected,
            })

    return {
        "section_details": section_details,
        "connection_details": connection_details,
        "issues": issues,
    }


def main():
    # Get seed from command line or use default
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 12345

    # ROM path
    rom_path = Path(__file__).parent.parent.parent / "rom-files" / "TMOS_ORIGINAL.nes"
    if not rom_path.exists():
        print(f"ERROR: ROM not found at {rom_path}")
        return 1

    print(f"=" * 60)
    print(f"SECTION STRUCTURE VALIDATION TEST")
    print(f"=" * 60)
    print(f"ROM: {rom_path.name}")
    print(f"Seed: {seed}")
    print()

    # Load ROM
    print("Loading ROM...")
    game_world = load_rom(rom_path)

    # Create randomizer and plan
    print("Creating randomization plan...")
    config = get_default_config()
    randomizer = Randomizer(config)
    plan = randomizer.create_plan(seed)

    print(f"Plan: {len(plan.world_plan.chapters)} chapters")
    for cp in plan.world_plan.chapters:
        print(f"  Chapter {cp.chapter_num}: {len(cp.sections)} sections, {cp.planned_screens} screens")

    # Phase 4: Population
    print("\nRunning Phase 4 (Population)...")
    world_population = populate_world(
        game_world=game_world,
        world_plan=plan.world_plan,
        world_shape=plan.world_shape,
        seed=seed,
    )
    plan.world_population = world_population

    # Phase 5: Navigation
    print("Running Phase 5 (Navigation)...")
    world_navigation = rewrite_world_navigation(
        game_world=game_world,
        world_shape=plan.world_shape,
        world_connections=plan.world_connections,
        world_population=world_population,
        seed=seed,
        preserve_buildings=True,
    )

    # Validate each chapter
    print("\n" + "=" * 60)
    print("VALIDATION RESULTS")
    print("=" * 60)

    all_passed = True

    for chapter_num in range(1, 6):
        chapter = game_world.chapters.get(chapter_num)
        chapter_plan = plan.world_plan.get_chapter(chapter_num)
        chapter_pop = world_population.get_chapter(chapter_num)
        chapter_conn = plan.world_connections.get_chapter(chapter_num)

        if not all([chapter, chapter_plan, chapter_pop]):
            continue

        result = validate_section_structure(chapter, chapter_plan, chapter_pop, chapter_conn)

        # Overall navigation components (for comparison)
        nav_components = find_connected_components(chapter)

        print(f"\n{'='*60}")
        print(f"CHAPTER {chapter_num}")
        print(f"{'='*60}")
        print(f"Planned: {len(chapter_plan.sections)} sections")
        print(f"Navigation graph: {len(nav_components)} components (sizes: {sorted([len(c) for c in nav_components], reverse=True)[:5]})")
        print()

        # Section details
        print("Section Analysis:")
        print("-" * 50)
        for s in result["section_details"]:
            if s["status"] == "SKIPPED":
                status_icon = "[--]"
            elif s["status"] == "PRESERVED":
                status_icon = "[~~]"  # Preserved section - original structure
            elif s["status"] == "OK":
                status_icon = "[OK]"
            else:
                status_icon = "[!!]"
            print(f"  {status_icon} Section {s['section_id']:2} ({s['type']:10}): "
                  f"planned={s['planned']:3}, assigned={s['assigned']:3}, "
                  f"components={s['components']}")
            if s["status"] not in ("OK", "SKIPPED", "PRESERVED"):
                print(f"      -> Component sizes: {s['sizes']}")

        # Connection details
        if result["connection_details"]:
            print("\nInter-Section Connections:")
            print("-" * 50)
            for c in result["connection_details"]:
                if c["connected"] is None:
                    status_icon = "[--]"  # Section doesn't exist
                elif c["connected"]:
                    status_icon = "[OK]"
                else:
                    status_icon = "[!!]"
                print(f"  {status_icon} Section {c['from']} -> Section {c['to']}")

        # Issues
        if result["issues"]:
            all_passed = False
            print("\n!! ISSUES:")
            for issue in result["issues"]:
                print(f"  - {issue}")
        else:
            print("\n[OK] All sections properly structured!")

    print("\n" + "=" * 60)
    if all_passed:
        print("OVERALL: PASS")
    else:
        print("OVERALL: FAIL")
    print("=" * 60)

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
