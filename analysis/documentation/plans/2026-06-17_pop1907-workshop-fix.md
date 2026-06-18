# Plan — 1907 population correctness fix (workshop chain only)

**Date:** 2026-06-17
**Status:** DRAFT — awaiting (1) PI approval of this plan, (2) the reconciled `pop_1907_canton.csv`.
**Dispatch:** `analysis/documentation/handoffs/2026-06-17_blind-coder-population-1907-correctness-cmetrics.md`
**Companion plan (other pipeline):** `..._population-1907-correctness-fix-and-rerun-map.md`
**PI decisions (2026-06-17):** scope = **workshop chain only**; data = **PI provides the reconciled CSV**.

## Context / defect
Workshop density + scale controls are built on the **1900** census population. Spec calls for the
**actual 1907** population (yearbook annual estimate), with density = `pop_1907 / land_area`, where
`land_area` is the time-invariant survey constant already backed out of 1900 pop÷density.

**Correction to the dispatch's file map:** the dispatch lists Gen-1 scripts (`01/02/04/05`,
`absinthe_analysis.dta`). Those do **not** build the paper's cohort. The workshop cohort
(`cohort_1908_workshop.dta`) gets population/density independently in the `08 → 08_workshop → 09w`
chain. Gen-1 is OUT OF SCOPE per PI (workshop only).

## Measurement-vintage principle (PI-locked)
- **First-best (1907):** population, density — annual yearbook estimates exist.
- **Second-best (1900 census, nearest):** confessional (`cov3`/Protestant) + linguistic (`cov1`/French)
  shares — decennial census, no annual series; held fixed across the window.
- **Honesty requirement:** vintage stated in variable labels AND table notes; 1900 shares not presented
  as contemporaneous with the 1907 controls.

## The trap (handled)
`pop_1900` is the denominator for BOTH census shares (must stay 1900) and scale/density/per-cap
controls (move to 1907). Census shares enter the workshop cohort already-built (`french_share`,
`protestant_share` from `08`); `09w` only rescales them ×100 into `cov1`/`cov3`. We do **not** touch the
share denominators. We add a distinct `pop_1907` and rewire only density/scale/per-cap.

---

## CSV contract (the gating input — PI provides)
- **Drop path:** `analysis/processed/pop_1907_canton.csv` (matches the `canton_wine_1907_pi.csv` convention).
- **Schema:** header row, then 25 canton rows.
  - `canton_iso` — 2-letter code, **same 25-canton set as `canton_wine_1907_pi.csv`** (BE incl. JU per project rule).
  - `pop_1907` — resident population, persons (integer or float).
  - *(optional)* a `CH` row — if present I use it for the national-sum cross-check, then drop it.
- **On arrival I assert:** exactly 25 canton rows; `canton_iso` matches the cohort 1:1 (`merge … assert(match)`);
  `pop_1907 > 0 & !missing` for all 25.

---

## Edits

### A. `08_setup_cohort_1908.do` — add `pop_1907` + `pop_density_1907` (keep `canton_area_km2`)
1. **New merge** (after the pop_1900/pop_1910 block, ~§4 L434–500): import `processed/pop_1907_canton.csv`,
   `merge 1:1 canton_iso … assert(match) nogenerate`, label
   `pop_1907 "Resident population per canton (Statistical Yearbook annual estimate, 1907)"`.
2. **§8.2 (L1107–1131): KEEP** `canton_area_km2 = pop_1900 / pop_density_1900` and `ln_canton_area_km2`
   **byte-identical** (the fixed land-area constant). Immediately after, ADD:
   ```stata
   gen double pop_density_1907 = pop_1907 / canton_area_km2
   label var pop_density_1907 "Population density (persons/km^2, 1907 = pop_1907 / fixed 1900 land area)"
   gen double ln_pop_1907 = ln(pop_1907)
   label var ln_pop_1907 "Log canton population (1907)"
   ```
3. **Consistency checks (report per §2 of dispatch):**
   - `assert pop_1907 > 0 & !missing(pop_1907)` (all 25); `count if missing(pop_1907)` == 0.
   - National sum: `egen double _ns = total(pop_1907)` → `di` the total; assert within rounding of the
     yearbook national 1907 figure (from the CSV `CH` row if provided, else PI supplies the constant).
   - Identity: `assert reldif(pop_1907 / pop_density_1907, canton_area_km2) < 1e-9` (no unit slip).
   - Spot-print 3 cantons (ZH, GE, NE) `pop_1907` for PNG eyeball.

