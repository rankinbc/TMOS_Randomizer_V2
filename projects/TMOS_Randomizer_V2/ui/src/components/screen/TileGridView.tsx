import { useState, useEffect, useRef } from 'react';
import type { ScreenData, ChapterData } from '../../api/client';
import { useRandomizerStore } from '../../store';

interface TileGridViewProps {
  chapter: ChapterData;
  selectedScreen: number | null;
  onScreenSelect: (index: number) => void;
}

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';
// ROM constants for address calculation
const TILESECTION_BASE = 0x03C4C7;
const TILESECTION_SIZE = 32;
const BANK_1_OFFSET = 0x2000;

function getBankOffsets(datapointer: number): { topOffset: number; bottomOffset: number } {
  if (datapointer >= 0xC0) return { topOffset: BANK_1_OFFSET, bottomOffset: BANK_1_OFFSET };
  if (datapointer >= 0x8F && datapointer < 0xA0) return { topOffset: BANK_1_OFFSET, bottomOffset: 0 };
  if (datapointer >= 0x40 && datapointer < 0x8F) return { topOffset: 0, bottomOffset: BANK_1_OFFSET };
  return { topOffset: 0, bottomOffset: 0 };
}

function getTileRomAddress(row: number, col: number, topTiles: number, bottomTiles: number, datapointer: number): number {
  const isTop = row < 4;
  const { topOffset, bottomOffset } = getBankOffsets(datapointer);
  const tileSectionIndex = isTop ? topTiles : bottomTiles;
  const bankOffset = isTop ? topOffset : bottomOffset;
  const localRow = isTop ? row : row - 4;
  return TILESECTION_BASE + bankOffset + (tileSectionIndex * TILESECTION_SIZE) + (localRow * 8) + col;
}
// Tile ID to image filename mapping (from TMOS_Romhack1)
function getTileFileName(tileValue: number): string {
  const mapping: Record<number, string> = {
    0x00: '00', 0x01: '01', 0x02: '02', 0x03: '03', 0x04: '04', 0x05: '05',
    0x06: '0D', 0x0D: '0D', 0x0E: '0D', 0x0F: '0D', 0x10: '0D', 0x14: '0D', 0x15: '0D',
    0x16: '0D', 0x17: '0D', 0x18: '0D', 0x19: '0D', 0x1A: '0D',
    0x07: '08', 0x08: '08', 0x09: '08', 0x0A: '08', 0x11: '08',
    0x0B: '20', 0x20: '20',
    0x0C: '0C', 0x12: '12', 0x1B: '1B', 0x1E: '1E', 0x1F: '1F',
    0x21: '21', 0x22: '22', 0x23: '23',
    0x24: '25', 0x25: '25',
    0x26: '26',
    0x2B: '43', 0x2C: '43', 0x2D: '43', 0x2E: '43', 0x37: '43', 0x38: '43',
    0x39: '43', 0x3A: '43', 0x3B: '43', 0x3C: '43', 0x3D: '43', 0x3E: '43', 0x43: '43',
    0x2F: '3F', 0x30: '3F', 0x3F: '3F',
    0x32: '41', 0x41: '41',
    0x33: '40', 0x34: '40', 0x40: '40',
    0x42: '42', 0x44: '44', 0x47: '47', 0x48: '48', 0x4A: '4A', 0x4C: '4C',
    0x4D: '4D', 0x4E: '4E',
    0x53: '53', 0x54: '54', 0x55: '55', 0x56: '56', 0x57: '57', 0x58: '58',
    0x59: '59', 0x5A: '5A', 0x5B: '5B', 0x5C: '5C', 0x5D: '5D', 0x5E: '5E', 0x5F: '5F',
    0x60: '60', 0x61: '61', 0x62: '62', 0x63: '63', 0x64: '64', 0x65: '65',
    0x67: '67', 0x68: '68', 0x6B: '6B', 0x6F: '6F',
    0x70: '70', 0x71: '71', 0x72: '72',
    0x73: '03', 0xED: '03', 0xF3: '03',
    0x76: '76', 0x77: '77', 0x78: '78', 0x7A: '7A', 0x7B: '7B', 0x7C: '7C', 0x7D: '7D', 0x7F: '7F',
    0x79: '26',
    0x80: '80', 0x81: '81', 0x82: '82', 0x83: '83', 0x84: '84',
    0x86: '86', 0x87: '87', 0x88: '88', 0x89: '89', 0x8A: '8A',
    0x8C: '8C', 0x8D: '8D', 0x8E: '8E', 0x8F: '8F',
    0x92: '92', 0x93: '93', 0x94: '94', 0x95: '95', 0x96: '96', 0x97: '97',
    0x98: '98', 0x99: '99', 0x9A: '9A', 0x9B: '9B', 0x9C: '9C',
    0x9D: '9D', 0x9E: '9E', 0x9F: '9F',
    0xA1: 'A1', 0xA2: 'A2', 0xA3: 'A3', 0xA4: 'A4', 0xA5: 'A5', 0xA6: 'A6', 0xA8: 'A8',
    0xA9: 'A9', 0xE2: 'A9',
    0xAA: 'AA', 0xAB: 'AA', 0xAF: 'AA',
    0xAC: 'AC', 0xAD: 'AD',
    0xB0: 'B0', 0xB1: 'B1', 0xB2: 'B2', 0xB3: 'B3', 0xB5: 'B5',
    0xB8: 'B8', 0xB9: 'B9', 0xBC: 'BC', 0xBD: 'BD', 0xBE: 'BE', 0xBF: 'BF',
    0xC0: 'C0', 0xC1: 'C1', 0xC2: 'C2', 0xC3: 'C3', 0xC4: 'C4', 0xC5: 'C5', 0xC6: 'C6', 0xC7: 'C7',
    0xCF: 'CF', 0xD0: 'D0',
    0xD5: 'D6', 0xD6: 'D6',
    0xDA: 'DA', 0xDC: 'DC', 0xDD: 'DD', 0xDE: 'DE',
    0xE0: 'E0', 0xE1: 'E1', 0xE6: 'E6', 0xE7: 'E7', 0xE9: 'E9', 0xEA: 'EA', 0xEB: 'EB',
    0xEC: 'EC', 0xEE: 'EE', 0xEF: 'EF',
    0xF0: 'F0', 0xF1: 'F1', 0xF2: 'F2', 0xF4: 'F4', 0xF5: 'F5',
    0xF6: 'F6', 0xF7: 'F7', 0xF8: 'F8', 0xF9: 'F9', 0xFA: 'FA', 0xFB: 'FB', 0xFC: 'FC',
    0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF',
  };
  const filename = mapping[tileValue];
  return filename ? filename + '.png' : tileValue.toString(16).toUpperCase().padStart(2, '0') + '.png';
}

