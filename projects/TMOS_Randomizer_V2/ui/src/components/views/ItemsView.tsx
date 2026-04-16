import { useEffect } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import type { GameplayItem } from '../../api/client';
import { useRandomizerStore } from '../../store';
import { InventoryCapEditor } from '../items/InventoryCapEditor';
import { ExpTierRow } from '../items/ExpTierRow';
import { HelpChip } from '../stats/HelpChip';

interface ItemsViewProps {
  chapter: SimplifiedChapterPlan;
}

// Items are loaded from /api/rom/items (backed by core/items.py::GAMEPLAY_ITEMS).
// IDs 0-11 = consumables, 12-17 = equipment, 18-23 = rods (progression),
// 24-29 = swords (progression). See core/items.py for the two-namespace
// rationale (gameplay vs battle table).

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

  // Items registry (static metadata from /api/rom/items)
  const items = useRandomizerStore((s) => s.items);
  const itemsLoading = useRandomizerStore((s) => s.itemsLoading);
  const itemsError = useRandomizerStore((s) => s.itemsError);
  const loadItems = useRandomizerStore((s) => s.loadItems);

  // Editable: inventory caps and EXP table
  const inventoryCaps = useRandomizerStore((s) => s.inventoryCaps);
  const inventoryCapsLoading = useRandomizerStore((s) => s.inventoryCapsLoading);
  const inventoryCapsError = useRandomizerStore((s) => s.inventoryCapsError);
  const expTable = useRandomizerStore((s) => s.expTable);
  const expUsage = useRandomizerStore((s) => s.expUsage);
  const expLoading = useRandomizerStore((s) => s.expLoading);
  const loadInventoryCaps = useRandomizerStore((s) => s.loadInventoryCaps);
  const loadExpTable = useRandomizerStore((s) => s.loadExpTable);
  const loadExpUsage = useRandomizerStore((s) => s.loadExpUsage);
  const updateInventoryCap = useRandomizerStore((s) => s.updateInventoryCap);
  const updateExpEntry = useRandomizerStore((s) => s.updateExpEntry);

  useEffect(() => {
    if (!items && !itemsLoading) loadItems();
    if (!inventoryCaps && !inventoryCapsLoading) loadInventoryCaps();
    if (!expTable && !expLoading) loadExpTable();
    if (!expUsage) loadExpUsage();
    // intentionally one-shot per mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Partition GAMEPLAY_ITEMS by ID range (matches core/items.py layout).
  const gameplay = items?.gameplay_items ?? [];
  const consumableItems = gameplay.filter((i) => i.id >= 0 && i.id <= 11);
  const equipmentItems = gameplay.filter((i) => i.id >= 12 && i.id <= 17);
  const rodItems = gameplay.filter((i) => i.id >= 18 && i.id <= 23);
  const swordItems = gameplay.filter((i) => i.id >= 24 && i.id <= 29);
  const chapterSword = swordItems.find((s) => s.chapter === chapter.chapter_num);
  const chapterRod = rodItems.find((r) => r.chapter === chapter.chapter_num);

  const resetAllExp = async () => {
    if (!expTable) return;
    for (const e of expTable.entries) {
      const v = expTable.vanilla[e.index]?.value;
      if (v !== undefined && e.value !== v) {
        await updateExpEntry(e.index, v);
      }
    }
  };

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
        {itemsLoading && (
          <div className="text-xs text-slate-500 italic mb-4">Loading items…</div>
        )}
        {itemsError && (
          <div className="text-xs text-red-400 bg-red-500/10 rounded p-2 mb-4">
            Failed to load items: {itemsError}
          </div>
        )}

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
        {swordItems.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Swords (Progression)
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-2">
              {swordItems.map((item) => (
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
        )}

        {/* All Rods */}
        {rodItems.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Magic Rods (Progression)
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-2">
              {rodItems.map((item) => (
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
        )}

        {/* Equipment */}
        {equipmentItems.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Equipment
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              {equipmentItems.map((item) => (
                <ItemCard key={item.id} item={item} icon="🛡️" />
              ))}
            </div>
          </div>
        )}

        {/* Consumables */}
        {consumableItems.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Consumables
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              {consumableItems.map((item) => (
                <ItemCard key={item.id} item={item} icon="🧪" />
              ))}
            </div>
          </div>
        )}

        {/* Inventory Caps — editable (formerly mislabeled "Shop Contents") */}
        <div className="mb-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide flex items-center gap-1">
              Inventory Caps
              <HelpChip
                content={
                  <div className="text-xs space-y-1">
                    <p>
                      8 entries at file <code>$0xD544</code> (Bank 3{' '}
                      <code>$9534</code>). Each row pins the max stack size
                      for one <code>$03xx</code> RAM variable when the
                      chest/drop pickup handler grants the item.
                    </p>
                    <p>
                      Raise BREAD's cap from 10 → 99 and the player can carry
                      99 bread (after picking up enough drops).
                    </p>
                    <p>
                      <strong>This is NOT a shop table.</strong> The previous
                      UI labeled this as "Shop Contents" with item dropdowns
                      and prices — that interpretation was wrong. Real shop
                      inventory lives in a Bank 2 bytecode interpreter that
                      hasn't been decoded. See{' '}
                      <code>docs/human/items-economy-re-answers.md</code>.
                    </p>
                  </div>
                }
              />
            </h3>
          </div>

          {inventoryCapsLoading && (
            <div className="text-xs text-slate-500 italic">Loading inventory caps…</div>
          )}
          {inventoryCapsError && (
            <div className="text-xs text-red-400 bg-red-500/10 rounded p-2 mb-2">
              {inventoryCapsError}
            </div>
          )}
          {!inventoryCapsLoading && !inventoryCaps && (
            <div className="text-xs text-slate-500 italic">
              No ROM loaded — upload a ROM to edit caps.
            </div>
          )}
          {inventoryCaps && (
            <>
              <div className="grid grid-cols-[40px_1fr_80px_24px] gap-2 px-2 text-[10px] uppercase tracking-wide text-slate-500 mb-1">
                <div>Slot</div>
                <div>Targets</div>
                <div className="text-right">Max cap</div>
                <div></div>
              </div>
              <div className="space-y-1">
                {inventoryCaps.slots.map((slot) => (
                  <InventoryCapEditor
                    key={slot.slot_index}
                    slot={slot}
                    vanillaSlot={inventoryCaps.vanilla[slot.slot_index]}
                    onChange={(max_cap) => updateInventoryCap(slot.slot_index, { max_cap })}
                  />
                ))}
              </div>
            </>
          )}
        </div>

        {/* EXP Tier Editor — editable */}
        <div className="mb-6">
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3 flex items-center gap-2">
            Overworld EXP Drops
            <HelpChip
              content={
                <div className="text-xs space-y-2">
                  <p>
                    <strong>What:</strong> The 10-entry lookup table that decides
                    how much EXP each <em>overworld</em> (action-mode) enemy gives
                    when killed. Turn-based (menu) battles use a separate path.
                  </p>
                  <p>
                    <strong>How it's indexed:</strong> Not by enemy type. Each
                    overworld screen's encounter-group entry contains a "tier"
                    byte that indexes into this table. So <em>every enemy on a
                    given screen awards the same EXP</em> — the screen's tier
                    value. The "N screens" counter under each tier shows which
                    screens point at it.
                  </p>
                  <p>
                    <strong>Why edit:</strong> Lower numbers = grindier
                    progression. Higher = faster leveling. The official "Romhack1"
                    halves this exact table (with the comment <em>"Cut exp given
                    by world enemies by half"</em>) to make the game harder.
                  </p>
                  <p className="text-slate-500">
                    Verified: ROM $0x174AA, stride 2 (every odd byte is a zero
                    separator, not a value). Confirmed against RETMOS Bank-5 XP
                    trigger code at $89CC.
                  </p>
                </div>
              }
            />
          </h3>
          {expLoading && (
            <div className="text-xs text-slate-500 italic">Loading EXP table…</div>
          )}
          {!expLoading && !expTable && (
            <div className="text-xs text-slate-500 italic">
              No ROM loaded — upload a ROM to edit EXP values.
            </div>
          )}
          {expTable && (
            <ExpTierRow
              entries={expTable.entries}
              vanilla={expTable.vanilla}
              labels={expTable.labels}
              usage={expUsage}
              onChange={updateExpEntry}
              onResetAll={resetAllExp}
            />
          )}
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
  item: GameplayItem;
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
        {item.chapter !== null && (
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
            {item.max_count !== null && (
              <span className="text-xs text-slate-500">Max: {item.max_count}</span>
            )}
            {item.ram_address !== null && (
              <span className="text-xs text-slate-600 font-mono">{item.ram_address}</span>
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
