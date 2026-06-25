import type { TabType, EnemiesSection } from '../store';

export interface AppRoute {
  tab: TabType;
  sub?: EnemiesSection;
  id?: number;       // roster: enemy id (decoded from hex)
  chapter?: number;  // encounters: chapter 1–5
}

const VALID_TABS: TabType[] = [
  'world', 'enemies', 'items', 'hero', 'allies', 'graphics', 'randomize', 'expert', 'debug',
];
const ENEMIES_SUBS: EnemiesSection[] = ['roster', 'encounters', 'bosses', 'overworld'];

export function idToHex(n: number): string {
  return n.toString(16).padStart(2, '0');
}

export function hexToId(s: string): number | null {
  if (!s) return null;
  const cleaned = s.toLowerCase().replace(/^0x/, '');
  if (!/^[0-9a-f]+$/.test(cleaned)) return null;
  const n = parseInt(cleaned, 16);
  if (Number.isNaN(n) || n > 0xff) return null; // negatives impossible after the [0-9a-f] regex + 0x strip
  return n;
}

function parseChapter(s: string | undefined): number {
  const n = Number(s);
  if (!Number.isInteger(n) || n < 1 || n > 5) return 1;
  return n;
}

export function parseHash(hash: string): AppRoute {
  const raw = hash.replace(/^#/, '').replace(/^\//, '');
  const segs = raw.split('/').filter(Boolean);
  const tab = segs[0];

  if (!VALID_TABS.includes(tab as TabType)) return { tab: 'world' };
  if (tab !== 'enemies') return { tab: tab as TabType };

  const sub: EnemiesSection = ENEMIES_SUBS.includes(segs[1] as EnemiesSection)
    ? (segs[1] as EnemiesSection)
    : 'roster';
  const route: AppRoute = { tab: 'enemies', sub };

  if (sub === 'roster') {
    const id = hexToId(segs[2] ?? '');
    if (id !== null) route.id = id;
  } else if (sub === 'encounters') {
    route.chapter = parseChapter(segs[2]);
  }
  return route;
}

export function hashForRoute(route: AppRoute): string {
  if (route.tab !== 'enemies') return `#/${route.tab}`;
  const sub = route.sub ?? 'roster';
  let h = `#/enemies/${sub}`;
  if (sub === 'roster' && route.id != null) h += `/${idToHex(route.id)}`;
  if (sub === 'encounters') h += `/${route.chapter ?? 1}`;
  return h;
}