// Ground color based on WorldScreen color value (from TMOS_Romhack1)
function getGroundColor(wsColorValue: number): string {
  const hex = wsColorValue.toString(16).toUpperCase().padStart(2, '0');
  switch (hex) {
    case '21': case '2A': case '32': case '45':
      return 'rgb(0, 60, 20)';      // past
    case '30': case '3B':
      return 'rgb(0, 112, 236)';    // water
    case '25': case '41': case '47':
      return 'rgb(252, 228, 160)';  // desert
    case '1A':
      return 'rgb(0, 80, 0)';       // dark palace
    case '3C': case '31':
      return 'rgb(164, 0, 0)';      // red
    case '23': case '2B': case '39':
      return 'rgb(188, 188, 188)';  // winter
    case '11': case '27': case '43': case '44': case '4A': case '34': case '1F': case '20':
      return 'rgb(0, 0, 0)';        // black
    case '1C': case '46': case '48':
      return 'rgb(216, 40, 0)';     // lava
    default:
      return 'rgb(0, 148, 0)';      // default green
  }
}




// Get individual tile image URL - uses static tiles from ui/public/tiles
function getTileImageUrl(tileId: number): string {
  const filename = getTileFileName(tileId);
  return `/tiles/${filename}`;
}

// Deadly tiles (water, lava - kills instantly, treated as blocking for navigation)
const DEADLY_TILES = new Set([
  0x2F, 0x30,  // Lava/fire
  0x3F, 0x40, 0x41, 0x42,  // Water
  0x6F,  // Water hazard
  0xE9,  // Lake entry - underwater section entrance
  0xEC,  // Special deadly
]);

