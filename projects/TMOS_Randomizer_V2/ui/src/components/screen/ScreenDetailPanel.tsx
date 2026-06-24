import type { ScreenData } from '../../api/client';
import { ScreenRenderer } from './ScreenRenderer';
import { Tooltip } from '../shared/Tooltip';
import { formatScreenId } from '../../utils/formatters';
import { CONTENT_TYPES, CHAPTER_NPCS, EVENT_TYPES } from './screenEnums';

interface ScreenDetailPanelProps {
  screen: ScreenData;
  chapterNum: number;
  screens?: ScreenData[];  // All screens for lookup
  onScreenSelect?: (index: number) => void;  // Navigate to screen
  onEdit?: (half: 'top' | 'bottom') => void;  // Request the WorldView-owned editor
  onClose?: () => void;
}

// Parent world/section types - CORRECTED naming per ROM analysis
// NOTE: ParentWorld values vary by chapter - same value can mean different things
// WARNING: Towns (0x10, 0x20) share same ParentWorld on BOTH sides of Time Door
const PARENT_WORLD_TYPES: Record<number, { name: string; color: string }> = {
  0x00: { name: 'Overworld', color: '#22c55e' },
  0x10: { name: 'Town A', color: '#3b82f6' },
  0x20: { name: 'Town B', color: '#6366f1' },
  0x40: { name: 'Overworld', color: '#22c55e' },  // Ch1/3: Overworld, Ch4: Past area
  0x50: { name: 'Maze', color: '#f97316' },       // Was incorrectly "Dungeon (Deep)"
  0x60: { name: 'Dungeon', color: '#a855f7' },    // Was incorrectly "Palace"
  0x70: { name: 'Special', color: '#eab308' },
  0x80: { name: 'Special', color: '#eab308' },
  0xA0: { name: 'Boss Area', color: '#ef4444' },
  0xAC: { name: 'Boss Area', color: '#ef4444' },
  0xC0: { name: 'Boss Area', color: '#ef4444' },
  0xE0: { name: 'Overworld', color: '#22c55e' },  // Ch2 overworld present
};

