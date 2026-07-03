# Shop System & Economy (Bank 1 Flat Tables)

**Last Updated**: 2026-07-02 (round 2: emulator-verified delivery paths)
**Sources**: RETMOS RE sessions (REVERSE.md "Shop Tables WRITE Spec" + "Emulator-Verified Shop Delivery"), byte-verified against TMOS_ORIGINAL.nes; delivery paths dynamically confirmed via RETMOS tools/emu.py unit-mode
**Confidence**: HIGH (offsets byte-checked; delivery emulator-verified)

---

## Supersedes

- The `0xD544` "shop slot table" claim: that offset is the Bank 3 inventory **cap** table (`$9534`), adjacent to 6502 code. Writing shop records there corrupts the ROM (see CHANGELOG "Disabled latent ROM-corruption path").
- The "shops live in an undecoded Bank 2 bytecode interpreter" theory (`docs/human/items-economy-re-answers.md`): the Bank 2 VM is real but only drives story/cutscene/dialogue/password scripts. Shops are flat data tables in Bank 1.

---

## Table Locations (byte-verified)

| Structure | CPU addr (bank 1) | File offset | Size | Format |
|-----------|-------------------|-------------|------|--------|
| Shop-pointer table | $94ED | 0x054FD | 16B | 8 x u16 LE (CPU addr in $8000-$BFFF) |
| Shop data | $94FD | 0x0550D | 64B | 8 shops x 4 slots x [code, price] |
| Magic-shop base prices | $8AAC | 0x04ABC | 11B | binary, indexed by code lo4, scaled x (chapter+1) |
| Bank 1 free space | $9731-$98FF | 0x05741-0x0590F | 463B | zero-filled (verified) |

- Shop id = WorldScreen `Content & $1F` (Content $60-$67 = item shops 0-7), indexed into the pointer table via `$04E1`.
- Slot count is FIXED at 4 per shop. No terminator/sentinel; exactly 8 bytes per shop.
- Pointer entries are plain CPU addresses read through a ZP pointer — repointing into bank 1 free space is legal (verify chosen range with RETMOS `tools/analyze_freespace.py`).

## Vanilla shop data (2026-07-02 dump)

```
shop 0: 33 34 10 53    shop 4: 33 34 52 58
shop 1: 33 34 52 51    shop 5: 33 34 52 51
shop 2: 33 34 52 51    shop 6: 33 34 52 51
shop 3: 52 10 53 11    shop 7: 52 10 53 11
```
(codes only; each code byte is followed by its price byte in ROM)

---

## Slot Code Namespace

Slot `code` bytes are **bank 1 state-command bytes** (the `$8746` processor space — the same command scheme the password decoder uses). They are NOT `$98E8` battle-table IDs and NOT menu item IDs.

**Legality: hi-nibble must be $1, $3, or $5.** Other hi4 values ($Cx/$Dx etc.) are password opcodes that write arbitrary game state — never emit them into shop slots.

| Code | Type path | RAM target | Cap | Item | Emu-verified |
|------|-----------|------------|-----|------|--------------|
| $33 | $3x -> $0303+3 | $0306 | 10 | BREAD (quantity-purchasable) | YES (qty=2 -> +2) |
| $34 | $3x -> $0303+4 | $0307 | 10 | MASHROOB (quantity-purchasable) | — (same path as $33) |
| $10 | $1x -> $0300+0 | $0300 | 9 | **GORTRAT BREAD** (NOT keys) | YES (+1; at cap 9 aborts) |
| $11 | $1x -> $0300+1 | $0301 | 9 | Gortrat-paired consumable | — |
| **$18** | $1x -> $0300+8 | **$0308** | — | **+1 PENDING GOLD — never sell** (see correction below) | YES (+1 to $0308) |
| $51 | $5x lo4=1 | $0310 | 5 | R.SEED (charge refill) | — |
| $52 | $5x lo4=2 | $0311 | 15 | CARPET (charge refill) | YES (write at $87D0) |
| $53 | $5x one-time | $0312 | init 5 | HORN (reject if owned; init from $87F2) | YES (fresh=5, owned=rejected) |
| $58 | $5x lo4=8 | $030D | 1 | RING | YES (=1) |

