# TMOS Progression / Gating Logic — Static-Reachability Source Map

**Date:** 2026-06-17
**Purpose:** Mine the authoritative local TMOS analysis repo for item/event gating logic and its ROM/RAM encoding, to drive a STATIC item-gated reachability validator for the map randomizer.
**Source of truth:** `C:/claude-workspace/GameAnalysis2/analysis_games/TMOS` (ROM_VERIFIED specs + 6502 disassembly `analysis/2026-06-12_rom_re/` + RAM map). Read-only.
**ROM:** `TMOS_ORIGINAL.nes`, md5 `b3236db14c87f375e5f24a5b9b79f071`.

**Confidence tags:** HIGH = ROM_VERIFIED or disassembly-confirmed; MEDIUM = inference / GUIDE_SOURCED cross-referenced; LOW = uncorroborated single-source.

---

## CRITICAL FINDING — what is and is NOT statically detectable

The repo's **HIGH-confidence facts are about ENCODING of screen features (the WorldScreen byte schema)**, and a **RAM progress-flag map**. But the repo did **NOT trace the actual gate-CHECK routines** — i.e., the 6502 code that decides "you may not pass this screen unless you hold item X." Almost every *gate's gating logic* (Faruk→underwater, Supica→desert maze, ally-ban screen lists, Holy Robe→lava) is **GUIDE_SOURCED behavior**, not disassembly-confirmed code. Consequence for the validator:

- **Spatially-encoded gates ARE statically detectable from WorldScreen bytes**: Time Doors (Content `0xC0`), stairways (Event `0x40` + Content=dest), building entrances (Exit byte `0xFE`), OPRIN-doors (Event `0x20`/`0x22`), hazard tiles (lava etc., tile-collision set). [HIGH]
- **Logical / item-conditional gates are NOT individually encoded on a screen byte.** They are enforced by event-script flags (`$0300`-region) and by hard-coded screen-list checks in code the repo never disassembled. The validator must **model these as hand-authored logical rules** keyed to known chapter critical paths — the ROM does not expose a per-screen "requires item N" field. [HIGH that no such field is documented; the four named gates are MEDIUM behavior]

---

## gating_mechanisms_catalog

```yaml
gating_mechanisms_catalog:

  - id: time_door
    kind: spatial
    encoding: WorldScreen byte 2 (Content) == 0xC0   # 0xC7/0xD7 are documented exit variants but NOT present in ROM scan; all 10 doors use 0xC0
    detect: "screen.content == 0xC0"
    semantics: "Bidirectional time-travel entrance. Exactly 2 per chapter (present-side + past-side). Era of a screen is NOT byte-encoded — determined by chapter-relative index membership in PAST_SCREEN_INDICES sets."
    item_requirement: "Coronya ally + OPRIN spell to ACTIVATE (GUIDE_SOURCED). In Ch2 the present-side door is also OPRIN-hidden."
    confidence: HIGH (encoding) / MEDIUM (activation requirement)
    source: "world/time_travel/README.md L8-26; world/map_layout/time_door_screens.json; content_types.md L40-42"

  - id: stairway
    kind: spatial
    encoding: "WorldScreen byte 15 (Event) == 0x40; byte 2 (Content) holds destination screen index (chapter-relative)"
    detect: "screen.event == 0x40 -> edge to screen[content]"
    semantics: "Non-adjacent bidirectional link. Content cannot double as building/shop on a stairway screen. Ch2 & Ch5 have ORPHAN stairways (dest does not point back) — treat as possibly one-way."
    confidence: HIGH
    source: "navigation/README.md L179-189; world/time_travel/README.md L95-107; map_layout/stairway_pairs.json"

  - id: building_entrance
    kind: spatial
    encoding: "Exit byte (4=Right,5=Left,6=Down,7=Up) == 0xFE"
    detect: "any exit byte == 0xFE -> enters interior sub-graph"
    semantics: "0x00-0xFD = valid dest screen index; 0xFF = blocked; 0xFE = building entrance (separate interior graph). Interior layout NOT byte-mapped."
    confidence: HIGH
    source: "world/README.md L30-33; navigation/README.md L8-15; map_layout/README.md L14-16"

  - id: oprin_door
    kind: spatial + logical(spell)
    encoding: "WorldScreen byte 15 (Event) == 0x20 (NPC_DIALOG / Oprin door, no message) or 0x22 (OPRIN_DOOR, reveals hidden door w/ Coronya msg)"
    detect: "screen.event in {0x20, 0x22}"
    item_requirement: "OPRIN spell (learned at level 1, always available; flag $0322). Reveals hidden staircases/passages/buildings."
    note: "0x22 is in SAFE_EVENTS (randomizer may relocate); 0x20 is DANGEROUS (story NPC). Both are the hidden-door mechanic."
    confidence: HIGH (encoding) / MEDIUM (which screens are gated vs cosmetic)
    source: "puzzles/README.md L9-13; content_types.md L122-123,146; magic/README.md (OPRIN)"

  - id: hazard_terrain
    kind: spatial(tile-collision)
    encoding: "Tile collision category Hazard; known hazard tile IDs {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC}. Tiles resolved from TopTiles(10)/BottomTiles(11) TileSection indices."
    detect: "screen renders a hazard tile in a path the player must cross (e.g. lava)"
    item_requirement: "Holy Robe (RAM $0305 boolean) negates lava damage (GUIDE_SOURCED). Armor tiers ($0302) halve/quarter generic damage but do NOT documented-ly bypass lava."
    confidence: HIGH (hazard tile set + collision categories) / MEDIUM (Holy-Robe-bypasses-lava is GUIDE_SOURCED, no traced routine)
    source: "world/README.md L85-90; economy/items_registry.md $0305 HOLYROBE; chapter_4_map.md L86-93"

  - id: event_script_progress_flag
    kind: logical
    encoding: "Bank-2 script VM IF-opcodes branch on progress flags in the $0300-region (observed $033E, $03E0-$03E4, $03E0+). Address-space base table $ACF8 index1 = $0300. No per-screen 'requires item' field exists."
    detect: "NOT statically detectable from WorldScreen bytes. Requires modeling the event/flag dependency by hand."
    confidence: HIGH (mechanism exists) / the per-screen mapping is UNTRACED
    source: "technical/script_vm.md L77-88 (IF on $03E0-$03E4); items_registry $03E0-$03E4 count map"

  - id: ally_ban_screen_restriction
    kind: logical(ROM screen-list)
    encoding: "ROM-level flag restricts specific allies from specific screens (Gubibi banned from lava-area screens; Mustafa banned from Troll Palace interior; Armor of Light banned from Sabaron's Castle screens)."
    detect: "Mechanism (flag vs screen-list vs content-byte check) is UNKNOWN — routine not disassembled."
    confidence: MEDIUM (existence ROM_VERIFIED per chapter docs) / encoding UNKNOWN
    source: "chapter_3_map.md L87; chapter_4_map.md L95-96; chapter_5_map.md L95"

  - id: boss_stage_content
    kind: spatial
    encoding: "Content byte 0x21-0x2A = boss phases (2 per boss, Gilga..GoraGora). Event 0x09 PRE_BOSS / 0x48 BOSS_PREP mark approach screens (DANGEROUS_EVENTS)."
    detect: "screen.content in 0x21..0x2A ; screen.event in {0x09,0x48}"
    confidence: HIGH
    source: "content_types.md L20-29,67; navigation/README.md boss-screen set"
```

