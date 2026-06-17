# AI_item-gating-logic-spec — TMOS Item-Gating Logic Spec (merged)

**Date:** 2026-06-17
**Purpose:** ONE reviewable spec that merges the two gating research reports into the input
contract for a STATIC item-gated reachability validator (Wave 2). Structured so it can be
turned into a data file (per-chapter regions/gates/acquirables) + a BFS validator.

**Merged from:**
- **R1** = `reports/2026-06-17_tmos-gates-local-disasm.md` — ROM/RAM ENCODING (HIGH on byte
  schema + RAM have-item map; from the authoritative GameAnalysis2 disassembly).
- **R2** = `reports/2026-06-17_tmos-gates-web-progression.md` — human PROGRESSION logic per
  chapter (what gates what, critical path, traversal abilities, win conditions).

**Merge rules applied:**
- R1 WINS on encoding/representation (byte values, RAM addresses, spatial-vs-logical).
- R2 supplies the progression LOGIC that R1 explicitly says is NOT ROM-encoded and must be
  hand-modeled.
- Conflicts / silences are preserved and carried to OPEN_QUESTIONS, tagged by source + confidence.

**Confidence tags (preserved from sources):** HIGH = ROM_VERIFIED / disassembly-confirmed (R1)
or 2+ independent walkthrough sources (R2); MEDIUM = single-source / inference / GUIDE_SOURCED;
LOW = uncorroborated single-source / weak inference. Each item carries its origin source string.

---

## 0. Framing — the two distinctions the validator is built on

### 0.1 Physical reachability vs. item-gated reachability
- **Physical reachability** = can you walk/transition there at all, ignoring items? This is a
  pure graph over WorldScreen exit/event edges (and building interiors as opaque sub-graphs).
- **Item-gated reachability** = of the physically-connected nodes, which are actually traversable
  given the items/allies/spells/class/flags you can hold by the time you arrive.
- The validator's reachability rule is therefore **BFS over physical edges AND satisfied
  requirements** (see MODELING NOTES). A randomized map is valid only if every win-condition
  requirement set is item-gated-reachable from the chapter start.

### 0.2 Spatial-AUTO gates vs. logical-HAND-MODELED gates (R1's crucial split)
- **SPATIAL gates are auto-derivable from WorldScreen bytes** and should be parsed straight out
  of the ROM by the validator — no authoring:
  - Time Door — Content byte `0xC0` [R1 HIGH]
  - Stairway — Event byte `0x40`, Content = destination screen index [R1 HIGH]
  - Building entrance — any Exit byte == `0xFE` [R1 HIGH]
  - OPRIN-door / hidden door — Event byte `0x20` or `0x22` [R1 HIGH]
  - Hazard terrain (lava etc.) — hazard tile IDs in the rendered TileSection [R1 HIGH]
  - Boss-stage screens — Content `0x21`–`0x2A`; approach Event `0x09`/`0x48` [R1 HIGH]
- **LOGICAL item gates are NOT individually encoded on any screen byte** and MUST be hand-authored
  as logic rules keyed to the chapter critical path (R1 HIGH that no per-screen "requires item N"
  field exists; the specific requirements are R2 progression logic):
  - Faruk → water/underwater (Ch1)
  - Supica → maze-desert (Ch2)
  - Holy Robe → lava (Ch4)
  - Ch5 Legend Sword + Armor of Light → Sabaron's Palace door; Isfa Rod → final boss
  - plus boss-prerequisite allies (Epin/Mustafa/Rainy), class gates, payment gates, Horn/gargoyle
    gates, in-palace puzzle gates.
- **R1's hard warning:** the repo documented gate ENCODING + the have-item RAM map but never
  disassembled the gate-CHECK routines for the four named logical gates. So the *requirements*
  on logical gates come from R2 (human walkthroughs), not from traced 6502 code. Treat logical
  gate requirements as authored model input, validated by playtesting — not as ROM-extracted fact.

---

## 1. Top-level: traversal_abilities

Merged. `rom_representation` / flag addresses are R1 (encoding wins). `effect` / acquire location
/ critical-path role are R2 where R1 is silent. Where the two name the same ability differently,
both names are kept.

```yaml
traversal_abilities:
  - id: oprin_spell
    aka: [OPRIN]
    effect: "Reveal hidden staircases/doors (Event 0x20/0x22 screens) AND activate Time Doors. Coronya flags the nearby hidden-staircase screen (in-game hint, not a gate)."
    scarce: false                       # always held from level 1 — NOT a gating item
    rom_representation: "spell-known flag $0322 (SpellFlagOPRIN); learned L1; MP cost 5."
    confidence: HIGH(flag) / MEDIUM(which screens require it)
    source: "R1 traversal_abilities oprin_spell; R2 GLOBAL OPRIN section + gating_mechanisms oprin_hidden_staircase"

  - id: faruk_swim
    aka: [faruk_underwater]
    item_or_ally: Faruk (ally)
    effect: "Underwater breathing / safe water entry -> reach present-era sunken Horen + Aqua Palace approach from North Cape (Ch1)."
    unlocks_terrain: water
    rom_representation: "Faruk recruit flag $033E (nonzero=recruited). Underwater-passability routine UNTRACED. Spatial anchors: North Cape jump screens Event 0x07/0x47."
    confidence: HIGH(flag) / MEDIUM(effect GUIDE_SOURCED, routine untraced)
    source: "R1 faruk_underwater; R2 faruk_swim"

  - id: magic_boots
    item_or_ally: Magic Boots (item)
    effect: "Prerequisite to RECRUIT Supica (from Lah in past Alart, answer NO). Indirect chain to maze-desert."
    rom_representation: "NOT documented in R1 [UNKNOWN]."
    confidence: MEDIUM (R2 single-source FO)
    source: "R2 magic_boots (R1 silent)"

  - id: supica_desert_guide
    item_or_ally: Supica (ally)
    effect: "Guides party through the repeating maze-desert west of Malart (present) blocking westward travel to Sudari / Dark Palace."
    unlocks_terrain: "maze-desert (navigational gate)"
    rom_representation: "Supica party flag NOT documented [UNKNOWN]. Recruited via Content 0x82 (Ch2). NO per-screen require-Supica byte; desert HP-drain is tile/screen hazard, mechanism UNKNOWN."
    confidence: MEDIUM(behavior) / encoding UNKNOWN
    source: "R1 supica_desert_guide; R2 supica_desert_guide"

  - id: raincom_desert
    item_or_ally: RAINCOM (spell)
    effect: "Temporarily normalizes desert -> prevents HP loss while crossing. Convenience/mitigation, NOT a hard wall."
    rom_representation: "Great-Magic / event region $03E0-$03E4 (see CONFLICT in RAM table)."
    confidence: MEDIUM
    source: "R2 raincom_desert; R1 raincom_greatmagic"

  - id: holy_robe_lava
    item_or_ally: Holy Robe (item; provided by ally Gubibi, also buyable)
    effect: "Negate lava damage -> cross Lava Cape to reach Lava town (Rainy) + (R1) Yufla Palace items (Ch4)."
    unlocks_terrain: lava
    rom_representation: "HOLYROBE boolean $0305; Gubibi recruit flag $0339. Lava = hazard tiles {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC}. $0305-negates-lava routine UNTRACED."
    confidence: HIGH(item+hazard encoding) / MEDIUM(bypass effect GUIDE_SOURCED)
    source: "R1 holy_robe_lava; R2 holy_robe_lava"

  - id: armor_tiers
    item_or_ally: R-ARMOR / Armor-of-Light (item)
    effect: "Damage reduction (½ / ¼). NOT a documented hard-gate bypass. NOTE: Ch5 'Armor of Light' is ALSO a story key-item door gate (see Ch5 gates) — distinct from this damage-tier role."
    rom_representation: "$0302: 0=none,1=R-ARMOR(½),2=L-ARMOR/Armor-of-Light(¼). Applied in damage sub $A43E."
    confidence: HIGH
    source: "R1 armor_tiers"

  - id: pukin_cimaron_rod_light
    item_or_ally: Pukin (ally) + Cimaron Rod (requires Saint class)
    effect: "Light the dark mazes of Ch3 (Maze of Darkness)."
    rom_representation: "Pukin party flag NOT documented [UNKNOWN]; Cimaron Rod = rod level $030E==4. Light mechanic UNTRACED."
    confidence: MEDIUM (GUIDE_SOURCED)
    source: "R1 pukin_cimaron_rod_light; R2 cimaron_rod/pukin"
```

