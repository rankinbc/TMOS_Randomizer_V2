# RE Request: Items, Effects & Shop Economy

**Date**: 2026-04-16
**Requester**: TMOS Randomizer V2 UI team
**ROM**: `TMOS_ORIGINAL.nes`, MD5 `b3236db14c87f375e5f24a5b9b79f071`
**Goal**: Decode item-effect dispatch + shop layout deeply enough that the customizer UI can offer **per-item effect remapping**, **per-shop pricing**, **stack-size editing**, and **icon/name customization** — not just byte editing.

---

## Why this matters

The customizer UI now exposes editable shop slots, EXP tiers, player damage curves, and encounter lineups. But several "items" interactions are still hard-coded item-ID checks, which means we can edit byte values but not behavior. To unlock real customization (e.g., "make Bread restore MP instead of HP", or "let Ring escape battles for non-Kebabu parties") we need to know where the dispatch lives.

We also recently discovered the documented shop-table layout in `core/constants.py` was wrong — it claimed `[item_id, qty, price_low, price_high]` but the actual format is `[item_id, flag_byte, price_byte, slot_index_counter]`, and there are only **8 valid slots** in vanilla, not the assumed 48. The SHOP_INDEX_TABLE that maps shops → slot ranges is undecoded.

---

## What's already known (don't redo)

- **`SHOP_ITEM_TABLE`** = `0x0D544` — confirmed, 8 valid 4-byte slots
- **`SHOP_INDEX_TABLE`** = `0x0D534` — 16 bytes, content `00 01 06 07 / 00 01 05 02 / 00 01 03 04 / 00 01 03 02` — purpose unconfirmed, suspected per-shop slot range mapping
- **`SHOP_PRICE_TABLE`** = `0x0D5E0` — 12 bytes — name suggests price scaling but never read by current code
- **`Bank 6`** is swapped to CPU `$8000-$9FFF` during shop routines (per `core/constants.py:46`)
- **Item registry** — full name/ID/category map at `analysis_games/TMOS/game_specs/systems/economy/items_registry.md` (in GameAnalysis2)
- **Per-item RAM inventory addresses** (partial, all `[ROM_VERIFIED]`):
  - `$0300` Key, `$0306` Bread, `$0307` Mashroob, `$030F` Hammer, `$0310` R.Seed, `$0311` Carpet, `$0312` Horn
- **Player damage system** fully traced — see `raw_research/player_damage_table.md` in GameAnalysis2 for the template of what "fully traced" looks like (LF657, LF670, LF6BA addresses + RAM mirrors)

---

## Priority 1 — Single highest-leverage trace

### Q1. Trace the shop purchase routine end-to-end

**Why**: Answers Q2, Q3, Q4 simultaneously and gives us ground truth for shop UI.

**Approach**:
1. Find the routine that fires when the player presses A on a shop menu item. Likely entry point is somewhere in Bank 6 (CPU `$8000-$9FFF`) since `SHOP_BANK_FILE_OFFSET = 0xC010` is documented.
2. Trace the load of the slot bytes — what addressing mode is used to find the right slot? (This tells us how `SHOP_INDEX_TABLE` is interpreted.)
3. Note every byte read from `$D534`, `$D544+`, `$D5E0`.
4. Trace the Rupia decrement: how many bytes? Is `SHOP_PRICE_TABLE` involved?
5. Trace the inventory increment: which RAM address gets bumped, and is there a max-stack check before the increment?

**Deliverables**:
- Pseudocode of the purchase routine
- ROM offset of the entry point (label name + address)
- For each table accessed: confirmation of the field meanings
- Note: is byte 1 (`flag_byte = 0x03` in vanilla) actually read? If yes, what controls?

---

## Priority 2 — Item effect dispatch

### Q2. Where is each "active" item's effect implemented?

**Items in scope** (effect column from `items_registry.md`):

| ID | Name | Effect | What we want to know |
|---|---|---|---|
| `0x01` | Bread | Auto-restore HP on death | Restore amount editable? Triggered by death event check or item presence check? |
| `0x02` | Carpet | Warp to towns / escape dungeon | Destination list address? Per-chapter? |
| `0x03` | Hammer | Stars hit all enemies | Effect duration? Target selection logic? |
| `0x04` | Horn | Disable gargoyles | Per-screen check or global flag? |
| `0x06` | Key | Open palace doors | Door-list table? Per-key consumption? |
| `0x08` | Mashroob | Auto-restore MP when empty | Same shape as Bread? |
| `0x0A` | R.Seed | Plant for money/invisibility | RNG seed for outcome? |
| `0x0C` | Holy Robe | Survive lava at north cape | Per-tile check (only the "north cape" lava)? |
| `0x0D` | L.Armor | Strongest armor + palace access | Two effects in one item — separate or coupled? |
| `0x0E` | M.Boots | Walk over damage (Saint class only) | Where is the class gate? |
| `0x0F` | M.Shield | Reflect bullets (with Kebabu) | Where is the ally gate? |
| `0x11` | Ring | Escape battles (with Kebabu) | Same — ally gate location |

**Approach**:
For each item, find the code that checks "does player have item X?" or "did player just use item X?". The check is almost certainly one of these patterns:
```
LDA $0306        ; Load Bread count
BEQ no_bread
... effect ...
```
or
```
CMP #$01         ; Item ID for Bread
BNE not_bread
JSR bread_handler
```

If table-driven (e.g., `JMP (item_handler_table,X)`), find the table and document its format — that's the dream because we can re-map effects to items without 6502 patching.

**Deliverables**:
- Per item: ROM offset of the dispatch check + handler routine
- Tag each item as **"data-table dispatched"** (high reward) vs. **"hard-coded ID check"** (low reward)
- For data-table items: dump the table structure

