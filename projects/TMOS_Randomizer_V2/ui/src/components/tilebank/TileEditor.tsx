import { useState, useEffect } from 'react';
import type { TileBankEntry } from '../../api/client';

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

function getTileImageUrl(tileId: number): string {
  const filename = getTileFileName(tileId);
  // Use static tiles from ui/public/tiles (served by Vite dev server)
  return `/tiles/${filename}`;
}

interface TileEditorProps {
  tile: TileBankEntry;
  onSave: (minitiles: [number, number, number, number]) => Promise<void>;
}

export function TileEditor({ tile, onSave }: TileEditorProps) {
  const [minitiles, setMinitiles] = useState<[string, string, string, string]>([
    tile.minitiles[0].toString(16).toUpperCase().padStart(2, '0'),
    tile.minitiles[1].toString(16).toUpperCase().padStart(2, '0'),
    tile.minitiles[2].toString(16).toUpperCase().padStart(2, '0'),
    tile.minitiles[3].toString(16).toUpperCase().padStart(2, '0'),
  ]);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [imgError, setImgError] = useState(false);

  // Reset form when tile changes
  useEffect(() => {
    setMinitiles([
      tile.minitiles[0].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[1].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[2].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[3].toString(16).toUpperCase().padStart(2, '0'),
    ]);
    setError(null);
    setImgError(false);
  }, [tile.index, tile.minitiles]);

  const handleChange = (index: number, value: string) => {
    // Only allow hex characters
    const cleaned = value.replace(/[^0-9A-Fa-f]/g, '').toUpperCase().slice(0, 2);
    const newMinitiles = [...minitiles] as [string, string, string, string];
    newMinitiles[index] = cleaned;
    setMinitiles(newMinitiles);
    setError(null);
  };

  const hasChanges = () => {
    return minitiles.some((m, i) => {
      const originalHex = tile.minitiles[i].toString(16).toUpperCase().padStart(2, '0');
      return m !== originalHex;
    });
  };

  const isValid = () => {
    return minitiles.every((m) => {
      if (m.length === 0) return false;
      const value = parseInt(m, 16);
      return !isNaN(value) && value >= 0 && value <= 255;
    });
  };

  const handleSave = async () => {
    if (!isValid()) {
      setError('All values must be valid hex (00-FF)');
      return;
    }

    setSaving(true);
    setError(null);

    try {
      const values: [number, number, number, number] = [
        parseInt(minitiles[0], 16),
        parseInt(minitiles[1], 16),
        parseInt(minitiles[2], 16),
        parseInt(minitiles[3], 16),
      ];
      await onSave(values);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save');
    } finally {
      setSaving(false);
    }
  };

  const handleReset = () => {
    setMinitiles([
      tile.minitiles[0].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[1].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[2].toString(16).toUpperCase().padStart(2, '0'),
      tile.minitiles[3].toString(16).toUpperCase().padStart(2, '0'),
    ]);
    setError(null);
  };

  const labels = ['TL', 'TR', 'BL', 'BR'];

  return (
    <div className="bg-slate-800 rounded-lg p-4 space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-slate-200">
          Tile 0x{tile.hex_index}
        </h3>
        <span className="text-xs text-slate-500 font-mono">
          ROM: {tile.rom_offset}
        </span>
      </div>

      {/* Tile Image Preview */}
      <div className="flex justify-center">
        <div className="p-3 bg-slate-900 rounded">
          {!imgError ? (
            <img
              src={getTileImageUrl(tile.index)}
              alt={`Tile ${tile.hex_index}`}
              className="w-24 h-24 border border-slate-600 rounded"
              style={{ imageRendering: 'pixelated' }}
              onError={() => setImgError(true)}
            />
          ) : (
            <div className="w-24 h-24 bg-slate-700 flex items-center justify-center text-lg font-mono text-slate-400 border border-slate-600 rounded">
              {tile.hex_index}
            </div>
          )}
        </div>
      </div>

      {/* 2x2 MiniTile Grid */}
      <div>
        <div className="text-xs text-slate-500 uppercase tracking-wide mb-2 text-center">
          MiniTile Composition (2x2)
        </div>
        <div className="flex justify-center">
          <div className="grid grid-cols-2 gap-1 p-2 bg-slate-900 rounded">
            {minitiles.map((m, i) => (
              <div
                key={i}
                className="w-10 h-10 bg-slate-700 flex items-center justify-center text-xs font-mono text-slate-300 rounded border border-slate-600"
                title={`${labels[i]}: 0x${m || '??'}`}
              >
                {m || '??'}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Hex Inputs */}
      <div className="space-y-3">
        <div className="text-xs text-slate-500 uppercase tracking-wide">
          MiniTile IDs (Hex)
        </div>
        <div className="grid grid-cols-2 gap-3">
          {labels.map((label, index) => (
            <div key={label} className="flex items-center gap-2">
              <label className="text-sm text-slate-400 w-6">{label}:</label>
              <div className="flex items-center">
                <span className="text-slate-500 text-sm mr-1">0x</span>
                <input
                  type="text"
                  value={minitiles[index]}
                  onChange={(e) => handleChange(index, e.target.value)}
                  className={`
                    w-12 px-2 py-1 text-sm font-mono text-center rounded
                    bg-slate-900 border focus:outline-none focus:ring-1
                    ${minitiles[index].length === 0 || parseInt(minitiles[index], 16) > 255
                      ? 'border-red-500 text-red-400 focus:ring-red-500'
                      : 'border-slate-600 text-slate-200 focus:ring-blue-500'
                    }
                  `}
                  placeholder="00"
                  maxLength={2}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="text-sm text-red-400 bg-red-500/10 px-3 py-2 rounded">
          {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex gap-2">
        <button
          onClick={handleSave}
          disabled={!hasChanges() || !isValid() || saving}
          className={`
            flex-1 px-4 py-2 text-sm font-medium rounded transition-colors
            ${hasChanges() && isValid() && !saving
              ? 'bg-blue-600 hover:bg-blue-500 text-white'
              : 'bg-slate-700 text-slate-500 cursor-not-allowed'
            }
          `}
        >
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
        <button
          onClick={handleReset}
          disabled={!hasChanges() || saving}
          className={`
            px-4 py-2 text-sm font-medium rounded transition-colors
            ${hasChanges() && !saving
              ? 'bg-slate-600 hover:bg-slate-500 text-slate-200'
              : 'bg-slate-700 text-slate-500 cursor-not-allowed'
            }
          `}
        >
          Reset
        </button>
      </div>

      {/* Original Values Reference */}
      <div className="text-xs text-slate-500 pt-2 border-t border-slate-700">
        Original: [{tile.minitiles.map(m => '0x' + m.toString(16).toUpperCase().padStart(2, '0')).join(', ')}]
      </div>
    </div>
  );
}
