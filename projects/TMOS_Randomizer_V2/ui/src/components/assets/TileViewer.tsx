// Tile viewer component for displaying game tile graphics

import { useState } from 'react';
import { useRandomizerStore } from '../../store';
import { api } from '../../api/client';

interface Tile {
  name: string;
  filename: string;
  path: string;
}

// Known tile categories based on hex IDs
const TILE_CATEGORIES: Record<string, { range: [number, number]; color: string }> = {
  'Grass/Trees': { range: [0x43, 0x4F], color: 'bg-green-600' },
  'Water': { range: [0x3F, 0x42], color: 'bg-blue-600' },
  'Desert': { range: [0x50, 0x5F], color: 'bg-yellow-600' },
  'Dungeon': { range: [0x60, 0x7F], color: 'bg-purple-600' },
  'Town': { range: [0x80, 0x9F], color: 'bg-orange-600' },
  'Special': { range: [0x00, 0x3E], color: 'bg-red-600' },
};

interface TileViewerProps {
  onSelect?: (tile: Tile) => void;
  selectable?: boolean;
  selectedTiles?: string[];
}

export function TileViewer({ onSelect, selectable = false, selectedTiles = [] }: TileViewerProps) {
  const { assets, apiConnected } = useRandomizerStore();
  const [hoveredTile, setHoveredTile] = useState<string | null>(null);
  const [filterCategory, setFilterCategory] = useState<string | null>(null);

  // Parse tile ID from filename (e.g., "3F.png" -> 0x3F)
  const getTileId = (filename: string): number => {
    const match = filename.match(/^([0-9A-Fa-f]+)\./);
    if (match) {
      return parseInt(match[1], 16);
    }
    return -1;
  };

  // Get category for a tile
  const getTileCategory = (tileId: number): string | null => {
    for (const [category, { range }] of Object.entries(TILE_CATEGORIES)) {
      if (tileId >= range[0] && tileId <= range[1]) {
        return category;
      }
    }
    return null;
  };

  // Filter and sort tiles
  const getFilteredTiles = (): Tile[] => {
    if (!assets?.tiles) return [];

    let tiles = [...assets.tiles];

    // Sort by hex ID
    tiles.sort((a, b) => getTileId(a.filename) - getTileId(b.filename));

    // Filter by category
    if (filterCategory) {
      const { range } = TILE_CATEGORIES[filterCategory];
      tiles = tiles.filter(t => {
        const id = getTileId(t.filename);
        return id >= range[0] && id <= range[1];
      });
    }

    return tiles;
  };

  const filteredTiles = getFilteredTiles();

  if (!apiConnected) {
    return (
      <div className="p-4 text-center text-slate-500">
        <p>Connect to API to view game tiles</p>
        <p className="text-xs mt-2">Run: tmos-randomize serve</p>
      </div>
    );
  }

  if (!assets?.tiles?.length) {
    return (
      <div className="p-4 text-center text-slate-500">
        <p>No tiles loaded</p>
        <p className="text-xs mt-2">Loading asset manifest...</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      {/* Category Filter */}
      <div className="flex gap-1 p-2 bg-slate-800 border-b border-slate-700 flex-wrap">
        <button
          onClick={() => setFilterCategory(null)}
          className={`px-3 py-1 text-xs rounded ${
            filterCategory === null
              ? 'bg-blue-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          All ({assets.tiles.length})
        </button>
        {Object.entries(TILE_CATEGORIES).map(([cat, { color }]) => (
          <button
            key={cat}
            onClick={() => setFilterCategory(cat)}
            className={`px-3 py-1 text-xs rounded ${
              filterCategory === cat
                ? `${color} text-white`
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Tile Grid */}
      <div className="flex-1 overflow-auto p-4">
        <div className="grid grid-cols-6 sm:grid-cols-8 md:grid-cols-10 lg:grid-cols-12 gap-2">
          {filteredTiles.map((tile) => {
            const tileId = getTileId(tile.filename);
            const category = getTileCategory(tileId);
            const isSelected = selectedTiles.includes(tile.name);

            return (
              <div
                key={tile.filename}
                className={`relative group cursor-pointer rounded p-1 transition-all ${
                  isSelected
                    ? 'bg-green-600/50 ring-2 ring-green-500'
                    : hoveredTile === tile.name
                    ? 'bg-blue-600/30 ring-2 ring-blue-500'
                    : 'bg-slate-800 hover:bg-slate-700'
                } ${selectable ? 'cursor-pointer' : ''}`}
                onMouseEnter={() => setHoveredTile(tile.name)}
                onMouseLeave={() => setHoveredTile(null)}
                onClick={() => selectable && onSelect?.(tile)}
              >
                <img
                  src={api.getTileUrl(tile.filename)}
                  alt={`Tile ${tile.name}`}
                  className="w-full h-auto pixelated"
                  style={{ imageRendering: 'pixelated' }}
                />
                <div className="absolute bottom-0 left-0 right-0 bg-black/70 text-center">
                  <p className="text-[8px] text-slate-300 font-mono">
                    {tile.name.toUpperCase()}
                  </p>
                </div>
                {category && (
                  <div
                    className={`absolute top-0 right-0 w-2 h-2 rounded-full ${TILE_CATEGORIES[category].color}`}
                    title={category}
                  />
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Tile Info */}
      {hoveredTile && (
        <div className="p-2 bg-slate-800 border-t border-slate-700 text-sm flex justify-between">
          <div>
            <span className="text-slate-400">Tile ID: </span>
            <span className="font-mono text-white">0x{hoveredTile.toUpperCase()}</span>
          </div>
          <div>
            <span className="text-slate-400">Category: </span>
            <span className="text-white">
              {getTileCategory(parseInt(hoveredTile, 16)) || 'Unknown'}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
