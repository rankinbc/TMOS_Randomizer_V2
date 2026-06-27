import { useEffect, useRef, useState } from 'react';
import type { SimplifiedChapterPlan } from '../../types/randomizer';
import type { GameplayItem, BattleItem, ShopSlot } from '../../api/client';
import { useRandomizerStore } from '../../store';
import { InventoryCapEditor } from '../items/InventoryCapEditor';
import { ExpTierRow } from '../items/ExpTierRow';
import { HelpChip } from '../stats/HelpChip';
import { GridPicker } from '../shared/GridPicker';
import type { GridPickerItem } from '../shared/GridPicker';
import { ByteField } from '../advanced/ByteField';

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

/** Text-only category badge — no emoji. */
function CategoryBadge({ category }: { category: string }) {
  const configs: Record<string, { abbr: string; cls: string }> = {
    progression: { abbr: 'PRG', cls: 'bg-amber-900/40 text-amber-300 border-amber-800/50' },
    equipment:   { abbr: 'EQP', cls: 'bg-sky-900/40 text-sky-300 border-sky-800/50' },
    consumable:  { abbr: 'CSM', cls: 'bg-emerald-900/40 text-emerald-300 border-emerald-800/50' },
    special:     { abbr: 'SPC', cls: 'bg-violet-900/40 text-violet-300 border-violet-800/50' },
  };
  const cfg = configs[category] ?? {
    abbr: category.slice(0, 3).toUpperCase(),
    cls: 'bg-slate-800 text-slate-400 border-slate-700',
  };
  return (
    <span
      className={`inline-block shrink-0 px-1.5 py-0.5 rounded text-[10px] font-bold font-mono border ${cfg.cls}`}
    >
      {cfg.abbr}
    </span>
  );
}

/** Two-letter text glyph replacing emoji section icons. */
function SectionTypeBadge({ type }: { type: string }) {
  const abbrs: Record<string, string> = {
    overworld: 'OW',
    town: 'TN',
    dungeon: 'DN',
    maze: 'MZ',
    boss: 'BS',
    special: 'SP',
  };
  const abbr = abbrs[type] ?? type.slice(0, 2).toUpperCase();
  return (
    <span className="inline-flex items-center justify-center w-8 h-8 rounded bg-slate-700 border border-slate-600 text-[10px] font-mono font-bold text-slate-300 shrink-0 uppercase">
      {abbr}
    </span>
  );
}

