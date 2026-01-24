"""Output generation (spoiler logs, ROM patching)."""

from .spoiler_log import (
    # Data structures
    ItemLocation,
    AllyLocation,
    ShopInventory,
    SectionInfo,
    ConnectionInfo,
    ChapterMapInfo,
    Sphere,
    PlaythroughStep,
    SpecialNote,
    SpoilerLog,
    # Builder
    SpoilerLogBuilder,
    # Generation functions
    generate_text_spoiler,
    generate_json_spoiler,
    write_spoiler_log,
    load_spoiler_log,
    create_spoiler_from_config,
)

__all__ = [
    # Data structures
    "ItemLocation",
    "AllyLocation",
    "ShopInventory",
    "SectionInfo",
    "ConnectionInfo",
    "ChapterMapInfo",
    "Sphere",
    "PlaythroughStep",
    "SpecialNote",
    "SpoilerLog",
    # Builder
    "SpoilerLogBuilder",
    # Generation functions
    "generate_text_spoiler",
    "generate_json_spoiler",
    "write_spoiler_log",
    "load_spoiler_log",
    "create_spoiler_from_config",
]
