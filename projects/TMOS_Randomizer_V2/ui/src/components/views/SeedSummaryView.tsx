import { useRef, useState } from 'react';
import { useRandomizerStore } from '../../store';
import type { EnemySpoiler, ShopSpoiler } from '../../api/client';

/**
 * Seed summary — everything the last randomization actually produced:
 * shop inventories, magic base prices, encounter lineups, per-chapter
 * navigability. Data comes from the apply-preview result (same content
 * the CLI writes to spoiler.txt), so it reflects the world the user will
 * actually play, not just the plan. A spoiler.json written by the CLI can
 * also be opened directly for viewing.
 */

interface NavChapter {
  chapter_num: number;
  reachable_percent: number;
  baseline_percent: number | null;
  fragmented: boolean;
}

interface SummaryData {
  seed: number;
  screensModified: number | null;
  /** null = the live applied seed; otherwise the loaded file's name. */
  sourceFile: string | null;
  shops: ShopSpoiler | null;
  enemies: EnemySpoiler | null;
  navChapters: NavChapter[];
}

/** Map a CLI spoiler.json (SpoilerLog.to_dict shape) to the view model. */
function parseSpoilerJson(fileName: string, raw: unknown): SummaryData {
  const data = raw as Record<string, unknown>;
  const meta = (data.meta ?? {}) as Record<string, unknown>;
  const seed = typeof meta.seed === 'number' ? meta.seed : 0;

  const shopEntries = Array.isArray(data.shops) ? (data.shops as Record<string, unknown>[]) : [];
  const magic = Array.isArray(data.magic_base_prices) ? (data.magic_base_prices as number[]) : [];
  const shops: ShopSpoiler | null = shopEntries.length
    ? {
        seed,
        magic_base_prices: magic,
        shops: shopEntries.map((entry, i) => ({
          shop_index: i,
          slots: (Array.isArray(entry.items) ? (entry.items as Record<string, unknown>[]) : []).map(
            (item) => ({
              item_label: String(item.name ?? '?'),
              item_code: String(item.code ?? ''),
              price: Number(item.price ?? 0),
            })
          ),
        })),
      }
    : null;

  const lineups = Array.isArray(data.enemy_lineups)
    ? (data.enemy_lineups as EnemySpoiler['lineups'])
    : [];
  const enemies: EnemySpoiler | null = lineups.length
    ? { seed, lineups, group_reassignments: {}, rate_changes: {} }
    : null;

  return {
    seed,
    screensModified: null,
    sourceFile: fileName,
    shops,
    enemies,
    navChapters: [],
  };
}

