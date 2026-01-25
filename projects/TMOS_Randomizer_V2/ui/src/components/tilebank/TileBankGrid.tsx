import { useEffect, useRef, useState } from 'react';
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

interface TileBankGridProps {
  tiles: TileBankEntry[];
  selectedIndex: number | null;
  onSelectTile: (index: number) => void;
}

function TileCell({
  tile,
  isSelected,
  onSelect,
  cellRef,
}: {
  tile: TileBankEntry;
  isSelected: boolean;
  onSelect: () => void;
  cellRef: React.RefObject<HTMLButtonElement> | null;
}) {
  const [imgError, setImgError] = useState(false);
  const hex = tile.index.toString(16).toUpperCase().padStart(2, '0');

  return (
    <button
      ref={cellRef}
      onClick={onSelect}
      className={`
        relative w-10 h-10 overflow-hidden
        transition-all duration-100
        ${isSelected
          ? 'ring-2 ring-blue-400 z-10 scale-110'
          : 'hover:ring-1 hover:ring-slate-400'
        }
      `}
      title={`Tile 0x${hex} [${tile.minitiles.map(m => '0x' + m.toString(16).toUpperCase().padStart(2, '0')).join(', ')}]`}
    >
      {!imgError ? (
        <img
          src={getTileImageUrl(tile.index)}
          alt={`Tile 0x${hex}`}
          className="w-full h-full object-cover"
          style={{ imageRendering: 'pixelated' }}
          onError={() => setImgError(true)}
        />
      ) : (
        <div className="w-full h-full flex items-center justify-center text-xs font-mono bg-slate-700 text-slate-400">
          0x{hex}
        </div>
      )}
      {/* Hex overlay on hover */}
      <div className="absolute inset-0 bg-black/60 opacity-0 hover:opacity-100 transition-opacity flex items-center justify-center">
        <span className="text-white text-xs font-mono">0x{hex}</span>
      </div>
      {/* Selection indicator */}
      {isSelected && (
        <div className="absolute inset-0 border-2 border-blue-400 pointer-events-none" />
      )}
    </button>
  );
}

export function TileBankGrid({ tiles, selectedIndex, onSelectTile }: TileBankGridProps) {
  const selectedRef = useRef<HTMLButtonElement>(null);

  // Scroll selected tile into view when it changes
  useEffect(() => {
    if (selectedRef.current) {
      selectedRef.current.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }, [selectedIndex]);

  return (
    <div className="grid grid-cols-16 gap-0.5 p-2 bg-slate-900 rounded-lg">
      {tiles.map((tile) => (
        <TileCell
          key={tile.index}
          tile={tile}
          isSelected={tile.index === selectedIndex}
          onSelect={() => onSelectTile(tile.index)}
          cellRef={tile.index === selectedIndex ? selectedRef : null}
        />
      ))}
    </div>
  );
}
