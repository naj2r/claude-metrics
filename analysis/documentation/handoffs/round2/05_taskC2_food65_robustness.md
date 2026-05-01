# Round 2 — Task C.2: Food-law (#65) robustness battery

**Read first**: `00_MASTER.md`, `04_taskC1_food65_simpson.md` (sequential)
**Status**: PENDING
**Prereqs**: Task C.1 complete.
**Estimated time**: 2 hours
**Output**: `analysis/results/tables/t18_food65_robustness.tex`

---

## Purpose

Replicate on vote #65 the headline robustness checks already done for #68. If the +1286 coefficient survives the battery, the food-law evidence is as robust as the absinthe evidence. If it collapses under specific specifications, report honestly that food-law evidence is more fragile.

## Robustness specs to run on vote #65

Mirror the existing #68 robustness battery (see `03_regress.do` for the patterns):

1. **LOO** (drop each canton in turn, store the 25 vineyard coefs)
2. **Drop NE + GE** (the 1908 absinthe-rejecting cantons; check that the food-law result isn't driven by them)
3. **RI 10k permutations** (analytical p reported alongside)
4. **Weighted regressions** (5 schemes: pop / votes / eligible / french-pop / german-pop)

Each spec runs on `keep if anr == 65` from `placebo_panel.dta`, with the KEY spec `reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)`.

## Implementation sketch

```stata
**# 10.13 Round-2 Task C.2: Food-law (#65) robustness battery
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr == 65

    * --- LOO ---
    levelsof canton_code, local(cantons) clean
    foreach c of local cantons {
        qui reg yes_pct vineyard_per_cap french_share catholic_share if canton_code != "`c'", vce(hc3)
        regsave using "`results_exp'", t p autoid append ///
            addlabel(spec, "food65_loo_drop_`c'", model, "ols")
    }

    * --- Drop NE + GE ---
    qui reg yes_pct vineyard_per_cap french_share catholic_share ///
        if canton_code != "NE" & canton_code != "GE", vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "food65_excl_ne_ge", model, "ols")

    * --- RI 10k ---
    set seed 20260430  // round-2 seed per MASTER §"Cross-task data invariants"
    ritest vineyard_per_cap _b[vineyard_per_cap], reps(10000) seed(20260430): ///
        reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    local food65_ri_p = r(p)
    di "Food-law #65 RI p (10k): " %5.3f `food65_ri_p'

    * --- Weighted regressions ---
    foreach w in pop_1900 yes_count eligible french_1900 german_1900 {
        cap qui reg yes_pct vineyard_per_cap french_share catholic_share [aweight = `w'], vce(hc3)
        if !_rc {
            regsave using "`results_exp'", t p autoid append ///
                addlabel(spec, "food65_weighted_`w'", model, "ols")
        }
    }

    restore
}
```

## t18 builder

4-column table (mirror #68 robustness format from t05/t06):

- Column 1: Headline #65 conditional (from C.1's `food65_conditional` row, or rerun)
- Column 2: Drop NE + GE
- Column 3: Median LOO coefficient + range (min, max across 25 LOO drops)
- Column 4: RI p-value

Plus a footnote with the 5 weighted-regression coefficients.

## Acceptance criteria

- [ ] LOO produces 25 stored rows (one per dropped canton)
- [ ] Drop-NE+GE produces 1 row
- [ ] RI 10k completes (~1 min runtime)
- [ ] 5 weighted regressions run; any failures captured + reported (likely all succeed)
- [ ] t18_food65_robustness.tex generated
- [ ] No assertion required (this is reportage, not a hypothesis test). But a sanity assert that LOO produced 25 rows and median is positive is reasonable.
- [ ] Commit pushed

## Pitfalls

1. **`pop_1900`, `yes_count`, `eligible`, `french_1900`, `german_1900` may not all be in placebo_panel.dta**. The current panel (per `02_clean.do` section 4b) keeps `vineyard_per_cap french_share catholic_share french_share_total catholic_share_total pop_1900 ln_pop`. `yes_count` and `eligible` are NOT in the keepusing list. Check before running; if missing, either:
   - (a) extend placebo_panel construction in 02_clean.do to keep these
   - (b) merge them in via canton-level dataset (but they're vote-specific, not canton-specific)
   - (c) limit weighted regressions to schemes that use canton-level vars (pop_1900, french_1900, german_1900)

   Probably (c) is fine for #65 robustness; the headline #68 weighted regressions used vote-specific weights. Document the limitation.

2. **`yes_count` / `eligible` for vote #65 specifically** must come from `placebo_votes_uncleaned.dta` (which `01_import.do` produces). If those columns weren't kept when building the panel, that's a back-extension item. Worth doing once for ALL 15 votes if you're already touching `01_import.do` for Task C.6's turnout extraction. **Coordinate with Task C.6 prereqs.**

3. **`ritest` runtime**: 10k reps × 1 vote × N=25 should be ~30-60 seconds. If it takes longer, check for spec issues.

## Commit message template

```
round2 Task C.2: Food-law (#65) robustness battery

Replicates the #68 robustness battery for vote #65 (Lebensmittelgesetz):
LOO across 25 cantons, drop NE+GE, RI 10k permutations, weighted
regressions (where panel data permit).

Result: <SURVIVES / FRAGILE>
- Headline #65 conditional: <X> (p=<Y>)
- Drop NE+GE: <X> (p=<Y>)
- LOO range: [<min>, <max>], median <X>
- RI p (10k): <Y.YYY>
- Weighted (pop): <X> (p=<Y>); (french_pop): <X> (p=<Y>); ...

Interpretation: <if survives> food-law evidence as robust as absinthe;
<if fragile> noted, food-law treated as supporting-but-fragile.

t18_food65_robustness.tex (4-column format mirroring t05/t06).
1 sanity assert (LOO produces 25 rows). Pipeline 35 assertions pass.
```

## Done when

- t18 generated, pipeline passes
- Commit pushed
- Move to `06_taskC3_RI_three_votes.md`
