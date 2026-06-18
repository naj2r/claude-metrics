# DISPATCH: Census-vintage extraction (1880 + 1888) for year-matched cross-referendum covariates

**From:** coordinator (gallant-thompson) · **Date:** 2026-06-10 · **Independent of all other queue items** — no dependency on the PI's yearbook transcriptions; can run anytime.
**Why:** the cross-referendum battery year-matches covariates per vote (nearest-prior vintage). The 1900 census family is already in the pipeline; **1888 and 1880 are not** — they exist only in the HSSO source xlsx. Gap bites: **#52 (1897) + #38 (1891) → 1888; #30 (1885) + #31 (1887) → 1880.**

## Sources (on disk, Dropbox raw)

`C:\Users\jensenn\Dropbox\research_data_raw\c-metrics-absinthe1\original\` (+ `translated\*_EN.xlsx` mirrors):
- **B.32** — language by canton (series: 1880, 1888, 1900, 1910) → `french_share_1880`, `french_share_1888` (German share as complement check)
- **B.27** — religion (1850…1880, 1888, 1900…) → `protestant_share_1880/1888`, `catholic_share_1880/1888` (audit note: 25/26 coverage on some vintages — record which canton is missing)
- **B.01a/B.01b** — population + density (decennial) → `pop_1880/1888`, `density_1880/1888`
- Optional, same pass: **E.1a** net migration for the 1870/80 and 1880/88 inter-census windows (flagged "extractable" in the audit; LOW priority)

## Deliverable

`analysis/processed/canton_census_vintages_1880_1888.csv` (or fold into the existing covariate build — coder's call, consistent with pipeline conventions): one row per canton × vintage, share variables in [0,1] matching the 1900 vintage's construction EXACTLY (same numerator/denominator definitions, same canton codes as `cohort_1908_workshop.dta`).

## Checks (the usual)

1. **Continuity anchor:** for each canton, 1888 value must sit plausibly between 1880 and 1900 (language/religion shares move slowly; flag any |Δ| > 5 pp between adjacent vintages for visual inspection of the source cell).
2. **1900 reproduction:** re-derive the 1900 shares from the same source files in the same pass and **diff against the pipeline's existing 1900 values** — pipeline-validation anchor (same logic as the canton-wine 1907 anchor).
3. Coverage matrix: canton × vintage presence; document any missing cantons (expected on some early vintages per the audit).
4. Stata-first: numbered `.do` produces the artifact (or documents the xlsx-read step per pipeline convention).

## NOT in scope
No regressions; no merge into vote panels (that's the supplement build, separate dispatch once the PI's yearbook xlsx lands); no farm-structure variables (none exist pre-1905 — documented constraint).
