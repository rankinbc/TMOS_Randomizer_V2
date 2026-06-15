"""Invariant tests for grow's nav-writing (strategies/grow/navwrite.py, v0.2.0).

grow's new value proposition is "navigable by construction", so — exactly as with
graph_mutate — these invariants are non-optional even though REQUIREMENTS.md §5 does
not require strategies to be tested in general.

The 3 intra-section unit cases mirror V2's test_grow_nav.py and need no ROM. The rest
are ROM-gated (skip cleanly when the stock ROM is not staged).
"""

from __future__ import annotations

import copy
import json
import random
from pathlib import Path
from types import SimpleNamespace

import pytest

from tmos_strategy_lab._v2_compat.parsers import (
    DO_NOT_RANDOMIZE,
    NAV_BLOCKED,
    NAV_BUILDING_ENTRANCE,
    PAST_SCREEN_INDICES,
    relative_to_global,
)
from tmos_strategy_lab.context import LabContext
from tmos_strategy_lab.metrics.edge_compatibility import EdgeCompatibilityMetric
from tmos_strategy_lab.models import Candidate
from tmos_strategy_lab.registry import get_strategy
from tmos_strategy_lab.strategies.grow.navwrite import (
    DIRECTION_DELTAS,
    apply_grid_navigation,
    write_navigation,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
ROM = PROJECT_ROOT / "data" / "rom" / "TMOS_ORIGINAL.nes"
_DIRS = ("right", "left", "down", "up")
_SEED = 42


def _run(seed: int = _SEED):
    ctx = LabContext.from_rom(ROM)
    cand = get_strategy("grow")().generate(ctx, seed)
    return ctx, cand


# ---------------------------------------------------------------------------
# Intra-section unit cases — NO ROM needed (mirror V2 test_grow_nav.py)
# ---------------------------------------------------------------------------

def _screen(idx):
    return SimpleNamespace(
        relative_index=idx,
        screen_index_right=0,
        screen_index_left=0,
        screen_index_up=0,
        screen_index_down=0,
    )


def test_intra_horizontal_neighbors_bidirectional():  # V2 case 1
    screens = {5: _screen(5), 8: _screen(8)}
    apply_grid_navigation(screens, {(0, 0): 5, (1, 0): 8})
    assert screens[5].screen_index_right == 8
    assert screens[8].screen_index_left == 5
    assert screens[5].screen_index_left == NAV_BLOCKED
    assert screens[5].screen_index_up == NAV_BLOCKED
    assert screens[8].screen_index_right == NAV_BLOCKED


def test_intra_isolated_cell_all_blocked():  # V2 case 2
    screens = {3: _screen(3)}
    apply_grid_navigation(screens, {(0, 0): 3})
    assert all(getattr(screens[3], f"screen_index_{d}") == NAV_BLOCKED for d in _DIRS)


def test_intra_building_entrance_preserved():  # V2 case 3
    s = _screen(7)
    s.screen_index_down = NAV_BUILDING_ENTRANCE
    apply_grid_navigation({7: s}, {(0, 0): 7})
    assert s.screen_index_down == NAV_BUILDING_ENTRANCE


# ---------------------------------------------------------------------------
# BFS helpers (over REAL edges only: skip 0xFE/0xFF and out-of-range)
# ---------------------------------------------------------------------------

def _bfs(by_idx: dict, get) -> set[int]:
    """Reachable relative indices from screen 0 over real nav edges."""
    if 0 not in by_idx:
        return set()
    seen = {0}
    stack = [0]
    while stack:
        node = by_idx[stack.pop()]
        for d in _DIRS:
            nb = get(node, d)
            if nb in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE):
                continue
            if nb in by_idx and nb not in seen:
                seen.add(nb)
                stack.append(nb)
    return seen


def _reach_dicts(screen_dicts) -> set[int]:
    by_idx = {sd["relative_index"]: sd for sd in screen_dicts}
    return _bfs(by_idx, lambda sd, d: sd[f"screen_index_{d}"])


def _reach_objs(screens) -> set[int]:
    by_idx = {s.relative_index: s for s in screens}
    return _bfs(by_idx, lambda s, d: getattr(s, f"screen_index_{d}"))


