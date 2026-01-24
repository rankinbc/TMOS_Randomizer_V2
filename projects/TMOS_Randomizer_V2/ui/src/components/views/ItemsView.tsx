import type { SimplifiedChapterPlan } from '../../types/randomizer';

interface ItemsViewProps {
  chapter: SimplifiedChapterPlan;
}

// Accurate item data from knowledge base
// Source: knowledge/enums/items.md

type ItemCategory = 'consumable' | 'equipment' | 'weapon' | 'progression';

interface GameItem {
  id: number;
  name: string;
  category: ItemCategory;
  effect: string;
  maxCount?: number;
  ramAddress?: string;
  chapter?: number; // For progression items
}

// Consumables (Index 0-11)
const CONSUMABLE_ITEMS: GameItem[] = [
  { id: 0, name: 'Amulet', category: 'consumable', effect: 'Reduces wizard transformation' },
  { id: 1, name: 'Bread', category: 'consumable', effect: 'Auto-restore HP on death', maxCount: 10, ramAddress: '$0306' },
  { id: 2, name: 'Carpet', category: 'consumable', effect: 'Warp to towns / escape dungeon', maxCount: 15, ramAddress: '$0311' },
  { id: 3, name: 'Hammer', category: 'consumable', effect: 'Stars hit all enemies', maxCount: 5, ramAddress: '$030F' },
  { id: 4, name: 'Horn', category: 'consumable', effect: 'Disable gargoyles', maxCount: 5, ramAddress: '$0312' },
  { id: 5, name: 'HP Drink', category: 'consumable', effect: 'HP restoration (rare)' },
  { id: 6, name: 'Key', category: 'consumable', effect: 'Open palace doors', maxCount: 9, ramAddress: '$0300' },
  { id: 7, name: 'Map', category: 'consumable', effect: 'Show palace layout' },
  { id: 8, name: 'Mashroob', category: 'consumable', effect: 'Auto-restore MP when empty', maxCount: 10, ramAddress: '$0307' },
  { id: 9, name: 'Money Bag', category: 'consumable', effect: 'Large money drop' },
  { id: 10, name: 'R.Seed', category: 'consumable', effect: 'Plant for money/invisibility', maxCount: 5, ramAddress: '$0310' },
  { id: 11, name: 'Rupia', category: 'consumable', effect: 'Currency' },
];

// Equipment - Armor/Accessories (Index 12-17)
const EQUIPMENT_ITEMS: GameItem[] = [
  { id: 12, name: 'Holy Robe', category: 'equipment', effect: 'Survive lava at north cape' },
  { id: 13, name: 'L.Armor', category: 'equipment', effect: 'Strongest armor, palace access' },
  { id: 14, name: 'M.Boots', category: 'equipment', effect: 'Walk over damage (Saint class)' },
  { id: 15, name: 'M.Shield', category: 'equipment', effect: 'Reflect bullets (with Kebabu)' },
  { id: 16, name: 'R.Armor', category: 'equipment', effect: 'Defense boost (SPRICOM course)' },
  { id: 17, name: 'Ring', category: 'equipment', effect: 'Escape battles (with Kebabu)' },
];

// Magic Rods Progression (Index 18-23)
const ROD_ITEMS: GameItem[] = [
  { id: 18, name: 'Rod', category: 'progression', effect: 'Starting magic rod', chapter: 0 },
  { id: 19, name: 'Flame', category: 'progression', effect: 'Fire magic rod', chapter: 1 },
  { id: 20, name: 'Stardust', category: 'progression', effect: 'Star magic rod', chapter: 2 },
  { id: 21, name: 'Cimaron', category: 'progression', effect: 'Cimaron magic rod', chapter: 3 },
  { id: 22, name: 'Crystal', category: 'progression', effect: 'Crystal magic rod', chapter: 4 },
  { id: 23, name: 'Isfa', category: 'progression', effect: 'Final magic rod', chapter: 5 },
];

// Swords Progression (Index 24-29)
const SWORD_ITEMS: GameItem[] = [
  { id: 24, name: 'Sword', category: 'progression', effect: 'Starting sword', chapter: 0 },
  { id: 25, name: 'Simitar', category: 'progression', effect: 'Chapter 1 sword upgrade', chapter: 1 },
  { id: 26, name: 'Dragoon', category: 'progression', effect: 'Chapter 2 sword upgrade', chapter: 2 },
  { id: 27, name: 'Kashim', category: 'progression', effect: 'Chapter 3 sword upgrade', chapter: 3 },
  { id: 28, name: 'Rostam', category: 'progression', effect: 'Chapter 4 sword upgrade', chapter: 4 },
  { id: 29, name: 'Legend', category: 'progression', effect: 'Final legendary sword', chapter: 5 },
];

// Chapter names for display
const CHAPTER_NAMES: Record<number, string> = {
  1: 'Mooroon',
  2: 'Alalart',
  3: 'Samalkand',
  4: 'Celestern',
  5: "Sabaron's Realm",
};

