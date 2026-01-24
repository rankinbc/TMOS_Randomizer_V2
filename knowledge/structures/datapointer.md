# DataPointer Analysis

**Last Updated**: 2026-01-24
**WorldScreen Offset**: Byte 8
**RAM Mirror**: `$B8` (when screen loaded)
**Confidence**: HIGH (disassembly verified)

---

## Overview

DataPointer controls which tile section "bank" is used when rendering the top and bottom halves of a WorldScreen. This was reverse-engineered from the LoadWorldScreen routine at `$841B`.

---

## Bit Layout

```
DataPointer: [7][6][5][4][3][2][1][0]
              │  │  └──────┬──────┘
              │  │         └── Bits 0-5: Unknown (masked to $38)
              │  └── Bit 6: Bottom tiles bank select
              └── Bit 7: Top tiles bank select
```

---

## Disassembly Evidence

From LoadWorldScreen at `$841B` (Bank 4):

```
$8432:  A5 B8       LDA $B8        ; Load DataPointer
$8434:  29 3F       AND #$3F       ; Mask bits 0-5
$8436:  85 38       STA $38        ; Store for later use

$843E:  A5 B8       LDA $B8        ; Load DataPointer again
$8440:  0A          ASL A          ; Bit 7 → CARRY
$8441:  A5 BA       LDA $BA        ; Load TopTiles index
$8443:  20 4C 84    JSR $844C      ; Call with carry = bit 7

$8446:  A5 B8       LDA $B8        ; Load DataPointer again
$8448:  0A          ASL A          ; Bit 7 → carry
$8449:  0A          ASL A          ; Bit 6 → CARRY
$844A:  A5 BB       LDA $BB        ; Load BottomTiles index
$844C:  ...                        ; Call with carry = bit 6
```

In Func_LoadTileSection at `$844C`:

```
$844C:  48          PHA            ; Save tile index
$844F:  84 EC       STY $EC        ; Clear $EC
$8451:  26 EC       ROL $EC        ; CARRY rotated into bit 0!
$8453:  0A          ASL A          ; Multiply index × 32
... (address calculation)
```

---

## Bank Selection Mechanism

The carry flag from the ASL operations determines which 8KB bank of tile sections to use:

| Carry | Effect |
|-------|--------|
| 0 | Use TileSection bank 0 (offset +0x0000) |
| 1 | Use TileSection bank 1 (offset +0x2000) |

The ROL instruction at `$8451` rotates the carry into the high byte of the address calculation, effectively adding 256 to the section index (256 × 32 bytes = 8KB).

---

## DataPointer Value Ranges

| DataPointer | Binary | Bit 7 | Bit 6 | TopTiles Bank | BottomTiles Bank |
|-------------|--------|-------|-------|---------------|------------------|
| `$00-$3F` | 00xx xxxx | 0 | 0 | Bank 0 | Bank 0 |
| `$40-$7F` | 01xx xxxx | 0 | 1 | Bank 0 | Bank 1 |
| `$80-$BF` | 10xx xxxx | 1 | 0 | Bank 1 | Bank 0 |
| `$C0-$FF` | 11xx xxxx | 1 | 1 | Bank 1 | Bank 1 |

### Common Values Observed

| Value | Top Bank | Bottom Bank | Typical Use |
|-------|----------|-------------|-------------|
| `$0F` | 0 | 0 | Dungeons? |
| `$40-$4F` | 0 | 1 | Standard overworld |
| `$8F-$9F` | 1 | 0 | Inverted areas |
| `$C0+` | 1 | 1 | Special areas |
| `$D1` | 1 | 1 | Chapter 1 starting screen |
| `$D3` | 1 | 1 | Town screens |

---

## Bits 0-5: CHR Bank Selection (DISCOVERED)

The lower 6 bits are masked with `$3F` and stored to zero page `$38`. This value controls **CHR bank selection** for sprites and background graphics.

### Disassembly Evidence

From fixed bank at `$E48E`:

```
$E48E:  A5 38       LDA $38        ; Load masked DataPointer (bits 0-5)
$E490:  0A          ASL A          ; Multiply by 2 (table index)
$E491:  A8          TAY            ; Transfer to Y
$E492:  B9 43 ED    LDA $ED43,Y    ; Load from CHR bank table
$E495:  20 6E E5    JSR $E56E      ; Write to MMC1 CHR register 0
$E498:  B9 44 ED    LDA $ED44,Y    ; Load second byte from table
$E49B:  20 82 E5    JSR $E582      ; Write to MMC1 CHR register 1
```

The subroutine at `$E56E` writes to `$BFFF` using the MMC1 serial protocol (5 writes with LSR between each).

