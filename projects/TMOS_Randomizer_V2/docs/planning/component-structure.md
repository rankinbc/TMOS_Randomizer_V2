# UI Component Structure

**Created**: 2026-01-24
**Status**: Draft
**Purpose**: Define the component architecture for the TMOS Randomizer V2 UI

---

## Technology Stack

### Recommended: Web-Based (React + Tauri)

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Framework** | React 18+ | Component-based, excellent ecosystem |
| **Language** | TypeScript | Type safety matches Python dataclasses |
| **Styling** | Tailwind CSS | Utility-first, rapid prototyping |
| **State** | Zustand | Lightweight, TypeScript-friendly |
| **Graph Viz** | D3.js / React Flow | Flexible graph rendering |
| **Desktop** | Tauri | Rust-based, smaller than Electron |
| **Build** | Vite | Fast dev server and builds |

### Alternative: Python Desktop (If preferred)

| Layer | Technology |
|-------|------------|
| **Framework** | PyQt6 / PySide6 |
| **Graph Viz** | PyQtGraph / NetworkX + Matplotlib |
| **Packaging** | PyInstaller |

---

## Directory Structure (React/Tauri)

```
tmos-randomizer-ui/
├── src/
│   ├── main.tsx                 # Entry point
│   ├── App.tsx                  # Root component
│   │
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── MainContent.tsx
│   │   │
│   │   ├── chapter/
│   │   │   ├── ChapterSelector.tsx
│   │   │   ├── ChapterCard.tsx
│   │   │   └── SectionBreakdown.tsx
│   │   │
│   │   ├── views/
│   │   │   ├── MapView/
│   │   │   │   ├── MapView.tsx
│   │   │   │   ├── SectionGraph.tsx
│   │   │   │   ├── SectionNode.tsx
│   │   │   │   ├── ConnectionEdge.tsx
│   │   │   │   └── GraphLegend.tsx
│   │   │   │
│   │   │   ├── TilesView/
│   │   │   │   ├── TilesView.tsx
│   │   │   │   ├── SectionGrid.tsx
│   │   │   │   ├── ScreenCell.tsx
│   │   │   │   ├── ScreenPreview.tsx
│   │   │   │   └── TileRenderer.tsx
│   │   │   │
│   │   │   ├── ItemsView/
│   │   │   │   ├── ItemsView.tsx
│   │   │   │   ├── ItemCategory.tsx
│   │   │   │   └── ItemTable.tsx
│   │   │   │
│   │   │   ├── AlliesView/
│   │   │   │   ├── AlliesView.tsx
│   │   │   │   ├── AllyTable.tsx
│   │   │   │   └── AllyDetails.tsx
│   │   │   │
│   │   │   └── ValidationView/
│   │   │       ├── ValidationView.tsx
│   │   │       ├── CheckList.tsx
│   │   │       ├── WarningList.tsx
│   │   │       └── SphereAnalysis.tsx
│   │   │
│   │   ├── modals/
│   │   │   ├── SettingsModal.tsx
│   │   │   ├── LoadROMModal.tsx
│   │   │   └── ExportModal.tsx
│   │   │
│   │   └── common/
│   │       ├── Button.tsx
│   │       ├── TabBar.tsx
│   │       ├── StatusBadge.tsx
│   │       ├── Tooltip.tsx
│   │       └── LoadingSpinner.tsx
│   │
│   ├── hooks/
│   │   ├── useRandomizerStore.ts
│   │   ├── useChapterData.ts
│   │   ├── useSectionGraph.ts
│   │   └── useBackend.ts
│   │
│   ├── store/
│   │   ├── index.ts
│   │   ├── romSlice.ts
│   │   ├── settingsSlice.ts
│   │   ├── planSlice.ts
│   │   └── uiSlice.ts
│   │
│   ├── types/
│   │   ├── randomizer.ts        # From data-contract.md
│   │   ├── settings.ts
│   │   └── ui.ts
│   │
│   ├── utils/
│   │   ├── colors.ts            # Section type colors
│   │   ├── validation.ts
│   │   └── formatters.ts
│   │
│   ├── api/
│   │   ├── backend.ts           # Tauri invoke calls
│   │   └── types.ts
│   │
│   └── styles/
│       ├── index.css            # Tailwind imports
│       └── graph.css            # D3 specific styles
│
├── src-tauri/                   # Rust backend wrapper
│   ├── src/
│   │   ├── main.rs
│   │   └── commands.rs          # Tauri commands
│   └── Cargo.toml
│
├── public/
│   └── assets/
│       └── tiles/               # Tile graphics (if rendering)
│
├── package.json
├── tsconfig.json
├── tailwind.config.js
└── vite.config.ts
```

