"""Tests for core/player_stats.py — nibble safety, ROM round-trip, presets, transforms."""

from pathlib import Path

import pytest

from tmos_randomizer.core import player_stats as ps


ROM_PATH = Path(__file__).resolve().parents[2] / "TMOS_ORIGINAL.nes"


@pytest.fixture(scope="module")
def vanilla_rom() -> bytes:
    if not ROM_PATH.exists():
        pytest.skip(f"ROM not found at {ROM_PATH}")
    return ROM_PATH.read_bytes()


# ---------------------------------------------------------------------------
# Nibble round-trip — exhaustive
# ---------------------------------------------------------------------------

class TestNibbles:
    def test_pack_unpack_round_trip_all_256_bytes(self):
        for b in range(256):
            s, r = ps._unpack(b)
            assert ps._pack(s, r) == b, f"round-trip failed for byte 0x{b:02X}"

    def test_unpack_pack_round_trip_all_nibble_pairs(self):
        for s in range(16):
            for r in range(16):
                packed = ps._pack(s, r)
                assert ps._unpack(packed) == (s, r)

    def test_high_nibble_is_sword(self):
        # 0xA5 = sword 10, rod 5
        assert ps._unpack(0xA5) == (10, 5)
        assert ps._pack(10, 5) == 0xA5

    def test_packing_truncates_oob_input(self):
        # _pack masks both inputs to 4 bits — defensive against caller bugs
        assert ps._pack(0x1F, 0x2F) == ps._pack(0xF, 0xF)


# ---------------------------------------------------------------------------
# Vanilla read — confirms our ROM offsets are right
# ---------------------------------------------------------------------------

class TestReadVanilla:
    def test_hp_table_starts_with_known_values(self, vanilla_rom):
        # From player_damage_table.md: HP grows by 8 per level from 50
        stats = ps.read_player_stats(vanilla_rom)
        assert len(stats["hp"]) == 25
        assert stats["hp"][0] == 50
        assert stats["hp"][1] == 58
        assert stats["hp"][2] == 66
        assert stats["hp"][24] == 255  # capped

    def test_damage_values_match_known_vanilla(self, vanilla_rom):
        # Documented vanilla values
        stats = ps.read_player_stats(vanilla_rom)
        assert stats["damage_values"] == [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 15, 16, 18]

    def test_sword_indices_known_levels(self, vanilla_rom):
        # Spot-check from disassembly: L1 sword=1, L25 sword=13
        stats = ps.read_player_stats(vanilla_rom)
        assert stats["sword_indices"][0] == 1     # level 1
        assert stats["sword_indices"][24] == 13   # level 25
        assert all(0 <= s <= 15 for s in stats["sword_indices"])

    def test_rod_indices_known_levels(self, vanilla_rom):
        stats = ps.read_player_stats(vanilla_rom)
        assert stats["rod_indices"][0] == 0       # level 1 rod is weakest
        assert all(0 <= r <= 15 for r in stats["rod_indices"])

    def test_rom_offsets_in_response(self, vanilla_rom):
        stats = ps.read_player_stats(vanilla_rom)
        assert stats["rom_offsets"]["hp"] == "0x1F734"
        assert stats["rom_offsets"]["damage_indices"] == "0x1F667"
        assert stats["rom_offsets"]["damage_values"] == "0x1F680"


# ---------------------------------------------------------------------------
# Write — sword and rod must be independently mutable without cross-contamination
# ---------------------------------------------------------------------------

