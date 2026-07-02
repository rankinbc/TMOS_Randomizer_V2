# Screen Relocation Constraints (Randomizer Support)

**Last Updated**: 2026-07-02
**Sources**: RETMOS RE sessions — full 128KB PRG sweep for hardcoded screen references (`tools/analyze_screen_imm.py`), content-handler tracing, warp table decode. Warp table byte-verified against TMOS_ORIGINAL.nes 2026-07-02
**Confidence**: HIGH

Answers: "which screens can the randomizer move, and what must it patch when it does?"

---

## Key Architectural Fact

The WorldScreen `Content` byte is passed VERBATIM as the bank 1 UI command (building entry at bank 5 `$AD34`: `LDA $B2; JSR bank1_dispatch`). Building handlers are keyed to **(chapter group $82, Content)** — never to screen index. This is why most content is freely movable within its chapter.

## Content Relocation Safety Table

| Content | Meaning | Verdict | Coupling |
|---------|---------|---------|----------|
| $00 | empty | SAFE | none |
| $01-$1F | wizard battle on enter | SAFE | param = Content & $1F; uses ExitPosition |
| $21-$2A | boss (demon) screens | NEEDS-PATCH | phase pairs ($21/$22 etc.) must stay together; CHR boss setup $95E8; chapter progression values |
| $40-$5F | universities | SAFE | chapter-keyed only |
| $60-$67 | item shops 0-7 | SAFE | shop id = Content & $1F -> $94ED table (screen-independent) |
| $75-$79 | magic/formation shops | SAFE | prices chapter-scaled, screen-independent |
| $7E/$7F | mosque/troopers | SAFE | chapter-keyed |
| $80-$9F | NPC scripts | SAFE within chapter | script = $8B32[$82] + lo5; scripts set progress flags — preserve reachability ORDER (wiseman before dependent event screens) |
| $A0-$BF | hotels/casino/special | SAFE | none found |
| $C0-$DF | time doors | NEEDS-PATCH | destination lives in $98C0 table, NOT derived from the door screen; patch table when moving destination screens |
| $E0-$FE | special/battle | SAFE | none found |
| any + Event bit6 | stairway | REWRITE | Content = destination screen index — must be rewritten when re-indexing screens (randomizer phase 5 already does this) |

---

## Hardcoded Screen References — Complete List (5 sites in 128KB)

Sweep result: zero `LDA #imm ; STA $AB` sites exist; all normal transitions are WorldScreen-data-driven. Only these are hardcoded (full transition model: RETMOS/docs/randomizer_handoff.md — 8 mechanisms write `$AB`, only edge walk / stairway / warp create graph edges):

### 1. Warp / Time-Door Destination Table — bank 6 $98C0, file 0x198D0

40 bytes: 5 chapter-groups x 8 door sub-indices -> destination screen index. Destination lookup: `$98C0[$82 * 8 + door]` -> `$AB`. Player lands at the destination screen's own ExitPosition.

Vanilla contents (byte-verified):

| $82 | Destinations |
|-----|--------------|
| 0 | 00 17 20 7E 3D 42 00 00 |
| 1 | 09 34 26 00 4E 00 00 00 |
| 2 | 01 2B 2D 00 35 33 00 00 |
| 3 | 26 28 08 00 38 60 00 00 |
| 4 | 20 1C 06 00 00 00 00 00 |

**Randomizer obligation**: when moving/re-indexing any screen listed here, patch the corresponding byte(s) at 0x198D0+group*8+slot.

Present<->past pairing is PURE DATA in this table — no computed mapping, no ParentWorld derivation. CAVEAT: bank 4 `$8335` selects past-area music when ParentWorld hi4 >= $E0, so keep ParentWorld consistent with the screen's time period.

### 2. Secret Event — bank 6 $90D1, immediate at file 0x190E2

`CMP #$1A`: secret event requires screen $1A + player grid position $68/$69 + magic level 6 (grants INC $88). **Pin screen $1A** or patch the immediate byte.

### 3. Chapter Start Positions — warp data $BB1F record 0

Chapter start screens = 4, 9, 14, 19, 24 (one per chapter), plus password-decode equivalents. **Pin these screens**: the password system encodes them, so moving chapter starts breaks password restore.

### 4. Chapter Start/Respawn Table — bank 4 $8136, file 0x10146

5 bytes = `63 09 01 26 20` (screen index per chapter), loaded at EVERY level-start setup ($E282). **Patch if these screens move, or respawn breaks.**

### 5. Chapter-Intro Display Screens — bank 1 $8E92, file 0x04EA2

10 bytes = two 5-screen sets (`40 4F 4B 38 68` / `1A 01 32 02 34`, toggled by $049F). Display-only during intro mode ($19=8): keep renderable; patch if moved.

---

## Progress Flags $03E0-$03E4 (progression validator input)

- Setters: bank 2 `$BC35` (wiseman script CALL): flag index = `$BC56[$82]` = [1,3,4,2,0] by script group (special case $82=3, $04E1=6 -> flag 3). Also chapter warp init ($BB1F).
- Gaters: 5 VM script IFs + world-event item handlers 24-28 (require flag nonzero, then DEC it).
- No other engine readers.

Flags are per-chapter story milestones keyed to script group, NOT screen index. **Validator rule: each chapter's wiseman-script screen must remain reachable before its dependent event screens.** Otherwise shuffle-safe.

---

## ExitPosition Semantics (WorldScreen byte 9)

- hi4 = X column, lo4 = Y row (16px grid, +8 centering). Consumer: bank 4 `$826B` via `$E086` sled.
- Read ONLY for: stairway arrivals (Event bit6), Content $01-$1F entry, warp arrivals, grid-position-0 fallback. Normal edge walks never read it.
- Randomizer obligation: any screen that can be arrived at via stairway/warp needs its ExitPosition on a walkable tile; screens only reachable by edge walks don't care.
