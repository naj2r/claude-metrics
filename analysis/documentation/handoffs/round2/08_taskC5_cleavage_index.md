# Round 2 — Task C.5: Language Cleavage Index across votes

**Read first**: `00_MASTER.md`, `07_taskC4_rank_recompute.md`
**Status**: PENDING
**Prereqs**: Tasks C.1-C.4 complete. **B-task results known and user has dispatched OK** (this task's framing depends on H3 holding).
**Estimated time**: 45 min
**Output**: `analysis/results/tables/t19_cleavage_index.tex` + `analysis/results/figures/f05_cleavage_coefficient_scatter.pdf`

---

## Purpose

Independent variance-decomposition channel that triangulates the wine-rent-seeking interpretation. Hypothesis: wine-relevant votes (#65, #68) show **attenuated** between-language variance compared to other votes — wine-industry interests cut across the language divide and pull German wine cantons (SH, ZH, AG, TG) toward voting with French wine cantons (VD, VS), reducing the otherwise-dominant language cleavage.

This complements the cross-vote regression panel: regressions report vineyard *coefficients* per vote; cleavage index reports *variance shares* per vote.

## Definitions (per vote v, see strategist spec lines 226-236)

```
LangGap_v   = mean(yes_pct | french_share >= 0.5) - mean(yes_pct | french_share < 0.5)
              (signed: positive = French cantons more pro-yes; near zero = language groups agreed)

VarBetween_v = (n_fr * (mean_fr - grand_mean)^2 + n_ge * (mean_ge - grand_mean)^2) / N
VarTotal_v   = total variance of yes_pct across the 25 cantons on vote v
rho_v        = VarBetween_v / VarTotal_v
              (between-language variance share; near 1 = language is dominant cleavage; 
               near 0 = other factors drove the vote)
```

**Critical definitional choice**: Task C.5 uses **`french_share >= 0.5` threshold** (per strategist spec line 229), NOT the strict {VD, VS, NE, GE} canton set used in Task C.6. Both definitions are defensible. Document the choice in t19 caption.

Counts under threshold definition (verify in code before relying):
- French cantons (`french_share >= 0.5`): typically 5 (VD, VS, NE, GE, possibly FR depending on year)
- German cantons: typically 20

## Implementation

In `05_expansion.do`, new section 10.15:

```stata
**# 10.15 Round-2 Task C.5: Language Cleavage Index across votes
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    gen byte french_canton = (french_share >= 0.5)

    * Per-vote means by language group
    bysort anr french_canton: egen mean_yes_lg = mean(yes_pct)
    bysort anr: egen y_fr = max(cond(french_canton == 1, mean_yes_lg, .))
    bysort anr: egen y_ge = max(cond(french_canton == 0, mean_yes_lg, .))
    bysort anr: egen y_grand = mean(yes_pct)

    gen lang_gap = y_fr - y_ge

    * Variance decomposition per vote
    bysort anr: egen y_total_sd = sd(yes_pct)
    gen y_total_var = y_total_sd^2

    * Use known counts (5 French / 20 German under threshold definition)
    bysort anr: egen n_fr = total(french_canton)
    bysort anr: egen n_ge = total(1 - french_canton)
    
    gen between_contrib = (n_fr * (y_fr - y_grand)^2 + n_ge * (y_ge - y_grand)^2) / 25
    gen rho = between_contrib / y_total_var

    * Collapse to one row per vote
    preserve
    collapse (first) lang_gap rho y_fr y_ge y_grand y_total_var n_fr n_ge vote_year vote_label, by(anr)
    gen byte wine_relevant = inlist(anr, 63, 65, 68)

    di "==== Language Cleavage Index across 15 votes 1900-1910 ===="
    list anr vote_year vote_label wine_relevant lang_gap rho, sepby(wine_relevant) noobs ab(35)

    * Test: do wine-relevant votes have lower rho than other votes?
    ttest rho, by(wine_relevant)
    local rho_wine_mean = r(mu_2)   // wine_relevant == 1
    local rho_other_mean = r(mu_1)  // wine_relevant == 0
    local rho_diff_p = r(p)
    di "Mean rho | wine_relevant: " %5.3f `rho_wine_mean'
    di "Mean rho | other:         " %5.3f `rho_other_mean'
    di "ttest p (two-sided):       " %5.3f `rho_diff_p'

    * Save for figure
    save "$MyProject/processed/intermediate/language_cleavage_index.dta", replace

    * Save row-level summary into regressions_expansion.dta for assertion checks
    foreach v in 63 65 68 {
        qui summ rho if anr == `v', meanonly
        local rho_`v' = r(mean)
    }
    di "rho_63 = " %5.3f `rho_63'
    di "rho_65 = " %5.3f `rho_65'
    di "rho_68 = " %5.3f `rho_68'

    restore
    restore
}
```

### Robustness with/without NE+GE

Per strategist spec lines 297-299:

```stata
* Robustness: rho recomputed dropping NE + GE from the French-canton set
* (the absinthe-rejecting French cantons; tests whether their distinct
* behavior drives the cleavage attenuation)

preserve
use "$MyProject/processed/placebo_panel.dta", clear
keep if !inlist(canton_code, "NE", "GE")
* ... repeat the computation above ...
* Save as language_cleavage_index_excl_ne_ge.dta
restore
```

## t19 builder

15-row table:
- Columns: anr, vote_year, vote_label (truncated), lang_gap (pp), rho (3 decimals), wine_relevant flag
- Sort: chronological by anr (ascending year)
- Wine-relevant rows (#63, #65, #68) bolded or marked with †

Caption (from strategist):
> Language Cleavage Index across federal referenda, 1900-1910. The Language Gap (column 4) is the difference in mean yes-vote share between French- and German-majority cantons (defined by french_share >= 0.5; threshold definition, distinct from the strict canton-set definition used in the turnout-mobilization analysis Table 20). The Between-Language Variance Share rho (column 5) is the share of total cross-cantonal variance attributable to language. Wine-relevant votes (#65 Lebensmittelgesetz 1906, #68 Absinthverbot 1908) show attenuated rho relative to other votes in the panel (mean rho_wine = X.XXX, mean rho_other = Y.YYY, ttest p = Z.ZZZ), consistent with wine-industry economic interests creating cross-cutting voting alignments that overrode the dominant language cleavage on these specific votes. Robustness with NE + GE excluded reported in footnote.

## f05 builder

Scatter plot:
- X-axis: rho_v (between-language variance share)
- Y-axis: vineyard coefficient (from `panel_anr*` rows, model="ols", in `regressions_expansion.dta`)
- Color: red for wine-relevant (#65, #68), gray for #63 (alcohol-trade null), black for other 12
- Annotate red points with vote ID

Predicted pattern: wine-relevant votes in upper-left (large positive vineyard coef, low rho); #63 near origin; others scattered around origin.

## Assertions

```stata
use "$MyProject/results/intermediate/regressions_expansion.dta", clear  // or use the cleavage dta directly

* Assert: rho_68 < rho_63 (absinthe should have lower between-language variance than the clean alcohol-regulation null)
* This is the substantive prediction.
* If it fails, the cleavage-attenuation story doesn't hold and the framing needs revisiting.

* (Encode this in code that reads from language_cleavage_index.dta or stored locals)
```

If the cleavage attenuation prediction fails (wine-relevant rho is NOT lower than other votes), **report honestly and reconsider the framing**. Don't bury the negative result. Per strategist spec line 297-298:

> if mean(rho | wine_relevant) is meaningfully below mean(rho | other) — say, <0.5x the average — and #63 falls in the normal range, the cleavage index corroborates the cross-vote regression panel via an independent statistical channel. If wine-relevant rho is NOT attenuated, the language-divide-was-overcome story doesn't hold up empirically; report this honestly and reconsider the framing.

## Acceptance criteria

- [ ] `language_cleavage_index.dta` saved (15 rows: one per vote)
- [ ] `language_cleavage_index_excl_ne_ge.dta` saved (robustness)
- [ ] t19_cleavage_index.tex generated (15 rows + summary stat in caption)
- [ ] f05_cleavage_coefficient_scatter.pdf generated
- [ ] Mean(rho | wine_relevant) and ttest p reported
- [ ] Sanity assert (e.g., rho values all in [0, 1]) passes
- [ ] Substantive assert (rho_wine < rho_other on average) — pass or report honest fail
- [ ] Commit pushed

## Pitfalls

1. **Edge case: a vote where all French cantons voted the same way** (`y_total_var → 0` for that subgroup) produces division-by-zero or undefined rho. Guard with `if y_total_var > 0 & !missing(y_total_var)`.

2. **`vote_label` may not match strategist's `vote_topic`** in semantics — confirm what's in the panel by `describe vote_label` first. If labels are too long for the table, truncate via `substr(vote_label, 1, 35)`.

3. **Definitional drift between Task C.5 and C.6**: C.5 uses `french_share >= 0.5` threshold; C.6 uses strict {VD, VS, NE, GE}. They will produce different French-canton counts. **Document the difference explicitly** in BOTH t19 and t20 captions to forestall referee confusion.

4. **Small N caveats**: With 5 French and 20 German cantons, the `mean_fr` is sensitive to single-canton swings. The robustness check excluding NE+GE addresses this; report both and note the divergence.

## Commit message template

```
round2 Task C.5: Language Cleavage Index across 15 votes 1900-1910

Independent variance-decomposition channel triangulating the wine-
rent-seeking interpretation. Per-vote rho = between-language variance
share. Hypothesis: wine-relevant votes (#65, #68) show attenuated rho
because wine-industry interests cut across the language divide.

Result:
  Mean rho | wine_relevant (#65, #68): X.XXX
  Mean rho | other (12 votes):         Y.YYY
  ttest p (two-sided):                 Z.ZZZ
  rho_63 = A.AAA (alcohol-regulation null reference)
  rho_65 = B.BBB
  rho_68 = C.CCC

Robustness excluding NE + GE: <similar / divergent> pattern.

t19_cleavage_index.tex (15 rows + summary).
f05_cleavage_coefficient_scatter.pdf (rho vs vineyard coef per vote).

Definitional note: C.5 uses french_share >= 0.5 threshold (5 French / 20
German); C.6 uses strict {VD, VS, NE, GE} (4 French / 20 German). Both
defensible; documented in both table captions.

1 sanity assert (all rho in [0,1]); 1 substantive assert (rho_wine_mean
< rho_other_mean). Pipeline 39 assertions pass.
```

## Done when

- t19 + f05 generated
- Both assertions pass (or honest report if substantive assert fails)
- Commit pushed
- Move to `09_taskC6_mobilization.md`