---

## Core Components

### 1. App.tsx

```tsx
// src/App.tsx
import { Header, Sidebar, MainContent, Footer } from './components/layout';
import { SettingsModal, LoadROMModal, ExportModal } from './components/modals';
import { useRandomizerStore } from './hooks/useRandomizerStore';

export function App() {
  const { modalOpen } = useRandomizerStore();

  return (
    <div className="flex flex-col h-screen bg-gray-900 text-white">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        <Sidebar />
        <MainContent />
      </div>
      <Footer />

      {/* Modals */}
      {modalOpen === 'settings' && <SettingsModal />}
      {modalOpen === 'load' && <LoadROMModal />}
      {modalOpen === 'export' && <ExportModal />}
    </div>
  );
}
```

### 2. ChapterSelector.tsx

```tsx
// src/components/chapter/ChapterSelector.tsx
import { ChapterCard } from './ChapterCard';
import { useRandomizerStore } from '../../hooks/useRandomizerStore';
import type { ChapterPlan } from '../../types/randomizer';

export function ChapterSelector() {
  const { plan, selectedChapter, setSelectedChapter } = useRandomizerStore();

  if (!plan) return <ChapterSelectorSkeleton />;

  return (
    <div className="flex flex-col gap-2 p-4">
      <h2 className="text-lg font-semibold mb-2">Chapters</h2>
      {plan.chapters.map((chapter: ChapterPlan) => (
        <ChapterCard
          key={chapter.chapter_num}
          chapter={chapter}
          isSelected={selectedChapter === chapter.chapter_num}
          onClick={() => setSelectedChapter(chapter.chapter_num)}
        />
      ))}
    </div>
  );
}
```

### 3. ChapterCard.tsx

```tsx
// src/components/chapter/ChapterCard.tsx
import type { ChapterPlan } from '../../types/randomizer';
import { getSectionCounts } from '../../utils/formatters';

interface ChapterCardProps {
  chapter: ChapterPlan;
  isSelected: boolean;
  onClick: () => void;
}

export function ChapterCard({ chapter, isSelected, onClick }: ChapterCardProps) {
  const sectionCounts = getSectionCounts(chapter.sections);

  return (
    <button
      onClick={onClick}
      className={`
        p-3 rounded-lg text-left transition-colors
        ${isSelected
          ? 'bg-blue-600 border-blue-400'
          : 'bg-gray-800 hover:bg-gray-700 border-gray-600'
        }
        border
      `}
    >
      <div className="flex justify-between items-center">
        <span className="font-medium">Chapter {chapter.chapter_num}</span>
        <span className="text-sm text-gray-400">
          {chapter.screen_count} screens
        </span>
      </div>

      <div className="mt-2 flex gap-2 flex-wrap">
        {Object.entries(sectionCounts).map(([type, count]) => (
          <span
            key={type}
            className={`text-xs px-2 py-0.5 rounded ${getSectionColor(type)}`}
          >
            {type}: {count}
          </span>
        ))}
      </div>
    </button>
  );
}
```

---

## View Components

### 4. MapView with D3.js

