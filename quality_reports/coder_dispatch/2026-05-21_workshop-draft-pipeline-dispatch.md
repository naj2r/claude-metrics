# Coder Dispatch: Workshop Draft Pipeline (2026-05-21)

**Project:** Paper 1, political economy of 1908 Swiss absinthe ban
**Workshop deadline:** ~2026-05-22 (presentation) / target submission ~2026-06-08 (EEH)
**Strategist on standby for review of outputs**

---

## Hard rules to flag before/during execution

Before executing any phase, read the following project rules:

- `.claude/rules/methodology-integrity.md`
- `.claude/rules/stata-gotchas.md`
- `.claude/rules/figures.md` (if exists)
- `.claude/rules/tables.md` (if exists)
- `.claude/rules/working-paper-format.md` (if exists)
- Any other `.claude/rules/*.md` in this repo

**If any instruction in this dispatch conflicts with a project rule, flag it explicitly in your completion message — DO NOT silently override or silently follow the dispatch.** Provide a one-line description of the conflict and your recommended resolution; await strategist confirmation before proceeding on the conflicting item.

Specific known frictions to watch for:
- HC3 robust SEs are project methodology for OLS at N=25 (must hold throughout)
- `_inventory_append` is append-only — only fire on RUN_POSTCREDITS=1
- `**# ` section banners cannot contain `/*` substrings (block-comment nesting bug)
- All paths via `$MyProject` / `$Absinthe1Data` globals; forward slashes only
- No renaming of existing PI variables in the cohort (X1, X2_num, X3_num, X4, cov1, cov2_*, cov3, cov_land are locked as-is)

---

## Scope summary

Build a workshop-targeted version of the existing 08–13 pipeline by:

1. **Duplicating scripts as `_workshop.do` variants** — preserves the existing pipeline intact for future "informal analysis" review
2. **Producing TWO and only TWO workshop .dta files:**
   - `cohort_1908_workshop.dta` — the EXHAUSTIVE FULL VERSION. Contains every raw variable from 08, plus every derivation, transformation, share construction, structural-zero enforcement, and interaction term created in 09. Nothing in this file is regenerable-only-from-pipeline — every variable is present after a successful pipeline run.
   - `cohort_1908_workshop_replication.dta` — the STRIPPED SUBSET. Pure `keep`-subset of the full. Produces byte-identical regression results to the full for every workshop spec.
3. **Routing LaTeX outputs to** `C:\Users\jensenn\Dropbox\Apps\Overleaf\Absinthe Switzerland Draft 1\Tables\Workshop_draft\`
4. **Routing figures to** `C:\Users\jensenn\Dropbox\Apps\Overleaf\Absinthe Switzerland Draft 1\Figures\`
5. **Markdown twins stay** at standard project `_md/` locations
6. **Workshop master MD** assembles all tables in paper presentation order at `_md/workshop/canton_workshop_summary.md`

Existing pipeline files 08–13 stay UNTOUCHED. The workshop pipeline is additive.

### Two-file principle (binding)

**`cohort_1908_workshop.dta` is THE workshop source of truth.** Loading this file gives access to every variable in the workshop pipeline — raw counts, share constructions, log transforms, interactions, the lot. No pipeline re-run is ever required to recover a variable from it. The file is overwritten ONLY by `09_canton_reg1_workshop.do`'s final save (after all derivations complete).

`cohort_1908_workshop_replication.dta` is regenerable from the full via `18_workshop_replication_strip.do`, which applies a single editable `keep` list. Edit the list and re-run to adjust the strip; the full file is read-only consumer.

Within the pipeline (08→09→12→14→15→16→17→18), `08_workshop` produces an intermediate version of `cohort_1908_workshop.dta` that contains raw + petition + eligibility merges only. `09_workshop` then loads that intermediate, adds all §1.x derivations, and OVERWRITES `cohort_1908_workshop.dta` with the canonical full version. After a successful 08→09 run, `cohort_1908_workshop.dta` is in its final state.

---

## Existing infrastructure to leverage

Before writing any new code, the following `.ster` files exist (or will after 09_workshop runs):

| Source script | Output `.ster` files | Used by workshop |
|---|---|---|
| 09 §2.1 | `estimates/ols_k_j.ster` (20 files) | Tables 2, 3 |
| 09 §2.5 | `estimates_fraclogit/fl_k_j.ster` + `fl_me_k_j.ster` (40 files) | Tables 2, 3 |
| 09 §2.6 | `estimates_robust/r{1-6}.ster` | Table 5 (R4 only) + Appendix Table 7 |
| 12 §2.1 | `estimates_petition/ols_pet_k_j.ster` (20 files) | Table 4 |
| `05_expansion.do` §12.15 | `results/tables/t25_lang_turnout_gap.tex` | Table 6 |

NEW `.ster` needed for Table 8 and Table 5 Panel B:
- `pct_yes_67` and `pct_yes_69` regressions (OLS + FL) at headline spec
- R4 interaction with X3_share instead of X2_share

---

## Variable label conventions (LOCK IN BEFORE TABLE BUILD)

Tables must use HUMAN-READABLE labels, not raw Stata variable names. Update labels in 09_workshop §1.2–§1.5 to the following (use `label var` and propagate via esttab's `coeflabels()` option):

| Stata var | Display label in tables |
|---|---|
| `X1` | Wine area per 1,000 pop. (ha) |
| `X1_share` | Wine area, national share (%) |
| `X2_share` | Wine volume, national share (%) |
| `X3_share` | Wine revenue, national share (%) |
| `X4` | Wine yield (hl/ha) |
| `cov1` | French language share (%) |
| `cov2_total_share` | Absinthe industry share (%) |
| `cov3` | Protestant share (%) |
| `cov_land` | Log canton area (km²) |
| `ln_pop_1900` | Log canton population |
| `ln_density` | Log population density |
| `abs_producer` | Absinthe-producer indicator |
| `fr_x_producer` | French × Absinthe-producer |
| `wine_vol_log` | Log wine volume |
| `abs_log` | Log absinthe purchases |
| `abs_nfirms` | N absinthe firms |
| `pct_yes_67` | Yes-vote, Vote #67 (commerce) |
| `Y1` | Yes-vote, Vote #68 (absinthe ban) |
| `pct_yes_69` | Yes-vote, Vote #69 (water power) |
| `pet_per_eligible` | Petition signatures per 100 eligible voters |
| `pet_per_cap` | Petition signatures per 100 pop. |
| `pet_natshare` | Petition canton share of national (%) |
| `turnout_68` | Turnout, Vote #68 |
| `pop_1900` | Population (1900) |

**Rationale:** A reviewer should NOT be wondering "what is X2 and why is it numbered X2 — what's X1?" The labels above make each variable's economic meaning self-evident without requiring memorization of the X1/X2/X3 internal naming.

In esttab calls, pass via:
```stata
esttab ..., coeflabels(X3_share "Wine revenue, national share (\%)" ///
                       cov1 "French language share (\%)" ///
                       cov3 "Protestant share (\%)" ///
                       ln_density "Log population density" ///
                       _cons "Constant") ///
            ...
