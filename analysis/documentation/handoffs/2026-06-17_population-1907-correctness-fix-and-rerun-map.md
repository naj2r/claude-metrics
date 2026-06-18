# Plan — 1907 population correctness fix + re-run map (worktree pipeline + paper)

**Date:** 2026-06-17
**Status:** DRAFT — awaiting PI approval; the coder implements (coordinator does not edit `.do`/paper prose).
**Companion (blind cross-check):** `coder_dispatch/2026-06-17_blind-coder-population-1907-correctness-cmetrics.md`

## The defect (one line)
Main-regression `population` and `pop_density` are **raw 1900** (and a `pop_1907_estimated` = 1900→1910 interpolation in the v2 csv). Workshop spec wants **actual 1907 population**, with **density = pop_1907 / land_area** (land_area = the fixed survey constant already backed out of 1900 pop÷density).

## The fix, precisely
Introduce `pop_1907` (actual). Keep `area_km2` (fixed). Rewire:
- `pop_density` → `pop_1907 / area_km2`
- `ln_pop` → `ln(pop_1907)`
- `vineyard_per_cap`, `vine_per_1000`, pop weights → denominator/weight = `pop_1907`
- **KEEP 1900:** `area_km2 = pop_1900/pop_density_1900`; and **all census shares** (`catholic_share`, `protestant_share`, `french_share`, `german_share`) keep the **1900 census** denominator.

### ⚠ The trap
`population` is overloaded — it's the denominator for census shares (must stay 1900) AND for scale/per-cap controls (must become 1907). **Do not globally `replace population = pop_1907`** — that corrupts the 1900 shares. Build a distinct `pop_1907` and rewire only the scale/density/per-cap/weight uses. (See `00_build_dataset.do:374–394` where both kinds are computed off the same `population`.)

### Measurement-vintage principle (PI-locked 2026-06-17)
**First-best where the source is annual; second-best where it isn't — and say so honestly.**
- **First-best (annual → use 1907):** population, population density (yearbook annual mid-year estimates exist).
- **Second-best (not annual → use nearest census = 1900):** religious composition (Catholic/Protestant) and linguistic composition (French/German). The Swiss federal census is decennial; no annual confessional/linguistic series exists for 1900–1908. Composition is treated as slow-moving across the window.
- **Honesty requirement:** the data/methods section AND table notes/variable labels must name the vintage explicitly and acknowledge the compromise — 1900-census shares are *not* presented as contemporaneous with the 1907 scale/density controls. State plainly that demographic composition is the nearest-available (1900) measure, held fixed over the 8-year window because no yearly source exists.

---

## Step 0 — PREREQUISITE: produce a clean `pop_1907_canton.csv` (25/25)
The actual 1907 pop is captured but **not reduced**:
- Source: `Data/raw/yearbook_extracts/population_canton/_combined.csv` (332 rows; wide `v1..v12` = annual back-series per yearbook volume).
- `_status.md`: 1907 volume = SUCCESS but **21/25 cantons**. The 4 missing must be cross-filled from the back-series of an adjacent volume (1908–1915 volumes each reprint 1907 as a `v` column).
- Verify against `Output/pop_check/1907_pdf*.png` + `1908_pdf*.png`.
- Output one reconciled `Data/cleaned/pop_1907_canton.csv` (25 cantons). **This becomes the shared input for BOTH pipelines** (worktree + c-metrics) so the cross-check isolates pipeline behavior, not extraction differences.

---

## Files to touch (worktree)

### Data build / dataset assembly
| File | Change |
|---|---|
| `Replication/Stata/00_build_dataset.do` | §5 (L270–309) add `pop_1907` input (keep 1900 as `pop_1900_census`); §6 (L312–348) keep 1900 density only to back out `area_km2`; §7 (L374–394) recompute `pop_density`, `ln_pop`, per-cap off `pop_1907`; **shares stay on 1900**. |
| `Replication/Data/build_swiss_referendum_dataset.py` | Python cross-validation mirror of the same change (Stata-first rule: `.do` canonical, `.py` cross-checks). |
| `Replication/Data/swiss_referendum_1908_analysis_v2.csv` (+ `_setup_v2_dta.py`) | Workshop dataset. Add real `pop_1907` column; demote `pop_1907_estimated` (the interpolation) to a robustness-only column. NB: authored in **main** repo per `_setup_v2_dta.py:13`; regenerate there, then re-copy. |
| `Replication/Data/swiss_referendum_1908_analysis.csv` / `.dta` | Regenerated outputs of the build. |

### Main regressions (consume the dataset)
| File | What uses population |
|---|---|
| `Replication/Stata/01_swiss_referendum_analysis.do` | `ln_pop` (L85), `pop_density`, `vine_per_1000` (L96,99), per-cap specs (L331+), FL/OLS controls. **SECTION 9 (L460–510) = the 10k-style RI loop → SKIP (move to R).** |
| `Replication/Stata/02_expansion_analysis.do` | `area_km2 = population/pop_density` (L697 — keep formula but inputs change), `vine_per_km2`, `ln_area`, pop weights (L312–332, 625), per-km2/agshare robustness. **SECTION 8 (L559–602) RI → SKIP.** |
| `Replication/Data/run_diagnostics.py`, `run_expansion.py` | Python cross-validation; mirror. `run_diagnostics.py` PART 3 already does RI in Python (10k) — basis for the R port. |