### B. `09_canton_reg1_workshop.do` — repoint `ln_density` + per-cap to 1907
4. **L282 `ln_density`** — redefine onto 1907 (cov_land = fixed land area stays):
   ```stata
   * OLD: gen double ln_density = ln_pop_1900 - cov_land            // = ln(pop_density_1900)
   gen double ln_density = ln_pop_1907 - cov_land                   // = ln(pop_1907 / land area) = ln(pop_density_1907)
   label var ln_density "Log population density (1907 pop / fixed 1900 land area)"
   ```
   Keep `ln_pop_1900` (cohort exhaustive); it is no longer the scale control.
5. **L287 identity check** → `gen double _ln_density_check = ln(pop_1907 / canton_area_km2)` (assert unchanged).
6. **L113 `X1`** (per-cap robustness): `gen X1 = wine_ha / pop_1907 * 1000`; update label to "(… per 1,000 pop, 1907)".
7. **L551 `pet_per_cap`**: `gen double pet_per_cap = pet_total / pop_1907 * 100`; label "(per 100 pop, 1907)".
8. **Honesty labels:** `cov1 "French language share (%, 1900 census — nearest available)"`,
   `cov3 "Protestant share (%, 1900 census — nearest available)"`.

### C. Other workshop per-cap/weight uses
- `_section_2_1_anchor_stats.do:80` `[aw=pop_1900]` → `[aw=pop_1907]` IF that anchor stat is in the paper (confirm w/ PI; low-stakes helper).
- Table-note vintage line ("confessional/linguistic shares: 1900 census, nearest; population/density: 1907")
  added where the workshop table builders / `_workshop_table.ado` support footnotes. Prose wording PI-owned.

---

## Re-run order (workshop; SKIP 10k RI per dispatch §4)
```
0. BASELINE snapshot (needs NO new data — can run now): current headline FL-AME, ln_density coef,
   X1 coef, pet_per_cap coef  → record for the before/after table.
1. 08_setup_cohort_1908.do            → cohort_1908.dta (+ pop_1907, pop_density_1907)
2. 08_setup_cohort_1908_workshop.do   → cohort_1908_workshop.dta (intermediate)
3. 09_canton_reg1_workshop.do         → overwrites cohort_1908_workshop.dta + estimates_workshop/ + estimates_crossref/
4. 12_canton_petition_workshop.do     → petition estimates (pet_per_cap)
5. Tables: 14, 10w, 13w, 11w, 15, 19, 21   (regenerate those printing density/scale/per-cap)
6. 22_canton_inference_battery.do     → POINT estimates + analytic/HC3/cluster + LOO only; SKIP the 10k RI loop
   23_canton_inference_battery_tables.do → rebuild; leave RI p-value cells flagged stale (PI porting RI to R)
7. _canton_ame_magnitudes.do          → headline FL-AME magnitude (before/after headline number)
8. 16/17/18                           → figures (esp. f02 partial scatter conditioning on density) + assemble + replication strip
```
Wrappers: `_rerun_09_12.do` (steps 1–4 via the existing chain), `_workshop_tables_run.do` (step 5),
`_inference_battery_run.do` + `_run_23_tables.do` (step 6), `_workshop_finals_run.do` (step 8).

## Acceptance / convergence (dispatch §6)
- `pop_1907` present for all 25; build passes existing asserts.
- **Census shares (`cov1`,`cov3`) byte-unchanged** vs baseline (proves the trap didn't fire).
- **`canton_area_km2` byte-identical** vs baseline (proves land-area constant preserved).
- `ln_density`, `X1`, `pet_per_cap` now reflect 1907.
- Headline X3 FL-AME should be **robust** (~0.434) — it is value-share, not population-derived. If it moves
  materially → flag (real or pipeline bug), do not smooth.
- Deliver before/after report: headline AME, density coef, each per-cap coef — old / new / Δ; flag sign flips.

## Verification (verification-protocol.md)
Run edited `08` + `09w` end-to-end via MCP (`is_file=True`, `allow_unsafe_paths=True`), read the log,
confirm all asserts pass + the shares/area invariants. Then run the table chain; confirm `.tex`/`.md` build.

## Out of scope
- Gen-1 (`01/02/04/05`, `absinthe_analysis.dta`, `placebo_panel`/T14b). 10k RI in Stata (→ R). Pre-1908 referenda extension.

## Open PI confirmations
1. National 1907 population total to assert the sum against (or include a `CH` row in the CSV).
2. Is `_section_2_1_anchor_stats.do`'s `[aw=pop_1900]` in the paper (→ move to 1907)?
3. Year-matching 1907 pop vs wine vintage: workshop wine measures are **1907**, so this matches well — confirm no concern.
