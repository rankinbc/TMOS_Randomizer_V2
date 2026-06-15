import { api } from '../../api/client';
import type { ShopSlot } from '../../api/client';
import { ByteField } from './ByteField';
import { PanelFrame, TierBadge, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

const ITEM_CODE_TIP =
  'Item-slot code indexing the $0300 counter array (no in-ROM name table exists).';
const BASE_PRICE_TIP = 'Base rupia price before class discount / chapter scaling.';

function vanillaSlot(
  vanilla: ShopSlot[] | undefined,
  shopIndex: number,
  slotIndex: number
): ShopSlot | undefined {
  return vanilla?.find((s) => s.shop_index === shopIndex && s.slot_index === slotIndex);
}

export function EconomyPanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getShopEconomy());

  const commitTrooper = async (next: number) => {
    if (!data) return;
    const prev = data;
    // optimistic
    setData({ ...data, trooper_cost: { ...data.trooper_cost, cost: next } });
    try {
      const res = await api.patchTrooperCost(next);
      setData((d) => (d ? { ...d, trooper_cost: res.trooper } : d));
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  const commitSlot = async (
    shopIndex: number,
    slotIndex: number,
    field: 'item_code' | 'base_price',
    next: number
  ) => {
    if (!data) return;
    const prev = data;
    // optimistic
    setData({
      ...data,
      shops: data.shops.map((s) =>
        s.shop_index === shopIndex && s.slot_index === slotIndex ? { ...s, [field]: next } : s
      ),
    });
    try {
      const res = await api.patchShopSlot(shopIndex, slotIndex, { [field]: next });
      setData((d) =>
        d
          ? {
              ...d,
              shops: d.shops.map((s) =>
                s.shop_index === shopIndex && s.slot_index === slotIndex ? res.slot : s
              ),
            }
          : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  // Group slots by shop_index into 8 cards.
  const shopGroups: ShopSlot[][] = [];
  if (data) {
    for (const slot of data.shops) {
      (shopGroups[slot.shop_index] ??= []).push(slot);
    }
    for (const group of shopGroups) {
      group?.sort((a, b) => a.slot_index - b.slot_index);
    }
  }

  return (
    <PanelFrame
      title="Economy & Shops"
      tier="expert"
      romNote="Trooper recruit cost + 8 shops × 4 slots · ROM_VERIFIED bytes (shop table)"
      help={
        <div className="text-xs space-y-1">
          <p>
            Trooper cost is safe to tune. Shop slots are Expert: item codes index a RAM counter
            array with no in-ROM name table, and prices are scaled by class and chapter at runtime.
          </p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="space-y-6">
          {/* Trooper cost — tier safe */}
          <div className="rounded-lg border border-slate-700 overflow-hidden">
            <div className="px-4 py-2 bg-slate-800/60 text-sm font-semibold text-slate-200 flex items-center gap-2">
              Trooper Recruitment
              <TierBadge tier="safe" />
            </div>
            <div className="px-4 py-3 flex items-center gap-2">
              <span className="flex-1 text-sm text-slate-200 flex items-center gap-1.5">
                Recruit cost
                <HelpChip content="Rupias charged to recruit a batch of 4 troopers (vanilla 100 = 25 each)." />
              </span>
              <code className="text-[10px] text-slate-600">{data.trooper_cost.rom_offset}</code>
              <ByteField
                value={data.trooper_cost.cost}
                vanilla={data.trooper_vanilla.cost}
                min={0}
                max={255}
                onCommit={commitTrooper}
                ariaLabel="Trooper recruit cost"
              />
            </div>
          </div>

          {/* Shops — tier expert */}
          <div className="grid gap-4 md:grid-cols-2">
            {shopGroups.map((slots, shopIndex) =>
              slots ? (
                <div
                  key={shopIndex}
                  className="rounded-lg border border-slate-700 overflow-hidden"
                >
                  <div className="px-4 py-2 bg-slate-800/60 text-sm font-semibold text-slate-200 flex items-center gap-2">
                    Shop {shopIndex}
                    <TierBadge tier="expert" />
                  </div>
                  <ul className="divide-y divide-slate-800">
                    {slots.map((slot) => {
                      const van = vanillaSlot(data.vanilla, slot.shop_index, slot.slot_index);
                      return (
                        <li
                          key={slot.slot_index}
                          className="px-4 py-2 flex items-center gap-2 flex-wrap"
                        >
                          <span className="flex-1 min-w-0 text-sm text-slate-200 truncate">
                            {slot.item_label}
                          </span>
                          <code className="text-[10px] text-slate-600">{slot.rom_offset}</code>
                          <span className="flex items-center gap-1">
                            <HelpChip label="code" content={ITEM_CODE_TIP} />
                            <ByteField
                              value={slot.item_code}
                              vanilla={van?.item_code}
                              min={0}
                              max={255}
                              onCommit={(next) =>
                                commitSlot(slot.shop_index, slot.slot_index, 'item_code', next)
                              }
                              ariaLabel={`Shop ${slot.shop_index} slot ${slot.slot_index} item code`}
                            />
                          </span>
                          <span className="flex items-center gap-1">
                            <HelpChip label="price" content={BASE_PRICE_TIP} />
                            <ByteField
                              value={slot.base_price}
                              vanilla={van?.base_price}
                              min={0}
                              max={255}
                              onCommit={(next) =>
                                commitSlot(slot.shop_index, slot.slot_index, 'base_price', next)
                              }
                              ariaLabel={`Shop ${slot.shop_index} slot ${slot.slot_index} base price`}
                            />
                          </span>
                        </li>
                      );
                    })}
                  </ul>
                </div>
              ) : null
            )}
          </div>
        </div>
      )}
    </PanelFrame>
  );
}
