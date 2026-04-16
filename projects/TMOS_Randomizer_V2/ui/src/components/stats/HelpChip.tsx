import type { ReactNode } from 'react';
import { Tooltip } from '../shared/Tooltip';

interface HelpChipProps {
  /** Tooltip body — accepts JSX so you can include <code>, lists, etc. */
  content: ReactNode;
  /** Optional inline label rendered before the chip. */
  label?: ReactNode;
  /** Tooltip placement. Defaults to 'top'. */
  position?: 'top' | 'bottom' | 'left' | 'right';
  /** Override the icon (defaults to ⓘ). Use ⚠ for warnings, ? for unknowns. */
  icon?: string;
  /** Tone affects color. */
  tone?: 'neutral' | 'warn' | 'unknown';
  className?: string;
}

const TONE_CLASS: Record<NonNullable<HelpChipProps['tone']>, string> = {
  neutral: 'text-slate-500 hover:text-slate-300',
  warn: 'text-amber-500 hover:text-amber-300',
  unknown: 'text-slate-600 hover:text-slate-400 italic',
};

export function HelpChip({
  content,
  label,
  position = 'top',
  icon = 'ⓘ',
  tone = 'neutral',
  className = '',
}: HelpChipProps) {
  return (
    <span className={`inline-flex items-center gap-1 ${className}`}>
      {label}
      <Tooltip content={content} position={position}>
        <span
          className={`text-xs leading-none cursor-help ${TONE_CLASS[tone]}`}
          aria-label="more info"
        >
          {icon}
        </span>
      </Tooltip>
    </span>
  );
}