---

## 2. Top-level: gating_mechanisms_catalog (tagged spatial vs logical)

Merged union of R1's encoding-keyed catalog and R2's behavior catalog. Each entry tagged
`kind: spatial` (auto-derivable from bytes) or `logical` (must be hand-modeled). R1 wins on
`rom_representation`; R2 supplies behaviors R1 didn't enumerate.

```yaml
gating_mechanisms_catalog:

  # ---- SPATIAL (auto-derive from WorldScreen bytes) ----
  - id: time_door
    kind: spatial
    rom_representation: "Content byte (offset 2) == 0xC0. All 10 doors use 0xC0 in ROM scan (0xC7/0xD7 documented variants NOT present). Era is NOT byte-encoded — by PAST_SCREEN_INDICES membership."
    detect: "screen.content == 0xC0"
    behavior: "Bidirectional era swap (PRESENT<->PAST, Ch3 PRESENT<->FUTURE). No scarce item gates use; needs OPRIN (always held) + Coronya hint."
    confidence: HIGH(encoding) / MEDIUM(activation requirement)
    source: "R1 time_door + named_gates OPRIN_to_TimeDoor; R2 time_door"

  - id: stairway
    kind: spatial
    rom_representation: "Event byte (offset 15) == 0x40; Content byte holds destination screen index (chapter-relative)."
    detect: "screen.event == 0x40 -> edge to screen[content]"
    behavior: "Non-adjacent bidirectional link. Ch2 & Ch5 have ORPHAN stairways (dest doesn't point back) — treat as possibly one-way."
    confidence: HIGH
    source: "R1 stairway"

  - id: building_entrance
    kind: spatial
    rom_representation: "Exit byte (4=R,5=L,6=D,7=U) == 0xFE. 0x00-0xFD = dest screen index; 0xFF = blocked; 0xFE = building entrance (separate interior sub-graph)."
    detect: "any exit byte == 0xFE -> opaque interior sub-graph"
    behavior: "Interior layout NOT byte-mapped — interiors are opaque to a WorldScreen-only static parse."
    confidence: HIGH
    source: "R1 building_entrance"

  - id: oprin_door
    kind: spatial + logical(spell, but spell always held)
    rom_representation: "Event byte == 0x20 (NPC_DIALOG / Oprin door, no msg) or 0x22 (OPRIN_DOOR, reveals hidden door w/ Coronya msg). 0x22 in SAFE_EVENTS (relocatable); 0x20 DANGEROUS (story NPC)."
    detect: "screen.event in {0x20, 0x22}"
    behavior: "Reveals hidden staircases/passages/buildings. Since OPRIN is always available, an OPRIN-revealed node is reachable iff its screen is reached — treat the reveal as a free edge, NOT a scarce gate."
    confidence: HIGH(encoding) / MEDIUM(which screens are gated vs cosmetic)
    source: "R1 oprin_door; R2 oprin_hidden_staircase"

  - id: hazard_terrain
    kind: spatial(tile-collision)
    rom_representation: "Hazard tile IDs {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC}; tiles resolved from TopTiles(10)/BottomTiles(11) TileSection indices."
    detect: "screen renders a hazard tile on a required-cross path (e.g. lava)"
    behavior: "Lava negated by Holy Robe ($0305) [GUIDE]. Armor tiers reduce generic damage but do NOT documented-ly bypass lava. THE TILE IS SPATIAL/AUTO; the bypass requirement (Holy Robe) is LOGICAL/HAND-MODELED."
    confidence: HIGH(hazard tiles+collision) / MEDIUM(Holy-Robe bypass GUIDE_SOURCED)
    source: "R1 hazard_terrain"

  - id: boss_stage_content
    kind: spatial
    rom_representation: "Content 0x21-0x2A = boss phases (2 per boss, Gilga..GoraGora). Event 0x09 PRE_BOSS / 0x48 BOSS_PREP mark approach (DANGEROUS_EVENTS)."
    detect: "screen.content in 0x21..0x2A ; screen.event in {0x09,0x48}"
    behavior: "Boss must die to clear chapter + reveal next-chapter password (R2 boss_defeat_gate)."
    confidence: HIGH
    source: "R1 boss_stage_content; R2 boss_defeat_gate"

  # ---- LOGICAL (hand-model — no per-screen byte) ----
  - id: event_script_progress_flag
    kind: logical
    rom_representation: "Bank-2 script VM IF-opcodes branch on $0300-region flags (observed $033E, $03E0-$03E4). Base table $ACF8 index1=$0300. NO per-screen 'requires item' field."
    detect: "NOT statically detectable from WorldScreen bytes — model the flag dependency by hand."
    confidence: HIGH(mechanism) / per-screen mapping UNTRACED
    source: "R1 event_script_progress_flag"

  - id: terrain_traversal_item
    kind: logical
    rom_representation: "No per-screen byte. Authored rule: impassable terrain (water/lava/maze-desert) requires Faruk/Holy-Robe/Supica respectively."
    behavior: "R2's umbrella for water<->Faruk, lava<->Holy Robe, maze-desert<->Supica."
    confidence: HIGH(behavior, R2 2+ sources) / encoding UNKNOWN(R1)
    source: "R2 terrain_traversal_item; R1 (the three named logical gates)"

  - id: ally_ban_screen_restriction
    kind: logical(ROM screen-list)
    rom_representation: "ROM restricts allies from screens: Gubibi banned from lava-area screens; Mustafa banned from Troll Palace interior; Armor-of-Light banned from Sabaron's Castle screens. Flag vs screen-list vs content-byte check UNKNOWN (routine not disassembled)."
    confidence: MEDIUM(existence ROM_VERIFIED per chapter docs) / encoding UNKNOWN
    source: "R1 ally_ban_screen_restriction"

  - id: npc_flag_blocker
    kind: logical
    rom_representation: "Story-flag gated NPC join/act (visited past era, recognized as Isufa's heir, spoke to prior NPC). Maps onto event_script_progress_flag region; specific addrs mostly UNTRACED."
    behavior: "Gun Meca joins only after visiting past Alart; Epin must be recruited before Curly; Kaji gives Armor of Light only after seeing Legend Sword."
    confidence: HIGH(behavior, R2)
    source: "R2 npc_flag_blocker"

  - id: locked_door_key
    kind: logical
    rom_representation: "Key item $0308 (cap 9) opens locked doors ('Keys open locked doors'). Ch5 Sabaron's-Palace door is an ITEM-gated door (Armor of Light), not a numeric key. Ch4 Yufla Palace F3 door names no key (could be story-flag)."
    confidence: HIGH(mechanism) / MEDIUM(specific doors)
    source: "R2 locked_door_key; R1 RAM $0308 KEY"

  - id: gargoyle_gatekeeper
    kind: logical
    rom_representation: "Stone-gargoyle gatekeepers block palace doors; bypass with a Horn item OR defeat in combat. No traced encoding."
    behavior: "Ch1 Aqua Palace + Ch2 Dark Palace. Because combat is always an alternative, Horn may be CONVENIENCE not a hard gate (OPEN_QUESTION)."
    confidence: HIGH(Ch1) / MEDIUM(Ch2 whether ever strictly required)
    source: "R2 gargoyle_gatekeeper"

  - id: class_requirement
    kind: logical
    rom_representation: "Hero class gate (Fighter/Magician/Saint), set via Mosque payment or *COM transform spell. No traced screen encoding. Class state likely in $0300-region but addr UNDOCUMENTED."
    behavior: "Rainy needs Fighter (Ch4); Cimaron Tree needs Saint (Ch3); Ch5 Pillar Room needs Magician."
    confidence: HIGH(behavior, R2)
    source: "R2 class_requirement"

  - id: payment_shop_gate
    kind: logical
    rom_representation: "Rupia currency gate ($0089-$008B BCD, cap 999). Pay Imam for class; hire mercenary ally (Mustafa 100 Rupias)."
    confidence: HIGH
    source: "R2 payment_shop_gate; R1 RAM $0089-$008B"

  - id: in_palace_puzzle_gate
    kind: logical
    rom_representation: "Scripted in-dungeon puzzle (Ch5 Pillar Room moon/sun/star shoot sequence). Ritual NOT byte-encoded / UNTRACED. RING bails out if stuck."
    confidence: MEDIUM
    source: "R2 in_palace_puzzle_gate; R1 ch5_goragora_final ritual"

  - id: eclipse_window
    kind: logical(timed)
    rom_representation: "Alalart Solar Eclipse. Eclipse state $03FA/$03FB/$03FC (0x0C=yes). Great Spells (MONECOM/SPRICOM/LIBCOM) work only during eclipse; Rupia seed->money tree across eras."
    behavior: "Recurring window, not a one-way gate, but a SEQUENCING constraint. Likely OUT OF SCOPE for a static map-reachability validator (it's a temporal/economy loop, not a screen edge)."
    confidence: HIGH(R2) / HIGH(state addr R1)
    source: "R2 eclipse_window; R1 RAM $03FA-$03FC"
```