```

---

## Phase 0 — Verify, then dispatch

### 0.1 Read project rules

Read all `.claude/rules/*.md` files. Flag anything in this dispatch that conflicts.

### 0.2 Confirm petition data is mergeable

- `$Absinthe1Data/translated/AbsinthePetition.xlsx` should exist (per 12 §1.2 path)
- `$Absinthe1Data/swissvotes_dataset.csv` should exist (per 12 §1.1)
- If either missing, halt and report

### 0.3 Confirm existing pipeline runs clean

Before duplicating, run the existing pipeline (08 → 09 → 12 → 10 → 11 → 13) once to confirm baseline state. Save run log to `analysis/scripts/logs/`. Report any errors.

---

## Phase 1 — `08_setup_cohort_1908_workshop.do` (cohort builder, intermediate save)

### Purpose

Duplicate of `08_setup_cohort_1908.do` with two additions:

1. **Merge petition signatures** from `$Absinthe1Data/translated/AbsinthePetition.xlsx` (canton-level: `pet_total`, `pet_valid`, `pet_invalid`)
2. **Merge vote 65 eligibility** from swissvotes (`eligible_1906`) — needed as petition denominator

Save the result (raw + petition + eligibility, BEFORE any §1.x derivations) to:
- `$MyProject/processed/cohort_1908_workshop.dta`

**This is an intermediate state.** Phase 2 (09_workshop) reads this file, adds all derivations, and OVERWRITES it with the canonical full version. After a successful 08→09 run, this file is in its final state and is the workshop source of truth.

### Implementation notes

- Use the EXACT import logic from `12_canton_petition.do` §1.1 (vote 65 eligibility) and §1.2 (petition XLSX) — do NOT rewrite from scratch. Just lift those sections into 08_workshop.
- After both merges, save the cohort with `save ..., replace`. 09_workshop will overwrite this file with the augmented version.
- Documentation block at top of file: identify lineage as "duplicate of 08 + petition/eligibility merges from 12 §1.1–§1.2; intermediate state — 09_workshop overwrites with full augmented cohort."

### Verification

- `assert c(N) == 25` after each merge
- Cross-validate petition total = 169,377 (Bundesblatt 1907 p.984)
- Cross-validate vote 65 eligible national total against published national figure
- Save with `replace` (the file will be overwritten by 09_workshop in the next phase; that's intentional)

---

## Phase 2 — `09_canton_reg1_workshop.do` (derivations + primary battery; canonical full save)

### Purpose

Duplicate of `09_canton_reg1.do` with:

1. **Read** `cohort_1908_workshop.dta` (the intermediate state from 08_workshop)
2. **Density swap**: derive `ln_density = ln_pop_1900 − cov_land`. Replace `cov_land + ln_pop_1900` with `ln_density` in `$ctrl_s_c5` and `$ctrl_1_c5`.
3. **Spec trim**: keep all 4 wine variants (X1, X2_share, X3_share, X1_share) for the full battery, but the workshop tables will draw selectively (Tables 2 and 4 show X2_share and X3_share; Table 3 shows X1, X2_share, X3_share).
4. **OVERWRITE** `cohort_1908_workshop.dta` at end of §1.5 (after all derivations + interactions, before §2 regressions) with the canonical full version. After this save, `cohort_1908_workshop.dta` contains the COMPLETE exhaustive workshop cohort — every raw variable from 08, plus every derivation, share, log transform, structural-zero enforcement, and interaction created in 09.

### Density swap details (KEY: reiterated because previous dispatch didn't land)

In 09_workshop §1.2.2 (after the existing `ln_pop_1900` derivation):

```stata
* New geographic-scale composite control: ln(population density)
* Replaces cov_land + ln_pop_1900 in cascade col 5 with a single density
* regressor. β_pop ≈ −β_area in the original col 5 indicates density is
* doing the work and the size/density separation is not identified at N=25.

cap drop ln_density
gen double ln_density = ln_pop_1900 - cov_land
label var ln_density "Log population density"

* Arithmetic identity assertion
gen double _ln_density_check = ln(pop_1900 / canton_area_km2)
assert abs(ln_density - _ln_density_check) < 1e-10
drop _ln_density_check
```

In 09_workshop §1.4, modify the col-5 globals:

```stata
* Original:
*   global ctrl_s_c5 "cov1 cov2_total_share cov3 cov_land ln_pop_1900"
*   global ctrl_1_c5 "cov1 cov2_total_share cov3 cov_land"
* Workshop variant:
global ctrl_s_c5 "cov1 cov2_total_share cov3 ln_density"
global ctrl_1_c5 "cov1 cov2_total_share cov3 ln_density"
```

Cols 1–4 globals unchanged (no geographic controls in earlier cascade cols).

### New R4-X3 spec (for Table 5 Panel B)

In 09_workshop §2.6 (after R6), add:

```stata
* R4b: French x absinthe-producer interaction with X3_share (revenue share)
*      Workshop Table 5 Panel B; mirrors R4 (X2_share) as Panel A.
cap estimates drop r4b_fr_x_prod_x3
qui regress Y1 X3_share cov1 cov2_total_share cov3 ln_density fr_x_producer abs_producer, vce(hc3)
estimates store r4b_fr_x_prod_x3
estimates save "$MyProject/results/intermediate/estimates_robust/r4b_fr_x_prod_x3.ster", replace
di as text "  R4b (fr x prod, X3): N=" e(N) ", β(X3_share)=" %8.4f _b[X3_share] ", β(fr_x_prod)=" %8.4f _b[fr_x_producer]
```

### Cross-referendum new regressions (for Table 8)

In 09_workshop §2.7 (replacing the existing 60/63/65 SKIP block), add:

```stata
* Cross-referendum same-day votes (67/68/69)
* Falsification logic: same voters, same ballot day, three different questions.
* Expectation: β_wine ≈ 0 on #67 (commerce) and #69 (water power); positive on #68.

cap mkdir "$MyProject/results/intermediate/estimates_crossref"

foreach r_id in 67 68 69 {
    * OLS
    cap estimates drop crossref_ols_`r_id'
    qui regress pct_yes_`r_id' X3_share cov1 cov2_total_share cov3 ln_density, vce(hc3)
    estimates store crossref_ols_`r_id'
    estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_ols_`r_id'.ster", replace
    di as text "  Vote `r_id' OLS: β(X3_share)=" %8.4f _b[X3_share]

    * Fractional logit
    cap drop _yfrac
    gen double _yfrac = pct_yes_`r_id' / 100
    cap estimates drop crossref_fl_`r_id'
    qui fracreg logit _yfrac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    estimates store crossref_fl_`r_id'
    estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_fl_`r_id'.ster", replace

    cap estimates drop crossref_fl_me_`r_id'
    qui margins, dydx(X3_share) post
    estimates store crossref_fl_me_`r_id'
    estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_fl_me_`r_id'.ster", replace
    di as text "  Vote `r_id' FL AME: " %8.4f _b[X3_share]

    drop _yfrac
}
```

Note: `pct_yes_68 == Y1`. The new regression for Y1 here will duplicate the existing primary spec; that's intentional — keeps Table 8 self-contained by using the same `crossref_*` naming family.

### Save full cohort (OVERWRITES intermediate from 08_workshop)

At end of §1.5 (after fr_x_producer is created, BEFORE §2 regressions begin):

```stata
* Overwrite cohort_1908_workshop.dta with the canonical full workshop cohort.
* This is THE workshop source of truth — contains every raw variable from 08,
* every §1.x derivation, every share construction, every transformation, every
* structural-zero enforcement, every interaction.  No pipeline re-run is ever
* needed to recover a variable from this file.
*
* Per dispatch design: 08_workshop wrote the intermediate (raw + petition +
* eligibility merges, no derivations).  This save OVERWRITES that intermediate
* with the augmented final version.  After this point, cohort_1908_workshop.dta
* is in its canonical state.
compress
save "$MyProject/processed/cohort_1908_workshop.dta", replace
di as text "  Saved canonical full workshop cohort with all §1 derivations: cohort_1908_workshop.dta"
di as text "  This file is the workshop source of truth. 18_workshop_strip will produce the stripped subset."
```

---

## Phase 3 — `12_canton_petition_workshop.do`

Duplicate of `12_canton_petition.do`. Reads `cohort_1908_workshop.dta` (the canonical full workshop cohort produced by 09_workshop) directly — it already contains the petition merge + eligible_1906 + all derivations, so 12_workshop's import logic (§1.1 vote 65 eligibility, §1.2 petition XLSX) becomes a defensive no-op (detect already-present variables, skip re-import).

Save petition `.ster` files to `$MyProject/results/intermediate/estimates_petition_workshop/` (separate from existing estimates_petition/ to keep workshop outputs distinct).

Run the 20-spec petition battery with the density-swap col-5 control.

---

## Phase 4 — Table-building scripts

Output directory for LaTeX:
```
$WorkshopTables = "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"
```

Define as Stata global at top of each script. All `esttab` calls write LaTeX to `$WorkshopTables/` and CSV/MD to standard project paths.

---

### Table 1 — Summary statistics + canton industrial composition

**Script:** `14_workshop_summary_stats.do`

#### Part A: Descriptive statistics

```markdown
| Variable                              | N  | Mean   | SD    | p50   | Min   | Max   | French | German | Producer | Non-prod |
|---------------------------------------|---:|-------:|------:|------:|------:|------:|-------:|-------:|---------:|---------:|
| **Outcomes**                          |    |        |       |       |       |       |        |        |          |          |
| Yes-vote, Vote #68 (absinthe ban)     | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Yes-vote, Vote #67 (commerce)         | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Yes-vote, Vote #69 (water power)      | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Petition signatures per 100 elig.     | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Turnout, Vote #68                     | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| **Wine regressors**                   |    |        |       |       |       |       |        |        |          |          |
| Wine area per 1,000 pop. (ha)         | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Wine volume, national share (%)       | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Wine revenue, national share (%)      | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| **Cultural covariates**               |    |        |       |       |       |       |        |        |          |          |
| French language share (%)             | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Protestant share (%)                  | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| **Absinthe industry**                 |    |        |       |       |       |       |        |        |          |          |
| Absinthe industry share (%)           | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Absinthe-producer indicator           | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | 1.00     | 0.00     |
| **Demographic**                       |    |        |       |       |       |       |        |        |          |          |
| Log population density                | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
| Population (1900, thousands)          | 25 | [.]    | [.]   | [.]   | [.]   | [.]   | [.]    | [.]    | [.]      | [.]      |
```

**Stats columns:** N, Mean, SD, p50 (median), Min, Max for overall; Mean only for the 4 subgroup columns.

**Stata code structure** (using `estpost tabstat` + `esttab`):

```stata
local sumstats "Y1 pct_yes_67 pct_yes_69 pet_per_eligible turnout_68 X1 X2_share X3_share cov1 cov3 cov2_total_share abs_producer ln_density pop_1900"

* Overall stats: N, Mean, SD, p50, Min, Max
eststo overall: estpost tabstat `sumstats', statistics(count mean sd p50 min max) columns(statistics)

* Subgroup means
eststo french:   estpost tabstat `sumstats' if cov1 > 50,         statistics(mean) columns(statistics)
eststo german:   estpost tabstat `sumstats' if cov1 <= 50,        statistics(mean) columns(statistics)
eststo producer: estpost tabstat `sumstats' if abs_producer == 1, statistics(mean) columns(statistics)
eststo nonprod:  estpost tabstat `sumstats' if abs_producer == 0, statistics(mean) columns(statistics)

esttab overall french german producer nonprod ///
    using "$WorkshopTables/T1_summary_stats.tex", replace booktabs ///
    cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) p50(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    mtitles("Overall" "French" "German" "Producer" "Non-prod.") ///
    nonumber noobs ///
    title("Descriptive statistics: 1908 cohort (N=25 cantons)") ///
    coeflabels(Y1 "Yes-vote, Vote #68 (absinthe ban)" ///
               pct_yes_67 "Yes-vote, Vote #67 (commerce)" ///
               pct_yes_69 "Yes-vote, Vote #69 (water power)" ///
               pet_per_eligible "Petition signatures per 100 eligible" ///
               turnout_68 "Turnout, Vote #68" ///
               X1 "Wine area per 1,000 pop. (ha)" ///
               X2_share "Wine volume, national share (\%)" ///
               X3_share "Wine revenue, national share (\%)" ///
               cov1 "French language share (\%)" ///
               cov3 "Protestant share (\%)" ///
               cov2_total_share "Absinthe industry share (\%)" ///
               abs_producer "Absinthe-producer indicator" ///
               ln_density "Log population density" ///
               pop_1900 "Population (1900)") ///
    addnote("French = cantons with French language share > 50\%; Producer = canton has any Milliet-listed absinthe purchases.")
```

#### Part B: Canton industrial composition (sub-table or separate small table)

Format as a separate table OR an inset block within Table 1:

```markdown
**Canton industrial composition, 1907**

| Category                       | N  | Cantons                                                  |
|--------------------------------|---:|----------------------------------------------------------|
| Wine AND absinthe producers    |  7 | NE, GE, BS, VD, SZ, FR, VS                               |
| Wine only                      | 13 | ZH, BE, LU, GL, SO, BL, SH, AR, SG, GR, AG, TG, TI       |
| Absinthe only                  |  1 | ZG                                                       |
| Neither                        |  4 | UR, OW, NW, AI                                           |
| **Total**                      | **25** |                                                      |
```

**Stata code:**

```stata
* Stata-side derivation
gen byte wine_producer = (X1_share > 0 & !missing(X1_share))
gen byte category = .
replace category = 1 if wine_producer == 1 & abs_producer == 1
replace category = 2 if wine_producer == 1 & abs_producer == 0
replace category = 3 if wine_producer == 0 & abs_producer == 1
replace category = 4 if wine_producer == 0 & abs_producer == 0
label define cat_lbl 1 "Wine AND absinthe" 2 "Wine only" 3 "Absinthe only" 4 "Neither"
label values category cat_lbl

* Generate the table — use `levelsof` + file write to a .tex fragment
* (esttab doesn't naturally do this; hand-roll the LaTeX)
file open f using "$WorkshopTables/T1_canton_composition.tex", write replace
file write f "\begin{tabular}{lcl}" _n
file write f "\toprule" _n
file write f "Category & N & Cantons \\" _n
file write f "\midrule" _n
forvalues c = 1/4 {
    local lbl : label cat_lbl `c'
    qui count if category == `c'
    local n = r(N)
    qui levelsof canton_iso if category == `c', local(cl) clean
    file write f "`lbl' & `n' & `cl' \\" _n
}
file write f "\midrule" _n
file write f "Total & 25 & \\" _n
file write f "\bottomrule" _n
file write f "\end{tabular}" _n
file close f
```

---

### Table 2 — Vote regression cascade (X3_share + X2_share, two panels)

**Script:** `10_canton_reg1_tables_workshop.do`

```markdown
| Wine measure                                                            | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |
|-------------------------------------------------------------------------|-------------:|------------:|--------------:|----------------:|--------------------:|
| **Panel A: Wine revenue, national share**                               |              |             |               |                 |                     |
| Wine revenue, national share (Fractional logit AME)                     | [.]          | [.]         | [.]           | [.]             | [.]                 |
|                                                                         | ([.])        | ([.])       | ([.])         | ([.])           | ([.])               |
| Wine revenue, national share (OLS HC3)                                  | [.]          | [.]         | [.]           | [.]             | [.]                 |
|                                                                         | ([.])        | ([.])       | ([.])         | ([.])           | ([.])               |
| French language share                                                   |              | [.]         | [.]           | [.]             | [.]                 |
| Absinthe industry share                                                 |              |             | [.]           | [.]             | [.]                 |
| Protestant share                                                        |              |             |               | [.]             | [.]                 |
| Log population density                                                  |              |             |               |                 | [.]                 |
| N                                                                       | 25           | 25          | 25            | 25              | 25                  |
| R² (OLS)                                                                | [.]          | [.]         | [.]           | [.]             | [.]                 |
| Pseudo R² (FL)                                                          | [.]          | [.]         | [.]           | [.]             | [.]                 |
|                                                                         |              |             |               |                 |                     |
| **Panel B: Wine volume, national share**                                |              |             |               |                 |                     |
| Wine volume, national share (Fractional logit AME)                      | [.]          | [.]         | [.]           | [.]             | [.]                 |
|                                                                         | ([.])        | ([.])       | ([.])         | ([.])           | ([.])               |
| Wine volume, national share (OLS HC3)                                   | [.]          | [.]         | [.]           | [.]             | [.]                 |
|                                                                         | ([.])        | ([.])       | ([.])         | ([.])           | ([.])               |
| French language share                                                   |              | [.]         | [.]           | [.]             | [.]                 |
| Absinthe industry share                                                 |              |             | [.]           | [.]             | [.]                 |
| Protestant share                                                        |              |             |               | [.]             | [.]                 |
| Log population density                                                  |              |             |               |                 | [.]                 |
| N                                                                       | 25           | 25          | 25            | 25              | 25                  |
| R² (OLS)                                                                | [.]          | [.]         | [.]           | [.]             | [.]                 |
| Pseudo R² (FL)                                                          | [.]          | [.]         | [.]           | [.]             | [.]                 |
```

**Source:** `estimates/ols_3_{1-5}.ster` + `estimates_fraclogit/fl_me_3_{1-5}.ster` (Panel A); `ols_2_{1-5}.ster` + `fl_me_2_{1-5}.ster` (Panel B).

**Strategy in esttab:** Build as two separate esttab tables and concatenate via LaTeX `\input` in the Overleaf document. Or use one esttab with stacked-column layout if package supports it. Whichever is simpler to maintain.

**Output filenames:** `T2_vote_cascade_X3.tex`, `T2_vote_cascade_X2.tex`, OR one consolidated `T2_vote_cascade.tex`.

**Verification:** Confirm all 10 cells (5 cols × 2 panels) use N=25 — no observations dropped.

---

### Table 3 — Vote horse race at col 5 (X1, X2_share, X3_share)

**Script:** `10_canton_reg1_tables_workshop.do`

```markdown
|                                            | (1) Per-cap        | (2) Volume share   | (3) Revenue share  |
|--------------------------------------------|-------------------:|-------------------:|-------------------:|
| **Panel A: Fractional Logit AME**          |                    |                    |                    |
| Wine treatment                             | [.]                | [.]                | [.]                |
|                                            | ([.])              | ([.])              | ([.])              |
| **Panel B: OLS HC3**                       |                    |                    |                    |
| Wine treatment                             | [.]                | [.]                | [.]                |
|                                            | ([.])              | ([.])              | ([.])              |
| **Controls (col 5 spec)**                  |                    |                    |                    |
| French language share                      | [.]                | [.]                | [.]                |
| Absinthe industry share                    | [.]                | [.]                | [.]                |
| Protestant share                           | [.]                | [.]                | [.]                |
| Log population density                     | [.]                | [.]                | [.]                |
| N                                          | 25                 | 25                 | 25                 |
| R² (OLS)                                   | [.]                | [.]                | [.]                |
```

**Verification:** ALL three columns must have N=25. If any column drops to fewer observations (e.g., per-cap collapsing structural zeros), flag immediately — this is a sample-coverage failure not just a result.

**Output filename:** `T3_vote_horserace.tex`

---

### Table 4 — Petition regression cascade (X3_share + X2_share, two panels)

**Script:** `13_canton_petition_tables_workshop.do`

Identical structure to Table 2 but Y = `pet_per_eligible`. Two panels (Wine revenue national share + Wine volume national share).

**Source:** `estimates_petition_workshop/ols_pet_3_{1-5}.ster` + FL parallel; same for spec 2.

**Output filename:** `T4_petition_cascade.tex` (or split into two)

---

### Table 5 — R4 mechanism interaction (X2_share + X3_share, two panels)

**Script:** `11_canton_robustness_tables_workshop.do`

```markdown
| Wine measure                          | (1) M1A col 5  | (2) + interaction |
|---------------------------------------|---------------:|------------------:|
| **Panel A: Wine volume, national share** |             |                   |
| Wine volume, national share           | [.]            | [.]               |
|                                       | ([.])          | ([.])             |
| French language share                 | [.]            | [.]               |
| Absinthe-producer indicator           |                | [.]               |
| French × Absinthe-producer            |                | [.]               |
| Absinthe industry share               | [.]            | [.]               |
| Protestant share                      | [.]            | [.]               |
| Log population density                | [.]            | [.]               |
| N                                     | 25             | 25                |
| R²                                    | [.]            | [.]               |
|                                       |                |                   |
| **Panel B: Wine revenue, national share** |             |                   |
| Wine revenue, national share          | [.]            | [.]               |
|                                       | ([.])          | ([.])             |
| French language share                 | [.]            | [.]               |
| Absinthe-producer indicator           |                | [.]               |
| French × Absinthe-producer            |                | [.]               |
| Absinthe industry share               | [.]            | [.]               |
| Protestant share                      | [.]            | [.]               |
| Log population density                | [.]            | [.]               |
| N                                     | 25             | 25                |
| R²                                    | [.]            | [.]               |

**Conditional means (vs. German non-producer baseline, Panel B = X3_share):**
- French non-producer: Δ = − [.] (French language share alone)
- German producer:    Δ = + [.] (Absinthe-producer indicator alone)
- French producer:    Δ =   [.] (cov1 + abs_producer + fr_x_producer combined)
```

**Note:** PI's instruction was "both revenue and yield share" but yield (X4 = hl/ha) is not naturally a share and was not used as an R4 regressor previously. The most natural reading is X2_share (volume) + X3_share (revenue). Confirm with PI if a different pairing was intended.

**Sources:**
- Panel A col 1: `estimates/ols_2_5.ster` (existing primary)
- Panel A col 2: `estimates_robust/r4_fr_x_prod.ster` (existing R4)
- Panel B col 1: `estimates/ols_3_5.ster` (existing primary)
- Panel B col 2: `estimates_robust/r4b_fr_x_prod_x3.ster` (NEW — see Phase 2 above)

**Output filename:** `T5_R4_mechanism.tex`

---

### Table 6 — French-German turnout gap collapse (T25)

**Script:** `11_canton_robustness_tables_workshop.do`

Already-built `.tex` file: `analysis/results/tables/t25_lang_turnout_gap.tex` (source: `05_expansion.do` §12.15).

**Action:**
1. Copy to `$WorkshopTables/T6_turnout_gap_collapse.tex` (rename for workshop numbering)
2. Generate markdown twin via the same csv→md helper as the rest of the pipeline
3. Reformat the title to use display labels consistent with the rest of the workshop tables

**Output filename:** `T6_turnout_gap_collapse.tex`

**Markdown:**

```markdown
|                                                                  | French (N=5) | German (N=20) | Gap (Fr−Ge)  |
|------------------------------------------------------------------|-------------:|--------------:|-------------:|
| Baseline turnout (median across 14 placebo votes 1907–1910)      | 44.40        | 56.62         | **−12.22**   |
| Vote #68 turnout (5 July 1908, absinthe ban)                     | 47.92        | 48.02         | **−0.11**    |
| Change (gap collapse, row 2 minus row 1)                         | **+3.52**    | **−8.60**     | **+12.12**   |
```

---

### Table 7 (Appendix) — Consolidated robustness

Per strategist directive: leave as the existing `_md/robust/canton_robustness_summary.md` (generated by 11_canton_robustness_tables.do). No new build for workshop; appendix reference only.

If you want to copy the existing `.tex` files (canton_robustness_fraclogit_vs_ols.tex + canton_robustness_r1_r6.tex) to the Workshop_draft folder for Overleaf inclusion, do so without modification.

---

### Table 8 — Cross-referendum #67/#68/#69

**Script:** `15_workshop_cross_referendum.do`

```markdown
|                                              | (1) Vote #67 (commerce) | (2) Vote #68 (absinthe ban) | (3) Vote #69 (water power) |
|----------------------------------------------|-------------------------:|---------------------------:|---------------------------:|
| **Panel A: OLS HC3**                         |                          |                            |                            |
| Wine revenue, national share                 | [.]                      | [.]                        | [.]                        |
|                                              | ([.])                    | ([.])                      | ([.])                      |
| **Panel B: Fractional Logit AME**            |                          |                            |                            |
| Wine revenue, national share                 | [.]                      | [.]                        | [.]                        |
|                                              | ([.])                    | ([.])                      | ([.])                      |
| **Controls (col 5 spec)**                    |                          |                            |                            |
| French language share                        | [.]                      | [.]                        | [.]                        |
| Absinthe industry share                      | [.]                      | [.]                        | [.]                        |
| Protestant share                             | [.]                      | [.]                        | [.]                        |
| Log population density                       | [.]                      | [.]                        | [.]                        |
| N                                            | 25                       | 25                         | 25                         |
| R² (OLS) / Pseudo R² (FL)                    | [.] / [.]                | [.] / [.]                  | [.] / [.]                  |
```

**Sources:** `estimates_crossref/crossref_ols_{67,68,69}.ster` + `estimates_crossref/crossref_fl_me_{67,68,69}.ster` (built in Phase 2 above).

**Output filename:** `T8_cross_referendum.tex`

---

## Phase 5 — `16_workshop_figures.do` (figures only)

Per PI directive, figures live in a separate `.do` file so `/run-stata` and other agents can invoke independently.

### Figure 1 — Petition rate vs. Protestant share (monochrome scatter)

```stata
* Load full workshop cohort (canonical source of truth)
use "$MyProject/processed/cohort_1908_workshop.dta", clear

* Language-group classification (already exists in workshop cohort, but defensive)
gen byte lang_group = .
replace lang_group = 1 if inlist(canton_iso, "ZH","BE","LU","UR","SZ","OW","NW","GL","ZG","SO","BS","BL","SH","AR","AI","SG","GR","AG","TG")
replace lang_group = 2 if inlist(canton_iso, "FR","VD","NE","GE","VS","JU")
replace lang_group = 3 if canton_iso == "TI"
label define lang_lbl 1 "German" 2 "French" 3 "Italian"
label values lang_group lang_lbl

twoway ///
    (scatter pet_per_eligible cov3 if lang_group==1, ///
        msymbol(circle_hollow) mcolor(black) msize(medium) ///
        mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
    (scatter pet_per_eligible cov3 if lang_group==2, ///
        msymbol(square) mcolor(black) msize(medium) mfcolor(black) ///
        mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
    (scatter pet_per_eligible cov3 if lang_group==3, ///
        msymbol(triangle) mcolor(black) msize(medium) mfcolor(black) ///
        mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
    (lfit pet_per_eligible cov3, lcolor(black) lpattern(solid) lwidth(medium)), ///
    xtitle("Protestant share of Christian population (%)") ///
    ytitle("Petition signatures per 100 eligible voters") ///
    xlabel(0(20)100) ylabel(0(10)50) ///
    legend(order(1 "German" 2 "French" 3 "Italian" 4 "Linear fit") ///
           cols(4) size(vsmall) position(6) region(lwidth(none))) ///
    graphregion(color(white)) bgcolor(white)

graph export "$WorkshopFigures/F1_petition_protestant.pdf", replace
graph export "$WorkshopFigures/F1_petition_protestant.png", replace width(2000)
```

**Symbol scheme:**
- German: open circle (`msymbol(circle_hollow)`)
- French: filled square (`msymbol(square)` + `mfcolor(black)`)
- Italian: filled triangle (`msymbol(triangle)` + `mfcolor(black)`)
- All markers black; linear fit solid black line

### Figure 2 — Vote and petition rates by canton, grouped by language cluster

```stata
* Set Stata x-axis sort order by language cluster, alphabetical within
gen byte sort_order = .
local i = 0
* German cantons (alphabetical)
foreach c in AG AI AR BE BL BS GL GR LU NW OW SG SH SO SZ TG UR ZG ZH {
    local i = `i' + 1
    replace sort_order = `i' if canton_iso == "`c'"
}
* French cantons (alphabetical)
foreach c in FR GE NE VD VS {
    local i = `i' + 1
    replace sort_order = `i' if canton_iso == "`c'"
}
* Italian
foreach c in TI {
    local i = `i' + 1
    replace sort_order = `i' if canton_iso == "`c'"
}

* Graph bar with side-by-side bars per canton
graph bar (asis) Y1 pet_per_eligible, ///
    over(canton_iso, sort(sort_order) label(angle(45) labsize(vsmall))) ///
    bar(1, color(gs6) fcolor(gs6)) ///
    bar(2, color(black) fcolor(black) fintensity(50) lpattern(solid)) ///
    legend(order(1 "Yes-vote, Vote #68 (%)" 2 "Petition signatures per 100 eligible (%)") ///
           cols(2) size(vsmall) position(6) region(lwidth(none))) ///
    ytitle("Percent") ylabel(0(20)100) ///
    note("Cantons grouped by language cluster (German | French | Italian).", size(vsmall)) ///
    graphregion(color(white)) bgcolor(white)

graph export "$WorkshopFigures/F2_canton_bars.pdf", replace
graph export "$WorkshopFigures/F2_canton_bars.png", replace width(2400)
```

**Bar shading:** vote = solid medium gray; petition = solid black with reduced fill intensity (50%). Adjust if monochrome reproduction renders the two bars too similar.

---

## Phase 6 — `17_workshop_assemble.do` (master MD assembly)

Generate `$MyProject/results/tables/_md/workshop/canton_workshop_summary.md` assembling all 8 tables and figure references in paper presentation order:

```markdown
# Canton workshop draft — comprehensive summary

**Generated:** 2026-05-21 (workshop draft pipeline)
**Order:** As tables/figures appear in Paper 1 draft 1.

---

## Table 1 — Descriptive statistics

[T1 markdown content]

### Canton industrial composition

[T1 sub-table markdown]

---

## Table 2 — Vote regression cascade (X3, X2)

[T2 markdown]

---

## Table 3 — Vote horse race at col 5

[T3 markdown]

---

## Table 4 — Petition regression cascade

[T4 markdown]

---

## Table 5 — R4 mechanism interaction

[T5 markdown]

---

## Table 6 — French-German turnout gap collapse

[T6 markdown]

---

## Figure 1 — Petition rate vs. Protestant share

[F1 path + description]

---

## Figure 2 — Vote and petition rates by canton

[F2 path + description]

---

## Table 7 (Appendix) — Consolidated robustness

[Pointer to existing `_md/robust/canton_robustness_summary.md`]

---

## Table 8 — Cross-referendum #67/#68/#69

[T8 markdown]
```

---

## Phase 7 — `18_workshop_replication_strip.do` (regenerable strip)

### Design principle (strict)

**The FULL workshop cohort (`cohort_1908_workshop.dta`) is the canonical source of truth.** All workshop regression scripts (09, 12, 10, 11, 13 workshop variants), summary stats (14), cross-referendum (15), and figures (16) consume the FULL cohort.

**The STRIPPED cohort (`cohort_1908_workshop_replication.dta`) is a pure derivative**, generated exclusively by re-running `18_workshop_replication_strip.do`. It exists only for journal-package distribution and external-replication purposes — nothing in the project's analysis pipeline reads it.

**Rules for the stripped cohort:**

1. The stripped cohort is built by loading the full cohort and applying a single `keep` statement.
2. To strip MORE aggressively (drop more variables) OR LESS aggressively (drop fewer), edit the keep list at the top of `18_workshop_replication_strip.do` and re-run. **DO NOT manually edit the stripped `.dta`.**
3. The full cohort is never modified by this script — read-only consumer.
4. Re-running 18 always overwrites the stripped cohort with the current keep-list result; previous strips are not preserved.
5. The verification step (below) ensures the stripped cohort produces byte-identical regression results to the full cohort for every workshop spec — this is a binding constraint on what can be dropped.

### Script structure

```stata
/*==============================================================================
 18_workshop_replication_strip.do
 Purpose:  Generate the stripped replication cohort from the full workshop
           cohort.  This is a pure regenerable derivative — to adjust the
           strip, edit the KEEP_LIST below and re-run.  Do not hand-edit the
           output .dta.

 Input:    $MyProject/processed/cohort_1908_workshop.dta
 Output:   $MyProject/processed/cohort_1908_workshop_replication.dta
==============================================================================*/