### WorldScreen 16-byte schema (the static parse target) [HIGH]
`world/README.md L22-41`. Offsets: 0 ParentWorld(music/section), 1 AmbientSound, **2 Content**, 3 ObjectSet, **4 ExitR / 5 ExitL / 6 ExitD / 7 ExitU**, 8 DataPointer, 9 ExitPosition, 10 TopTiles, 11 BottomTiles, 12 ScreenColor, 13 SpritesColor, 14 Unknown, **15 Event**. Chapter base addrs: Ch1 `$039695`, Ch2 `$039EC5`, Ch3 `$03A755`, Ch4 `$03B0E5`, Ch5 `$03BB25`; addr = `base + index*16`.

---

## traversal_abilities

```yaml
traversal_abilities:
  - id: oprin_spell
    enables: "reveal hidden doors/staircases/buildings (Event 0x20/0x22 screens); ACTIVATE time doors"
    rom_representation: "spell-known flag $0322 (SpellFlagOPRIN); learned at level 1 (always held). MP cost 5."
    confidence: HIGH (flag) / MEDIUM (which screens require it)
    source: "labels.csv $0322; magic/README.md; puzzles/README.md L9-13"

  - id: faruk_underwater
    enables: "underwater breathing -> reach sunken Horen (present) + Aqua Palace approach from North Cape (Ch1)"
    rom_representation: "ally recruit flag Faruk = $033E (nonzero=recruited). Also combat flag $03F4 (Gilzade/2x-dmg, separate)."
    confidence: HIGH (flag addr) / MEDIUM (underwater-traversal effect is GUIDE_SOURCED, routine untraced)
    source: "party/README.md L62 ($033E Faruk); chapter_1_map.md L78-88"

  - id: supica_desert_guide
    enables: "navigate the maze-like HP-drain desert west of Malart (Ch2) — impassable/lost without Supica leading"
    rom_representation: "Supica party flag address NOT documented [UNKNOWN]. Recruited via Content 0x82 (Ch2)."
    confidence: MEDIUM (behavior GUIDE_SOURCED; whether it mechanically blocks exits or is purely navigational is UNKNOWN)
    source: "party/README.md L24; chapter_2_map.md L64-72,94,118-119"

  - id: holy_robe_lava
    enables: "survive Lava Cape volcanic hazard screens (Ch4 past)"
    rom_representation: "HOLYROBE boolean at $0305. Provided by ally Gubibi (recruit flag $0339)."
    confidence: HIGH (item flag $0305 + Gubibi flag $0339) / MEDIUM (lava-bypass effect GUIDE_SOURCED, no traced routine)
    source: "economy/items_registry.md $0305; party/README.md L62 ($0339 Gubibi); chapter_4_map.md L58,86,93"

  - id: armor_tiers
    enables: "damage reduction (NOT a documented hard-gate bypass)"
    rom_representation: "$0302: 0=none, 1=R-ARMOR (1/2 dmg), 2=L-ARMOR/Armor-of-Light (1/4 dmg). Applied in damage sub $A43E (quarter if $0302==2)."
    confidence: HIGH
    source: "items_registry.md $0302; labels.csv 5,A43E; REVERSE.md L685-688"

  - id: pukin_cimaron_rod_light
    enables: "light dark mazes (Ch3) — requires Saint class + Pukin/Cimaron Rod"
    rom_representation: "Pukin party flag NOT documented [UNKNOWN]; rod level $030E."
    confidence: MEDIUM (GUIDE_SOURCED)
    source: "party/README.md L26; puzzles/README.md L43"
```