export function ItemsView({ chapter }: ItemsViewProps) {
  const chapterName = CHAPTER_NAMES[chapter.chapter_num] || `Chapter ${chapter.chapter_num}`;

  // Get progression items for this chapter
  const chapterSword = SWORD_ITEMS.find((s) => s.chapter === chapter.chapter_num);
  const chapterRod = ROD_ITEMS.find((r) => r.chapter === chapter.chapter_num);

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <h2 className="text-lg font-semibold text-slate-200">
          Items - {chapterName}
        </h2>
        <p className="text-sm text-slate-400">
          Item information for Chapter {chapter.chapter_num}
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4">
        {/* Chapter Progression Items */}
        {(chapterSword || chapterRod) && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Chapter {chapter.chapter_num} Progression Items
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {chapterSword && (
                <ItemCard item={chapterSword} icon="⚔️" highlight />
              )}
              {chapterRod && (
                <ItemCard item={chapterRod} icon="🪄" highlight />
              )}
            </div>
          </div>
        )}

        {/* All Swords */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Swords (Progression)
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-2">
            {SWORD_ITEMS.map((item) => (
              <ItemCard
                key={item.id}
                item={item}
                icon="⚔️"
                compact
                highlight={item.chapter === chapter.chapter_num}
              />
            ))}
          </div>
        </div>

        {/* All Rods */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Magic Rods (Progression)
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-2">
            {ROD_ITEMS.map((item) => (
              <ItemCard
                key={item.id}
                item={item}
                icon="🪄"
                compact
                highlight={item.chapter === chapter.chapter_num}
              />
            ))}
          </div>
        </div>

        {/* Equipment */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Equipment
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {EQUIPMENT_ITEMS.map((item) => (
              <ItemCard key={item.id} item={item} icon="🛡️" />
            ))}
          </div>
        </div>

        {/* Consumables */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Consumables
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {CONSUMABLE_ITEMS.map((item) => (
              <ItemCard key={item.id} item={item} icon="🧪" />
            ))}
          </div>
        </div>

        {/* Chapter sections that may have items */}
        {chapter.sections.length > 0 && (
          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Potential Item Locations in {chapterName}
            </h3>
            <div className="space-y-2">
              {chapter.sections.map((section) => (
                <div
                  key={section.section_id}
                  className="bg-slate-800 rounded-lg p-3 flex items-center justify-between"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-lg">
                      {getSectionIcon(section.type)}
                    </span>
                    <div>
                      <div className="text-sm font-medium text-slate-200 capitalize">
                        {section.section_id.replace(/_/g, ' ')}
                      </div>
                      <div className="text-xs text-slate-500">
                        {section.type} • {section.screen_count} screens
                      </div>
                    </div>
                  </div>
                  <div className="text-xs text-slate-400">
                    {getExpectedItemTypes(section.type)}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

interface ItemCardProps {
  item: GameItem;
  icon: string;
  compact?: boolean;
  highlight?: boolean;
}

function ItemCard({ item, icon, compact, highlight }: ItemCardProps) {
  if (compact) {
    return (
      <div
        className={`rounded-lg p-2 text-center ${
          highlight
            ? 'bg-amber-500/20 border border-amber-500/50'
            : 'bg-slate-800'
        }`}
      >
        <div className="text-lg mb-1">{icon}</div>
        <div className={`text-xs font-medium ${highlight ? 'text-amber-300' : 'text-slate-200'}`}>
          {item.name}
        </div>
        {item.chapter !== undefined && (
          <div className="text-xs text-slate-500">Ch.{item.chapter || 'Start'}</div>
        )}
      </div>
    );
  }

  return (
    <div
      className={`rounded-lg p-3 ${
        highlight
          ? 'bg-amber-500/20 border border-amber-500/50'
          : 'bg-slate-800'
      }`}
    >
      <div className="flex items-start gap-3">
        <span className="text-xl">{icon}</span>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className={`text-sm font-medium ${highlight ? 'text-amber-300' : 'text-slate-200'}`}>
              {item.name}
            </span>
            <span className="text-xs text-slate-500 font-mono">#{item.id}</span>
          </div>
          <p className="text-xs text-slate-400 mb-1">{item.effect}</p>
          <div className="flex flex-wrap gap-2">
            {item.maxCount && (
              <span className="text-xs text-slate-500">Max: {item.maxCount}</span>
            )}
            {item.ramAddress && (
              <span className="text-xs text-slate-600 font-mono">{item.ramAddress}</span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function getSectionIcon(type: string): string {
  const icons: Record<string, string> = {
    overworld: '🌍',
    town: '🏘️',
    dungeon: '🏰',
    maze: '🌀',
    boss: '👑',
    special: '⭐',
  };
  return icons[type] || '📍';
}

function getExpectedItemTypes(type: string): string {
  const expected: Record<string, string> = {
    overworld: 'Hidden chests, NPCs',
    town: 'Shops, NPCs, Hotels',
    dungeon: 'Chests, boss drops, keys',
    maze: 'Hidden items, treasures',
    boss: 'Swords, Rods, Key items',
    special: 'Unique equipment',
  };
  return expected[type] || 'Various';
}
