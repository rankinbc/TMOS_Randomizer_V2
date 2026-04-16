import { HelpChip } from './HelpChip';

/**
 * Read-only display of class effective tier behavior.
 *
 * The tier-by-class function lives at $F0CF (sword) and $F0ED (rod). Editing
 * it requires writing 6502 assembly opcodes, not just byte values, and the
 * downstream side effects on equipment menus, save state, and class-change
 * events have NOT been traced. We surface the current behavior for awareness
 * but don't expose it as editable in v1.
 *
 * Source: GameAnalysis2 raw_research/player_damage_table.md (LF0CF, $F0ED).
 */
export function ClassTierPanel() {
  return (
    <div className="bg-slate-900/40 rounded p-3 space-y-2">
      <div className="flex items-center gap-2 text-sm font-semibold text-slate-200">
        Class Effective Weapon Tier
        <HelpChip
          tone="warn"
          icon="⚠"
          content={
            <div className="text-xs space-y-1">
              <p>
                When a class wields a weapon below their primary type, the game
                internally subtracts a fixed amount from the weapon's tier index
                before resolving damage. Functions at <code>$F0CF</code> (sword)
                and <code>$F0ED</code> (rod).
              </p>
              <p>
                <strong>Editing not exposed in v1.</strong> The class-tier function
                is 6502 code, not a byte table; downstream effects on equipment
                menus and class-change events haven't been traced.
              </p>
            </div>
          }
        />
      </div>

      <table className="w-full text-xs">
        <thead className="text-[10px] uppercase tracking-wide text-slate-500">
          <tr>
            <th className="text-left py-1">Class</th>
            <th className="text-right pr-3">Sword tier</th>
            <th className="text-right pr-3">Rod tier</th>
            <th></th>
          </tr>
        </thead>
        <tbody className="font-mono">
          <ClassRow name="Fighter" sword="full" rod="−1" />
          <ClassRow name="Saint" sword="−2" rod="−1" />
          <ClassRow name="Magician" sword="−3" rod="full" />
        </tbody>
      </table>

      <ul className="text-[11px] text-slate-500 space-y-1">
        <li>
          ⚠ Side effects on equipment menus across class-change boundaries:{' '}
          <span className="italic text-slate-600">UNKNOWN</span>
        </li>
        <li>
          ⚠ Behavior when wielding a tier-0 (negative-resolved) weapon:{' '}
          <span className="italic text-slate-600">UNKNOWN</span>
        </li>
      </ul>
    </div>
  );
}

function ClassRow({ name, sword, rod }: { name: string; sword: string; rod: string }) {
  return (
    <tr className="border-t border-slate-800">
      <td className="py-1 text-slate-300">{name}</td>
      <td className="text-right pr-3 text-orange-300">{sword}</td>
      <td className="text-right pr-3 text-fuchsia-300">{rod}</td>
      <td className="text-right">
        <span className="text-[10px] text-slate-700 italic">read-only</span>
      </td>
    </tr>
  );
}