---

## 3. WorldScreen 16-byte schema (the static parse target) [R1 HIGH]

`world/README.md`. Offsets:
`0` ParentWorld(music/section), `1` AmbientSound, **`2` Content**, `3` ObjectSet,
**`4` ExitR / `5` ExitL / `6` ExitD / `7` ExitU**, `8` DataPointer, `9` ExitPosition,
`10` TopTiles, `11` BottomTiles, `12` ScreenColor, `13` SpritesColor, `14` Unknown,
**`15` Event**.

Chapter base addresses; `addr = base + index*16`:
| Ch | Base | Screens | Alt-era count |
|----|------|---------|---------------|
| 1 | `$039695` | 131 | 47 past |
| 2 | `$039EC5` | 137 | 44 past |
| 3 | `$03A755` | 153 | 48 FUTURE |
| 4 | `$03B0E5` | 164 | 84 past (largest) |
| 5 | `$03BB25` | 154 | 29 past (fewest, most linear) |

---

## 4. Per-chapter spec

For each chapter: `regions[]`, `acquirables[]`, `gates[]`, `win_condition{}`. Encoding fields
(`ram_addr`, `rom_representation`) are R1; progression fields (acquire location prose,
`requires`, critical-path role) prefer R2 where R1 is silent, and BOTH are shown when they
differ. `kind` tags each gate spatial|logical.

### Chapter 1 — Mooroon (Water) · boss Gilga · rescue Ashelato

```yaml
chapter: 1
regions: [Meshudo(start,present), Rudoria(present+past,MagicUniv-past), Poponoll(present),
          Horen(thriving-past / sunken-underwater-present), North-Cape(present water-entry),
          Magic-Field(past,Rupia-seed), Aqua-Palace(present,underwater,dungeon/boss),
          Underground-Maze(past)]

acquirables:
  - {id: oprin_spell, type: spell, obtained_at: "level 1 (start)", unlocks_terrain: "oprin_doors+time_doors", ram_addr: "$0322", confidence: HIGH, source: "R1+R2"}
  - {id: coronya, type: ally, obtained_at: "Time Door (answer YES to Coronya)", ram_addr: "UNKNOWN", confidence: MEDIUM, source: "R1 party L18 / R2"}
  - {id: faruk, type: ally, obtained_at: "Horen (PAST), Content 0x81; joins as Isufa's descendant", unlocks_terrain: water, ram_addr: "$033E", confidence: HIGH(flag)/MEDIUM(effect), source: "R1+R2"}
  - {id: kebabu, type: ally, obtained_at: "Horen (present), answer NO; gives Mirror Shield+Ring", ram_addr: "$033D", confidence: HIGH(flag), source: "R1+R2"}
  - {id: monecom, type: spell, obtained_at: "Wise Man in Underground Maze (past); eclipse great-spell", ram_addr: "$03E0-$03E4 region (CONFLICT)", confidence: HIGH(R2)/MEDIUM(addr), source: "R2"}
  - {id: horn, type: item, obtained_at: "via MONECOM duplication during eclipse (mechanism fuzzy)", confidence: MEDIUM, source: "R2"}
  - {id: mirror_shield, type: item, obtained_at: "from Kebabu, present Horen", ram_addr: "$0303 M-SHIELD", confidence: HIGH, source: "R2 / R1 $0303"}
  - {id: rupias_seed, type: item, obtained_at: "Meshudo shop; plant in Magic Field (past) during eclipse", confidence: HIGH, source: "R2"}
  - {id: cygnus_formation, type: formation, obtained_at: "Rudoria (past) Magic University", confidence: MEDIUM, source: "R1"}
  - {id: simitar_sword, type: weapon, obtained_at: "Ch1 story", ram_addr: "$0332 tier2", confidence: HIGH, source: "R1"}
  - {id: flame_rod, type: weapon, obtained_at: "Ch1", ram_addr: "$030E rod level 2", confidence: HIGH, source: "R1"}

gates:
  - gate_id: ch1_time_door
    from: "Rudoria area (present)"; to: "Rudoria/Horen (past)"
    requires: [oprin_spell, coronya, reach_door_screen]
    mechanism: time_door; kind: spatial
    rom_representation: "screen26.content==0xC0; screen64.content==0xC0 (past return). Era by PAST set {0x25-0x4A,0x69-0x71}."
    confidence: HIGH(encoding)/MEDIUM(requirement); source: "R1 ch1_timedoor_present + R2 ch1_time_door"
  - gate_id: ch1_water_to_aquapalace            # THE Faruk->water gate
    from: "North Cape (present)"; to: "Aqua Palace (underwater) + sunken Horen"
    requires: [faruk]
    mechanism: terrain_traversal_item; kind: logical
    rom_representation: "Faruk flag $033E. Underwater-passability routine UNTRACED. Spatial anchors: North Cape Event 0x07/0x47 jump screens. NO per-screen require-Faruk byte."
    confidence: HIGH(R2)/MEDIUM(R1 effect untraced); source: "R1 ch1_faruk_underwater + R2 ch1_water_to_aquapalace"
  - gate_id: ch1_palace_gargoyles
    from: "Aqua Palace entry"; to: "Aqua Palace interior (toward Gilga)"
    requires: [horn]            # OR defeat gargoyles in combat (combat always available)
    mechanism: gargoyle_gatekeeper; kind: logical
    rom_representation: "No traced encoding."
    confidence: HIGH(R2); source: "R2 ch1_palace_gargoyles"
  - gate_id: ch1_boss_gilga
    from: "Aqua Palace interior"; to: "Chapter clear (Ch2 password)"
    requires: [faruk, defeat_gilga]   # mirror_shield strongly aids (reflects Stone)
    mechanism: boss_stage_content + boss_defeat_gate; kind: spatial(screens)+logical(defeat)
    rom_representation: "boss screens (global) {118,127,128}, Content 0x21/0x22; victory 129; Event 0x09/0x48."
    confidence: HIGH(encoding)/MEDIUM(crit-path); source: "R1 ch1_aqua_palace_boss + R2 ch1_boss_gilga"

win_condition:
  description: "Defeat Water Demon Gilga in Aqua Palace; rescue Princess Ashelato; receive Ch2 password."
  goal: defeat_boss
  requires: [faruk, defeat_gilga]      # + Horn or combat for gargoyles
  confidence: HIGH(R2)/MEDIUM(R1)
  source: "R1+R2"
```