### Randomization inference → R (the time-saver)
RI currently lives in Stata `01.do §9`, `02.do §8` (slow `permute`/manual loops) and `run_diagnostics.py §3` (Python 10k). **Do NOT re-run the Stata RI in the main pass.** Port to a standalone **`Replication/R/ri_permutation.R`** (new) that reads the corrected dataset and emits the RI p-values for the headline + per-cap specs. Saves the hours of Stata permutation per re-run. Feed p-values back into the paper from the R output.

### Tables / Figures (regenerate, code-generated)
`Tables/tab1_*`, `tab2_*`, `tab4_*` (worktree) and the Overleaf set below; `Figures/fig1_*`, `fig2_*` (and any partial-residual/marginsplot that conditions on log pop / density).

---

## Re-run order (DAG)
```
Step0: build pop_1907_canton.csv (25/25, verified)         [data-prep]
   │
00_build_dataset.do  (+ build_swiss_referendum_dataset.py cross-val)
   │   → swiss_referendum_1908_analysis.{csv,dta} + v2
   ├── 01_swiss_referendum_analysis.do  (OLS/FL/robustness/shares; RI section SKIPPED)
   └── 02_expansion_analysis.do         (FL/weights/per-km2/agshare; RI section SKIPPED)
   │   → Tables/*, Figures/*
ri_permutation.R  (NEW; reads corrected dataset → RI p-values)   [parallel, off-Stata]
   │
CROSS-CHECK vs c-metrics coder rebuild  → converge or surface discrepancy
   │
Paper update (below)
```

## Safeguard / expected behavior
The headline regressor is the **wine value share (X3)** — **not population-derived** — so the headline FL-AME should be **robust** to this fix (PI safeguard: ~0.434, RI ~0.05–0.09). What *should* move is the **density control coefficient**, the **per-capita robustness specs**, and pop-weighted variants. If the headline moves materially, that's a flag (real effect or pipeline bug) — surface it.

---

## Paper impact (Overleaf: `…/Absinthe Switzerland Draft 1/`)
Manuscript prose is PI-owned; tables/figures are code-generated. What the rebuild forces:
| File | Why |
|---|---|
| `Sections/3-data.tex` (§Population density, ~L132–138) | Re-describe density as **pop_1907 / land_area** (not 1900); the lake-exclusion + 0.5% land-area cross-validation note stays valid. |
| `Sections/3-data.tex` (§religion + §language) | **Honesty note (PI-locked):** state that confessional/linguistic shares are the **1900 census** (nearest available; decennial census → no annual series), held fixed over 1900–1908, while population/density are the **1907** annual figure. Don't imply the demographic shares are contemporaneous with the 1907 controls. |
| `Sections/4-methods.tex` (L23/29/57/79) | OLS+FL equations carry `ln(pop_density)` as control γ_D — update any "1900" vintage wording; notation `pop_density` unchanged. |
| `Sections/5-results.tex` + `Sections/7-figuresAndTables.tex` | AME / density-coefficient numbers; table inputs. |
| `Sections/8-appendix.tex` | Esp. **A5 temporal interpolation** — its premise flips: from "interpolated 1907" to "**actual 1907 vs interpolated**" robustness. **A4 religion×density absorption** — density variable changed. |
| `Tables/` | Regenerate: `appendix_tab_A4_religion_density_absorption.tex`, `appendix_tab_A5_temporal_interpolation.tex`, `appendix_tab_A1_robustness.tex`, `appendix_tab_A2_religion_language.tex`, main FL/OLS tables, `tab_m1A/m1B` if density enters. |
| `Figures/` | `f02_scatter_partial` (controls for log pop), `f04_marginsplot_french` if density conditioning changes. |

---

## Out of scope (noted, not started)
Pre-1908 referenda back to ~1887 (procedural year-by-year). Park until the population fix lands and the two pipelines converge.

## Decisions LOCKED (PI, 2026-06-17)
1. **Population/density = actual 1907** (first-best annual); **religion/language = 1900 census** (second-best nearest vintage), held fixed over the window, **discussed honestly** in §3-data + table notes (see Measurement-vintage principle above).
2. Census-share denominators stay **1900** (consequence of #1 — `catholic_pop_1900 / pop_1900`).

## Open PI confirmations (minor)
1. Year-matching: 1907 pop vs 1905 vineyard harvest — using 1907 per PI; the harvest-prior nuance only matters for the #52 edge case flagged earlier.
2. RI R port: two-sided permutation, same #perms as the prior Stata RI? (default: match the old design exactly so p-values are comparable.)