export function ScreenDetailPanel({ screen, chapterNum, screens, onScreenSelect, onEdit, onClose }: ScreenDetailPanelProps) {
  const contentInfo = getContentInfo(screen.content, chapterNum);
  const eventInfo = getEventInfo(screen.event);
  const parentInfo = getParentWorldInfo(screen.parent_world);
  const screenId = formatScreenId(screen.index, screen.global_index, chapterNum);

  // Time period is authoritative from the backend (core.enums.PAST_SCREEN_INDICES),
  // served per-screen as `is_past`. Do NOT re-derive it in the UI.
  const isPast = screen.is_past ?? false;
  const timePeriod = isPast ? 'PAST' : 'PRESENT';

  // Determine if this is a stairway
  const isStairway = screen.event === 0x40;
  const stairwayDest = isStairway ? screen.content : null;
  const stairwayDestScreen = stairwayDest !== null ? screens?.find(s => s.index === stairwayDest) : null;

  // Determine CHR bank info from datapointer
  const chrBankIndex = screen.datapointer & 0x3F;
  const topTileBank = (screen.datapointer & 0x80) ? 1 : 0;
  const bottomTileBank = (screen.datapointer & 0x40) ? 1 : 0;

  const openEditor = (half: 'top' | 'bottom') => onEdit?.(half);

  return (
    <div className="bg-slate-800 h-full overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 bg-slate-800 z-10 flex items-center justify-between p-3 border-b border-slate-700">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="font-semibold text-slate-200">
              Screen {screenId.short}
            </h3>
            <span className={`px-2 py-0.5 rounded text-xs font-bold ${
              isPast
                ? 'bg-amber-500/20 text-amber-400 border border-amber-500/30'
                : 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
            }`}>
              {timePeriod}
            </span>
          </div>
          <span className="text-xs text-slate-500 font-mono">
            {screenId.global}
          </span>
        </div>
        {onClose && (
          <button onClick={onClose} className="text-slate-400 hover:text-white text-xl">
            &times;
          </button>
        )}
      </div>

      {/* Screen Preview */}
      <div className="p-4 flex justify-center bg-slate-900 border-b border-slate-700">
        <ScreenRenderer screen={screen} chapterNum={chapterNum} scale={0.5} showInfo={false} />
      </div>

      {/* Content Type - Prominent Display */}
      {contentInfo && (
        <div className={`p-3 border-b border-slate-700 ${getCategoryBg(contentInfo.category)}`}>
          <div className="flex items-center gap-2">
            <span className="text-lg">{getCategoryIcon(contentInfo.category)}</span>
            <div>
              <div className="font-medium text-slate-100">{contentInfo.name}</div>
              {contentInfo.description && (
                <div className="text-xs text-slate-300">{contentInfo.description}</div>
              )}
            </div>
          </div>
          <div className="text-xs text-slate-400 mt-1 font-mono">
            Content: 0x{screen.content.toString(16).toUpperCase().padStart(2, '0')}
          </div>
        </div>
      )}

      {/* Event Type */}
      {eventInfo && screen.event !== 0 && (
        <div className="p-3 border-b border-slate-700 bg-amber-500/10">
          <div className="flex items-center gap-2">
            <span className="text-amber-400">Event:</span>
            <span className="font-medium text-amber-200">{eventInfo.name}</span>
          </div>
          <div className="text-xs text-amber-300/80 mt-1">{eventInfo.description}</div>
          {isStairway && stairwayDest !== null && (
            <div className="text-xs text-amber-400 mt-1">
              Leads to{' '}
              {onScreenSelect ? (
                <button
                  onClick={() => onScreenSelect(stairwayDest)}
                  className="underline hover:text-amber-200 transition-colors"
                >
                  Screen {formatScreenId(stairwayDest, stairwayDestScreen?.global_index ?? stairwayDest).short}
                </button>
              ) : (
                <span>Screen {formatScreenId(stairwayDest, stairwayDestScreen?.global_index ?? stairwayDest).short}</span>
              )}
            </div>
          )}
        </div>
      )}

      {/* Data Sections */}
      <div className="p-4 space-y-4">
        {/* Section/World Info */}
        <DataSection title="Section Info">
          {/* Time Period - prominent display */}
          <div className="flex items-center justify-between mb-2">
            <span className="text-slate-500">Time Period</span>
            <span className={`font-bold ${isPast ? 'text-amber-400' : 'text-emerald-400'}`}>
              {timePeriod}
            </span>
          </div>
          <div className="flex items-center justify-between mb-2">
            <span className="text-slate-500">Parent World</span>
            <div className="flex items-center gap-2">
              <div
                className="w-3 h-3 rounded"
                style={{ backgroundColor: parentInfo?.color || '#64748b' }}
              />
              <span className="text-slate-200">{parentInfo?.name || 'Unknown'}</span>
            </div>
          </div>
          <DataRow label="Parent World ID" value={`0x${screen.parent_world.toString(16).toUpperCase()}`} />
          <DataRow label="Screen Index" value={screen.index.toString()} />
        </DataSection>

        {/* Navigation */}
        <DataSection title="Navigation">
          <div className="grid grid-cols-3 gap-2 text-center mb-3">
            <div />
            <NavCell
              direction="Up"
              value={screen.nav_up}
              screens={screens}
              chapterNum={chapterNum}
              onScreenSelect={onScreenSelect}
            />
            <div />
            <NavCell
              direction="Left"
              value={screen.nav_left}
              screens={screens}
              chapterNum={chapterNum}
              onScreenSelect={onScreenSelect}
            />
            <div className="bg-blue-500/20 rounded p-2 text-xs text-blue-300 font-mono">
              {screenId.compact}
            </div>
            <NavCell
              direction="Right"
              value={screen.nav_right}
              screens={screens}
              chapterNum={chapterNum}
              onScreenSelect={onScreenSelect}
            />
            <div />
            <NavCell
              direction="Down"
              value={screen.nav_down}
              screens={screens}
              chapterNum={chapterNum}
              onScreenSelect={onScreenSelect}
            />
            <div />
          </div>
          <div className="text-xs text-slate-500 text-center">
            Click a direction to navigate
          </div>
        </DataSection>

        {/* Tile Data */}
        <DataSection title="Graphics (DataPointer)">
          <DataRow label="DataPointer" value={`0x${screen.datapointer.toString(16).toUpperCase()}`} />
          <DataRow label="CHR Bank Index" value={`0x${chrBankIndex.toString(16).toUpperCase()} (${chrBankIndex})`} />
          <DataRow label="Top Tile Bank" value={`Bank ${topTileBank}`} />
          <DataRow label="Bottom Tile Bank" value={`Bank ${bottomTileBank}`} />
          <div className="border-t border-slate-700 mt-2 pt-2 space-y-1">
            <div className="flex justify-between text-sm items-center">
              <span className="text-slate-500">Top TileSection</span>
              <button
                onClick={() => openEditor('top')}
                className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
                title="Open the screen editor on the top section"
              >
                0x{screen.top_tiles.toString(16).toUpperCase()} ({screen.top_tiles})
              </button>
            </div>
            <div className="flex justify-between text-sm items-center">
              <span className="text-slate-500">Bottom TileSection</span>
              <button
                onClick={() => openEditor('bottom')}
                className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
                title="Open the screen editor on the bottom section"
              >
                0x{screen.bottom_tiles.toString(16).toUpperCase()} ({screen.bottom_tiles})
              </button>
            </div>
          </div>
        </DataSection>

        {/* ObjectSet */}
        <DataSection title="Enemy Spawning">
          <div className="flex justify-between text-sm items-center">
            <span className="text-slate-500">ObjectSet</span>
            <button
              onClick={() => openEditor('top')}
              className="text-slate-200 font-mono px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 hover:ring-1 hover:ring-blue-400 transition-all"
              title="Open the screen editor to change ObjectSet"
            >
              0x{screen.objectset.toString(16).toUpperCase()} ({screen.objectset})
            </button>
          </div>
          <div className="text-xs text-slate-500 mt-1">
            {getObjectSetDescription(screen.objectset)}
          </div>
        </DataSection>

        {/* Colors */}
        <DataSection title="Palettes">
          <div className="flex gap-2 mb-2">
            <div className="flex-1 bg-slate-800 rounded p-2 text-center">
              <div className="text-xs text-slate-500 mb-1">World Color</div>
              <div className="font-mono text-slate-200">0x{screen.worldscreen_color.toString(16).toUpperCase()}</div>
            </div>
            <div className="flex-1 bg-slate-800 rounded p-2 text-center">
              <div className="text-xs text-slate-500 mb-1">Sprite Color</div>
              <div className="font-mono text-slate-200">0x{screen.sprites_color.toString(16).toUpperCase()}</div>
            </div>
          </div>
          <DataRow label="Exit Position" value={`0x${screen.exit_position.toString(16).toUpperCase()}`} />
        </DataSection>

        {/* Raw Data */}
        <DataSection title="Raw Data">
          <div className="font-mono text-xs text-slate-400 break-all">
            [{screen.parent_world.toString(16).padStart(2, '0')}, {screen.objectset.toString(16).padStart(2, '0')}, {screen.content.toString(16).padStart(2, '0')}, {screen.event.toString(16).padStart(2, '0')}, {screen.nav_right.toString(16).padStart(2, '0')}, {screen.nav_left.toString(16).padStart(2, '0')}, {screen.nav_down.toString(16).padStart(2, '0')}, {screen.nav_up.toString(16).padStart(2, '0')}, ...]
          </div>
        </DataSection>
      </div>

    </div>
  );
}

