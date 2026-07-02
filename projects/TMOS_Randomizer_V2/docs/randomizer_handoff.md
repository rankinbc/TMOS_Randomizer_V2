# RETMOS -> TMOS_Randomizer_V2 Handoff

RE findings answering the randomizer-support questions (REVERSE.md "Randomizer Support" tasks, all closed).
Source of truth: RETMOS/REVERSE.md. Addresses are `bank $cpu-addr`; file offsets given where write-relevant.
Corrections to TMOS_AI/knowledge marked **CORRECTS**.

## 1. Screen-Transition Model (connectivity validator)

The current screen index lives in ZP `$AB`. **Exhaustive sweep: only 8 code sites in the entire ROM write it.**
A world-graph edge exists iff created by mechanisms 1-3; players are injected by 4-5; 6-8 never create links.

| # | Mechanism | Code | Destination source | Randomizer action |
|---|-----------|------|--------------------|-------------------|
| 1 | Edge walk | bank5 $AE4E | WorldScreen nav bytes 4-7 ($FF=wall, $FE=building door) | rewrite nav bytes (already supported) |
| 2 | Stairway / ledge jump | bank5 $AE0B | **Event byte bit6 set -> Content byte = destination screen index**. North Cape "jump" (Event $47) is the same mechanism -- bit6 | rewrite Content when re-indexing screens |
| 3 | Warp / time door | bank6 $8D65 | table `$98C0[$82*8 + door]`, bank6, **file 0x198D0**, 5 chapter-groups x 8 screen indices | patch table entries |
| 4 | Chapter start / respawn | bank4 $8133 | table `$8136[chapter]` = `63 09 01 26 20`, **file 0x10146** -- loaded at EVERY level-start setup ($E282) | patch if these screens move (breaks respawn otherwise) |
| 5 | Password-continue entry | bank1 $8E8A path | see 6; the same routine seeds gameplay after intro | patch |
| 6 | Chapter-intro display screens | bank1 $8E8A | table `$8E92`, **file 0x04EA2**: set A `40 4F 4B 38 68` then set B `1A 01 32 02 34` (toggle $049F); display-only during intro mode $19=8 | keep renderable; patch if moved |
| 7 | Return/restore | bank6 $8127, bank3 $9178 | saved screen `$94` (building exit, post-battle) | automatic, no data |
| 8 | Debug screen browser | bank6 $8B91 | d-pad (up/down +/-16, left/right +/-1) | ignore |

**Zero** immediate `LDA #imm; STA $AB` writes exist. No `$84 <-> $AB` coupling ($84 is chapter progression, independent).

### Present <-> Past
Pure data: destination = `$98C0` lookup. No computed pairing, no ParentWorld derivation.
**CAVEAT**: bank4 $8335 selects past-area music when ParentWorld hi4 >= $E0 -- keep ParentWorld consistent with time period even though it does not drive the pairing.

### Hardcoded screen indices (complete list)
- `$98C0` warp destinations (40B, file 0x198D0)
- `$8136` chapter start/respawn (5B, file 0x10146)
- `$8E92` intro screens (10B, file 0x04EA2)
- bank6 `$90D1`: `CMP #$1A` -- secret event needs screen $1A + player gridpos $68/$69 + magic level 6 (immediate at file 0x190E2)
- chapter-warp data `$BB1F` ($0084 progression values 4,9,14,19,24)

## 2. Content Byte = UI Command (relocation safety)

Building doors (nav byte $FE) reach bank5 $AD34 which passes **Content verbatim** to the bank1 UI engine:
hi3 = mode, lo5 = sub-index (`$04E1`). Handlers key on (chapter group `$82`, Content) -- never on screen index.

| Content | Meaning | Verdict |
|---------|---------|---------|
| $00 | empty | SAFE |
| $01-$1F | wizard battle on entry (param = lo5; uses ExitPosition) | SAFE |
| $20 | first mosque (mode-1 script) | SAFE |
| $21-$2A | boss screens -- mode-1 dialog scripts like the mosque; "phase 1/2" is data convention, **no engine mutation of Content exists** | NEEDS-CARE: keep phase pairs together + chapter progression |
| $40-$5F | universities | SAFE |
| $60-$67 | item shops: **shop id = Content & $1F** -> $94ED table | SAFE |
| $75-$79 | magic/formation shops (chapter-scaled prices) | SAFE |
| $7E/$7F | mosque / troopers | SAFE |
| $80-$9F | NPC scripts = $8B32[$82] + lo5 (chapter-keyed -- same value differs per chapter) | SAFE within chapter; preserve wiseman-before-event order |
| $A0-$BF | hotels/casino/special | SAFE |
| $C0-$DF | time doors (destination from $98C0, NOT from door screen) | NEEDS-PATCH ($98C0) |
| $E0-$FE | special/battle | SAFE |
| any + Event bit6 | stairway: Content = destination screen | rewrite on re-index |