### Chapter 2 — Alalart (Desert) · boss Curly · rescue Ishutal

```yaml
chapter: 2
regions: [Malart(start,present), Copanes(present,GunMeca), Alart(PAST,PekePeke,MagicUniv),
          Sudari(past maze-desert; Troopers), Maze-Desert(present,navigational gate),
          Dark-Palace(dungeon/boss), Magic-Field(past), Underground-Prison(past,W of Alart)]

acquirables:
  - {id: raincom, type: spell, obtained_at: "Wise Man E of Malart (OPRIN)", unlocks_terrain: "desert (mitigation)", ram_addr: "$03E0-$03E4 region (CONFLICT)", confidence: MEDIUM, source: "R1+R2"}
  - {id: gun_meca, type: ally, obtained_at: "Copanes (present); joins only AFTER visiting past Alart; translates Peke Peke", ram_addr: "$0337 GunMeca", confidence: HIGH(flag), source: "R1 $0337 / R2"}
  - {id: magic_boots, type: item, obtained_at: "Lah in Alart (past), answer NO", ram_addr: "UNKNOWN", confidence: MEDIUM, source: "R2"}
  - {id: supica, type: ally, obtained_at: "Underground Maze prison (past, W of Alart); needs Magic Boots + Gun Meca in party; Content 0x82", unlocks_terrain: "maze-desert", ram_addr: "UNKNOWN", confidence: HIGH(R2 effect)/encoding UNKNOWN, source: "R1+R2"}
  - {id: epin, type: ally, obtained_at: "inside Dark Palace hidden room; Content 0x83; MUST recruit BEFORE Curly", ram_addr: "$033B", confidence: HIGH(flag), source: "R1+R2"}
  - {id: dragoon_sword, type: weapon, obtained_at: "Magic University Alart (past) — optional", ram_addr: "$0332 tier3", confidence: HIGH(R1)/MEDIUM(R2 loc), source: "R1+R2"}
  - {id: stardust_rod, type: weapon, obtained_at: "Ch2", ram_addr: "$030E rod level 3", confidence: HIGH, source: "R1"}
  - {id: libra_formation, type: formation, obtained_at: "Alart (past) Magic University", confidence: MEDIUM, source: "R1"}

gates:
  - gate_id: ch2_time_door
    from: "near Copanes (present)"; to: "Alart (past forest)"
    requires: [oprin_spell, coronya, reach_door_screen]
    mechanism: time_door (OPRIN-HIDDEN — invisible until OPRIN cast); kind: spatial
    rom_representation: "screen1.content==0xC0; screen79.content==0xC0. PAST set {0x38-0x5D,0x70,0x78-0x7C}. Hidden-reveal routine UNTRACED. Door is '7 S, 1 E of Copanes'."
    confidence: HIGH(encoding)/MEDIUM(hidden+req); source: "R1 ch2_timedoor_oprin_hidden + R2 ch2_time_door"
  - gate_id: ch2_gunmeca_flag
    from: "Copanes (present)"; to: "Gun Meca recruited"
    requires: [visited_past_alart]
    mechanism: npc_flag_blocker; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch2_supica_recruit
    from: "Underground Maze prison (past)"; to: "Supica recruited"
    requires: [magic_boots, gun_meca]
    mechanism: npc_flag_blocker; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch2_maze_desert            # THE Supica->desert gate
    from: "west of Malart (present)"; to: "Sudari / Dark Palace approach"
    requires: [supica]
    mechanism: terrain_traversal_item (navigational); kind: logical
    rom_representation: "Supica flag UNKNOWN. Desert HP-drain = tile/screen hazard, mechanism UNKNOWN. Whether exits are mechanically blocked or merely confusing is UNKNOWN. NO per-screen require-Supica byte."
    confidence: HIGH(R2)/encoding UNKNOWN(R1); source: "R1 ch2_supica_desert + R2 ch2_maze_desert"
  - gate_id: ch2_palace_gargoyles
    from: "Dark Palace entry"; to: "Dark Palace interior"
    requires: [horn]            # OR fight gargoyles (possibly always optional)
    mechanism: gargoyle_gatekeeper; kind: logical
    confidence: MEDIUM; source: "R2"
  - gate_id: ch2_boss_epin_prereq       # HARD ally gate
    from: "Dark Palace"; to: "winnable Curly fight"
    requires: [epin]            # without Epin the boss is unbeatable (Whistle forces Curly out of statue form)
    mechanism: npc_flag_blocker; kind: logical
    rom_representation: "Epin $033B. Statue/hidden state candidate enemy id $15/$17 + SILUETTE flag $054F&$10 [LOW link]."
    confidence: HIGH(R2 narrative-critical); source: "R1 ch2_curly_boss + R2 ch2_boss_epin_prereq"
  - gate_id: ch2_boss_curly
    from: "Dark Palace final room"; to: "Chapter clear (Ch3 password)"
    requires: [defeat_curly]
    mechanism: boss_stage_content + boss_defeat_gate; kind: spatial+logical
    rom_representation: "boss screens {264,265} Content 0x23/0x24; victory 266."
    confidence: HIGH; source: "R1+R2"

win_condition:
  description: "Recruit Epin, then defeat Curly's true form in the Dark Palace; rescue Princess Ishutal."
  goal: defeat_boss
  requires: [supica, epin, defeat_curly]
  confidence: HIGH(R2); source: "R1+R2"
```

### Chapter 3 — Samalkand (Forest) · boss Troll (Winter Demon) · rescue Roxanne

> NOTE: Ch3 is the only FORWARD-time chapter (PRESENT <-> FUTURE +30y). R2 names the FUTURE
> region; R1 confirms 48 FUTURE screens.

