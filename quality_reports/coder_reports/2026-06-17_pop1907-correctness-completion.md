# Completion report — 1907 population correctness fix (c-metrics, blind cross-check)

**Date:** 2026-06-17
**Dispatch:** `analysis/documentation/handoffs/2026-06-17_blind-coder-population-1907-correctness-cmetrics.md`
**Plan:** `analysis/documentation/plans/2026-06-17_pop1907-workshop-fix.md`
**Scope (PI-locked):** workshop chain only. **Status:** implemented + verified; **uncommitted** (HEAD `starter` `2932089`), awaiting PI say-so to commit.

## What changed (methodology)
- Density/scale/per-cap controls moved from **1900 census** to **actual 1907** yearbook population.
- `canton_area_km2` (= `pop_1900 / pop_density_1900`, the fixed land-area constant) **unchanged**.
- Census shares (`cov1` French, `cov3` Protestant) **kept on the 1900 denominator** (the trap).
- **Petition** per-capita denominator moved to **1906** (the petition is a 1906 event; matches `eligible_1906`).

## Shared inputs (identical-input contract for the diff)
Built from the 1908 Statistical Yearbook volume (sheet `English`, 1907 & 1906 back-columns) by
`analysis/scripts/python/build_pop_canton_yearbook.py`, each national-total cross-validated:
- `processed/pop_1907_canton.csv` — 25 cantons, Σ = **3,524,529** (= source CH 1907 total, exact).
- `processed/pop_1906_canton.csv` — 25 cantons, Σ = **3,491,163** (= source CH 1906 total, exact).
- Spot values (pop_1907): ZH 475,162 · BE 620,321 · GE 149,172 · NE 134,360 · VD 303,139.

## Before/after (workshop col-5; identical specs run pre/post via `_pop1907_capture.do`)
| Quantity | Before (1900) | After (1907/1906) | Δ | Status |
|---|---|---|---|---|
| Headline OLS `X3_share` | 0.46937 | **0.47278** | +0.73% | robust ✓ |
| Headline FL-AME `X3_share` (pp) | 0.43380 | **0.43723** | +0.79% | robust ✓ (safeguard) |
| Density coef `ln_density` | −2.08645 | **−2.01890** | +3.2% | moved (intended) |
| Per-cap `X1` coef | 0.16778 | **0.17444** | +4.0% | moved (intended) |
| Σ `cov1` (French) | 442.819965 | 442.819965 | **0** | unchanged ✓ |
| Σ `cov3` (Protestant) | 1076.419136 | 1076.419136 | **0** | unchanged ✓ |
| Σ `canton_area_km2` | 39933.999964 | 39933.999964 | **0** | unchanged ✓ |
| Σ `ln_density` | 115.45 | 116.71 | +1.25 | moved ✓ |
| Σ `X1` | 172.03 | 162.53 | −9.49 | moved ✓ |
| Σ `pet_per_cap` | 120.78 | 116.17 | −4.61 | moved (1906) ✓ |

No sign flips. Headline robust (value-share, not population-derived). Directions consistent with
1900<1906<1907 population growth (per-cap sums fall, density rises).

## Acceptance criteria (dispatch §6) — all met
- [x] `pop_1907` present for all 25; build asserts pass (national-sum + density identity).
- [x] Census shares **byte-identical** (trap did not fire).
- [x] `canton_area_km2` **byte-identical** (land-area constant preserved).
- [x] Density/scale/per-cap reflect 1907; petition reflects 1906.
- [x] Headline AME robust (0.434→0.437; not material).

## Randomization inference — deliberately deferred to R (dispatch §4)
- `22` run with `RUN_RI=0`: regenerated LOO + HC1/HC2/HC3 + Bell-McCaffrey + Oster + Cahannes on
  corrected data; **10k Stata `ritest` skipped**.
- `23` run with `RI_PENDING_RERUN=1` (new gate): `T_ri` **withheld from Overleaf** and flagged
  *"STALE — pending R re-run on 1907-corrected data"* in caption + footnote. `inference_ri.dta`
  remains the pre-fix 10k run. **Action:** regenerate RI via the standalone R port on the corrected
  dataset, then re-run `23` (drop `RI_PENDING_RERUN`) to finalize/deploy `T_ri`.

## Outputs regenerated (deployed)
- **32 workshop `.tex`** (T1–T11, T10v, T_desc) → `Overleaf/.../Tables/Workshop_draft/` — spot-checked
  T2 col-5: Wine revenue share **0.473**, Log population density **−2.02**, vintage footnote present.
- **4 inference `.tex`** (T_loo_gate, T_producer_cascade, T_se_bm, T_oster) → `Tables/Robustness_6-3-26/`.
  `T_ri` correctly NOT redeployed (stale).
- Figures (16), master md (17), replication strip (18), headline AME magnitudes — all rebuilt.

## Files touched (uncommitted)
- `scripts/python/build_pop_canton_yearbook.py` (new; supersedes deleted `build_pop_1907_canton.py`)
- `processed/pop_1907_canton.csv`, `processed/pop_1906_canton.csv` (new)
- `scripts/08_setup_cohort_1908.do` (§8.2: +pop_1907/pop_density_1907/ln_pop_1907 +pop_1906; canton_area_km2 unchanged)
- `scripts/09_canton_reg1_workshop.do` (ln_density→1907; X1→1907; pet_per_cap→1906; cov1/cov3 vintage labels)
- `scripts/programs/_workshop_table.ado` (vintage footnote)
- `scripts/23_canton_inference_battery_tables.do` (`RI_PENDING_RERUN` gate)
- helper runners: `_pop1907_capture.do`, `_pop1907_rebuild.do`, `_pop1907_phase2.do`
- regenerated cohort (`cohort_1908_workshop.dta`, 90 vars), estimates, deployed tables/figures, codebook.

## Notes / minor follow-ups
- 9 orphaned `.tex` in Workshop_draft are old-naming variants no longer emitted (e.g.
  `T9_..._A_agg.tex` → now `_A_agg_OLS/_FL`) + out-of-scope `t27` (script 07). Not deleted (PI's Overleaf).
- The Phase-2 batch reported a spurious rc=111 "failed" — it is the benign `di as error` T_ri-withhold
  message (line 4201/4202 of `23`); `PHASE2_DONE` printed and all four phase markers fired.

## For the cross-check
Diff this repo's before/after against the parallel `Brainstorm-Absinthe/Replication` rebuild. Expected
convergence on the headline FL-AME (~0.437) and the `ln_density` coefficient. Both pipelines ingest the
identical `pop_1907_canton.csv`; divergence beyond rounding = a pipeline bug to localize.
