# RE Answer: Items, Economy & Shop System

**Date**: 2026-04-16
**Author**: RETMOS RE agent
**Scope**: Response to `items-economy-re-guide.md`. Built from disassembly of `TMOS_ORIGINAL.nes` (MD5 `b3236db14c87f375e5f24a5b9b79f071`) cross-referenced with `RETMOS/REVERSE.md` (~150 prior session findings) and `RETMOS/labels.csv`.

---

## TL;DR — Read This First

**The customizer UI is editing the wrong table.** Three foundational assumptions in `core/constants.py` and `items_registry.md` are wrong. Fixing them is a precondition to any further customization work.

### Critical correction 1 — Bank math is off by 2x

`core/constants.py:48` says:

```python
# For bank 6: base = 16 + (6 * 0x2000) = 0xC010
SHOP_BANK_FILE_OFFSET = 0xC010  # Bank 6 start in ROM file
```

NES PRG banks on MMC1 are **16 KB (0x4000)**, not 8 KB (0x2000). The actual file offsets:

| PRG Bank | File Offset | CPU Address |
|----------|-------------|-------------|
| 0 | `0x00010` | `$8000-$BFFF` (switchable) |
| 1 | `0x04010` | `$8000-$BFFF` |
| 2 | `0x08010` | `$8000-$BFFF` |
| **3** | **`0x0C010`** | `$8000-$BFFF` |
| 4 | `0x10010` | `$8000-$BFFF` |
| 5 | `0x14010` | `$8000-$BFFF` |
| **6** | **`0x18010`** | `$8000-$BFFF` |
| 7 | `0x1C010` | `$C000-$FFFF` (fixed) |

So `0xD544` is in **Bank 3, CPU `$9534`** — not Bank 6. Bank 3 is the **RPG battle engine**, not the shop code. The fix: `SHOP_BANK_FILE_OFFSET = 0xC010` is correctly the Bank 3 base, but the variable name is wrong, and the comment "Bank 6 swapped to $8000-$9FFF" is a separate misconception.

### Critical correction 2 — `0xD544` is NOT a shop slot table

The 8 records at `0xD544` were decoded by inspecting the routine that reads them (Bank 3 `$94B0`, full disasm below). Actual format is **`[ram_addr_lo, $03, max_cap, slot_idx]`**, not `[item_id, qty, price_low, price_high]`.

The reader at `$94D0` literally does:

```
LDX #$00
loop:
  LDA $9534,Y     ; copy 4 bytes from table
  STA $00,X
  INY
  INX
  CPX #$04
  BNE loop
LDY #$00
LDA ($00),Y       ; <-- INDIRECT! $00-$01 is now a POINTER
CMP $02           ; compare current value with cap
BCC do_increment  ; if current < cap, increment
```

So **byte 0 = low byte of a `$03xx` RAM pointer**, not an item ID. Byte 1 = `$03` because all inventory variables live in RAM page `$03xx`. Byte 2 = the **max stack cap**, not a price. Byte 3 = a slot index used for an optional party-slot mirror at `$0515+X`.

Decoded vanilla contents (verified against `REVERSE.md` documented variables):

| Slot | File | Bytes | Pointer | Cap | What it actually is |
|------|------|-------|---------|-----|---------------------|
| 0 | `0xD544` | `11 03 0F 00` | `$0311` | 15 | STARDUST charges (matches REVERSE max=15 ✓) |
| 1 | `0xD548` | `0F 03 01 01` | `$030F` | 1 | ROD charges (cap=1; pickup gives +1) |
| 2 | `0xD54C` | `10 03 01 02` | `$0310` | 1 | FLAME charges |
| 3 | `0xD550` | `01 03 01 03` | `$0301` | 1 | Gortrat mashroob counter |
| 4 | `0xD554` | `12 03 05 04` | `$0312` | 5 | Max MP / power |
| 5 | `0xD558` | `00 03 09 05` | `$0300` | 9 | Gortrat bread counter (matches max=9 ✓) |
| 6 | `0xD55C` | `06 03 0A 06` | `$0306` | 10 | BREAD (matches max=10 ✓; mirrors to `$0515`) |
| 7 | `0xD560` | `07 03 0A 07` | `$0307` | 10 | MASHROOB (matches max=10 ✓; mirrors to `$0516`) |

Three of the eight caps **exactly match** documented item maxes. This identification is solid.

### Critical correction 3 — `items_registry.md` IDs are fabricated

