import type { SafetyTier } from '../../types/metadata';
import { tierStyle } from '../../utils/safety';

const SYMBOL: Record<SafetyTier, string> = {
  safe: '●',
  caution: '▲',
  danger: '⛔',
};

export function SafetyBadge({ tier }: { tier: SafetyTier }) {
  const style = tierStyle(tier);
  return (
    <span
      role="img"
      aria-label={`${style.label} field`}
      className={`inline-flex items-center gap-1 text-xs ${style.border} border rounded px-1`}
    >
      <span className={`w-2 h-2 rounded-full ${style.dot}`} aria-hidden />
      <span aria-hidden>{SYMBOL[tier]}</span>
    </span>
  );
}