```tsx
// src/components/views/MapView/MapView.tsx
import { useEffect, useRef } from 'react';
import * as d3 from 'd3';
import { useRandomizerStore } from '../../../hooks/useRandomizerStore';
import { useSectionGraph } from '../../../hooks/useSectionGraph';
import { GraphLegend } from './GraphLegend';
import type { SectionPlan, SectionConnection } from '../../../types/randomizer';

export function MapView() {
  const svgRef = useRef<SVGSVGElement>(null);
  const { selectedChapter, plan } = useRandomizerStore();

  const chapter = plan?.chapters.find(c => c.chapter_num === selectedChapter);
  const { nodes, links } = useSectionGraph(chapter?.sections, chapter?.connections);

  useEffect(() => {
    if (!svgRef.current || !nodes.length) return;

    const svg = d3.select(svgRef.current);
    const width = svgRef.current.clientWidth;
    const height = svgRef.current.clientHeight;

    // Clear previous
    svg.selectAll('*').remove();

    // Create force simulation
    const simulation = d3.forceSimulation(nodes)
      .force('link', d3.forceLink(links).id((d: any) => d.id).distance(100))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(60));

    // Draw links
    const link = svg.append('g')
      .selectAll('line')
      .data(links)
      .enter()
      .append('line')
      .attr('stroke', '#666')
      .attr('stroke-width', 2)
      .attr('marker-end', 'url(#arrowhead)');

    // Draw nodes
    const node = svg.append('g')
      .selectAll('g')
      .data(nodes)
      .enter()
      .append('g')
      .call(d3.drag()
        .on('start', dragstarted)
        .on('drag', dragged)
        .on('end', dragended));

    // Node rectangles
    node.append('rect')
      .attr('width', 100)
      .attr('height', 60)
      .attr('x', -50)
      .attr('y', -30)
      .attr('rx', 8)
      .attr('fill', (d: any) => getSectionFill(d.section_type))
      .attr('stroke', (d: any) => getSectionStroke(d.section_type))
      .attr('stroke-width', 2);

    // Node labels
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', -5)
      .attr('fill', 'white')
      .attr('font-size', '12px')
      .text((d: any) => d.label);

    // Screen count
    node.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', 15)
      .attr('fill', '#ccc')
      .attr('font-size', '10px')
      .text((d: any) => `${d.screen_count} screens`);

    // Update positions on tick
    simulation.on('tick', () => {
      link
        .attr('x1', (d: any) => d.source.x)
        .attr('y1', (d: any) => d.source.y)
        .attr('x2', (d: any) => d.target.x)
        .attr('y2', (d: any) => d.target.y);

      node.attr('transform', (d: any) => `translate(${d.x},${d.y})`);
    });

    function dragstarted(event: any) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }

    function dragged(event: any) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
    }

    function dragended(event: any) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }

    return () => {
      simulation.stop();
    };
  }, [nodes, links]);

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 relative">
        <svg ref={svgRef} className="w-full h-full">
          {/* Arrowhead marker definition */}
          <defs>
            <marker
              id="arrowhead"
              markerWidth="10"
              markerHeight="7"
              refX="10"
              refY="3.5"
              orient="auto"
            >
              <polygon points="0 0, 10 3.5, 0 7" fill="#666" />
            </marker>
          </defs>
        </svg>
      </div>
      <GraphLegend />
    </div>
  );
}

function getSectionFill(type: string): string {
  const colors: Record<string, string> = {
    overworld: '#4CAF50',
    town: '#2196F3',
    dungeon: '#9C27B0',
    maze: '#FF9800',
    boss: '#F44336',
    special: '#607D8B',
  };
  return colors[type] || '#666';
}

function getSectionStroke(type: string): string {
  const colors: Record<string, string> = {
    overworld: '#81C784',
    town: '#64B5F6',
    dungeon: '#CE93D8',
    maze: '#FFB74D',
    boss: '#E57373',
    special: '#90A4AE',
  };
  return colors[type] || '#888';
}
```

### 5. TilesView / ScreenPreview

