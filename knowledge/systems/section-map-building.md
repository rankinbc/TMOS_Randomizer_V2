# Section Map Building

**Last Updated**: 2026-01-24
**Sources**: projects/TMOS_Randomizer_V2 codebase, navigation analysis
**Confidence**: HIGH

---

## Overview

A section map is a visual grid representation of multiple WorldScreens arranged according to their navigation connections. This document describes how to build section maps that display all tiles for each WorldScreen.

---

## Key Concepts

### WorldScreen Navigation

Each WorldScreen has 4 navigation fields (bytes 4-7):

| Field | Byte | Direction | Blocked Value |
|-------|------|-----------|---------------|
| `nav_right` | 4 | Move right | 0xFF |
| `nav_left` | 5 | Move left | 0xFF |
| `nav_down` | 6 | Move down | 0xFF |
| `nav_up` | 7 | Move up | 0xFF |

Navigation values are screen indices within the same chapter (0-255). Value `0xFF` (255) means no exit in that direction.

### Parent World (Section ID)

The `parent_world` field (byte 0) groups screens into sections:

| Value | Section Type |
|-------|--------------|
| 0x00 | Overworld |
| 0x01 | Town |
| 0x02 | Dungeon |
| 0x03 | Maze |
| 0x04 | Special |
| 0x05 | Boss |

---

## Building the Navigation Map

### Algorithm: BFS Grid Placement

```python
def build_navigation_map(screens: List[ScreenData]) -> Dict[int, Position]:
    """
    Build a 2D position map from screen navigation data.
    Uses breadth-first search starting from screen 0.
    """
    positions = {}
    visited = set()

    if not screens:
        return positions

    # Start from screen 0 at origin
    queue = [(0, 0, 0)]  # (screen_index, x, y)

    while queue:
        index, x, y = queue.pop(0)

        if index in visited:
            continue
        visited.add(index)

        screen = find_screen(screens, index)
        if not screen:
            continue

        positions[index] = Position(x, y)

        NAV_BLOCKED = 0xFF

        # Enqueue neighbors based on navigation
        if screen.nav_right != NAV_BLOCKED:
            if screen.nav_right not in visited:
                queue.append((screen.nav_right, x + 1, y))

        if screen.nav_left != NAV_BLOCKED:
            if screen.nav_left not in visited:
                queue.append((screen.nav_left, x - 1, y))

        if screen.nav_down != NAV_BLOCKED:
            if screen.nav_down not in visited:
                queue.append((screen.nav_down, x, y + 1))

        if screen.nav_up != NAV_BLOCKED:
            if screen.nav_up not in visited:
                queue.append((screen.nav_up, x, y - 1))

    # Handle disconnected screens - place in row at bottom
    disconnected_x = 0
    max_y = max((p.y for p in positions.values()), default=0) + 2

    for screen in screens:
        if screen.index not in positions:
            positions[screen.index] = Position(disconnected_x, max_y)
            disconnected_x += 1

    return positions
```

### Normalizing Positions

After BFS, positions may have negative coordinates. Normalize to start at (0, 0):

```python
def normalize_positions(positions: Dict[int, Position]) -> Dict[int, Position]:
    """Shift all positions so minimum x,y = (0, 0)."""
    if not positions:
        return positions

    min_x = min(p.x for p in positions.values())
    min_y = min(p.y for p in positions.values())

    return {
        index: Position(p.x - min_x, p.y - min_y)
        for index, p in positions.items()
    }
```

---

## Building a Section-Specific Map

To build a map showing only screens from one section (parent_world):

```python
def build_section_map(chapter: ChapterData, section_id: int) -> SectionMap:
    """
    Build a map for a specific section (parent_world value).
    Shows all screens belonging to that section arranged by navigation.
    """
    # 1. Filter screens by parent_world
    section_screens = [s for s in chapter.screens if s.parent_world == section_id]

    # 2. Build navigation map for filtered screens
    raw_positions = build_navigation_map(section_screens)

    # 3. Normalize to (0, 0) origin
    positions = normalize_positions(raw_positions)

    # 4. Calculate grid dimensions
    grid_width = max((p.x for p in positions.values()), default=0) + 1
    grid_height = max((p.y for p in positions.values()), default=0) + 1

    return SectionMap(
        section_id=section_id,
        screens=section_screens,
        positions=positions,
        width=grid_width,
        height=grid_height
    )
```

---

## Rendering the Grid

### NES Screen Dimensions

| Property | Value |
|----------|-------|
| Width | 256 pixels |
| Height | 224 pixels |
| Aspect Ratio | 256:224 = 1.143:1 |

### Grid Cell Sizing

```python
# Base tile size (configurable)
tile_width = 64  # pixels

# Maintain NES aspect ratio
tile_height = round(tile_width * (224 / 256))  # = 56 pixels
```

### Rendering Each Screen

```typescript
function renderSectionMap(sectionMap: SectionMap, tileWidth: number) {
  const tileHeight = Math.round(tileWidth * (224 / 256));

  return (
    <div
      style={{
        position: 'relative',
        width: sectionMap.width * tileWidth,
        height: sectionMap.height * tileHeight,
      }}
    >
      {sectionMap.screens.map(screen => {
        const pos = sectionMap.positions[screen.index];

        return (
          <div
            key={screen.index}
            style={{
              position: 'absolute',
              left: pos.x * tileWidth,
              top: pos.y * tileHeight,
              width: tileWidth,
              height: tileHeight,
            }}
          >
            <ScreenTile screen={screen} />
          </div>
        );
      })}
    </div>
  );
}
```

