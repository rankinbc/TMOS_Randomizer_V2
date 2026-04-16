import type { ScreenData } from '../../api/client';
import { ScreenRenderer } from './ScreenRenderer';
import { Tooltip } from '../shared/Tooltip';
import { formatScreenId } from '../../utils/formatters';

interface ScreenDetailPanelProps {
  screen: ScreenData;
  chapterNum: number;
  screens?: ScreenData[];  // All screens for lookup
  onScreenSelect?: (index: number) => void;  // Navigate to screen
  onClose?: () => void;
}

// Content type descriptions from knowledge/enums/content-types.md
const CONTENT_TYPES: Record<number, { name: string; category: string; description?: string }> = {
  0x00: { name: 'Empty', category: 'special', description: 'Normal screen, no building' },
  0x01: { name: 'Wizard Battle', category: 'battle', description: 'Triggers wizard battle on entry' },
  0x1D: { name: 'Frozen Palace', category: 'special', description: 'Frozen Palace area' },
  0x20: { name: 'First Mosque', category: 'mosque', description: '"Will you defeat Sabaron?" dialog' },
  // Boss demons
  0x21: { name: 'Gilga Phase 1', category: 'boss', description: 'Chapter 1 boss - first phase' },
  0x22: { name: 'Gilga Phase 2', category: 'boss', description: 'Chapter 1 boss - second phase' },
  0x23: { name: 'Curly Phase 1', category: 'boss', description: 'Chapter 2 boss - first phase' },
  0x24: { name: 'Curly Phase 2', category: 'boss', description: 'Chapter 2 boss - second phase' },
  0x25: { name: 'Troll Phase 1', category: 'boss', description: 'Chapter 3 boss - first phase' },
  0x26: { name: 'Troll Phase 2', category: 'boss', description: 'Chapter 3 boss - second phase' },
  0x27: { name: 'Salamander Phase 1', category: 'boss', description: 'Chapter 4 boss - first phase' },
  0x28: { name: 'Salamander Phase 2', category: 'boss', description: 'Chapter 4 boss - second phase' },
  0x29: { name: 'GoraGora Phase 1', category: 'boss', description: 'Chapter 5 boss - first phase' },
  0x2A: { name: 'GoraGora Phase 2', category: 'boss', description: 'Chapter 5 boss - second phase' },
  0x2B: { name: 'Princess Victory', category: 'special', description: 'Post-boss victory screen' },
  // Universities
  0x40: { name: 'University', category: 'university', description: 'Magic training (Cygnus)' },
  0x41: { name: 'University', category: 'university', description: 'Magic training (World 2)' },
  0x42: { name: 'University', category: 'university', description: 'Magic training (World 3)' },
  0x43: { name: 'University', category: 'university', description: 'Magic training (World 4)' },
  0x44: { name: 'University', category: 'university', description: 'Magic training (World 5)' },
  0x50: { name: 'University Monecom', category: 'university' },
  0x55: { name: 'University Alalart', category: 'university' },
  // Shops — per-Content-byte stock lists were unverified guesses. Real shop
  // inventory lives in a Bank 2 bytecode interpreter that has not been decoded.
  // See TMOS_AI/docs/human/items-economy-re-answers.md.
  0x60: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x61: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x62: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x63: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x64: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x65: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x66: { name: 'Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x75: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x76: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x77: { name: 'Magic Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x78: { name: 'Formation Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x79: { name: 'Mixed Shop', category: 'magic-shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7B: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7C: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  0x7D: { name: 'Unused Shop', category: 'shop', description: 'Inventory not yet decoded (Bank 2 RE pending)' },
  // Services
  0x7E: { name: 'Mosque', category: 'mosque', description: 'Class change, save, revive' },
  0x7F: { name: 'Trooper Hire', category: 'service', description: 'Hire trooper soldiers' },
  // Hotels
  0xA0: { name: 'Hotel (10 Rupias)', category: 'hotel' },
  0xA1: { name: 'Hotel', category: 'hotel' },
  0xA2: { name: 'Hotel', category: 'hotel' },
  0xA3: { name: 'Hotel', category: 'hotel' },
  0xB0: { name: 'Hotel (169 Rupias)', category: 'hotel', description: 'Expensive hotel' },
  // Special locations
  0xBC: { name: 'Rupia Seed Plant', category: 'special', description: 'Plant rupia seed location' },
  0xBD: { name: 'Rupia Tree', category: 'special', description: 'Grown rupia tree' },
  0xBE: { name: 'Casino', category: 'special', description: 'Gambling mini-games' },
  0xC0: { name: 'Time Door (Enter)', category: 'time-door', description: 'Time travel entrance' },
  0xC7: { name: 'Time Door (Exit)', category: 'time-door', description: 'Time travel exit' },
  0xD7: { name: 'Time Door (Exit)', category: 'time-door', description: 'Time travel exit variant' },
  0xFF: { name: 'Random Battle', category: 'battle', description: 'Random encounter area' },
};

// Chapter-specific NPCs (0x80-0x8F range)
const CHAPTER_NPCS: Record<number, Record<number, { name: string; description?: string }>> = {
  1: {
    0x80: { name: 'Jad', description: 'NPC' },
    0x81: { name: 'Faruk', description: 'Genie ally - attacks 2x per turn' },
    0x82: { name: 'Dogos', description: 'NPC' },
    0x83: { name: 'Kebabu', description: 'Harpy ally - enables Ring+Shield' },
    0x84: { name: 'Aqua Palace', description: 'Palace entrance' },
    0x85: { name: 'Wiseman Monecom', description: 'Money spell teacher' },
    0x86: { name: 'Achelato Princess', description: 'Princess NPC' },
    0x87: { name: 'Sabaron', description: 'Sabaron appearance' },
    0x88: { name: '50 Rupias', description: 'Money reward' },
    0x89: { name: 'Gun Meca', description: 'Robot NPC' },
    0x90: { name: 'Newborn Cimaron Tree', description: 'Cimaron tree' },
  },
  2: {
    0x80: { name: 'Gun Meca', description: 'Robot ally - translator' },
    0x81: { name: 'Lah', description: 'NPC' },
    0x82: { name: 'Supica', description: 'Flying monkey ally - maze guide' },
    0x83: { name: 'Epin', description: '700yr guardian ally - whistle' },
    0x84: { name: 'Wiseman Raincom', description: 'Rain spell teacher' },
    0x87: { name: 'Princess', description: 'Princess NPC' },
    0x8D: { name: 'Rupia Seed Plant', description: 'Plant location' },
  },
  3: {
    0x80: { name: 'Newborn Cimaron Tree', description: 'Baby cimaron' },
    0x81: { name: 'Cimaron Tree', description: 'Grown cimaron - gives Pukin' },
    0x82: { name: 'Supapa', description: 'NPC' },
    0x84: { name: 'Mustafa', description: 'Crystal ball ally - stingy' },
    0x85: { name: 'Frozen Palace 2', description: 'Palace area' },
    0x87: { name: 'Wiseman Spricom', description: 'Sprite spell teacher' },
  },
  4: {
    0x80: { name: 'Gubibi', description: 'Bottle magician ally - gives Holy Robe' },
    0x81: { name: 'Rainy', description: 'Rain Shrimp ally - drum' },
    0x82: { name: 'Yufla Palace', description: 'Palace entrance' },
    0x83: { name: 'Rostam', description: 'Rostam NPC' },
    0x84: { name: 'Rostam Sword', description: 'Rostam sword location' },
    0x85: { name: 'King Fiesal', description: 'King NPC' },
    0x86: { name: 'Wiseman', description: 'Spell teacher' },
    0x87: { name: '50 Rupias Lady', description: 'Money reward' },
  },
  5: {
    0x80: { name: 'Wiseman Moscom', description: 'Moscom spell teacher' },
    0x81: { name: 'Hassan', description: 'Genie ally - strong fighter' },
    0x82: { name: 'Kaji', description: 'NPC' },
    0x83: { name: 'Legend Sword', description: 'Final sword location' },
    0x84: { name: 'Armor of Light', description: 'Final armor location' },
    0x85: { name: 'Sabaron Final', description: 'Final boss trigger' },
    0x86: { name: 'Only One Jar', description: 'Jar NPC' },
    0x87: { name: 'Libcom', description: 'Spell teacher' },
    0x88: { name: 'Rupias', description: 'Money reward' },
  },
};

// Event types from knowledge/enums/content-types.md
const EVENT_TYPES: Record<number, { name: string; description: string }> = {
  0x00: { name: 'None', description: 'No special event' },
  0x01: { name: 'Coronya: Listen', description: '"Listen to the people of the town"' },
  0x02: { name: 'Use Oprin', description: 'Oprin item required' },
  0x03: { name: 'North Cape', description: '"This is the north cape"' },
  0x05: { name: 'Town', description: 'Town event trigger' },
  0x06: { name: 'Oprin', description: 'Oprin event' },
  0x07: { name: 'North Cape', description: '"This is the north cape"' },
  0x08: { name: 'Screen Event', description: 'Generic screen event' },
  0x20: { name: 'Oprin Door', description: 'Oprin door (no message)' },
  0x22: { name: 'Oprin Door + Coronya', description: 'Oprin door with Coronya message' },
  0x40: { name: 'Stairway', description: 'Content byte = destination screen' },
  0x47: { name: 'Jump', description: 'Can jump in North Cape' },
  0x48: { name: 'Water', description: 'Water/underwater area' },
  0x60: { name: 'Building Entry', description: 'Building entrance trigger' },
  0x62: { name: 'Building Event', description: 'Building event' },
  0x80: { name: 'NPC Event', description: 'NPC interaction event' },
  0xC0: { name: 'Time Door', description: 'Time door event' },
};

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

// Past screen indices by chapter - time period determined by SCREEN INDEX, not ParentWorld
const PAST_SCREEN_INDICES: Record<number, Set<number>> = {
  1: new Set([48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
              64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
              80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
              96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
              110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
              123, 124, 125, 126]),
  2: new Set([48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
              64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
              80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
              96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
              110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
              123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
              136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148,
              149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
              162, 163, 164, 165, 166, 167, 168, 169, 170]),
  3: new Set([48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
              64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
              80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
              96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
              110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
              123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
              136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148,
              149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
              162, 163, 164]),
  4: new Set([48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
              64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
              80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
              96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
              110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
              123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
              136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148,
              149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
              162, 163, 164, 165]),
  5: new Set([48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
              64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
              80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
              96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
              110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
              123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134]),
};

// Determine if a screen is in the PAST based on its index
function isScreenInPast(screenIndex: number, chapterNum: number): boolean {
  return PAST_SCREEN_INDICES[chapterNum]?.has(screenIndex) ?? false;
}

export function ScreenDetailPanel({ screen, chapterNum, screens, onScreenSelect, onClose }: ScreenDetailPanelProps) {
  const contentInfo = getContentInfo(screen.content, chapterNum);
  const eventInfo = getEventInfo(screen.event);
  const parentInfo = getParentWorldInfo(screen.parent_world);
  const screenId = formatScreenId(screen.index, screen.global_index, chapterNum);

  // Determine time period (PRESENT or PAST) based on screen index
  const isPast = isScreenInPast(screen.index, chapterNum);
  const timePeriod = isPast ? 'PAST' : 'PRESENT';

  // Determine if this is a stairway
  const isStairway = screen.event === 0x40;
  const stairwayDest = isStairway ? screen.content : null;
  const stairwayDestScreen = stairwayDest !== null ? screens?.find(s => s.index === stairwayDest) : null;

  // Determine CHR bank info from datapointer
  const chrBankIndex = screen.datapointer & 0x3F;
  const topTileBank = (screen.datapointer & 0x80) ? 1 : 0;
  const bottomTileBank = (screen.datapointer & 0x40) ? 1 : 0;

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
          <div className="border-t border-slate-700 mt-2 pt-2">
            <DataRow label="Top TileSection" value={`0x${screen.top_tiles.toString(16).toUpperCase()} (${screen.top_tiles})`} />
            <DataRow label="Bottom TileSection" value={`0x${screen.bottom_tiles.toString(16).toUpperCase()} (${screen.bottom_tiles})`} />
          </div>
        </DataSection>

        {/* ObjectSet */}
        <DataSection title="Enemy Spawning">
          <DataRow label="ObjectSet" value={`0x${screen.objectset.toString(16).toUpperCase()} (${screen.objectset})`} />
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
  const destIsPast = destScreen && chapterNum ? isScreenInPast(destScreen.index, chapterNum) : false;

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
