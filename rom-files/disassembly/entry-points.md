# The Magic of Scheherazade - Entry Points Analysis

**Confidence Level: HIGH** (directly verified from ROM vectors)

## Interrupt Vectors

Located at the end of PRG-ROM (Bank 15, $FFFA-$FFFF):

| Vector | Address | ROM Offset | Handler |
|--------|---------|------------|---------|
| NMI | $FFFA | 0x2000A | $E3C9 |
| RESET | $FFFC | 0x2000C | $E19B |
| IRQ/BRK | $FFFE | 0x2000E | $E19B |

## RESET Handler ($E19B)

The RESET handler performs standard NES initialization:

```asm
RESET_Handler:
        sei                     ; Disable interrupts
        cld                     ; Clear decimal mode
        lda     #$00
        sta     PPU_CTRL        ; Disable NMI
        sta     PPU_MASK        ; Disable rendering
        ldx     #$03
LE1A7:  lda     PPU_STATUS      ; Wait for VBlank (3 times)
        bpl     LE1A7
LE1AC:  lda     PPU_STATUS
        bmi     LE1AC
        dex
        bpl     LE1A7
        txs                     ; Set stack pointer
        stx     JOY2_FRAME      ; APU frame counter
        lda     #$00
        sta     APU_STATUS      ; Silence APU
        sta     APU_STATUS
        ldx     #$00
        txa
LE1C3:  sta     $00,x           ; Clear zero page
        sta     $0100,x         ; Clear stack
        sta     $0300,x         ; Clear RAM
        sta     $0400,x
        sta     $0500,x
        inx
        bne     LE1C3
        ; ... continues with game initialization
```

### Initialization Sequence
1. Disable interrupts (SEI)
2. Clear decimal mode (CLD)
3. Disable PPU rendering and NMI
4. Wait for PPU warmup (3 VBlank cycles)
5. Initialize stack pointer
6. Silence APU
7. Clear RAM ($00-$05FF)
8. Continue to game-specific setup

## NMI Handler ($E3C9)

The NMI (Non-Maskable Interrupt) fires every VBlank (~60 times/second).
This is typically where the main game loop processes input and updates state.

Location: Bank 15, file offset 0x1E3C9

## IRQ Handler ($E19B)

The IRQ handler points to the same address as RESET ($E19B).
This is common for games that don't use IRQ - on unexpected IRQ, the system
effectively resets.

## Game Title String

Located at $FFE0 (end of ROM):
```
SCHEHERAZADE USA
```

This confirms the ROM is the US version of the game.

## Key Subroutines to Investigate

Based on the RESET handler analysis, these areas warrant further investigation:

1. **Main game loop** - Called after initialization, likely jumps to different game states
2. **Bank switching code** - Look for writes to $8000-$FFFF (MMC1 registers)
3. **Text rendering** - For dialog system analysis
4. **Input handling** - Controller reading, typically in NMI

## MMC1 Bank Switching

MMC1 uses serial writes to registers. Look for patterns like:
```asm
        sta     $8000   ; Write bit to shift register
        lsr     a
        sta     $8000
        lsr     a
        sta     $8000
        lsr     a
        sta     $8000
        lsr     a
        sta     $8000   ; 5th write triggers register update
```

## Notes

- IRQ sharing RESET address suggests the game doesn't use mapper-generated IRQs
- The extensive RAM clearing at startup is typical for NES games
- Bank 15 ($E000-$FFFF) is always mapped and contains core system code