class TestWrite:
    def test_sword_write_preserves_rod(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        original_rod = ps._unpack(vanilla_rom[ps.DMG_INDEX_OFFSET + 4])[1]
        ps.write_sword_index(rom, level=5, value=15)
        s, r = ps._unpack(rom[ps.DMG_INDEX_OFFSET + 4])
        assert s == 15
        assert r == original_rod, "rod nibble was clobbered by sword write"

    def test_rod_write_preserves_sword(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        original_sword = ps._unpack(vanilla_rom[ps.DMG_INDEX_OFFSET + 9])[0]
        ps.write_rod_index(rom, level=10, value=15)
        s, r = ps._unpack(rom[ps.DMG_INDEX_OFFSET + 9])
        assert s == original_sword
        assert r == 15

    def test_hp_write_round_trip(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.write_hp(rom, level=12, value=200)
        assert rom[ps.HP_TABLE_OFFSET + 11] == 200

    def test_damage_value_write_round_trip(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.write_damage_value(rom, index=7, value=99)
        assert rom[ps.DMG_VALUE_OFFSET + 7] == 99

    @pytest.mark.parametrize("level", [0, 26, -1])
    def test_invalid_level(self, vanilla_rom, level):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError):
            ps.write_hp(rom, level=level, value=10)

    @pytest.mark.parametrize("value", [-1, 16, 100])
    def test_index_value_bounds(self, vanilla_rom, value):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError):
            ps.write_sword_index(rom, level=1, value=value)


# ---------------------------------------------------------------------------
# Resolution — the indirection chain
# ---------------------------------------------------------------------------

class TestResolution:
    def test_sword_damage_resolves_through_indirection(self, vanilla_rom):
        # Level 1: sword index 1 → damage value 2
        assert ps.resolve_sword_damage(vanilla_rom, 1) == 2
        # Level 25: sword index 13 → damage value 18 (top of table)
        assert ps.resolve_sword_damage(vanilla_rom, 25) == 18

    def test_levels_using_damage_index_returns_cascade(self, vanilla_rom):
        # Index 3 should be used by some sword and rod levels
        usage = ps.levels_using_damage_index(vanilla_rom, 3)
        assert usage["sword"] == [5, 6, 7]   # vanilla: sword L5-L7 use index 3
        assert usage["rod"] == [9, 10]        # vanilla: rod L9-L10 use index 3


# ---------------------------------------------------------------------------
# Preview — consequence calculation
# ---------------------------------------------------------------------------

class TestPreview:
    def test_preview_includes_all_chapter_enemies(self, vanilla_rom):
        preview = ps.compute_preview(vanilla_rom, vanilla_rom, level=10)
        assert preview["level"] == 10
        # Should include every chapter
        chapters_present = {int(e["name"].split()[0][2:]) for e in preview["enemy_kills"]}
        assert chapters_present == {1, 2, 3, 4, 5}

    def test_preview_hit_count_uses_ceil_division(self, vanilla_rom):
        preview = ps.compute_preview(vanilla_rom, vanilla_rom, level=1)
        # Level 1 sword damage = 2. Bee HP=3 -> ceil(3/2) = 2 hits.
        bee = next(e for e in preview["enemy_kills"] if "Bee" in e["name"])
        assert bee["sword_hits"] == 2

    def test_preview_diff_vs_vanilla(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        # Buff sword index at level 5 from 3 -> 13 (max value -> dmg 18)
        ps.write_sword_index(rom, level=5, value=13)
        preview = ps.compute_preview(bytes(rom), vanilla_rom, level=5)
        assert preview["sword_damage"] == 18
        assert preview["sword_damage_vanilla"] == 4  # vanilla level 5 sword index=3 -> 4
        # Pick a Ch5 enemy where the buff actually changes hit count
        gorgon = next(e for e in preview["enemy_kills"] if "Gorgon1" in e["name"])
        assert gorgon["sword_hits"] < gorgon["sword_hits_vanilla"]

    def test_preview_rejects_invalid_level(self, vanilla_rom):
        with pytest.raises(ValueError):
            ps.compute_preview(vanilla_rom, vanilla_rom, level=0)

    def test_zero_damage_returns_999_hits(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        # Set damage value 1 (used by sword L1) to 0
        ps.write_damage_value(rom, index=1, value=0)
        preview = ps.compute_preview(bytes(rom), vanilla_rom, level=1)
        bee = next(e for e in preview["enemy_kills"] if "Bee" in e["name"])
        assert bee["sword_hits"] == 999


# ---------------------------------------------------------------------------
# Presets
# ---------------------------------------------------------------------------

class TestPresets:
    def test_list_presets_returns_named_descriptions(self):
        presets = ps.list_presets()
        names = {p["name"] for p in presets}
        assert names == {"vanilla", "easy", "hardcore", "glass_cannon", "tank", "speedrun", "romhack1_halved"}
        for p in presets:
            assert p["description"]

    def test_vanilla_preset_restores_modifications(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.write_hp(rom, level=5, value=200)
        ps.write_sword_index(rom, level=5, value=15)
        ps.apply_preset(rom, vanilla_rom, "vanilla")
        assert bytes(rom[ps.HP_TABLE_OFFSET : ps.HP_TABLE_OFFSET + 25]) == vanilla_rom[ps.HP_TABLE_OFFSET : ps.HP_TABLE_OFFSET + 25]

    def test_easy_preset_buffs_hp_and_damage(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_preset(rom, vanilla_rom, "easy")
        # HP at level 1 was 50 -> 75; clamped at 255
        assert rom[ps.HP_TABLE_OFFSET] == 75
        # Damage value 0 was 1 -> 1.25 -> rounded to 1; value 4 was 5 -> 6.25 -> 6
        assert rom[ps.DMG_VALUE_OFFSET + 4] == 6

    def test_hardcore_preset_halves(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_preset(rom, vanilla_rom, "hardcore")
        assert rom[ps.HP_TABLE_OFFSET] == 25  # 50 / 2

    def test_speedrun_preset_maxes_everything(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_preset(rom, vanilla_rom, "speedrun")
        for level in range(1, 26):
            assert rom[ps.HP_TABLE_OFFSET + (level - 1)] == 255
            s, r = ps._unpack(rom[ps.DMG_INDEX_OFFSET + (level - 1)])
            assert s == 13 and r == 13  # max valid index

    def test_romhack1_halves_damage_values_only(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_preset(rom, vanilla_rom, "romhack1_halved")
        # Entries 0-8 halved, 9-13 untouched
        assert rom[ps.DMG_VALUE_OFFSET + 0] == 1   # max(1, 1//2) = 1
        assert rom[ps.DMG_VALUE_OFFSET + 4] == 2   # 5 // 2 = 2
        assert rom[ps.DMG_VALUE_OFFSET + 8] == 5   # 10 // 2 = 5
        assert rom[ps.DMG_VALUE_OFFSET + 9] == vanilla_rom[ps.DMG_VALUE_OFFSET + 9]
        # HP untouched
        assert rom[ps.HP_TABLE_OFFSET] == vanilla_rom[ps.HP_TABLE_OFFSET]

    def test_unknown_preset_raises(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        with pytest.raises(ValueError, match="unknown preset"):
            ps.apply_preset(rom, vanilla_rom, "nonexistent")


# ---------------------------------------------------------------------------
# Bulk transforms
# ---------------------------------------------------------------------------

class TestTransforms:
    def test_scale_hp_in_range(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_transform(rom, vanilla_rom, target="hp", op="scale",
                           params={"factor": 2.0}, range_start=1, range_end=5)
        # Level 1: 50 -> 100; level 6 (out of range) untouched
        assert rom[ps.HP_TABLE_OFFSET] == 100
        assert rom[ps.HP_TABLE_OFFSET + 5] == vanilla_rom[ps.HP_TABLE_OFFSET + 5]

    def test_offset_damage_value(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_transform(rom, vanilla_rom, target="damage_value", op="offset",
                           params={"delta": 5}, range_start=0, range_end=3)
        # Index 0: 1 + 5 = 6; out of range untouched
        assert rom[ps.DMG_VALUE_OFFSET] == 6
        assert rom[ps.DMG_VALUE_OFFSET + 4] == vanilla_rom[ps.DMG_VALUE_OFFSET + 4]

    def test_set_sword_index_preserves_rod(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        original_rods = [ps._unpack(vanilla_rom[ps.DMG_INDEX_OFFSET + i])[1] for i in range(25)]
        ps.apply_transform(rom, vanilla_rom, target="sword_index", op="set",
                           params={"value": 5}, range_start=1, range_end=25)
        for i in range(25):
            s, r = ps._unpack(rom[ps.DMG_INDEX_OFFSET + i])
            assert s == 5
            assert r == original_rods[i], f"rod nibble corrupted at level {i+1}"

    def test_reset_restores_vanilla(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.write_hp(rom, level=5, value=200)
        ps.apply_transform(rom, vanilla_rom, target="hp", op="reset", params={},
                           range_start=5, range_end=5)
        assert rom[ps.HP_TABLE_OFFSET + 4] == vanilla_rom[ps.HP_TABLE_OFFSET + 4]

    def test_clamp_on_overflow(self, vanilla_rom):
        rom = bytearray(vanilla_rom)
        ps.apply_transform(rom, vanilla_rom, target="hp", op="scale",
                           params={"factor": 10.0}, range_start=1, range_end=25)
        # Every level should be clamped to 255
        assert all(rom[ps.HP_TABLE_OFFSET + i] == 255 for i in range(25))