version 19

* Standalone preamble omitted for brevity — pattern matches other scripts

**# 1. The KEEP LIST — single point of editing for strip aggressiveness
*------------------------------------------------------------------------------*
* To strip MORE: remove a variable from this list and re-run.
* To strip LESS: add a variable to this list and re-run.
* Verification (§3 below) will confirm the resulting strip still produces
* byte-identical workshop regression results.

local KEEP_LIST ""

* --- IDs ---
local KEEP_LIST `KEEP_LIST' canton_iso

* --- Workshop regression outcomes ---
local KEEP_LIST `KEEP_LIST' Y1 pct_yes_67 pct_yes_69 pet_per_eligible turnout_68

* --- Workshop wine regressors ---
local KEEP_LIST `KEEP_LIST' X1 X2_share X3_share

* --- Workshop cultural covariates ---
local KEEP_LIST `KEEP_LIST' cov1 cov3

* --- Workshop absinthe + interactions ---
local KEEP_LIST `KEEP_LIST' cov2_total_share abs_producer fr_x_producer

* --- Workshop geographic + demographic ---
local KEEP_LIST `KEEP_LIST' ln_density pop_1900

* --- Petition raw counts (for re-derivation transparency) ---
local KEEP_LIST `KEEP_LIST' pet_total pet_valid pet_invalid eligible_1906

* --- Cross-referendum parity (forward-looking, low cost) ---
local KEEP_LIST `KEEP_LIST' turnout_67 turnout_69 eligible_67 eligible_69
local KEEP_LIST `KEEP_LIST' yes_count_68 no_count_68 total_votes_68 eligible_68

* --- Geographic flexibility (recovers cov_land, ln_pop, density alts) ---
local KEEP_LIST `KEEP_LIST' canton_area_km2 pop_density_1900