---

## Per-Chapter Findings

```yaml
- chapter: 1   # Water World Mooroon (131 screens, base $039695, 47 past)
  regions: [Mooroon-present-overworld, Aqua-Palace-dungeon, Towns(Meshudo/Rudoria/Horen/Poponoll), Past-overworld, South-Maze]
  acquirables:
    - {id: oprin_spell,  type: spell, obtained_at: "level 1 (start)",            unlocks_terrain: oprin_doors+time_doors, rom_representation: "$0322 flag", confidence: HIGH, source: "magic/README.md; labels.csv"}
    - {id: coronya,      type: ally,  obtained_at: "Ch1 start (party index 0)",  rom_representation: "flag addr UNKNOWN; detects hidden staircases; needed w/ OPRIN to use time doors", confidence: MEDIUM, source: "party/README.md L18; time_travel/README.md L6"}
    - {id: faruk,        type: ally,  obtained_at: "Horen (PAST era), Content 0x81 Ch1", unlocks_terrain: underwater, rom_representation: "$033E recruit flag", confidence: HIGH(flag)/MEDIUM(effect), source: "party/README.md L19,62; chapter_1_map.md L36,67"}
    - {id: kebabu,       type: ally,  obtained_at: "Horen (past) Content 0x83 Ch1", rom_representation: "$033D recruit flag; Mirror Shield+Ring", confidence: HIGH(flag), source: "party/README.md L20,62"}
    - {id: cygnus_formation, type: formation, obtained_at: "Rudoria (past) Magic University", rom_representation: "TB action code $01 GYGATORN", confidence: MEDIUM, source: "magic/README.md L86; chapter_1_map.md L63"}
    - {id: simitar_sword, type: weapon, obtained_at: "Chapter 1 (story)", rom_representation: "$0332 equipped sword=tier2", confidence: HIGH, source: "items_registry.md L186-187"}
    - {id: flame_rod,    type: weapon, obtained_at: "Chapter 1", rom_representation: "$030E rod level=2", confidence: HIGH, source: "items_registry.md L197"}
  gates:
    - gate_id: ch1_timedoor_present
      from: "screen 26 (present)"; to: "past era (screen 64 region)"
      requires: [coronya, oprin_spell]
      mechanism: time_door
      rom_representation: "screen26.content==0xC0; screen64.content==0xC0 (past-side return). Era by PAST_SCREEN_INDICES {0x25-0x4A,0x69-0x71}."
      confidence: HIGH(encoding)/MEDIUM(requirement)
      source: "time_door_screens.json; time_travel/README.md L22,37"
    - gate_id: ch1_faruk_underwater     # THE Faruk->Horen gate
      from: "present overworld / North Cape"; to: "sunken Horen + Aqua Palace approach"
      requires: [faruk]
      mechanism: "logical traversal ability (underwater); Horen present-era node is graph-disconnected until Faruk. NOTE: 'Faruk obtained in PAST Horen unlocks PRESENT Horen' — repo phrases the canonical gate as Faruk->Horen."
      rom_representation: "Faruk flag $033E. Underwater-passability routine UNTRACED. Spatially: North Cape Event 0x07/0x47 (jump) screens."
      confidence: MEDIUM
      source: "chapter_1_map.md L39,78,85-88; party/README.md L19"
    - gate_id: ch1_aqua_palace_boss
      from: "Aqua Palace"; to: "Gilga boss"
      requires: [faruk]
      mechanism: boss_stage_content (Content 0x21/0x22 Gilga phases; Event 0x09/0x48)
      rom_representation: "boss screens global {118,127,128}; victory 129"
      confidence: HIGH(encoding)
      source: "content_types.md L20-21; navigation boss set; puzzles/README.md L22"
  win_condition:
    description: "Defeat Water Demon Gilga in Aqua Palace, rescue Princess Ashelato"
    goal: "reach + clear boss Content 0x21/0x22 screens"
    requires: [faruk]
    confidence: MEDIUM (GUIDE_SOURCED critical path; boss-screen encoding HIGH)
    source: "chapter_1_map.md L59-68"

- chapter: 2   # Desert World Alalart (137 screens, base $039EC5, 44 past)
  regions: [Desert-overworld(HP-drain maze), Dark-Palace-dungeon, Towns(Malart/Copanes/Alart-past/Sudari), Past-forest, Underground-Prison]
  acquirables:
    - {id: supica, type: ally, obtained_at: "Alart (PAST) Content 0x82 Ch2", unlocks_terrain: desert-maze, rom_representation: "party flag UNKNOWN", confidence: MEDIUM, source: "party/README.md L21; chapter_2_map.md L64"}
    - {id: epin,   type: ally, obtained_at: "inside Dark Palace, Content 0x83 Ch2", rom_representation: "$033B recruit flag; Whistle forces Curly out of statue form", confidence: HIGH(flag), source: "party/README.md L22,62; chapter_2_map.md L69"}
    - {id: libra_formation, type: formation, obtained_at: "Alart (past) Magic University", rom_representation: "TB action $03 MONIBURN", confidence: MEDIUM, source: "magic/README.md; chapter_2_map.md L66"}
    - {id: raincom_greatmagic, type: great_magic, obtained_at: "Alart (past) Magic University", rom_representation: "single-use, $03E0-$03E4 region (see CONFLICT note)", confidence: MEDIUM, source: "magic/README.md L172; chapter_2_map.md L66"}
    - {id: dragoon_sword, type: weapon, obtained_at: "Chapter 2", rom_representation: "$0332 tier3", confidence: HIGH, source: "items_registry.md L187"}
    - {id: stardust_rod,  type: weapon, obtained_at: "Chapter 2", rom_representation: "$030E rod level=3", confidence: HIGH, source: "items_registry.md L198"}
  gates:
    - gate_id: ch2_timedoor_oprin_hidden
      from: "Copanes screen 1 (present)"; to: "past forest (screen 79 region)"
      requires: [oprin_spell, coronya]
      mechanism: "time_door (Content 0xC0) that is OPRIN-HIDDEN (not visible until OPRIN cast)"
      rom_representation: "screen1.content==0xC0; screen79.content==0xC0. PAST set {0x38-0x5D,0x70,0x78-0x7C}. Hidden-reveal routine UNTRACED."
      confidence: HIGH(encoding)/MEDIUM(hidden+requirement)
      source: "chapter_2_map.md L60-85; time_door_screens.json"
    - gate_id: ch2_supica_desert      # THE Supica->desert gate
      from: "Malart / east desert"; to: "west desert -> Dark Palace"
      requires: [supica]
      mechanism: "logical navigational gate — maze-like desert impassable/un-navigable without Supica as guide. Whether exits are mechanically blocked or merely confusing is UNKNOWN."
      rom_representation: "Supica party flag UNKNOWN; desert HP-drain is tile/screen hazard (mechanism UNKNOWN). NO per-screen require-Supica byte."
      confidence: MEDIUM(behavior)/encoding UNKNOWN
      source: "chapter_2_map.md L64-72,94,118-119"
    - gate_id: ch2_curly_boss
      from: "Dark Palace"; to: "Demon Curly"
      requires: [epin]
      mechanism: "boss_stage_content (Content 0x23/0x24); HARD ally gate — Epin's Whistle forces Curly out of invulnerable statue form, REQUIRED to win"
      rom_representation: "boss screens {264,265}; victory 266. Statue/hidden state candidate = enemy id $15/$17 + SILUETTE flag $054F&$10 (Velver/Whistle reveals). [LOW link]"
      confidence: HIGH(boss encoding)/MEDIUM(epin requirement NARRATIVE_CRITICAL)
      source: "party/README.md L109-119; content_types.md L22-23; magic/README.md L154-155,216"
  win_condition:
    description: "Defeat Demon Curly (needs Epin's Whistle), rescue Princess Ishutal"
    goal: "clear Content 0x23/0x24 boss screens"
    requires: [supica, epin]
    confidence: MEDIUM
    source: "chapter_2_map.md L59-72"

- chapter: 3   # Forest World Samalkand (153 screens, base $03A755, 48 FUTURE)
  regions: [Forest-overworld-present, Frozen-Palace-dungeon, Dark-Maze/Maze-of-Darkness, Towns(Nubia/Kasimeel/Passora/Fairy-future), Frozen-future-overworld]
  acquirables:
    - {id: mustafa, type: ally, obtained_at: "Passora Content 0x8x Ch3, costs 100 Rupias", rom_representation: "party flag UNKNOWN; reveals real Troll", confidence: MEDIUM, source: "party/README.md L25; chapter_3_map.md L38,62"}
    - {id: pukin,   type: ally, obtained_at: "Supapa@Nubia transforms Cimaron Fruit", unlocks_terrain: dark-maze-light, rom_representation: "party flag UNKNOWN", confidence: MEDIUM, source: "party/README.md L23; chapter_3_map.md L53,63-64"}
    - {id: cimaron_rod, type: weapon, obtained_at: "Chapter 3", rom_representation: "$030E rod level=4; lights dark mazes w/ Saint+Pukin", confidence: HIGH(item)/MEDIUM(light effect), source: "items_registry.md L199; puzzles/README.md L43"}
    - {id: aries_sirius_formations, type: formation, obtained_at: "Kasimeel Magic University", rom_representation: "TB actions TORNADOR/STARDON", confidence: MEDIUM, source: "chapter_3_map.md L64"}
    - {id: kashim_sword, type: weapon, obtained_at: "Chapter 3", rom_representation: "$0332 tier4", confidence: HIGH, source: "items_registry.md L188"}
  gates:
    - gate_id: ch3_timedoor_future
      from: "screen 50 (present)"; to: "FUTURE (+30y) screen 75 region"
      requires: [oprin_spell, coronya]
      mechanism: "time_door (Content 0xC0) — only chapter with FORWARD travel"
      rom_representation: "screen50.content==0xC0; screen75.content==0xC0. FUTURE set {0x33-0x5A,0x8C-0x93}."
      confidence: HIGH(encoding)/MEDIUM(requirement)
      source: "chapter_3_map.md L93-98; time_door_screens.json"
    - gate_id: ch3_dark_maze
      from: "forest overworld"; to: "Frozen Palace approach via Dark Maze"
      requires: [pukin]  # + Saint class for Cimaron Rod light (GUIDE)
      mechanism: "maze with invisible-wall hazards (Event 0x80/0xC0 maze events). Cimaron Rod/Pukin lights it."
      rom_representation: "maze ParentWorld 0x58 (Ch3); Event 0x80 MAZE_PUZZLE / 0xC0 MAZE_SPECIAL. Light mechanic UNTRACED."
      confidence: MEDIUM
      source: "puzzles/README.md L40-43; content_types.md L129-130; chapter_3_map.md L51,88"
    - gate_id: ch3_troll_boss
      from: "Frozen Palace"; to: "Winter Demon Troll"
      requires: [mustafa, pukin]
      mechanism: "boss_stage_content (Content 0x25/0x26); Pukin identifies real Troll among 4-5 decoys; Mustafa BANNED from palace interior (ROM screen-restriction, mechanism UNKNOWN)"
      rom_representation: "boss screens {401,402}; victory 403. Mustafa-ban encoding UNKNOWN."
      confidence: HIGH(boss encoding)/MEDIUM(ally logic)
      source: "chapter_3_map.md L45,66-68,87; content_types.md L24-25; puzzles/README.md L24"
  win_condition:
    description: "Defeat Winter Demon Troll (needs Mustafa+Pukin), rescue Princess Roxanne"
    goal: "clear Content 0x25/0x26 boss screens"
    requires: [mustafa, pukin]
    confidence: MEDIUM
    source: "chapter_3_map.md L58-69"

- chapter: 4   # Flower World Celestern (164 screens, base $03B0E5, 84 past — largest)
  regions: [Present-overworld(3 zones), Fire-Palace-dungeon, Yufla-Palace-past(optional 3F), Towns(Yufla/Pao/Chigris present; Farvil/Lava past), Lava-Cape]
  acquirables:
    - {id: gubibi, type: ally, obtained_at: "Yufla (present) Content 0x80 Ch4", unlocks_terrain: lava-cape, rom_representation: "$0339 recruit flag; provides Holy Robe", confidence: HIGH(flag), source: "party/README.md L27,62; chapter_4_map.md L39,65"}
    - {id: holy_robe, type: equipment, obtained_at: "from Gubibi (also buyable: MAGIC shop 0x76/0x79, 200 Rupias)", unlocks_terrain: lava, rom_representation: "$0305 HOLYROBE boolean", confidence: HIGH, source: "items_registry.md L163,256-257; economy"}
    - {id: rainy,  type: ally, obtained_at: "Lava town (PAST) Ch4", rom_representation: "$033C recruit flag; rain draws Salamander out of fire-field — REQUIRED for boss. HARD GATE: player must be Fighter class at recruit or game-over", confidence: HIGH(flag)/HIGH(narrative-critical), source: "party/README.md L28,62,109-119; chapter_4_map.md L66-68"}
    - {id: kaitos_moscom_formations, type: formation, obtained_at: "Pao Magic University", rom_representation: "TB actions THUNDERN/Moscom-greatmagic", confidence: MEDIUM, source: "chapter_4_map.md L69"}
    - {id: rostam_sword, type: weapon, obtained_at: "Yufla Palace (past, optional 3F)", rom_representation: "$0332 tier5", confidence: HIGH, source: "items_registry.md L189; chapter_4_map.md L50,75"}
    - {id: crystal_rod, type: weapon, obtained_at: "Pao (Ch4)", rom_representation: "$030E rod level=5", confidence: HIGH, source: "items_registry.md L200; chapter_4_map.md L40"}
  gates:
    - gate_id: ch4_holy_robe_lava     # THE Holy Robe->Lava Cape gate
      from: "past volcanic overworld"; to: "Lava Cape -> Lava town (Rainy) / Yufla Palace"
      requires: [holy_robe]  # via gubibi
      mechanism: "hazard_terrain — lava hazard tiles damage/block without Holy Robe ($0305). Conditional path gate."
      rom_representation: "lava = hazard tiles {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC} on TileSections; $0305 negates (GUIDE). Bypass routine UNTRACED. Also: Gubibi ALLY banned from lava-area screens (ROM flag, mechanism UNKNOWN)."
      confidence: HIGH(hazard+item encoding)/MEDIUM(bypass effect GUIDE_SOURCED)
      source: "chapter_4_map.md L58,86,93,95; world/README.md L90; items_registry.md $0305"
    - gate_id: ch4_timedoor
      from: "screen 2 (present)"; to: "past volcanic (screen 56 region)"
      requires: [oprin_spell, coronya]
      mechanism: time_door (Content 0xC0)
      rom_representation: "screen2.content==0xC0; screen56.content==0xC0. PAST set {0x35-0x5D,0x68-0x8E} (84 screens)."
      confidence: HIGH(encoding)/MEDIUM(requirement)
      source: "chapter_4_map.md L102-106; time_door_screens.json"
    - gate_id: ch4_salamander_boss
      from: "Fire Palace"; to: "Fire Demon Salamander"
      requires: [rainy]
      mechanism: "boss_stage_content (Content 0x27/0x28); Rainy's rain draws Salamander from invulnerable fire-field — REQUIRED. Rainy has finite MP risk."
      rom_representation: "boss screens {560,561}; victory 562. Salamander disasm $BA99/bank12. Fire-field 127 iter ROM 0x18A2E."
      confidence: HIGH(boss encoding)/MEDIUM(rainy requirement)
      source: "chapter_4_map.md L49,63-72; content_types.md L26-27; navigation/README.md L130-155"
  win_condition:
    description: "Defeat Fire Demon Salamander (needs Rainy's rain), rescue King Feisal"
    goal: "clear Content 0x27/0x28 boss screens"
    requires: [gubibi/holy_robe, rainy]
    confidence: MEDIUM
    source: "chapter_4_map.md L63-73"

- chapter: 5   # Evil Magician's Realm (154 screens, base $03BB25, 29 past — fewest; most linear)
  regions: [Corrupted-overworld, Underground-Maze(14 stairways), Sabaron's-Palace, Airosche-Dark-World, inherited-Towns(Yufla/Pao/Chigris), Light-Palace-past]
  acquirables:
    - {id: hassan, type: ally, obtained_at: "Yufla (present) Content 0x81 Ch5", rom_representation: "$033F recruit flag; strongest fighter; Dragon formation w/ Faruk", confidence: HIGH(flag), source: "party/README.md L29,62; chapter_5_map.md L39,67"}
    - {id: isfa_rod, type: weapon, obtained_at: "Sabaron's Palace — answer password CORONYA", unlocks_terrain: required-for-final, rom_representation: "$030E rod level=6. Password CORONYA = bank2 secret table $AC27 entry1 (when $04D0==1)", confidence: HIGH, source: "items_registry.md L201; chapter_5_map.md L52,71,93; password_system.md L196-205"}
    - {id: legend_sword, type: weapon, obtained_at: "Chapter 5", rom_representation: "$0332 tier6", confidence: HIGH, source: "items_registry.md L190"}
    - {id: libcom_greatmagic, type: great_magic, obtained_at: "Ch5", rom_representation: "$03E0-$03E4 region (Great Magic, see CONFLICT)", confidence: MEDIUM, source: "magic/README.md L177; REVERSE.md L655"}
  gates:
    - gate_id: ch5_password_isfa     # THE OPRIN/password->item gate analog (NOTE: prompt's 'OPRIN->time door' = generic time-door gate; Ch5's distinctive gate is the CORONYA password)
      from: "Sabaron's Palace mid"; to: "deeper palace + Isfa Rod"
      requires: [password_CORONYA_event]
      mechanism: "event_script_progress_flag — password answer is a story-scripted event (bank-2 VM opcode 12 / secret table), NOT a WorldScreen byte. Unlocks Isfa Rod."
      rom_representation: "secret password CORONYA at bank2 $AC27 (tiles $32 $3E $41 $3E $3D $48 $30), checked by VM op12 $AC7C. Isfa = $030E=6."
      confidence: HIGH(password encoding)/MEDIUM(gate placement)
      source: "password_system.md L196-205; chapter_5_map.md L71,93,118; script_vm.md L57"
    - gate_id: ch5_underground_maze
      from: "corrupted overworld"; to: "Sabaron's Palace via Underground Maze"
      requires: []  # funnel; heavy stairway network
      mechanism: "stairway network (14 Event 0x40 screens, 4 clean pairs + 6 orphans) + maze ParentWorld 0x5D"
      rom_representation: "stairway screens {36,37,40,46,47,49,50,55,56,57,62,64,65,114+}"
      confidence: HIGH(encoding)
      source: "chapter_5_map.md L106-108; stairway_pairs.json"
    - gate_id: ch5_goragora_final
      from: "Airosche Dark World"; to: "Archdemon GoraGora (final boss)"
      requires: [isfa_rod, bolttor3_spell, ritual_moon_sun_hexagram]
      mechanism: "boss_stage_content (Content 0x29/0x2A) + scripted ritual tile sequence (moon->sun->hexagram). Ritual encoding UNKNOWN."
      rom_representation: "boss screens {632,640,650,738}. Bolttor3 = $0325 flag (L17). Isfa $030E=6. Ritual NOT byte-encoded/UNTRACED."
      confidence: HIGH(boss/item encoding)/MEDIUM(ritual)
      source: "chapter_5_map.md L64-76,93-94; puzzles/README.md L26; content_types.md L28-29"
  win_condition:
    description: "Defeat Archdemon GoraGora at Airosche after moon/sun/hexagram ritual"
    goal: "clear Content 0x29/0x2A final boss screens"
    requires: [hassan, isfa_rod, bolttor3_spell]
    confidence: MEDIUM
    source: "chapter_5_map.md L64-76; puzzles/README.md L26"
```

