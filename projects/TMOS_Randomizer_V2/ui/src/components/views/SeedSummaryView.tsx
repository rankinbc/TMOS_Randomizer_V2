import { useRandomizerStore } from '../../store';

/**
 * Seed summary — everything the last randomization actually produced:
 * shop inventories, magic base prices, encounter lineups, per-chapter
 * navigability. Data comes from the apply-preview result (same content
 * the CLI writes to spoiler.txt), so it reflects the world the user will
 * actually play, not just the plan.
 */
export function SeedSummaryView() {
  const summary = useRandomizerStore((s) => s.lastSeedSummary);

  if (!summary) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="text-center p-8">
          <div className="text-4xl mb-4 opacity-50">{'\u{1F4CB}'}</div>
          <h3 className="text-lg font-medium text-slate-300 mb-2">No Seed Applied</h3>
          <p className="text-sm text-slate-500 max-w-sm">
            Run Randomize first — the applied seed&apos;s shops, encounters and
            navigability will show up here.
          </p>
        </div>
      </div>
    );
  }

  const { shops, enemies } = summary;
  const navChapters = summary.navigability?.chapters ?? [];

  const downloadSummary = () => {
    const lines: string[] = [
      `TMOS Randomizer — seed ${summary.seed}`,
      `Screens modified: ${summary.screens_modified}`,
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
          <p className="text-sm text-slate-400">
            {summary.screens_modified} screens modified
          </p>
        </div>
        <button
          onClick={downloadSummary}
          className="px-3 py-1.5 text-sm bg-slate-700 hover:bg-slate-600 text-slate-200 rounded transition-colors"
        >
          Download summary
        </button>
      </div>

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
                          <td className="text-slate-500 text-xs pr-2">{slot.item_code}</td>
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
