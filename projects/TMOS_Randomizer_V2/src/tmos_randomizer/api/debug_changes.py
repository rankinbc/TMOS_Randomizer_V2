"""ROM-vs-vanilla structured diff for the Debug tab.

Pure logic (no FastAPI imports). Compares the mutable working ROM against the
immutable vanilla snapshot and reports every differing field, grouped by system.
Derived from ROM state, so it is authoritative and refresh-proof — unlike the
session edit log.
"""
from __future__ import annotations

from typing import Any, Callable, List, Tuple

Provider = Tuple[str, Callable[[bytes], Any]]


def _walk(path: str, cur: Any, van: Any, out: List[dict]) -> None:
    if isinstance(cur, dict) and isinstance(van, dict):
        for key in sorted(set(cur) | set(van), key=str):
            child = f"{path}.{key}" if path else str(key)
            _walk(child, cur.get(key), van.get(key), out)
    elif isinstance(cur, list) and isinstance(van, list):
        for i in range(max(len(cur), len(van))):
            c = cur[i] if i < len(cur) else None
            v = van[i] if i < len(van) else None
            _walk(f"{path}[{i}]", c, v, out)
    elif cur != van:
        out.append({"label": path, "vanilla": van, "current": cur})


def diff_structured(current_obj: Any, vanilla_obj: Any) -> List[dict]:
    """Recursively diff two JSON-able structures; return leaf-level changes."""
    out: List[dict] = []
    _walk("", current_obj, vanilla_obj, out)
    return out


def build_changes(rom: bytes, vanilla: bytes, providers: List[Provider]) -> dict:
    """Diff `rom` vs `vanilla` through each provider; aggregate into groups.

    A provider that raises is skipped (a single broken reader must not blank the
    whole report). `differing_bytes` is the raw byte-level delta so the UI can
    flag when structured groups under-account for what actually changed.
    """
    groups: List[dict] = []
    total = 0
    for system, reader in providers:
        try:
            entries = diff_structured(reader(rom), reader(vanilla))
        except Exception:
            continue
        if entries:
            groups.append({"system": system, "count": len(entries), "entries": entries})
            total += len(entries)

    differing_bytes = sum(1 for a, b in zip(rom, vanilla) if a != b) + abs(len(rom) - len(vanilla))
    return {"total_changes": total, "groups": groups, "differing_bytes": differing_bytes}
