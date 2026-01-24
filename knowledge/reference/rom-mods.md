# ROM Modifications Reference

Documentation for available ROM patches and modifications.

---

## Available Mods

### Salamander - Fast Fire Field

**File:** `/rom-files/mods/salamander/TMOS_Sal_FastFireField.nes`

**Purpose:** Speeds up fire field and rain animations during Salamander boss fight.

**Changes (6 bytes):**

| ROM Offset | Original | Modified | Effect |
|------------|----------|----------|--------|
| `0x18150` | `0x10` | `0x02` | Rain timer #1: 16→2 frames |
| `0x18223` | `0x10` | `0x02` | Rain timer #2: 16→2 frames |
| `0x182E5` | `0x10` | `0x02` | Rain timer #3: 16→2 frames |
| `0x18418` | `0x10` | `0x02` | Rain timer #4: 16→2 frames |
| `0x18A2E` | `0x70` | `0xE0` | Fire field loop: 127→15 iterations |
| `0x18A46` | `0x70` | `0xE0` | Fire field loop: 127→15 iterations |

**Time Savings:** ~2.8 seconds per fire field cycle

**Safety:** Only affects Salamander boss fight. No impact on other gameplay.

**Details:** See [bosses/salamander.md](../bosses/salamander.md#rom-mod-fast-fire-field)

---

## Applying Mods

### Manual Hex Edit

1. Open ROM in hex editor (HxD, XVI32, etc.)
2. Navigate to offset
3. Change byte value
4. Save

### Python Script

```python
with open('TMOS_ORIGINAL.nes', 'rb') as f:
    data = bytearray(f.read())

# Apply changes
data[0x18150] = 0x02  # Example

with open('TMOS_MODDED.nes', 'wb') as f:
    f.write(data)
```

---

## Mod Development Notes

### Bank 12 Layout
- **File Offset:** `0x18000 - 0x19FFF`
- **CPU Address:** `$8000 - $9FFF`
- **Size:** 8KB

### Offset Calculation
```
ROM_offset = 0x18000 + (CPU_address - 0x8000)
```

### Testing Checklist
- [ ] Verify original bytes match expected values
- [ ] Test affected gameplay section
- [ ] Confirm no side effects on other areas
- [ ] Document all changes with confidence levels
