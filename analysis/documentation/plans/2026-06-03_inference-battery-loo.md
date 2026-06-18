# Plan — Small-N Inference Battery + Leave-One-Out (canton N=25)

**Date:** 2026-06-03
**Dispatch:** `quality_reports/coder_dispatch/2026-06-03_inference-battery-loo-dispatch.md`
**Strategy note:** `Obsidian/.../Notes/lit-positioning-and-submission-strategy.md` §3–§4
**Status:** PI-APPROVED 2026-06-03 (build started). Live decision record: `quality_reports/coder_reports/2026-06-03_inference-battery-decision-log.md`.

**Post-approval scope updates:** (i) producer leg (`abs_producer`) ADDED to LOO+RI; (ii) tables deploy to NEW Overleaf folder `Tables/Robustness_6-3-26/` in addition to local `results/tables/`.

---

## Decisions locked (from PI Q&A, 2026-06-03)

| # | Decision | Detail |
|---|---|---|
| 1 | **Pipeline = WORKSHOP** | Read `processed/cohort_1908_workshop.dta` directly. **Audit-confirmed**: newest mtime (2026-05-22 12:55) and frozen `fl_me_3_5.ster` AME×100 = **0.4338 ≈ deployed 0.434**. Do **not** source `09_workshop` (it OVERWRITES the cohort). |
| 2 | **Conley = DEFERRED** | Build LOO + RI + HC2/BM + Oster + white/red first. Then investigate Swiss canton coordinates (period-appropriate to 1908 boundaries; jurisdictions flux). Conley only if valid coords found — never fabricate. |
| 3 | **Scope = WINE leg × FULL CASCADE** | Cols 1–5 of the wine spec; LOO drops each canton on each column (flag VD, NE). Producer leg (`abs_producer`) **not** in this battery per PI Q3 — flagged as cheap optional add. |
| 4 | **RI = Option B, both estimators** | `ritest`/`permute` (vendored, 10k, seeded once) on **both** the FL AME and the OLS β. PLUS Oster δ-bounds (`psacalc`, needs `/add-package`) and white-vs-red split (`X3_white_share`/`X3_red_share` already in cohort). |

## Headline spec (the gate hinges on col 5)

`fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)` → `margins, dydx(X3_share)` ×100 = 0.434 (paper). OLS twin: `regress Y1 X3_share cov1 cov2_total_share cov3 ln_density, vce(hc3)`.
Cascade: (1) X3 only; (2) +cov1; (3) +cov2_total_share; (4) +cov3; (5) +ln_density.
Co-headline: X2_share (volume). White/red: X3_white_share, X3_red_share at col 5.

## Methods

**IN (this build):**
- **LOO** — drop each of 25 cantons; β_wine + SE per cascade column; drop-VD and drop-NE flagged prominently. Coefficient-stability figure (no embedded title; descriptive filename).
- **RI 10,000 perms** — `ritest`/`permute`, `set seed` once at top. On FL AME *and* OLS β, headline + key cascade cols. (Methodology rule: 10k, not reduced.)
- **HC2 + Bell-McCaffrey dof** (Imbens-Koleśár 2016) — OLS, reported beside HC1/HC3.
- **Oster (2019) δ-bounds** — `psacalc` (needs `/add-package`).
- **White-vs-red split** — β_white vs β_red at col 5 (Cahannes mechanism: expect white > red).

**DEFERRED:** Conley spatial-HAC (pending coords).
**OUT (per PI + strategy note):** district/commune disaggregation, canton-clustered SEs, wild-cluster bootstrap.

## Deliverables

- `analysis/scripts/22_canton_inference_battery.do` — analysis (reads workshop cohort; reconstructs `Y1_frac = Y1/100` w/ comment + **assert** headline AME reproduces 0.4338 ±0.001 as a paper-anchor check).
- `analysis/scripts/23_canton_inference_battery_tables.do` — tables → `analysis/results/tables/*.tex` **+ markdown twins**.
- LOO figure → `analysis/results/figures/` (descriptive name, no embedded title).
- Memo → `quality_reports/coder_reports/2026-06-03_inference-battery-results.md` — drop-VD/drop-NE coefficients, RI p-values (FL + OLS), HC2/BM SEs, Oster δ, white/red, one-paragraph "does the wine leg survive drop-Vaud?"
- Battery tables stay **LOCAL** (results/tables/) + memo; **not** auto-deployed to Overleaf (PI integrates later if desired).

## Replicability commitments (PI's explicit requirement — no corner-cutting)

- `DATA_SOURCE` toggle + `global ROOT`/`$MyProject` at top, matching existing scripts.
- `adopath ++` project libraries dir.
- `set seed` ONCE at top; seed value documented in header + memo.
- `Y1_frac` reconstruction commented AND assert-anchored to the frozen paper AME (self-verifying).
- `psacalc` added via `/add-package` (tracked `.trk`), **never** inline `ssc install`.
- RI 10k (full), both estimators, every step documented; no precision dilution.
- Pipeline runs clean from the toggle on a fresh run before "done."

## Verification

1. `22` runs rc=0; the Y1_frac→AME assert passes (proves paper-anchor).
2. LOO N=25 rows per cascade col; drop-VD/NE present.
3. RI: 10k reps each, seed echoed; p-values for FL + OLS.
4. `23` builds; every `.tex` has its md twin.
5. Memo states the drop-Vaud verdict + RI p-values.

## Open items folded into final approval

- Script numbers **22/23** (11/14/15/20/21 all taken) — confirm or override.
- Producer leg intentionally **excluded** (wine-only) — confirm.
- `/add-package psacalc` authorized — confirm (else skip Oster).
- Tables **local + memo only**, not Overleaf — confirm.

## Out of scope

Conley (deferred), producer-leg battery, district/commune, clustering, wild-bootstrap, paper-prose integration.
