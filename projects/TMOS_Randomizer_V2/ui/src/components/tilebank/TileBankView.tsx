import { useEffect, useState } from 'react';
import { useRandomizerStore } from '../../store';
import { TileBankGrid } from './TileBankGrid';
import { TileEditor } from './TileEditor';

// Common CHR bank presets with descriptions
const CHR_BANK_PRESETS = [
  { value: 0x0F, label: '0F', description: 'Overworld/Dungeon' },
  { value: 0x13, label: '13', description: 'Town Interiors' },
  { value: 0x17, label: '17', description: 'Underwater/Cave' },
  { value: 0x16, label: '16', description: 'Maze' },
  { value: 0x0E, label: '0E', description: 'Desert' },
  { value: 0x11, label: '11', description: 'Title/Special' },
  { value: 0x18, label: '18', description: 'Boss Areas' },
];

export function TileBankView() {
  const {
    romLoaded,
    tileBankData,
    tileBankLoading,
    selectedTileIndex,
    loadTileBankData,
    setSelectedTileIndex,
    updateTileBankTile,
    apiError,
  } = useRandomizerStore();

  // DataPointer state for CHR bank selection
  const [dataPointer, setDataPointer] = useState(0x0F); // Default to overworld
  const [dataPointerInput, setDataPointerInput] = useState('0F');

  // Load tile bank data when component mounts
  useEffect(() => {
    if (romLoaded && !tileBankData && !tileBankLoading) {
      loadTileBankData();
    }
  }, [romLoaded, tileBankData, tileBankLoading, loadTileBankData]);

  // Select first tile if none selected
  useEffect(() => {
    if (tileBankData && tileBankData.length > 0 && selectedTileIndex === null) {
      setSelectedTileIndex(0);
    }
  }, [tileBankData, selectedTileIndex, setSelectedTileIndex]);

  // Handle DataPointer input change
  const handleDataPointerInputChange = (value: string) => {
    const cleaned = value.replace(/[^0-9A-Fa-f]/g, '').toUpperCase().slice(0, 2);
    setDataPointerInput(cleaned);

    // Update actual dataPointer if valid
    if (cleaned.length > 0) {
      const parsed = parseInt(cleaned, 16);
      if (!isNaN(parsed) && parsed >= 0 && parsed <= 255) {
        setDataPointer(parsed);
      }
    }
  };

  // Handle preset button click
  const handlePresetClick = (value: number) => {
    setDataPointer(value);
    setDataPointerInput(value.toString(16).toUpperCase().padStart(2, '0'));
  };

  // Get CHR bank index from DataPointer (bits 0-5)
  const chrBankIndex = dataPointer & 0x3F;

  // ROM not loaded state
  if (!romLoaded) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <div className="text-slate-400 mb-2">No ROM loaded</div>
          <p className="text-sm text-slate-500">
            Upload a ROM file to view and edit the Tile Bank.
          </p>
        </div>
      </div>
    );
  }

  // Loading state
  if (tileBankLoading) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full mx-auto mb-3" />
          <div className="text-slate-400">Loading tile bank...</div>
        </div>
      </div>
    );
  }

  // Error state
  if (apiError && !tileBankData) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-400 mb-2">Failed to load tile bank</div>
          <p className="text-sm text-slate-500">{apiError}</p>
          <button
            onClick={() => loadTileBankData()}
            className="mt-4 px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white rounded text-sm"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  // No data state
  if (!tileBankData || tileBankData.length === 0) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-slate-400">No tile data available</div>
      </div>
    );
  }

  const selectedTile = selectedTileIndex !== null
    ? tileBankData.find((t) => t.index === selectedTileIndex)
    : null;

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="text-lg font-semibold text-slate-200">Tile Bank</h2>
            <p className="text-sm text-slate-400">
              ROM: 0x011B0B | 256 tiles | 4 bytes per tile (2x2 MiniTile IDs)
            </p>
          </div>
          <div className="text-sm text-slate-500">
            {selectedTileIndex !== null && (
              <span>Selected: 0x{selectedTileIndex.toString(16).toUpperCase().padStart(2, '0')}</span>
            )}
          </div>
        </div>

        {/* DataPointer / CHR Bank Selector */}
        <div className="flex items-center gap-4 flex-wrap">
          {/* Hex Input */}
          <div className="flex items-center gap-2">
            <span className="text-sm text-slate-400">DataPointer:</span>
            <div className="flex items-center">
              <span className="text-slate-500 text-sm mr-1">0x</span>
              <input
                type="text"
                value={dataPointerInput}
                onChange={(e) => handleDataPointerInputChange(e.target.value)}
                className="w-12 px-2 py-1 text-sm font-mono text-center rounded bg-slate-900 border border-slate-600 text-slate-200 focus:outline-none focus:ring-1 focus:ring-blue-500"
                placeholder="0F"
                maxLength={2}
              />
            </div>
            <span className="text-xs text-slate-500">
              (CHR Bank: 0x{chrBankIndex.toString(16).toUpperCase().padStart(2, '0')})
            </span>
          </div>

          {/* Preset Buttons */}
          <div className="flex items-center gap-1">
            <span className="text-xs text-slate-500 mr-1">Presets:</span>
            {CHR_BANK_PRESETS.map((preset) => (
              <button
                key={preset.value}
                onClick={() => handlePresetClick(preset.value)}
                className={`px-2 py-1 text-xs font-mono rounded transition-colors ${
                  chrBankIndex === preset.value
                    ? 'bg-blue-600 text-white'
                    : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
                }`}
                title={preset.description}
              >
                {preset.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Grid Panel */}
        <div className="flex-1 overflow-auto p-4">
          <div className="mb-3">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide">
              16x16 Tile Grid (0x00 - 0xFF)
            </h3>
            <p className="text-xs text-slate-500 mt-1">
              Click a tile to select it for editing. Tiles rendered with CHR Bank 0x{chrBankIndex.toString(16).toUpperCase().padStart(2, '0')}.
            </p>
          </div>
          <TileBankGrid
            tiles={tileBankData}
            selectedIndex={selectedTileIndex}
            onSelectTile={setSelectedTileIndex}
            chrBank={chrBankIndex}
          />
        </div>

        {/* Editor Panel */}
        <div className="w-72 border-l border-slate-700 overflow-y-auto p-4 bg-slate-800/30">
          {selectedTile ? (
            <TileEditor
              tile={selectedTile}
              onSave={(minitiles) => updateTileBankTile(selectedTile.index, minitiles)}
              chrBank={chrBankIndex}
            />
          ) : (
            <div className="text-center text-slate-500 py-8">
              Select a tile to edit
            </div>
          )}

          {/* Help Text */}
          <div className="mt-6 p-3 bg-slate-900 rounded text-xs text-slate-500 space-y-2">
            <div className="font-semibold text-slate-400">CHR Banks</div>
            <p>
              The DataPointer determines which CHR graphics bank is used to render tiles.
              Different areas of the game use different banks:
            </p>
            <ul className="space-y-1 text-slate-500">
              {CHR_BANK_PRESETS.map((preset) => (
                <li key={preset.value} className="flex justify-between">
                  <span className="font-mono">0x{preset.label}</span>
                  <span>{preset.description}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
