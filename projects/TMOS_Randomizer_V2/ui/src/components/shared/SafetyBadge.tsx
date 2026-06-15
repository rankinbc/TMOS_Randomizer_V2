import type { SafetyTier } from '../../types/metadata';
import { tierStyle } from '../../utils/safety';

const SYMBOL: Record<SafetyTier, string> = {
  safe: '●',     // ●
  caution: '▲',  // ▲
  danger: '⛔',   // ⛔
};

export function SafetyBadge({ tier }: { tier: SafetyTier }) {
  const style = tierStyle(tier);
  return (
    <span
      className={`inline-flex items-center gap-1 text-xs ${style.border} border rounded px-1`}
      title={`${style.label} field`}
    >
      <span className={`w-2 h-2 rounded-full ${style.dot}`} aria-hidden />
      {SYMBOL[tier]}
    </span>
  );
}
