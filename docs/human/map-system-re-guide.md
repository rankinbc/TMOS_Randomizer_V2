# Reverse engineering The Magic of Scheherazade's map system

**No complete disassembly exists for this game**, but substantial technical resources combined with NES hardware knowledge provide a strong foundation for reverse engineering its ~750-screen map system. The game uses the MMC3 mapper with approximately 256KB PRG-ROM and 128KB CHR-ROM, enabling sophisticated bank-switching for large world data.

## Existing RE resources provide critical starting points

The **TMoSRandomizer** project (GitHub: synthpopisback/TMoSRandomizer) contains C# source code with documented ROM offsets for randomizable elements including overworld enemy locations, shop/hotel/mosque positions, item placements, and companion locations. The `Tmos.Romhacks.Core` directory likely contains specific hex offset definitions that would accelerate map data identification.

TAS documentation from TASVideos provides **RAM memory addresses** for enemy HP and critical gameplay variables. More significantly, it documents frame rules that reveal screen transition mechanics:

- **16-frame framerule**: Screen transitions (entering/leaving towns, palaces, shops, mosques, staircases, carpet rides, time doors)
- **14-frame fixed delay**: Ordinary screen transitions
- **8-frame framerule**: After turn-based encounters

The existence of a Spanish translation hack confirms that text pointer tables have been located. The Cutting Room Floor documents unused graphics and a hidden sound test (password "SOUN D"), indicating some internal structure has been mapped.

## The PPU renders screens through nametables and pattern tables

Understanding how the NES PPU works is essential for identifying map data in ROM. The PPU maintains a **16KB address space** completely separate from the CPU:

| PPU Address | Content |
|-------------|---------|
| **$0000-$0FFF** | Pattern Table 0 (256 tiles × 16 bytes) |
| **$1000-$1FFF** | Pattern Table 1 (256 tiles × 16 bytes) |
| **$2000-$23BF** | Nametable 0 (32×30 tile indices = 960 bytes) |
| **$23C0-$23FF** | Attribute Table 0 (64 bytes for palette data) |
| **$2400-$27FF** | Nametable 1 + Attribute Table 1 |

Each hardware tile is **8×8 pixels, 16 bytes** encoded as two bitplanes. Bytes 0-7 contain the low bits of each pixel's 2-bit color index; bytes 8-15 contain the high bits. The attribute table assigns palettes in 2×2 tile (16×16 pixel) blocks—each byte controls a 4×4 tile area using 2 bits per quadrant.

## Metatile systems are almost certainly used

With **~750 screens** and severe ROM constraints, raw nametable storage (960 bytes × 750 = ~703KB) would be impossible. The game almost certainly uses **16×16 pixel metatiles** (2×2 hardware tiles), reducing each screen to approximately 240 bytes before compression.

A typical metatile definition table structure for this era:

```
Metatile_TL:  .db $45, $53, $b4, ...  ; Top-left tile indices
Metatile_TR:  .db $46, $54, $b5, ...  ; Top-right tile indices  
Metatile_BL:  .db $47, $55, $b6, ...  ; Bottom-left tile indices
Metatile_BR:  .db $48, $56, $b7, ...  ; Bottom-right tile indices
Metatile_Attr: .db $00, $01, $02, ... ; Palette (2 bits) + collision flags
```

When reverse engineering, search for sequences of 256 bytes that appear to be tile indices (values $00-$FF) repeated in groups of 4 with similar patterns. The metatile definitions typically reside in a fixed bank for quick access during rendering.

## Screen data likely uses RLE compression with pointer tables

Late-1980s NES RPGs commonly used **run-length encoding** with row or column pointers for random access. The Final Fantasy/Dragon Warrior approach provides a likely model:

**Pointer table structure:**
- 16-bit little-endian pointers, one per row (or per screen)
- Pointers stored at a fixed ROM address for each world/chapter
- Point to CPU addresses ($8000+) that must be converted to ROM offsets

**RLE encoding patterns to search for:**
- Values $00-$7F: Single metatile of that index
- Values $80-$FE: (value XOR $80) = metatile, next byte = repeat count
- $FF: Row/screen terminator

Alternatively, the game might use **column-based encoding** like Zelda 1, where each screen is defined by 16 column indices that reference predefined vertical strips. This would result in exactly **16 bytes per screen** plus column definition tables.

## MMC3 bank switching enables 256KB+ ROM organization

The MMC3 mapper provides flexible bank switching critical for understanding ROM layout:

