"""V1 SaveRom fixed patch layer (boss rebalance, shop costs, cosmetics, intro).
Transcribed from RandomizeScript.cs:42-222. Excludes per-screen/encounter writes
and the dynamic seed text (handled elsewhere). Gated by config v1.apply_tweaks.
"""
from __future__ import annotations

SEED_TEXT_OFFSET = 0x038493

# (absolute_offset, bytes) — verbatim static SaveRom writes from RandomizeScript.cs:42-222.
# Excludes:
#   - foreach WorldScreenCollection wc ... wc.WriteDataToRom(ref fs)  [per-screen, Task 5]
#   - GetSeedTextBytes at 0x038493  [dynamic seed, handled by seed_text_bytes()]
#   - All commented-out C# blocks (bread/mushroom max, mosque dialog, first guy sprite,
#     risky town shuffle)
# Duplicates preserved as-is (TROLL thunder damage written twice at 0x18759).
TWEAKS: list[tuple[int, bytes]] = [
    # Screen1 tile change
    (0x03F687, bytes([0x4D, 0x20, 0xB8, 0xC4, 0xC6, 0xB8, 0x20, 0x4D,
                      0x4D, 0x20, 0xB9, 0xC5, 0xC7, 0xB9, 0x20, 0x4D,
                      0x4D, 0xB8, 0xB8, 0xC0, 0xC3, 0xB8, 0xB8, 0x4D,
                      0x4D, 0xB9, 0xB9, 0xC0, 0xC3, 0xB9, 0xB9, 0x4D])),
    (0x03F7C7, bytes([0x73, 0x73, 0x73, 0x73, 0x73, 0x73, 0x73, 0x73,
                      0xBF, 0x73, 0xBE, 0xBF, 0x73, 0x73, 0x73, 0xBE, 0x4D])),

    # GILGA
    (0x1743F, bytes([0x06])),   # eye hp
    (0x17447, bytes([0x1C])),   # stage 2 hp damage
    (0x18751, bytes([0x20])),   # thunder damage
    (0x17248, bytes([0x0D])),   # projectile damage
    (0x174C6, bytes([0x04])),   # projectile speed

    # CURLY
    (0x17450, bytes([0x1D])),              # Arm HP
    (0x1724C, bytes([0x22])),              # Projectile damage
    (0x1724F, bytes([0x01])),              # projectile cooldown
    (0x1156E, bytes([0xAA, 0x66, 0x03])), # Color

    # TROLL
    (0x17A24, bytes([0x1B])),   # Switch position delay time
    (0x17459, bytes([0x80])),   # HP (parts 1 and 2)
    (0x18759, bytes([0x24])),   # thunder damage  (first write)
    (0x18759, bytes([0x24])),   # thunder damage  (duplicate — preserved verbatim from C#)

    # TROLL part 2
    (0x17250, bytes([0x24])),   # Projectile damage
    (0x17251, bytes([0x05])),   # projectile behavior
    (0x17253, bytes([0x01])),   # projectile cooldown
    (0x17455, bytes([0x05])),   # collision damage

    # SALAMANDER
    (0x17462, bytes([0xE0])),   # HP
    (0x17257, bytes([0x00])),   # projectile cooldown
    (0x17255, bytes([0x03])),   # projectile speed
    (0x1875D, bytes([0x38])),   # fire magic dmg
    (0x18A2E, bytes([0xF6])),   # fire field animation

    # Part before goragora
    (0x3C458, bytes([0x1F])),
    (0x3C448, bytes([0x0D])),
    (0x3C478, bytes([0x0D])),
    (0x3C468, bytes([0x0D])),
    (0x03C488, bytes([0x0F])),
    (0x3C418, bytes([0x2F])),
    (0x03C498, bytes([0x2F])),

    # Cut exp given by world enemies by half
    (0x174AA, bytes([0x01, 0x00, 0x02, 0x00, 0x05, 0x00, 0x0A, 0x00,
                     0x0F, 0x00, 0x14, 0x00, 0x19, 0x00, 0x02, 0x00, 0x04])),

    # make troopers cost 200
    (0x4577, bytes([0xC8])),

    # change university costs
    (0x52B2, bytes([0x05])),
    (0x52B4, bytes([0x14])),
    (0x52B6, bytes([0x14])),
    (0x51B8, bytes([0x14])),

    (0x52C1, bytes([0x16])),
    (0x52C3, bytes([0x28])),
    (0x52C5, bytes([0x28])),

    (0x52D0, bytes([0x25])),
    (0x52D2, bytes([0x3C])),
    (0x52D4, bytes([0x3C])),
    (0x51D6, bytes([0x3C])),

    (0x52DF, bytes([0x32])),
    (0x52E1, bytes([0x50])),
    (0x52E3, bytes([0x50])),

    (0x52EE, bytes([0x40])),
    (0x52F0, bytes([0x64])),
    (0x52F2, bytes([0x64])),

    # Player clothes color
    (0x1ED07, bytes([0x02])),   # normal
    (0xCA72,  bytes([0x02])),   # battle
    (0x1ED0A, bytes([0x03])),   # r armor
    (0xCA75,  bytes([0x03])),   # r armor battle

    # StartScreen Title Color  (fs.Seek / fs.Write)
    (0x38890, bytes([0x72])),
    (0x38892, bytes([0x02])),
    (0x38894, bytes([0x12])),

    # StartScreen Text mod
    (0x038473, bytes([0x41, 0x30, 0x3D, 0x33, 0x3E, 0x3C, 0x38, 0x49,
                      0x34, 0x33, 0x2C, 0x23, 0x64, 0x18, 0x3C, 0x3E,
                      0x33, 0x2C, 0x31, 0x48, 0x2C, 0x32, 0x43, 0x01,
                      0x08, 0x07, 0x2C, 0x42, 0x34, 0x34, 0x33, 0x2C])),

    # First Screen character dialog
    (0x0215B5, bytes([0x80, 0xC9, 0x2C, 0x46, 0x3E, 0x41, 0x3B, 0x33,
                      0x2C, 0x20, 0x10, 0x42, 0x2C, 0x31, 0x12, 0x12,
                      0x3D, 0x2C, 0x41, 0x10, 0x3D, 0x33, 0x3E, 0x21,
                      0x38, 0x49, 0x12, 0x33, 0x4F, 0x2E, 0x12, 0x3D,
                      0x39, 0x3E, 0x48, 0x7D, 0x2C, 0x4B, 0x2F])),

    # center first guy (fs.Seek / fs.Write)
    (0x013C70, bytes([0xF1])),
    (0x013C74, bytes([0xF9])),

    # starting screen (fs.Seek / fs.Write)
    (0x039CC8, bytes([0x21])),
    (0x039CC6, bytes([0x04])),
    (0x039CD1, bytes([0xA3])),
    (0x039CD2, bytes([0xDF])),
]


def seed_text_bytes(seed: int) -> bytes:
    """Return 6 bytes for the seed display: each decimal digit → its value,
    right-padded with 0x2C (space character in TMOS font)."""
    out = bytearray([0x2C] * 6)
    for i, ch in enumerate(str(seed)[:6]):
        out[i] = int(ch)
    return bytes(out)


def apply_tweaks(rom: bytearray, seed: int) -> None:
    """Apply all static TWEAKS then the dynamic seed text to *rom* in place."""
    for offset, data in TWEAKS:
        rom[offset:offset + len(data)] = data
    text = seed_text_bytes(seed)
    rom[SEED_TEXT_OFFSET:SEED_TEXT_OFFSET + len(text)] = text