```tsx
// src/components/views/TilesView/ScreenPreview.tsx
import { useRandomizerStore } from '../../../hooks/useRandomizerStore';
import type { ScreenPlan } from '../../../types/randomizer';

interface ScreenPreviewProps {
  screen: ScreenPlan;
}

export function ScreenPreview({ screen }: ScreenPreviewProps) {
  const { worldscreen } = screen;

  // 8x7 tile grid placeholder
  // In real implementation, this would render actual tile graphics
  const tiles = generateTileGrid(worldscreen.top_tiles, worldscreen.bottom_tiles);

  return (
    <div className="border border-gray-600 rounded-lg p-4">
      <h3 className="text-sm font-medium mb-2">
        Screen Preview (8x7)
      </h3>

      {/* Tile Grid */}
      <div
        className="grid gap-0.5 bg-gray-800 p-1 rounded"
        style={{ gridTemplateColumns: 'repeat(8, 1fr)' }}
      >
        {tiles.map((row, y) =>
          row.map((tile, x) => (
            <div
              key={`${x}-${y}`}
              className="w-6 h-6 flex items-center justify-center text-xs"
              style={{ backgroundColor: getTileColor(tile) }}
              title={`Tile 0x${tile.toString(16).toUpperCase()}`}
            >
              {getTileEmoji(tile)}
            </div>
          ))
        )}
      </div>

      {/* Navigation Arrows */}
      <div className="mt-4 grid grid-cols-3 gap-1 w-24 mx-auto">
        <div />
        <NavArrow direction="up" value={worldscreen.nav_up} />
        <div />
        <NavArrow direction="left" value={worldscreen.nav_left} />
        <div className="text-center text-xs text-gray-500">●</div>
        <NavArrow direction="right" value={worldscreen.nav_right} />
        <div />
        <NavArrow direction="down" value={worldscreen.nav_down} />
        <div />
      </div>

      {/* Properties */}
      <div className="mt-4 text-xs text-gray-400 space-y-1">
        <div>Global Index: {screen.global_index}</div>
        <div>Section: {screen.section_id}</div>
        <div>ParentWorld: 0x{worldscreen.parent_world.toString(16).toUpperCase()}</div>
        <div>DataPointer: 0x{worldscreen.datapointer.toString(16).toUpperCase()}</div>
        <div>TopTiles: 0x{worldscreen.top_tiles.toString(16).toUpperCase()}</div>
        <div>BottomTiles: 0x{worldscreen.bottom_tiles.toString(16).toUpperCase()}</div>
        <div>Content: 0x{worldscreen.content.toString(16).toUpperCase()}</div>
      </div>
    </div>
  );
}

function NavArrow({ direction, value }: { direction: string; value: number }) {
  const arrows: Record<string, string> = {
    up: '↑',
    down: '↓',
    left: '←',
    right: '→',
  };

  const isBlocked = value === 0xFF;
  const isBuilding = value === 0xFE;

  return (
    <div
      className={`
        text-center text-sm
        ${isBlocked ? 'text-red-500' : isBuilding ? 'text-yellow-500' : 'text-green-500'}
      `}
      title={isBlocked ? 'Blocked' : isBuilding ? 'Building' : `Screen ${value}`}
    >
      {arrows[direction]}
    </div>
  );
}

// Placeholder tile rendering
function generateTileGrid(topTiles: number, bottomTiles: number): number[][] {
  // This would use actual TileSection data
  // For now, return placeholder based on indices
  const grid: number[][] = [];
  for (let y = 0; y < 7; y++) {
    const row: number[] = [];
    for (let x = 0; x < 8; x++) {
      // Placeholder: use tile indices
      row.push(y < 4 ? topTiles + (y * 8 + x) % 16 : bottomTiles + ((y - 4) * 8 + x) % 16);
    }
    grid.push(row);
  }
  return grid;
}

function getTileColor(tile: number): string {
  // Simplified tile type colors
  if (tile >= 0x46 && tile <= 0x47) return '#2d5016'; // Trees/Grass
  if (tile >= 0x80 && tile <= 0x9F) return '#654321'; // Buildings
  return '#3d3d3d'; // Default
}

function getTileEmoji(tile: number): string {
  if (tile === 0x46) return '🌿';
  if (tile === 0x47) return '🌲';
  if (tile >= 0x86 && tile <= 0x9F) return '🏠';
  return '';
}
```

### 6. SectionGrid (Tile Layout)

