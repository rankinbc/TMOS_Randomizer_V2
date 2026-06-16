export type SafetyTier = 'safe' | 'caution' | 'danger';

export interface EnumOption {
  value: number;
  label: string;
}

export interface FieldMetadata {
  label: string;
  byte: number;
  tier: SafetyTier;
  description: string;
  control?: 'enum' | 'number';
  enum?: EnumOption[];
  valid_range?: [number, number];
  warning?: string;
  used_by?: string[];
}

export interface EntityMetadata {
  label: string;
  fields: Record<string, FieldMetadata>;
}

export interface FieldMetadataResponse {
  version: string;
  generated_from: string;
  entities: Record<string, EntityMetadata>;
}