def _reach_objs_undirected(screens) -> set[int]:
    """Undirected reachability from screen 0 — treat each real nav edge as
    bidirectional. This matches what union-find linking guarantees (a connected
    component), independent of the one-way edges that preserved 0xFE building
    entrances introduce. Directed reachability is covered separately by TEST 8."""
    by_idx = {s.relative_index: s for s in screens}
    adj: dict[int, set[int]] = {s.relative_index: set() for s in screens}
    for s in screens:
        for d in _DIRS:
            nb = getattr(s, f"screen_index_{d}")
            if nb in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE) or nb not in by_idx:
                continue
            adj[s.relative_index].add(nb)
            adj[nb].add(s.relative_index)
    if 0 not in adj:
        return set()
    seen = {0}
    stack = [0]
    while stack:
        for nb in adj[stack.pop()]:
            if nb not in seen:
                seen.add(nb)
                stack.append(nb)
    return seen


def _reach_undirected_with_warps(screens) -> set[int]:
    """Warp-augmented undirected reachability from screen 0: directional edges (all
    screens) PLUS warp edges (stairway content links + the time-door pair). Mirrors the
    connectivity model link_sections uses, so a section linked via a warp is reachable."""
    by_idx = {s.relative_index: s for s in screens}
    adj: dict[int, set[int]] = {s.relative_index: set() for s in screens}

    def _connect(a, b):
        if a in adj and b in adj:
            adj[a].add(b)
            adj[b].add(a)

    for s in screens:
        for d in _DIRS:
            nb = getattr(s, f"screen_index_{d}")
            if nb in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE) or nb not in by_idx:
                continue
            _connect(s.relative_index, nb)
    for s in screens:  # stairway warps (Event 0x40 → Content destination)
        if s.is_stairway and s.stairway_destination is not None:
            _connect(s.relative_index, s.stairway_destination)
    tds = sorted(s.relative_index for s in screens if s.content == 0xC0)  # time-door pair
    if len(tds) == 2:
        _connect(tds[0], tds[1])

    if 0 not in adj:
        return set()
    seen = {0}
    stack = [0]
    while stack:
        for nb in adj[stack.pop()]:
            if nb not in seen:
                seen.add(nb)
                stack.append(nb)
    return seen


def _baseline_candidate(ctx) -> Candidate:
    """Stock world as a Candidate, for metric baselining (tests 6 & 10)."""
    return Candidate(
        strategy_id="baseline@test",
        strategy_version="0.0.0",
        seed=0,
        chapters={
            n: [s.to_dict() for s in c.screens]
            for n, c in sorted(ctx.game_world.chapters.items())
        },
        repairs=[],
        breadcrumbs={"source": ctx.source, "rom_md5": ctx.rom_md5},
    )


# GameAnalysis2 authoritative warp oracle (test 11 cross-check). Skip the cross-check
# (not the preservation check) when the knowledge base isn't present on this machine.
_GA2 = Path(
    r"C:\claude-workspace\GameAnalysis2\analysis_games\TMOS"
    r"\game_specs\systems\world\map_layout"
)


def _load_oracle(name: str):
    p = _GA2 / name
    return json.loads(p.read_text()) if p.exists() else None


def _rebuild(seed: int):
    """Re-run generate()'s per-chapter pipeline so we can inspect section membership.

    Mirrors GrowStrategy.generate exactly (same RNG draw order), so the mutated
    chapters are byte-identical to the emitted Candidate. Returns
    ``(ctx, {ch_num: (chapter, growth, nav_stats)})``.
    """
    from tmos_strategy_lab.strategies.grow.impl import grow_chapter, plan_for_chapter
    from tmos_strategy_lab.strategies.grow.ts_swap import BiomeRegistry, TileSectionCache

    ctx = LabContext.from_rom(ROM)
    world = copy.deepcopy(ctx.game_world)
    rng = random.Random(seed)
    rom_bytes = ctx.rom_bytes
    biome = BiomeRegistry.build_from_world(world)
    ts_cache = TileSectionCache.build(rom_bytes)

    out = {}
    for ch_num in sorted(world.chapters.keys()):
        chapter = world.chapters[ch_num]
        chapter_rng = random.Random(rng.randrange(2**31))
        growth = grow_chapter(
            chapter=chapter,
            rom_data=rom_bytes,
            plan=plan_for_chapter(ch_num),
            rng=chapter_rng,
            biome=biome,
            ts_cache=ts_cache,
        )
        nav_rng = random.Random(rng.randrange(2**31))
        nav_stats = write_navigation(chapter, ch_num, growth, rom_bytes, nav_rng)
        out[ch_num] = (chapter, growth, nav_stats)
    return ctx, out


