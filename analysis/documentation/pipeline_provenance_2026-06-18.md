# Replication pipeline — data-construction trace (Gen-2 / workshop paper)

**Check date:** 2026-06-18
**As-of state:** branch `pop1907-correctness`, commit `9957667` (1907/1906 population fix).
**Type:** dated *provenance snapshot* (factual "how it was wired on this commit"), NOT a plan.

> **How to use / maintain this file**
> - This is a point-in-time map of *what produces the data behind the final paper results*,
>   built by back-tracing from the deployed Overleaf tables/figures to their producing scripts.
> - It is **dated + commit-anchored on purpose**: if it disagrees with the scripts, the scripts
>   win — re-trace and either update this file in place or add a new dated snapshot. Staleness is
>   self-evident from the date/commit header (unlike an undated plan doc).
> - The **OPEN** section at the bottom is the next deliverable (raw-input provenance). When that
>   trace is done, extend THIS file rather than starting a new one.
> - **Trust notes:** `codebook.md` is mechanically regenerated from the real `.dta` each run
>   (trustworthy). `analysis/results/_inventory.xlsx` is STALE — do not rely on it.

**Method:** read empirically from each script's `save` / `estimates save` / `graph export`
(not from narrative docs). Scope of THIS trace = the **data layer only**; full out-of-production
classification of every script and the raw-input acquisition trace are still pending.

---

## Production spine (verified by running it end-to-end, 2026-06-17/18)
```
08_setup_cohort_1908 -> 08_setup_cohort_1908_workshop -> 09_canton_reg1_workshop (+ 12_canton_petition_workshop)
   -> table builders {10w, 11w, 13w, 14, 15, 19, 21}
   -> inference {22 -> 23}
   -> finals {16, 17, 18}
   -> _canton_ame_magnitudes
```

## How the main regressions are constructed
- **Headline col-5 spec:** `Y1 ~ X3_share + cov1 + cov2_total_share + cov3 + ln_density`
  - `Y1` = canton Yes-share, vote #68 (1908 absinthe ban); FL outcome `Y1_frac = Y1/100`
  - `X3_share` = wine **revenue** national share (1907)
  - `cov1` = French language share (1900 census, nearest available)
  - `cov2_total_share` = Milliet absinthe-trade share
  - `cov3` = Protestant share (1900 census, nearest available)
  - `ln_density` = log(`pop_1907` / fixed land area)
  - **Estimators:** OLS HC3 **and** fractional-logit average marginal effect (`fracreg logit` + `margins, dydx`)
  - **Current values (commit 9957667):** OLS β(X3) = 0.473; FL-AME = 0.437 pp

## What makes the data the tables/figures consume
| Output consumed | Producing script | Data it writes |
|---|---|---|
| Cohort (base) | `08_setup_cohort_1908.do:1456` | `processed/cohort_1908.dta` |
| Cohort (intermediate) | `08_setup_cohort_1908_workshop.do:233` | `processed/cohort_1908_workshop.dta` |
| Cohort (FINAL) + main estimates | `09_canton_reg1_workshop.do:594` | overwrites `cohort_1908_workshop.dta`; `estimates_workshop/`, `estimates_crossref/`, `estimates_winetype_workshop/`, `estimates_robust_workshop/`, `estimates_fraclogit_workshop/` |
| Petition estimates | `12_canton_petition_workshop.do` | `estimates_petition_workshop/` |
| AME estimates | `_canton_ame_magnitudes.do` | `estimates_fraclogit_workshop/` |
| Inference (.dta read by 23) | `22_canton_inference_battery.do` | `inference_{loo,ri,se_bm,oster,winetype}.dta` |
| Structural-break ratio data | `07_substrate_descriptives.do` | `processed/intermediate/h2a_substrate_prices_long.dta` (wine/potato ratio) |
| Structural-break figure | `_2_1_structural_break.do:57` | `f11_wine_potato_ratio_breaks.{png,pdf}` |

**Lynchpin:** `09_canton_reg1_workshop.do` finalizes the cohort AND runs most regressions.
Regenerable binaries (`processed/*.dta`, `results/intermediate/*.dta/.ster`) are gitignored.

## Disambiguation flags ("don't trust the naming")
1. **`_`-prefix != out-of-production.** `_2_1_structural_break.do` (deployed f11) and
   `_canton_ame_magnitudes.do` (production AME) are underscore-named but PRODUCTION.
2. **Superseded OLD path:** suffix-less `estimates/` is written/read by non-workshop `09 / 10 / 11`
   (pre-workshop canton chain) — superseded by `estimates_*_workshop`.
3. **Collision risk:** `_phase9_exhaustive.do` writes INTO the production estimate dirs — confirm
   scratch vs canonical before relying on or pruning it.
4. **Unresolved:** producer of deployed `t27_quandt_andrews_structural_break.tex` not yet pinned
   (`07` writes only a notes `.md`; `_2_1` writes only f11).

---

## OPEN — next deliverable (deferred): raw-input provenance of the cohort build
Trace the **raw inputs to `08_setup_cohort_1908.do`** (the opening/cohort-build file): exactly
*which* raw files it reads to construct `cohort_1908.dta`, and **how each was obtained** (source,
acquisition method, transcription/extraction step). Preliminary list from `08`'s Input header +
this session (**acquisition NOT yet verified**):
- `$Absinthe1Data/swissvotes_dataset.csv` (vote shares + `eligible_1906`)
- HSSO `B.01a` (population 1900/1910), `B.27` (religion 1900), `B.32` (language 1900), `B.01b` (density 1900)
- `processed/canton_wine_1907_pi.csv` <- `python/build_canton_wine_1907_pi.py` <- 1908 Yearbook wine table
- `processed/pop_1907_canton.csv` + `pop_1906_canton.csv` <- `python/build_pop_canton_yearbook.py` <- 1908 Yearbook population table
- `$Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx` (absinthe-trade proxy)
- Petition source (`AbsinthePetition.xlsx`)

For each: confirm the file actually read (grep `08`), the original source, and the obtain/transcribe path.
```