// Collidable tiles (cannot walk through)
const COLLIDABLE_TILES = new Set([
  // Maze walls
  0x00, 0x01, 0x02, 0x07, 0x08, 0x09, 0x0A, 0x0D, 0x0E, 0x0F,
  0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,
  // Building/structure
  0x22, 0x23,
  // Dark world
  0x4C, 0x4F, 0x50, 0x51, 0x52,
  // Dungeon walls (0x5F is walkable dungeon floor)
  0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E,
  0x60, 0x61, 0x62, 0x63, 0x64, 0x67, 0x68, 0x6B,
  // Trees
  0x47,
  // Elevated terrain
  0x73,
  0x77, 0x78, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F,
  0x80, 0x81, 0x82, 0x83, 0x84,
  // Building walls
  0x86, 0x87, 0x88, 0x89, 0x8A, 0x8F,
  0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
  0x98, 0x99, 0x9A, 0x9B, 0x9C,
  // More structures
  0xA1, 0xA2, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF,
  0xB2, 0xB3, 0xB5, 0xB8, 0xB9, 0xBC, 0xBD, 0xBE, 0xBF,
  0xC0, 0xC1, 0xCB, 0xCC, 0xCF,
  0xD5, 0xD6, 0xDE,
  0xE2, 0xE6, 0xE7, 0xEA, 0xEB, 0xEF,
  0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE,
]);

// Check if a tile is non-walkable (collidable or deadly)
function isNonWalkable(tileId: number): boolean {
  return DEADLY_TILES.has(tileId) || COLLIDABLE_TILES.has(tileId);
}

// Get tile category for display
function getTileCategory(tileId: number): 'walkable' | 'deadly' | 'collidable' {
  if (DEADLY_TILES.has(tileId)) return 'deadly';
  if (COLLIDABLE_TILES.has(tileId)) return 'collidable';
  return 'walkable';
}

// Content descriptions based on content value (from TMOS game data)
function getContentDescription(content: number): string | null {
  const contentMap: Record<number, string> = {
    0x00: 'Empty',
    0x01: 'Faruk (Ally)',
    0x02: 'Shop',
    0x03: 'Inn',
    0x04: 'Church',
    0x05: 'Armor Shop',
    0x06: 'Weapon Shop',
    0x07: 'Magic Shop',
    0x08: 'Fortune Teller',
    0x09: 'Bank',
    0x0A: 'Item Shop',
    0x0B: 'Sage',
    0x0C: 'King',
    0x0D: 'Elder',
    0x0E: 'Princess',
    0x0F: 'Hint NPC',
    0x10: 'Chest',
    0x11: 'Boss',
    0x12: 'Mini Boss',
    0x13: 'Dungeon Exit',
    0x14: 'Secret',
    0x15: 'Warp Point',
    0x16: 'Save Point',
    0x17: 'Healing Spot',
    0x18: 'Trap',
    0x19: 'Puzzle',
    0x1A: 'Lock',
    0x1B: 'Key Door',
    0x1C: 'Switch',
    0x1D: 'Bridge',
    0x1E: 'Boat Dock',
    0x1F: 'Raft Point',
  };
  return contentMap[content] || null;
}

// Parent world names
const PARENT_WORLD_NAMES: Record<number, string> = {
  0x00: 'Overworld',
  0x01: 'Town',
  0x02: 'Dungeon',
  0x03: 'Maze',
  0x04: 'Special',
  0x05: 'Boss',
};

// Event type names
const EVENT_NAMES: Record<number, string> = {
  0x00: 'None',
  0x40: 'Stairway',
  0x80: 'Event',
  0xC0: 'Special',
};

// Format navigation value
function formatNavigation(value: number): string {
  if (value === 0xFF) return 'Blocked';
  if (value === 0xFE) return 'Building';
  return `Screen ${value} (0x${value.toString(16).toUpperCase()})`;
}