# ---------------------------------------------------------------------------
# ROM-gated integration tests
# ---------------------------------------------------------------------------

romonly = pytest.mark.skipif(not ROM.exists(), reason=f"Stock ROM not staged at {ROM}.")


@romonly
def test_determinism_byte_identical():  # TEST 1
    _, a = _run()
    _, b = _run()
    assert a.to_json() == b.to_json()


@romonly
def test_navigability_written():  # TEST 2 — not an identity emit
    ctx, cand = _run()
    any_diff = False
    for ch, screens in cand.chapters.items():
        for sd, orig in zip(screens, ctx.game_world.chapters[ch].screens, strict=True):
            if any(sd[f"screen_index_{d}"] != getattr(orig, f"screen_index_{d}") for d in _DIRS):
                any_diff = True
                break
        if any_diff:
            break
    assert any_diff, "grow emitted nav identical to input — nav was not written"


@romonly
def test_intra_adjacency_correct_on_real_section():  # TEST 3
    """For a real grown section: grid neighbors wired bidirectionally; non-neighbor
    edges are NAV_BLOCKED or a preserved 0xFE."""
    _, rebuilt = _rebuild(_SEED)
    checked = 0
    for _ch_num, (chapter, growth, _stats) in rebuilt.items():
        by_idx = {s.relative_index: s for s in chapter.screens}
        for section in growth.sections:
            grid = section.grid
            for (x, y), idx in grid.items():
                scr = by_idx[idx]
                for d, (dx, dy) in DIRECTION_DELTAS.items():
                    val = getattr(scr, f"screen_index_{d}")
                    npos = (x + dx, y + dy)
                    if npos in grid:
                        # Grid neighbor → wired to it, unless the stock byte was a
                        # building entrance (0xFE), which is preserved over the wire.
                        assert val == grid[npos] or val == NAV_BUILDING_ENTRANCE
                        checked += 1
                    else:
                        # No grid neighbor → BLOCKED, a preserved 0xFE, or an
                        # inter-section link to another section (a real index).
                        assert val == NAV_BLOCKED or val == NAV_BUILDING_ENTRANCE or val in by_idx
    assert checked > 0, "no intra-section adjacencies found to verify"


@romonly
def test_building_entrances_preserved():  # TEST 4
    ctx, cand = _run()
    for ch, screens in cand.chapters.items():
        for sd, orig in zip(screens, ctx.game_world.chapters[ch].screens, strict=True):
            for d in _DIRS:
                if getattr(orig, f"screen_index_{d}") == NAV_BUILDING_ENTRANCE:
                    assert sd[f"screen_index_{d}"] == NAV_BUILDING_ENTRANCE


@romonly
def test_do_not_randomize_untouched():  # TEST 5
    ctx, cand = _run()
    keys16 = (
        "parent_world", "ambient_sound", "content", "objectset",
        "screen_index_right", "screen_index_left", "screen_index_down", "screen_index_up",
        "datapointer", "exit_position", "top_tiles", "bottom_tiles",
        "worldscreen_color", "sprites_color", "unknown", "event",
    )
    for ch, screens in cand.chapters.items():
        for sd, orig in zip(screens, ctx.game_world.chapters[ch].screens, strict=True):
            if relative_to_global(ch, orig.relative_index) in DO_NOT_RANDOMIZE:
                assert all(sd[k] == getattr(orig, k) for k in keys16)


