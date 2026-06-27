// Shared screen-render URL builder + base dimensions.
// Used by both ScreenRenderer.tsx (full thumbnail with cache-busting) and
// ScreenByteRef.tsx (mini link chip). Lives in a plain-TS file so it is not
// subject to the react-refresh/only-export-components ESLint rule.

// API base URL
export const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Base screen dimensions (8 tiles × 6 tiles, each tile is a 64px metatile).
// Full rendered size at scale=1 is 512×384.
export const BASE_WIDTH = 512; // 8 tiles * 64px
export const BASE_HEIGHT = 384; // 6 tiles * 64px

// Get the rendered screen image URL.
// Optional tile/datapointer/color params are appended as cache-busting query
// params so the image refreshes when in-memory screen data changes.
export function getScreenRenderUrl(
  chapterNum: number,
  screenIndex: number,
  scale: number = 1,
  topTiles?: number,
  bottomTiles?: number,
  datapointer?: number,
  wsColor?: number
): string {
  let url = `${API_BASE}/api/rom/render/${chapterNum}/${screenIndex}?scale=${scale}`;
  if (topTiles !== undefined) url += `&t=${topTiles}`;
  if (bottomTiles !== undefined) url += `&b=${bottomTiles}`;
  if (datapointer !== undefined) url += `&d=${datapointer}`;
  if (wsColor !== undefined) url += `&ws_color=${wsColor}`;
  return url;
}