```tsx
// src/components/views/TilesView/SectionGrid.tsx
import { useRandomizerStore } from '../../../hooks/useRandomizerStore';
import { ScreenCell } from './ScreenCell';
import type { SectionPlan, ScreenPlan } from '../../../types/randomizer';

interface SectionGridProps {
  section: SectionPlan;
  screens: ScreenPlan[];
  onScreenSelect: (screenId: number) => void;
  selectedScreenId: number | null;
}

export function SectionGrid({
  section,
  screens,
  onScreenSelect,
  selectedScreenId,
}: SectionGridProps) {
  // Calculate grid bounds
  const positions = section.shape_grid;
  const minX = Math.min(...positions.map(p => p.x));
  const maxX = Math.max(...positions.map(p => p.x));
  const minY = Math.min(...positions.map(p => p.y));
  const maxY = Math.max(...positions.map(p => p.y));

  const width = maxX - minX + 1;
  const height = maxY - minY + 1;

  // Create grid
  const grid: (ScreenPlan | null)[][] = Array(height)
    .fill(null)
    .map(() => Array(width).fill(null));

  // Place screens in grid
  positions.forEach(pos => {
    const screen = screens.find(s => s.chapter_relative === pos.screen_id);
    if (screen) {
      grid[pos.y - minY][pos.x - minX] = screen;
    }
  });

  return (
    <div className="overflow-auto p-4">
      <div className="text-sm text-gray-400 mb-2">
        {section.section_id} - Shape: {section.shape} - {section.screen_count} screens
      </div>

      <div
        className="grid gap-1"
        style={{
          gridTemplateColumns: `repeat(${width}, 48px)`,
          gridTemplateRows: `repeat(${height}, 48px)`,
        }}
      >
        {grid.flat().map((screen, idx) =>
          screen ? (
            <ScreenCell
              key={screen.chapter_relative}
              screen={screen}
              isSelected={selectedScreenId === screen.chapter_relative}
              onClick={() => onScreenSelect(screen.chapter_relative)}
            />
          ) : (
            <div key={`empty-${idx}`} className="bg-gray-900 rounded" />
          )
        )}
      </div>
    </div>
  );
}
```

---

## State Management (Zustand)

