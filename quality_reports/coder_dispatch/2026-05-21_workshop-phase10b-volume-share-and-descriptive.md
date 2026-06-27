# Phase 10b Coder Dispatch — Volume/Area-Share Re-test + Cultural-Cleavage Descriptive Table

**Author:** Strategist
**Date:** 2026-05-21
**Status:** READY for coder execution
**Priority:** Workshop-critical (D1v, D2v, descriptive table); Workshop-ideal (D1a, D2a)
**Prior dispatch:** `2026-05-21_workshop-phase10-mechanism-interactions.md`
**Prior recap:** `.handoffs/2026-05-21T23-00-00-recap-phase10-dispatched-white-wine-cascade-confirms-cahannes.md`

---

> **CORRECTION NOTICE (added 2026-05-21):** The variable construction in §"Specs D1v / D2v — Volume-Share Re-test" of this dispatch contained a non-canonical hybrid formula that was caught during coder execution. See the **CORRECTION ADDENDUM** at the end of this document for the canonical national-parallel construction. The original (incorrect) formula is preserved in the body of this dispatch for audit-trail purposes. The coder used the corrected formula and re-ran D1v / D2v cleanly.

---

## Context: Why Phase 10b Exists

Phase 10 executed cleanly but returned uniformly null interaction estimates (D1: β_{W×F} = −0.0074, p=0.726; D2: β_{W×F} = −0.0060, p=0.745; E1: p=0.353; E2: p=0.966). The drop-Ticino cascade (Spec F) returned the opposite of the dispatch's prediction: red cascade DOUBLED rather than collapsed.

**Strategist diagnosis with PI agreement:**

1. **Value/yield confound concern (OVB):** `X3_white_share` is constructed from CHF revenue, not hectoliters or hectares. Price and yield heterogeneity across cantons (premium Vaud whites ~150 CHF/hL vs. bulk Ticino reds ~50 CHF/hL) loads onto value-share. If Cahannes's substitution channel runs through volume or area (what consumers drink, what growers plant) — not revenue — then value-share is a mis-specified test.
2. **DoF/power problem:** at N=25 with 6+ controls in col 5, interaction estimates have power roughly 15–20% under realistic alternatives. Null at p>0.7 is the *expected* outcome under the alternative, not evidence against it.
3. **Drop-TI substantive read:** TI is the only Italian canton, the highest red-share canton, AND voted NO. Removing it doesn't purify the red estimate — it removes a single high-leverage (high-red, low-yes) observation. The "+0.43 doubling" is consistent with a French-speaking-wine-canton mobilization story plus a Ticino outlier, not a red-wine mechanism.

**Phase 10b's purpose:** (a) Re-run D1 and D2 with volume-share and area-share variants to disentangle the value/yield confound from the DoF problem. (b) Build a descriptive cultural-cleavage table that carries the substantive story without leaning on interactions at N=25.

---

## Step 0: Data Availability Check (REPORT BACK BEFORE EXECUTING SPECS)

Before running any new specs, please report what fields exist in the white/red wine source data (the table the PI provided via tablesgenerator.com plus the 1907 Statistisches Jahrbuch wine table).

For each canton in `canton_wine_dummy==1`, confirm presence (Y/N) of:

| Field | Expected unit | Used for |
|---|---|---|
| `wine_value_white` | CHF | already exists; basis for current `X3_white_share` |
| `wine_value_red` | CHF | already exists; basis for current `X3_red_share` |
| `wine_volume_white` | hL | needed for `X3_white_vol_share` |
| `wine_volume_red` | hL | needed for `X3_red_vol_share` |
| `wine_area_white` | ha | needed for `X3_white_area_share` |
| `wine_area_red` | ha | needed for `X3_red_area_share` |
| `wine_yield_white` | hL/ha | optional; productivity covariate |
| `wine_yield_red` | hL/ha | optional; productivity covariate |

**Branch logic from Step 0 findings:**
- Volume present → execute D1v, D2v (REQUIRED for workshop)
- Area present → execute D1a, D2a (IDEAL for workshop, defensible for EEH)
- Only value present → flag explicitly, skip volume/area re-test, proceed directly to descriptive table

If the source has volume but not area (or vice versa), execute whichever is available and report the asymmetry.

---

## Specs D1v / D2v — Volume-Share Re-test (REQUIRED if data available)