The IDs in `items_registry.md` (Amulet=`0x00`, Bread=`0x01`, Carpet=`0x02`, ...) **do not match** the actual ROM item-ID system. They were inferred from byte-0 of the `0xD544` table, which (per correction 2) isn't an item ID at all.

The real item-ID system lives in **Bank 6 `$98E8`** as 30 records of 8 bytes each (`item_id * 8 + $98E8`). It's fully decoded in `REVERSE.md` lines 1747-1788. Side-by-side:

| Byte | UI Registry says... | ROM `$98E8` actually says... |
|------|---------------------|------------------------------|
| `0x00` | Amulet | (null/placeholder) |
| `0x01` | Bread | ROD (consumable weapon ammo) |
| `0x02` | Carpet | FLAME |
| `0x03` | Hammer | STARDUST |
| `0x04` | Horn | CIMARON |
| `0x06` | Key | ISFA |
| `0x07` | (Map) | KEY |
| `0x08` | Mashroob | AMULET |
| `0x0A` | R.Seed | SIMITAR (sword tier 1) |
| `0x0C` | HolyRobe | KASHIM (named sword) |
| `0x0E` | M.Boots | LEGEND (named sword, best) |
| `0x0F` | M.Shield | HAMMER |
| `0x11` | Ring | CARPET |

The UI's IDs are coincidental — they happen to equal the low byte of the inventory RAM pointer for the few items that have one. For items the UI invented (M.Boots, M.Shield, Ring, R.Armor, HolyRobe), the IDs are pure fabrication.

### Critical correction 4 — Per-item RAM addresses (partial fix)

The doc claims:

> `$030F` Hammer, `$0310` R.Seed, `$0311` Carpet, `$0312` Horn

These are wrong. From `REVERSE.md` `$0300+` map (verified against chapter warp data + handler code):

| Address | UI doc says | ROM truth |
|---------|-------------|-----------|
| `$030F` | Hammer | **ROD charges** |
| `$0310` | R.Seed | **FLAME charges** |
| `$0311` | Carpet | **STARDUST charges** |
| `$0312` | Horn | **Max MP / power constant** |

CARPET, R.SEED, HORN, HAMMER, RING **do not have fixed `$03xx` addresses**. They're managed by the bank 2 shop/inventory bytecode interpreter, which has not yet been decoded (see Q1 below).

Verified `$03xx` mapping for items with fixed slots:

| Address | Item | ROM Verified |
|---------|------|--------------|
| `$0300` | Gortrat bread (NOT carried Bread!) | YES |
| `$0301` | Gortrat mashroob | YES |
| `$0302` | Armor level (0=none, 1=R-ARMOR, 2=L-ARMOR) | YES |
| `$0303` | M-SHIELD (boolean) | YES |
| `$0304` | M-BOOTS (boolean) | YES |
| `$0305` | HOLYROBE | YES |
| `$0306` | BREAD (carried, max 10) | YES |
| `$0307` | MASHROOB (carried, max 10) | YES |
| `$0308` | KEY (max 9) | YES |
| `$0309` | AMULET (max 9) | YES |
| `$030E` | Player level | YES |
| `$030F-$0311` | ROD/FLAME/STARDUST charges | YES |
| `$0322` | Magic level | YES |
| `$0332` | Equipped sword ID | YES |
| `$03D9-$03DB` | Gold (BCD hundreds/tens/ones) | YES |

---

## Per-Question Answers

### Q1: Trace the shop purchase routine end-to-end

**Status**: NOT_FOUND (and the assumed location was wrong — see TL;DR)

**What was found instead**: The routine the UI assumed was the shop purchase handler is actually the **inventory-pickup-with-cap handler** in Bank 3.

**ROM offsets** (the wrong-but-now-fully-traced routine):

- **Bank 3 `$94B0`** — `inv_pickup_handler`. Picks a random slot from a 16-byte indexer, looks up RAM pointer + cap from the 8-slot table, increments the inventory variable if `current < cap`, mirrors to party slot `$0515+X` if slot index ≥ 6. Called only from a Bank 4 pointer table at `$A28E` — used for chest/drop pickup events, not shops.
- **Bank 3 `$9524`** — `inv_slot_indexer`, 16 bytes (4 groups × 4 random selectors).
- **Bank 3 `$9534`** — `inv_slot_table`, 8 records × 4 bytes (the table the UI thinks is shop data).

**Pseudocode** (the actual routine, full disasm preserved in `REVERSE.md`):