---

## The Four Named Gates — full specification

```yaml
named_gates:
  - id: Faruk_to_Horen     # = ch1_faruk_underwater
    chapter: 1
    requires: Faruk ally (recruited in PAST-era Horen, Content 0x81)
    effect: "underwater breathing -> present-era sunken Horen + Aqua Palace approach from North Cape become reachable"
    rom_representation:
      acquire_flag: "$033E (Faruk recruit, nonzero=recruited) [HIGH]"
      gate_encoding: "NOT a WorldScreen byte. Horen-present node is graph-disconnected until Faruk; underwater-passability is a runtime code check — ROUTINE UNTRACED [gap]"
      spatial_anchors: "North Cape jump screens Event 0x07/0x47 [HIGH encoding]"
    confidence: MEDIUM
    source: "party/README.md L19,62; chapter_1_map.md L39,67,78,85-88; content_types.md L118,125"

  - id: Supica_to_Desert   # = ch2_supica_desert
    chapter: 2
    requires: Supica ally (recruited in PAST-era Alart, Content 0x82)
    effect: "navigate maze-like HP-drain desert west of Malart toward Dark Palace; impassable/un-navigable without Supica guide"
    rom_representation:
      acquire_flag: "Supica party flag NOT documented [UNKNOWN — gap]"
      gate_encoding: "NOT byte-encoded. Desert is HP-drain hazard + navigational maze; whether exits are mechanically blocked w/o Supica or merely confusing is UNKNOWN [gap]"
    confidence: MEDIUM (behavior) / encoding UNKNOWN
    source: "party/README.md L21,24; chapter_2_map.md L64-72,94,118-119"

  - id: OPRIN_to_TimeDoor  # = generic time-door activation; sharpest in Ch2 (hidden door)
    chapter: all (esp. 2)
    requires: OPRIN spell ($0322, always held from L1) + Coronya ally
    effect: "activate Time Door (Content 0xC0); in Ch2 the present-side door is INVISIBLE until OPRIN is cast"
    rom_representation:
      acquire_flag: "OPRIN spell flag $0322 [HIGH]; Coronya flag UNKNOWN"
      gate_encoding: "Time Door = Content byte 0xC0 [HIGH]. OPRIN-hidden-door screens carry Event 0x20/0x22 [HIGH]. The reveal/activation routine (what consumes OPRIN, how a hidden 0xC0 is shown) is UNTRACED [gap]"
      anchors: "10 door screens in time_door_screens.json, all content==0xC0"
    confidence: HIGH (encoding) / MEDIUM (activation requirement is GUIDE_SOURCED)
    source: "time_travel/README.md L6,26; content_types.md L40,122-123; chapter_2_map.md L85,92; puzzles/README.md L9-13"

  - id: HolyRobe_to_LavaCape  # = ch4_holy_robe_lava
    chapter: 4
    requires: Holy Robe ($0305) — provided by ally Gubibi ($0339); also buyable at MAGIC shop (200 Rupias)
    effect: "survive Lava Cape volcanic hazard screens -> reach Lava town (Rainy) + Yufla Palace (Rostam Sword)"
    rom_representation:
      acquire_flag: "HOLYROBE boolean $0305 [HIGH]; Gubibi recruit flag $0339 [HIGH]"
      gate_encoding: "Lava = hazard tiles {0x2F,0x30,0x3F,0x40,0x41,0x42,0x6F,0xEC} in TileSection render [HIGH]. $0305-negates-lava-damage is GUIDE_SOURCED; the lava-damage routine that reads $0305 is UNTRACED [gap]. Separately, ally Gubibi is ROM-banned from lava-area screens (encoding UNKNOWN)."
    confidence: HIGH (hazard + item flag) / MEDIUM (bypass effect)
    source: "chapter_4_map.md L58,86,93,95; world/README.md L85-90; items_registry.md $0305; party/README.md L27,62"
```

