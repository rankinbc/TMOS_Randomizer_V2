# Music & Sound Values

**Last Updated**: 2026-01-24
**RAM Address**: Music: `$00B0` (WorldScreen byte 0), Ambient: `$00B1`
**Source**: TAS flashdrive, FCEUX labels
**Confidence**: HIGH (TAS-verified)

---

## Music Values ($00B0 / ParentWorld)

| Value | Music/Area | Confidence |
|-------|------------|------------|
| `$10` | Town variant | MEDIUM |
| `$20` | Town | HIGH |
| `$40` | Overworld 1 | HIGH |
| `$50` | Maze | HIGH |
| `$60` | Dungeon | HIGH |
| `$80` | Raincom (rain effect) | HIGH |
| `$E0` | Overworld (Ch2) | HIGH |

---

## Ambient Sounds ($00B1)

| Value | Sound | Confidence |
|-------|-------|------------|
| `$00` | None | HIGH |
| `$08` | Water/ambient | MEDIUM |

---

## Sound Effect RAM Addresses

| Address | Effect | Confidence |
|---------|--------|------------|
| `$0158` | Enter/exit sound | MEDIUM |
| `$0159` | Take damage sound | MEDIUM |
| `$015A` | Ambient water | MEDIUM |

---

## Music System RAM ($0100-$0146)

### Synth Channels
| Address | Description | Confidence |
|---------|-------------|------------|
| `$0100` | Synth 1 pitch | MEDIUM |
| `$0106` | Droning effect | LOW |
| `$0115` | Synth 2 pitch | MEDIUM |
| `$0116` | Synth 3 pitch | LOW |
| `$011A` | Unknown | LOW |
| `$012B` | Bass pitch | MEDIUM |
| `$012C` | Synth 4 pitch | MEDIUM |
| `$0130` | Enemy present music | MEDIUM |
| `$0141` | Synth 5 pitch | MEDIUM |

### Percussion
| Address | Description | Confidence |
|---------|-------------|------------|
| `$0142` | Percussion rhythm | MEDIUM |
| `$0146` | Percussion volume | MEDIUM |

### Other
| Address | Description | Confidence |
|---------|-------------|------------|
| `$00D3` | Sound note 1 | MEDIUM |
| `$00D4` | Sound timing | MEDIUM |
| `$03E7` | Music track (changes on world section) | HIGH |

---

## Related Documents

- [memory/ram-map.md](../memory/ram-map.md) - Complete RAM map
- [structures/worldscreen.md](../structures/worldscreen.md) - ParentWorld byte

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-24 | Initial creation from TAS + FCEUX data |
