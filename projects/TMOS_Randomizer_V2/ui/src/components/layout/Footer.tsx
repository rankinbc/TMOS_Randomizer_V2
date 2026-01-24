import { useRandomizerStore } from '../../store';

export function Footer() {
  const { plan, romLoaded, romFilename } = useRandomizerStore();

  // Calculate totals from plan
  const totalScreens = plan?.chapters.reduce((sum, ch) => sum + ch.total_screens, 0) ?? 0;
  const chapterCount = plan?.chapters.length ?? 0;

  return (
    <footer className="bg-slate-800 border-t border-slate-700 px-4 py-2">
      <div className="flex items-center justify-between">
        {/* Left: Plan Status */}
        <div className="flex items-center gap-4 text-sm text-slate-400">
          {plan ? (
            <>
              <span>
                Total: <span className="text-slate-200">{totalScreens} screens</span>
              </span>
              <span>
                Chapters: <span className="text-slate-200">{chapterCount}</span>
              </span>
              <span>
                Seed: <span className="text-slate-200 font-mono">{plan.meta.seed}</span>
              </span>
              {plan.validation && (
                <span className={plan.validation.is_valid ? 'text-green-400' : 'text-red-400'}>
                  {plan.validation.is_valid ? '✓ Valid' : '✕ Invalid'}
                </span>
              )}
            </>
          ) : (
            <span className="text-slate-500">No plan generated</span>
          )}
        </div>

        {/* Right: ROM Status */}
        <div className="flex items-center gap-4 text-sm text-slate-400">
          {romLoaded ? (
            <span>
              ROM: <span className="text-slate-200">{romFilename}</span>
            </span>
          ) : (
            <span className="text-slate-500">No ROM loaded</span>
          )}
        </div>
      </div>
    </footer>
  );
}