export function SeedSummaryView() {
  const live = useRandomizerStore((s) => s.lastSeedSummary);
  const [loaded, setLoaded] = useState<SummaryData | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const openSpoilerFile = async (file: File) => {
    setLoadError(null);
    try {
      const parsed = parseSpoilerJson(file.name, JSON.parse(await file.text()));
      if (!parsed.shops && !parsed.enemies) {
        setLoadError(
          `${file.name} has no shop or encounter data — was it written before those sections existed?`
        );
        return;
      }
      setLoaded(parsed);
    } catch {
      setLoadError(`${file.name} is not a readable spoiler.json file.`);
    }
  };

  const openButton = (
    <>
      <input
        ref={fileInputRef}
        type="file"
        accept=".json"
        className="hidden"
        onChange={(e) => {
          const f = e.target.files?.[0];
          if (f) openSpoilerFile(f);
          e.target.value = '';
        }}
      />
      <button
        onClick={() => fileInputRef.current?.click()}
        className="px-3 py-1.5 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded transition-colors"
      >
        Open spoiler.json
      </button>
    </>
  );

  const summary: SummaryData | null =
    loaded ??
    (live
      ? {
          seed: live.seed,
          screensModified: live.screens_modified,
          sourceFile: null,
          shops: live.shops ?? null,
          enemies: live.enemies ?? null,
          navChapters: (live.navigability?.chapters ?? []).map((c) => ({
            chapter_num: c.chapter_num,
            reachable_percent: c.reachable_percent,
            baseline_percent: c.baseline_percent,
            fragmented: c.fragmented,
          })),
        }
      : null);

  if (!summary) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="text-center p-8">
          <div className="text-4xl mb-4 opacity-50">{'\u{1F4CB}'}</div>
          <h3 className="text-lg font-medium text-slate-300 mb-2">No Seed Applied</h3>
          <p className="text-sm text-slate-500 max-w-sm mb-4">
            Run Randomize first — the applied seed&apos;s shops, encounters and
            navigability will show up here. Or open a spoiler.json written by
            the command-line randomizer.
          </p>
          {openButton}
          {loadError && <p className="mt-3 text-sm text-red-400">{loadError}</p>}
        </div>
      </div>
    );
  }

  const { shops, enemies, navChapters } = summary;

  const downloadSummary = () => {
    const lines: string[] = [
      `TMOS Randomizer — seed ${summary.seed}`,
      summary.screensModified != null ? `Screens modified: ${summary.screensModified}` : '',
      '',
    ];
    if (navChapters.length) {
      lines.push('NAVIGABILITY (reachable % vs vanilla)');
      for (const c of navChapters) {
        lines.push(
          `  Chapter ${c.chapter_num}: ${c.reachable_percent}%` +
            (c.baseline_percent != null ? ` (vanilla ${c.baseline_percent}%)` : '') +
            (c.fragmented ? '  [FRAGMENTED]' : '')
        );
      }
      lines.push('');
    }
    if (shops) {
      lines.push('SHOP INVENTORIES');
      for (const shop of shops.shops) {
        lines.push(`  Shop ${shop.shop_index}`);
        for (const slot of shop.slots) {
          lines.push(`    ${slot.item_label} (${slot.item_code})  ${slot.price}`);
        }
      }
      if (shops.magic_base_prices?.length) {
        lines.push(`  Magic base prices: ${shops.magic_base_prices.join(', ')}`);
      }
      lines.push('');
    }
    if (enemies) {
      lines.push('ENCOUNTER LINEUPS');
      let ch = 0;
      for (const lineup of enemies.lineups) {
        if (lineup.chapter !== ch) {
          ch = lineup.chapter;
          lines.push(`  Chapter ${ch}`);
        }
        const names = lineup.slots.map((s) => s.name).join(', ') || '(empty)';
        lines.push(`    Lineup ${lineup.lineup_index}: ${names}`);
      }
    }
    const blob = new Blob([lines.join('\n')], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `tmos-seed-${summary.seed}-summary.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="h-full overflow-y-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-slate-200">
            Seed {summary.seed}
          </h2>
          {summary.sourceFile ? (
            <p className="text-sm text-amber-400">
              Viewing {summary.sourceFile}{' '}
              <button
                onClick={() => setLoaded(null)}
                className="ml-2 text-slate-400 underline hover:text-slate-200"
              >
                back to applied seed
              </button>
            </p>
          ) : (
            summary.screensModified != null && (
              <p className="text-sm text-slate-400">
                {summary.screensModified} screens modified
              </p>
            )
          )}
        </div>
        <div className="flex items-center gap-2">
          {openButton}
          <button
            onClick={downloadSummary}
            className="px-3 py-1.5 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded transition-colors"
          >
            Download summary
          </button>
        </div>
      </div>
      {loadError && <p className="text-sm text-red-400">{loadError}</p>}

      {/* Navigability */}
      {navChapters.length > 0 && (
        <section>
          <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
            Navigability
          </h3>
          <div className="grid grid-cols-5 gap-2">
            {navChapters.map((c) => (
              <div
                key={c.chapter_num}
                className={`rounded p-3 border ${
                  c.fragmented
                    ? 'border-amber-500/40 bg-amber-500/10'
                    : 'border-slate-700 bg-slate-800'
                }`}
              >
                <div className="text-xs text-slate-400">Chapter {c.chapter_num}</div>
                <div className="text-lg font-semibold text-slate-200">
                  {c.reachable_percent}%
                </div>
                {c.baseline_percent != null && (
                  <div className="text-xs text-slate-500">
                    vanilla {c.baseline_percent}%
                  </div>
                )}
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Shops */}
      <section>
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Shop Inventories
        </h3>
        {shops ? (
          <>
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
              {shops.shops.map((shop) => (
                <div
                  key={shop.shop_index}
                  className="rounded border border-slate-700 bg-slate-800 p-3"
                >
                  <div className="text-xs font-medium text-slate-400 mb-2">
                    Shop {shop.shop_index}
                  </div>
                  <table className="w-full text-sm">
                    <tbody>
                      {shop.slots.map((slot, i) => (
                        <tr key={i}>
                          <td className="text-slate-200 pr-2">{slot.item_label}</td>
                          <td className="text-slate-500 text-xs pr-2 font-mono">{slot.item_code}</td>
                          <td className="text-right text-amber-300">{slot.price}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ))}
            </div>
            {shops.magic_base_prices?.length > 0 && (
              <p className="mt-2 text-xs text-slate-500">
                Magic base prices (in-game price = base × (chapter+1)):{' '}
                {shops.magic_base_prices.join(', ')}
              </p>
            )}
          </>
        ) : (
          <p className="text-sm text-slate-500">
            Shop randomization was not applied to this seed.
          </p>
        )}
      </section>

      {/* Encounter Lineups */}
      <section>
        <h3 className="text-sm font-semibold text-slate-400 uppercase tracking-wide mb-3">
          Encounter Lineups
        </h3>
        {enemies ? (
          <div className="space-y-3">
            {[1, 2, 3, 4, 5].map((ch) => {
              const lineups = enemies.lineups.filter((l) => l.chapter === ch);
              if (!lineups.length) return null;
              return (
                <div key={ch} className="rounded border border-slate-700 bg-slate-800 p-3">
                  <div className="text-xs font-medium text-slate-400 mb-2">
                    Chapter {ch}
                  </div>
                  <div className="space-y-1">
                    {lineups.map((l) => (
                      <div key={l.lineup_index} className="text-sm">
                        <span className="text-slate-500 mr-2">
                          Lineup {l.lineup_index}:
                        </span>
                        <span className="text-slate-200">
                          {l.slots.map((s) => s.name).join(', ') || '(empty)'}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <p className="text-sm text-slate-500">
            Enemy randomization was not applied to this seed.
          </p>
        )}
      </section>
    </div>
  );
}