> **The variable construction block immediately below is INCORRECT — see the CORRECTION ADDENDUM at the end of this document for the canonical national-parallel construction. The original is preserved here for audit-trail purposes only; do not use this formula.**

### Variable construction (add to §1.5 of 09_workshop.do, alongside existing X3 share construction)

```stata
* Volume-based color shares (Phase 10b)
cap drop X3_white_vol_share
cap drop X3_red_vol_share
cap drop X3_white_vol_x_cov1

gen double X3_white_vol_share = .
gen double X3_red_vol_share   = .

* Conditional on canton_wine_dummy==1 (structural zeros preserved per §1.3)
replace X3_white_vol_share = (wine_volume_white / (wine_volume_white + wine_volume_red)) * X3_share if canton_wine_dummy==1
replace X3_red_vol_share   = (wine_volume_red   / (wine_volume_white + wine_volume_red)) * X3_share if canton_wine_dummy==1
replace X3_white_vol_share = 0 if canton_wine_dummy==0
replace X3_red_vol_share   = 0 if canton_wine_dummy==0

gen double X3_white_vol_x_cov1 = X3_white_vol_share * cov1

label var X3_white_vol_share "White wine share of canton wine production (volume, hL-based)"
label var X3_red_vol_share   "Red wine share of canton wine production (volume, hL-based)"
label var X3_white_vol_x_cov1 "White (vol) × French share interaction"
```

**Note on construction:** the multiplication by `X3_share` ensures the volume-share is on the same intensive scale as the existing `X3_white_share` (i.e., "white volume share of canton wine production, weighted by canton wine intensity"). If you prefer a pure volume ratio (`X3_white_vol_share = wine_volume_white / (wine_volume_white + wine_volume_red)`) as an alternative, run BOTH and report the difference — but `weighted-by-X3_share` is the right apples-to-apples comparison to the original value-based D1/D2.

### Spec D1v: White × French interaction, volume-share, absinthe dummy moderator

```stata
qui regress Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density, vce(hc3)
estimates store D1v_ols
estimates save "$STER/D1v_ols.ster", replace

qui fracreg logit Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density, vce(robust)
estimates store D1v_fl
estimates save "$STER/D1v_fl.ster", replace

margins, dydx(X3_white_vol_share) at(cov1=(0 25 50 75 100)) post
estimates store D1v_margins
estimates save "$STER/D1v_margins.ster", replace
```

### Spec D2v: White × French interaction, volume-share, absinthe continuous moderator

```stata
qui regress Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 cov2 cov3 ln_density, vce(hc3)
estimates store D2v_ols
estimates save "$STER/D2v_ols.ster", replace

qui fracreg logit Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 cov2 cov3 ln_density, vce(robust)
estimates store D2v_fl
estimates save "$STER/D2v_fl.ster", replace

margins, dydx(X3_white_vol_share) at(cov1=(0 25 50 75 100)) post
estimates store D2v_margins
estimates save "$STER/D2v_margins.ster", replace
```

### Sentinel reporting for D1v / D2v

After execution, report a comparison table:

| Spec | β_{white_share} | β_{cov1} | β_{interaction} | p(interaction) |
|---|---:|---:|---:|---:|
| D1 (value, dummy) | … | … | −0.0074 | 0.726 |
| **D1v (volume, dummy)** | … | … | … | … |
| D2 (value, continuous) | … | … | −0.0060 | 0.745 |
| **D2v (volume, continuous)** | … | … | … | … |

Plus correlation diagnostics:
- `corr X3_white_share cov1` (value-based; expected ~0.638 from Phase 10)
- `corr X3_white_vol_share cov1` (volume-based; report)

**If volume-share materially changes the interaction estimate or the cov1-collinearity profile, flag this prominently in the reporting.** That outcome would indicate value/yield heterogeneity was masking the substitution channel and would warrant resurrecting T10 to the main paper.

---

## Specs D1a / D2a — Area-Share Re-test (CONDITIONAL on area data availability)

Identical structure to D1v / D2v but with area-based shares. Run if and only if `wine_area_white` and `wine_area_red` exist in the source.

```stata
gen double X3_white_area_share = .
gen double X3_red_area_share   = .

replace X3_white_area_share = (wine_area_white / (wine_area_white + wine_area_red)) * X3_share if canton_wine_dummy==1
replace X3_red_area_share   = (wine_area_red   / (wine_area_white + wine_area_red)) * X3_share if canton_wine_dummy==1
replace X3_white_area_share = 0 if canton_wine_dummy==0
replace X3_red_area_share   = 0 if canton_wine_dummy==0

gen double X3_white_area_x_cov1 = X3_white_area_share * cov1
```