```yaml
chapter: 3
regions: [Nubia(start), Kasimeel(MagicUniv + Mosque buy Saint), Passora(hire Mustafa),
          Frozen-Palace(dungeon/boss), Magic-Field(FUTURE; SPRICOM), Cimaron-Tree(past; Pukin+Cimaron Rod),
          Dark-Maze/Maze-of-Darkness, Frozen-future-overworld]

acquirables:
  - {id: saint_class, type: class_change, obtained_at: "Pay Imam 40 Rupias, Kasimeel mosque", confidence: HIGH, source: "R2"}
  - {id: chocola_password, type: password, obtained_at: "Cimaron Tree dialogue (requires Saint class)", confidence: MEDIUM, source: "R2"}
  - {id: cimaron_rod, type: weapon, obtained_at: "Cimaron Tree (past), with CHOCOLA", unlocks_terrain: "dark-maze-light (w/ Saint+Pukin)", ram_addr: "$030E rod level 4", confidence: HIGH(item)/MEDIUM(light), source: "R1+R2"}
  - {id: pukin, type: ally, obtained_at: "Cimaron Tree (past); Cimaron Fruit converted to Pukin (via 'Supapa' — name unverified)", unlocks_terrain: "dark-maze-light", ram_addr: "UNKNOWN", confidence: MEDIUM, source: "R1+R2"}
  - {id: spricom, type: spell, obtained_at: "Magic Field, FUTURE Samalkand; eclipse great-spell; winter->spring", confidence: MEDIUM, source: "R2"}
  - {id: mustafa, type: ally, obtained_at: "Passora; hire for 100 Rupias", ram_addr: "UNKNOWN (R1)/N/A", confidence: HIGH, source: "R1+R2"}
  - {id: aries_sirius_formations, type: formation, obtained_at: "Kasimeel Magic University", confidence: MEDIUM, source: "R1"}
  - {id: kashim_sword, type: weapon, obtained_at: "Ch3", ram_addr: "$0332 tier4", confidence: HIGH, source: "R1"}

gates:
  - gate_id: ch3_time_door
    from: "screen 50 (present)"; to: "FUTURE (+30y) screen 75 region"
    requires: [oprin_spell, coronya]
    mechanism: time_door (FORWARD travel — only chapter); kind: spatial
    rom_representation: "screen50.content==0xC0; screen75.content==0xC0. FUTURE set {0x33-0x5A,0x8C-0x93}."
    confidence: HIGH(encoding)/MEDIUM(req); source: "R1 ch3_timedoor_future"
  - gate_id: ch3_saint_payment
    from: "Kasimeel mosque"; to: "Saint class"
    requires: [rupias_40]
    mechanism: payment_shop_gate; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch3_saint_for_cimaron
    from: "approach to Cimaron Tree"; to: "Cimaron Tree dialogue (Pukin + Cimaron Rod)"
    requires: [saint_class]
    mechanism: class_requirement; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch3_dark_maze
    from: "forest overworld"; to: "Frozen Palace approach via Dark Maze"
    requires: [pukin]      # + Saint+Cimaron Rod for light (GUIDE)
    mechanism: maze (invisible-wall hazards); kind: spatial(maze events)+logical(light item)
    rom_representation: "maze ParentWorld 0x58; Event 0x80 MAZE_PUZZLE / 0xC0 MAZE_SPECIAL. Light mechanic UNTRACED."
    confidence: MEDIUM; source: "R1 ch3_dark_maze"
  - gate_id: ch3_mustafa_hire
    from: "Passora"; to: "Mustafa in party"
    requires: [rupias_100]
    mechanism: payment_shop_gate; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch3_boss_troll
    from: "Frozen Palace"; to: "Chapter clear (Ch4 password)"
    requires: [mustafa, defeat_troll]   # R1 adds pukin (identifies real Troll among decoys); Mustafa BANNED from palace interior (ROM screen-restriction, mechanism UNKNOWN)
    mechanism: boss_stage_content + boss_defeat_gate + ally_ban_screen_restriction; kind: spatial+logical
    rom_representation: "boss screens {401,402} Content 0x25/0x26; victory 403. Mustafa-ban encoding UNKNOWN."
    confidence: HIGH(R2 Mustafa)/MEDIUM(R1 Pukin role); source: "R1 ch3_troll_boss + R2 ch3_boss_troll"
    CONFLICT: "R2 states only Mustafa is REQUIRED for Troll; R1 lists [mustafa, pukin]. See OPEN_QUESTIONS."

win_condition:
  description: "Defeat Winter Demon Troll in the Frozen Palace (Mustafa required; Pukin per R1); rescue Princess Roxanne."
  goal: defeat_boss
  requires: [mustafa, defeat_troll]    # pukin: R1=required, R2=unconfirmed
  confidence: HIGH(R2)/MEDIUM(R1); source: "R1+R2"
```

### Chapter 4 — Celestern (Flower) · boss Salamander · rescue King Feisal (no princess)

```yaml
chapter: 4
regions: [Yufla(town,present), Pao(MagicUniv,Crystal Rod), Chigris(Mosque buy Fighter),
          Fire-Palace(Gubibi/Holy Robe + Time Door), Farvil(PAST 3000y; Lava town; Mosque),
          Lava-Cape(lava terrain gate), Lava-town(past; Rainy), Yufla-Palace(dungeon/boss; Rostam Sword/MOSCOM)]
  # CONFLICT (R2 OQ1): SW world title "Celestern" vs FO town names Yufla/Pao/Chigris (which reappear in Ch5).

acquirables:
  - {id: gubibi, type: ally, obtained_at: "Fire Palace (present), reached via OPRIN; Content 0x80", unlocks_terrain: lava (provides Holy Robe), ram_addr: "$0339", confidence: HIGH(flag), source: "R1+R2"}
  - {id: holy_robe, type: equipment, obtained_at: "from Gubibi (also buyable MAGIC shop ~200 Rupias)", unlocks_terrain: lava, ram_addr: "$0305", confidence: HIGH, source: "R1+R2"}
  - {id: crystal_rod, type: weapon, obtained_at: "Magic University, Pao", ram_addr: "$030E rod level 5", confidence: HIGH, source: "R1+R2"}
  - {id: rainy, type: ally, obtained_at: "Lava town (PAST); answer NO to both; MUST be Fighter class (else game-over per R1); rain breaks Salamander Fire Field", ram_addr: "$033C", confidence: HIGH(flag+narrative), source: "R1+R2"}
  - {id: moscom, type: spell, obtained_at: "Yufla Palace F3 (through a locked door); Magician transform", confidence: MEDIUM, source: "R2"}
  - {id: rostam_sword, type: weapon, obtained_at: "Yufla Palace (past, optional F2/3F)", ram_addr: "$0332 tier5", confidence: HIGH(R1)/MEDIUM(R2 loc), source: "R1+R2"}
  - {id: kaitos_moscom_formations, type: formation, obtained_at: "Pao Magic University", confidence: MEDIUM, source: "R1"}

gates:
  - gate_id: ch4_lava_cape              # THE Holy Robe->Lava gate
    from: "Lava Cape (past volcanic overworld)"; to: "Lava town (Rainy) + Yufla Palace items"
    requires: [holy_robe]              # via Gubibi
    mechanism: hazard_terrain (lava) + terrain_traversal_item; kind: spatial(tile)+logical(item req)
    rom_representation: "lava hazard tiles {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC}; $0305 negates (GUIDE, routine UNTRACED). Gubibi ALLY banned from lava-area screens (mechanism UNKNOWN)."
    confidence: HIGH(hazard+item encoding)/MEDIUM(bypass GUIDE); source: "R1 ch4_holy_robe_lava + R2 ch4_lava_cape"
  - gate_id: ch4_time_door
    from: "screen 2 (present Fire Palace area)"; to: "Farvil / past volcanic screen 56 region (3000y past)"
    requires: [oprin_spell, coronya]
    mechanism: time_door; kind: spatial
    rom_representation: "screen2.content==0xC0; screen56.content==0xC0. PAST set {0x35-0x5D,0x68-0x8E} (84 screens)."
    confidence: HIGH(encoding)/MEDIUM(req); source: "R1 ch4_timedoor + R2 ch4_time_door"
  - gate_id: ch4_rainy_fighter
    from: "Lava town (past)"; to: "Rainy recruited"
    requires: [fighter_class]
    mechanism: class_requirement; kind: logical
    rom_representation: "HARD GATE — wrong class at recruit = game-over (R1)."
    confidence: HIGH; source: "R1+R2"
  - gate_id: ch4_palace_locked_door
    from: "Yufla Palace Floor 3"; to: "MOSCOM chamber"
    requires: [key_or_progression]    # 'through a locked door'; no key item named — may be story-flag
    mechanism: locked_door_key; kind: logical
    confidence: LOW; source: "R2 (R1 silent)"
  - gate_id: ch4_boss_salamander
    from: "Yufla Palace boss room"; to: "Chapter clear (Ch5 password)"
    requires: [rainy, crystal_rod, defeat_salamander]   # Rainy's rain breaks Fire Field
    mechanism: boss_stage_content + boss_defeat_gate; kind: spatial+logical
    rom_representation: "boss screens {560,561} Content 0x27/0x28; victory 562. Fire-field 127-iter ROM 0x18A2E."
    confidence: HIGH(encoding)/MEDIUM(crit-path); source: "R1 ch4_salamander_boss + R2 ch4_boss_salamander"
    NOTE: "R1 win_condition lists [gubibi/holy_robe, rainy]; R2 adds crystal_rod. Merged requires keeps all."

win_condition:
  description: "Defeat Fire Demon Salamander in Yufla Palace (Rainy's rain + Crystal Rod); rescue King Feisal (NOT a princess)."
  goal: defeat_boss
  requires: [holy_robe, rainy, crystal_rod, defeat_salamander]
  confidence: HIGH(R2)/MEDIUM(R1); source: "R1+R2"
```

