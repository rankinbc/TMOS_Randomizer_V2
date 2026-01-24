import { useState, useMemo } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import { useRandomizerStore } from '../../store';

interface AlliesViewProps {
  chapter: SimplifiedChapterPlan;
}

// Ally sprite image filenames in public/sprites/
const ALLY_SPRITES: Record<string, string> = {
  Coronya: '/sprites/coronya1.gif',
  Faruk: '/sprites/faruk.gif',
  Kebabu: '/sprites/kebabu1.gif',
  GunMeca: '/sprites/gunmeca1.gif',
  Supica: '/sprites/supica1.gif',
  Epin: '/sprites/epin1.gif',
  Pukin: '/sprites/pukin1.gif',
  Mustafa: '/sprites/mustafa1.gif',
  Gubibi: '/sprites/gubibi1.gif',
  Rainy: '/sprites/rainy1.gif',
  Hassan: '/sprites/hassan1.gif',
  Troopers: '/sprites/trooper1.gif',
};

// Comprehensive ally data from knowledge base
// Source: knowledge/enums/allies.md, knowledge/enums/content-types.md, knowledge/memory/ram-map.md
interface AllyData {
  id: number;
  name: string;
  class: 'fighter' | 'magician' | 'saint';
  chapter: number;
  contentByte: number | null;
  description: string;
  spells: SpellData[];
  combatStats: {
    baseHP?: number;
    baseMP?: number;
    attackPower?: string;
    special?: string;
  };
  ramAddresses: {
    partyFlag?: string;
    hp?: string;
    mp?: string;
  };
}

interface SpellData {
  name: string;
  type: 'attack' | 'defense' | 'support' | 'heal';
  description: string;
}