### CHR Bank Lookup Table at $ED43

| Bits 0-5 Value | Index | CHR Bank 0 | CHR Bank 1 | Notes |
|----------------|-------|------------|------------|-------|
| `$00` | 0 | `$00` | `$40` | - |
| `$01` | 2 | `$C1` | `$80` | - |
| `$02` | 4 | `$C2` | `$43` | - |
| `$03` | 6 | `$42` | `$20` | - |
| `$04` | 8 | `$20` | `$20` | - |
| `$05` | 10 | `$11` | `$11` | - |
| `$06` | 12 | `$11` | `$0F` | - |
| `$07` | 14 | `$0F` | `$0F` | - |
| `$08` | 16 | `$00` | `$14` | - |
| `$09` | 18 | `$05` | `$14` | - |
| ... | ... | ... | ... | - |
| `$11` | 34 | `$07` | `$0E` | Chapter 1 ($D1) |
| `$13` | 38 | `$01` | `$06` | Town screens ($D3) |

### Why Sprite Corruption Occurs

**This fully explains the user's observations:**

1. **Changing DataPointer changes CHR banks** - Different bits 0-5 values select different CHR pattern banks via the table at $ED43
2. **Wrong CHR = Wrong graphics** - Sprites are drawn using CHR data; wrong bank = corrupted/wrong appearance
3. **Some values work** - DataPointer values with similar low bits (same bits 0-5) load compatible CHR banks
4. **ObjectSet itself is unchanged** - The ObjectSet value still references the same enemy type, but the **graphics** for that enemy come from a different CHR bank

### Sprite Compatibility Rule

**Two screens are sprite-compatible if their DataPointer bits 0-5 are identical.**

For example:
- `$D1` (bits 0-5 = `$11`) and `$91` (bits 0-5 = `$11`) → Same CHR banks → Compatible
- `$D1` (bits 0-5 = `$11`) and `$D3` (bits 0-5 = `$13`) → Different CHR banks → Incompatible

**Confidence**: HIGH (disassembly verified)

---

## ROM Layout

TileSection data is stored in ROM with two banks:

| Bank | ROM Address | File Offset | Section Count |
|------|-------------|-------------|---------------|
| Bank 0 | `$C4C7` | `$03C4C7` | ~256 |
| Bank 1 | `$E4C7` | `$03E4C7` | ~215 |
| **Total** | - | - | **471** |

Each TileSection is 32 bytes (8 tiles × 4 rows).

---

## Verification

### Chapter 1 Screen 0 (Starting Screen)
- **DataPointer**: `$D1` = 1101 0001
- **Bit 7**: 1 → TopTiles from Bank 1
- **Bit 6**: 1 → BottomTiles from Bank 1
- **TopTiles index**: `$0D` (13)
- **BottomTiles index**: `$11` (17)

Both tile sections come from the second bank (+8KB offset).

### Chapter 1 Town Screen
- **DataPointer**: `$D3` = 1101 0011
- Same bank selection pattern as overworld

---

## Randomizer Implications

1. **Cannot freely change DataPointer** - it affects tile bank AND CHR bank selection
2. **Screens with same visual tiles must use compatible DataPointers**
3. **Bits 7-6**: Control TileSection bank selection (background tiles)
4. **Bits 0-5**: Control CHR bank selection (sprite graphics)
5. **Safe modifications**: Swapping screens with identical DataPointer values
6. **Partial compatibility**: Screens can share TileSection banks but have different sprites (if bits 7-6 match but bits 0-5 differ)

### Screen Swap Compatibility Matrix

| Condition | Tile Graphics | Sprite Graphics | Safe to Swap? |
|-----------|---------------|-----------------|---------------|
| Full DataPointer match | Same | Same | YES |
| Bits 7-6 match, bits 0-5 differ | Same | Different | PARTIAL (tiles OK, sprites wrong) |
| Bits 7-6 differ, bits 0-5 match | Different | Same | PARTIAL (sprites OK, tiles wrong) |
| No bits match | Different | Different | NO |

---

## Related Documents

- [worldscreen.md](worldscreen.md) - WorldScreen structure
- [disassembly-notes.md](../systems/disassembly-notes.md) - Disassembly analysis
- [memory/ram-map.md](../memory/ram-map.md) - RAM addresses

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial analysis from disassembly |
| 2026-01-24 | MAJOR: Discovered bits 0-5 control CHR bank selection via table at $ED43 |
| 2026-01-24 | Added disassembly of $E48E (CHR bank switching code) |
| 2026-01-24 | Added sprite compatibility rules for randomizer |