---

## Priority 3 — Shop infrastructure

### Q3. Decode `SHOP_INDEX_TABLE` @ `$0xD534`

**Bytes**: `00 01 06 07 00 01 05 02 00 01 03 04 00 01 03 02`

**Hypotheses to test**:
- 4 shops × 4 bytes each, format `[type, ?, slot_first, slot_last]`?
- 8 shops × 2 bytes each, format `[slot_first, slot_count]`?
- A shop_id → slot_index mapping consumed by the purchase routine traced in Q1?

**Cross-reference**: there are 12 game world shops based on Content bytes (`0x60-0x66` general, `0x75-0x79` magic). If the index table only has room for 4-8 shops, then multiple game-world shops must share inventories — which ones?

**Deliverables**:
- The decoded structure
- A `shop_id → slot_range` mapping (e.g., "shop 0 = slots 0-1, shop 1 = slots 2-3, ...")
- A `Content_byte → shop_id` mapping (so the UI can label cards "Mooroon General Store" etc.)

### Q4. What is `SHOP_PRICE_TABLE` @ `$0xD5E0` actually used for?

Vanilla bytes (12): `01 07 07 08 08 1C 23 25 25 27 1C 22 AD CD 05 0A`

Suspected to be a per-shop price multiplier. Values like `0x1C` (28) and `0x27` (39) don't look like multipliers though. Could be:
- discount tiers?
- per-shop NPC dialog ID?
- stocking refresh rate?

**Approach**: trace any read of `$D5E0..$D5EB` from inside the shop routine identified in Q1. If untouched there, search Bank 6 broadly.

**Deliverables**:
- Confirmation of purpose
- If price multiplier: the formula (e.g., `final_price = byte_2_of_slot × scale_byte`)
- If something else: rename in our `core/constants.py` so we stop misleading future readers

### Q5. What does byte 1 of each shop slot (`flag_byte`) do?

Vanilla constant: `0x03` for all 8 slots. Test patches in an emulator:
- Set to `0x00` for slot 0 → does that slot disappear? become unsellable? change icon?
- Set to `0xFF` → crash? "out of stock" display?
- Set to `0x07` → any difference in shop dialog?

**Deliverables**:
- Confirmation that `0x03` is meaningful (vs. just an unused field)
- If meaningful: list of valid values + their effects

---

## Priority 4 — Item display + metadata

### Q6. Where is the item NAME string table?

These names ("Bread", "M.Boots", "Holy Robe") render in shop menus + inventory. NES games typically store text as a packed-character table or null-terminated strings.

**Approach**: search the ROM for ASCII or NES-charset bytes spelling "BREAD" or "RING".

**Deliverables**:
- ROM offset of the name table
- Format: fixed-width? null-terminated? char-set encoding?
- One-string-per-item-ID layout? Or some other indexing?

### Q7. Where is the per-item ICON/SPRITE assignment?

Each item has an icon shown in the inventory grid + shop menu. Likely a tile index per item ID.

**Deliverables**:
- Address of the item-ID → tile-index table (or whatever the indirection is)
- Where the actual pixel data lives (CHR bank, almost certainly)

### Q8. Where is the per-item MAX-STACK-SIZE table?

`items_registry.md` documents Bread max=10, Carpet max=15, Key max=9, etc. These caps are enforced somewhere.

**Approach**: from the inventory increment found in Q1, look for a comparison against a per-item value before the increment.

**Deliverables**:
- ROM offset of the cap table
- One byte per item, presumably

---

## Priority 5 — Drops + economy

### Q9. Per-enemy money-drop and EP tables

`turn_based_enemys.json` has Rupia + EP values from guides but no ROM offsets. Find the tables.

**Approach**: similar pattern to the EXP tier table we already mapped (`$174AA`). Check for similar small lookup tables near enemy combat code.

**Deliverables**:
- ROM offset of the per-enemy Rupia drop table
- ROM offset of the per-enemy EP table
- Confirmation that the existing JSON values match (they came from disassembly indirectly)

### Q10. Starting Rupia + starting inventory

Where is the new-game initial state set? Specifically:
- Starting Rupia count
- Whether the player starts with any consumables (probably 0 of each, but verify)

**Approach**: find the new-game setup routine (likely RAM zeroing / initialization at start). Look for writes to `$030E` (RodLevel = 1), `$0322` (SwordLevel = 1), and the Rupia counter.

**Deliverables**:
- ROM offset of new-game init
- Starting Rupia value
- Starting weapon/equipment/inventory state

---

## Format requested for answers

Each answer should be a section in a markdown response with:

```markdown
### Q[N]: [short title]

**Status**: TRACED | PARTIAL | NOT_FOUND

**ROM offsets**:
- `$XXXXX` — short label — purpose

**Pseudocode** (if applicable):
```
... 6502 disassembly or pseudocode ...
```

**Deliverable for the customizer UI**:
- Concrete byte address(es) we can read/write
- Constraints (valid value ranges, side effects, etc.)
- Whether this is **safe to expose as a UI field** or **needs more research before exposure**

**Verification**:
- Test patch description (what byte change you tried)
- Observed effect in emulator
```

A complete answer to even **just Q1 (purchase routine trace)** unblocks 4 follow-up UI features. We don't need everything at once.

---

## How to know we're done

The minimum viable answer set:
- ✅ Q1 (purchase routine) — unblocks proper shop UI
- ✅ Q2 for at least 4 items (M.Boots, Ring, Carpet, Bread) — unblocks "effect editor" prototype
- ✅ Q3 (shop index table) — unblocks per-shop labeling

The dream:
- All 10 questions answered
- Customizer can ship a "fully redesign the economy" mode
