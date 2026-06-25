// Pure collision-filter logic for the tile-section picker.
//
// A "section signature" is a 32-char walkability bitstring ('1'=walkable,
// '0'=blocking) in row-major order over a section's 4 rows x 8 cols. The backend
// endpoint /api/rom/tilesection-walkability returns one per global section index.
//
// Screen layout: rows 0-3 come from the top section; rows 4-5 come from the
// bottom section's rows 0-1.

export type Half = 'top' | 'bottom';
export type WalkabilityTable = Record<string, string>;

export interface SectionPair {
  top: string;
  bottom: string;
}

export interface NeighborSigs {
  up: SectionPair | null;
  down: SectionPair | null;
  left: SectionPair | null;
  right: SectionPair | null;
}

export interface RankedSection {
  globalIndex: number;
  mismatch: number;
}

export interface SuggestedPair {
  top: number;
  bottom: number;
  mismatch: number;
}

const COLS = 8;

/** 8-char row r (0..3) of a 32-char section signature. */
export function rowSig(sig: string, r: number): string {
  return sig.slice(r * COLS, r * COLS + COLS);
}

/** Column c (0 or 7) over the given rows, as a bitstring. */
export function colSig(sig: string, c: number, rows: number[]): string {
  return rows.map((r) => sig[r * COLS + c] ?? '0').join('');
}

/** Per-position walkability mismatches between two bitstrings (walkable-vs-blocking). */
export function mismatchCount(a: string, b: string): number {
  const n = Math.min(a.length, b.length);
  let m = 0;
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) m++;
  return m;
}

/** Resolve a neighbor's section pair from the table; null if either is missing. */
export function sectionPair(
  table: WalkabilityTable,
  topGlobal: number,
  bottomGlobal: number,
): SectionPair | null {
  const top = table[String(topGlobal)];
  const bottom = table[String(bottomGlobal)];
  if (top == null || bottom == null) return null;
  return { top, bottom };
}

/** Mismatch score of a candidate section used as `half`, vs the relevant neighbors. */
export function scoreCandidate(
  candidate: string,
  half: Half,
  neighbors: NeighborSigs,
): number {
  let score = 0;
  if (half === 'top') {
    // Candidate owns screen rows 0-3.
    if (neighbors.up) {
      // up neighbor's bottom edge = its bottom section row 1 (screen row 5).
      score += mismatchCount(rowSig(candidate, 0), rowSig(neighbors.up.bottom, 1));
    }
    if (neighbors.left) {
      // left neighbor's right edge, upper rows 0-3 (from its top section).
      score += mismatchCount(colSig(candidate, 0, [0, 1, 2, 3]), colSig(neighbors.left.top, 7, [0, 1, 2, 3]));
    }
    if (neighbors.right) {
      score += mismatchCount(colSig(candidate, 7, [0, 1, 2, 3]), colSig(neighbors.right.top, 0, [0, 1, 2, 3]));
    }
  } else {
    // Candidate owns screen rows 4-5 (= its section rows 0-1).
    if (neighbors.down) {
      // down neighbor's top edge = its top section row 0 (screen row 0).
      score += mismatchCount(rowSig(candidate, 1), rowSig(neighbors.down.top, 0));
    }
    if (neighbors.left) {
      // left neighbor's right edge, lower rows 4-5 (from its bottom section rows 0-1).
      score += mismatchCount(colSig(candidate, 0, [0, 1]), colSig(neighbors.left.bottom, 7, [0, 1]));
    }
    if (neighbors.right) {
      score += mismatchCount(colSig(candidate, 7, [0, 1]), colSig(neighbors.right.bottom, 0, [0, 1]));
    }
  }
  return score;
}

/** Rank all sections 0..count-1 for the active half (ascending mismatch, missing last). */
export function rankSections(
  table: WalkabilityTable,
  half: Half,
  neighbors: NeighborSigs,
  count: number,
): RankedSection[] {
  const out: RankedSection[] = [];
  for (let g = 0; g < count; g++) {
    const sig = table[String(g)];
    out.push({
      globalIndex: g,
      mismatch: sig == null ? Infinity : scoreCandidate(sig, half, neighbors),
    });
  }
  out.sort((a, b) => a.mismatch - b.mismatch || a.globalIndex - b.globalIndex);
  return out;
}

/** Internal mid-screen seam mismatch: top section row 3 vs bottom section row 0. */
export function internalSeam(topSig: string, bottomSig: string): number {
  return mismatchCount(rowSig(topSig, 3), rowSig(bottomSig, 0));
}

/** Total mismatch of a top+bottom pair: both halves vs neighbors + the internal seam. */
export function scorePair(
  topSig: string,
  bottomSig: string,
  neighbors: NeighborSigs,
): number {
  return (
    scoreCandidate(topSig, 'top', neighbors) +
    scoreCandidate(bottomSig, 'bottom', neighbors) +
    internalSeam(topSig, bottomSig)
  );
}

/**
 * Suggest the best top+bottom pairs. Bounds work by taking the K best tops and K
 * best bottoms by their own half score, then scoring the K×K combinations.
 */
export function suggestPairs(
  table: WalkabilityTable,
  neighbors: NeighborSigs,
  count: number,
  k = 40,
  limit = 12,
): SuggestedPair[] {
  const tops = rankSections(table, 'top', neighbors, count).slice(0, k);
  const bottoms = rankSections(table, 'bottom', neighbors, count).slice(0, k);
  const pairs: SuggestedPair[] = [];
  for (const t of tops) {
    const tSig = table[String(t.globalIndex)];
    if (tSig == null) continue;
    for (const b of bottoms) {
      const bSig = table[String(b.globalIndex)];
      if (bSig == null) continue;
      pairs.push({
        top: t.globalIndex,
        bottom: b.globalIndex,
        mismatch: scorePair(tSig, bSig, neighbors),
      });
    }
  }
  pairs.sort((a, b) => a.mismatch - b.mismatch || a.top - b.top || a.bottom - b.bottom);
  return pairs.slice(0, limit);
}
