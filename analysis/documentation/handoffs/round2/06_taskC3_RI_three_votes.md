# Round 2 — Task C.3: RI consistency for three wine-relevant votes

**Read first**: `00_MASTER.md`, `05_taskC2_food65_robustness.md` (sequential)
**Status**: PENDING
**Prereqs**: Task C.2 complete. `ritest` package vendored from setup.
**Estimated time**: 1 hour
**Output**: RI p-value column added to `t13_placebo_panel.tex` (or sibling t13c)

---

## Purpose

Round 1 used analytical HC3 for the cross-referendum falsification panel due to runtime cost. For methodological consistency with the headline RI inference, run RI specifically for the three wine-relevant votes (#63, #65, #68). 10k permutations × 3 votes ≈ 30k regressions, ~1-2 minute extra runtime. The other 11 placebos can stay analytical-only since they're orthogonal to the headline.

## Implementation

```stata
**# 10.14 Round-2 Task C.3: RI for the three wine-relevant votes
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    foreach v in 63 65 68 {
        keep if anr == `v'
        ritest vineyard_per_cap _b[vineyard_per_cap], reps(10000) seed(20260430): ///
            reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
        local ri_p_`v' = r(p)
        di "Vote #`v' RI p (10k): " %5.3f `ri_p_`v''

        * Save as a regsave-style row for the t13 builder
        clear
        set obs 1
        gen str20 var = "vineyard_per_cap"
        gen double coef = .
        gen double stderr = .
        gen double tstat = .
        gen double pval = `ri_p_`v''
        gen long N = 25
        gen str30 spec = "panel_anr`v'_ri10k"
        gen str20 model = "ri_10k"
        append using "`results_exp'"
        save "`results_exp'", replace

        * Reload panel for next iteration
        use "$MyProject/processed/placebo_panel.dta", clear
    }
    restore
}
```

## t13 update

Add an "RI p (10k)" column to the existing t13_placebo_panel.tex builder. Only 3 of 15 rows have the new column populated (#63, #65, #68); other 11 show "—" or blank.

In section 12.8 (the t13 builder), after the existing OLS + fracreg AME columns, add:

```stata
* Merge in RI p-values for the 3 wine-relevant votes
preserve
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ri_10k" & strpos(spec, "panel_anr") & strpos(spec, "_ri10k")
    gen int anr = real(substr(spec, 10, strpos(spec, "_ri10k") - 10))
    keep anr pval
    rename pval ri_p_10k
    tempfile ri_rows
    save "`ri_rows'", replace
restore

merge 1:1 anr using "`ri_rows'", nogen   // adds ri_p_10k for 3 votes; missing for other 12

gen str10 ri_p_str = ""
replace ri_p_str = string(ri_p_10k, "%5.3f") if !missing(ri_p_10k)
replace ri_p_str = "—" if missing(ri_p_10k)
* Add ri_p_str to the texsave column list and label var
```

## Acceptance criteria

- [ ] 3 RI p-values computed (~1-2 min runtime total)
- [ ] All 3 stored in regressions_expansion.dta with `model == "ri_10k"`
- [ ] t13 has new RI-p column with values for #63/#65/#68 and "—" elsewhere
- [ ] Pipeline passes
- [ ] Commit pushed

## Pitfalls

1. **`ritest` syntax** — varies between SSC and GitHub versions. Confirm via `help ritest` after vendoring. The `_b[varname]` test-statistic syntax is standard.

2. **Seed scope** — `set seed 20260430` immediately before the `ritest` block ensures reproducibility. Use the same seed across all 3 votes (per round-2 invariant in MASTER §"Cross-task data invariants"). The `seed()` option inside `ritest` is also good practice.

3. **Vote #63 should produce p > 0.10** (it's the alcohol-regulation null per round-1 result, β=−52, analytical p=0.886). RI p should also be > 0.10. Add an assert: `assert ri_p_63 > 0.10`.

4. **Votes #65 and #68 should produce p ≤ 0.10** (round-1 analytical p = 0.045 and 0.024 respectively). RI p should likely be a bit higher than analytical due to small N=25 (RI is exact under the sharp null but discretized; the smallest possible RI p is 1/(reps+1) = 1/10001 = 0.0001). If RI p is much higher than analytical (e.g., > 0.20 for #68 when analytical was 0.024), investigate — possible spec issue.

## Commit message template

```
round2 Task C.3: RI for three wine-relevant votes (#63, #65, #68)

Methodological consistency: round 1 ran analytical HC3 for the 15-vote
falsification panel; this task adds 10k-permutation RI for the three
wine-relevant votes for inference consistency with the headline.

RI p-values (10k reps, seed 20260430):
- Vote #63 (alcohol regulation 1903): p = <Y.YYY> [analytical: 0.886]
- Vote #65 (food law 1906):           p = <Y.YYY> [analytical: 0.045]
- Vote #68 (absinthe ban 1908):       p = <Y.YYY> [analytical: 0.024]

t13_placebo_panel.tex extended with RI-p column (3 votes populated, 12
shown as em-dashes).

1 sanity assert added (vote #63 RI p > 0.10). Pipeline 36 assertions pass.
```

## Done when

- t13 has new RI column
- 3 RI p-values stored and verified
- Commit pushed
- Move to `07_taskC4_rank_recompute.md`