function getContentInfo(content: number, chapterNum: number): { name: string; category: string; description?: string } | null {
  // Check chapter-specific NPCs first
  if (content >= 0x80 && content <= 0x9F) {
    const chapterNpcs = CHAPTER_NPCS[chapterNum];
    if (chapterNpcs?.[content]) {
      return { ...chapterNpcs[content], category: 'npc' };
    }
    return { name: `NPC 0x${content.toString(16).toUpperCase()}`, category: 'npc' };
  }

  // Check hotel range
  if (content >= 0xA0 && content <= 0xB0) {
    return CONTENT_TYPES[content] || { name: 'Hotel', category: 'hotel' };
  }

  return CONTENT_TYPES[content] || null;
}

function getEventInfo(event: number): { name: string; description: string } | null {
  return EVENT_TYPES[event] || (event !== 0 ? { name: `Event 0x${event.toString(16).toUpperCase()}`, description: 'Unknown event type' } : null);
}

function getParentWorldInfo(parentWorld: number): { name: string; color: string } | null {
  // Check exact match first
  if (PARENT_WORLD_TYPES[parentWorld]) {
    return PARENT_WORLD_TYPES[parentWorld];
  }
  // Check by high nibble
  const highNibble = parentWorld & 0xF0;
  return PARENT_WORLD_TYPES[highNibble] || null;
}

function getCategoryIcon(category: string): string {
  const icons: Record<string, string> = {
    'shop': '🏪',
    'magic-shop': '✨',
    'mosque': '🕌',
    'hotel': '🏨',
    'university': '🎓',
    'boss': '👹',
    'battle': '⚔️',
    'npc': '👤',
    'special': '⭐',
    'time-door': '🚪',
    'service': '🛎️',
  };
  return icons[category] || '📍';
}

