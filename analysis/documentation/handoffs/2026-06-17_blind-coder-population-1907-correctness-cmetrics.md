# Blind coder dispatch — 1907 population correctness in the workshop pipeline (c-metrics-absinthe1)

**Date:** 2026-06-17
**Target repo:** `c-metrics-absinthe1` (your own repo, `analysis/` tree)
**Type:** independent cross-validation fix. A parallel rebuild is happening in the other pipeline (`Brainstorm-Absinthe/Replication/`). **Do this blind** — implement from the methodology below and report *your* numbers. We compare afterward: agreement validates the fix; divergence isolates a pipeline bug. Do **not** tune toward any expected value, and do not consult the other pipeline's outputs.

> Coordinator note: the PI (Nicholas) will review and approve before you commit anything. Produce the change + a results report; await the PI's manual say-so to finalize.

---

## 1. The defect

Older code established the canton **population** and **population density** controls for the 1908 cross-section in one of two ways, both wrong for our purpose:

1. **raw 1900 census** (`pop_1900`, `pop_density_1900`), or
2. **1900→1910 linear interpolation** to 1907 (a `pop_1907_estimated`-style column).

Neither is the intended measure. The workshop specification calls for the **actual 1907 population** (Statistical Yearbook annual mid-year estimate), with density derived as **1907 population ÷ land area**, where land area is the fixed survey constant already backed out of the census.

In your repo this currently surfaces as `pop_1900` / `pop_density_1900` used directly as controls and per-capita denominators:
- `analysis/scripts/01_import.do` (imports density, `rename v1 pop_density_1900`)
- `analysis/scripts/02_clean.do:354` — `gen double area_km2 = pop_1900 / pop_density_1900` (✓ keep — this is the fixed land-area backout)
- `analysis/scripts/02_clean.do` (~525, ~568) — `ln_pop`, `pop_1900`, `pop_density_1900` carried as controls
- `analysis/scripts/04_tables.do` — summary stats over `pop_density_1900`
- `analysis/scripts/05_expansion.do:186` — `[aweight = pop_1900]`

---

## 2. The fix (methodology, not line-edits)

Introduce **`pop_1907`** (actual) and rebuild the three population-derived quantities from it. **Keep `area_km2` exactly as it is** (backed out from 1900 pop/density — land area is time-invariant; this is the "algebraically stored land area per canton").

| Quantity | OLD | NEW |
|---|---|---|
| Land area | `area_km2 = pop_1900 / pop_density_1900` | **unchanged** (fixed survey constant) |
| Density control | `pop_density_1900` | `pop_density_1907 = pop_1907 / area_km2` |
| Scale control | `ln_pop = ln(pop_1900)` | `ln_pop = ln(pop_1907)` |
| Per-capita denominators | `… / pop_1900` (e.g. `vineyard_per_cap`, `vine_per_1000`) | `… / pop_1907` |
| Population weights | `[aweight = pop_1900]` | `[aweight = pop_1907]` |

### ⚠ The one trap — do NOT globally swap `population`

`population` is overloaded. It is the denominator for **two different kinds of variable**:

- **Census composition shares** — `catholic_share`, `protestant_share`, `french_share`, `german_share`. These are 1900-census measurements (numerator = 1900 census counts from B.27/B.32). Their denominator **must stay the 1900 census total** so the share is internally consistent (`catholic_pop_1900 / pop_1900`). **Do not move these to 1907.**
- **Scale / density / per-capita controls** — `ln_pop`, `pop_density`, `vineyard_per_cap`, weights. These should be **1907**.

So you need *both* `pop_1900` (retained, for shares + the area backout) and `pop_1907` (new, for scale/density/per-cap). A blind `replace population = pop_1907` would corrupt every census share. Build a distinct `pop_1907` variable and rewire only the scale/density/per-cap/weight uses.

### Measurement-vintage principle (PI-locked 2026-06-17)
**First-best where the source is annual; second-best where it isn't — and say so honestly.**
- **First-best (use 1907):** population, density — yearbook annual estimates exist.
- **Second-best (use nearest census = 1900):** religious + linguistic composition — Swiss census is decennial, no annual series for 1900–1908; treat as slow-moving across the window.
- **Honesty requirement (not optional):** label these variables with their vintage and acknowledge the compromise in your **table notes / variable labels** (e.g. "confessional shares: 1900 census, nearest available; population/density: 1907"). Do not let a reader infer the demographic shares are contemporaneous with the 1907 controls. The PI will mirror this honesty in the prose.

