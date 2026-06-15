"""SPIKE (read-only, temporary): confirm the ObjectSet spawn-data header length.

Loads the default ROM if present; prints the raw bytes at the spawn addresses for
known World-1 ObjectSets and asserts the documented 3-byte-header / [type][x][y]
layout. Delete after the parser lands.

Per knowledge/structures/objectset.md:
  Ch1 pointer table @ 0x38933, base 0x37000, pointers little-endian.
  ObjectSet 0x05 spawn @ 0x38B55, header 20 4D 00, then 11.. x4, then 00.
  ObjectSet 0x0B spawn @ 0x38BA3, header 24 7E 00, then 1C.. x4.
"""
import pytest

from tmos_randomizer.api import server

PTR_TABLE_CH1 = 0x38933
BASE = 0x37000


def _rom():
    # Reuse the server's load path so we exercise the same bytes the endpoint will.
    from fastapi.testclient import TestClient
    c = TestClient(server.app)
    if c.post("/api/rom/load-default").status_code != 200:
        pytest.skip("default ROM not available")
    rom = server._rom_data
    if rom is None:
        pytest.skip("ROM bytes not available on server module")
    return rom


def _spawn_addr(rom, objectset_id):
    p = PTR_TABLE_CH1 + objectset_id * 2
    ptr = rom[p] | (rom[p + 1] << 8)
    return BASE + ptr


def test_spike_header_is_three_bytes():
    rom = _rom()
    for osid, first_type in ((0x05, 0x11), (0x0B, 0x1C)):
        addr = _spawn_addr(rom, osid)
        window = bytes(rom[addr:addr + 16])
        print(f"ObjectSet 0x{osid:02X} @ 0x{addr:05X}: {window.hex(' ')}")
        # With a 3-byte header, byte index 3 is the first enemy type.
        assert window[3] == first_type, (
            f"Expected first entry type 0x{first_type:02X} at offset 3, "
            f"got 0x{window[3]:02X} (header may not be 3 bytes)"
        )
        # Entries are 3-byte stride: next type at offset 6 should be the same enemy.
        assert window[6] == first_type
