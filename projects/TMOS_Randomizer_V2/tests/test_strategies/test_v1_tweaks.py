# tests/test_strategies/test_v1_tweaks.py
from tmos_randomizer.strategies.v1 import tweaks as TW


def test_seed_text_digits_and_padding():
    assert TW.seed_text_bytes(12345) == bytes([0x01, 0x02, 0x03, 0x04, 0x05, 0x2C])
    assert TW.seed_text_bytes(7) == bytes([0x07, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C])


def test_known_tweak_present():
    # Gilga eye HP: WriteByte(fs, 0x1743f, 0x06)  (RandomizeScript.cs:64)
    assert (0x1743F, bytes([0x06])) in TW.TWEAKS
    # troopers cost 200: WriteByte(fs, 0x4577, 0xc8)
    assert (0x4577, bytes([0xC8])) in TW.TWEAKS


def test_apply_tweaks_writes_bytes_and_seed():
    rom = bytearray(0x40000)
    TW.apply_tweaks(rom, 12345)
    assert rom[0x1743F] == 0x06
    assert rom[TW.SEED_TEXT_OFFSET:TW.SEED_TEXT_OFFSET + 6] == bytes([1, 2, 3, 4, 5, 0x2C])
