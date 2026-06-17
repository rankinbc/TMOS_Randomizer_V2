# The Magic of Scheherazade (NES, 1987 Culture Brain) — Progression & Gating Logic

**Purpose:** Human-logic layer for a static, item-gated reachability validator for a map
randomizer. Documents per chapter what items/keys/allies/spells/events are REQUIRED,
WHERE each is obtained, and WHICH transition each unlocks. ROM byte/address encoding is
out of scope (researched separately).

**Date:** 2026-06-17
**Confidence tags:** HIGH = corroborated by 2+ independent sources / explicit in a detailed
walkthrough; MEDIUM = single detailed walkthrough, logically consistent, not independently
confirmed; LOW = inferred or sources unclear.

**Primary sources:**
- FO = Flying Omelette walkthrough (most detailed; per-chapter pages) — https://flyingomelette.com/mos/guide.html (+ guide_part1..5.html)
- HG101 = Hardcore Gaming 101 — https://www.hardcoregaming101.net/the-magic-of-scheherazade/
- TONL = Take on the NES Library #145 — https://takeontheneslibrary.com/finished/145-the-magic-of-scheherazade/
- ACRPG = The RPG Consoler blog (endgame detail) — http://allconsolerpgs.blogspot.com/2012/05/game-9-magic-of-scheherazade-nes.html
- SW = StrategyWiki chapter pages (titles/town names via search snippets; pages 403 to direct fetch) — https://strategywiki.org/wiki/The_Magic_of_Scheherazade
- Hoz = Hoz's 8-bit NES Quest (OPRIN/eclipse mechanics) — https://hoz14nes.wordpress.com/2021/01/08/the-magic-of-scheherazade/

---

## GLOBAL MECHANICS (apply across all chapters)

### Chapter / world list (HIGH — SW titles + FO)
| Chapter | World name | Theme | Final boss (demon) | Princess rescued |
|---|---|---|---|---|
| 1 | Mooroon   | Water  | Gilga       | Ashelato (FO) |
| 2 | Alalart   | Desert | Curly       | Ishutal (FO) |
| 3 | Samalkand | Forest | Troll (Winter Demon) | Roxanne (FO) |
| 4 | Celestern | Flower | Salamander  | (rescues King Feisal, not a princess) (FO) |
| 5 | (Sabaron) | —      | Goragora / Sabaron | Scheherazade (the real one) |

Each of chapters 1–4 follows the same template: explore towns → recruit allies → gather
items/spells → find the world's Palace → defeat its demon → (rescue captive). Chapter 5 is
the endgame assault on Sabaron's palace. (HIGH — TONL, HG101, FO all agree on the template.)

### OPRIN spell (HIGH — FO, Hoz, TONL, search corroboration)
- **OPRIN** is a reveal spell the player possesses (effectively from the start of each chapter).
  Cast on the correct overworld screen it reveals a HIDDEN STAIRCASE / door.
- Coronya (the cat-girl time spirit companion) **alerts the player when a hidden staircase is
  nearby on a screen** — i.e., she is the in-game hint that OPRIN should be used here.
- A revealed staircase may lead to: a Time Door, a Wise Man / NPC, a Magic University, an
  Underground Maze, an MP Star, a buried item, or a Rupia-seed plot.
- **Gating implication for the validator:** any node reached only through an OPRIN-revealed
  staircase is reachable as long as the player has reached that screen (OPRIN is always
  available). OPRIN itself is NOT a scarce gating item; the staircase locations are the graph
  edges.

### Time Doors (HIGH — HG101, TONL, FO, Hoz)
- Each world has PRESENT and a second era (PAST, or in Ch4 a deep PAST "3000 years"; one
  source phrases it as past/future depending on chapter). The alternate era is "same layout,
  different environment" (compared to A Link to the Past). (HG101)
- A Time Door is a specific OPRIN-revealed staircase; entering it swaps the player to the
  other era of the same world. (HIGH)