const KNOWN_ALLIES: AllyData[] = [
  // Chapter 1 - Mooroon
  {
    id: 0,
    name: 'Coronya',
    class: 'fighter',
    chapter: 1,
    contentByte: null, // Automatic join
    description: 'Time Spirit in cat form. Secretly Scheherazade, the Princess of Time.',
    spells: [
      { name: 'Defenee', type: 'defense', description: 'Raises party defense' },
      { name: 'Mymy', type: 'support', description: 'Teleport to previous town' },
      { name: 'Gygatorn', type: 'attack', description: 'Lightning attack on all enemies' },
    ],
    combatStats: {
      special: 'Always in party, provides guidance',
    },
    ramAddresses: {},
  },
  {
    id: 1,
    name: 'Faruk',
    class: 'fighter',
    chapter: 1,
    contentByte: 0x81,
    description: 'A powerful genie who attacks twice per turn.',
    spells: [
      { name: 'Gilzade', type: 'attack', description: 'Fire attack on single enemy' },
      { name: 'Gygatorn', type: 'attack', description: 'Lightning attack on all enemies' },
    ],
    combatStats: {
      baseHP: 40,
      baseMP: 20,
      attackPower: 'High (2x attacks per turn)',
      special: 'Genie type - strong vs demons',
    },
    ramAddresses: { partyFlag: '$033E', hp: '$03D2', mp: '$03D3' },
  },
  {
    id: 2,
    name: 'Kebabu',
    class: 'saint',
    chapter: 1,
    contentByte: 0x83,
    description: 'A harpy/valkyrie who enables Ring and Shield equipment.',
    spells: [
      { name: 'Bolttor', type: 'attack', description: 'Lightning bolt on single enemy' },
      { name: 'Seal', type: 'support', description: 'Prevents enemy magic' },
    ],
    combatStats: {
      baseHP: 30,
      baseMP: 25,
      attackPower: 'Medium',
      special: 'Flying - immune to ground attacks, enables Ring+Shield',
    },
    ramAddresses: { partyFlag: '$033D', hp: '$03D0', mp: '$03D1' },
  },
  // Chapter 2 - Alalart
  {
    id: 3,
    name: 'GunMeca',
    class: 'magician',
    chapter: 2,
    contentByte: 0x80,
    description: 'A robot translator essential for understanding Alalart.',
    spells: [
      { name: 'Bolttor', type: 'attack', description: 'Lightning bolt on single enemy' },
      { name: 'Mirror Reflect', type: 'defense', description: 'Reflects enemy magic' },
    ],
    combatStats: {
      baseHP: 35,
      baseMP: 30,
      attackPower: 'Medium',
      special: 'Mechanical - immune to poison, translates languages',
    },
    ramAddresses: { partyFlag: '$0337' },
  },
  {
    id: 4,
    name: 'Supica',
    class: 'fighter',
    chapter: 2,
    contentByte: 0x82,
    description: 'A flying monkey maze guide who knows dungeon layouts.',
    spells: [
      { name: 'Seal', type: 'support', description: 'Prevents enemy magic' },
      { name: 'Magic Arrow', type: 'attack', description: 'Piercing magic attack' },
    ],
    combatStats: {
      baseHP: 25,
      baseMP: 20,
      attackPower: 'Medium',
      special: 'Flying, high speed, maze navigation hints',
    },
    ramAddresses: {},
  },
  {
    id: 5,
    name: 'Epin',
    class: 'saint',
    chapter: 2,
    contentByte: 0x83,
    description: 'A 700-year-old guardian with a summoning whistle.',
    spells: [
      { name: 'Defenee', type: 'defense', description: 'Raises party defense' },
      { name: 'Tornador', type: 'attack', description: 'Wind attack on all enemies' },
    ],
    combatStats: {
      baseHP: 35,
      baseMP: 30,
      attackPower: 'Low',
      special: 'Ancient being, high wisdom, whistle summons help',
    },
    ramAddresses: { partyFlag: '$033B' },
  },
  // Chapter 3 - Samalkand
  {
    id: 6,
    name: 'Pukin',
    class: 'magician',
    chapter: 3,
    contentByte: null, // Special join via Cimaron fruit
    description: 'A Cimaron doll with pumpkin head, grown from fruit.',
    spells: [
      { name: 'Velver', type: 'heal', description: 'Heals one ally' },
    ],
    combatStats: {
      baseHP: 20,
      baseMP: 40,
      attackPower: 'Low',
      special: 'Healing specialist, grows from Cimaron tree',
    },
    ramAddresses: {},
  },
  {
    id: 7,
    name: 'Mustafa',
    class: 'magician',
    chapter: 3,
    contentByte: 0x84,
    description: 'A stingy fortune teller with a crystal ball.',
    spells: [
      { name: 'Bolttor2', type: 'attack', description: 'Stronger lightning on single enemy' },
      { name: 'Slow Enemies', type: 'support', description: 'Reduces enemy speed' },
    ],
    combatStats: {
      baseHP: 30,
      baseMP: 35,
      attackPower: 'Medium-High',
      special: 'Enemy speed debuff, fortune telling',
    },
    ramAddresses: {},
  },
  // Chapter 4 - Celestern
  {
    id: 8,
    name: 'Gubibi',
    class: 'magician',
    chapter: 4,
    contentByte: 0x80,
    description: 'A bottle magician who possesses the Holy Robe.',
    spells: [
      { name: 'Defenee', type: 'defense', description: 'Raises party defense' },
      { name: 'Resealo', type: 'heal', description: 'Removes status ailments' },
    ],
    combatStats: {
      baseHP: 35,
      baseMP: 40,
      attackPower: 'Low',
      special: 'Status removal specialist, Holy Robe bearer',
    },
    ramAddresses: { partyFlag: '$0339', hp: '$03C8', mp: '$03C9' },
  },
  {
    id: 9,
    name: 'Rainy',
    class: 'saint',
    chapter: 4,
    contentByte: 0x81,
    description: 'A Rain Shrimp with a magical weather-controlling drum.',
    spells: [
      { name: 'Perius', type: 'heal', description: 'Revives fallen ally' },
      { name: 'Matato', type: 'attack', description: 'Water attack on all enemies' },
    ],
    combatStats: {
      baseHP: 30,
      baseMP: 45,
      attackPower: 'Medium',
      special: 'Only ally with Revive, aquatic type, weather control',
    },
    ramAddresses: { partyFlag: '$033C', hp: '$03CE', mp: '$03CF' },
  },
  // Chapter 5 - Sabaron's Realm
  {
    id: 10,
    name: 'Hassan',
    class: 'fighter',
    chapter: 5,
    contentByte: 0x81,
    description: 'The most powerful genie fighter for the final battle.',
    spells: [
      { name: 'Flamol3', type: 'attack', description: 'Strongest fire attack on all enemies' },
      { name: 'Caraba', type: 'attack', description: 'Physical attack on all enemies' },
    ],
    combatStats: {
      baseHP: 60,
      baseMP: 30,
      attackPower: 'Very High',
      special: 'Strongest ally, genie type, multi-target physical',
    },
    ramAddresses: { partyFlag: '$033F', hp: '$03D4', mp: '$03D5' },
  },
];

