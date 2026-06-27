# Absinthe Ban Replication — Plan

## Context

Replicate from scratch: did Swiss vineyard cantons support the 1908 absinthe ban to protect their wine industry? The naive bivariate correlation is negative (misleading); conditioning on French-language share and Catholic share flips the vineyard coefficient positive. This Simpson's-paradox sign flip is the headline finding.

Code lives in this repo (`$MyProject` = `$Absinthe1`). Raw data stays on Dropbox at `$Absinthe1Data`. We write to `$MyProject/processed/` and `$MyProject/results/` only.

CONTEXT.md content: **approved by user** (see draft below in Appendix A).

---

## Data flow

```
$Absinthe1Data/swissvotes_dataset.csv        ─┐
$Absinthe1Data/translated/I.01_EN.xlsx        │
$Absinthe1Data/translated/B.01a_EN.xlsx       │
$Absinthe1Data/translated/B.01b_EN.xlsx       ├─► [1_process_raw_data.do]
$Absinthe1Data/translated/B.27_EN.xlsx        │      │
$Absinthe1Data/translated/B.32_EN.xlsx       ─┘      ▼
                                          processed/intermediate/
                                            swissvotes_uncleaned.dta  (25 obs)
                                            vineyard_uncleaned.dta    (25 x 5 years)
                                            population_uncleaned.dta  (25 obs)
                                            pop_density_uncleaned.dta (25 obs)
                                            religion_uncleaned.dta    (25 obs)
                                            language_uncleaned.dta    (25 obs)
                                            canton_crosswalk.dta      (25 obs)
                                                     │
                                                     ▼
                                          [2_clean_data.do]
                                                     │
                                                     ▼
                                          processed/absinthe_analysis.dta (25 obs, ~15 vars)
                                                     │
                                                     ▼
                                          [3_regressions.do]
                                                     │
                                                     ▼
                                          results/intermediate/regressions.dta
                                                     │
                                                     ▼
                                          [4_make_tables_figures.do]
                                                     │
                                                     ▼
                                          results/tables/summary_stats.tex
                                          results/tables/ols_main.tex
                                          results/tables/fracreg.tex
                                          results/figures/scatter_raw.pdf
                                          results/figures/scatter_partial.pdf
```

---

## Script 1: `1_process_raw_data.do`

**Purpose**: Import six raw sources from `$Absinthe1Data` and save uncleaned `.dta` snapshots.

**Inputs**: `$Absinthe1Data/swissvotes_dataset.csv`, `$Absinthe1Data/translated/{I.01_EN, B.01a_EN, B.01b_EN, B.27_EN, B.32_EN}.xlsx`

**Outputs**: `$MyProject/processed/intermediate/{swissvotes,vineyard,population,pop_density,religion,language}_uncleaned.dta`, `canton_crosswalk.dta`

**Sections**:
```
**# 0. Setup
**# 1. Import swissvotes
**# 1.1 Filter to vote anr==68
**# 1.2 Reshape canton columns to long (25 rows)
**# 2. Build canton crosswalk
**# 3. Import I.01 vineyard data
**# 3.1 Locate vineyard sub-block
**# 3.2 Parse and reshape (drop range years, keep {1877,1884,1894,1905,1913})
**# 4. Import B.01a population (1900 row)
**# 5. Import B.01b population density (1900 row)
**# 6. Import B.27 religion (1900 Protestant + Catholic)
**# 7. Import B.32 language (1900 German + French)
**# 8. Post-credits
```

**Key variables**: `canton_code` (str2), `yes_pct`, `yes_count`, `no_count`, `vineyard_ha`, `year`, `pop_1900`, `pop_density_1900`, `protestant_1900`, `catholic_1900`, `german_1900`, `french_1900`

**Tricky parts**:
- Swissvotes CSV: semicolon-delimited, UTF-8 BOM. `import delimited` converts hyphens in column names (`zh-japroz`) to underscores (`zh_japroz`). Filter to `anr==68` (one row), then reshape the 25×4 canton columns into 25 long rows. Drop JU columns (all missing for 1908).
- I.01 stacked sub-blocks: import entire sheet as `allstring` (no `firstrow`), locate "vineyard" or "Vineyard" in column A/B, extract that sub-block. Drop year-range rows containing "/". Column C = "BE,JU" → rename to BE; drop column D (BE-only) and column AB (JU-only).
- Canton crosswalk: HSSO column headers are canton names; swissvotes uses 2-letter codes. Build the 25-row crosswalk (col_header → canton_code) in section 2 and save as `.dta`. All HSSO imports then use this crosswalk via merge or programmatic rename.
- BE/JU: In all HSSO files, use the combined BE+JU column as BE. Document in code comment.

