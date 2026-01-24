# Disassembly Analysis Notes

**Last Updated**: 2026-01-24
**ROM**: MMC1 (Mapper 1), 128KB PRG-ROM
**Method**: Cross-referencing FCEUX labels with raw hex disassembly
**Confidence**: HIGH (direct code verification)

---

## ROM Configuration

From iNES header analysis:
```
Mapper: MMC1 (1)
PRG-ROM: 8 × 16KB = 128KB
CHR-ROM: 16 × 8KB = 128KB
```

### Bank Mapping Formula
```
file_offset = 0x10 + (bank × 0x4000) + (cpu_addr - 0x8000)

Examples:
- Bank 5, $AE67: 0x10 + 0x14000 + 0x2E67 = 0x16E77
- Bank 4, $841B: 0x10 + 0x10000 + 0x041B = 0x1042B
- Fixed bank, $E891: 0x10 + 0x1C000 + 0x2891 = 0x1E8A1
```

---

## Random Encounter System ($AE67)

### Disassembly
```
$AE67:  A9 00       LDA #$00       ; Initialize
$AE69:  A4 72       LDY $72        ; Load game state
$AE6B:  C0 06       CPY #$06       ; Is Ramipas active?
$AE6D:  F0 08       BEQ $AE77      ; If yes, skip encounter calc
$AE6F:  18          CLC
$AE70:  AD F4 03    LDA $03F4      ; Load RE_RandEnc1
$AE73:  6D F5 03    ADC $03F5      ; Add RE_RandEnc2
$AE76:  4A          LSR A          ; Divide by 2
$AE77:  A8          TAY            ; Result to Y index
$AE78:  AD F0 03    LDA $03F0      ; Load RE_BattleExits
$AE7B:  EE F0 03    INC $03F0      ; Increment counter
$AE7E:  29 07       AND #$07       ; Mask to 0-7 (bit position)
$AE80:  AA          TAX
$AE81:  B9 9A AE    LDA $AE9A,Y    ; Lookup probability table
$AE84:  2A          ROL A          ; Rotate to get bit
$AE85:  CA          DEX
$AE86:  10 FC       BPL $AE84      ; Loop X times
$AE88:  90 0C       BCC $AE96      ; No carry = NO ENCOUNTER
$AE8A:  20 91 E8    JSR $E891      ; CALL StartBattle!
```

### Findings
| RAM Address | Label | Verified Usage |
|-------------|-------|----------------|
| `$0072` | (new) | Ramipas state: if == 6, skip encounters |
| `$03F0` | RE_BattleExits | Counter, incremented each check, masked to 0-7 |
| `$03F4` | RE_RandEnc1 | Added to $03F5 |
| `$03F5` | RE_RandEnc2 | Added to $03F4, sum divided by 2 |
| `$AE9A` | (ROM table) | Probability lookup table |

### Algorithm Summary
1. Check if Ramipas active ($72 == 6) → skip if true
2. Combine random values: `($03F4 + $03F5) / 2`
3. Use result as index into probability table at $AE9A
4. Use battle exit counter (masked 0-7) as bit rotation count
5. If carry flag set after rotation → trigger battle

---

## WorldScreen Loader ($841B)

### Disassembly
```
$841B:  A9 00       LDA #$00
$841D:  8D A0 03    STA $03A0      ; Clear state
$8420:  8D A1 03    STA $03A1
...
$8432:  A5 B8       LDA $B8        ; Read DataPointer (WS byte 8)
$8434:  29 3F       AND #$3F       ; Mask for bank selection
...
$8441:  A5 BA       LDA $BA        ; Read TopTiles (WS byte 10)
$8443:  20 4C 84    JSR $844C      ; Call Func_LoadTileSection
...
$844A:  A5 BB       LDA $BB        ; Read BottomTiles (WS byte 11)
```

### Findings
| RAM Address | WS Byte | Verified Usage |
|-------------|---------|----------------|
| `$B8` | 8 (DataPointer) | Masked with $3F for bank selection |
| `$BA` | 10 (TopTiles) | Index passed to tile loader |
| `$BB` | 11 (BottomTiles) | Index passed to tile loader |

### Confirms
- WorldScreen bytes 8, 10, 11 are used exactly as documented
- DataPointer affects tile bank through the $3F mask

---

## Salamander Movement ($BA99)