### Tile Image Rendering

Each screen displays its tile image based on `top_tiles` index:

```typescript
function ScreenTile({ screen }: { screen: ScreenData }) {
  // Convert tile index to hex filename
  const hex = screen.top_tiles.toString(16).toUpperCase().padStart(2, '0');
  const tileUrl = `/tiles/${hex}.png`;

  return (
    <img
      src={tileUrl}
      alt={`Screen ${screen.index}`}
      style={{
        width: '100%',
        height: '100%',
        objectFit: 'cover',
        imageRendering: 'pixelated',  // Preserve pixel art
      }}
    />
  );
}
```

---

## Full Section Map with All Tiles

To show **all tiles** (both top and bottom) for each screen:

### Option 1: Composite Pre-rendered Images

Pre-render combined top+bottom TileSection images:

```python
def generate_screen_image(screen: WorldScreen, rom: bytes) -> Image:
    """Generate full screen image from top and bottom TileSections."""

    # Get TileSection addresses
    top_addr = get_tilesection_address(screen.top_tiles, screen.top_bank)
    bottom_addr = get_tilesection_address(screen.bottom_tiles, screen.bottom_bank)

    # Read TileSection data (32 bytes each)
    top_data = rom[top_addr:top_addr + 32]
    bottom_data = rom[bottom_addr:bottom_addr + 32]

    # Create 256x224 image
    image = Image.new('RGB', (256, 224))

    # Render top 4 rows (rows 0-3 of top TileSection)
    for row in range(4):
        for col in range(8):
            tile_id = top_data[row * 8 + col]
            render_tile(image, col, row, tile_id)

    # Render bottom 2 rows (rows 0-1 of bottom TileSection)
    for row in range(2):
        for col in range(8):
            tile_id = bottom_data[row * 8 + col]
            render_tile(image, col, row + 4, tile_id)

    return image
```

### Option 2: Stacked Top/Bottom Images

Display top and bottom tiles as separate layers:

```typescript
function FullScreenTile({ screen }: { screen: ScreenData }) {
  const topUrl = `/tiles/${screen.top_tiles.toString(16).padStart(2, '0')}.png`;
  const bottomUrl = `/tiles/${screen.bottom_tiles.toString(16).padStart(2, '0')}.png`;

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      {/* Top 4/6 of screen */}
      <img
        src={topUrl}
        style={{
          position: 'absolute',
          top: 0,
          width: '100%',
          height: '67%',  // 4/6 = 67%
          objectFit: 'cover',
          objectPosition: 'top',
          imageRendering: 'pixelated',
        }}
      />
      {/* Bottom 2/6 of screen */}
      <img
        src={bottomUrl}
        style={{
          position: 'absolute',
          bottom: 0,
          width: '100%',
          height: '33%',  // 2/6 = 33%
          objectFit: 'cover',
          objectPosition: 'top',
          imageRendering: 'pixelated',
        }}
      />
    </div>
  );
}
```

---

## Section Map Data Structure

```typescript
interface SectionMap {
  section_id: number;           // parent_world value
  section_type: string;         // 'overworld', 'town', etc.
  screens: ScreenData[];        // All screens in this section
  positions: Map<number, Position>;  // screen_index -> grid position
  width: number;                // Grid width in cells
  height: number;               // Grid height in cells
}

interface Position {
  x: number;  // Grid column (0-based)
  y: number;  // Grid row (0-based)
}

interface ScreenData {
  index: number;
  parent_world: number;
  top_tiles: number;
  bottom_tiles: number;
  datapointer: number;
  nav_right: number;
  nav_left: number;
  nav_down: number;
  nav_up: number;
  // ... other fields
}
```

---

## Example: Building Chapter 1 Section Maps

```python
# Load chapter data
chapter = rom_reader.read_chapter(1)  # 131 screens

# Get unique sections in this chapter
sections = set(s.parent_world for s in chapter.screens)
# Result: {16, 32, 64, 83, 96, 97, 176, 192, 208}

# Build map for each section
for section_id in sections:
    section_map = build_section_map(chapter, section_id)
    print(f"Section {section_id}: {len(section_map.screens)} screens, "
          f"{section_map.width}x{section_map.height} grid")
```

---

## Code References

| Component | File |
|-----------|------|
| Navigation map builder | `projects/TMOS_Randomizer_V2/ui/src/components/screen/NavigationMapView.tsx:18-77` |
| Screen renderer | `projects/TMOS_Randomizer_V2/ui/src/components/screen/ScreenRenderer.tsx` |
| Chapter data model | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/chapter.py` |
| WorldScreen model | `projects/TMOS_Randomizer_V2/src/tmos_randomizer/core/worldscreen.py` |

---

## Related Documents

- [tile-rendering.md](tile-rendering.md) - Full tile rendering pipeline
- [navigation.md](navigation.md) - Screen navigation system
- [../structures/worldscreen.md](../structures/worldscreen.md) - WorldScreen structure
- [../structures/tilesection.md](../structures/tilesection.md) - TileSection structure

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation with full section map building documentation |