* --- Add additional variables here as needed for forward-looking robustness ---


**# 2. Load full cohort, apply keep, save stripped
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/cohort_1908_workshop.dta", clear

    local N_FULL = c(N)
    local K_FULL = c(k)

    keep `KEEP_LIST'

    local N_STRIP = c(N)
    local K_STRIP = c(k)

    di as text _newline "  Strip applied:"
    di as text "    Observations: " `N_FULL' " (full) -> " `N_STRIP' " (strip)"
    di as text "    Variables:    " `K_FULL' " (full) -> " `K_STRIP' " (strip)"

    assert `N_FULL' == `N_STRIP'

    compress
    save "$MyProject/processed/cohort_1908_workshop_replication.dta", replace
    di as text "  Saved: cohort_1908_workshop_replication.dta"
}


**# 3. Verification: stripped cohort produces identical regression results
*------------------------------------------------------------------------------*
* Sentinel regressions: if any one of these diverges between full and strip,
* the strip is over-aggressive and the keep list needs an addition.
{
    local SENTINELS ""
    local SENTINELS `SENTINELS' "Y1 X3_share cov1 cov2_total_share cov3 ln_density"
    local SENTINELS `SENTINELS' "pet_per_eligible X3_share cov1 cov2_total_share cov3 ln_density"
    local SENTINELS `SENTINELS' "Y1 X2_share cov1 abs_producer fr_x_producer cov2_total_share cov3 ln_density"
    local SENTINELS `SENTINELS' "pct_yes_67 X3_share cov1 cov2_total_share cov3 ln_density"

    foreach spec of local SENTINELS {
        * Run on FULL cohort
        use "$MyProject/processed/cohort_1908_workshop.dta", clear
        qui regress `spec', vce(hc3)
        local b_full = _b[`: word 2 of `spec'']
        local se_full = _se[`: word 2 of `spec'']

        * Run on STRIPPED cohort
        use "$MyProject/processed/cohort_1908_workshop_replication.dta", clear
        qui regress `spec', vce(hc3)
        local b_strip = _b[`: word 2 of `spec'']
        local se_strip = _se[`: word 2 of `spec'']

        * Tolerance: 1e-12 for byte-identical; widen if needed
        if (abs(`b_full' - `b_strip') > 1e-12) | (abs(`se_full' - `se_strip') > 1e-12) {
            di as error "  DIVERGENCE on spec [`spec']:"
            di as error "    Full:  b=" %12.8f `b_full' ", se=" %12.8f `se_full'
            di as error "    Strip: b=" %12.8f `b_strip' ", se=" %12.8f `se_strip'
            di as error "  ACTION: add variable(s) to KEEP_LIST or investigate."
            error 9
        }
        else {
            di as text "  OK: spec [`spec'] identical between full and strip"
        }
    }

    di as text _newline "  All sentinels verified — strip is regression-equivalent to full."
}
```

### Workflow for adjusting the strip later

1. Edit the `KEEP_LIST` block in `18_workshop_replication_strip.do`
2. Re-run `18_workshop_replication_strip.do`
3. Verification step automatically confirms regression-equivalence; if any sentinel diverges, the script errors and tells you to add a variable back

The full cohort `cohort_1908_workshop.dta` is NEVER touched by this workflow. Always rebuildable by re-running `08_workshop` → `09_workshop`.

### Verification at the strip level (binding constraint)

Stripped cohort must produce byte-identical β and SE for every workshop regression spec (Tables 2–5 + 8). The `§3 Verification` block above runs sentinel regressions and asserts identity within 1e-12. If any sentinel fails, the strip is over-aggressive and the keep list must be expanded.

---

## Output routing summary

| Output type | Location | Existing or new dir? |
|---|---|---|
| LaTeX tables (workshop) | `C:\Users\jensenn\Dropbox\Apps\Overleaf\Absinthe Switzerland Draft 1\Tables\Workshop_draft\` | EXISTS (PI-curated Overleaf folder) |
| Figures (workshop) | `C:\Users\jensenn\Dropbox\Apps\Overleaf\Absinthe Switzerland Draft 1\Figures\` | EXISTS |
| `.ster` files (new) | `$MyProject/results/intermediate/estimates_crossref/` + `estimates_petition_workshop/` | NEW dirs (create via `cap mkdir`) |
| Markdown twins | `$MyProject/results/tables/_md/workshop/` | NEW subdir |
| Workshop full cohort (canonical source of truth) | `$MyProject/processed/cohort_1908_workshop.dta` | NEW (written by 08_workshop, OVERWRITTEN with augmented version by 09_workshop) |
| Workshop replication cohort (stripped subset) | `$MyProject/processed/cohort_1908_workshop_replication.dta` | NEW (built from full by 18_workshop_strip via editable keep list) |

**DO NOT touch:**
- `$MyProject/processed/cohort_1908.dta` (original)
- `$MyProject/results/tables/_md/all_tables_summary.md`
- `$MyProject/results/tables/_md/robust/canton_robustness_summary.md`
- `$MyProject/results/tables/_md/petition/canton_petition_summary.md`
- Original 08, 09, 10, 11, 12, 13 `.do` files

---

## Verification checklist (run after all phases complete)

1. **Cohort integrity:** workshop analysis cohort vs. replication cohort produce identical β + SE on at least 3 sentinel regressions (X3_share at col 5 vote, X3_share at col 5 petition, R4 mechanism).
2. **N = 25 throughout:** every regression in Tables 2–5 and 8 has N = 25.
3. **No overwrite of existing masters:** mtime check on `all_tables_summary.md`, `canton_robustness_summary.md`, `canton_petition_summary.md`.
4. **Table outputs present:** all 8 `.tex` files exist in `$WorkshopTables/`.
5. **Figure outputs present:** both `.pdf` and `.png` for F1 and F2 in `$WorkshopFigures/`.
6. **Workshop master MD exists:** `_md/workshop/canton_workshop_summary.md` with all 8 tables + 2 figure references in order.
7. **Labels readable:** open one `.tex` file, confirm variable labels (e.g., "Wine revenue, national share") not raw Stata names (e.g., "X3_share").
8. **Density swap consistent:** `ln_density` present in workshop cohort; `cov_land` and `ln_pop_1900` NOT in col 5 controls of workshop specs.
9. **Hard rules:** any flagged conflicts addressed or escalated.

---

## Reporting requirements (coder writes back)

In your completion message, report:

1. File paths for all created scripts (`08_workshop`, ..., `18_workshop_strip`).
2. File paths for all generated `.tex`, `.pdf`, `.png`, `.md` outputs.
3. File paths for all `.dta` cohort versions.
4. Sentinel numbers from Tables 2, 4, 5, 8 (β + SE for the X3_share coefficient in each at col 5).
5. Canton industrial composition counts (confirm 7 / 13 / 1 / 4 split).
6. Confirmation that all sample sizes are N = 25.
7. Confirmation that existing pipeline masters are untouched (mtime unchanged).
8. Any rule conflicts flagged + recommended resolution.
9. Any places where the dispatch was ambiguous and the coder made a judgment call — flag these for strategist review (e.g., the "yield share" interpretation in Table 5).
10. Estimated wallclock used per phase.

---

## DO NOT

- Modify the original 08–13 `.do` files.
- Overwrite `cohort_1908.dta`.
- Overwrite any `_md/*_summary.md` master files.
- Run RI 10k, Romano-Wolf, Oster bounds, or Conley HAC (all deferred to post-workshop).
- Use `priorban` in any regression (tabled).
- Rename any PI variable already in use (X1, X2_num, X3_num, X4, cov1, cov2_*, cov3, etc.).
- Add Bootleggers-and-Baptists framing language to script comments — the framing is in the manuscript prose, not the analysis scripts.
- Use raw Stata variable names in table outputs — every coefficient row must show the human-readable label from the conventions table above.

---

## End of dispatch.

Strategist on standby for clarification or partial-run review. If any phase fails or any judgment call needs adjudication, halt and report rather than proceed.
