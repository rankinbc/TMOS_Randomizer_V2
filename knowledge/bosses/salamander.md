# Salamander Boss (Chapter 4)

## Overview

| Property | Value |
|----------|-------|
| Chapter | 4 |
| HP | 255 ($FF) |
| Fight Detection | Chapter=3, ParentWorld=201, Room=140 |
| Key Ally | **Rainy** (required for optimal fight) |

---

## RAM Addresses

### Boss State Variables

| Address | Label | Description | Confidence |
|---------|-------|-------------|------------|
| `$0012` | Sal_X | X coordinate (bounded 72-184 pixels) | HIGH |
| `$0014` | Sal_Y | Y coordinate | HIGH |
| `$002B` | Sal_FlamolCountdown | Fire magic countdown | HIGH |
| `$002C` | Sal_FFCountdown | Fire field countdown | HIGH |
| `$002F` | Sal_RainCountdown | Rain countdown (Rainy's ability) | HIGH |
| `$0700` | Sal_MovementTimer | Frames until direction change | HIGH |
| `$0706` | Sal_DirectionIndex | Direction lookup index (0-31) | HIGH |
| `$0738` | Sal_DirChangeTimer | Direction change countdown | HIGH |
| `$0739` | Sal_HP | Boss hit points | HIGH |
| `$073A` | Sal_Iframe | Invincibility frames after hit | HIGH |
| `$073E` | Sal_DirChangeCount | Direction change count | HIGH |
| `$0742` | Sal_NextFlame | Next flame attack timer | HIGH |
| `$030A` | Sal_MovementEnable | If 0, movement is frozen | HIGH |

### Related Party Variables

| Address | Label | Description |
|---------|-------|-------------|
| `$033C` | InParty_Rainy | Rainy in party flag (bit 7 = rain active) |
| `$03CE` | Rainy_HP | Rainy's HP |
| `$03CF` | Rainy_MP | Rainy's MP (costs 10 per rain use) |

---

## ROM Addresses

### Boss Stats

| Stat | ROM Offset | CPU Address | Default | Confidence |
|------|------------|-------------|---------|------------|
| HP | `0x17462` | - | `$FF` (255) | HIGH |
| Projectile Speed | `0x17255` | - | `$03` | HIGH |
| Projectile Cooldown | `0x17257` | - | `$00` | HIGH |
| Fire Magic Damage | `0x1875D` | - | `$38` | HIGH |

### Code Labels (Bank 5/Bank 12)

| CPU Address | Label | Purpose |
|-------------|-------|---------|
| `$8A0A` | FireFieldAnimation | Main fire field animation routine |
| `$8A19` | FireFieldLoop | Animation loop (127 iterations) |
| `$8A55` | FireFieldStart | Fire field initialization |
| `$BA99` | SalamanderMovementLoop | Main movement routine |
| `$BAD4` | SalamanderHitLowerBound | Left boundary handler |
| `$BAD9` | SalamanderHitUpperBound | Right boundary handler |

### Code Labels (Bank 7/Fixed)

| CPU Address | Label | Purpose |
|-------------|-------|---------|
| `$E39B` | FireField_SalamanderDisappears | Fire field effect end |
| `$EAAC` | ResetSalamander | Initialize boss state to 0 |

---

## Movement Mechanics

### Movement Bounds
- **Left boundary:** `$48` (72 pixels)
- **Right boundary:** `$B8` (184 pixels)
- **Valid range:** 112 pixels wide

### Movement Pattern

The Salamander uses a lookup table at `$FF84` for movement deltas:

```
Index 0-7:   +1/-1 (slowest - best attack window)
Index 8-15:  +1/-2, +2/-1 (medium)
Index 16-23: +2/-2 (faster)
Index 24-31: +3/-3 (fastest - dodge phase)
```

### Movement Code Flow

```asm
; bank_12.asm @ $98CA-$98FF
L98CA:  lda     $0700,x         ; Load movement timer
        bne     L98E3           ; If not zero, skip direction change
        lda     $0706,x         ; Load direction index
        clc
        adc     #$01            ; Increment
        and     #$1F            ; Wrap at 32 (0-31)
        sta     $0706,x         ; Store new index
        lda     $E0             ; Timer seed
        and     #$1F            ; Mask
        ora     #$07            ; Minimum 7
        sta     $0700,x         ; New timer (7-31 frames)
L98E3:  dec     $0700,x         ; Decrement timer
        lda     $030A           ; Check movement enable
        beq     L98FE           ; If ZERO, skip movement!
        ldy     $0706,x         ; Load direction index
        lda     $FF84,y         ; Get delta from table
        clc
        adc     $12             ; Add to X position
        cmp     #$48            ; Left bound check
        bcc     L98FC           ; Store if valid
        cmp     #$B8            ; Right bound check
        bcc     L98FF           ; Out of bounds
L98FC:  sta     $12             ; Update position
L98FE:  rts
```

---

## Manipulation Strategies

### Movement Freeze
If `$030A = 0`, movement is completely skipped. This can occur during certain state transitions.

### Boundary Abuse
When Salamander hits X=184 boundary:
- Movement timer resets to 0
- Causes immediate direction reversal
- Useful for position locking

### Frame-Perfect Entry
Timer seed formula: `($E0 AND $1F) OR $07` = 7-31 frames
- Enter when `$E0` is low for faster direction cycling

### Attack Windows
- **Index 0-7:** Slowest movement = best time to attack
- **Index 24-31:** Fastest movement = dodge phase

---

## Rainy Strategy (Critical)

Having **Rainy** in the party is essential for fast kills:

1. **Damage Boost:** Attack value changes from `$35` to `$46` (~35% increase)
2. **Rain Neutralizes Fire Field:** Disables the fire field hazard
3. **MP Cost:** 10 MP per rain activation (`$03CF -= 10`)

### Rain Activation Code

```asm
; bank_12.asm @ $8300
lda     $033C           ; Check Rainy in party
beq     L8309           ; No Rainy -> weaker attack
lda     #$46            ; WITH RAINY -> stronger attack
bne     L830B
L8309:  lda     #$35            ; Without Rainy
```

---

## ROM Mod: Fast Fire Field

### Overview
Speeds up the fire field appearance and Rainy's rain neutralization animations.

### Modifications (6 bytes)

| ROM Offset | Original | Modified | Purpose |
|------------|----------|----------|---------|
| `0x18150` | `0x10` | `0x02` | Rain timer #1 (16->2 frames) |
| `0x18223` | `0x10` | `0x02` | Rain timer #2 (16->2 frames) |
| `0x182E5` | `0x10` | `0x02` | Rain timer #3 (16->2 frames) |
| `0x18418` | `0x10` | `0x02` | Rain timer #4 (16->2 frames) |
| `0x18A2E` | `0x70` | `0xE0` | Fire field loop end #1 |
| `0x18A46` | `0x70` | `0xE0` | Fire field loop end #2 |

### Time Savings

| Animation | Before | After | Saved |
|-----------|--------|-------|-------|
| Fire field appear/disappear | ~2.1 sec | ~0.25 sec | ~1.85 sec |
| Rain animation | ~1.1 sec | ~0.13 sec | ~0.97 sec |
| **TOTAL per cycle** | ~3.2 sec | ~0.38 sec | **~2.8 sec** |

### Technical Details

**Fire Field Animation Loop** (bank_12.asm @ $8A15-$8A37):
```asm
        lda     #$EF            ; Start value (239)
        sta     $14
L8A19:  dec     $14             ; Decrement
        lda     $14
        cmp     #$70            ; End at 112 (127 iterations)
        beq     L8A2C           ; Exit
        ...
        jsr     LF0B2           ; Frame delay
        ...
        cmp     #$70            ; Loop check
        bne     L8A19           ; Continue
```

Changing `#$70` to `#$E0` reduces iterations from 127 to 15.

**Rain Countdown Pattern** (`A9 10 85 21 85 2F`):
```asm
        lda     #$10            ; 16 frames delay
        sta     $21
        sta     $2F             ; Rain countdown
```

Changing `#$10` to `#$02` reduces each delay from 16 to 2 frames.

### Safety Notes
- Changes only affect Salamander boss fight
- No impact on other bosses or gameplay
- `L8A0A` routine only called during fire field sequence

---

## Quick Reference

### RAM Watch (Emulator)
```
$0012 - Salamander X position
$0706 - Direction index (0-7 = attack window)
$0700 - Movement timer
$0739 - HP (goal: reduce to 0)
$030A - Movement enable (0 = frozen)
$033C - Rainy status (bit 7 = rain active)
```

### Fast Kill Checklist
1. Have Rainy in party
2. Equip best Rod + Sword
3. Let rain neutralize Fire Field
4. Position at right edge (X ~ 180)
5. Attack during slow phases (index 0-7)
6. ~5-6 hits with Legend Sword = kill