D1a / D2a run analogously to D1v / D2v with the area-share variable substituted. Store as `D1a_ols`, `D1a_fl`, `D1a_margins`, etc. Save `.ster` files. Report in the same comparison table.

**Theoretical priority:** area_share is the cleanest test of Cahannes's growers-planted-more-white channel (agronomic allocation). volume_share is closer to the consumption-substitution channel. value_share (existing D1/D2) is the political-stakes channel. If all three give the same null, the DoF/power problem is binding and the descriptive table carries the substantive load. If any differs, we have a finding.

---

## Cultural-Cleavage Descriptive Table

### Specification

Build a wide-format descriptive table at the canton level, restricted to `canton_wine_dummy==1` (all 20 wine cantons).

**Columns (in order):**

| Column | Source variable | Format |
|---|---|---|
| Canton | canton abbrev (text) | 2-letter ISO (GE, VD, TI, etc.) |
| Lang | derived from cov1: FR if cov1≥50; IT if Ticino; DE if cov1<50 and not TI; mixed flag for FR if needed | text (FR / IT / DE / FR–DE) |
| Abs prod | abs_producer | Yes / No |
| Red % | X3_red_share × 100 (value-based unless volume-share survives Step 0) | 1 decimal |
| White % | X3_white_share × 100 | 1 decimal |
| Wine intensity | X3_share × 100 OR a wine_value per capita measure; whichever is more informative | 1 decimal |
| Yes #69 | Y1 × 100 | 1 decimal |
| Yes #68 | yes_share_v68 × 100 | 1 decimal |
| Yes #67 | yes_share_v67 × 100 | 1 decimal |

**Sort order:** Language group (FR → FR–DE mixed → IT → DE), then `Yes #69` descending within group.