---

## Progress / Inventory RAM map (the validator's "have-item" oracle) [HIGH unless noted]

Source: `economy/items_registry.md` correction block, `party/README.md`, `progression/README.md`, `labels.csv`, `password_system.md`.

| RAM | Meaning | Cap | Notes |
|-----|---------|-----|-------|
| `$0082` | ChapterIndex 0-4 | — | selects per-chapter scaling |
| `$0089-$008B` | Rupia (BCD H/T/O) | 999 | the real currency |
| `$0300`/`$0301` | progress level / party progress | 9 | warp-table writes these (Ch0-4 = 3..7); also two unidentified @40-Rupia shop items |
| `$0302` | Armor level | 2 | 0/1=R-ARMOR(½)/2=L-ARMOR Armor-of-Light(¼) |
| `$0305` | HOLYROBE | bool | **lava traversal** |
| `$0303` M-SHIELD, `$0304` M-BOOTS | equipment | bool | |
| `$0306` BREAD / `$0307` MASHROOB | consumables | 10 | |
| `$0308` KEY / `$0309` AMULET | quest | 9 | |
| `$030E` | Rod level | 1-6 | Rod/Flame/Stardust/Cimaron/Crystal/Isfa |
| `$030F-$0311` | ROD/FLAME/STARDUST ammo | 5/5/15 | item IDs 1-3 |
| `$0322` | OPRIN flag / Magic level base | — | spell-known flags `$0322-$0331` |
| `$0323-$0325` | Bolttor1/2/3 | — | L3/11/17 |
| `$0326-$0328` | Flamol1/2/3 | — | L7/14/23 |
| `$0332` | Equipped sword ID/tier | 1-6 | item IDs 9-14 |
| `$0337` GunMeca, `$0339` Gubibi, `$033B` Epin, `$033C` Rainy, `$033D` Kebabu, `$033E` Faruk, `$033F` Hassan | ally recruit flags | nonzero=recruited | **Coronya/Supica/Pukin/Mustafa/Gun-Meca... flag addrs partly UNKNOWN** |
| `$03E0-$03E4` | special/event items (5) | — | **CONFLICT: items_registry=Battle/Restore/Screen/Ceremony/Magic event triggers; REVERSE.md=5 Great Magic LIBCOM/MONECOM/MOSCOM/RAINCOM/SPRICOM. Same region either way.** |
| `$03FA/$03FB/$03FC` | Eclipse state / countdown | 0x0C=yes | gates Rupia-Seed planting, Great Magic, casino |

