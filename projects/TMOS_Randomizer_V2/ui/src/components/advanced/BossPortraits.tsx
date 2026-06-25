import { api } from '../../api/client';

// Boss portraits from extracted-data/images/DemonImages, served via
// /api/assets/bosses/<file>. Multiple entries = phase / form variants.
const BOSS_IMAGES: Record<string, string[]> = {
  gilga: ['gilga-1.gif', 'gilga-2.gif', 'gilga-3.gif'],
  curly: ['curly-1.gif', 'curly-2.gif'],
  troll: ['troll1.gif', 'troll2.gif'],
  salamander: ['salamander.gif'],
  goragora: ['goragora.gif', 'gora2.gif'],
};

/** Boss form/phase portraits, shared by the Bosses and Boss Bytes sub-tabs. */
export function BossPortraits({ bossId }: { bossId: string }) {
  const files = BOSS_IMAGES[bossId];
  if (!files?.length) return null;
  return (
    <div className="flex items-center gap-1.5">
      {files.map((f) => (
        <img
          key={f}
          src={api.getBossImageUrl(f)}
          alt={`${bossId} ${f}`}
          className="h-10 w-10 object-contain rounded bg-slate-900/70 border border-slate-700"
          style={{ imageRendering: 'pixelated' }}
          onError={(e) => {
            (e.currentTarget as HTMLImageElement).style.display = 'none';
          }}
        />
      ))}
    </div>
  );
}