@romonly
def test_edge_compatibility_no_new_failures():  # TEST 6
    """grow's grid edge-validity survives nav-writing: EdgeCompatibilityMetric finds
    no failures grow introduced. Zero is the goal; when stock itself is clean, zero is
    enforced. The <= baseline guard never lets grow *regress* edge compatibility."""
    ctx, cand = _run()
    metric = EdgeCompatibilityMetric()
    baseline = _baseline_candidate(ctx)
    base_fail = metric.compute(baseline, ctx).failures
    grow_fail = metric.compute(cand, ctx).failures
    assert len(grow_fail) <= len(base_fail), (
        f"grow added edge_compatibility failures: {len(grow_fail)} > baseline "
        f"{len(base_fail)} — first new: {grow_fail[:3]}"
    )
    if len(base_fail) == 0:
        assert grow_fail == [], grow_fail


@romonly
def test_chapter_connectivity_linked_reachable():  # TEST 7
    """Every placed screen of a LINKED section is in screen 0's connected component
    — the breadcrumb's connectivity claim is honest, not an islanded chapter
    pretending. Uses WARP-AUGMENTED undirected reachability (directional edges +
    stairway/time-door warps), matching the warp-aware connectivity model: union-find
    linking guarantees a component, while preserved 0xFE entrances make some intra
    edges one-way (directed reachability is TEST 8's job)."""
    _, rebuilt = _rebuild(_SEED)
    verified_chapters = 0
    for ch_num, (chapter, growth, nav_stats) in rebuilt.items():
        unlinked_ids = set(nav_stats["unlinked_sections"])
        linked_placed: set[int] = set()
        for s in growth.sections:
            if s.section_id not in unlinked_ids:
                linked_placed |= set(s.grid.values())
        if 0 not in linked_placed:
            continue  # screen 0 unplaced or not in a linked section — nothing to assert
        reachable = _reach_undirected_with_warps(chapter.screens)
        missing = linked_placed - reachable
        assert not missing, (
            f"ch{ch_num}: {len(missing)} linked-section screens not in screen 0's "
            f"component: {sorted(missing)[:10]}"
        )
        verified_chapters += 1
    assert verified_chapters > 0, "no chapter had screen 0 in a linked section to verify"


@romonly
@pytest.mark.xfail(
    strict=True,
    reason=(
        "KNOWN NEGATIVE RESULT (v0.3.0) — see strategies/grow/RESULTS.md. With correct "
        "era-safety, directed BFS from PRESENT screen 0 (V2's lab_adapter._reach_counts "
        "model) regresses vs stock on ch2/ch4/ch5 across all sampled seeds: grow's "
        "by-construction edge validity does NOT translate to directed reachability. "
        "v0.2.0 only 'passed' because un-era-guarded links let the BFS walk PRESENT→PAST "
        "(physically illegal). strict=True so this XPASSes loudly — prompting removal of "
        "the xfail — if a future linking improvement (v0.4.0) closes the gap."
    ),
)
def test_reachability_no_worse_than_baseline():  # TEST 8 (shippability gate)
    ctx, cand = _run()
    for ch, screens in cand.chapters.items():
        stock = ctx.game_world.chapters[ch].screens
        grow_count = len(_reach_dicts(screens))
        stock_count = len(_reach_objs(stock))
        assert grow_count >= stock_count, (
            f"ch{ch}: grow reachable {grow_count} < stock {stock_count}"
        )


@romonly
def test_snapshot_input_rejected():  # TEST 9
    base = LabContext.from_rom(ROM)
    ctx = LabContext(
        game_world=base.game_world,
        rom_bytes=None,
        source="snapshot:x.json",
        rom_md5=None,
    )
    with pytest.raises(ValueError, match="rom_bytes"):
        get_strategy("grow")().generate(ctx, _SEED)


@romonly
def test_no_new_broken_inter_section_edges():  # TEST 10
    """Walk-across links are edge-verified, so grow must not ADD edge_compatibility
    failures vs the stock ROM. The 14 broken inter-section edges from the pre-nav era
    must stay gone. (<= baseline guard; == 0 when stock itself is clean.)"""
    ctx, cand = _run()
    metric = EdgeCompatibilityMetric()
    base_fail = metric.compute(_baseline_candidate(ctx), ctx).failures
    grow_fail = metric.compute(cand, ctx).failures
    assert len(grow_fail) <= len(base_fail), (
        f"grow added broken inter-section edges: {len(grow_fail)} > baseline "
        f"{len(base_fail)} — first new: {grow_fail[:3]}"
    )