### Consistency checks to run after wiring (report these)
- National sum of `pop_1907` matches the yearbook national 1907 total (within rounding).
- `pop_1907 / pop_density_1907` reproduces `area_km2` (definitional — confirms no unit slip).
- Spot-check 2–3 cantons against the source page images.

---

## 3. Data source for `pop_1907` (use the canonical extract — identical inputs both sides)

For the cross-check to isolate *pipeline* behavior, both pipelines must ingest **identical** 1907 population numbers. Do not independently re-OCR.

- Canonical raw extract: `Brainstorm-Absinthe/.../Data/raw/yearbook_extracts/population_canton/_combined.csv` (wide; columns `v1..v12` are the annual back-series each yearbook volume prints; `yearbook` column = volume year).
- Verification page images: `Output/pop_check/1907_pdf*.png` and `1908_pdf*.png`.
- **Caveat:** the 1907 *volume* extract is only 21/25 cantons. The 4 missing cantons must be recovered from the **back-series of an adjacent volume** (the 1908–1915 volumes each reprint 1907 as one of their `v` columns). The PI is producing a single reconciled `pop_1907_canton.csv` (25/25, verified vs the PNGs) as the shared input. **Wait for that file and ingest it** rather than reducing `_combined.csv` yourself — that guarantees identical inputs. If you must proceed before it lands, document your reduction rule precisely so we can diff.

Year choice is **1907** per PI instruction (closest pre-vote annual estimate). Flag, don't resolve, the harvest-matching nuance (1905 vineyard vs 1907 pop) — that's a PI call.

---

## 4. What to re-run — and what to skip

Re-run the build → clean → main estimation → robustness so all point estimates and analytic/HC3 SEs reflect the corrected density/scale controls:
- `01_import.do` → `02_clean.do` → rebuild `cohort_1908_workshop.dta`
- `05_expansion.do` (headline KEY spec, AME magnitudes, robustness battery, formal-hypotheses table)
- `04_tables.do` (summary stats + regenerate the `.tex` tables that print density/scale)

**Skip the 10k randomization-inference / permutation pass in Stata** (e.g. `_inference_battery_run.do`'s RI loop). The PI is migrating RI to a standalone **R** script for speed — it will be regenerated there on the corrected dataset. Re-run only the point estimates + analytic/HC3/cluster SEs in Stata. Leave RI p-value cells stale/flagged; do not spend the hours on Stata `permute`.

Do **not** start the pre-1908 (back to ~1887) referenda extension — out of scope here.

---

## 5. What to report back (for convergence comparison)

Write a completion report (`analysis/output/notes/` or your usual location) with:
1. The new `pop_1907` you used (25 cantons) + the consistency-check results from §2.
2. **Before/after table** for every spec touched: headline X (wine value share) AME, the density-control coefficient, and each per-capita robustness coefficient — old value, new value, Δ. Flag any **sign flip** or move beyond your normal tolerance.
3. Which `.tex` tables/figures regenerated (paths + git status).
4. Any place the decoupling (§2 trap) forced a structural change to the build.
5. Anything that *didn't* behave as a pure control-side change (it should mostly be density/scale/per-cap that moves; the value-share headline is not population-derived, so watch whether it stays put — report it either way, don't target it).

---

## 6. Acceptance / convergence criteria

- Build passes existing asserts; `pop_1907` present for all 25 cantons; census shares **unchanged** from the current run (proves you didn't corrupt the 1900 denominators).
- `area_km2` byte-identical to before (proves the land-area constant was preserved).
- Density/scale/per-cap controls now reflect 1907.
- Report delivered per §5. The other pipeline's rebuild will be diffed against yours; we expect the **two to converge** on the headline and on the density coefficient. Discrepancies are findings — surface them, don't smooth them.

**Stop and ask the PI** if: the reconciled `pop_1907_canton.csv` isn't available; a census share moves (means the trap fired); or the headline AME moves materially (could be real or a pipeline bug — flag it).
