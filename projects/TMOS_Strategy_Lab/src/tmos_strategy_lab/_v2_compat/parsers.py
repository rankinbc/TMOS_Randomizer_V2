"""V2 parser re-exports (path-imported via ``_v2_compat.__init__``)."""
from __future__ import annotations

from . import V2_AVAILABLE

if V2_AVAILABLE:
    from tmos_randomizer.core import (  # type: ignore[import-untyped]
        CHAPTER_BASES,
        CHAPTER_OFFSETS,
        DO_NOT_RANDOMIZE,
        Chapter,
        ContentType,
        EventType,
        GameWorld,
        ObjectSetRegistry,
        SectionType,
        WorldScreen,
        build_registry_from_data,
        get_compatible_objectsets,
        relative_to_global,
    )
    from tmos_randomizer.core.enums import (  # type: ignore[import-untyped]
        NAV_BLOCKED,
        NAV_BUILDING_ENTRANCE,
        PAST_SCREEN_INDICES,
    )
    from tmos_randomizer.io.rom_reader import (  # type: ignore[import-untyped]
        ROMReader,
        load_chapter,
        load_rom,
    )
else:  # pragma: no cover — degraded shim; real run always has V2 available
    CHAPTER_BASES = {}
    CHAPTER_OFFSETS = {1: (0, 131), 2: (131, 137), 3: (268, 153), 4: (421, 164), 5: (585, 154)}
    DO_NOT_RANDOMIZE: set[int] = set()
    NAV_BLOCKED = 0xFF
    NAV_BUILDING_ENTRANCE = 0xFE
    PAST_SCREEN_INDICES: dict[int, set[int]] = {}

    class _Unavailable:
        def __getattr__(self, name: str):  # noqa: ANN001
            raise RuntimeError(
                f"V2 sibling not reachable — parsers.{name} is unavailable. "
                "Ensure TMOS_Randomizer_V2 is a sibling of this project."
            )

    Chapter = ContentType = EventType = GameWorld = ObjectSetRegistry = SectionType = WorldScreen = _Unavailable()  # type: ignore[assignment]
    build_registry_from_data = get_compatible_objectsets = relative_to_global = _Unavailable()  # type: ignore[assignment]
    ROMReader = load_chapter = load_rom = _Unavailable()  # type: ignore[assignment]


__all__ = [
    "CHAPTER_BASES",
    "CHAPTER_OFFSETS",
    "DO_NOT_RANDOMIZE",
    "NAV_BLOCKED",
    "NAV_BUILDING_ENTRANCE",
    "PAST_SCREEN_INDICES",
    "Chapter",
    "ContentType",
    "EventType",
    "GameWorld",
    "ObjectSetRegistry",
    "SectionType",
    "WorldScreen",
    "build_registry_from_data",
    "get_compatible_objectsets",
    "relative_to_global",
    "ROMReader",
    "load_chapter",
    "load_rom",
]