// Screen Info Header Component
function ScreenInfoHeader({ screen }: { screen: ScreenData }) {
  const contentDesc = getContentDescription(screen.content);
  const parentWorld = PARENT_WORLD_NAMES[screen.parent_world] || 'Unknown';
  const eventType = EVENT_NAMES[screen.event & 0xC0] || 'Unknown';
  const { topOffset, bottomOffset } = getBankOffsets(screen.datapointer);

  return (
    <div className="bg-slate-800 rounded-lg p-4">
      {/* Title Row */}
      <div className="flex items-center gap-4 mb-4">
        <h3 className="text-xl font-bold text-slate-100">
          Screen 0x{screen.index.toString(16).toUpperCase().padStart(2, '0')}
          <span className="text-slate-400 font-normal ml-2">({screen.index})</span>
        </h3>
        {contentDesc && contentDesc !== 'Empty' && (
          <span className="px-2 py-1 bg-blue-600 text-white text-sm rounded font-medium">
            {contentDesc}
          </span>
        )}
        <span className={`px-2 py-1 text-sm rounded font-medium ${
          parentWorld === 'Overworld' ? 'bg-green-600 text-white' :
          parentWorld === 'Town' ? 'bg-amber-600 text-white' :
          parentWorld === 'Dungeon' ? 'bg-red-600 text-white' :
          parentWorld === 'Maze' ? 'bg-purple-600 text-white' :
          parentWorld === 'Boss' ? 'bg-rose-700 text-white' :
          'bg-slate-600 text-white'
        }`}>
          {parentWorld}
        </span>
      </div>

      {/* Info Grid */}
      <div className="grid grid-cols-4 gap-4 text-sm">
        {/* Tile Data */}
        <div className="space-y-1">
          <div className="text-slate-400 font-medium border-b border-slate-600 pb-1 mb-1">Tile Data</div>
          <InfoRow label="DataPointer" value={`0x${screen.datapointer.toString(16).toUpperCase()}`} />
          <InfoRow label="Top Tiles" value={`0x${screen.top_tiles.toString(16).toUpperCase()} (${screen.top_tiles})`} />
          <InfoRow label="Bottom Tiles" value={`0x${screen.bottom_tiles.toString(16).toUpperCase()} (${screen.bottom_tiles})`} />
          <InfoRow label="CHR Index" value={`0x${screen.chr_index.toString(16).toUpperCase()}`} />
          <InfoRow label="Top Bank" value={topOffset === 0x2000 ? 'Bank 1' : 'Bank 0'} />
          <InfoRow label="Bottom Bank" value={bottomOffset === 0x2000 ? 'Bank 1' : 'Bank 0'} />
        </div>

        {/* Navigation */}
        <div className="space-y-1">
          <div className="text-slate-400 font-medium border-b border-slate-600 pb-1 mb-1">Navigation</div>
          <InfoRow label="Right →" value={formatNavigation(screen.nav_right)} />
          <InfoRow label="Left ←" value={formatNavigation(screen.nav_left)} />
          <InfoRow label="Down ↓" value={formatNavigation(screen.nav_down)} />
          <InfoRow label="Up ↑" value={formatNavigation(screen.nav_up)} />
        </div>

        {/* World Data */}
        <div className="space-y-1">
          <div className="text-slate-400 font-medium border-b border-slate-600 pb-1 mb-1">World Data</div>
          <InfoRow label="Parent World" value={`${parentWorld} (${screen.parent_world})`} />
          <InfoRow label="ObjectSet" value={`0x${screen.objectset.toString(16).toUpperCase()} (${screen.objectset})`} />
          <InfoRow label="Event" value={`${eventType} (0x${screen.event.toString(16).toUpperCase()})`} />
          <InfoRow label="Content" value={`0x${screen.content.toString(16).toUpperCase()}${contentDesc ? ` - ${contentDesc}` : ''}`} />
        </div>

        {/* Colors & Exit */}
        <div className="space-y-1">
          <div className="text-slate-400 font-medium border-b border-slate-600 pb-1 mb-1">Colors & Exit</div>
          <InfoRow label="WS Color" value={`0x${screen.worldscreen_color.toString(16).toUpperCase()}`} />
          <InfoRow label="Sprites Color" value={`0x${screen.sprites_color.toString(16).toUpperCase()}`} />
          <InfoRow label="Exit Position" value={`0x${screen.exit_position.toString(16).toUpperCase()}`} />
          <div className="flex items-center gap-2 mt-2">
            <span className="text-slate-500">Ground:</span>
            <div 
              className="w-6 h-6 rounded border border-slate-500" 
              style={{ backgroundColor: getGroundColor(screen.worldscreen_color) }}
              title={`Ground color for WS Color 0x${screen.worldscreen_color.toString(16).toUpperCase()}`}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

function InfoRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between gap-2">
      <span className="text-slate-500">{label}:</span>
      <span className="text-slate-200 font-mono text-xs">{value}</span>
    </div>
  );
}

