import { formatHex } from '../../utils/formatters';
import { getScreenRenderUrl, BASE_WIDTH, BASE_HEIGHT } from '../../utils/screenRenderUrl';
import { useJumpToWorldScreen } from './jumpLinks';

/**
 * Clickable chip that shows a screen hex reference and an optional thumbnail.
 * Clicking navigates to the World tab and selects the given screen.
 *
 * The thumbnail reuses the shared `getScreenRenderUrl` builder (also used by
 * ScreenRenderer.tsx).
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

  // Shared URL builder — API scale=1 gives 512×384; CSS clips to thumb size.
  const renderUrl = getScreenRenderUrl(chapter, screenIndex, 1);

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
          onError={(e) => {
            // Render failed (e.g. backend down) — hide the broken image so the
            // chip degrades gracefully to just its hex label. Mirrors the
            // hide-on-error behavior in ScreenRenderer.tsx.
            e.currentTarget.style.display = 'none';
          }}
        />
      )}
      <span>{hexLabel}</span>
    </button>
  );
}
