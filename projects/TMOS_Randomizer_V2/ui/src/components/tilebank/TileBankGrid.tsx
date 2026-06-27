import { useEffect, useRef, useState } from 'react';
import type { TileBankEntry } from '../../api/client';
import { api } from '../../api/client';

interface TileBankGridProps {
  tiles: TileBankEntry[];
  selectedIndex: number | null;
  onSelectTile: (index: number) => void;
  /** CHR bank index (0-63) used to render tile graphics. */
  chr: number;
}

function TileCell({
  tile,
  isSelected,
  onSelect,
  cellRef,
  chr,
}: {
  tile: TileBankEntry;
  isSelected: boolean;
  onSelect: () => void;
  cellRef: React.RefObject<HTMLButtonElement | null> | null;
  chr: number;
}) {
  const hex = tile.index.toString(16).toUpperCase().padStart(2, '0');

  // CHR-aware render URL: including chr as a query param ensures the browser
  // re-fetches whenever the CHR bank changes (different URL = new request).
  const imgSrc = api.getTileBankTileRenderUrl(tile.index, chr, 4);

  // Track the URL that last caused an error. When imgSrc changes (new CHR bank),
  // the derived `imgError` becomes false without needing an effect.
  const [errorSrc, setErrorSrc] = useState<string | null>(null);
  const imgError = errorSrc === imgSrc;

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
          src={imgSrc}
          alt={`Tile 0x${hex}`}
          className="w-full h-full object-cover"
          style={{ imageRendering: 'pixelated' }}
          onError={() => setErrorSrc(imgSrc)}
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

export function TileBankGrid({ tiles, selectedIndex, onSelectTile, chr }: TileBankGridProps) {
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
          chr={chr}
        />
      ))}
    </div>
  );
}
