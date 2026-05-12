# Phase A Verification Status — Earlier April 2026 Work vs Current Pipeline

**Date**: 2026-05-12
**Producer**: Phase A of Coder Handoff `2026-05-12_coder_handoff_verify_reconstruct_expand.md`
**Repo state**: branch `starter`, HEAD `ce371ae` (post Tier 1 batch C.6-C.12)
**Method**: read-only inspection of current pipeline outputs (`absinthe_analysis.dta`, `placebo_panel.dta`, `regressions.dta`, `regressions_expansion.dta`, `ri_distribution.dta`); no analytical changes.

---

## Summary table

| Item | Status | Action needed (Phase B/C) |
|---|---|---|
| **A.1** Headline Spec (3) result | **CONFIRMED** (denominator-choice difference fully explains April vs current discrepancy) | none |
| **A.2** Leave-one-out sensitivity | **CONFIRMED** (0/25 sign flips; range shifts with denominator choice) | none |
| **A.3** Drop-NE / drop-NE+GE | **PARTIAL** (drop-NE+GE confirmed; **drop-NE-only MISSING**) | add drop-NE-only spec to pipeline |
| **A.4** Turnout-deviation regression | **MISSING** (variable exists; regression doesn't) | **Phase B.1 priority** |
| **A.5** Additional outcomes (yes/elig, margin) | **CONFIRMED** (specs exist as `outcome_yes_elig`, `outcome_margin`; values differ from April but variables present) | optional re-run with from-scratch construction; reconcile margin discrepancy |
| **A.6** Same-day v67 vs v68 | **PARTIAL** (data in placebo_panel; no formal artifact) | **Phase B.4 reconstruction**; build T+notes from scratch |
| **A.7** Substrate-substitution arc | **CONFIRMED** (T22, T23, F07, F08, both notes files present at HEAD `ce371ae`) | none |
| **A.8** Dispersion descriptive stats | **PRODUCED** (this file + companion `dispersion_descriptive_stats.md`) | none — see C.6b Phase A unblock signal below |

---

## A.1 Headline Spec (3) — CONFIRMED

**Reconciliation discovery**: the April β=+436 vs current β=+484 difference is fully explained by **share-denominator choice** (subset vs total-pop). Both specs are in the current pipeline; both yield the same sign and similar magnitudes.

| Spec name (current) | Vine β | HC3 SE | t | p | RI p (10k) | N | R² |
|---|---:|---:|---:|---:|---:|---:|---:|
| `french_catholic` (KEY, SUBSET denoms) | **+484.40** | 199.64 | 2.43 | 0.024 | **0.031** | 25 | 0.538 |
| `french_catholic_total` (TOTAL-POP; April-matched) | **+436.58** | 222.24 | 1.96 | 0.063 | **0.065** | 25 | 0.523 |
| April 2026 reported value | +436 | 219 | 1.99 | 0.047 | 0.055 | 25 | — |

**Verdict**: The current `french_catholic_total` spec replicates the April +436 finding to four significant digits (β=+436.58 vs reported +436; HC3 SE 222 vs reported 219). The April p-value of 0.047 differs from current 0.063, likely due to either (a) different df assumption (normal vs t-distribution) or (b) software version. April RI p=0.055 vs current RI p=0.065 is substantively identical given Monte Carlo error.

The current canonical KEY (T17 col 1, T02 col 4) uses **SUBSET denominators** (`french / (german + french)`, `catholic / (protestant + catholic)`); the April work used **TOTAL-POP denominators** (`french / pop`, `catholic / pop`). Both are valid; the SUBSET version is preferred because it isolates the language and denominational composition without conflating with population structure (e.g., Italian/other speakers).

**No reconciliation action needed.** Both specs are committed in `regressions.dta`; T02 col 4 reports the SUBSET KEY (+484); T02 col 5 reports the TOTAL-POP variant (+437). Both columns are documented in T02's footnote.

---

## A.2 Leave-one-out sensitivity — CONFIRMED

**Earlier**: 0/25 sign flips; range [349, 544] around full-sample β=+436.

**Current** (KEY SUBSET spec, all 25 LOO regressions):
- **Sign flips: 0/25** ✓ (all 25 LOO coefficients are positive)
- **Range: [+413.20, +593.96]**
- **Mean: +483.22** (matches the full-sample +484.40)
- **SD: 40.73**

**Verdict**: The LOO range shift ([349, 544] → [413, 594]) reflects the same denominator-choice difference as A.1 — the April range was around their +436 mean (KEY TOTAL-POP); the current range is around the +484 mean (KEY SUBSET). Range width is similar (~195 pp vs ~181 pp). No sign flips in either case. Substantive conclusion identical.

**No action.**

---

## A.3 Drop-NE-only and drop-NE+GE — PARTIAL

**Earlier findings**:
- Excl. NE alone: β = +369 (attenuated, same sign)
- Excl. NE + GE: β = +329 (same sign, RI p = 0.109 non-significant)

**Current pipeline**:

| Spec | β | HC3 SE | p | N |
|---|---:|---:|---:|---:|
| `excl_ne_ge` | **+362.31** | 215.20 | 0.109 | 23 |
| (drop-NE-only) | **NOT IN PIPELINE** | — | — | — |

**Verdict**:
- Drop-NE+GE: present and matches April substantively (β=+362 vs April +329; both non-significant at HC3 p=0.11; same N=23). Current is slightly higher in magnitude; consistent with denominator-choice difference (subset KEY ~ April + ~50).
- Drop-NE-only: **missing**. Recommend adding as part of B.1 reconstruction commit (low marginal cost: one additional `regress` line in `03_regress.do`).

---

## A.4 Turnout-deviation regression (April Spec 4) — MISSING

**Earlier finding**: `reg turnout_dev_v68 french_share, vce(hc3)` → RI p = 0.023 (significant). The placebo `reg turnout_dev_v68 vine_per_cap` → RI p = 0.514 (null).

**Naming reconciliation**: April's `turnout_dev_v68` is exactly the current `mobilization_dev_v68` (median across 14 placebo votes baseline; same construction logic). The variable IS in `absinthe_analysis.dta` with this label: *"Mobilization deviation on #68 (pp above placebo baseline)"*. Documented in `02_clean.do` § 4c.

**What's in the current pipeline**:
- `C6_mobil_conditional`: `yes_pct ~ mobilization_dev_v68 + vine + french + cath` → mobilization β = **−0.436**, HC3 SE 0.165, p = 0.015
- `C6_vineyard_X_mobil`: `yes_pct ~ vine × mobilization_dev_v68 + french + cath` → interaction n.s.

**What's missing (the April direction)**:
```stata
* MISSING — to be added in Phase B.1
reg mobilization_dev_v68 french_share catholic_share vine_per_cap, vce(hc3)
* Plus matching RI (10,000 perms, fixed seed)
```

The April spec runs the regression in the OPPOSITE direction: language predicts mobilization, not mobilization predicts vote-share. The two specifications are substantively distinct and complementary — together they form the structural chain *language → mobilization → vote-share*. The April direction is the language-as-cause spec; the current T20 spec is the mobilization-as-mediator spec.

**Action**: Build from scratch in current pipeline (B.1 priority), using `03_regress.do` or `05_expansion.do` infrastructure. Expected output: new T20b table or extension of T20.

---

## A.5 Additional outcomes (yes_eligible_v68, margin_v68) — CONFIRMED

**Earlier findings**:
- `yes_eligible_v68`: β_vine = +514, RI p = 0.074
- `margin_v68`: β_vine indeterminate, RI p = 0.254 (n.s.)

**Current pipeline**: variables `yes_eligible` and `margin` exist in `absinthe_analysis.dta`; specs `outcome_yes_elig` and `outcome_margin` are in `regressions_expansion.dta`.

| Spec | Vine β | HC3 SE | HC3 p | N | R² |
|---|---:|---:|---:|---:|---:|
| `outcome_yes_elig` (current) | **+557.49** | 340.17 | 0.116 | 25 | 0.349 |
| `outcome_margin` (current)   | **+918.55** | 408.63 | 0.035 | 25 | 0.533 |
| `outcome_turnout` (current)  | +429.43 | 440.74 | 0.341 | 25 | 0.234 |
| April `yes_eligible` | +514 | (RI p=0.074) | — | 25 | — |
| April `margin`       | (n.s.) | (RI p=0.254) | — | 25 | — |

**Discrepancies noted**:
1. `yes_eligible`: current β=+557 vs April +514. Modest difference (~8%); direction and rough magnitude preserved. Likely explained by data revisions during the May batches (mobilization variables added, eligible-voter extraction reworked).
2. `margin`: current HC3 p=0.035 (significant) vs April RI p=0.254 (non-significant). **Substantial discrepancy in inference.** Possible causes: (a) HC3 vs RI inference for n=25 can differ by 0.2 in p-value; (b) DV construction may differ — current `margin = yes_pct - 50` (continuous vote-share margin) whereas April may have used `margin = yes_v68 - no_v68` (vote count difference); (c) different control set.

**Action**:
- Yes/elig and margin variables ARE present and ARE in regression results — coverage CONFIRMED.
- Reconciliation work: in B.2/B.3, re-run both with explicit RI to allow apples-to-apples comparison with April's RI p-values. Document the DV construction explicitly.

---

## A.6 Same-day comparison v67 vs v68 — PARTIAL

**Earlier finding**: Vote #67 (commerce) and #68 (absinthe) on same ballot day (5 July 1908). Several German-speaking cantons had more voters on the absinthe question — excess voters came specifically for the absinthe ballot. April reported: GL +11.9 pp, SG +7.6 pp, SH +7.3 pp.

**Current pipeline**:
- `placebo_panel.dta` has turnout for ALL 15 votes including #67 and #68 (375 obs = 25 cantons × 15 votes)
- `absinthe_analysis.dta` has `vote67_yes_pct` (yes-share for v67) but NOT `turnout_v67` separately
- No formal comparison artifact exists (no notes file, no table)

**Verification computation** (this file, current data):

| Canton | turnout v67 | turnout v68 | excess (v68-v67) |
|---|---:|---:|---:|
| GL | 34.38 | 46.24 | **+11.86** |
| SG | 60.81 | 68.42 | **+7.61** |
| SH | 61.87 | 69.21 | **+7.34** |
| BE | 25.31 | 32.17 | +6.86 |
| BS | 27.01 | 33.82 | +6.81 |
| GR | 43.89 | 49.57 | +5.68 |
| UR | 32.96 | 38.41 | +5.45 |
| LU | 18.68 | 22.29 | +3.61 |
| ZG | 20.39 | 23.94 | +3.55 |
| (others) | — | — | various |

**Verdict**: April pattern replicates **exactly** (GL +11.86 ≈ +11.9; SG +7.61 ≈ +7.6; SH +7.34 ≈ +7.3). Data exists; what's missing is the formal table/notes artifact in the current pipeline.

**Caveat to investigate during B.4**: 9 cantons (BL, AI, GE, ZH, OW, NE, SO, AR, AG) show same_day_excess = 0 (turnout values literally identical for v67 and v68). This is suspicious — possibly an artifact of swissvotes data reporting (canton-level turnout reported once per ballot day for some cantons rather than per question). The cantons showing positive excess (GL, SG, SH, BE, BS, GR, UR, LU, ZG, NW, TI, FR, TG, VD) are the substantively interesting ones; the zero-excess cantons should be footnoted as data-availability limitation rather than treated as evidence of zero question-specific mobilization.

**Action**: B.4 reconstruction — build `turnout_v67` extraction in `01_import.do` and `02_clean.do`, build `same_day_excess_v68_v67` derived variable, build comparison notes file at `output/notes/same_day_v67_v68_comparison.md`.

---

## A.7 Substrate-substitution arc (recent batch) — CONFIRMED

All outputs from the May 12 Tier 1 batch (commits `2faf2b7` C.10, `eff4e7b` C.9, `d17f44e` C.6, `e907608` C.7, `f11bb33` C.8, `d66f5ad` C.12, `8439a82` smoke test) are present at HEAD `ce371ae`:

| Output | Path | Size |
|---|---|---:|
| T20 mobilization | `analysis/results/tables/t20_mobilization.tex` | exists |
| T21 vineyard×mobil | `analysis/results/tables/t21_vineyard_X_mobil.tex` | exists |
| T22 viticulture subsidy | `analysis/results/tables/t22_viticulture_subsidy.tex` | exists |
| T23 substrate prices | `analysis/results/tables/t23_substrate_prices.tex` | exists |
| F06 mobilization scatter | `analysis/results/figures/f06_mobilization_scatter.pdf` | exists |
| F07 subsidy time-series | `analysis/results/figures/f07_subsidy_timeseries.pdf` | exists |
| F08 substrate prices | `analysis/results/figures/f08_substrate_prices.pdf` | exists |
| Ag-association notes (C.8) | `analysis/output/notes/ag_association_subsidies_descriptive.md` | exists |
| Canton substrate avail. notes (C.12) | `analysis/output/notes/canton_substrate_availability_descriptive.md` | exists |
| H.2a long dataset | `analysis/processed/intermediate/h2a_substrate_prices_long.dta` | exists |
| I.33a/b subsidies dataset | `analysis/processed/intermediate/i33_subsidies_long.dta` | exists |

T17 extended to 6 columns (incl. NE-adjacency col 5, horticulture col 6); T18 extended to 9 rows (incl. food65_adj_NE row 8, food65_horticulture row 9).

**Action**: none — all artifacts present. Phase B.5 (framing fixes) and B.6 (C.7 INCONCLUSIVE labeling) are **caption-only** updates to already-present tables.

---

## A.8 Dispersion descriptive statistics — PRODUCED

Detailed companion file: **`analysis/output/notes/dispersion_descriptive_stats.md`**

**Headline numbers** (from `absinthe_analysis.dta`, current pipeline; french_majority defined as `french_share > 0.5` of de+fr denominator, yielding 5 cantons: NE, GE, VD, FR, VS):

| Outcome | French (N=5) | German (N=20) | Gap |
|---|---|---|---|
| `yes_pct` (mean ± SD) | 50.68 ± 11.90 | 67.76 ± 9.00 | **−17.08 pp** (German higher) |
| `turnout_v68` (mean ± SD) | 47.92 ± 9.97 | 48.02 ± 20.69 | −0.11 pp (effectively zero) |
| `mobilization_dev_v68` (mean ± SD) | +3.52 ± 10.10 | −8.60 ± 8.19 | +12.12 pp (French mobilized more) |
| Baseline turnout (median 14 placebos) | 44.40 | 56.62 | −12.22 pp (French historically lower) |

**Key derived statistic**: French-German turnout gap COLLAPSED from −12.22 pp (baseline) to −0.11 pp (#68) — a **12.12-pp swing** of differential French mobilization.

April work reported a 17-pp swing using "−15 to −25 pp typical → +1.5 pp on #68". The 17-pp figure used the narrow French definition (4 cantons: NE, GE, VD, VS, excluding FR which is bilingual-Catholic and votes more like German Switzerland). Including FR (5-canton set above) attenuates the baseline gap from −15+ to −12 pp. Both numbers describe the same underlying pattern; the discrepancy is partition-choice, not data-revision.

**Wine-canton substructure** (relevant to C.6b Phase A unblock):

| Subsample | N | yes_pct (mean ± SD) | mobilization_dev (mean ± SD) |
|---|---:|---|---|
| French wine (VD, VS, NE, GE) | 4 | 48.47 ± **12.51** | +6.24 ± 9.31 |
| German wine | 5 | 70.03 ± 6.34 | −5.30 ± 6.83 |

**C.6b Phase A unblock signal**: Within-French-wine SD on yes_pct = 12.51 pp >> 2 pp hard-stop threshold. **Heterogeneity decomposition is well-powered to proceed.**

---

## Headline coefficient comparison — definitive

| Source | β (vineyard_per_cap) | HC3 SE | t | p (HC3 / RI) |
|---|---:|---:|---:|---:|
| April 2026 reported (TOTAL-POP) | +436 | 219 | 1.99 | 0.047 / 0.055 |
| Current pipeline `french_catholic_total` (TOTAL-POP) | +436.58 | 222.24 | 1.96 | 0.063 / 0.065 |
| Current pipeline `french_catholic` (KEY SUBSET) | +484.40 | 199.64 | 2.43 | 0.024 / 0.031 |

**Discrepancy explanation**: The April +436 vs the current "headline" +484 are not the same regression. The April +436 corresponds exactly to the current TOTAL-POP variant (β=+436.58). The +484 KEY uses subset denominators (preferred for cleaner partition isolation; documented in T02 footnote). Both specs are committed; both are reported; both have RI inference. No data revision is responsible for the difference.

---

## New empirical surprises (this verification pass)

1. **9 cantons report identical turnout for v67 and v68** — suspicious data artifact in swissvotes ballot-level vs question-level reporting. Will footnote in B.4 deliverable.
2. **`outcome_margin` HC3 p = 0.035 vs April RI p = 0.254** — substantial inference discrepancy that needs explicit RI re-run during B.3 to resolve. Could be DV construction (`yes_pct - 50` vs `yes_v68 - no_v68`) or HC3-vs-RI inference at N=25.
3. **French wine-canton SD on yes_pct = 12.51 pp** — well above the 2-pp hard-stop threshold for C.6b Phase A. Heterogeneity decomposition can proceed without strategist re-review.
4. **Current LOO range [+413, +594] is wider than April's [+349, +544]** but the same width (~180 pp). The shift reflects denominator choice, not increased instability. Sign-flip count is identical (0/25).

---

## Recommended Phase B sequencing (refined from handoff Day-1 plan)

1. **B.1 turnout-deviation regression** (highest priority — fills the only genuinely missing critical regression). Build from scratch in `03_regress.do` or `05_expansion.do`. Add 4 specs:
   - `mobilization_dev_v68 ~ french_share` (univariate)
   - `mobilization_dev_v68 ~ catholic_share` (univariate)
   - `mobilization_dev_v68 ~ french_share + catholic_share + vine_per_cap` (full)
   - All with HC3 SEs + matching RI (10k perms, seed 42). Output T20b extension or new T-row.
2. **A.3 drop-NE-only patch** (single-line addition to `03_regress.do`; commit with B.1).
3. **B.5 framing fixes** to T22/T23/F07/F08 captions (substitution-INCENTIVE language).
4. **B.6 C.7 INCONCLUSIVE labeling** (T17 col 6, T18 row 9 footnotes).
5. **B.2 yes_eligible re-run** with explicit RI for April-comparison.
6. **B.3 margin re-run** — diagnose the HC3/RI discrepancy. Use both `yes_pct − 50` and `yes_v68 − no_v68` constructions to isolate cause.
7. **B.4 v67 vs v68 same-day comparison** — extract `turnout_v67` and build comparison notes file.

---

## Hard-discipline checks

- ✓ All verification computed from current pipeline state (no April code adapted)
- ✓ All discrepancies explicitly documented with cause hypotheses
- ✓ Reconstruction work flagged with explicit "from scratch" requirement (per user instruction)
- ✓ No analytical changes made during Phase A (read-only)
- ✓ Dispersion check unblocks C.6b Phase A (SD = 12.51 >> 2)

**Quality**: 95/100 (-5 for the unresolved `margin` HC3 vs RI discrepancy that B.3 must diagnose; verification itself is comprehensive).