Warp/state-init table `$BB1F` (50×7 records, password_system.md): writes `$0084` screen-pos (4/9/14/19/24 per chapter), `$0089` chapter number (1-5), `$0300`/`$0301` progress, `$0302` armor — confirming these are the canonical chapter-progress state bytes. [HIGH]

---

## OPEN_QUESTIONS  (count: 14)

Headline: **the repo documents gate ENCODING (screen bytes) and the have-item RAM map, but never disassembled the gate-CHECK routines for the four logical gates** — so item-conditional reachability must be hand-modeled, not auto-derived from ROM.

1. **Faruk underwater-passability routine** — what code makes Horen-present / Aqua-Palace screens reachable only when `$033E`≠0? Resolve by tracing the screen-transition / collision code that reads `$033E`. [gate: Faruk→Horen]
2. **Supica party-flag RAM address** — not documented. And: is the desert-west gate mechanical (exits blocked) or purely navigational? Trace Ch2 desert screen exit-resolution + Supica flag. [gate: Supica→desert]
3. **OPRIN time-door reveal/activation routine** — how a hidden Content 0xC0 (Ch2) is shown and what consumes the OPRIN cast; the code that checks Coronya+OPRIN before allowing time travel. [gate: OPRIN→time door]
4. **Holy-Robe lava-damage bypass routine** — confirm the lava-hazard damage code reads `$0305` to skip damage. Currently GUIDE_SOURCED only. [gate: Holy Robe→Lava]
5. **Ally-ban screen restriction encoding** — Gubibi (lava), Mustafa (Troll palace), Armor-of-Light (Sabaron's castle): flag vs screen-list vs content-byte check? Routine untraced.
6. **`$03E0-$03E4` identity CONFLICT** — Great Magic items (REVERSE.md 2026-06-12) vs event-action triggers (items_registry 2026-06-15). Re-trace handlers `$9659/$966A/$96AE/$96B9/$9725`.
7. **Coronya / Pukin / Mustafa / Gun-Meca / Epin-partial party-flag addresses** — needed to model ally-gated reachability for those allies. (party/README known-unknowns)
8. **Era-membership data extraction for the validator** — PAST_SCREEN_INDICES live in randomizer enums.py, not the ROM screen bytes; confirm whether they are derivable from ROM or must be imported as a constant table.
9. **Ch2 / Ch5 orphan stairways** — non-bidirectional destinations: are these genuine one-way edges (affect reachability) or a different mechanism? (stairway_pairs.json orphans)
10. **OPRIN-hidden building/service inventory** — full per-chapter list of which buildings/screens are OPRIN-gated (only Ch2 Sudari + Ch2 time door confirmed).
11. **Ch5 final-boss ritual encoding** — moon/sun/hexagram tile sequence: not byte-encoded; how is it scripted/checked?
12. **CORONYA password gate placement** — is the Isfa-Rod password checked via the bank-2 dialog VM (op12 $AC7C / table $AC27) at a specific screen, or a special event byte? (chapter_5_map known-unknown L118)
13. **Building-interior sub-graphs** — `0xFE` enters an interior, but interior screen relationships / where Content maps to interior layout are not byte-mapped — interiors are opaque to a WorldScreen-only static parse.
14. **Whether any exit bytes are modified at runtime** (e.g., a gate "opening" an exit after an event) — navigation/README open-question; would mean static exit bytes under-count or over-count edges.
