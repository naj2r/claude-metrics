# Round 2 — Task B: Formal B&B hypothesis tests

**Read first**: `00_MASTER.md`, `01_setup.md`, `02_taskA_diagnostics.md` (sequential)
**Status**: PENDING
**Prereqs**: Tasks 01 and 02 complete. Pipeline at green baseline with t16_diagnostics.tex producing.
**Estimated time**: 3-4 hours
**Output**: `analysis/results/tables/t17_formal_hypotheses.tex` + new entries in `regressions_expansion.dta`

**⚠️ STOP-AFTER-THIS rule**: Once this task commits, **STOP and report H3/H6 results to user before continuing to C.5/C.6**. The framing of those downstream tasks depends on whether H3 and H6 hold. Do NOT proceed to `04_taskC1_*` automatically.

---

## Purpose (1 paragraph)

Move the paper from "consistent with B&B" to "tests B&B against rival explanations" by adding two interaction tests derived from Becker (1983) and Olson (1965). H3 (coalition interaction): the wine-industry effect is *amplified* where the moralist-temperance coalition is strong. H6 (Olsonian concentration): the wine-industry effect is *amplified* where wine production is more concentrated (Olsonian rent-seeking efficiency). Predicted signs: both interactions positive. Null results would weaken the formal-hypothesis framing for the paper but are reportable findings, not failures.

## Sub-tasks

### B.1 — H3 coalition interaction (vine × protestant_share)

Operationalize moralist coalition strength via Protestant share (proxy for temperance-organization density; Blue Cross / Croix-Bleue / IOGT canton-level membership UNAVAILABLE per MASTER §"Data availability fallbacks", so we use this fallback).

**Construction**: `protestant_share_total = 1 - catholic_share_total` (total-pop denominator). Already constructed in Task A.3; reuse via `cap drop` + regen pattern.