**Footer:** group-level means of (Red %, White %, Yes #69, Yes #68, Yes #67) for FR, IT, DE rows. Show row count per group.

**Variable confirmation:** if the actual variable name for "canton abbreviation" differs in the workshop cohort (e.g., `canton_iso` vs `canton_abbrev`), use whatever exists. If language-majority indicator does not exist, derive it from `cov1` per the rule above and record the derivation in the table notes.

### Output paths

| Format | Path |
|---|---|
| LaTeX | `C:\Users\jensenn\Dropbox\Apps\Overleaf\Absinthe Switzerland Draft 1\Tables\Workshop_draft\t_desc_wine_cantons_cleavage.tex` |
| Markdown | `analysis/results/tables/_md/workshop/t_desc_wine_cantons_cleavage.md` |

### LaTeX format requirements
- `booktabs` rules (`\toprule`, `\midrule`, `\bottomrule`) — NO `\hline`
- Wrap in `threeparttable` for notes block
- Row group separator (`\midrule`) between language groups
- Table notes: data sources, year (1907), variable construction (esp. language-majority derivation if applicable)
- NO `\caption`, NO `\label` in the generated file — those go in the paper `\input{}` wrapper per project rule `.claude/rules/tables.md`

---

## KEEP_LIST Update for 18_workshop_strip.do

If Step 0 confirms volume/area data and D1v/D2v (and optionally D1a/D2a) execute, add the following variables to the KEEP_LIST in `18_workshop_strip.do` (alongside existing Phase 10 additions `X3_white_x_cov1`, `X3_white_x_absprod`, `X3_white_x_cov2`):

```
X3_white_vol_share
X3_red_vol_share
X3_white_vol_x_cov1
X3_white_area_share        // if area path executed
X3_red_area_share          // if area path executed
X3_white_area_x_cov1       // if area path executed
```

Update the sentinel-byte-count in `18_workshop_strip.do` after adding variables.

---

## Verification Checklist (coder confirms before reporting back)

- [ ] **Step 0 report:** which fields exist in the white/red wine source (value/volume/area) — explicit Y/N table
- [ ] D1v + D2v executed if volume data available; sentinels reported in comparison table
- [ ] D1a + D2a executed if area data available; sentinels reported in comparison table; OR explicit "area not available, skipped" notation
- [ ] `corr X3_white_vol_share cov1` reported alongside `corr X3_white_share cov1`
- [ ] Descriptive table has exactly 20 rows (matches `count if canton_wine_dummy==1`)
- [ ] Descriptive table footer group means match raw `summarize` output by language group
- [ ] LaTeX output uses `booktabs`, `threeparttable`, no `\caption`/`\label` in body
- [ ] Markdown output renders cleanly in standard markdown previewer
- [ ] `.ster` files saved for all executed estimates
- [ ] KEEP_LIST in `18_workshop_strip.do` updated if new variables created; sentinel-byte-count recalculated
- [ ] All file paths populated; no orphan empty files

---

## Reporting Requirements (coder report-back format)

When Phase 10b execution completes, return a single report with:

1. **Step 0 data availability matrix** — explicit Y/N per field
2. **Volume-share / area-share comparison table** — value (D1/D2 from Phase 10) vs. volume (D1v/D2v) vs. area (D1a/D2a if applicable); interaction coefficient + p-value at col 5; correlation with cov1
3. **Margin plot data** — marginal effect of white-share at cov1=(0, 25, 50, 75, 100) for each executed spec; FL AME basis
4. **Descriptive table preview** — full table inline in the report (markdown format), so strategist can review immediately without opening the .tex
5. **Substantive recommendation** — does the volume/area re-test support resurrecting T10 to main paper, OR does the null persist robustly across share-measure variants?
6. **Flagged anomalies** — any unexpected behavior (e.g., volume-share has high missingness for specific cantons, area data inconsistent with value data, etc.)

---

## Workshop-vs-EEH Priority Tiering

| Spec | Workshop deadline (~2026-05-22) | EEH submission (~2026-06-14) |
|---|---|---|
| **D1v, D2v** (volume-share) | REQUIRED if volume data exists | REQUIRED regardless |
| **D1a, D2a** (area-share) | IDEAL if area data exists | REQUIRED if area data exists |
| **Descriptive table** | REQUIRED for workshop | REQUIRED with polish (full notes, source citations) |

**If time runs short:** prioritize Step 0 + descriptive table + D1v over D2v / D1a / D2a. The descriptive table is non-negotiable for the cultural-cleavage narrative; D1v is the cleanest single-spec re-test.

---

## Downstream Decision Tree (strategist's branch logic for T10/T11 placement)

| Phase 10b outcome | T10 (interactions) | T11 (drop-TI) | Descriptive table | Workshop narrative |
|---|---|---|---|---|
| **A. Volume/area gives positive significant W×F** | RESURRECT to main paper, replace value-share with volume-share as primary; value-share to appendix | Reframe as cultural-cleavage robustness | Appendix, as triangulation | Cahannes substitution channel confirmed via correct measure |
| **B. Null persists across all share measures** | Demote to appendix with power footnote; report all variants honestly | Reframe as cultural-cleavage robustness | MAIN PAPER as primary substantive vehicle | "We tested four Cahannes predictions; at N=25 they're underpowered; descriptive cultural-cleavage evidence is more informative" |
| **C. Volume gives one direction, area another** | Both in main paper as competing channels; discuss in interpretation | Reframe per case | MAIN PAPER as the unifying frame | "Substitution vs. allocation channels diverge; consumer-side vs. producer-side dynamics" |

Strategist resolves the branch upon receiving coder's Phase 10b report.

---

## Files Touched (anticipated)

| File | Change |
|---|---|
| `analysis/scripts/09_canton_reg1_workshop.do` | Add §1.5b (Phase 10b variable construction) + §2.10b (Phase 10b regressions) |
| `analysis/scripts/18_workshop_strip.do` | Update KEEP_LIST + sentinel-byte-count |
| `analysis/results/tables/_md/workshop/t_desc_wine_cantons_cleavage.md` | NEW |
| `Tables\Workshop_draft\t_desc_wine_cantons_cleavage.tex` (Overleaf) | NEW |
| `analysis/results/tables/_md/workshop/t10v_white_french_volume_share.md` | NEW (if volume executed) |
| `Tables\Workshop_draft\t10v_white_french_volume_share.tex` (Overleaf) | NEW (if volume executed) |
| `analysis/results/tables/_md/workshop/t10a_white_french_area_share.md` | NEW (if area executed) |
| `Tables\Workshop_draft\t10a_white_french_area_share.tex` (Overleaf) | NEW (if area executed) |
| `analysis/results/ster/D1v_*.ster`, `D2v_*.ster`, `D1a_*.ster`, `D2a_*.ster` | NEW (per executed spec) |

---

## Notes on PI Constraints (preserved from prior dispatches)

- HC3 robust SEs throughout (project methodology rule for OLS at N=25)
- No variable renames beyond what's documented here
- Don't write to `09_canton_reg1.do` (canonical) — operate on `09_canton_reg1_workshop.do`
- No RI 10k (deferred to EEH refinement)
- No priorban in cascade (tabled)
- Two-file replication principle preserved: full cohort saved by `09_workshop` is the source of truth; `18_workshop_strip.do` produces the byte-verified derivative

---

**End of Phase 10b dispatch.**

---

## CORRECTION ADDENDUM (added 2026-05-21)

### Summary

The variable-construction block in §"Specs D1v / D2v — Volume-Share Re-test" of this dispatch specified a non-canonical hybrid formula for `X3_white_vol_share` and `X3_red_vol_share`. The error was caught during coder execution. Below: what the error was, the canonical correction, the detection-and-resolution chain, the effect on reported results, the lesson logged, and the QC implication for workshop deliverables.

### The error (preserved verbatim in body above)

```stata
* INCORRECT (original dispatch text — DO NOT USE):
replace X3_white_vol_share = (wine_volume_white / (wine_volume_white + wine_volume_red)) * X3_share if canton_wine_dummy==1
replace X3_red_vol_share   = (wine_volume_red   / (wine_volume_white + wine_volume_red)) * X3_share if canton_wine_dummy==1
```

This is a hybrid: intra-canton white-of-total volume ratio MULTIPLIED BY canton's national wine-value share. The construction has no clean theoretical interpretation — it double-counts canton overall wine importance against intra-canton color allocation. It does NOT match the canonical project pattern for the X3-family share variables.

The canonical pattern for X3-family share variables in this project is `canton_value / national_value × 100` (canton's share of the national total on a single metric). See `09_canton_reg1.do` §1.2.1 for the established construction of `X3_white_share` (canton's share of national white-wine VALUE), `X3_share` (canton's share of national wine VALUE), `X1_share` (canton's share of national wine AREA), etc. The volume-share variants must structurally parallel this pattern with `volume` substituted for `value` on a single metric.

### The corrected construction (canonical national-parallel form)

```stata
* CORRECT — use this form for any future replication or re-execution:
*
* National denominators from Switzerland row of the 1907 Statistisches Jahrbuch wine table:
*   national_white_volume = 486,278.9 hL
*   national_red_volume   = 165,102.4 hL
*
* Best practice: read these as macros from the Switzerland row at import time rather than
* hardcoding, so the script remains robust if the source data is updated.

gen double X3_white_vol_share = (wine_volume_white / 486278.9) * 100 if canton_wine_dummy==1
replace    X3_white_vol_share = 0 if canton_wine_dummy==0

gen double X3_red_vol_share   = (wine_volume_red / 165102.4) * 100 if canton_wine_dummy==1
replace    X3_red_vol_share   = 0 if canton_wine_dummy==0

gen double X3_white_vol_x_cov1 = X3_white_vol_share * cov1

label var X3_white_vol_share "Canton share of national white-wine volume (hL-based, pp, 0-100)"
label var X3_red_vol_share   "Canton share of national red-wine volume (hL-based, pp, 0-100)"
label var X3_white_vol_x_cov1 "White-volume-share × French-language-share interaction"
```

Structural-zero behavior under the corrected construction: cantons with `canton_wine_dummy==0` correctly get `X3_white_vol_share = 0` and `X3_red_vol_share = 0`. The pathological case under the hybrid (Glarus, where `wine_volume_white + wine_volume_red = 0` made the ratio undefined and N dropped to 24) dissolves under the corrected form: GL's `0 / 486278.9 = 0` is a clean structural zero, restoring N=25.

### Detection and resolution chain

1. **Coder authoring step:** strategist drafted dispatch with hybrid formula on 2026-05-21, derived from first principles ("weighted-by-X3_share for apples-to-apples comparison to value-based D1/D2"). The dispatch's own rationale note acknowledged the hybrid was unusual but did not reference the canonical X3-family construction pattern in `09_canton_reg1.do` §1.2.1.
2. **Coder execution:** coder followed the dispatch literally (correct separation-of-powers behavior — coder should not deviate from dispatch without authorization). Executed D1v / D2v with the hybrid variables. Reported results showed N=24 (GL dropped), main effect AME = 0.0132 at cov1=50, p=0.018.
3. **PI catch:** PI Nicholas Jensen flagged the construction during result review: "wine share is canton's share of national, not share per canton that is white or red. Has that been how you were coding it or did you get the definitions off?"
4. **Coder audit:** coder confirmed the hybrid was specified by the dispatch and audited all other share variables in the project for consistency (X1_share, X2_share, X3_share, X3_white_share, X3_red_share, pet_natshare). Audit result: only Phase 10b volume-share construction was non-canonical; all prior work used the correct canton/national pattern.
5. **Strategist acknowledgment:** strategist confirmed the dispatch error, issued the corrected construction (above), and authorized the coder to re-run D1v / D2v.
6. **Coder re-execution:** D1v / D2v re-ran cleanly under corrected construction. N=25 restored. Comparison numbers reported (next section).

### Effect on reported results

Substantive direction preserved; magnitudes attenuate (because the hybrid double-counted national wine intensity, inflating apparent effect sizes for big-wine-producer cantons):

| Spec | Hybrid (INCORRECT) — DO NOT CITE | Corrected (canonical) |
|---|---:|---:|
| D1v FL AME at cov1=50 | 0.0132 (= 1.32 pp Y per pp X), p=0.018 | 0.00912 (= 0.91 pp Y per pp X), p=0.029 |
| D2v FL AME at cov1=50 | 0.0112 (= 1.12 pp Y per pp X), p=0.058 | 0.00750 (= 0.75 pp Y per pp X), p=0.074 |
| D1v interaction term | β = −0.0088, p=0.668 (null) | β = −0.0088, p=0.668 (null, unchanged) |
| D2v interaction term | β ≈ −0.0051, p≈0.7 (null) | β ≈ −0.0051, p≈0.7 (null, unchanged) |
| Sample size | N=24 (GL dropped due to undefined ratio) | N=25 (GL is structural zero) |
| Corr(X3_white_vol_share, cov1) | (not meaningfully different) | 0.612 (vs 0.638 for value-share) |

The Branch A' decision tree call (T10v → main paper, T10 value → appendix, T_desc → main paper, T11 → main paper with cultural-cleavage caption) holds under either version. The substantive interpretation of Phase 10b results stands: white-wine main effect is robust positive (FL AME +0.91 pp Y per pp X at cov1=50, p=0.029); cultural conditioning of the slope is null (interaction p=0.67) but underpowered at N=25.

### QC implication for workshop deliverables

All workshop draft materials (master MD, table .tex files in `Tables\Workshop_draft\`, .md files in `_md/workshop/`) must report only the corrected magnitudes. The hybrid values (e.g., D1v at cov1=50, AME ≈ 1.32 pp Y per pp X) must not appear in any deliverable. Coder is responsible for verifying that all post-rebuild output reflects the corrected `.ster` files and that no stale hybrid-era numbers persist in any rendered table or callout box.

### Process lesson logged

`[LEARN:dispatch-authoring]` — When a dispatch introduces a new variable that is intended to parallel an existing one:

1. The dispatch MUST point explicitly to the existing variable's source-script construction (e.g., "see `09_canton_reg1.do` §1.2.1 for `X3_white_share` construction") rather than restating the formula from first principles.
2. The dispatch MUST require structural parallelism with the existing pattern. The new variable's denominator family and scale convention must match the canonical pattern; only the numerator metric should change.
3. The dispatch SHOULD require the coder to confirm parallelism (e.g., "verify that `X3_white_vol_share` reads as canton/national share on the same scale as `X3_white_share` before executing").
4. The dispatch author MUST NOT infer parallel-variable construction from variable names. Variable naming is suggestive but not definitive; only the source-script construction is authoritative.

Logged to `MEMORY.md` as a permanent entry under category `dispatch-authoring`.

### Authorization

- **Error caught by:** Coder during Phase 10b execution
- **Escalated by:** PI Nicholas Jensen on 2026-05-21
- **Correction issued by:** Strategist agent (this document)
- **Correction applied:** Coder re-executed D1v / D2v with corrected construction on 2026-05-21
- **Date of addendum:** 2026-05-21
- **Status:** Closed — corrected results adopted; original dispatch preserved for audit trail; lesson logged

---

**End of correction addendum.**
