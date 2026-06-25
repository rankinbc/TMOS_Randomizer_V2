export interface SubTab<T extends string> {
  id: T;
  label: string;
  expert?: boolean;
}

interface SubTabBarProps<T extends string> {
  tabs: SubTab<T>[];
  active: T;
  onSelect: (id: T) => void;
}

/**
 * Segmented sub-tab bar shared by the entity tabs (Hero / Enemies / Items /
 * Graphics). A tab flagged `expert` renders an inline amber "expert" tag — the
 * danger marker that replaced the old full-page Expert gate.
 */
export function SubTabBar<T extends string>({ tabs, active, onSelect }: SubTabBarProps<T>) {
  return (
    <div className="flex-shrink-0 bg-slate-800/60 border-b border-slate-700 overflow-x-auto">
      <div className="flex">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => onSelect(t.id)}
            className={`whitespace-nowrap px-4 py-2.5 text-sm font-medium border-b-2 transition-colors ${
              active === t.id
                ? 'text-blue-400 border-blue-400 bg-slate-700/40'
                : 'text-slate-400 border-transparent hover:text-slate-200 hover:bg-slate-700/20'
            }`}
          >
            {t.label}
            {t.expert && (
              <span className="ml-1.5 align-middle text-[10px] uppercase tracking-wide text-amber-400/80">
                expert
              </span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}