---

## Script 2: `2_clean_data.do`

**Purpose**: Merge six uncleaned sources into a single 25-canton analysis dataset. Construct derived variables.

**Inputs**: all `*_uncleaned.dta` files from script 1

**Output**: `$MyProject/processed/absinthe_analysis.dta` (25 obs)

**Sections**:
```
**# 0. Load vote data
**# 1. Merge covariates
**# 1.1 Vineyard (filter to year==1905 before merge)
**# 1.2 Population
**# 1.3 Population density
**# 1.4 Religion
**# 1.5 Language
**# 2. Construct derived variables
**# 2.1 Per-capita and share variables
**# 2.2 Log transforms
**# 2.3 Dummy variables
**# 3. Labels and assertions
**# 4. Save
**# 5. Post-credits
```

**Key derived variables**:
| Variable | Formula | Label |
|---|---|---|
| `vineyard_per_cap` | vineyard_ha / pop_1900 * 1000 | "Vineyard area per 1000 pop. (ha, 1905)" |
| `french_share` | french_1900 / (german_1900 + french_1900) | "French share of Ger.+Fr. speakers (1900)" |
| `catholic_share` | catholic_1900 / (protestant_1900 + catholic_1900) | "Catholic share of Christians (1900)" |
| `ln_pop` | ln(pop_1900) | "Log population (1900)" |
| `yes_frac` | yes_pct / 100 | "Yes-vote share (fractional, 0-1)" |
| `absinthe_dummy` | 1 if canton_code == "NE" | "Absinthe-producing canton" |

**Tricky parts**:
- All merges are 1:1 on `canton_code`. Assert `_merge == 3` after each merge.
- Vineyard file has multiple years — filter to `year == 1905` before merge, assert N==25.
- `french_share` denominator = German + French (not total pop), appropriate because Italian/Romansch speakers are small and orthogonal.
- `catholic_share` denominator = Protestant + Catholic (not total pop), avoids noise from "other" categories.
- Guard all comparisons against missing: `if pop_1900 > 0 & !missing(pop_1900)`.
- `absinthe_dummy`: NE (Val-de-Travers) was the absinthe heartland. Coded conservatively as NE only — can expand to include VD if user requests.
- End with assertion battery: `assert c(N) == 25`, `isid canton_code`, no missing in key vars.

---

## Script 3: `3_regressions.do`

**Purpose**: Estimate OLS and fractional logit models, plus robustness checks. Save all coefficients via regsave.

**Input**: `$MyProject/processed/absinthe_analysis.dta`

**Output**: `$MyProject/results/intermediate/regressions.dta`

**Sections**:
```
**# 0. Load
**# 1. OLS progressive specifications
**# 1.1 Bivariate: yes_pct ~ vineyard_per_cap
**# 1.2 + catholic_share
**# 1.3 + french_share
**# 1.4 + french_share + catholic_share  (KEY)
**# 1.5 + ln_pop
**# 1.6 + absinthe_dummy
**# 2. Fractional logit
**# 2.1 Same progressive specs on yes_frac via fracreg logit
**# 2.2 Average marginal effects (margins, dydx(*) post)
**# 3. Robustness
**# 3.1 Leave-one-out (KEY spec, drop each canton in turn)
**# 3.2 Exclude NE+GE (KEY spec on N=23)
**# 3.3 Randomization inference (10,000 permutations of vineyard_per_cap)
**# 4. Save regression results
**# 5. Post-credits
```