### Chapter 5 — Sabaron's Realm · final boss GoraGora · rescue Scheherazade

```yaml
chapter: 5
regions: [Yufla(recruit Hassan), Pao(Armor of Light S of Pao, between two trees),
          Chigris(LIBCOM door E of Chigris), Fire-Palace(Underground Maze + Time Door to Light Palace),
          Light-Palace(past; Legend Sword), Underground-Maze(14 stairways; Armor-of-Light-locked door),
          Sabarons-Palace(endgame; Pillar Room), Airosche-Dark-World, inherited towns Yufla/Pao/Chigris]

acquirables:
  - {id: hassan, type: ally, obtained_at: "Yufla (present), after beating Salamander; Content 0x81; strongest fighter", ram_addr: "$033F", confidence: HIGH(flag)/MEDIUM(loc), source: "R1+R2"}
  - {id: legend_sword, type: weapon, obtained_at: "Light Palace (past), via Time Door in Fire Palace maze", ram_addr: "$0332 tier6", confidence: HIGH, source: "R1+R2"}
  - {id: armor_of_light, type: item, obtained_at: "Bridge S of Pao (between two trees); from Kaji after showing Legend Sword", ram_addr: "$0302==2 (L-ARMOR)", confidence: HIGH, source: "R1+R2"}
  - {id: libcom, type: spell, obtained_at: "Door E of Chigris (OPRIN); eclipse great-spell; revives party", ram_addr: "$03E0-$03E4 region (CONFLICT)", confidence: MEDIUM, source: "R1+R2"}
  - {id: isfa_rod, type: weapon, obtained_at: "Sabaron's Palace — given by Scheherazade / per R1 unlocked by CORONYA password", unlocks_terrain: "required-for-final", ram_addr: "$030E rod level 6", confidence: HIGH(R1)/MEDIUM(R2 loc), source: "R1+R2"}
  - {id: bolttor3_spell, type: spell, obtained_at: "(L17 spell)", ram_addr: "$0325", confidence: HIGH, source: "R1"}
  - {id: legend... see legend_sword}

gates:
  - gate_id: ch5_legend_sword_timedoor
    from: "Fire Palace -> Underground Maze -> Time Door"; to: "Light Palace (past) -> Legend Sword"
    requires: [oprin_spell, coronya, reach_door]
    mechanism: time_door; kind: spatial
    confidence: HIGH; source: "R2 ch5_legend_sword_timedoor"
  - gate_id: ch5_underground_maze
    from: "corrupted overworld"; to: "Sabaron's Palace approach via Underground Maze"
    requires: []          # funnel; heavy stairway network
    mechanism: stairway network; kind: spatial
    rom_representation: "14 Event 0x40 stairway screens {36,37,40,46,47,49,50,55,56,57,62,64,65,114+} (4 clean pairs + 6 orphans); maze ParentWorld 0x5D."
    confidence: HIGH(encoding); source: "R1 ch5_underground_maze"
  - gate_id: ch5_kaji_proof
    from: "Kaji (near Pao)"; to: "Armor of Light granted"
    requires: [legend_sword]    # proof of Isufa's heir
    mechanism: npc_flag_blocker; kind: logical
    confidence: HIGH; source: "R2"
  - gate_id: ch5_sabaron_palace_door   # THE Ch5 sword+armor gate
    from: "Underground Maze"; to: "Sabaron's Palace"
    requires: [armor_of_light]   # door refuses entry without it (both sword+armor needed to reach final area)
    mechanism: locked_door_key (item-gated door, not numeric key); kind: logical
    rom_representation: "No traced per-screen byte. Armor-of-Light ally/item ALSO banned from Sabaron's Castle screens (R1 ally_ban, mechanism UNKNOWN)."
    confidence: HIGH(R2); source: "R1 ally_ban + R2 ch5_sabaron_palace_door"
  - gate_id: ch5_password_isfa          # R1's distinctive Ch5 gate
    from: "Sabaron's Palace mid"; to: "deeper palace + Isfa Rod"
    requires: [password_CORONYA_event]
    mechanism: event_script_progress_flag (password = bank-2 VM op12 / secret table, NOT a WorldScreen byte); kind: logical
    rom_representation: "password CORONYA at bank2 $AC27 (tiles $32 $3E $41 $3E $3D $48 $30), checked by VM op12 $AC7C (when $04D0==1). Isfa = $030E==6."
    confidence: HIGH(encoding)/MEDIUM(placement); source: "R1 ch5_password_isfa"
    NOTE: "R2 says Isfa Rod is simply given by Scheherazade in the palace. R1 ties it to the CORONYA password event. Both kept; see OPEN_QUESTIONS."
  - gate_id: ch5_pillar_room
    from: "Sabaron's Palace"; to: "Goragora arena"
    requires: [magician_class, pillar_room_puzzle]   # moon/sun/star shoot sequence; RING bails out
    mechanism: in_palace_puzzle_gate; kind: logical
    rom_representation: "ritual (moon->sun->hexagram) NOT byte-encoded / UNTRACED."
    confidence: MEDIUM; source: "R1 ch5_goragora_final + R2 ch5_pillar_room"
  - gate_id: ch5_boss_goragora
    from: "Goragora arena"; to: "Game end"
    requires: [isfa_rod, bolttor3_spell, defeat_goragora]   # BOLTTOR3 to head, ISFA rod on spinning balls
    mechanism: boss_stage_content + boss_defeat_gate; kind: spatial+logical
    rom_representation: "boss screens {632,640,650,738} Content 0x29/0x2A."
    confidence: HIGH(encoding)/MEDIUM(crit-path); source: "R1+R2"

win_condition:
  description: "Enter Sabaron's Palace with Legend Sword + Armor of Light, solve the Pillar Room (as Magician), defeat GoraGora with ISFA Rod + BOLTTOR3. Game ends; rescue the real Scheherazade."
  goal: defeat_final_boss
  requires: [legend_sword, armor_of_light, magician_class, isfa_rod, bolttor3_spell, defeat_goragora]
  confidence: HIGH(R2)/MEDIUM(R1); source: "R1+R2"
```

