import { api } from '../../api/client';
import type { WeaponDamageEntry } from '../../api/client';
import { ByteField } from './ByteField';
import { PanelFrame, useRomResource } from './panelHelpers';
import { HelpChip } from '../stats/HelpChip';

type EditableField = 'weapon_class' | 'damage_base';

function vanillaFieldValue(
  vanilla: WeaponDamageEntry[] | undefined,
  attackId: number,
  field: EditableField
): number | undefined {
  return vanilla?.find((e) => e.attack_id === attackId)?.[field];
}

export function WeaponDamagePanel() {
  const { data, setData, loading, error, reload } = useRomResource(() => api.getWeaponDamage());

  const commit = async (attackId: number, field: EditableField, next: number) => {
    if (!data) return;
    const prev = data;
    // optimistic
    setData({
      ...data,
      table: data.table.map((e) =>
        e.attack_id === attackId ? { ...e, [field]: next } : e
      ),
    });
    try {
      const res = await api.patchWeaponDamage(attackId, { [field]: next });
      setData((d) =>
        d
          ? { ...d, table: d.table.map((e) => (e.attack_id === attackId ? res.entry : e)) }
          : d
      );
    } catch (e) {
      setData(prev); // rollback
      throw e;
    }
  };

  return (
    <PanelFrame
      title="Weapon Damage"
      tier="expert"
      romNote="Per-attack weapon class & base damage · packed bytes (class = bits 7-6, damage = bits 5-0)"
      help={
        <div className="text-xs space-y-1">
          <p>
            Each attack object carries a single packed byte: the high 2 bits are its{' '}
            <em>weapon class</em> and the low 6 bits are its <em>base damage</em>.
          </p>
          <p>
            A hit only lands when the attacker's class is at least the target's armor class; HP lost
            per hit is base damage + 1.
          </p>
          <p className="text-amber-300/90">
            Only ids 7–19 store dedicated data and are safe to edit. The other rows overlap
            executable code and are read-only.
          </p>
        </div>
      }
      loading={loading}
      error={error}
      hasData={!!data}
      onReload={reload}
    >
      {data && (
        <div className="rounded-lg border border-slate-700 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-slate-800/60 text-slate-300 text-xs uppercase tracking-wide">
                <th className="px-4 py-2 text-left font-semibold">ID</th>
                <th className="px-4 py-2 text-left font-semibold">
                  <span className="inline-flex items-center gap-1">
                    Weapon class
                    <HelpChip content="Attack class (bits 7-6); a hit lands only if class ≥ the target's armor class." />
                  </span>
                </th>
                <th className="px-4 py-2 text-left font-semibold">
                  <span className="inline-flex items-center gap-1">
                    Damage base
                    <HelpChip content="Base damage (bits 5-0); HP loss per hit = damage_base + 1." />
                  </span>
                </th>
                <th className="px-4 py-2 text-left font-semibold">Applied</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {data.table.map((entry) => {
                const ro = !entry.is_dedicated_data;
                return (
                  <tr key={entry.attack_id} className={ro ? 'opacity-70' : undefined}>
                    <td className="px-4 py-2 font-mono text-slate-400">
                      <span className="inline-flex items-center gap-1.5">
                        {entry.attack_id_hex}
                        {ro && (
                          <HelpChip
                            icon="⚠"
                            tone="warn"
                            content="Overlaps executable code — read-only (editing would corrupt the ROM)."
                          />
                        )}
                      </span>
                    </td>
                    <td className="px-4 py-2">
                      <ByteField
                        value={entry.weapon_class}
                        vanilla={vanillaFieldValue(data.vanilla, entry.attack_id, 'weapon_class')}
                        min={0}
                        max={3}
                        disabled={ro}
                        onCommit={(next) => commit(entry.attack_id, 'weapon_class', next)}
                        ariaLabel={`Attack ${entry.attack_id_hex} weapon class`}
                      />
                    </td>
                    <td className="px-4 py-2">
                      <ByteField
                        value={entry.damage_base}
                        vanilla={vanillaFieldValue(data.vanilla, entry.attack_id, 'damage_base')}
                        min={0}
                        max={63}
                        disabled={ro}
                        onCommit={(next) => commit(entry.attack_id, 'damage_base', next)}
                        ariaLabel={`Attack ${entry.attack_id_hex} damage base`}
                      />
                    </td>
                    <td className="px-4 py-2">
                      <span className="font-mono tabular-nums text-slate-300">
                        {(entry.raw_byte & 0x3f) + 1}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </PanelFrame>
  );
}