**Centered interaction** (per strategist; aids interpretation, doesn't change inference):

```stata
* B.1: H3 coalition interaction
* Construct centered vineyard and centered protestant_share_total
sum vineyard_per_cap, meanonly
gen vineyard_c = vineyard_per_cap - r(mean)

cap drop protestant_share_total
gen double protestant_share_total = 1 - catholic_share_total
sum protestant_share_total, meanonly
gen protestant_c = protestant_share_total - r(mean)

gen vineyard_X_protestant = vineyard_c * protestant_c

reg yes_pct vineyard_c protestant_c vineyard_X_protestant french_share catholic_share, vce(hc3)
regsave using "`results_exp'", t p autoid append ///
    addlabel(spec, "H3_coalition_interaction", model, "ols")

* Capture interaction coef + p for assertion
local h3_coef = _b[vineyard_X_protestant]
local h3_p    = (2 * (1 - normal(abs(_b[vineyard_X_protestant] / _se[vineyard_X_protestant]))))
di "H3 vineyard × protestant_share interaction: " %7.2f `h3_coef' " (p=" %5.3f `h3_p' ")"
```

**Predicted sign**: positive (wine effect stronger where moralists organized). If null, the coalition framing is harder to defend.

### B.2 — H6 Olsonian concentration test (vine × avg_parcel_area)

Olson (1965) predicts wine effect *amplified* by industrial concentration. Operationalize via `avg_parcel_area_1905` (already in `absinthe_analysis.dta` — constructed by `02_clean.do` as `agland_1000ha * 1000 / (farms_1905 * parcels_per_farm_1905)`).

**Note**: I (the round-1 coder) already have `vine_x_parcel_area` in `t08_interactions.tex`. Task B.2 produces a **separate** table that frames this as a formal hypothesis test, with its own row/column structure. Don't delete the existing t08 entry; the framing is different (interactions table = mechanical heterogeneity check; formal hypothesis test = theory-driven prediction).

```stata
* B.2: H6 Olsonian concentration interaction
sum avg_parcel_area_1905, meanonly
gen parcel_c = avg_parcel_area_1905 - r(mean)
gen vineyard_X_parcel = vineyard_c * parcel_c

reg yes_pct vineyard_c parcel_c vineyard_X_parcel french_share catholic_share, vce(hc3)
regsave using "`results_exp'", t p autoid append ///
    addlabel(spec, "H6_olsonian_interaction", model, "ols")

local h6_coef = _b[vineyard_X_parcel]
local h6_p    = (2 * (1 - normal(abs(_b[vineyard_X_parcel] / _se[vineyard_X_parcel]))))
di "H6 vineyard × parcel_area interaction: " %7.2f `h6_coef' " (p=" %5.3f `h6_p' ")"
```

**Predicted sign**: positive (concentration → easier mobilization → larger wine effect).

### B.3 — Joint H3+H6 spec (M3+M4)

Strategist's t15 (renumbered t17) column 4 is "Both interactions simultaneously":

```stata
reg yes_pct vineyard_c protestant_c vineyard_X_protestant parcel_c vineyard_X_parcel french_share catholic_share, vce(hc3)
regsave using "`results_exp'", t p autoid append ///
    addlabel(spec, "H3_and_H6_joint", model, "ols")
```

This tests whether H3 and H6 each survive controlling for the other.

### B.4 — Build t17_formal_hypotheses.tex

4-column table:
- Column 1: Headline KEY spec (replicate from existing regressions; `spec == "french_catholic"`, `model == "ols"`)
- Column 2: H3 coalition interaction
- Column 3: H6 Olsonian concentration
- Column 4: Both interactions jointly

Rows (in order of substantive interest):
- vineyard_per_cap (or vineyard_c after centering)
- vineyard_X_protestant (only cols 2 & 4)
- vineyard_X_parcel (only cols 3 & 4)
- protestant_share_total or protestant_c (cols 2 & 4)
- avg_parcel_area_1905 or parcel_c (cols 3 & 4)
- french_share (all cols)
- catholic_share (all cols)
- Constant
- N
- R²

Caption template (from strategist):
> We test two implications of the bootleggers-and-baptists framework derived from Becker (1983) and Olson (1965). H3 (column 2) tests whether the wine-industry effect is amplified by moralist coalition strength, operationalized as protestant_share_total = 1 − catholic_share_total in the absence of canton-level Blue Cross membership data (the first-best measure). H6 (column 3) tests whether the effect is amplified by Olsonian industrial concentration, operationalized as avg_parcel_area_1905 (constructed from agricultural land 1912 / total parcels 1905; documented in CONTEXT.md). Column 4 tests both interactions jointly. Centered regressors (vineyard_c, protestant_c, parcel_c) are used to ease interpretation of the interaction coefficients. HC3 standard errors. N=25 cantons. Stars: * p<0.10, ** p<0.05, *** p<0.01.

### B.5 — Add assertions

```stata
* Task B formal-hypothesis assertions
use "$MyProject/results/intermediate/regressions_expansion.dta", clear

* H3 vineyard × protestant interaction: REPORT sign and significance
* (don't assert positive — that's the hypothesis being tested)
summ coef if spec == "H3_coalition_interaction" & var == "vineyard_X_protestant", meanonly
local h3_coef_chk = r(mean)
summ pval if spec == "H3_coalition_interaction" & var == "vineyard_X_protestant", meanonly
local h3_p_chk = r(mean)
di "H3 interaction coef = " %7.2f `h3_coef_chk' " (p=" %5.3f `h3_p_chk' ")"

* H6 vineyard × parcel interaction
summ coef if spec == "H6_olsonian_interaction" & var == "vineyard_X_parcel", meanonly
local h6_coef_chk = r(mean)
summ pval if spec == "H6_olsonian_interaction" & var == "vineyard_X_parcel", meanonly
local h6_p_chk = r(mean)
di "H6 interaction coef = " %7.2f `h6_coef_chk' " (p=" %5.3f `h6_p_chk' ")"

* Sanity: vineyard main effect should remain positive in M3 and M4 (H3, H6, joint)
foreach s in H3_coalition_interaction H6_olsonian_interaction H3_and_H6_joint {
    summ coef if spec == "`s'" & var == "vineyard_c", meanonly
    di "vineyard main effect in `s': " %7.2f r(mean)
    assert r(mean) > 0  // KEY-spec result should survive interaction inclusion
}
```

The hypothesis itself (positive interaction) is NOT asserted — it's the result being reported. The assertion ensures vineyard's main effect remains positive (sanity check that the interaction inclusion didn't break the headline).

### B.6 — Stop-and-report

After Task B commits and pipeline passes:

1. Compose a short status update to user with:
   - H3 sign and p-value (e.g., "H3: vineyard × protestant_share = +XXX.X, p=Y.YYY → [supports / nulls] coalition framing")
   - H6 sign and p-value (e.g., "H6: vineyard × parcel_area = +XXX.X, p=Y.YYY → [supports / nulls] Olsonian framing")
   - Joint M3+M4 result: do both interactions survive when included together?
   - Vineyard main-effect stability across M2/M3/M4
   - Recommendation for C.5/C.6 framing based on what was found

2. **Wait for user dispatch.** Do NOT proceed to `04_taskC1_*` automatically.

3. If user says "go", proceed to `04_taskC1_food65_simpson.md`. If user says "reframe C.5 because H3 was null", read the modified instructions and adapt.

## Where this lives in `05_expansion.do`

NEW section between 10.10 (Task A diagnostics) and 11 (assertion block):

```
**# 10.11 Round-2 Task B: Formal B&B hypothesis tests (H3 + H6)
*------------------------------------------------------------------------------*
{
    * (the code above)
}
```

t17 builder goes after t16 builder (likely as section 12.13 or thereabouts; renumber subsequent if needed).

## Acceptance criteria

- [ ] `t17_formal_hypotheses.tex` exists in `analysis/results/tables/`
- [ ] 4 columns produced (KEY / H3 / H6 / joint)
- [ ] H3 interaction coef and p reported (in table AND in log via `di`)
- [ ] H6 interaction coef and p reported (in table AND in log via `di`)
- [ ] Vineyard main-effect-positive assertion passes for all 3 interaction specs
- [ ] Pipeline runtime not materially increased
- [ ] Commit pushed
- [ ] **Status update written to user; awaiting dispatch before C.* tasks**

## Pitfalls

1. **Centering changes the main-effect interpretation**, not the interaction. After centering, `_b[vineyard_c]` is the vineyard slope at the MEAN of the moderator (mean protestant_share or mean parcel_area), not at moderator=0. This is what we want for interpretation but document in the table caption.

2. **Multicollinearity in the joint M3+M4 spec** — vineyard_c appears multiplied by two different moderators. With N=25, this can inflate VIFs to >10 in the joint spec. If t16 (Task A) showed clean VIFs in the KEY spec, M3+M4 may not. Report VIFs for the joint spec in a footnote (re-run `estat vif` after the joint regression, store separately).

3. **`vineyard_X_protestant` interpretation** — coef is the change in vineyard slope per unit increase in (mean-centered) protestant_share. Since protestant_share is bounded [0, 1], a coef of +1000 means moving from mean protestant share to mean+1 (i.e., to ~1) increases the vineyard slope by 1000. Translate to a one-SD change for the magnitudes table if helpful.

4. **`vineyard_X_parcel` magnitude** — `avg_parcel_area_1905` is in hectares, so a one-unit increase is one hectare per parcel. Many cantons cluster around 0.3-0.5 ha/parcel. A one-SD change is the substantively interpretable scale; prefer that when describing the magnitude.

5. **vineyard_c can collide with prior session's vine_x_french/vine_x_catholic/etc.** in t08_interactions. The existing interactions use uncentered vineyard_per_cap; this task introduces a centered version. Use distinct names (`vineyard_c`, `vineyard_X_protestant`, etc.) to avoid namespace collision. Drop after table builds: `cap drop vineyard_c protestant_c parcel_c vineyard_X_protestant vineyard_X_parcel`.

## Commit message template

```
round2 Task B: H3 coalition + H6 Olsonian formal hypothesis tests

Implements the formal B&B hypothesis tests called out in the strategist
round-2 handoff Task B. Code in 05_expansion.do new section 10.11.

H3 (coalition interaction): vine × protestant_share_total
  - Predicted sign: positive (wine effect amplified where moralists strong)
  - Result: <SIGN> coef = <VAL>, p = <P>, [supports / nulls] hypothesis

H6 (Olsonian concentration): vine × avg_parcel_area_1905
  - Predicted sign: positive (concentration → easier rent-seeking)
  - Result: <SIGN> coef = <VAL>, p = <P>, [supports / nulls] hypothesis

Joint M3+M4: <interpretation>

Vineyard main effect remains positive across M2/M3/M4 (sanity check).

protestant_share_total constructed as 1 - catholic_share_total (Blue Cross
canton-level membership unavailable; documented in t17 caption).

t17_formal_hypotheses.tex (4 columns: KEY / H3 / H6 / joint).
3 new sanity asserts. Full pipeline 31+3=34 assertions pass.

NEXT: STOP and report H3/H6 to user before continuing to Tasks C.5/C.6.
The cleavage-index and mobilization framings depend on whether H3 and H6
hold; user dispatch needed before proceeding.
```

## Done when

- t17_formal_hypotheses.tex regenerates cleanly
- 3 new sanity asserts pass
- Commit pushed
- Status update sent to user with H3/H6 numbers + framing recommendation
- **AWAITING USER** before reading `04_taskC1_food65_simpson.md`