**CORRECTED (2026-07-03, RETMOS round 3 — supersedes the round-2 "$18 = KEY" reading)**: **the KEY item does not exist.** `$0308` is the action-mode **pending-gold accumulator**: coin/moneybag drops credit it (+1/+20 at bank5 `$8BCA`), and the `$F2C6` payout tick drains it into the gold BCD at `$89-$8B` (1 unit per 2 frames, coin sound). Round 2 verified the right BYTE behavior ($18 increments `$0308`) but inherited the wrong LABEL from the old RAM map. Consequences:
- Shop code **$18 sells "+1 gold"** for the slot price — which is exactly why no vanilla shop uses it. **A randomizer must never emit $18** (the sell_keys feature built on the KEY reading was removed).
- The former `$F2CB` "door unlock consume" is the payout tick's DEC, unrelated to doors. Door blockers are type-6 ObjectSet entities opened by script/Oprin paths.
- `$0300` = Gortrat bread stands (round 1/2, unchanged).
See RETMOS/REVERSE.md "Vanilla Key Source Hunt ($0308)".

- Ownership/rebuy check: `$03C0 + (code & $0F) * 2` (11 logical entries, stride 2); one-time items reject if nonzero.
- At-cap purchase aborts with error $0E and gold is NOT spent.

---

## Pricing Rules

- Price byte: 1 byte binary 0-255. Price 0 is legal (free item).
- Gold is 3-digit BCD 0-999. **Constraint: price x max-quantity <= 999** for quantity-purchasable codes ($33/$34, quantity from numeric input `$049B`). Flat slots safe at any 0-255.
- **Magic/formation shops (Content $75-$79) IGNORE the slot price byte.** Price = `$8AAC[code & $0F] x (chapter + 1)` via 16-bit multiply `$8B89`. Vanilla base table: 20,30,40,20,40,30,20,40,30,40,50. To randomize magic-shop prices, write `$8AAC` (file 0x04ABC), not the slot bytes.
- Haggle mini-game (`$A33B`) only perturbs a display digit; it does not change the charged total. No overflow hazard from haggle.
- **Shops 4-7 take a different price post-processing path** (`$86A6: CPY #$04; BCS $86CF`, includes halving at `$86B7`). If randomization moves slot layouts across the shop 0-3 / 4-7 boundary, verify displayed prices in-game once.

---

## Purchase Delivery (bank 1 $8746 state-command processor)

| Type | Target | Cap | On buy |
|------|--------|-----|--------|
| $1x | $0300 + lo4 | 9 | INC (or +qty when X=6/7) |
| $3x | $0303 + lo4 | 10 | INC / +qty |
| $5x lo4=8 | $030D | 1 | INC |
| $5x lo4=2 | $0311 | 15 | INC (charge refill) |
| $5x lo4=1 | $0310 | 5 | INC (charge refill) |
| $5x other | $030F + lo4 | one-time | reject if owned; else initial charges from $87F2 = [1,1,1,5,5,0,0,0] |

Pipeline: `$8680` (slot read) -> `$A5A0` (price x qty) -> `$A33B` (haggle) -> `$8A71` (magic-shop scaling) -> `$A736` (gold spend) -> `$8746` (delivery).

Item NAMES are not code-indexed anywhere: menu/shop names are pre-rendered CHR-tile layout strings (bank 1 `$B4BA` pointer table), drawn positionally. Changing a slot's code does NOT change the displayed name on the shop screen layout — shop screen text is part of the shop's text-entry layout, keyed to (chapter, Content).

---

## Randomizer implications

1. Shop randomization is write-ready: shuffle/reprice the 64 bytes at 0x0550D within the legality rules above.
2. Safe code pool without emulator verify: {$33, $34, $51, $52, $53, $58}. Add {$10, $11} after the conflict is resolved.
3. Magic-shop price randomization = write 11 bytes at 0x04ABC (keep base x 6 <= 999 for chapter 5, i.e. base <= 166; vanilla max 50).
4. Expanded shops (>4 slots impossible — fixed count) but different per-shop data is possible by repointing $94ED entries into the 463B free block.
