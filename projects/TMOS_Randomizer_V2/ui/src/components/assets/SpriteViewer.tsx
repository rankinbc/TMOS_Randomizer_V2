// Sprite viewer component for displaying game character sprites

import { useState, useEffect } from 'react';
import { useRandomizerStore } from '../../store';
import { api } from '../../api/client';

interface Sprite {
  name: string;
  filename: string;
  path: string;
}

// Character categories for organization
const SPRITE_CATEGORIES = {
  heroes: ['hero1', 'hero2', 'hero3', 'hero4', 'hero5'],
  allies: [
    'coronya1', 'coronya2', 'epin1', 'epin2', 'faruk', 'faruk2',
    'gubibi1', 'gubibi2', 'gunmeca1', 'gunmeca2', 'hassan1', 'hassan2',
    'kebabu1', 'kebabu2', 'mustafa1', 'mustafa2', 'pukin1', 'pukin2',
    'rainy1', 'rainy2', 'supica1', 'supica2', 'trooper1', 'trooper2'
  ],
  npcs: [
    'ashelato', 'assistant', 'beckal', 'casinoman', 'dogos', 'feisal',
    'imam', 'innkeeper', 'jad', 'mohammed', 'rupias', 'sabaron',
    'sche', 'shopkeeper', 'teacher', 'wiseman', 'zainab'
  ],
  townspeople: [
    'tp-charmer', 'tp-fairy', 'tp-lava', 'tp-man', 'tp-merchant',
    'tp-mermaid', 'tp-oldman', 'tp-oldwoman', 'tp-woman'
  ],
} as const;

// Friendly names for sprites
const SPRITE_NAMES: Record<string, string> = {
  hero1: 'Hero (Fighter)',
  hero2: 'Hero (Magician)',
  hero3: 'Hero (Saint)',
  hero4: 'Hero (Walking)',
  hero5: 'Hero (Attacking)',
  coronya1: 'Coronya',
  coronya2: 'Coronya (Alt)',
  epin1: 'Epin',
  epin2: 'Epin (Alt)',
  faruk: 'Faruk',
  faruk2: 'Faruk (Alt)',
  gubibi1: 'Gubibi',
  gubibi2: 'Gubibi (Alt)',
  gunmeca1: 'GunMeca',
  gunmeca2: 'GunMeca (Alt)',
  hassan1: 'Hassan',
  hassan2: 'Hassan (Alt)',
  kebabu1: 'Kebabu',
  kebabu2: 'Kebabu (Alt)',
  mustafa1: 'Mustafa',
  mustafa2: 'Mustafa (Alt)',
  pukin1: 'Pukin',
  pukin2: 'Pukin (Alt)',
  rainy1: 'Rainy',
  rainy2: 'Rainy (Alt)',
  supica1: 'Supica',
  supica2: 'Supica (Alt)',
  trooper1: 'Trooper',
  trooper2: 'Trooper (Alt)',
  ashelato: 'Princess Ashelato',
  assistant: 'Assistant',
  beckal: 'Beckal',
  casinoman: 'Casino Man',
  dogos: 'Dogos',
  feisal: 'King Feisal',
  imam: 'Imam',
  innkeeper: 'Innkeeper',
  jad: 'Jad',
  mohammed: 'Mohammed',
  rupias: 'Rupias',
  sabaron: 'Sabaron',
  sche: 'Scheherazade',
  shopkeeper: 'Shopkeeper',
  teacher: 'Teacher',
  wiseman: 'Wise Man',
  zainab: 'Zainab',
  'tp-charmer': 'Snake Charmer',
  'tp-fairy': 'Fairy',
  'tp-lava': 'Lava Spirit',
  'tp-man': 'Townsman',
  'tp-merchant': 'Merchant',
  'tp-mermaid': 'Mermaid',
  'tp-oldman': 'Old Man',
  'tp-oldwoman': 'Old Woman',
  'tp-woman': 'Townswoman',
};

interface SpriteViewerProps {
  category?: keyof typeof SPRITE_CATEGORIES | 'all';
  onSelect?: (sprite: Sprite) => void;
}

export function SpriteViewer({ category = 'all', onSelect }: SpriteViewerProps) {
  const { assets, apiConnected } = useRandomizerStore();
  const [selectedCategory, setSelectedCategory] = useState<keyof typeof SPRITE_CATEGORIES | 'all'>(category);
  const [hoveredSprite, setHoveredSprite] = useState<string | null>(null);

  // Filter sprites by category
  const getFilteredSprites = (): Sprite[] => {
    if (!assets?.sprites) return [];

    if (selectedCategory === 'all') {
      return assets.sprites;
    }

    const categoryNames = SPRITE_CATEGORIES[selectedCategory];
    return assets.sprites.filter(s =>
      categoryNames.some(name => s.name.toLowerCase().startsWith(name.replace(/[12]$/, '')))
    );
  };

  const filteredSprites = getFilteredSprites();

  if (!apiConnected) {
    return (
      <div className="p-4 text-center text-slate-500">
        <p>Connect to API to view game sprites</p>
        <p className="text-xs mt-2">Run: tmos-randomize serve</p>
      </div>
    );
  }

  if (!assets?.sprites?.length) {
    return (
      <div className="p-4 text-center text-slate-500">
        <p>No sprites loaded</p>
        <p className="text-xs mt-2">Loading asset manifest...</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      {/* Category Tabs */}
      <div className="flex gap-1 p-2 bg-slate-800 border-b border-slate-700 flex-wrap">
        <button
          onClick={() => setSelectedCategory('all')}
          className={`px-3 py-1 text-xs rounded ${
            selectedCategory === 'all'
              ? 'bg-blue-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          All ({assets.sprites.length})
        </button>
        {Object.entries(SPRITE_CATEGORIES).map(([cat, names]) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat as keyof typeof SPRITE_CATEGORIES)}
            className={`px-3 py-1 text-xs rounded capitalize ${
              selectedCategory === cat
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
          >
            {cat} ({names.length})
          </button>
        ))}
      </div>

      {/* Sprite Grid */}
      <div className="flex-1 overflow-auto p-4">
        <div className="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 lg:grid-cols-10 gap-3">
          {filteredSprites.map((sprite) => (
            <div
              key={sprite.filename}
              className={`relative group cursor-pointer rounded-lg p-2 transition-colors ${
                hoveredSprite === sprite.name
                  ? 'bg-blue-600/30 ring-2 ring-blue-500'
                  : 'bg-slate-800 hover:bg-slate-700'
              }`}
              onMouseEnter={() => setHoveredSprite(sprite.name)}
              onMouseLeave={() => setHoveredSprite(null)}
              onClick={() => onSelect?.(sprite)}
            >
              <img
                src={api.getSpriteUrl(sprite.filename)}
                alt={SPRITE_NAMES[sprite.name] || sprite.name}
                className="w-full h-auto pixelated mx-auto"
                style={{ imageRendering: 'pixelated' }}
              />
              <div className="mt-1 text-center">
                <p className="text-[10px] text-slate-400 truncate">
                  {SPRITE_NAMES[sprite.name] || sprite.name}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Selected Sprite Info */}
      {hoveredSprite && (
        <div className="p-2 bg-slate-800 border-t border-slate-700 text-sm">
          <span className="text-slate-400">Selected: </span>
          <span className="text-white">{SPRITE_NAMES[hoveredSprite] || hoveredSprite}</span>
        </div>
      )}
    </div>
  );
}
