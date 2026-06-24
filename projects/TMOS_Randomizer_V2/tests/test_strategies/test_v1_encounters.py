import random

from tmos_randomizer.strategies.v1 import encounters as E
from tmos_randomizer.core.encounter_lineups import LINEUP_BASE, LINEUP_COUNT, LINEUP_SIZE
from tmos_randomizer.core.encounter_groups import GROUP_BASE


def _rom_with_lineups(chapter):
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE
    rom = bytearray(0x40000)
    # Fill the lineup block with distinct "monster" bytes plus some empties.
    for k in range(size):
        rom[base + k] = 0x00 if k % LINEUP_SIZE == 0 else (0x10 + k)
    return bytes(rom)


def test_lineup_patches_preserve_multiset_and_keep_empties_fixed():
    chapter = 1
    rom = _rom_with_lineups(chapter)
    base = LINEUP_BASE[chapter]
    size = LINEUP_COUNT[chapter] * LINEUP_SIZE

    patches = E.shuffle_lineup_patches(rom, chapter, random.Random(7))
    patched = bytearray(rom)
    for off, val in patches:
        patched[off] = val

    before = sorted(b for b in rom[base:base + size] if b not in (0x00, 0x01, 0xFF))
    after = sorted(b for b in patched[base:base + size] if b not in (0x00, 0x01, 0xFF))
    assert before == after                      # same monsters, rearranged
    # start_byte slots (every LINEUP_SIZE-th) stay 0x00
    for li in range(LINEUP_COUNT[chapter]):
        assert patched[base + li * LINEUP_SIZE] == 0x00


def test_lineup_patches_are_deterministic():
    rom = _rom_with_lineups(2)
    p1 = E.shuffle_lineup_patches(rom, 2, random.Random(99))
    p2 = E.shuffle_lineup_patches(rom, 2, random.Random(99))
    assert p1 == p2


def test_group_pointer_patches():
    patches = E.group_pointer_patches(3, {0: 0x1B, 2: 0x40})
    base = GROUP_BASE[3]
    assert (base + 0 * E.GROUP_ENTRY_SIZE, 0x1B) in patches
    assert (base + 2 * E.GROUP_ENTRY_SIZE, 0x40) in patches