export function TileGridView({ chapter, selectedScreen, onScreenSelect }: TileGridViewProps) {
  const [showImages, setShowImages] = useState(true);
  const [highlightNonWalkable, setHighlightNonWalkable] = useState(false);
  const screenListRef = useRef<HTMLDivElement>(null);

  const selectedScreenData = chapter.screens.find(s => s.index === selectedScreen);

  // Auto-scroll to selected screen when component mounts or selection changes
  useEffect(() => {
    if (selectedScreen !== null && screenListRef.current) {
      const selectedButton = screenListRef.current.querySelector(`[data-screen-index="${selectedScreen}"]`);
      if (selectedButton) {
        selectedButton.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
    }
  }, [selectedScreen]);

  return (
    <div className="h-full flex">
      {/* Screen List */}
      <div ref={screenListRef} className="w-64 border-r border-slate-700 overflow-y-auto p-2">
        <h3 className="text-sm font-medium text-slate-300 mb-2 px-2">
          Screens ({chapter.screens.length})
        </h3>
        <div className="space-y-1">
          {chapter.screens.map((screen) => (
            <button
              key={screen.index}
              data-screen-index={screen.index}
              onClick={() => onScreenSelect(screen.index)}
              className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${
                selectedScreen === screen.index
                  ? 'bg-blue-600 text-white'
                  : 'text-slate-300 hover:bg-slate-700'
              }`}
            >
              <span className="font-mono">
                0x{screen.index.toString(16).toUpperCase().padStart(2, '0')}
              </span>
              <span className="text-slate-400 ml-2">
                ({screen.index})
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Tile Grid Display */}
      <div className="flex-1 p-4 overflow-auto">
        {selectedScreenData ? (
          <div className="space-y-6">
            {/* Screen Info Header */}
            <ScreenInfoHeader screen={selectedScreenData} />

            {/* Display Options */}
            <div className="flex items-center gap-6 p-3 bg-slate-800 rounded-lg">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showImages}
                  onChange={(e) => setShowImages(e.target.checked)}
                  className="w-4 h-4 rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500 focus:ring-offset-slate-800"
                />
                <span className="text-sm text-slate-300">Show Tile Images</span>
              </label>

              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={highlightNonWalkable}
                  onChange={(e) => setHighlightNonWalkable(e.target.checked)}
                  className="w-4 h-4 rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500 focus:ring-offset-slate-800"
                />
                <span className="text-sm text-slate-300">Highlight Non-Walkable</span>
              </label>

              {highlightNonWalkable && (
                <div className="flex items-center gap-4 ml-4 text-xs">
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 bg-red-500/50 border border-red-500 rounded" />
                    <span className="text-slate-400">Collidable</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 bg-orange-500/50 border border-orange-500 rounded" />
                    <span className="text-slate-400">Deadly</span>
                  </div>
                </div>
              )}
            </div>

            {/* 8x6 Tile Grid */}
            <div>
              <h3 className="text-sm font-medium text-slate-300 mb-2">
                Tile Grid (8×6) - Hover for tile ID
              </h3>
              <TileGrid
                chapterNum={chapter.chapter_num}
                screen={selectedScreenData}
                showImages={showImages}
                highlightNonWalkable={highlightNonWalkable}
              />
            </div>
          </div>
        ) : (
          <div className="flex items-center justify-center h-full text-slate-500">
            Select a screen from the list to view its tile grid.
          </div>
        )}
      </div>
    </div>
  );
}

// Component to display the 8x6 tile grid
function TileGrid({
  chapterNum,
  screen,
  showImages,
  highlightNonWalkable
}: {
  chapterNum: number;
  screen: ScreenData;
  showImages: boolean;
  highlightNonWalkable: boolean;
}) {
  const [tileGrid, setTileGrid] = useState<number[][] | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Fetch the tile grid data from the API
    async function fetchTileGrid() {
      setLoading(true);
      setError(null);
      try {
        const response = await fetch(
          `${API_BASE}/api/rom/tiles/${chapterNum}/${screen.index}`
        );
        if (response.ok) {
          const data = await response.json();
          setTileGrid(data.grid);
        } else {
          // API endpoint might not exist yet, show placeholder
          setError('Tile grid API not available');
        }
      } catch (e) {
        setError('Failed to load tile grid');
      } finally {
        setLoading(false);
      }
    }

    fetchTileGrid();
  }, [chapterNum, screen.index]);

  if (loading) {
    return <div className="text-slate-400">Loading tile grid...</div>;
  }

  if (error || !tileGrid) {
    // Show placeholder grid based on screen properties
    return (
      <div className="space-y-2">
        <div className="text-xs text-slate-500 mb-2">{error || 'Tile data not loaded'}</div>
        <PlaceholderTileGrid screen={screen} />
      </div>
    );
  }

  return (
    <div
      className="inline-grid gap-px bg-slate-700 p-px rounded"
      style={{ gridTemplateColumns: 'repeat(8, 64px)' }}
    >
      {tileGrid.map((row, rowIdx) =>
        row.map((tileId, colIdx) => (
          <TileCell
            key={`${rowIdx}-${colIdx}`}
            tileId={tileId}
            row={rowIdx}
            col={colIdx}
            showImage={showImages}
            highlightNonWalkable={highlightNonWalkable}
            topTiles={screen.top_tiles}
            bottomTiles={screen.bottom_tiles}
            datapointer={screen.datapointer}
            wsColor={screen.worldscreen_color}
          />
        ))
      )}
    </div>
  );
}

// Tooltip component for tile info
function TileTooltip({ tileId, row, col, romAddress, category, visible, position, chrBank }: {
  tileId: number; row: number; col: number; romAddress: number;
  category: 'walkable' | 'deadly' | 'collidable'; visible: boolean; position: { x: number; y: number }; chrBank?: number;
}) {
  if (!visible) return null;
  const hex = tileId.toString(16).toUpperCase().padStart(2, '0');
  const isTop = row < 4;
  const categoryColors: Record<string, string> = { walkable: 'text-green-400', deadly: 'text-orange-400', collidable: 'text-red-400' };

  return (
    <div className="fixed z-50 pointer-events-none" style={{ left: position.x + 10, top: position.y - 10, transform: 'translateY(-100%)' }}>
      <div className="bg-slate-900 border border-slate-600 rounded-lg shadow-xl p-3 min-w-[200px]">
        <div className="flex gap-3">
          <div className="flex-shrink-0">
            <img src={getTileImageUrl(tileId)} alt={`Tile 0x${hex}`} className="w-16 h-16 border border-slate-600 rounded" style={{ imageRendering: 'pixelated' }} />
          </div>
          <div className="flex-1 text-xs space-y-1">
            <div className="text-slate-200 font-semibold text-sm">Tile 0x{hex}</div>
            <div className="text-slate-400">Decimal: <span className="text-slate-200">{tileId}</span></div>
            <div className="text-slate-400">Position: <span className="text-slate-200">[{col}, {row}]</span><span className="text-slate-500 ml-1">({isTop ? 'Top' : 'Bottom'})</span></div>
            <div className="text-slate-400">Status: <span className={categoryColors[category] + ' capitalize font-medium'}>{category}</span></div>
            <div className="text-slate-400">ROM: <span className="text-slate-200 font-mono">0x{romAddress.toString(16).toUpperCase()}</span></div>
          </div>
        </div>
      </div>
    </div>
  );
}

// Context menu for tiles
function TileContextMenu({
  visible,
  position,
  tileId,
  onClose,
  onViewInTileBank,
}: {
  visible: boolean;
  position: { x: number; y: number };
  tileId: number;
  onClose: () => void;
  onViewInTileBank: () => void;
}) {
  const menuRef = useRef<HTMLDivElement>(null);

  // Close menu when clicking outside
  useEffect(() => {
    if (!visible) return;

    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        onClose();
      }
    };

    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };

    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleEscape);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleEscape);
    };
  }, [visible, onClose]);

  if (!visible) return null;

  const hex = tileId.toString(16).toUpperCase().padStart(2, '0');

  return (
    <div
      ref={menuRef}
      className="fixed z-50 bg-slate-800 border border-slate-600 rounded-lg shadow-xl py-1 min-w-[180px]"
      style={{ left: position.x, top: position.y }}
    >
      <div className="px-3 py-1.5 border-b border-slate-700 text-xs text-slate-400">
        Tile 0x{hex}
      </div>
      <button
        onClick={() => {
          onViewInTileBank();
          onClose();
        }}
        className="w-full px-3 py-2 text-left text-sm text-slate-200 hover:bg-slate-700 flex items-center gap-2"
      >
        <span className="text-blue-400">&#x2192;</span>
        View in Tile Bank
      </button>
    </div>
  );
}

// Individual tile cell in the grid
function TileCell({
  tileId, row, col, showImage, highlightNonWalkable, topTiles, bottomTiles, datapointer, wsColor
}: {
  tileId: number; row: number; col: number; showImage: boolean; highlightNonWalkable: boolean;
  topTiles: number; bottomTiles: number; datapointer: number; wsColor: number;
}) {
  const { navigateToTile } = useRandomizerStore();
  const groundColor = getGroundColor(wsColor);
  const [imgError, setImgError] = useState(false);
  const [showTooltip, setShowTooltip] = useState(false);
  const [tooltipPos, setTooltipPos] = useState({ x: 0, y: 0 });
  const [contextMenu, setContextMenu] = useState<{ visible: boolean; x: number; y: number }>({
    visible: false,
    x: 0,
    y: 0,
  });
  const cellRef = useRef<HTMLDivElement>(null);

  const hex = tileId.toString(16).toUpperCase().padStart(2, '0');
  const category = getTileCategory(tileId);
  const romAddress = getTileRomAddress(row, col, topTiles, bottomTiles, datapointer);
  const chrBankIndex = datapointer & 0x3F;  // Extract CHR bank from datapointer

  const getOverlayStyle = () => {
    if (!highlightNonWalkable) return {};
    if (category === 'collidable') return { backgroundColor: 'rgba(239, 68, 68, 0.5)' };
    if (category === 'deadly') return { backgroundColor: 'rgba(249, 115, 22, 0.5)' };
    return {};
  };

  const handleMouseEnter = (e: React.MouseEvent) => { setTooltipPos({ x: e.clientX, y: e.clientY }); setShowTooltip(true); };
  const handleMouseMove = (e: React.MouseEvent) => { setTooltipPos({ x: e.clientX, y: e.clientY }); };
  const handleMouseLeave = () => { setShowTooltip(false); };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
    setShowTooltip(false);
    setContextMenu({ visible: true, x: e.clientX, y: e.clientY });
  };

  return (
    <>
      <div ref={cellRef} className="relative w-16 h-16 bg-slate-800 group cursor-pointer"
        onMouseEnter={handleMouseEnter} onMouseMove={handleMouseMove} onMouseLeave={handleMouseLeave}
        onContextMenu={handleContextMenu}>
        {showImage && !imgError ? (
          <img src={getTileImageUrl(tileId)} alt={`Tile 0x${hex}`} className="w-full h-full object-cover"
            style={{ imageRendering: 'pixelated' }} onError={() => setImgError(true)} />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-sm text-white font-mono" style={{ backgroundColor: groundColor }}>0x{hex}</div>
        )}
        {highlightNonWalkable && isNonWalkable(tileId) && <div className="absolute inset-0 pointer-events-none" style={getOverlayStyle()} />}
        <div className="absolute inset-0 bg-blue-500/30 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
          <span className="bg-black/80 text-white text-xs px-1 rounded font-mono">0x{hex}</span>
        </div>
      </div>
      <TileTooltip tileId={tileId} row={row} col={col} romAddress={romAddress} category={category} visible={showTooltip} position={tooltipPos} chrBank={chrBankIndex} />
      <TileContextMenu
        visible={contextMenu.visible}
        position={{ x: contextMenu.x, y: contextMenu.y }}
        tileId={tileId}
        onClose={() => setContextMenu({ ...contextMenu, visible: false })}
        onViewInTileBank={() => navigateToTile(tileId)}
      />
    </>
  );
}

// Placeholder grid when tile data isn't available
function PlaceholderTileGrid({ screen }: { screen: ScreenData }) {
  const rows = 6;
  const cols = 8;

  return (
    <div
      className="inline-grid gap-px bg-slate-700 p-px rounded"
      style={{ gridTemplateColumns: 'repeat(8, 64px)' }}
    >
      {Array.from({ length: rows }, (_, rowIdx) =>
        Array.from({ length: cols }, (_, colIdx) => {
          const isTop = rowIdx < 4;
          const tileSection = isTop ? screen.top_tiles : screen.bottom_tiles;

          return (
            <div
              key={`${rowIdx}-${colIdx}`}
              className="w-16 h-16 bg-slate-800 flex items-center justify-center text-xs text-slate-500 border border-slate-700"
              title={`Row ${rowIdx}, Col ${colIdx} - ${isTop ? 'Top' : 'Bottom'} TileSection 0x${tileSection.toString(16).toUpperCase()}`}
            >
              <div className="text-center">
                <div className="text-[10px] text-slate-600">{isTop ? 'T' : 'B'}[{rowIdx},{colIdx}]</div>
              </div>
            </div>
          );
        })
      )}
    </div>
  );
}