```tsx
// src/store/index.ts
import { create } from 'zustand';
import type { RandomizationPlan, RandomizerSettings } from '../types/randomizer';

interface RandomizerState {
  // ROM State
  romLoaded: boolean;
  romFilename: string | null;
  romChecksum: string | null;

  // Settings
  settings: RandomizerSettings;

  // Plan
  plan: RandomizationPlan | null;
  planLoading: boolean;

  // UI State
  selectedChapter: number;
  selectedTab: 'map' | 'tiles' | 'items' | 'allies' | 'validation';
  selectedSection: string | null;
  selectedScreen: number | null;
  modalOpen: 'settings' | 'load' | 'export' | null;

  // Actions
  setRomLoaded: (loaded: boolean, filename?: string, checksum?: string) => void;
  setSettings: (settings: Partial<RandomizerSettings>) => void;
  setPlan: (plan: RandomizationPlan | null) => void;
  setPlanLoading: (loading: boolean) => void;
  setSelectedChapter: (chapter: number) => void;
  setSelectedTab: (tab: RandomizerState['selectedTab']) => void;
  setSelectedSection: (section: string | null) => void;
  setSelectedScreen: (screen: number | null) => void;
  setModalOpen: (modal: RandomizerState['modalOpen']) => void;
}

export const useRandomizerStore = create<RandomizerState>((set) => ({
  // Initial state
  romLoaded: false,
  romFilename: null,
  romChecksum: null,
  settings: getDefaultSettings(),
  plan: null,
  planLoading: false,
  selectedChapter: 1,
  selectedTab: 'map',
  selectedSection: null,
  selectedScreen: null,
  modalOpen: null,

  // Actions
  setRomLoaded: (loaded, filename, checksum) =>
    set({ romLoaded: loaded, romFilename: filename, romChecksum: checksum }),

  setSettings: (newSettings) =>
    set((state) => ({ settings: { ...state.settings, ...newSettings } })),

  setPlan: (plan) => set({ plan }),

  setPlanLoading: (loading) => set({ planLoading: loading }),

  setSelectedChapter: (chapter) =>
    set({ selectedChapter: chapter, selectedSection: null, selectedScreen: null }),

  setSelectedTab: (tab) => set({ selectedTab: tab }),

  setSelectedSection: (section) => set({ selectedSection: section, selectedScreen: null }),

  setSelectedScreen: (screen) => set({ selectedScreen: screen }),

  setModalOpen: (modal) => set({ modalOpen: modal }),
}));

function getDefaultSettings(): RandomizerSettings {
  return {
    preset: 'standard',
    shuffle_overworld: true,
    shuffle_towns: true,
    shuffle_dungeons: true,
    randomize_mazes: false,
    section_planning: {
      overworld_count_weights: { 1: 35, 2: 50, 3: 15 },
      town_count_weights: { 1: 10, 2: 60, 3: 30 },
      dungeon_count_weights: { 1: 85, 2: 15 },
      maze_count_weights: { 0: 5, 1: 70, 2: 25 },
    },
    section_shaping: {
      shape_weights: {
        overworld: { blob: 60, branching: 25, linear: 10, grid: 5 },
        town: { blob: 40, grid: 40, branching: 15, linear: 5 },
        dungeon: { branching: 45, blob: 30, linear: 20, grid: 5 },
        maze: { linear: 40, branching: 35, blob: 20, grid: 5 },
      },
      compactness_variance: 0.15,
    },
    section_connection: {
      topology_weights: { linear: 25, hub: 25, branching: 35, freeform: 15 },
      towns_only_overworld: true,
      dungeon_always_last: true,
    },
    content_placement: {
      encounter_density: 0.3,
      shops_per_town: { min: 1, max: 3 },
      hotels_per_town: { min: 1, max: 2 },
    },
    difficulty: {
      enemy_scaling: 'normal',
      shop_price_multiplier: 1.0,
    },
  };
}
```

---

## Backend Integration (Tauri)

```tsx
// src/api/backend.ts
import { invoke } from '@tauri-apps/api/core';
import type {
  LoadROMRequest,
  ROMLoadResponse,
  GeneratePlanRequest,
  RandomizationPlan,
  PatchROMRequest,
  PatchedROMResponse,
} from '../types/randomizer';

export const backendApi = {
  async loadROM(romData: Uint8Array): Promise<ROMLoadResponse> {
    const base64 = btoa(String.fromCharCode(...romData));
    return invoke<ROMLoadResponse>('load_rom', { request: { rom_data: base64 } });
  },

  async generatePlan(seed: number, settings: any): Promise<RandomizationPlan> {
    return invoke<RandomizationPlan>('generate_plan', {
      request: { seed, settings },
    });
  },

  async patchROM(planHash: string, options: {
    generateSpoiler: boolean;
    spoilerFormat: ('text' | 'json')[];
  }): Promise<PatchedROMResponse> {
    return invoke<PatchedROMResponse>('patch_rom', {
      request: {
        plan_hash: planHash,
        generate_spoiler: options.generateSpoiler,
        spoiler_format: options.spoilerFormat,
      },
    });
  },
};
```

### Tauri Commands (Rust)