/** Typographic card for a gameplay item — no emoji. */
function ItemCard({
  item,
  compact,
  highlight,
}: {
  item: GameplayItem;
  compact?: boolean;
  highlight?: boolean;
}) {
  const idHex = `0x${item.id.toString(16).toUpperCase().padStart(2, '0')}`;

  if (compact) {
    return (
      <div
        className={`rounded-lg p-2 text-center ${
          highlight
            ? 'bg-amber-500/20 border border-amber-500/50'
            : 'bg-slate-800'
        }`}
      >
        <CategoryBadge category={item.category} />
        <div
          className={`text-xs font-medium mt-1 ${
            highlight ? 'text-amber-300' : 'text-slate-200'
          }`}
        >
          {item.name}
        </div>
        {item.chapter !== null && (
          <div className="text-[10px] text-slate-500">Ch.{item.chapter}</div>
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
      <div className="flex items-start gap-2 mb-2">
        <CategoryBadge category={item.category} />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span
              className={`text-sm font-semibold ${
                highlight ? 'text-amber-300' : 'text-slate-100'
              }`}
            >
              {item.name}
            </span>
            <span className="text-[10px] text-slate-500 font-mono">{idHex}</span>
            {item.chapter !== null && (
              <span className="text-[10px] text-slate-500">Ch.{item.chapter}</span>
            )}
          </div>
        </div>
      </div>
      <p className="text-xs text-slate-400 mb-1.5 leading-relaxed">{item.effect}</p>
      <div className="flex flex-wrap gap-3 text-[10px]">
        {item.max_count !== null && (
          <span className="text-slate-500">
            Max: <span className="text-slate-400 font-medium">{item.max_count}</span>
          </span>
        )}
        {item.ram_address !== null && (
          <span className="text-slate-600 font-mono">{item.ram_address}</span>
        )}
      </div>
    </div>
  );
}

/** Card for a battle-namespace item (no ROM sprite; show all metadata). */
function BattleItemCard({ item }: { item: BattleItem }) {
  const idHex = `0x${item.id.toString(16).toUpperCase().padStart(2, '0')}`;
  return (
    <div className="rounded-lg p-3 bg-slate-800">
      <div className="flex items-start gap-2 mb-2">
        <span className="inline-block shrink-0 px-1.5 py-0.5 rounded text-[10px] font-bold font-mono border bg-rose-900/40 text-rose-300 border-rose-800/50">
          BTL
        </span>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-sm font-semibold text-slate-100">{item.name}</span>
            <span className="text-[10px] text-slate-500 font-mono">{idHex}</span>
          </div>
        </div>
      </div>
      {item.notes && (
        <p className="text-xs text-slate-400 mb-1.5 leading-relaxed">{item.notes}</p>
      )}
      <div className="flex flex-wrap gap-3 text-[10px]">
        <span className="text-slate-500">
          Sound: <span className="text-slate-400 font-mono">{item.pickup_sound}</span>
        </span>
        <span className="text-slate-500">
          Flags: <span className="text-slate-400 font-mono">0x{item.flags.toString(16).toUpperCase().padStart(2, '0')}</span>
        </span>
        {item.handler_addr && (
          <span className="text-slate-600 font-mono">Handler: {item.handler_addr}</span>
        )}
        {item.count_addr && (
          <span className="text-slate-600 font-mono">Count: {item.count_addr}</span>
        )}
      </div>
    </div>
  );
}

/** Single shop slot row: GridPicker trigger for item_code + ByteField for base_price. */
function ShopSlotEditor({
  slot,
  vanillaSlot,
  itemPickerItems,
  onItemCodeChange,
  onPriceChange,
}: {
  slot: ShopSlot;
  vanillaSlot: ShopSlot | undefined;
  itemPickerItems: GridPickerItem[];
  onItemCodeChange: (shopIndex: number, slotIndex: number, itemCode: number) => Promise<void>;
  onPriceChange: (shopIndex: number, slotIndex: number, price: number) => Promise<void>;
}) {
  const [pickerOpen, setPickerOpen] = useState(false);
  const anchorRef = useRef<HTMLElement | null>(null);

  const itemChanged = vanillaSlot !== undefined && slot.item_code !== vanillaSlot.item_code;
  const priceChanged = vanillaSlot !== undefined && slot.base_price !== vanillaSlot.base_price;
  const anyChanged = itemChanged || priceChanged;

  return (
    <div
      className={`rounded-md p-2 flex items-center gap-2 ${
        anyChanged
          ? 'bg-amber-500/5 border-l-2 border-amber-500'
          : 'bg-slate-900/40'
      }`}
    >
      <div className="text-[10px] text-slate-600 font-mono w-6 text-center shrink-0">
        {slot.slot_index}
      </div>
      <button
        ref={(el) => { anchorRef.current = el; }}
        type="button"
        onClick={() => setPickerOpen((v) => !v)}
        className={`flex-1 min-w-0 text-left rounded px-2 py-1 text-xs transition-colors border ${
          itemChanged
            ? 'bg-amber-500/10 border-amber-500/50 text-amber-300 hover:bg-amber-500/20'
            : 'bg-slate-800 border-slate-700 text-slate-200 hover:bg-slate-700'
        }`}
        title="Click to change item in this shop slot"
      >
        <span className="font-medium">{slot.item_label}</span>
        <span className="text-slate-500 font-mono ml-1.5 text-[10px]">({slot.item_code_hex})</span>
      </button>
      <span className="text-[10px] text-slate-500 shrink-0">price</span>
      <ByteField
        value={slot.base_price}
        vanilla={vanillaSlot?.base_price}
        min={0}
        max={255}
        width="w-14"
        onCommit={(v) => onPriceChange(slot.shop_index, slot.slot_index, v)}
        ariaLabel={`Price for ${slot.item_label} in shop ${slot.shop_index}`}
      />
      {pickerOpen && (
        <GridPicker
          items={itemPickerItems}
          currentId={slot.item_code}
          onPick={(id) => {
            void onItemCodeChange(slot.shop_index, slot.slot_index, id);
          }}
          onClose={() => setPickerOpen(false)}
          anchorRef={anchorRef}
          columns={5}
          title="Select Item"
          renderCell={(item) => (
            <div className="p-1.5 text-center min-h-[52px] flex flex-col justify-center gap-0.5">
              <div className="text-[10px] font-mono text-slate-500">{item.hex}</div>
              <div className="text-[11px] font-medium text-slate-200 leading-tight px-0.5">
                {item.label}
              </div>
            </div>
          )}
        />
      )}
    </div>
  );
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

export function ItemsView({ chapter }: ItemsViewProps) {
  const chapterName = CHAPTER_NAMES[chapter.chapter_num] || `Chapter ${chapter.chapter_num}`;

  // Items registry (static metadata from /api/rom/items)
  const items = useRandomizerStore((s) => s.items);
  const itemsLoading = useRandomizerStore((s) => s.itemsLoading);
  const itemsError = useRandomizerStore((s) => s.itemsError);
  const loadItems = useRandomizerStore((s) => s.loadItems);

  // Shop economy (item_code + base_price per slot, trooper cost)
  const shopEconomy = useRandomizerStore((s) => s.shopEconomy);
  const shopEconomyLoading = useRandomizerStore((s) => s.shopEconomyLoading);
  const shopEconomyError = useRandomizerStore((s) => s.shopEconomyError);
  const loadShopEconomy = useRandomizerStore((s) => s.loadShopEconomy);
  const updateShopSlot = useRandomizerStore((s) => s.updateShopSlot);
  const updateTrooperCost = useRandomizerStore((s) => s.updateTrooperCost);

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
    if (!shopEconomy && !shopEconomyLoading) loadShopEconomy();
    // intentionally one-shot per mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Partition GAMEPLAY_ITEMS by ID range (matches core/items.py layout).
  const gameplay = items?.gameplay_items ?? [];
  const battleItems = items?.battle_items ?? [];
  const consumableItems = gameplay.filter((i) => i.id >= 0 && i.id <= 11);
  const equipmentItems = gameplay.filter((i) => i.id >= 12 && i.id <= 17);
  const rodItems = gameplay.filter((i) => i.id >= 18 && i.id <= 23);
  const swordItems = gameplay.filter((i) => i.id >= 24 && i.id <= 29);
  const chapterSword = swordItems.find((s) => s.chapter === chapter.chapter_num);
  const chapterRod = rodItems.find((r) => r.chapter === chapter.chapter_num);

  // Build GridPickerItem list for shop slot item-code picker.
  // Items have no sprite — render id hex + name only.
  const itemPickerItems: GridPickerItem[] = gameplay.map((item) => ({
    id: item.id,
    label: item.name,
    hex: `0x${item.id.toString(16).toUpperCase().padStart(2, '0')}`,
    sub: item.category,
  }));

  // Group shop slots by shop index
  const shopsByIndex: Record<number, ShopSlot[]> = {};
  if (shopEconomy) {
    for (const slot of shopEconomy.shops) {
      if (!shopsByIndex[slot.shop_index]) shopsByIndex[slot.shop_index] = [];
      shopsByIndex[slot.shop_index].push(slot);
    }
  }

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
          Items &amp; Economy — {chapterName}
        </h2>
        <p className="text-sm text-slate-400">
          Item registry, shop economy, inventory caps and EXP tuning for Chapter {chapter.chapter_num}
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4 space-y-6">
        {itemsLoading && (
          <div className="text-xs text-slate-500 italic">Loading items…</div>
        )}
        {itemsError && (
          <div className="text-xs text-red-400 bg-red-500/10 rounded p-2">
            Failed to load items: {itemsError}
          </div>
        )}

        {/* ── Chapter Progression Items ── */}
        {(chapterSword || chapterRod) && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Chapter {chapter.chapter_num} Progression Items
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {chapterSword && <ItemCard item={chapterSword} highlight />}
              {chapterRod && <ItemCard item={chapterRod} highlight />}
            </div>
          </section>
        )}

        {/* ── Swords (Progression) ── */}
        {swordItems.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
              Swords — Progression
            </h3>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2">
              {swordItems.map((item) => (
                <ItemCard
                  key={item.id}
                  item={item}
                  compact
                  highlight={item.chapter === chapter.chapter_num}
                />
              ))}
            </div>
          </section>
        )}

        {/* ── Magic Rods (Progression) ── */}
        {rodItems.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
              Magic Rods — Progression
            </h3>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2">
              {rodItems.map((item) => (
                <ItemCard
                  key={item.id}
                  item={item}
                  compact
                  highlight={item.chapter === chapter.chapter_num}
                />
              ))}
            </div>
          </section>
        )}

        {/* ── Equipment ── */}
        {equipmentItems.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
              Equipment
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              {equipmentItems.map((item) => (
                <ItemCard key={item.id} item={item} />
              ))}
            </div>
          </section>
        )}

        {/* ── Consumables ── */}
        {consumableItems.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2">
              Consumables
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              {consumableItems.map((item) => (
                <ItemCard key={item.id} item={item} />
              ))}
            </div>
          </section>
        )}

        {/* ── Battle Items (separate namespace) ── */}
        {battleItems.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-2 flex items-center gap-1">
              Battle Items
              <HelpChip
                content={
                  <div className="text-xs space-y-1">
                    <p>
                      Battle items use a <strong>separate ID namespace</strong> from gameplay
                      items (see <code>core/items.py</code>). They appear in turn-based combat
                      only and are not editable in the current build.
                    </p>
                  </div>
                }
              />
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
              {battleItems.map((item) => (
                <BattleItemCard key={item.id} item={item} />
              ))}
            </div>
          </section>
        )}

        {/* ── Shop Economy ── */}
        <section>
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide flex items-center gap-1">
              Shop Economy
              <HelpChip
                content={
                  <div className="text-xs space-y-1">
                    <p>
                      Each shop slot has an <strong>item code</strong> (which item it sells) and a
                      <strong> base price</strong>. Click an item name to open the item picker;
                      edit the price field directly.
                    </p>
                    <p>
                      <strong>Trooper cost</strong> is the rupia cost to recruit one trooper
                      from any tavern.
                    </p>
                    <p className="text-slate-500">
                      ROM: shop table offset {shopEconomy?.shop_table_offset ?? '…'}
                    </p>
                  </div>
                }
              />
            </h3>
          </div>

          {shopEconomyLoading && (
            <div className="text-xs text-slate-500 italic">Loading shop economy…</div>
          )}
          {shopEconomyError && (
            <div className="text-xs text-red-400 bg-red-500/10 rounded p-2 mb-2">
              {shopEconomyError}
            </div>
          )}
          {!shopEconomyLoading && !shopEconomy && (
            <div className="text-xs text-slate-500 italic">
              No ROM loaded — upload a ROM to edit shop data.
            </div>
          )}

          {shopEconomy && (
            <div className="space-y-4">
              {/* Trooper cost */}
              <div className="flex items-center gap-3 bg-slate-900/40 rounded-md p-3">
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-medium text-slate-200">Trooper Cost</div>
                  <div className="text-[10px] text-slate-500 font-mono">
                    {shopEconomy.trooper_cost.rom_offset} — rupia per recruit
                  </div>
                </div>
                <ByteField
                  value={shopEconomy.trooper_cost.cost}
                  vanilla={shopEconomy.trooper_vanilla.cost}
                  min={1}
                  max={255}
                  width="w-14"
                  onCommit={(v) => updateTrooperCost(v)}
                  ariaLabel="Trooper recruitment cost"
                />
              </div>

              {/* Shop slots grouped by shop index */}
              {Object.entries(shopsByIndex).map(([shopIdxStr, slots]) => {
                const shopIdx = Number(shopIdxStr);
                return (
                  <div key={shopIdx}>
                    <div className="text-[10px] text-slate-500 uppercase tracking-wide font-mono mb-1 px-1">
                      Shop {shopIdx}
                    </div>
                    <div className="space-y-1">
                      {slots.map((slot) => {
                        const vanilla = shopEconomy.vanilla.find(
                          (v) =>
                            v.shop_index === slot.shop_index &&
                            v.slot_index === slot.slot_index
                        );
                        return (
                          <ShopSlotEditor
                            key={`${slot.shop_index}-${slot.slot_index}`}
                            slot={slot}
                            vanillaSlot={vanilla}
                            itemPickerItems={itemPickerItems}
                            onItemCodeChange={(si, sli, id) =>
                              updateShopSlot(si, sli, { item_code: id })
                            }
                            onPriceChange={(si, sli, price) =>
                              updateShopSlot(si, sli, { base_price: price })
                            }
                          />
                        );
                      })}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>

        {/* ── Inventory Caps ── */}
        <section>
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide flex items-center gap-1">
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
                <div />
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
        </section>

        {/* ── Overworld EXP Drops ── */}
        <section>
          <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-3 flex items-center gap-2">
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
        </section>

        {/* ── Potential Item Locations in this chapter ── */}
        {chapter.sections.length > 0 && (
          <section>
            <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wide mb-3">
              Potential Item Locations in {chapterName}
            </h3>
            <div className="space-y-2">
              {chapter.sections.map((section) => (
                <div
                  key={section.section_id}
                  className="bg-slate-800 rounded-lg p-3 flex items-center justify-between"
                >
                  <div className="flex items-center gap-3">
                    <SectionTypeBadge type={section.type} />
                    <div>
                      <div className="text-sm font-medium text-slate-200 capitalize">
                        {section.section_id.replace(/_/g, ' ')}
                      </div>
                      <div className="text-xs text-slate-500">
                        {section.type} — {section.screen_count} screens
                      </div>
                    </div>
                  </div>
                  <div className="text-xs text-slate-400">
                    {getExpectedItemTypes(section.type)}
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}