**Specification details**:
- All OLS: `vce(hc3)` (not plain `robust`). HC3 is less biased at N=25.
- Regsave accumulation: first spec uses `replace`, rest use `append`. Label each with `addlabel(spec, "<name>", model, "ols")`.
- Fractional logit: `fracreg logit yes_frac <controls>, vce(robust)` (fracreg doesn't support hc3). Then `margins, dydx(*) post` and regsave the AMEs.
- Leave-one-out: loop over 25 cantons, estimate KEY spec dropping each, save coefficient on `vineyard_per_cap`. Tag with `addlabel(spec, "loo", dropped, "<canton>")`.
- Exclude NE+GE: KEY spec on `canton_code != "NE" & canton_code != "GE"`. Tag `addlabel(spec, "excl_ne_ge")`.
- Randomization inference: permute `vineyard_per_cap` 10,000 times, re-estimate KEY spec, store distribution. Report RI p-value. Use `set seed 42` for reproducibility.

---

## Script 4: `4_make_tables_figures.do`

**Purpose**: Generate LaTeX tables, PDF figures, and assertion checks on key reported numbers.

**Inputs**: `absinthe_analysis.dta`, `regressions.dta`

**Outputs**: `summary_stats.tex`, `ols_main.tex`, `fracreg.tex`, `scatter_raw.pdf`, `scatter_partial.pdf`

**Sections**:
```
**# 0. Setup
**# 1. Summary statistics table
**# 2. OLS regression table
**# 2.1 Format with regsave_tbl (6 columns)
**# 2.2 Clean variable names (clean_vars)
**# 2.3 texsave to LaTeX
**# 3. Fractional logit table
**# 4. Raw scatter: yes_pct vs vineyard_per_cap
**# 5. Partial-residuals scatter (Frisch-Waugh-Lovell)
**# 5.1 Residualize both variables on french_share + catholic_share
**# 5.2 Scatter residuals with canton labels + fit line
**# 6. Sanity-check assertions
**# 7. Post-credits: inventory
```

**Assertion checks** (section 6):
```stata
* Bivariate vineyard coefficient: negative
summ coef if var == "vineyard_per_cap" & spec == "bivariate" & model == "ols", meanonly
assert r(mean) < 0

* Conditional vineyard coefficient (KEY spec): positive, in [300, 600]
summ coef if var == "vineyard_per_cap" & spec == "french_catholic" & model == "ols", meanonly
assert r(mean) > 0
assert inrange(r(mean), 300, 600)

* N = 25 for all OLS specs
summ N if var == "vineyard_per_cap" & model == "ols", meanonly
assert r(mean) == 25
```

**Partial-residuals scatter**: Regress `yes_pct` on `french_share catholic_share`, predict residuals. Regress `vineyard_per_cap` on same, predict residuals. Scatter the two residual vectors. The slope equals the KEY spec coefficient (Frisch-Waugh-Lovell theorem) — this is the visualization that resolves the Simpson's paradox.

---

## Files to modify

| File | Change |
|---|---|
| `CONTEXT.md` | Replace placeholder with approved content (Appendix A) |
| `analysis/run.do` | Uncomment/set `global MyProject "$Absinthe1"`, set `DisableR = 1`, update header comment |
| `analysis/scripts/1_process_raw_data.do` | Replace scaffold with import logic |
| `analysis/scripts/2_clean_data.do` | Replace scaffold with merge/construct logic |
| `analysis/scripts/3_regressions.do` | Replace scaffold with estimation logic |
| `analysis/scripts/4_make_tables_figures.do` | Replace scaffold with table/figure/assert logic |
| `analysis/scripts/programs/clean_vars.ado` | Replace auto.csv mappings with project variables |

---

## Verification

1. After each script: run via `/run-stata` or MCP, read log, confirm no errors.
2. After script 1: verify each `_uncleaned.dta` has expected N (25 for votes/pop/etc., 125 for vineyard 5×25).
3. After script 2: verify `absinthe_analysis.dta` has N=25, all key vars non-missing.
4. After script 3: verify `regressions.dta` exists, bivariate vineyard coef is negative, KEY spec coef is positive.
5. After script 4: verify `.tex` and `.pdf` files exist in `results/`. Assertions pass.
6. Final: `run.do` end-to-end without error. Then `/validate` and `/phase-review`.

---

## Out of scope

- Spatial analysis / maps of Swiss cantons
- Time-series analysis across multiple votes
- IV or matching estimators (OLS + fractional logit only)
- R-based analysis (DisableR = 1)
- Quarto document / paper draft

---

## Appendix A: Approved CONTEXT.md content

_(see earlier draft — all five fields populated, approved by user)_