```rust
// src-tauri/src/commands.rs
use serde::{Deserialize, Serialize};
use std::process::Command;

#[derive(Deserialize)]
pub struct LoadROMRequest {
    rom_data: String, // Base64
}

#[derive(Serialize)]
pub struct ROMLoadResponse {
    success: bool,
    error: Option<String>,
    rom_info: Option<ROMInfo>,
}

#[derive(Serialize)]
pub struct ROMInfo {
    filename: String,
    size: usize,
    checksum_sha256: String,
    is_valid: bool,
}

#[tauri::command]
pub async fn load_rom(request: LoadROMRequest) -> Result<ROMLoadResponse, String> {
    // Call Python backend via subprocess or embedded Python
    // For now, use subprocess
    let output = Command::new("python")
        .args(["-m", "tmos_randomizer.cli", "load-rom"])
        .arg(&request.rom_data)
        .output()
        .map_err(|e| e.to_string())?;

    let response: ROMLoadResponse = serde_json::from_slice(&output.stdout)
        .map_err(|e| e.to_string())?;

    Ok(response)
}

#[tauri::command]
pub async fn generate_plan(
    seed: u64,
    settings: serde_json::Value,
) -> Result<serde_json::Value, String> {
    // Call Python backend
    let settings_json = serde_json::to_string(&settings).unwrap();

    let output = Command::new("python")
        .args(["-m", "tmos_randomizer.cli", "generate-plan"])
        .arg(seed.to_string())
        .arg(&settings_json)
        .output()
        .map_err(|e| e.to_string())?;

    let plan: serde_json::Value = serde_json::from_slice(&output.stdout)
        .map_err(|e| e.to_string())?;

    Ok(plan)
}
```

---

## Hooks

### useSectionGraph

```tsx
// src/hooks/useSectionGraph.ts
import { useMemo } from 'react';
import type { SectionPlan, SectionConnection } from '../types/randomizer';

interface GraphNode {
  id: string;
  label: string;
  section_type: string;
  screen_count: number;
  x?: number;
  y?: number;
}

interface GraphLink {
  source: string;
  target: string;
  connection_type: string;
  bidirectional: boolean;
}

export function useSectionGraph(
  sections: SectionPlan[] | undefined,
  connections: SectionConnection[] | undefined
) {
  return useMemo(() => {
    if (!sections || !connections) {
      return { nodes: [], links: [] };
    }

    const nodes: GraphNode[] = sections.map((section) => ({
      id: section.section_id,
      label: formatSectionLabel(section),
      section_type: section.section_type,
      screen_count: section.screen_count,
    }));

    const links: GraphLink[] = connections.map((conn) => ({
      source: conn.from_section,
      target: conn.to_section,
      connection_type: conn.connection_type,
      bidirectional: conn.bidirectional,
    }));

    return { nodes, links };
  }, [sections, connections]);
}

function formatSectionLabel(section: SectionPlan): string {
  const typeLabels: Record<string, string> = {
    overworld: 'Overworld',
    town: 'Town',
    dungeon: 'Dungeon',
    maze: 'Maze',
    boss: 'Boss',
    special: 'Special',
  };

  const base = typeLabels[section.section_type] || section.section_type;
  if (section.section_index > 0) {
    return `${base} ${String.fromCharCode(65 + section.section_index)}`; // A, B, C...
  }
  return base;
}
```

---

## Utility Functions

### Color Utilities

```tsx
// src/utils/colors.ts

export const SECTION_COLORS = {
  overworld: {
    fill: '#4CAF50',
    stroke: '#81C784',
    text: 'text-green-400',
    bg: 'bg-green-600',
  },
  town: {
    fill: '#2196F3',
    stroke: '#64B5F6',
    text: 'text-blue-400',
    bg: 'bg-blue-600',
  },
  dungeon: {
    fill: '#9C27B0',
    stroke: '#CE93D8',
    text: 'text-purple-400',
    bg: 'bg-purple-600',
  },
  maze: {
    fill: '#FF9800',
    stroke: '#FFB74D',
    text: 'text-orange-400',
    bg: 'bg-orange-600',
  },
  boss: {
    fill: '#F44336',
    stroke: '#E57373',
    text: 'text-red-400',
    bg: 'bg-red-600',
  },
  special: {
    fill: '#607D8B',
    stroke: '#90A4AE',
    text: 'text-gray-400',
    bg: 'bg-gray-600',
  },
} as const;

export function getSectionColor(type: string, variant: 'fill' | 'stroke' | 'text' | 'bg' = 'fill'): string {
  const colors = SECTION_COLORS[type as keyof typeof SECTION_COLORS];
  return colors?.[variant] || '#666666';
}
```

---

## Related Documents

- [ui-design.md](ui-design.md) - Visual wireframes
- [data-contract.md](data-contract.md) - JSON schemas
- [implementation-plan.md](implementation-plan.md) - Build steps