- **No scarce item gates Time Door usage** in the sources reviewed — you need to (a) reach the
  screen and (b) use OPRIN (always available). Coronya flags the location. (MEDIUM — absence of
  a gate is asserted by HG101's "could have refined"; no walkthrough lists a key for the door.)
- Cross-era dependency: items/allies/spells obtained in one era are required to progress in the
  other (e.g., recruit in past → use ability in present). This makes the era graph a single
  connected reachability space per chapter, joined at Time Door edges.

### Alalart Solar Eclipse (ASE) (HIGH — FO, Hoz, search)
- A scripted timed event ("the sun is eclipsed"). During the ASE:
  - Certain **high-level "Great Spells" (e.g., MONECOM, SPRICOM, LIBCOM) only work during the
    eclipse.** (HIGH)
  - **Rupia Seed → Rupia Tree:** plant a Rupia's Seed in a Magic Field in the PAST during the
    eclipse; travel to the PRESENT and the same spot yields a money tree (hundreds of coins).
    (HIGH — Hoz, FO)
- For the validator: ASE is a recurring time window, not a one-way gate, but the seed→tree
  money loop and the eclipse-only spells are sequencing constraints (need eclipse active).

### Gating mechanism vocabulary confirmed in-game (HIGH — TONL, FO)
- "Keys open locked doors." (TONL explicit)
- "Horns can help you fight some gatekeepers" — **Horn** items bypass/neutralize the
  stone-gargoyle gatekeepers guarding palace doors; alternative is to fight them. (TONL, FO)
- NPC blockers that only act/join after a flag (visited past, recognized as Isufa's heir, etc.).
- Impassable terrain neutralized by a traversal item/ally (water↔Faruk, lava↔Holy Robe,
  maze-desert↔Supica). (FO)
- Class requirement gates (must be Fighter / Magician / Saint for a recruit or room). (FO)
- Payment/shop gates (pay Imam for a class; hire a mercenary ally for Rupias). (FO)
- Boss-defeat gates (palace boss must die to clear the chapter / unlock the password). (FO)
- Password/teleport gates (chapter-complete passwords; in-palace puzzle "passwords" like the
  Pillar Room). (FO, ACRPG)

---

## traversal_abilities  (top-level)

```yaml
traversal_abilities:
  - id: faruk_swim
    item_or_ally: Faruk (ally)
    effect: "Party can safely enter/swim water; enables reaching the sunken/underwater Aqua Palace"
    acquired_chapter: 1
    acquired_at: "Horen (past) — joins automatically, recognizes hero as Isufa's descendant"
    unlocks_terrain: water
    confidence: HIGH        # FO; cross-checked vs TONL terrain-gate pattern
    source_url: https://flyingomelette.com/mos/guide_part1.html

  - id: magic_boots
    item_or_ally: Magic Boots (item)
    effect: "Required to recruit Supica; prerequisite for the maze-desert traversal chain"
    acquired_chapter: 2
    acquired_at: "From Lah in Alart (past), after answering NO to his question"
    unlocks_terrain: "(indirect) enables Supica recruit -> maze desert"
    confidence: MEDIUM      # FO only
    source_url: https://flyingomelette.com/mos/guide_part2.html

  - id: supica_desert_guide
    item_or_ally: Supica (flying-monkey ally)
    effect: "Guides party through the repeating maze-desert (present) that blocks westward travel to Sudari"
    acquired_chapter: 2
    acquired_at: "Underground Maze prison (past, west of Alart); needs Magic Boots + Gun Meca in party"
    unlocks_terrain: "maze desert (navigational gate)"
    confidence: HIGH        # FO detailed; desert-gate pattern corroborated by TONL
    source_url: https://flyingomelette.com/mos/guide_part2.html

  - id: raincom_desert
    item_or_ally: RAINCOM (spell)
    effect: "Temporarily turns desert into normal overworld; prevents HP loss while crossing desert"
    acquired_chapter: 2     # also reusable / re-learnable in ch4
    acquired_at: "Ch2: Wise Man E of Malart (OPRIN). Ch4: Wise Man's chamber (past)"
    unlocks_terrain: "desert (HP-damage mitigation, not a hard wall)"
    confidence: MEDIUM      # FO; convenience more than hard gate
    source_url: https://flyingomelette.com/mos/guide_part2.html

  - id: holy_robe_lava
    item_or_ally: Holy Robe (item)
    effect: "Lava protection; required to cross the Lava Cape / lava terrain to reach Lava town"
    acquired_chapter: 4
    acquired_at: "Fire Palace (present) — Gubibi joins / gives Holy Robe (reached via OPRIN)"
    unlocks_terrain: lava
    confidence: HIGH        # FO + ACRPG ('Holy Robe enables Lava town access') + TONL terrain pattern
    source_url: https://flyingomelette.com/mos/guide_part4.html
```

---

## gating_mechanisms_catalog  (top-level)

```yaml
gating_mechanisms_catalog:
  - id: locked_door_key
    description: "A locked door opened by a specific Key item. 'Keys open locked doors.'"
    confidence: HIGH
    source_url: https://takeontheneslibrary.com/finished/145-the-magic-of-scheherazade/
  - id: gargoyle_gatekeeper
    description: "Stone-gargoyle gatekeepers block palace doors; bypass with a Horn item or defeat them in combat."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: terrain_traversal_item
    description: "Impassable terrain (water/lava/maze-desert) requires a traversal item or ally (Faruk/Holy Robe/Supica)."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: time_door
    description: "OPRIN-revealed staircase that swaps PRESENT<->alternate era of the same world; Coronya flags location. No scarce item gates its use."
    confidence: HIGH
    source_url: https://www.hardcoregaming101.net/the-magic-of-scheherazade/
  - id: oprin_hidden_staircase
    description: "Hidden staircases/doors revealed only by casting OPRIN on the correct screen (lead to Time Doors, NPCs, items, mazes)."
    confidence: HIGH
    source_url: https://hoz14nes.wordpress.com/2021/01/08/the-magic-of-scheherazade/
  - id: npc_flag_blocker
    description: "An NPC only acts/joins after a story flag is set (visited past era, recognized as Isufa's heir, spoke to a prior NPC, etc.)."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: class_requirement
    description: "A recruit, room, or boss requires the hero to be a specific class (Fighter/Magician/Saint), set via Mosque payment or a *COM transform spell."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: payment_shop_gate
    description: "Pay Rupias to the Imam/Mosque for a class, or hire a mercenary ally (e.g., Mustafa 100 Rupias) — currency gate."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: boss_defeat_gate
    description: "World palace boss must be defeated to clear the chapter and reveal the next-chapter password."
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide.html
  - id: eclipse_window
    description: "Alalart Solar Eclipse: timed window during which Great Spells (MONECOM/SPRICOM/LIBCOM) work and Rupia seeds grow into money trees across time."
    confidence: HIGH
    source_url: https://hoz14nes.wordpress.com/2021/01/08/the-magic-of-scheherazade/
  - id: in_palace_puzzle_gate
    description: "Scripted in-dungeon puzzle (e.g., Ch5 Pillar Room moon/sun/star sequence) that must be solved to reach the boss; RING bails you out if stuck."
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part5.html
```

---

## CHAPTER 1 — Water World Mooroon  (boss: Gilga)

```yaml
chapter: 1
world: Mooroon
regions:
  - Meshudo            # starting town (present)
  - Rudoria            # town (present & past); has Magic University in past
  - Poponoll           # town (present)
  - Horen              # town: thriving in PAST, sunken/underwater in PRESENT
  - North Cape         # present coast; water-entry point
  - Magic Field        # past; Rupia-seed plot
  - Aqua Palace        # present, underwater; chapter dungeon/boss

acquirables:
  - id: weapon_rod_or_sword
    type: item
    obtained_at: "Meshudo shop"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: coronya
    type: ally
    obtained_at: "Time Door (answer YES to Coronya's question)"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: faruk
    type: ally
    obtained_at: "Horen (past); joins automatically as Isufa's descendant"
    unlocks_terrain: water
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: monecom
    type: spell
    obtained_at: "Wise Man in Underground Maze (past); great-spell, works during eclipse"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: horn
    type: item
    obtained_at: "Reward via MONECOM (duplicated during Solar Eclipse)"
    confidence: MEDIUM   # FO; mechanism (duplication) single-source
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: mirror_shield
    type: item
    obtained_at: "Kebabu, present Horen"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: kebabu
    type: ally
    obtained_at: "Horen (present); answer NO to her question"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - id: rupias_seed
    type: item
    obtained_at: "Shop (Meshudo); plant in Magic Field (past) during eclipse -> money tree in present"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html

gates:
  - gate_id: ch1_time_door
    from: "Rudoria area (present)"
    to: "Rudoria/Horen (past)"
    requires: [oprin, reach_pier_screen]   # plus Exp Level ~2 to survive (soft)
    mechanism: time_door
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - gate_id: ch1_water_to_aquapalace
    from: "North Cape (present)"
    to: "Aqua Palace (underwater, present) / sunken Horen"
    requires: [faruk_swim]
    mechanism: terrain_traversal_item
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - gate_id: ch1_palace_gargoyles
    from: "Aqua Palace entry"
    to: "Aqua Palace interior (toward Gilga)"
    requires: [horn]            # OR defeat gargoyles in combat
    mechanism: gargoyle_gatekeeper
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html
  - gate_id: ch1_boss_gilga
    from: "Aqua Palace interior"
    to: "Chapter 2 (password)"
    requires: [defeat_gilga]    # mirror_shield strongly aids (reflects Stone spell)
    mechanism: boss_defeat_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part1.html

win_condition:
  description: "Defeat Gilga in the Aqua Palace; rescue Princess Ashelato; receive Chapter 2 password."
  goal: defeat_boss
  requires: [faruk_swim, defeat_gilga]   # Horn or combat for gargoyles; mirror_shield recommended
  confidence: HIGH
  source_url: https://flyingomelette.com/mos/guide_part1.html
```

---

## CHAPTER 2 — Desert World Alalart  (boss: Curly)

```yaml
chapter: 2
world: Alalart
regions:
  - Malart             # starting town (present)
  - Copanes            # town (present); Gun Meca lives here
  - Alart              # town in PAST (Peke Peke language); has Magic University
  - Sudari             # town reached past the maze-desert; hire Troopers
  - Maze Desert        # repeating-screen maze west of Malart (present); navigational gate
  - Dark Palace        # chapter dungeon/boss
  - Magic Field        # past (SW of Copanes); Rupia-seed plot

acquirables:
  - id: raincom
    type: spell
    obtained_at: "Wise Man E of Malart (OPRIN)"
    unlocks_terrain: desert
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: gun_meca
    type: ally
    obtained_at: "Copanes (present); joins only AFTER visiting past Alart; translates Peke Peke"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: magic_boots
    type: item
    obtained_at: "Lah in Alart (past); answer NO"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: supica
    type: ally
    obtained_at: "Underground Maze prison (past, W of Alart); needs Magic Boots + Gun Meca in party"
    unlocks_terrain: "maze desert"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: epin
    type: ally
    obtained_at: "Dark Palace hidden room; MUST recruit BEFORE fighting boss Curly"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - id: dragoon_sword
    type: item
    obtained_at: "Magic University, Alart (past) — optional"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part2.html

gates:
  - gate_id: ch2_time_door
    from: "near Copanes (present)"
    to: "Alart (past)"
    requires: [oprin, reach_timedoor_screen]   # 7 S, 1 E of Copanes
    mechanism: time_door
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_gunmeca_flag
    from: "Copanes (present)"
    to: "Gun Meca recruited"
    requires: [visited_past_alart]
    mechanism: npc_flag_blocker
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_supica_recruit
    from: "Underground Maze prison (past)"
    to: "Supica recruited"
    requires: [magic_boots, gun_meca]
    mechanism: npc_flag_blocker
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_maze_desert
    from: "west of Malart (present)"
    to: "Sudari / Dark Palace approach"
    requires: [supica_desert_guide]
    mechanism: terrain_traversal_item
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_palace_gargoyles
    from: "Dark Palace entry"
    to: "Dark Palace interior"
    requires: [horn]            # OR fight gargoyles
    mechanism: gargoyle_gatekeeper
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_boss_epin_prereq
    from: "Dark Palace"
    to: "winnable Curly fight"
    requires: [epin]            # without Epin the boss is unbeatable; RING bails you out early
    mechanism: npc_flag_blocker
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html
  - gate_id: ch2_boss_curly
    from: "Dark Palace final room"
    to: "Chapter 3 (password)"
    requires: [defeat_curly]
    mechanism: boss_defeat_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part2.html

win_condition:
  description: "Recruit Epin, then defeat Curly's true form in the Dark Palace; rescue Princess Ishutal."
  goal: defeat_boss
  requires: [supica_desert_guide, epin, defeat_curly]
  confidence: HIGH
  source_url: https://flyingomelette.com/mos/guide_part2.html
```

---

## CHAPTER 3 — Forest World Samalkand  (boss: Troll / Winter Demon)

```yaml
chapter: 3
world: Samalkand
regions:
  - Nubia              # starting town
  - Kasimeel           # town; Magic University + Mosque (buy Saint class)
  - Passora            # town; hire Mustafa
  - Frozen Palace      # chapter dungeon/boss
  - Magic Field        # future Samalkand; SPRICOM
  - Cimaron Tree       # past; gives Pukin + CIMARON Rod via CHOCOLA password

acquirables:
  - id: saint_class
    type: event       # class change
    obtained_at: "Pay Imam 40 Rupias, Kasimeel mosque"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: chocola_password
    type: password
    obtained_at: "Cimaron Tree dialogue (requires Saint class)"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: cimaron_rod
    type: item
    obtained_at: "Cimaron Tree (past), with CHOCOLA"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: pukin
    type: ally
    obtained_at: "Cimaron Tree (past); Cimaron Fruit converted to living Pukin (via Supapa)"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: spricom
    type: spell
    obtained_at: "Magic Field, future Samalkand; eclipse great-spell; converts winter->spring"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - id: mustafa
    type: ally
    obtained_at: "Passora; hire for 100 Rupias"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html

gates:
  - gate_id: ch3_saint_for_cimaron
    from: "approach to Cimaron Tree"
    to: "Cimaron Tree dialogue (Pukin + CIMARON Rod)"
    requires: [saint_class]
    mechanism: class_requirement
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - gate_id: ch3_saint_payment
    from: "Kasimeel mosque"
    to: "Saint class"
    requires: [rupias_40]
    mechanism: payment_shop_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - gate_id: ch3_mustafa_hire
    from: "Passora"
    to: "Mustafa in party"
    requires: [rupias_100]
    mechanism: payment_shop_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html
  - gate_id: ch3_boss_troll
    from: "Frozen Palace"
    to: "Chapter 4 (password)"
    requires: [mustafa, defeat_troll]   # 'You can't beat Troll without his help'
    mechanism: boss_defeat_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part3.html

win_condition:
  description: "Defeat the Winter Demon Troll in the Frozen Palace (Mustafa required); rescue Princess Roxanne."
  goal: defeat_boss
  requires: [mustafa, defeat_troll]
  confidence: HIGH
  source_url: https://flyingomelette.com/mos/guide_part3.html
```

---

## CHAPTER 4 — Flower World Celestern  (boss: Salamander)

```yaml
chapter: 4
world: Celestern
regions:
  - Yufla              # town (FO names Yufla/Pao/Chigris — see OPEN_QUESTIONS on world name)
  - Pao                # town; Magic University (Crystal Rod)
  - Chigris            # town; Mosque (Fighter class)
  - Fire Palace        # contains Gubibi (Holy Robe) + Time Door
  - Farvil             # PAST era (3000 years past); Lava town; Mosque
  - Lava Cape          # lava terrain gating Lava town
  - Lava town          # past; recruit Rainy
  - Yufla Palace       # chapter dungeon/boss (Salamander)

acquirables:
  - id: crystal_rod
    type: item
    obtained_at: "Magic University, Pao"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: gubibi
    type: ally
    obtained_at: "Fire Palace (present), reached via OPRIN"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: holy_robe
    type: item
    obtained_at: "Fire Palace — from/with Gubibi"
    unlocks_terrain: lava
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: rainy
    type: ally
    obtained_at: "Lava town (past); answer NO to both questions; must be Fighter class; provides rain vs Salamander"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: moscom
    type: spell
    obtained_at: "Yufla Palace Floor 3 (through a locked door); grants Magician transform"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - id: rostam_sword
    type: item
    obtained_at: "Yufla Palace Floor 2"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part4.html

gates:
  - gate_id: ch4_lava_cape
    from: "Lava Cape (overworld)"
    to: "Lava town"
    requires: [holy_robe_lava]
    mechanism: terrain_traversal_item
    confidence: HIGH       # FO + ACRPG ('Holy Robe enables Lava town access')
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - gate_id: ch4_time_door
    from: "past Fire Palace"
    to: "Farvil (3000 years past)"
    requires: [oprin, reach_timedoor_screen]
    mechanism: time_door
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - gate_id: ch4_rainy_fighter
    from: "Lava town (past)"
    to: "Rainy recruited"
    requires: [fighter_class]
    mechanism: class_requirement
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - gate_id: ch4_palace_locked_door
    from: "Yufla Palace Floor 3"
    to: "MOSCOM chamber"
    requires: [key_or_progression]   # 'through a locked door'; no key item named
    mechanism: locked_door_key
    confidence: LOW
    source_url: https://flyingomelette.com/mos/guide_part4.html
  - gate_id: ch4_boss_salamander
    from: "Yufla Palace boss room"
    to: "Chapter 5 (password)"
    requires: [rainy, crystal_rod, defeat_salamander]  # Rainy's rain breaks the Fire Field
    mechanism: boss_defeat_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part4.html

win_condition:
  description: "Defeat Salamander in Yufla Palace (Rainy + Crystal Rod required); rescue King Feisal."
  goal: defeat_boss
  requires: [holy_robe_lava, rainy, crystal_rod, defeat_salamander]
  confidence: HIGH
  source_url: https://flyingomelette.com/mos/guide_part4.html
```

---

## CHAPTER 5 — Evil Magician Sabaron  (final boss: Goragora)

```yaml
chapter: 5
world: (Sabaron's realm; reuses Celestern-area towns Yufla/Pao/Chigris)
regions:
  - Yufla              # recruit Hassan
  - Pao                # Armor of Light is south of Pao (bridge between two trees)
  - Chigris            # LIBCOM door is east of Chigris
  - Fire Palace        # contains Underground Maze + Time Door to Light Palace
  - Light Palace       # past; holds Legend Sword
  - Underground Maze   # contains the Armor-of-Light-locked door to Sabaron's Palace
  - Sabaron's Palace   # endgame; Pillar Room; Goragora
  - Dark World / Pillar Room

acquirables:
  - id: hassan
    type: ally
    obtained_at: "Yufla, after beating Salamander (final party member)"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - id: legend_sword
    type: item
    obtained_at: "Light Palace (past), via Time Door in Fire Palace maze"
    confidence: HIGH       # FO + ACRPG ('fetch quest for legendary armor that unlocks a legendary sword; both needed to enter final area')
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - id: armor_of_light
    type: item
    obtained_at: "Bridge south of Pao (between two trees); given by Kaji after showing Legend Sword"
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - id: libcom
    type: spell
    obtained_at: "Door E of Chigris (OPRIN); eclipse great-spell; revives dead party members"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - id: isfa_rod
    type: item
    obtained_at: "Sabaron's Palace; given by Princess Scheherazade; weapon for final boss"
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part5.html

gates:
  - gate_id: ch5_legend_sword_timedoor
    from: "Fire Palace -> Underground Maze -> Time Door"
    to: "Light Palace (past) -> Legend Sword"
    requires: [oprin, reach_timedoor]
    mechanism: time_door
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - gate_id: ch5_kaji_proof
    from: "Kaji (near Pao)"
    to: "Armor of Light granted"
    requires: [legend_sword]   # proof of being Isufa's heir
    mechanism: npc_flag_blocker
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - gate_id: ch5_sabaron_palace_door
    from: "Underground Maze"
    to: "Sabaron's Palace"
    requires: [armor_of_light]   # door refuses entry without it
    mechanism: locked_door_key   # (item-gated door, not a numeric key)
    confidence: HIGH             # FO + ACRPG (both armor+sword needed to enter final area)
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - gate_id: ch5_pillar_room
    from: "Sabaron's Palace"
    to: "Goragora arena"
    requires: [magician_class, pillar_room_puzzle]   # moon/sun/star shoot sequence; RING bails out
    mechanism: in_palace_puzzle_gate
    confidence: MEDIUM
    source_url: https://flyingomelette.com/mos/guide_part5.html
  - gate_id: ch5_boss_goragora
    from: "Goragora arena"
    to: "Game end"
    requires: [isfa_rod, defeat_goragora]   # BOLTTOR3 to head, ISFA rod on spinning balls
    mechanism: boss_defeat_gate
    confidence: HIGH
    source_url: https://flyingomelette.com/mos/guide_part5.html

win_condition:
  description: "Enter Sabaron's Palace with Legend Sword + Armor of Light, solve the Pillar Room (as Magician), defeat Goragora with ISFA Rod. Game ends; rescue Princess Scheherazade."
  goal: defeat_final_boss
  requires: [legend_sword, armor_of_light, magician_class, isfa_rod, defeat_goragora]
  confidence: HIGH
  source_url: https://flyingomelette.com/mos/guide_part5.html
```

---

## OPEN_QUESTIONS

Count: 9

1. **Ch4 town names vs. world name.** FO's Chapter 4 page names towns Yufla / Pao / Chigris and
   palaces Fire Palace / Yufla Palace, but SW titles call Chapter 4 "Flower World Celestern."
   Sources do not clearly reconcile which town belongs to which world, and Yufla/Pao/Chigris
   reappear in Ch5. Need the SW Ch4 page (currently 403) or a map source to confirm the
   canonical town list and whether Ch4 and Ch5 literally reuse the same overworld.
   Conflicting: FO guide_part4/5 vs SW chapter titles.

2. **Time Door: any hard gate on use?** HG101/TONL/FO imply Time Doors need only OPRIN + Coronya's
   hint (no scarce key). Asserted as "no gate" by absence of evidence, not by a positive
   statement. A randomizer-critical assumption — verify no chapter has an item-gated Time Door.

3. **Ch1 Horn acquisition exact mechanism.** FO says the Horn is obtained as a MONECOM/eclipse
   *duplication* reward; the precise "where is the first Horn found" is fuzzy (single source).
   Also unclear how many Horns exist per chapter vs. needing to fight gargoyles instead.

4. **Ch2 Dark Palace gargoyle gate.** FO mentions Horns are "optional" for the Dark Palace
   gargoyle door (fight as alternative). Whether a Horn is ever strictly REQUIRED (vs. always
   beatable in combat) is unclear — affects whether Horn is a true gate or convenience.

5. **Ch3 SPRICOM vs. Saint-class ordering.** FO lists both SPRICOM (winter→spring) and the Saint
   class / CHOCOLA / Pukin chain, but the strict dependency order (does SPRICOM gate reaching
   the Cimaron Tree, or only the boss?) is not crisply stated. Pukin's role as a required vs.
   optional ally for the Troll fight is also unconfirmed (only Mustafa is stated as mandatory).

6. **Ch3 Pukin / Cimaron Fruit / "Supapa".** The conversion of Cimaron Fruit → living Pukin via
   "Supapa" appears in a single source and the name "Supapa" may be a mis-transcription. Needs
   a second source.

7. **Ch4 Yufla Palace locked door (Floor 3).** FO says "through a locked door" but names no key
   item — could be a story-flag door rather than a key. Mechanism tagged LOW; verify.

8. **Class-change availability per chapter.** Fighter/Magician/Saint requirements appear (Rainy
   needs Fighter, Salamander/Pillar Room need Magician, Cimaron needs Saint). Whether every
   chapter offers all class changes (Mosque + *COM spells) is assumed but not exhaustively
   confirmed; matters if a randomizer can strand a required class.

9. **Princess names / Ch4 captive.** FO gives Ashelato (Ch1), Ishutal (Ch2), Roxanne (Ch3),
   Scheherazade (Ch5), but Ch4 rescues **King Feisal**, not a princess — confirm whether Ch4
   has a princess at all, and verify princess-name spellings (single-source).

### Naming discrepancies noted (not blocking)
- Ch2 town spelling: FO uses both "Malart" and "Alart"/"Alalart" and "Copanes"; some search
  snippets render the world "Alalart." Treat Alart(past)/Malart(present)/Alalart(world) as the
  same world cluster.
- Ch1: search/SW confirm world "Mooroon" and towns Meshudo/Rudoria/Poponoll/Horen/Aqua Palace;
  FO additionally references "North Cape" and "Magic Field." Consistent, just more granular.
```
