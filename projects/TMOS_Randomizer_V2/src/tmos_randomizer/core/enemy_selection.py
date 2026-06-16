"""Canonical source of selectable turn-based enemy IDs.

Every UI dropdown that lets the user choose a battle enemy (encounter lineups,
etc.) should call :func:`selectable_enemy_ids` so all surfaces filter
identically.  The function excludes every ID in
:data:`~tmos_randomizer.core.enums.CONSERVATIVE_DANGER_ENEMY_IDS` — IDs that
either hard-crash the game (``CRASH_ENEMY_IDS``) or have unknown/dangerous
behaviour (0x0F, 0x17, 0x25).

The roster itself is read from :mod:`tmos_randomizer.core.enemies`; no data
is duplicated here.
"""

from __future__ import annotations

from .enemies import list_battle_enemies
from .enums import CONSERVATIVE_DANGER_ENEMY_IDS


def selectable_enemy_ids() -> list[dict]:
    """Return every turn-based enemy that is safe to offer in UI dropdowns.

    Excludes all IDs in ``CONSERVATIVE_DANGER_ENEMY_IDS`` (crash IDs 0x0B,
    0x0C plus dangerous/unknown variants 0x0F, 0x17, 0x25).

    Returns:
        Sorted list of dicts, each with keys:
        ``enemy_id`` (int), ``enemy_id_hex`` (str, e.g. ``"0x0D"``),
        ``name`` (str).
    """
    return [
        {
            "enemy_id": e["enemy_id"],
            "enemy_id_hex": e["enemy_id_hex"],
            "name": e["name"],
        }
        for e in list_battle_enemies()
        if e["enemy_id"] not in CONSERVATIVE_DANGER_ENEMY_IDS
    ]