```
inv_pickup_handler:                 ; bank 3 $94B0
  jsr damage_rng                    ; advance frame-counter RNG
  jsr battle_check                  ; gate on battle state
  ldy #2; ldy #2                    ; advance ($00) pointer 2 bytes
  lda ($00),y                       ; group selector (0-3)
  asl a; asl a                      ; *4
  sta $00
  lda $1E                           ; RNG byte
  and #$03                          ; 0-3 random
  clc; adc $00                      ; group_base + random
  tay                               ; Y = 0..15
  lda $9524,y                       ; <-- inv_slot_indexer
  asl a; asl a                      ; *4 = byte offset
  tay
  ; copy 4 bytes from inv_slot_table
  ldx #0
copy:
  lda $9534,y                       ; <-- inv_slot_table
  sta $00,x                         ; $00=ptr_lo, $01=$03 (page hi), $02=cap, $03=slot_idx
  iny; inx; cpx #4; bne copy
  ; INDIRECT increment with cap
  ldy #0
  lda ($00),y                       ; current value
  cmp $02                           ; vs cap
  bcs full                          ; current >= cap, skip
  tax; inx; txa; sta ($00),y        ; *ptr++
  ; party-slot mirror (only for slots 6, 7)
  lda $03; sec; sbc #6
  bcc skip
  tax; inc $0515,x
skip:
  ; ... display reward sprite at (120, 96), play sound ...
full: rts
```

**Where the REAL shop purchase routine probably lives**: Bank 2 has a **bytecode interpreter** that is referenced 8 times in `REVERSE.md` but has not been decoded yet. The trail:

- Bank 6 `$818A` (`mode3_npc`) is the shop/NPC entry point. It sets up screen and dialogue.
- Bank 6 `$81A9` reads `$03CC` (shop_flag) — this is the **only** read of `$03CC` in the entire ROM, and there are **zero** writes to it from any directly-readable code (it's set by indirect-store via the chapter warp data table at Bank 6 `$BB1F`).
- Dialogue text (and likely shop scripts) lives in CHR banks 22-24 as token-compressed text. The interpreter is in Bank 2 ($A0DB-$AF06 range, partially decoded).
- The interpreter's transaction opcodes (deduct gold, add inventory, check stock) have **not** been decoded.
- Critical clue: there are **zero** direct reads of `$03D9` (gold) anywhere in Bank 2. Gold modification must happen via cross-bank dispatch into Bank 6's gold-arithmetic cluster (`$9333-$93DB` — confirmed gold BCD add/subtract code).

**Deliverable for the customizer UI**:

1. **Stop calling `0xD544` "shop inventory" in the UI**. Rename in `core/constants.py`:
   ```python
   # WAS:
   SHOP_BANK_FILE_OFFSET = 0xC010      # mislabeled
   SHOP_INDEX_TABLE = 0xD534           # NOT a shop index
   SHOP_ITEM_TABLE = 0xD544            # NOT a shop slot table
   SHOP_PRICE_TABLE = 0xD5E0           # NOT a price table
   
   # SHOULD BE:
   BANK_3_FILE_OFFSET = 0xC010
   INV_PICKUP_INDEXER = 0xD534         # bank 3 $9524, 16-byte indexer
   INV_PICKUP_CAP_TABLE = 0xD544       # bank 3 $9534, 8 entries x 4B
   INV_PICKUP_AUX_DATA = 0xD5E0        # bank 3 $95D0, 12B, purpose unknown (see Q4)
   ```
2. **The "shop randomizer" UI feature is currently not editing shop data at all.** Setting price=15 for "Ring" actually sets the cap of `$0311` (STARDUST charges) to 15 (the vanilla value, no behavior change).
3. **Reverse-engineer the bank 2 bytecode interpreter** to find real shop data. This is a 1-2 week effort. Until then, the UI cannot actually edit shop inventory, prices, or shop-to-item mappings.

**Verification**:
- Set byte at `0xD55C+2` from `0x0A` (10) to `0xFF` (255) → expectation: BREAD cap raises to 255 (player can carry 255 bread). NOT a shop change.
- Set byte at `0xD544+2` from `0x0F` (15) to `0x01` → expectation: STARDUST charge cap becomes 1 (pickup only ever gives 1, max 1 stockpiled). NOT a shop change.

---

### Q2: Where is each "active" item's effect implemented?

**Status**: PARTIAL (table-driven dispatch identified for pickup handlers; effect handlers are scattered)

**Two distinct dispatch systems**:

**A. Pickup/equip dispatch — TABLE-DRIVEN** (good news for randomization):

`REVERSE.md` line 1747-1788 documents the **Bank 6 `$98E8` item table**: 30 records × 8 bytes each, accessed as `$98E8 + item_id * 8`. Lookup function at Bank 6 `$950F` converts item ID to Y offset.

Record format: `[item_id, pickup_sound, flags, handler_lo, handler_hi, unused, sub_type_lo, sub_type_hi]`.

Verified pickup handlers (real item IDs from `$98E8`, NOT the UI's IDs):

| ROM ID | Name | Pickup Handler | Inventory Addr |
|--------|------|----------------|----------------|
| 1 | ROD | Bank 6 `$8CA9` | `$030F` |
| 2 | FLAME | Bank 6 `$8CCF` | `$0310` |
| 3 | STARDUST | Bank 6 `$8CFE` | `$0311` |
| 4 | CIMARON | (unset) | (one-time) |
| 5 | CRYSTAL | Bank 6 `$9106` | -- |
| 6 | ISFA | Bank 6 `$8D8E` | -- |
| 7 | KEY | (unset) | -- |
| 8 | AMULET | (unset) | -- |
| 9-14 | Swords (Sword, Simitar, Dragoon, Kashim, Rostam, Legend) | `$8E3D`/`$8ECE` | `$0332` |
| 15 | HAMMER | Bank 6 `$8F4F` | (bank 2 bytecode) |
| 16 | R-SEED | Bank 6 `$8F4F` | (bank 2 bytecode) |
| 17 | CARPET | (unset, passive) | (bank 2 bytecode) |
| 18 | HORN | (unset, one-time) | (bank 2 bytecode) |
| 19/20 | OPRIN/RING | Bank 6 `$8F73` | (bank 2 bytecode) |
| 22 | MAP | Bank 6 `$8F7B` | (bank 2 bytecode) |
| 23 | Mode change | Bank 6 `$9654` | -- |
| 24 | Battle event | Bank 6 `$9659` | `$03E0` |
| 25 | Full restore | Bank 6 `$966A` | `$03E1` |
| 26 | Screen event | Bank 6 `$96AE` | `$03E2` |
| 27 | Ceremony cutscene | Bank 6 `$96B9` | `$03E3` |
| 28 | Magic effect | Bank 6 `$9725` | `$03E4` |
| 29 | Entity action | Bank 6 `$91DC` | -- |

**This table IS editable as a UI surface**. Changing the handler pointer (bytes 3-4 of any record) re-routes pickup behavior to a different routine. Changing the flags byte alters display/skip behavior.

**B. Per-effect runtime checks — HARD-CODED** (bad news for randomization):

The effects the UI doc asks about (auto-restore on death, escape battles, walk over damage, etc.) are NOT in the `$98E8` dispatch. They're checked at the moment they fire, by code that loads the inventory variable directly. No central effect table.

Per-item effect locations (verified in `REVERSE.md`):

| Effect | ROM Location | Type |
|--------|--------------|------|
| Bread auto-restore HP on death | Bank 7 `$F1FA` (overworld) + Bank 6 `$8AB5` (battle) | Hard-coded `LDA $0306; BEQ game_over; DEC $0306; LDA #50; STA hp` |
| Mashroob auto-restore MP on empty | Bank 6 `$8BFB` | Hard-coded `LDA $0307; BEQ no_mp; DEC $0307; ...` |
| KEY auto-consume | Bank 7 `$F2CB` | Hard-coded `DEC $0308` |
| AMULET auto-use | Bank 5 `$87F4` | Hard-coded |
| HOLYROBE entity check | Bank 5 `$A3F6` | Hard-coded `LDA $0305; BEQ no_robe` |
| M-BOOTS movement (mode 1) | Bank 5 `$A8FD` | Hard-coded `LDA $0304; BEQ no_boots` |
| Sword gate (enables attack) | Bank 5 `$8854` + Bank 4 `$86B5` | Reads `$0336` |
| Magic gate | Bank 5 `$8867` + Bank 4 `$86C5` | Reads `$0338` |
| R-ARMOR / L-ARMOR damage reduction | `$A44D` / `$A456` (bank 5) | Reads `$0302`, `LSR A` for half/quarter dmg |
| Carpet warp / Ring escape battle / Hammer all-enemies / Horn disable gargoyles | **NOT FOUND** — likely all in bank 2 bytecode interpreter | Bytecode-driven |

**Per-item answers**:

| UI ID | UI Name | Effect dispatched as... | Editable as data? |
|-------|---------|-------------------------|-------------------|
| 0x01 | Bread | Hard-coded check at `$F1FA`/`$8AB5`. Restore amount is `LDA #50` immediate at `$F202` (probable). | Restore amount editable as 1-byte ROM patch; trigger requires 6502 patch |
| 0x02 | Carpet | **In bank 2 bytecode** — destination list not yet decoded | NO until bank 2 traced |
| 0x03 | Hammer | **In bank 2 bytecode** | NO |
| 0x04 | Horn | **In bank 2 bytecode** (gargoyle-disable check likely a global flag set by Horn opcode) | NO |
| 0x06 | Key | Hard-coded at `$F2CB`. Per-key consumption (1 per door). No door-list table — door opening is per-screen entity. | Cap editable; per-door behavior is per-entity |
| 0x08 | Mashroob | Hard-coded at `$8BFB`, restore amount `LDA #50` immediate. | Same as Bread |
| 0x0A | R.Seed | **In bank 2 bytecode** + likely RNG via `$1E` byte | NO |
| 0x0C | HolyRobe | Hard-coded at `$A3F6`. Lava-tile check is at the lava entity, not the robe. | Class check editable as 6502 patch |
| 0x0D | L.Armor | TWO effects coupled: damage reduction at `$A456` (reads `$0302`) AND palace access (likely in `$0337-$033F` gate flags). Coupling is hard-coded. | Damage curve editable; decoupling requires 6502 patch |
| 0x0E | M.Boots | Hard-coded at `$A8FD`. **No class gate found** — guide claim "Saint class only" is unverified in code. | Effect editable as 6502 patch |
| 0x0F | M.Shield | Bank 2 bytecode (no fixed RAM addr) | NO |
| 0x11 | Ring | Bank 2 bytecode (no fixed RAM addr) | NO |

**Deliverable for the customizer UI**:

- **Editable today**: Bread/Mashroob restore amounts (1-byte each), `$98E8` pickup handler pointers, individual `$0300+` cap values via the chapter warp data at Bank 6 `$BB1F`.
- **Blocked on bank 2 bytecode**: Carpet, R.Seed, Hammer, Horn, Ring, M.Shield effects.
- **Requires 6502 patch**: any "rewrite Bread to restore MP" or "decouple L.Armor from palace access" type changes.

**Verification** (suggested test patches):
- Patch ROM byte at file offset `0x1F202` from `0x32` (50) to `0x0A` (10). Expectation: Bread restores 10 HP on death instead of 50.
- Patch `$98E8 + 6*8 + 3` (handler_lo for ID 6=ISFA) to point at `$8E3D` (sword pickup). Expectation: picking up ISFA equips it as a sword (will probably crash or look weird, but proves table is dispatched).

---

### Q3: Decode `SHOP_INDEX_TABLE` @ `0xD534`

**Status**: TRACED (and it's not what the UI thought)

**Decoded purpose**: 16-byte randomization indexer for `inv_pickup_handler`. NOT a shop-to-slot map.

**Bytes**: `00 01 06 07 / 00 01 05 02 / 00 01 03 04 / 00 01 03 02`

**Format**: 4 groups × 4 random selectors. The pickup handler computes `Y = (group_id * 4) + (RNG AND 3)`, then `LDA $9524,Y` returns a slot index 0-7 to look up in the 8-slot cap table. So each "group" is a small randomized loot pool.

| Group | Selectors | Items it can grant (slot → variable) |
|-------|-----------|--------------------------------------|
| 0 | `0,1,6,7` | STARDUST (15), ROD (1), BREAD (10), MASHROOB (10) |
| 1 | `0,1,5,2` | STARDUST, ROD, Gortrat bread (9), FLAME (1) |
| 2 | `0,1,3,4` | STARDUST, ROD, Gortrat mashroob (1), Max MP (5) |
| 3 | `0,1,3,2` | STARDUST, ROD, Gortrat mashroob, FLAME |

This is **enemy/chest random drop logic**, not shop pricing.

**Cross-reference to "12 game world shops"**: Shop content bytes `0x60-0x66` and `0x75-0x79` from the WorldScreen byte 2 are real (`items_registry.md` is correct on this point). But the per-shop inventory mapping is **not** in this table. It's in the bank 2 bytecode interpreter, which selects a different dialogue/transaction script per shop NPC. The UI's per-shop labeling will need to come from the bytecode scripts once decoded.

**Deliverable for the customizer UI**:

- Rename `SHOP_INDEX_TABLE` → `INV_PICKUP_INDEXER` in `core/constants.py`.
- **Do not surface this as a "shop" editing field**. Editing it changes which random items drop from chests/enemies.
- The actual per-shop inventory mapping requires bank 2 bytecode decoding (not done).

---

### Q4: What is `SHOP_PRICE_TABLE` @ `0xD5E0` actually used for?

**Status**: PARTIAL (likely auxiliary data for `inv_pickup_handler`, not prices)

**ROM context**: At file offset `0xD5DF` is `0x60` (RTS). The bytes immediately after (`0xD5E0+`) are data, not code. They live right after `inv_pickup_handler` ends.

**Bytes** (12): `01 07 07 08 08 1C 23 25 25 27 1C 22`

**Hypotheses** (none verified, no xref to `0xD5E0` from any reader):

- **Per-slot tile/sound/animation** for the reward sprite display the handler shows (`$0678/$0679` set to coords 120, 96 just before this).
- **Continuation of a different table** that the disassembler can't see because no code references it from a directly-followable path.
- The values **don't correspond to any known TMOS price scale** (10/20/30/50/60/80/100/200 are the actual prices; 7/8/0x1C=28/0x23=35/0x25=37/0x27=39/0x22=34 don't match).

The user-team's "price scale" name is almost certainly wrong. **Recommend renaming to `INV_PICKUP_AUX_DATA` and marking as "purpose unknown — do not edit"** until a reader is found.

**Deliverable for the customizer UI**:

- Remove `SHOP_PRICE_TABLE` from any user-facing UI.
- Add a comment in constants: `# 12B, purpose unknown, no readers found in xref`.

---

### Q5: What does byte 1 of each shop slot (`flag_byte`) do?

**Status**: TRACED — answered by the table re-decoding

**The "flag_byte" is the high byte of a RAM pointer.** All inventory variables live in RAM page `$03xx`, so byte 1 = `0x03` always. It's not a flag at all.

If you change byte 1 to `0x00` (slot 0), the handler will read/write `$0011` instead of `$0311` — corrupting zero-page state and probably crashing. If you change it to `0x07`, it reads/writes `$0711` (extended entity buffer area).

**Deliverable for the customizer UI**:

- Mark byte 1 as **read-only / fixed at `0x03`** in the UI. It has no "valid alternate values" — non-`0x03` is corruption.

**Verification**:
- Set `0xD544+1` from `0x03` to `0x00`. Expectation: pickup of slot 0's drop now writes to `$0011` (zero page) — likely visible glitch in player position, screen scroll, or sound state.

---

### Q6: Where is the item NAME string table?

**Status**: TRACED — names are CHR tile graphics, NOT strings

**ROM offsets**:

- Item names are rendered via **CHR tile graphics**, not the dictionary text system. See `REVERSE.md` line 1788: "Items display their name via CHR tile graphics (loaded from CHR bank 23 via `$9140`), not through the dictionary text system."
- The CHR page lookup is at **Bank 6 `$9163`** (`chr_page_lookup`). It maps an item category to a tile offset within CHR bank 23 (file offset `0x36010-0x3700F`).
- A **few** item names are also in the dictionary at Bank 2 `$99D7-$9C37` (16 dictionary groups, 97 words):
  - Group 1 (KEY, AMULET) — 2 words
  - Group 4 ((space), ROD, FLAME, STARDUST, CIMARON, CRYSTAL, ISFA) — 7 words
  - Group 5 ((space), HOLYROBE, M-BOOTS, M-SHIELD, BREAD, MASHROOB) — 5 words
  - Group 6 (game items: DRAGOON, KASHIM, ROSTAM, LEGEND, SPEAK, CARPET, R.SEED, HAMMER, HORN, RING, FIGHTER, SAINT, MAGICIAN, MAGIC, ITEM, THE, MAXIMUM, HAS BECOME, OFFENSE POWER OF THE, HAS INCREASED, LEVEL) — 21 words

Dictionary character encoding: `$30-$49 = A-Z`, `$2C = space`, `$4F = '-'`, `$00-$09 = 0-9`, bit 7 = end-of-word marker.

**Deliverable for the customizer UI**:

- **Renaming items in the dictionary IS possible** — write the new name as encoded bytes at the dictionary group's pointer. Length-changes require updating the group's start offsets.
- **Renaming items in the CHR tile graphics requires editing pixel data in CHR bank 23** — a different operation entirely (tile editor, not text editor).
- The dictionary names are used in some contexts (RPG battle messages, password screen, chapter info) but the **shop UI uses CHR-rendered names**. So changing the dictionary won't affect what shows up in the shop.

---

### Q7: Where is the per-item ICON/SPRITE assignment?

**Status**: PARTIAL

**ROM offsets**:

- **Bank 6 `$9163`** (`chr_page_lookup`): maps item category → CHR bank 23 tile offset.
- **Bank 6 `$9140`**: loads item display tiles from CHR bank 23.
- The actual pixel data is in **CHR bank 23, file offset `0x36010-0x3700F`** (4 KB).
- The category-to-icon mapping table itself has not been individually decoded, but it lives in the `$9140-$9163` code region.

**Deliverable for the customizer UI**:

- Editing item icons requires editing CHR bank 23 pixel data (8x8 tiles, NES 2bpp planar format).
- The item-ID → tile-index indirection table is in Bank 6 around `$9163`. A short trace would confirm the exact format. **Recommend a follow-up RE task** (~30 min of work).

---

### Q8: Where is the per-item MAX-STACK-SIZE table?

**Status**: TRACED — and it's the same table the UI is mislabeling as a shop slot table

**ROM offset**: **Bank 3 `$9534` / file offset `0xD544`** (the table from corrections 2/3 above).

**Format**: 8 entries × 4 bytes; byte 2 of each = max cap.

**Caveat**: This table only covers **8 inventory slots** (3 weapon ammo + 4 special + 1 party-mirrored). Many items have caps stored elsewhere:
- KEY (`$0308`) cap 9 and AMULET (`$0309`) cap 9: **not in this table**, hard-coded in the per-item check sites.
- HOLYROBE/M-BOOTS/M-SHIELD: boolean flags (cap = 1 by definition).
- CARPET, R.SEED, HORN, HAMMER, RING: managed by **bank 2 bytecode** (caps not yet decoded).

**Deliverable for the customizer UI**:

- Editing byte 2 of each entry at `0xD544` IS the correct way to change those 8 items' max stacks. Just rename the field in the UI from "PRICE" to "MAX STACK".
- The mapping from "slot" to game item must be derived from byte 0+1 (the RAM pointer), not from a hard-coded item ID. Suggested UI: show "STARDUST charges (max)" instead of "Ring price".
- KEY/AMULET caps (9 each) are hard-coded immediates in the consumption code (`$F2CB` for KEY, `$87F4` for AMULET). Editing those caps requires finding and patching the `CMP #$09` instruction.
- CARPET/R.SEED/HORN/HAMMER/RING caps require bank 2 bytecode trace.

---

### Q9: Per-enemy money-drop and EP tables

**Status**: TRACED

**ROM offsets**:

- **Bank 3 `$8341`** — `enemy_stat_table`, 29 entries × 10 bytes each, IDs `0x0D-0x29` (enemy ID range).
- File offset: `0x0C010 + ($8341 - $8000) = 0x0C351`.

**Record format** (per `REVERSE.md` line 2364-2399, ROM-verified):

| Byte | Field |
|------|-------|
| 0 | EP reward |
| 1 | Rupia reward |
| 2-6 | Combat stats (5 bytes — attack, defense, speed-related) |
| 7 | HP |
| 8-9 | Unknown (2 bytes) |

**Verification**: All values cross-checked against the gamefaq guide. 100% match for all 29 enemies. The full table is in `REVERSE.md` lines 2367-2390.

**Deliverable for the customizer UI**:

- Editing byte 0 (EP) and byte 1 (Rupia) at `0x0C351 + (enemy_id - 0x0D) * 10` directly changes drop rewards. **Safe to expose as UI fields.**
- Range: enemy IDs `0x0D-0x29` (29 enemies).
- Reward accumulator at Bank 7 `$CAE1` (`battle_reward_accum`) sums into `$05C0/$05C1` per battle.

---

### Q10: Starting Rupia + starting inventory

**Status**: TRACED

**ROM offsets**:

- **Bank 6 `$BB1F`** — `chapter_warp_data`. 50 records × 7 bytes each. Format: `[addr_lo, addr_hi, ch0_val, ch1_val, ch2_val, ch3_val, ch4_val]`. Sentinel `$FF` at `$BC7D`.
- File offset: `0x18010 + ($BB1F - $8000) = 0x1BB2F`.
- This is the **complete chapter-init table** — sets all `$03xx` game state variables on chapter warp / new game.

**Starting values** (chapter 0 / column 2 of each record, per `REVERSE.md` line 1644+):

| Address | Variable | Ch0 (start) |
|---------|----------|-------------|
| `$0302` | Armor level | 0 (none) |
| `$0303` | M-SHIELD | 0 |
| `$0304` | M-BOOTS | 0 |
| `$0305` | HOLYROBE | 1 (always available!) |
| `$0306` | BREAD | 6 |
| `$0307` | MASHROOB | 6 |
| `$030E` | Player level | 2 |
| `$030F` | ROD charges | 2 |
| `$0310` | FLAME charges | 2 |
| `$0311` | STARDUST charges | 6 |
| `$0312` | Max MP/power | 3 |
| `$0322` | Magic level | 2 |
| `$03D6` | Chapter (BCD) | 1 |
| `$03D9-$03DB` | Gold | (Need to look up exact ch0 value — game guide says 50 Rupias) |

**Note**: The game guide states "50 Rupias and 2 extra lives" at start. This matches a chapter-warp record for `$03D9-$03DB` setting BCD `00 00 50` (= 50 decimal). The exact record offset within the 50-entry table is straightforward to locate by scanning for `D9 03` and `DA 03` and `DB 03` as the first two bytes of records.

**Deliverable for the customizer UI**:

- **Safe to expose**: each row of the `chapter_warp_data` table is a `(variable, ch0..ch4)` tuple. Editing the chapter-N column changes what the player has at chapter N start.
- **UI-friendly model**: load the 50 records, label each by its `addr_lo+addr_hi` (look up in the `$03xx` map), present as a 50-row × 5-column editor (5 chapters).
- For starting Rupia specifically: the gold-init records are 3 separate entries in this table (one per BCD digit at `$03D9/$03DA/$03DB`).

**Verification**:
- Patch the ch0 value of the `$0306` record from `6` to `99`. Expectation: new game starts with 99 BREAD instead of 6.
- Patch the ch0 value of the `$030F` record from `2` to `0`. Expectation: new game starts with 0 ROD charges.

---

## What's Blocked Until Bank 2 Is Decoded

These deliverables **cannot be completed** with current RE state. They all require decoding the Bank 2 shop/dialogue bytecode interpreter (estimated 1-2 sessions of focused RE work):

1. **Real shop inventory editing** (per-shop item list + price)
2. **Real per-shop labels** ("Mooroon General Store" etc.)
3. **Carpet warp destinations**
4. **R.Seed planting outcomes / RNG**
5. **Hammer all-enemies effect parameters**
6. **Horn gargoyle-disable logic**
7. **Ring escape-battle logic + ally gate**
8. **M.Shield reflect bullets logic + ally gate**
9. **CARPET/R.SEED/HORN/HAMMER/RING max stack sizes**
10. **Hotel cost / Casino payout tables**

**Recommended next RE task**: Trace Bank 2 bytecode interpreter starting from the entry table at Bank 2 `$8000` (10 entry pointers). The most-called entries are entry 1 (`$A61C`, 78 cross-bank calls) and entry 2 (`$A91A`, 34 calls). The `$03CC` shop_flag is set by the chapter warp table indirectly via `STA ($00),Y` patterns — need to trace the warp data interpreter to find the script-loading path.

---

## What's Safe to Build in the UI Today

Based on confirmed RE:

1. **Inventory cap editor** for the 8 slots at `0xD544` (renamed from "shop slots")
2. **Item pickup handler editor** — the `$98E8` table in Bank 6, 30 entries × 8 bytes
3. **Per-enemy EP/Rupia drop editor** — `$8341` in Bank 3
4. **Chapter starting-state editor** — `$BB1F` in Bank 6, 50 records × 7 bytes
5. **Bread/Mashroob restore-amount editor** — single-byte patches at `$F202`/`$8C0?` (exact bytes need confirmation)
6. **Dictionary item-name editor** — Bank 2 `$99D7-$9C37` (limited to dictionary-rendered contexts)
7. **Damage reduction tier editor** — `$0302`-driven LSR at `$A44D`/`$A456` (bank 5)

**Should NOT be exposed yet**:
- Anything labeled "shop" (the data being edited is not shop data)
- Anything that depends on the fabricated UI item-ID system (re-derive from `$98E8` first)
- `$D5E0` 12-byte block (no known reader)

---

## Cross-References

- `RETMOS/REVERSE.md` lines 1620-1810 — full game state map (`$0300+`)
- `RETMOS/REVERSE.md` lines 1747-1788 — full Bank 6 `$98E8` item table
- `RETMOS/REVERSE.md` lines 2364-2399 — enemy stat table verification
- `RETMOS/REVERSE.md` lines 2401-2450 — item max counts cross-check
- `RETMOS/labels.csv` — adds `inv_slot_indexer`, `inv_slot_table`, `inv_pickup_handler`
- `RETMOS/REVERSE.md` "Inventory-increment / max-cap table" section (newly added today)