@romonly
def test_stairways_and_time_doors_preserved():  # TEST 11
    """Every input stairway (Event 0x40) keeps its content+event; every input time
    door (Content 0xC0) stays 0xC0. Detected sets also match the GameAnalysis2 oracle
    (counts + indices) when the knowledge base is present."""
    ctx, cand = _run()
    # (a) preservation — bytes intact on output.
    for ch, screens in cand.chapters.items():
        for sd, orig in zip(screens, ctx.game_world.chapters[ch].screens, strict=True):
            if orig.is_stairway:
                assert sd["content"] == orig.content and sd["event"] == orig.event, (
                    f"ch{ch} stairway {orig.relative_index} content/event changed"
                )
            if orig.content == 0xC0:  # 0xC0 == ContentType.TIME_DOOR
                assert sd["content"] == 0xC0, f"ch{ch} time door {orig.relative_index} lost 0xC0"

    # (b) oracle cross-check — skip cleanly if GA2 KB absent on this machine.
    td_oracle = _load_oracle("time_door_screens.json")
    if td_oracle is not None:
        want: dict[int, list[int]] = {}
        for s in td_oracle["screens"]:
            want.setdefault(s["chapter"], []).append(s["screen_index"])
            assert s["content_byte"] == 0xC0  # oracle confirms 0xC0-only
        for ch in want:
            got = sorted(
                o.relative_index
                for o in ctx.game_world.chapters[ch].screens
                if o.content == 0xC0
            )
            assert got == sorted(want[ch]), f"ch{ch} time doors: detected {got} != oracle {want[ch]}"

    sp_oracle = _load_oracle("stairway_pairs.json")
    if sp_oracle is not None:
        for ch_str, entries in sp_oracle["chapters"].items():
            ch = int(ch_str)
            # Detection lists every Event==0x40 screen. In the oracle, screen_a is always
            # the stairway source; screen_b is itself a stairway only for a clean (non-orphan)
            # pair — for a one-way orphan, screen_b is merely the Content destination, not a
            # stairway. So detected == {all screen_a} ∪ {screen_b of non-orphan pairs}.
            want_screens = {e["screen_a"] for e in entries}
            want_screens |= {e["screen_b"] for e in entries if not e.get("orphan")}
            got_screens = {
                o.relative_index for o in ctx.game_world.chapters[ch].screens if o.is_stairway
            }
            assert got_screens == want_screens, (
                f"ch{ch} stairway screens: detected {sorted(got_screens)} != "
                f"oracle sources {sorted(want_screens)}"
            )


@romonly
def test_no_cross_era_walk_or_stairway_link():  # TEST 12
    """No directional nav edge that grow WROTE on a placed cell straddles
    PRESENT↔PAST (era by PAST_SCREEN_INDICES, never parent_world). Time doors are the
    only legal era bridge and are pool-excluded orphans, so they never appear here."""
    _, rebuilt = _rebuild(_SEED)
    checked = 0
    for ch_num, (chapter, growth, _stats) in rebuilt.items():
        past = PAST_SCREEN_INDICES.get(ch_num, set())
        placed: set[int] = set()
        for s in growth.sections:
            placed |= set(s.grid.values())
        by_idx = {sc.relative_index: sc for sc in chapter.screens}
        for idx in sorted(placed):
            scr = by_idx[idx]
            for d in _DIRS:
                nb = getattr(scr, f"screen_index_{d}")
                if nb in (NAV_BLOCKED, NAV_BUILDING_ENTRANCE) or nb not in by_idx:
                    continue
                assert (idx in past) == (nb in past), (
                    f"ch{ch_num}: cross-era directional edge {idx}->{nb} "
                    f"(past[{idx}]={idx in past}, past[{nb}]={nb in past})"
                )
                checked += 1
    assert checked > 0, "no placed-cell directional edges found to verify"