// Troopers info
const TROOPERS = {
  name: 'Troopers',
  contentByte: 0x7F,
  description: 'Armored bulldog soldiers (up to 99)',
  combatStats: {
    attackPower: 'Low per trooper',
    special: '4 fight at once, rotate as they fall',
  },
  ramAddresses: {
    countTens: '$03D6',
    countOnes: '$03D7',
  },
};

const CHAPTER_NAMES: Record<number, string> = {
  1: 'Mooroon',
  2: 'Alalart',
  3: 'Samalkand',
  4: 'Celestern',
  5: "Sabaron's Realm",
};

export function AlliesView({ chapter }: AlliesViewProps) {
  const [selectedAlly, setSelectedAlly] = useState<AllyData | null>(null);
  const [showAllChapters, setShowAllChapters] = useState(false);
  const { chapterData, selectedChapter } = useRandomizerStore();

  // Find screen locations for allies based on content byte
  const allyScreenLocations = useMemo(() => {
    const locations: Record<number, number[]> = {};

    if (chapterData?.screens) {
      for (const screen of chapterData.screens) {
        const content = screen.content;
        // Check if content is in the NPC range (0x80-0x8F)
        if (content >= 0x80 && content <= 0x8F) {
          if (!locations[content]) {
            locations[content] = [];
          }
          locations[content].push(screen.index);
        }
        // Also check for Troopers (0x7F)
        if (content === 0x7F) {
          if (!locations[0x7F]) {
            locations[0x7F] = [];
          }
          locations[0x7F].push(screen.index);
        }
      }
    }

    return locations;
  }, [chapterData]);

  // Filter allies by chapter or show all
  const displayedAllies = showAllChapters
    ? KNOWN_ALLIES
    : KNOWN_ALLIES.filter((a) => a.chapter === chapter.chapter_num);

  const chapterName = CHAPTER_NAMES[chapter.chapter_num] || `Chapter ${chapter.chapter_num}`;

  // Get screen locations for an ally
  const getScreensForAlly = (ally: AllyData): number[] => {
    if (!ally.contentByte) return [];
    // Only show location if we're viewing the ally's chapter
    if (ally.chapter !== selectedChapter) return [];
    return allyScreenLocations[ally.contentByte] || [];
  };

  // Get trooper locations
  const trooperScreens = allyScreenLocations[0x7F] || [];

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="flex-shrink-0 p-4 border-b border-slate-700">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-lg font-semibold text-slate-200">Party Allies</h2>
          <label className="flex items-center gap-2 text-sm text-slate-400 cursor-pointer">
            <input
              type="checkbox"
              checked={showAllChapters}
              onChange={(e) => setShowAllChapters(e.target.checked)}
              className="rounded border-slate-600 bg-slate-700 text-blue-500 focus:ring-blue-500"
            />
            Show all chapters
          </label>
        </div>
        <p className="text-sm text-slate-400">
          {showAllChapters
            ? `${KNOWN_ALLIES.length} total allies across all chapters`
            : `${displayedAllies.length} allies in ${chapterName}`}
        </p>
      </div>

      {/* Main content area */}
      <div className="flex-1 overflow-auto flex">
        {/* Ally list */}
        <div className="w-1/2 p-4 border-r border-slate-700 overflow-auto">
          {/* Group by chapter when showing all */}
          {showAllChapters ? (
            Object.entries(CHAPTER_NAMES).map(([chNum, chName]) => {
              const chapterAllies = KNOWN_ALLIES.filter((a) => a.chapter === parseInt(chNum));
              if (chapterAllies.length === 0) return null;
              return (
                <div key={chNum} className="mb-6">
                  <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
                    Chapter {chNum}: {chName}
                  </h3>
                  <div className="space-y-2">
                    {chapterAllies.map((ally) => (
                      <AllyCard
                        key={ally.id}
                        ally={ally}
                        isSelected={selectedAlly?.id === ally.id}
                        onClick={() => setSelectedAlly(ally)}
                        screens={getScreensForAlly(ally)}
                        isCurrentChapter={ally.chapter === selectedChapter}
                      />
                    ))}
                  </div>
                </div>
              );
            })
          ) : (
            <div className="space-y-2">
              {displayedAllies.map((ally) => (
                <AllyCard
                  key={ally.id}
                  ally={ally}
                  isSelected={selectedAlly?.id === ally.id}
                  onClick={() => setSelectedAlly(ally)}
                  screens={getScreensForAlly(ally)}
                  isCurrentChapter={ally.chapter === selectedChapter}
                />
              ))}
            </div>
          )}

          {/* Troopers */}
          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Troopers
            </h3>
            <div className="bg-slate-800 rounded-lg p-3 border border-amber-500/30">
              <div className="flex items-center gap-3">
                <img
                  src={ALLY_SPRITES.Troopers}
                  alt="Troopers"
                  className="w-12 h-12 object-contain image-rendering-pixelated"
                  style={{ imageRendering: 'pixelated' }}
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-semibold text-slate-200">{TROOPERS.name}</span>
                    <span className="text-xs font-mono bg-slate-700 px-1.5 py-0.5 rounded text-amber-400">
                      0x{TROOPERS.contentByte.toString(16).toUpperCase().padStart(2, '0')}
                    </span>
                  </div>
                  <p className="text-xs text-slate-400">{TROOPERS.description}</p>
                  {trooperScreens.length > 0 && (
                    <div className="text-xs text-green-400 mt-1">
                      Screen{trooperScreens.length > 1 ? 's' : ''}: {trooperScreens.join(', ')}
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Ally detail panel */}
        <div className="w-1/2 p-4 overflow-auto">
          {selectedAlly ? (
            <AllyDetailPanel
              ally={selectedAlly}
              screens={getScreensForAlly(selectedAlly)}
              isCurrentChapter={selectedAlly.chapter === selectedChapter}
            />
          ) : (
            <div className="h-full flex items-center justify-center text-slate-500">
              <div className="text-center">
                <div className="text-4xl mb-2">?</div>
                <p className="text-sm">Select an ally to view details</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

interface AllyCardProps {
  ally: AllyData;
  isSelected: boolean;
  onClick: () => void;
  screens: number[];
  isCurrentChapter: boolean;
}

function AllyCard({ ally, isSelected, onClick, screens, isCurrentChapter }: AllyCardProps) {
  return (
    <button
      onClick={onClick}
      className={`w-full text-left bg-slate-800 rounded-lg p-3 transition-colors border ${
        isSelected ? 'border-blue-500 bg-slate-700' : 'border-transparent hover:bg-slate-750'
      }`}
    >
      <div className="flex items-center gap-3">
        <img
          src={ALLY_SPRITES[ally.name]}
          alt={ally.name}
          className="w-12 h-12 object-contain"
          style={{ imageRendering: 'pixelated' }}
        />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-sm font-semibold text-slate-200">{ally.name}</span>
            <span className={`text-xs px-2 py-0.5 rounded ${getClassColor(ally.class)}`}>
              {ally.class}
            </span>
            {ally.contentByte && (
              <span className="text-xs font-mono bg-slate-700 px-1.5 py-0.5 rounded text-blue-400">
                0x{ally.contentByte.toString(16).toUpperCase().padStart(2, '0')}
              </span>
            )}
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-500 mt-1">
            <span>Ch.{ally.chapter}</span>
            {isCurrentChapter && screens.length > 0 && (
              <span className="text-green-400">
                Screen{screens.length > 1 ? 's' : ''}: {screens.join(', ')}
              </span>
            )}
            {ally.contentByte === null && (
              <span className="text-amber-400">Auto-join</span>
            )}
          </div>
        </div>
      </div>
    </button>
  );
}

interface AllyDetailPanelProps {
  ally: AllyData;
  screens: number[];
  isCurrentChapter: boolean;
}

function AllyDetailPanel({ ally, screens, isCurrentChapter }: AllyDetailPanelProps) {
  return (
    <div className="space-y-4">
      {/* Header with large sprite */}
      <div className="flex items-start gap-4">
        <div className="bg-slate-800 rounded-lg p-2">
          <img
            src={ALLY_SPRITES[ally.name]}
            alt={ally.name}
            className="w-20 h-20 object-contain"
            style={{ imageRendering: 'pixelated' }}
          />
        </div>
        <div className="flex-1">
          <h3 className="text-xl font-bold text-slate-200">{ally.name}</h3>
          <div className="flex items-center gap-2 mt-1 flex-wrap">
            <span className={`text-xs px-2 py-0.5 rounded ${getClassColor(ally.class)}`}>
              {ally.class}
            </span>
            <span className="text-sm text-slate-400">
              Chapter {ally.chapter}: {CHAPTER_NAMES[ally.chapter]}
            </span>
          </div>
          <p className="text-sm text-slate-300 mt-2">{ally.description}</p>
        </div>
      </div>

      {/* Location Info */}
      <div className="bg-slate-800 rounded-lg p-4">
        <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-2">
          Location
        </h4>
        <div className="space-y-2">
          {ally.contentByte ? (
            <>
              <div className="flex items-center gap-2">
                <span className="text-xs text-slate-500">Content Byte:</span>
                <span className="text-sm font-mono text-blue-400">
                  0x{ally.contentByte.toString(16).toUpperCase().padStart(2, '0')}
                </span>
              </div>
              {isCurrentChapter ? (
                screens.length > 0 ? (
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-500">Current Screen:</span>
                    <span className="text-sm text-green-400">
                      {screens.join(', ')}
                    </span>
                  </div>
                ) : (
                  <div className="text-xs text-amber-400">
                    Not found in current chapter data
                  </div>
                )
              ) : (
                <div className="text-xs text-slate-500">
                  Load Chapter {ally.chapter} to see screen location
                </div>
              )}
            </>
          ) : (
            <div className="text-sm text-amber-400">
              Joins automatically (no specific screen)
            </div>
          )}
        </div>
      </div>

      {/* Combat Stats */}
      <div className="bg-slate-800 rounded-lg p-4">
        <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Combat Stats
        </h4>
        <div className="grid grid-cols-2 gap-3">
          {ally.combatStats.baseHP && (
            <div className="bg-slate-700/50 rounded p-2">
              <div className="text-xs text-slate-500">Base HP</div>
              <div className="text-lg font-bold text-red-400">{ally.combatStats.baseHP}</div>
            </div>
          )}
          {ally.combatStats.baseMP && (
            <div className="bg-slate-700/50 rounded p-2">
              <div className="text-xs text-slate-500">Base MP</div>
              <div className="text-lg font-bold text-blue-400">{ally.combatStats.baseMP}</div>
            </div>
          )}
        </div>
        {ally.combatStats.attackPower && (
          <div className="mt-2">
            <span className="text-xs text-slate-500">Attack: </span>
            <span className="text-sm text-slate-300">{ally.combatStats.attackPower}</span>
          </div>
        )}
        {ally.combatStats.special && (
          <div className="mt-2 text-xs text-amber-300 bg-amber-500/10 rounded p-2">
            {ally.combatStats.special}
          </div>
        )}
      </div>

      {/* Spells */}
      <div className="bg-slate-800 rounded-lg p-4">
        <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Magic ({ally.spells.length})
        </h4>
        <div className="space-y-2">
          {ally.spells.map((spell) => (
            <div key={spell.name} className="flex items-start gap-3 p-2 bg-slate-700/50 rounded">
              <div className={`w-6 h-6 rounded flex items-center justify-center text-xs flex-shrink-0 ${getSpellTypeColor(spell.type)}`}>
                {getSpellTypeIcon(spell.type)}
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium text-slate-200">{spell.name}</span>
                  <span className={`text-xs px-1.5 py-0.5 rounded ${getSpellTypeBadge(spell.type)}`}>
                    {spell.type}
                  </span>
                </div>
                <p className="text-xs text-slate-400 mt-0.5">{spell.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* RAM Addresses (Technical) */}
      {Object.keys(ally.ramAddresses).length > 0 && (
        <div className="bg-slate-800 rounded-lg p-4">
          <h4 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-2">
            RAM Addresses
          </h4>
          <div className="font-mono text-xs space-y-1">
            {ally.ramAddresses.partyFlag && (
              <div className="flex items-center gap-2">
                <span className="text-slate-500 w-20">Party Flag:</span>
                <span className="text-green-400">{ally.ramAddresses.partyFlag}</span>
              </div>
            )}
            {ally.ramAddresses.hp && (
              <div className="flex items-center gap-2">
                <span className="text-slate-500 w-20">HP:</span>
                <span className="text-red-400">{ally.ramAddresses.hp}</span>
              </div>
            )}
            {ally.ramAddresses.mp && (
              <div className="flex items-center gap-2">
                <span className="text-slate-500 w-20">MP:</span>
                <span className="text-blue-400">{ally.ramAddresses.mp}</span>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

// Helper functions
function getClassColor(cls: string): string {
  const colors: Record<string, string> = {
    fighter: 'bg-red-500/20 text-red-400',
    magician: 'bg-purple-500/20 text-purple-400',
    saint: 'bg-blue-500/20 text-blue-400',
  };
  return colors[cls] || 'bg-slate-600 text-slate-300';
}

function getSpellTypeColor(type: string): string {
  const colors: Record<string, string> = {
    attack: 'bg-red-500/30 text-red-400',
    defense: 'bg-blue-500/30 text-blue-400',
    support: 'bg-yellow-500/30 text-yellow-400',
    heal: 'bg-green-500/30 text-green-400',
  };
  return colors[type] || 'bg-slate-600 text-slate-300';
}

function getSpellTypeIcon(type: string): string {
  const icons: Record<string, string> = {
    attack: '!',
    defense: '#',
    support: '~',
    heal: '+',
  };
  return icons[type] || '?';
}

function getSpellTypeBadge(type: string): string {
  const colors: Record<string, string> = {
    attack: 'bg-red-500/20 text-red-400',
    defense: 'bg-blue-500/20 text-blue-400',
    support: 'bg-yellow-500/20 text-yellow-400',
    heal: 'bg-green-500/20 text-green-400',
  };
  return colors[type] || 'bg-slate-600 text-slate-300';
}
