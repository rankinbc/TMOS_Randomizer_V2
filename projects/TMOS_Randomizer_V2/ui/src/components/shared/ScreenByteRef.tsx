import { formatHex } from '../../utils/formatters';
import { useJumpToWorldScreen } from './jumpLinks';

// Matches the render URL pattern used by ScreenRenderer.tsx
const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Screen aspect ratio: 512×384 (8 tiles × 6 tiles at 64px)
const BASE_WIDTH = 512;
const BASE_HEIGHT = 384;

/**
 * Clickable chip that shows a screen hex reference and an optional thumbnail.
 * Clicking navigates to the World tab and selects the given screen.
 *
 * Thumbnail uses the same `${API_BASE}/api/rom/render/{chapter}/{index}?scale=1`
 * URL pattern as ScreenRenderer.tsx.
 */
export function ScreenByteRef({
  chapter,
  screenIndex,
  showRender = true,
  label,
}: {
  chapter: number;
  screenIndex: number;
  /** Show a ~64px mini thumbnail from the API render endpoint. Default: true. */
  showRender?: boolean;
  /** Button label. Default: "0xNN → World" */
  label?: string;
}) {
  const jumpToWorldScreen = useJumpToWorldScreen();
  const hexLabel = label ?? `${formatHex(screenIndex)} → World`;

  // Thumbnail dimensions (4:3 aspect from BASE_WIDTH/BASE_HEIGHT)
  const thumbW = 64;
  const thumbH = Math.round(thumbW * (BASE_HEIGHT / BASE_WIDTH));

  // API render URL — same pattern as ScreenRenderer.tsx's getScreenRenderUrl
  const renderUrl = `${API_BASE}/api/rom/render/${chapter}/${screenIndex}?scale=1`;

  return (
    <button
      type="button"
      onClick={() => { void jumpToWorldScreen(chapter, screenIndex); }}
      className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-slate-700 hover:bg-slate-600 text-white text-xs font-mono transition-colors"
      title={`Jump to Ch${chapter} screen ${formatHex(screenIndex)}`}
    >
      {showRender && (
        <img
          src={renderUrl}
          alt={`Screen ${formatHex(screenIndex)}`}
          draggable={false}
          style={{
            width: thumbW,
            height: thumbH,
            imageRendering: 'pixelated',
            flexShrink: 0,
            objectFit: 'cover',
          }}
        />
      )}
      <span>{hexLabel}</span>
    </button>
  );
}
