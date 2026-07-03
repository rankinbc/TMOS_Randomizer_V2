/**
 * Eight-point star (Rub el Hizb) — the app's mark, drawn from the game's
 * Islamic-geometry vernacular. Two overlapping squares, one rotated 45°.
 * Used in the header wordmark and as the active-tab marker; keep its
 * placements few so the motif stays quiet.
 */
export function StarMark({ size = 16, className = '' }: { size?: number; className?: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      className={className}
      aria-hidden="true"
    >
      <rect x="5" y="5" width="14" height="14" stroke="currentColor" strokeWidth="1.6" />
      <rect
        x="5"
        y="5"
        width="14"
        height="14"
        stroke="currentColor"
        strokeWidth="1.6"
        transform="rotate(45 12 12)"
      />
      <circle cx="12" cy="12" r="2.2" fill="currentColor" />
    </svg>
  );
}