---

## 5. RAM have-item address table (from R1) — for the EMULATOR, not the static validator

R1 HIGH unless noted. **This table is NOT needed by the static map-reachability validator**
(which reasons over abstract requirement tokens, not RAM). It is recorded here for the later
emulator-backed dynamic checker / playtest oracle.

| RAM | Meaning | Cap | Notes |
|-----|---------|-----|-------|
| `$0082` | ChapterIndex 0-4 | — | per-chapter scaling |
| `$0089-$008B` | Rupia (BCD H/T/O) | 999 | currency (payment gates) |
| `$0300`/`$0301` | progress level / party progress | 9 | warp-table writes (Ch0-4 = 3..7) |
| `$0302` | Armor level | 2 | 0/1=R-ARMOR(½) / 2=L-ARMOR=Armor-of-Light(¼) |
| `$0303` / `$0304` | M-SHIELD / M-BOOTS | bool | |
| `$0305` | HOLYROBE | bool | **lava traversal** |
| `$0306` / `$0307` | BREAD / MASHROOB | 10 | consumables |
| `$0308` / `$0309` | KEY / AMULET | 9 | quest items |
| `$030E` | Rod level | 1-6 | Rod/Flame/Stardust/Cimaron/Crystal/**Isfa** |
| `$030F-$0311` | ROD/FLAME/STARDUST ammo | 5/5/15 | |
| `$0322` | OPRIN flag / magic base | — | spell-known flags `$0322-$0331` |
| `$0323-$0325` | Bolttor1/2/3 | — | L3/11/17 (**$0325=Bolttor3, Ch5 boss**) |
| `$0326-$0328` | Flamol1/2/3 | — | L7/14/23 |
| `$0332` | Equipped sword tier | 1-6 | tier2..6 = Simitar/Dragoon/Kashim/Rostam/Legend |
| `$0337/$0339/$033B/$033C/$033D/$033E/$033F` | GunMeca / Gubibi / Epin / Rainy / Kebabu / Faruk / Hassan recruit flags | — | nonzero=recruited |
| (UNKNOWN) | Coronya / Supica / Pukin / Mustafa recruit flags | — | **addresses UNDOCUMENTED — gap for emulator oracle** |
| `$03E0-$03E4` | special/event items OR 5 Great Magic | — | **CONFLICT (see OQ)** |
| `$03FA/$03FB/$03FC` | Eclipse state / countdown | 0x0C=yes | gates Rupia-Seed / Great Magic / casino |
| `$04D0` | (Ch5) CORONYA password armed flag | 1=armed | enables Isfa Rod secret-table check |
| `$054F & $10` | SILUETTE (Curly statue reveal candidate) | — | [LOW link] |

Warp/state-init table `$BB1F` (50×7 records): writes `$0084` screen-pos, `$0089` chapter,
`$0300/$0301` progress, `$0302` armor — confirms these are canonical chapter-progress bytes. [HIGH]

---

## 6. MODELING NOTES FOR THE VALIDATOR

### 6.1 What is AUTO-DERIVED from WorldScreen bytes (no authoring)
Parse every screen `addr = base + index*16` and emit physical edges + spatial gates:
- **Adjacency edges:** for each Exit byte (4..7): value `0x00-0xFD` => edge to that screen index;
  `0xFF` => no edge; `0xFE` => edge into an opaque building interior node.
- **Stairway edges:** `Event == 0x40` => edge to `screen[Content]` (bidirectional; but flag Ch2/Ch5
  orphans as suspect one-way — OQ a4).
- **Time Door edges:** `Content == 0xC0` => era-swap edge to the paired door (pairs from
  `time_door_screens.json`); gate token `oprin_spell` (free — always held) + Coronya hint.
- **OPRIN-door reveals:** `Event in {0x20,0x22}` => the revealed node is a free edge (OPRIN always
  held); do NOT treat as scarce gate.
- **Hazard tiles:** if a screen renders any hazard tile ID on a required-cross path, attach a
  HAND-MODELED bypass requirement (lava => `holy_robe`). The tile detection is auto; the
  *requirement* is authored.
- **Boss screens:** `Content in 0x21..0x2A` => terminal boss node; attach the chapter's
  authored boss `requires[]` (Section 4 win_condition).

### 6.2 What MUST be AUTHORED (logical rules — Section 4 `gates[].kind == logical`)
These have no per-screen "requires item" byte (R1 HIGH). They are encoded as authored rules that
attach a requirement set to a specific edge/region/boss:
- **Terrain item gates:** Faruk=>water (Ch1 North-Cape/Horen/Aqua region), Supica=>maze-desert
  (Ch2 west-of-Malart region), Holy-Robe=>lava (Ch4 Lava Cape).
- **Boss-prerequisite allies:** Epin (Ch2 Curly), Mustafa [+Pukin?] (Ch3 Troll), Rainy (Ch4
  Salamander), Isfa Rod + Bolttor3 (Ch5 GoraGora).
- **Class gates:** Saint (Ch3 Cimaron), Fighter (Ch4 Rainy recruit — hard), Magician (Ch5 Pillar).
- **Payment gates:** Rupia thresholds (Saint 40, Mustafa 100). Model as "currency reachable",
  i.e. is there a reachable income source — usually trivially satisfiable; can be a soft check.
- **Item-gated doors:** Ch5 Sabaron door (Armor of Light), Ch4 Yufla F3 (LOW — maybe story-flag).
- **Story-flag/NPC blockers:** Gun Meca (visited past Alart), Kaji (showed Legend Sword), Ch5
  CORONYA password (=> Isfa Rod).
- **Cross-era dependency:** the era graph is ONE connected reachability space joined at Time Door
  edges; an item obtained in one era satisfies its requirement in the other. Model PAST and
  PRESENT/FUTURE screens as a single graph linked by the time-door edges, not two graphs.

### 6.3 How era (PAST_SCREEN_INDICES) interacts
- Era is **NOT byte-encoded** (R1 HIGH). A screen's era is its membership in the chapter's
  PAST/FUTURE index set (e.g. Ch1 `{0x25-0x4A,0x69-0x71}`, Ch4 `{0x35-0x5D,0x68-0x8E}`).
- R1 OQ8: these sets currently live in the randomizer's `enums.py`, NOT in the ROM bytes. The
  validator must **import PAST_SCREEN_INDICES as a constant table** (confirm whether derivable
  from ROM or must stay a hand-maintained constant — OQ b1).
- Implication: when randomizing, time-door PAIRS must keep one present-side + one alt-era-side
  member, or the era graph splits. The validator's BFS treats a time-door edge as connecting the
  two era halves; if a chapter's two `0xC0` screens both fall in the same era set, the era graph
  is disconnected => INVALID.

### 6.4 The reachability rule (the validator's core)
```
reachable = BFS from chapter_start over:
    physical edges (adjacency / stairway / time-door / building-entrance / oprin-reveal)
    WHERE each LOGICAL gate on an edge/region is satisfied by the current acquired-token set,
    AND acquired tokens grow monotonically as their source nodes become reachable
    (fixed-point: re-run BFS until no new node/token is added).
A randomized chapter map is VALID iff, at fixed point:
    - every acquirable required by the win_condition is reachable, AND
    - the boss node is reachable with win_condition.requires[] all satisfied, AND
    - no required class-change / payment source is stranded behind its own requirement.
```
Tokens are abstract (`faruk`, `holy_robe`, `saint_class`, `armor_of_light`, ...), NOT RAM values.
The RAM table (Section 5) is only for a later emulator oracle that confirms the static result.

---

## 7. OPEN_QUESTIONS (prioritized)

Headline (R1): the disasm documented gate ENCODING + the have-item RAM map but **never traced the
gate-CHECK routines** for the logical gates, so logical requirements come from R2 walkthroughs and
must be playtest-validated. Below, **(a) BLOCKING** = could make the validator wrong; **(b)
COSMETIC/NAMING** = won't change reachability math.

### (a) BLOCKING — resolve before trusting the validator

- **B1. Does ANY Time Door have a hard (scarce-item) gate?**
  R1: time door = Content 0xC0, needs OPRIN(always held)+Coronya, activation routine UNTRACED.
  R2 (OQ2): "no gate" asserted by ABSENCE of evidence, not a positive statement.
  *Why blocking:* the whole era graph hinges on time doors being free. If any chapter gates its
  door on a scarce item, BFS would wrongly mark the alt-era reachable.
  *Resolve by:* trace the time-travel activation routine (does it check any flag besides $0322?);
  or positive walkthrough confirmation per chapter. [R1 OQ3, R2 OQ2]

- **B2. Era-membership table (PAST_SCREEN_INDICES) — source of truth + correctness.**
  Era is not byte-encoded (R1 HIGH); the index sets live in randomizer enums.py (R1 OQ8).
  *Why blocking:* the validator imports this table to know which screens are which era and to
  verify time-door pairs straddle eras. A wrong/stale table => wrong reachability.
  *Resolve by:* confirm the sets are authoritative (cross-check vs door indices in
  time_door_screens.json) and decide derivable-from-ROM vs hand-maintained constant. [R1 OQ8]

- **B3. Supica desert gate: mechanical block vs. mere navigation?**
  R1: Supica flag addr UNKNOWN; whether exits are mechanically blocked w/o Supica or just
  confusing is UNKNOWN. R2: HIGH that Supica is the maze-desert traversal gate.
  *Why blocking:* if the desert is merely confusing (not exit-blocked), it is NOT a reachability
  gate and modeling it as one would over-constrain valid maps; if it IS blocked, omitting it
  would pass un-winnable maps.
  *Resolve by:* trace Ch2 desert screen exit-resolution + the Supica flag check. [R1 OQ2, R2 OQ on desert]

- **B4. Class-change availability per chapter — can a randomizer strand a required class?**
  Required classes: Saint (Ch3), Fighter (Ch4 Rainy — HARD, wrong class = game-over), Magician
  (Ch5 Pillar). R2 OQ8: whether every chapter offers all class changes (Mosque + *COM) is
  ASSUMED, not confirmed. Class-state RAM addr is UNDOCUMENTED (R1).
  *Why blocking:* if a chapter's only class source is itself behind the gate it unlocks, or a
  randomizer can remove it, the chapter is unwinnable. Rainy's game-over-on-wrong-class is a hard
  fail state.
  *Resolve by:* enumerate per-chapter class sources (Mosque locations + *COM spell sources) and
  confirm reachability independent of the gates they satisfy. [R2 OQ8]

- **B5. Ch3 Troll: is Pukin REQUIRED, or only Mustafa? (R1 vs R2 conflict)**
  R1 ch3_troll_boss requires [mustafa, pukin] (Pukin identifies real Troll among decoys).
  R2 states only Mustafa is mandatory ("can't beat Troll without his help"); Pukin role
  unconfirmed (R2 OQ5).
  *Why blocking:* changes the Ch3 win_condition requirement set, hence which acquirables must be
  reachable.
  *Resolve by:* second walkthrough source or a Troll-fight disasm trace for the decoy mechanic.

- **B6. Ch5 Isfa Rod: CORONYA-password event gate (R1) vs. simply given by Scheherazade (R2)?**
  R1 ch5_password_isfa: Isfa unlocked via bank-2 password event (op12 $AC7C / table $AC27).
  R2: Isfa Rod just given in Sabaron's Palace.
  *Why blocking:* if Isfa is behind a scripted password event, that event is a hard gate on the
  final boss; if it's a plain pickup, it's only reach-the-screen. Final-boss reachability depends
  on which.
  *Resolve by:* trace where op12 $AC7C is invoked / which screen arms $04D0; or detailed endgame
  walkthrough on how Isfa is obtained. [R1 OQ12]

- **B7. Ally-ban screen restrictions — do they affect reachability?**
  R1: Gubibi banned from lava screens, Mustafa from Troll palace interior, Armor-of-Light from
  Sabaron's castle screens — encoding UNKNOWN. If a banned ally is the REQUIRED traversal/boss
  ally for that very region, the ban could strand progress.
  *Why blocking (conditionally):* e.g. Gubibi provides Holy Robe (needed for lava) yet is banned
  from lava screens — confirm the ban is about presence-in-party-on-screen, not about whether the
  item works, else lava traversal logic is wrong.
  *Resolve by:* trace the ally-ban check (flag vs screen-list vs content byte). [R1 OQ5]

- **B8. Are any exit bytes modified at RUNTIME (a gate "opening" an exit after an event)?**
  R1 OQ14 / navigation open-question. *Why blocking:* a static WorldScreen parse would then
  under- or over-count edges (e.g. a wall that opens after a boss). *Resolve by:* search for code
  that writes to the WorldScreen exit bytes / a parallel runtime exit override table. [R1 OQ14]

### (b) COSMETIC / NAMING / non-reachability — fix opportunistically

- C1. `$03E0-$03E4` identity conflict: Great Magic (REVERSE.md) vs event-action triggers
  (items_registry). Same region either way; doesn't change map reachability. Resolve by re-tracing
  handlers $9659/$966A/$96AE/$96B9/$9725. [R1 OQ6]
- C2. Undocumented recruit-flag addresses (Coronya/Supica/Pukin/Mustafa). Only needed for the
  emulator oracle, not the static validator (which uses abstract tokens). [R1 OQ7]
- C3. Ch4 town/world naming: SW "Celestern" vs FO Yufla/Pao/Chigris (reused in Ch5). Naming only.
  [R2 OQ1]
- C4. Ch1 Horn acquisition exact mechanism + count; whether Horn is ever strictly required vs
  always-beatable gargoyles (Ch2). Affects an optional convenience gate, not the critical path
  (boss reachable via combat). [R2 OQ3, OQ4]
- C5. Ch3 SPRICOM vs Saint-ordering; "Supapa" name for Cimaron->Pukin conversion (possible
  mistranscription). Sequencing/naming. [R2 OQ5, OQ6]
- C6. Ch4 Yufla Palace F3 locked door — key vs story-flag (LOW). Only gates MOSCOM (optional
  spell), not the boss path. [R2 OQ7]
- C7. Princess names / Ch4 "King Feisal not a princess" — narrative labels only. [R2 OQ9]
- C8. OPRIN-hidden building/service inventory (full per-chapter list). Refines which buildings are
  OPRIN-gated; since OPRIN is free, doesn't change reachability, only annotation. [R1 OQ10]
- C9. Building-interior sub-graphs opaque (0xFE interiors not byte-mapped) — interiors treated as
  opaque nodes; acceptable unless a required item sits at an interior depth the parse can't see.
  Borderline; promote to BLOCKING if a win-condition item is interior-only. [R1 OQ13]
- C10. Ch5 final-boss ritual (moon/sun/hexagram) encoding — UNTRACED; modeled as an authored
  in-palace puzzle token, so it's an authored constant, not a parse gap. [R1 OQ11]
- C11. Ch2/Ch5 orphan stairways one-way? Listed B-adjacent (could be reachability-affecting); kept
  here as it likely only matters if an orphan is the sole edge to a required node — flag for
  promotion if so. [R1 OQ9]
```