## 3. ExitPosition (WorldScreen byte 9)

Consumer: bank4 $826B via $E086. Format: **hi nibble = X tile column (0-15), lo nibble = Y tile row (0-13)** on the 16px grid; engine adds +8px centering.
Read ONLY on: stairway arrival, entry to Content $01-$1F screens, warp arrival ($8D83), and gridpos-0 fallback. Edge walks never read it.
(**CORRECTS** old consumer list $986C/$A1A1/$A26B -- those were data false positives.)

## 4. Progress Flags $03E0-$03E4

- **Setters**: wiseman scripts via bank2 $BC35 (flag index = $BC56[$82] = `01 03 04 02 00`; special case $82=3 + $04E1=6 -> flag 3); chapter-warp init.
- **Gaters**: 5 VM script IFs ($03E1@$B878, $03E2@$BAF1, $03E3@$B95E/$BB04, $03E4@$BA5B) + world-event items 24-28 (require flag nonzero, then DECREMENT it, then run event: battle / full-restore / screen event / ceremony / magic effect).
- **No other engine readers.** Flags = chapter-story milestones keyed to script group, not screens. Screen shuffling is safe if wiseman screens stay reachable before their dependent event screens.

## 5. Shop Randomization (write spec)

| Structure | File offset | Size | Format |
|-----------|-------------|------|--------|
| Shop-pointer table | 0x054FD | 16B | 8 x u16 LE CPU addr (bank1 window $8000-$BFFF) |
| Shop data | 0x0550D | 64B | 8 shops x 4 slots x [code, price]; fixed 4 slots, no sentinel |
| Magic-shop base prices | 0x04ABC | 11B | binary; effective price = value x (chapter+1) |

- Repointing legal; bank1 free space: **$9731-$98FF (463B zero, file 0x05741)**, $9DD3-$9DFF (45B).
- **Code namespace** (**CORRECTS** any item-ID assumption): codes are bank1 state-command bytes. Legal hi4 only {1,3,5}; $Cx/$Dx are password opcodes writing arbitrary state -- never emit.
  - `$33`=BREAD($0306,cap10), `$34`=MASHROOB($0307,cap10), `$51`=R.SEED($0310,cap5), `$52`=CARPET($0311,cap15), `$53`=HORN(one-time,5 charges), `$58`=RING($030D,cap1)
  - `$10`/`$11` -> $0300/$0301 cap9. **OPEN CONFLICT**: knowledge docs call the $10 slot "Key", but door unlock decrements $0308 and HUD key = $0308. Verify in emulator before relying on shop-bought keys.
- **Prices**: 1 byte binary 0-255; gold is 3-digit BCD (0-999) -- keep price x quantity <= 999 for $33/$34; price 0 legal (free); haggle ($A33B) only perturbs a display digit. Magic-shop screens ($75-$79) IGNORE slot price. Shops 4-7 take a different display-price path ($86CF/$86B7 halving) -- verify in-game after moving slots across the 0-3 / 4-7 boundary.
- At-cap purchases abort safely (error $0E, gold not spent).

## 6. Misc verified facts

- Spell MP costs: table at bank6 $98E8 (records +5..+7 BCD); player MP = ZP $8C-$8E BCD. All guide costs confirmed; RESEALO=1, VELVER=2.
- Level-up reward byte ($97EC): bit6=SWORD, bit5=ROD, lo4=spell index -- display only; damage scales from level/equip.
- Formation pairs: bank3 $89C0, pairs (1,10)(4,6)(3,9)(10,11)(7,2)(5,8); 10=Faruk, 1=Coronya, 11=Hassan.
- $030A = MAP flag, gates map overlay (bank4 $8C1E).
- **CORRECTS**: file 0xD544 is the bank3 pickup max-cap table, not shop inventory; shops are flat bank1 tables (0x054FD/0x0550D); bank2 VM drives only dialog/cutscenes/password.

## Open items (emulator verification recommended)

1. `$10`/`$11` shop codes vs KEY counter ($0300 vs $0308).
2. $030F-$0313 charge-slot identities (labels ROD/FLAME/STARDUST vs guide-max alignment R.SEED/CARPET/HORN/RING).
3. Use-table records 9-16 name mapping (costs match BOLTTOR/FLAMOL family, names say SWORD tiers).
4. Shops 4-7 price display path ($86CF).
