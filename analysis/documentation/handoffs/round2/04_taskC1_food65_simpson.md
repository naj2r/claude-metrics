# Round 2 — Task C.1: Food-law (#65) Simpson sign-flip diagnostic

**Read first**: `00_MASTER.md`, `03_taskB_formal_hypotheses.md` (Task B must be complete + user dispatched OK)
**Status**: PENDING (do not start until user re-confirms after Task B status report)
**Prereqs**: Tasks 01, 02, 03 complete. Pipeline at green baseline. User has reviewed H3/H6 and given go-ahead for C.* tasks.
**Estimated time**: 30 min
**Output**: Extension to `t13_placebo_panel.tex` (panel B with bivariate vs conditional rows for #65)

---

## Purpose

The headline result on #68 (absinthe) is a Simpson's paradox: bivariate vineyard coef negative, conditional positive. Verify whether the same structure holds for #65 (food law). If both bivariate negative + conditional positive: structurally identical mechanism. If bivariate already positive: similar-but-not-identical (coalition assembled differently). Either is informative.

## Implementation

In `05_expansion.do`, add a new section 10.12 (after Task B's 10.11):

```stata
**# 10.12 Round-2 Task C.1: Food-law (#65) Simpson sign-flip check
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr == 65

    * Bivariate
    qui reg yes_pct vineyard_per_cap, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "food65_bivariate", model, "ols")
    local food65_b_biv = _b[vineyard_per_cap]
    local food65_p_biv = (2 * (1 - normal(abs(_b[vineyard_per_cap] / _se[vineyard_per_cap]))))

    * Conditional on french_share + catholic_share (KEY-spec analog for #65)
    qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "food65_conditional", model, "ols")
    local food65_b_cond = _b[vineyard_per_cap]
    local food65_p_cond = (2 * (1 - normal(abs(_b[vineyard_per_cap] / _se[vineyard_per_cap]))))

    di "Food-law #65 bivariate vineyard coef: " %7.2f `food65_b_biv' " (p=" %5.3f `food65_p_biv' ")"
    di "Food-law #65 conditional vineyard coef: " %7.2f `food65_b_cond' " (p=" %5.3f `food65_p_cond' ")"
    di "Sign flip? " cond(`food65_b_biv' < 0 & `food65_b_cond' > 0, "YES (Simpson)", "NO (mechanism differs from #68)")

    restore
}
```

## t13 extension (panel B)

Modify section 12.8 (existing t13 builder) to append a 2-row "Panel B: Food-law (#65) Simpson check" below the main 15-vote panel. Use `texsave` with appropriate row separators, OR build a separate `t13b_food65_simpson.tex` and `\input{}` both into the paper. Recommend the panel-B approach (one table, one ref).

Specifically, in the t13 builder:
1. After building the main 15-vote table (rows 1-15), append 2 rows:
   - Row 16: "Panel B header" (use `texsave`'s `marker()` row trick or a manual `\hline\multicolumn{...}{...}{Panel B}` insert)
   - Row 17: "(#65) bivariate" — show `food65_b_biv` + SE + p
   - Row 18: "(#65) conditional" — show `food65_b_cond` + SE + p

This is fiddly with `texsave`. Easiest: build the 15-row main table as before, then post-process the .tex to inject panel-B rows. Or just build TWO tables (`t13a_placebo_panel.tex` and `t13b_food65_simpson.tex`) and `\input{}` both. Pick whichever is less code.

## Acceptance criteria

- [ ] Both regressions ran; coefs and p-values logged
- [ ] Result classified: "Simpson sign-flip YES" or "NO (mechanism differs from #68)"
- [ ] t13 (or t13b sibling) shows the two new rows
- [ ] Pipeline still passes all assertions
- [ ] Commit pushed

## Pitfall

`placebo_panel.dta` already has the #65 rows (it's the long format covering all 15 votes). No new data needed. Just `keep if anr == 65` and run two regressions. Don't overcomplicate.

## Commit message template

```
round2 Task C.1: Food-law (#65) Simpson sign-flip diagnostic

Tests whether vote #65 (1906 Lebensmittelgesetz) shows the same Simpson
structure as the #68 absinthe headline (bivariate negative, conditional
positive after adding language + religion).

Result: <SIMPSON_PRESENT or NOT>
- Bivariate vineyard coef: <X.X> (p=<Y.YY>)
- Conditional (KEY spec analog): <X.X> (p=<Y.YY>)

Interpretation: <if Simpson YES> structurally identical mechanism to #68;
<if NO> similar-but-not-identical, coalition assembled differently for
the food law (which had broader public-health support beyond wine).

t13 panel B updated (or t13b_food65_simpson.tex created). Pipeline 34+0
assertions (no new asserts; this is a reportable diagnostic).
```

## Done when

- t13 panel B (or t13b) updated with 2 new rows
- Result interpretation captured in commit message
- Move to `05_taskC2_food65_robustness.md`
