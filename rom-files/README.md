# ROM Files

## TMOS_ORIGINAL.nes

**STATUS: READ-ONLY - DO NOT MODIFY**

This is the authoritative, unmodified ROM of "The Magic of Scheherazade" (NES).

| Property | Value |
|----------|-------|
| File | TMOS_ORIGINAL.nes |
| Size | 262,160 bytes (256KB + 16-byte iNES header) |
| MD5 | `b3236db14c87f375e5f24a5b9b79f071` |
| Source | `C:\Users\bcode\Desktop\Docker\fceux-docker\roms\TMOS\Magic of ScheherazadeORIGINAL.nes` |
| Added | 2026-01-24 |

## Rules

1. **NEVER write to TMOS_ORIGINAL.nes**
2. For hex editing tests, create a copy first
3. For randomizer output, use a different filename
4. Always verify MD5 matches before trusting analysis

## Working Copies

When you need to modify the ROM for testing:
```
cp TMOS_ORIGINAL.nes TMOS_test_YYYYMMDD.nes
```

Place test ROMs in `/testing/` folder, not here.
