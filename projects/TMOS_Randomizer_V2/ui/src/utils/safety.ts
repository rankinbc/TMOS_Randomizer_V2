import type { FieldMetadataResponse, FieldMetadata, SafetyTier } from '../types/metadata';

export interface TierStyle {
  dot: string;     // tailwind class for the status dot
  border: string;  // left-border accent
  label: string;   // human label
}

const STYLES: Record<SafetyTier, TierStyle> = {
  safe: { dot: 'bg-green-500', border: 'border-green-500', label: 'Safe' },
  caution: { dot: 'bg-amber-500', border: 'border-amber-500', label: 'Caution' },
  danger: { dot: 'bg-red-600', border: 'border-red-600', label: 'Danger' },
};

export function tierStyle(tier: SafetyTier): TierStyle {
  return STYLES[tier];
}

export function lookupField(
  meta: FieldMetadataResponse | null,
  entity: string,
  field: string,
): FieldMetadata | undefined {
  return meta?.entities[entity]?.fields[field];
}

export function isDanger(
  meta: FieldMetadataResponse | null,
  entity: string,
  field: string,
): boolean {
  return lookupField(meta, entity, field)?.tier === 'danger';
}