### Disassembly (partial)
```
$BAC6:  B9 84 FF    LDA $FF84,Y    ; Movement delta lookup table
$BAC9:  18          CLC
$BACA:  65 12       ADC $12        ; Add to Salamander X position
$BACC:  C9 48       CMP #$48       ; Left boundary ($48 = 72)
$BACE:  90 04       BCC +4         ; Branch if X < $48
$BAD0:  C9 B8       CMP #$B8       ; Right boundary ($B8 = 184)
$BAD2:  90 05       BCC +5         ; Branch if X < $B8
$BAD4:  85 12       STA $12        ; Update Salamander X
$BAD6:  4C DE BA    JMP $BADE      ; Continue to bound handler
```

### Findings
| RAM Address | Label | Verified Usage |
|-------------|-------|----------------|
| `$12` | Sal_X | Salamander X coordinate, bounds 72-184 |
| `$FF84` | (ROM table) | Movement delta lookup table |

### Movement Bounds (NEW)
| Bound | Value | Pixels |
|-------|-------|--------|
| Left | `$48` | 72 |
| Right | `$B8` | 184 |

---

## New Discoveries

### RAM Address $0072 - Ramipas Active Flag
- **Value 6** = Ramipas spell active (no random encounters)
- Previously unlabeled in our RAM map
- **Action**: Add to ram-map.md

### Encounter Probability Table at $AE9A
- ROM address in Bank 5
- File offset: 0x16EAA
- Used to determine encounter chance based on area/progression

### Salamander Horizontal Bounds
- Movement constrained to X range 72-184 (112 pixel range)
- Controlled by lookup table at $FF84

---

## CHR Bank Selection ($E48E)

### Disassembly
```
$E48E:  A5 38       LDA $38        ; Load masked DataPointer (bits 0-5)
$E490:  0A          ASL A          ; Multiply by 2 (table index)
$E491:  A8          TAY            ; Transfer to Y
$E492:  B9 43 ED    LDA $ED43,Y    ; Load from CHR bank table
$E495:  20 6E E5    JSR $E56E      ; Write to MMC1 CHR register 0
$E498:  B9 44 ED    LDA $ED44,Y    ; Load second byte from table
$E49B:  20 82 E5    JSR $E582      ; Write to MMC1 CHR register 1
```

### MMC1 Write Subroutine ($E56E)
```
$E56E:  8D FF BF    STA $BFFF      ; Write bit 0
$E571:  4A          LSR A          ; Shift right
$E572:  8D FF BF    STA $BFFF      ; Write bit 1
$E575:  4A          LSR A
$E576:  8D FF BF    STA $BFFF      ; Write bit 2
$E579:  4A          LSR A
$E57A:  8D FF BF    STA $BFFF      ; Write bit 3
$E57D:  4A          LSR A
$E57E:  8D FF BF    STA $BFFF      ; Write bit 4
$E581:  60          RTS
```

### Findings
| Address | Purpose | Confidence |
|---------|---------|------------|
| `$38` | Masked DataPointer bits 0-5, used as CHR bank index | HIGH |
| `$ED43` | CHR bank lookup table (pairs of bytes) | HIGH |
| `$E56E` | MMC1 CHR register 0 write (serial protocol) | HIGH |
| `$E582` | MMC1 CHR register 1 write (serial protocol) | HIGH |

### Key Insight
**DataPointer bits 0-5 control which CHR banks are active for sprites.**
- Different values load different sprite graphics
- This explains why changing DataPointer corrupts sprite appearance
- Screens with matching bits 0-5 share compatible sprites

---

## Verification Summary

| RAM Address | Our Label | Code Usage | Status |
|-------------|-----------|------------|--------|
| `$03F0` | RE_BattleExits | Counter, masked 0-7 | CONFIRMED |
| `$03F4` | RE_RandEnc1 | Added to $03F5 | CONFIRMED |
| `$03F5` | RE_RandEnc2 | Added to $03F4 | CONFIRMED |
| `$12` | Sal_X | Salamander X position | CONFIRMED |
| `$B8` | WS_DataPointer | Masked with $3F | CONFIRMED |
| `$BA` | WS_TopTiles | Tile section index | CONFIRMED |
| `$BB` | WS_BottomTiles | Tile section index | CONFIRMED |
| `$38` | DataPointer_Masked | CHR bank table index | CONFIRMED |

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - RAM addresses
- [memory/rom-map.md](../memory/rom-map.md) - ROM addresses and code labels
- [structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial disassembly analysis |
| 2026-01-24 | Added CHR bank selection disassembly at $E48E |
| 2026-01-24 | Documented MMC1 serial write protocol at $E56E |