| CPU Address | Function |
|-------------|----------|
| **$8000-$9FFF** | 8KB switchable PRG bank (or fixed to second-last) |
| **$A000-$BFFF** | 8KB switchable PRG bank |
| **$C000-$DFFF** | 8KB switchable (or fixed to second-last) |
| **$E000-$FFFF** | 8KB fixed to last bank (reset/NMI handlers here) |

**Mapper registers:**
- **$8000**: Bank select (bits 0-2 select which of 8 bank registers)
- **$8001**: Bank data value
- **$A000**: Mirroring control (bit 0: 0=vertical, 1=horizontal)

**Likely ROM organization for map data:**
- Fixed bank at $E000: Core engine, decompression routines, bank-switching code
- Switchable banks: Map/level data organized by chapter (5 chapters = likely 1-2 banks each)
- Separate CHR banks: Tilesets swapped per area type (overworld, dungeon, town, underwater)

## Where to search for map data in ROM

Based on similar games' structures, investigate these ROM regions:

**Pointer tables** (look for sequences of 16-bit values in $80xx-$Bxxx range):
- Chapter/world pointer table: Likely in fixed bank ($E000-$FFFF area of ROM)
- Screen pointer table: Within each chapter's data bank
- Metatile definition pointers: Usually in a commonly-loaded bank

**Map data signatures:**
- Repeated byte patterns with values < $40 (typical metatile counts)
- Sequences ending in $FF (RLE terminators)
- 16-byte aligned blocks (possible fixed-size screen data)
- Byte pairs where second byte varies 1-8 (RLE runs)

**Useful hex editor searches:**
- Search for sequences of 4 consecutive similar values (metatile quads)
- Look for $FF bytes at regular intervals (screen boundaries)
- Find pointer tables by searching for little-endian addresses pointing to nearby data

## Screen transitions reveal data organization

The TAS-documented **16-frame and 14-frame transition rules** indicate the game uses discrete screen loading rather than continuous scrolling. This suggests:

1. Screens are self-contained data units, not streamed from larger maps
2. Transition code loads a complete screen during the animation delay
3. Adjacent screen relationships stored in a separate connectivity table

**Flip-screen implementation pattern:**
```
1. Read player exit direction
2. Look up destination screen index from connectivity table
3. Bank-switch to screen's data bank if needed
4. Decompress screen metatiles to RAM buffer
5. Copy metatile tiles to PPU nametables during VBlank
6. Update attribute table for new screen's palettes
```

Look for a **screen connectivity table** that maps each screen to its 4 neighbors (up/down/left/right). This would be 4 bytes per screen × ~750 screens = ~3KB, likely stored contiguously.

## Practical reverse engineering approach

Begin by identifying the **NMI handler** (at the vector address $FFFA-$FFFB in the last PRG bank). Trace backward from screen drawing routines to find:

1. **Decompression routine**: Called after screen transitions, takes a screen ID and fills a RAM buffer
2. **Metatile expansion**: Converts metatile indices to 4 tile indices for nametable updates
3. **Pointer table dereferencing**: Code that reads from fixed addresses to locate screen data

Use Mesen or FCEUX with debugging features to:
- Set write breakpoints on PPU nametable addresses ($2000-$2400)
- Watch which ROM banks are active during screen loads
- Log bank-switch writes to $8000/$8001 during transitions
- Capture metatile buffer in RAM after decompression

**ROM hash for verification:** The US version should match SHA-1 `6A280A9BCF01D756EBDA46F5158080FADEE6A737`.

## Crystalis provides the best reference implementation

SNK's **Crystalis** (1990) uses identical hardware (MMC3, 256KB PRG, 256KB CHR) and has an extensively documented ROM map:

- `$00010-$1000F`: Map screens (256 × $100 bytes each)
- `$10010-$1300F`: Map tileset patterns (12 × $400 bytes)
- `$13310-$13E0F`: Map collision flags (11 × $100 bytes)
- `$14310-$14507`: Area data pointers (252 × 2 bytes)

A complete **Crystalis disassembly** exists on GitHub (crystalisdisassembly/crystalisdisassembly) that can serve as a structural template for Magic of Scheherazade analysis.

## Key unknowns requiring original analysis

Several critical details have not been publicly documented:

- Exact compression algorithm used (RLE variant, column-based, or custom)
- ROM offsets for metatile definition tables
- Screen connectivity/adjacency data location
- Chapter-specific bank assignments
- Collision data format and location
- Sprite/enemy placement data format (separate from background tiles)

The **synthpopisback** randomizer author and TAS community Discord represent the best contacts for undocumented technical knowledge. The randomizer's ability to modify locations confirms these data structures have been at least partially decoded in the source code.