function getCategoryBg(category: string): string {
  const colors: Record<string, string> = {
    'shop': 'bg-green-500/10',
    'magic-shop': 'bg-purple-500/10',
    'mosque': 'bg-blue-500/10',
    'hotel': 'bg-cyan-500/10',
    'university': 'bg-indigo-500/10',
    'boss': 'bg-red-500/10',
    'battle': 'bg-orange-500/10',
    'npc': 'bg-teal-500/10',
    'special': 'bg-yellow-500/10',
    'time-door': 'bg-pink-500/10',
    'service': 'bg-slate-500/10',
  };
  return colors[category] || 'bg-slate-500/10';
}

function getObjectSetDescription(objectSet: number): string {
  if (objectSet === 0x00) return 'Empty - no enemy spawns';
  if (objectSet >= 0x01 && objectSet <= 0x02) return 'Dungeon/staircase area';
  if (objectSet >= 0x03 && objectSet <= 0x15) return 'Overworld enemies';
  if (objectSet >= 0x16 && objectSet <= 0x33) return 'Town NPCs (non-hostile)';
  if (objectSet >= 0x34 && objectSet <= 0x40) return 'Dungeon/maze enemies';
  if (objectSet >= 0x36 && objectSet <= 0x37) return 'Special area';
  return 'Enemy configuration';
}

function DataSection({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <h4 className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-2">{title}</h4>
      <div className="bg-slate-900 rounded-lg p-3 space-y-1">
        {children}
      </div>
    </div>
  );
}

function DataRow({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="flex justify-between text-sm">
      <span className="text-slate-500">{label}</span>
      <span className="text-slate-200 font-mono">{value}</span>
    </div>
  );
}

interface NavCellProps {
  direction: string;
  value: number;
  screens?: ScreenData[];
  chapterNum?: number;
  onScreenSelect?: (index: number) => void;
}

function NavCell({ direction, value, screens, chapterNum, onScreenSelect }: NavCellProps) {
  const isBlocked = value === 0xFF;
  const isBuilding = value === 0xFE;
  const isValid = !isBlocked && !isBuilding;

  // Get destination screen info for tooltip
  const destScreen = isValid && screens ? screens.find(s => s.index === value) : null;
  const destScreenId = destScreen
    ? formatScreenId(destScreen.index, destScreen.global_index, chapterNum)
    : isValid
    ? formatScreenId(value, value)
    : null;
  const destContentInfo = destScreen ? getContentInfo(destScreen.content, chapterNum ?? 1) : null;
  const destParentInfo = destScreen ? getParentWorldInfo(destScreen.parent_world) : null;

  let bgColor = 'bg-slate-700';
  let textColor = 'text-slate-300';
  let displayValue: string;

  if (isBlocked) {
    bgColor = 'bg-red-500/20';
    textColor = 'text-red-400';
    displayValue = '✕';
  } else if (isBuilding) {
    bgColor = 'bg-amber-500/20';
    textColor = 'text-amber-400';
    displayValue = '🏠';
  } else {
    bgColor = 'bg-green-500/20';
    textColor = 'text-green-400';
    displayValue = destScreenId?.compact ?? value.toString();
  }

  const isClickable = isValid && onScreenSelect;

  // Build tooltip content
  const tooltipContent = isBlocked ? (
    <span>Blocked (no exit)</span>
  ) : isBuilding ? (
    <div>
      <div className="font-medium">Building Entrance</div>
      <div className="text-slate-400 text-xs">Enter building interior</div>
    </div>
  ) : destScreen ? (
    <div className="space-y-1">
      <div className="font-medium">Screen {destScreenId?.short}</div>
      <div className="text-slate-400 text-xs">{destScreenId?.global}</div>
      {destParentInfo && (
        <div className="flex items-center gap-1.5 text-xs">
          <div
            className="w-2 h-2 rounded"
            style={{ backgroundColor: destParentInfo.color }}
          />
          <span className="text-slate-300">{destParentInfo.name}</span>
        </div>
      )}
      {destContentInfo && (
        <div className="text-xs text-slate-300">
          {getCategoryIcon(destContentInfo.category)} {destContentInfo.name}
        </div>
      )}
      {isClickable && (
        <div className="text-xs text-blue-400 mt-1">Click to navigate</div>
      )}
    </div>
  ) : (
    <span>Screen {destScreenId?.short}</span>
  );

  const cell = (
    <div
      className={`${bgColor} rounded p-2 transition-all ${
        isClickable ? 'cursor-pointer hover:ring-2 hover:ring-blue-400' : ''
      }`}
      onClick={isClickable ? () => onScreenSelect(value) : undefined}
    >
      <div className="text-[10px] text-slate-500 mb-0.5">{direction}</div>
      <div className={`${textColor} font-mono text-xs`}>{displayValue}</div>
    </div>
  );

  return (
    <Tooltip content={tooltipContent} position="top" delay={150}>
      {cell}
    </Tooltip>
  );
}
