import type { ScreenData } from '../../api/client';

interface ScreenRendererProps {
  screen: ScreenData;
  chapterNum: number;
  scale?: number;
  showOverlay?: boolean;
  showInfo?: boolean;
  selected?: boolean;
  onClick?: () => void;
}

// Base screen dimensions (8 tiles × 6 tiles, each tile is 64px metatile)
// Full rendered size at scale=1 is 512x384
const BASE_WIDTH = 512;  // 8 tiles * 64px
const BASE_HEIGHT = 384; // 6 tiles * 64px

// API base URL
const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Get the rendered screen image URL
function getScreenRenderUrl(chapterNum: number, screenIndex: number, scale: number = 4): string {
  return `${API_BASE}/api/rom/render/${chapterNum}/${screenIndex}?scale=${scale}`;
}

export function ScreenRenderer({
  screen,
  chapterNum,
  scale = 1,
  showOverlay = false,
  showInfo = false,
  selected = false,
  onClick,
}: ScreenRendererProps) {
  // Use API scale of 1 (gives 512x384), then CSS scale for display
  const apiScale = 1;
  const renderUrl = getScreenRenderUrl(chapterNum, screen.index, apiScale);

  // Display dimensions - scale from base size
  const displayWidth = BASE_WIDTH * scale;
  const displayHeight = BASE_HEIGHT * scale;

  return (
    <div
      className={`relative inline-block cursor-pointer transition-all ${
        selected ? 'ring-2 ring-yellow-400 z-10' : 'hover:ring-2 hover:ring-white/50'
      }`}
      style={{ 
        width: displayWidth, 
        height: displayHeight,
        backgroundColor: getGroundColor(screen.worldscreen_color),
      }}
      onClick={onClick}
      title={`Screen ${screen.index} (0x${screen.index.toString(16).toUpperCase()})`}
    >
      {/* Rendered screen image from API */}
      <img
        src={renderUrl}
        alt={`Screen ${screen.index}`}
        className="w-full h-full object-cover"
        style={{ imageRendering: 'pixelated' }}
        onError={(e) => {
          // Fallback to a colored div if rendering fails
          e.currentTarget.style.display = 'none';
          const fallback = e.currentTarget.nextElementSibling as HTMLElement;
          if (fallback) fallback.style.display = 'flex';
        }}
      />

      {/* Fallback colored div */}
      <div
        className="absolute inset-0 items-center justify-center text-white text-xs font-bold hidden"
        style={{
          backgroundColor: getParentWorldColor(screen.parent_world),
        }}
      >
        {screen.index.toString(16).toUpperCase()}
      </div>

      {/* Overlay with screen index */}
      {showOverlay && (
        <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
          <span className="text-white font-mono text-sm font-bold drop-shadow-lg">
            {screen.index.toString(16).toUpperCase()}
          </span>
        </div>
      )}

      {/* Info panel */}
      {showInfo && (
        <div className="absolute bottom-0 left-0 right-0 bg-black/80 text-white text-[8px] p-1 font-mono">
          <div>0x{screen.index.toString(16).toUpperCase()} ({screen.index})</div>
          <div>DP:{screen.datapointer} Top:{screen.top_tiles.toString(16).toUpperCase()}</div>
          <div>Bot:{screen.bottom_tiles.toString(16).toUpperCase()} OS:{screen.objectset}</div>
        </div>
      )}
    </div>
  );
}

// Mini version for overview grids - uses rendered screen images
export function ScreenMini({
  screen,
  chapterNum,
  size = 64,
  selected = false,
  onClick,
  showIndex = true,
}: {
  screen: ScreenData;
  chapterNum: number;
  size?: number;
  selected?: boolean;
  onClick?: () => void;
  showIndex?: boolean;
}) {
  // Use API scale 1 (512x384), CSS will resize to thumbnail
  const apiScale = 1;
  const renderUrl = getScreenRenderUrl(chapterNum, screen.index, apiScale);

  // Aspect ratio: 512x384 base (4:3)
  const width = size;
  const height = Math.round(size * (BASE_HEIGHT / BASE_WIDTH));

  return (
    <div
      className={`relative cursor-pointer transition-all ${
        selected ? 'ring-2 ring-yellow-400 z-10' : 'hover:ring-1 hover:ring-white/50'
      }`}
      style={{ 
        width, 
        height,
        backgroundColor: getGroundColor(screen.worldscreen_color),
      }}
      onClick={onClick}
      title={`Screen ${screen.index} (0x${screen.index.toString(16).toUpperCase()})`}
    >
      <img
        src={renderUrl}
        alt={`Screen ${screen.index}`}
        className="w-full h-full object-cover"
        style={{ imageRendering: 'pixelated' }}
        onError={(e) => {
          e.currentTarget.style.display = 'none';
          const fallback = e.currentTarget.nextElementSibling as HTMLElement;
          if (fallback) fallback.style.display = 'flex';
        }}
      />
      {/* Fallback colored div when image fails */}
      <div
        className="absolute inset-0 items-center justify-center text-white text-[10px] font-bold hidden"
        style={{ backgroundColor: getParentWorldColor(screen.parent_world) }}
      >
        {screen.index.toString(16).toUpperCase().padStart(2, '0')}
      </div>
      {/* Screen index overlay - always visible */}
      {showIndex && (
        <div className="absolute top-0 left-0 bg-black/70 text-white text-[8px] font-mono px-1 leading-tight">
          {screen.index.toString(16).toUpperCase().padStart(2, '0')}
        </div>
      )}
    </div>
  );
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

function getParentWorldColor(parentWorld: number): string {
  const colors: Record<number, string> = {
    0x00: '#2563eb', // Overworld - blue
    0x01: '#16a34a', // Town - green
    0x02: '#dc2626', // Dungeon - red
    0x03: '#9333ea', // Maze - purple
    0x04: '#f59e0b', // Special - amber
    0x05: '#06b6d4', // Boss - cyan
  };
  return colors[parentWorld] || '#64748b';
}
