/*==============================================================================
 05_expansion.do
 Purpose:  Expansion analyses. Originally ported from prior Brainstorm-Absinthe
           replication; extended 2026-04-30 with cross-referendum panel,
           strategist new-controls, German-share interaction, Olson 1965
           concentration test, and Gelbach (2016) decomposition.
            1. Same-day placebo (vote #67 commerce, also July 5 1908)
            2. German-only subsample (eliminates Simpson confound)
            3. Pre-determined vineyard (1894 measure)
            4. Vineyard-change ("desperation hypothesis")
            5. Weighted regressions (pop, votes, French/German pop)
            6. Alternative vineyard operationalizations
            6.5 Absinthe-canton tiering (NE / NE+VD / NE+VD+GE)
            7. Heterogeneity interactions (vine x french/german/catholic/lnpop/parcels)
            8. Additional outcomes (margin, turnout, yes/eligible)
            9. NE prediction-gap (absinthe-industry effect estimate)
           10. Coefficient stability + Oster delta (with Simpson caveat)
           10.5 Cross-referendum falsification panel (15 votes 1900-1910)
           10.6 Strategist new-control specs (migration, parcels) [2026-04-30]
           10.7 vine x german_share interaction [2026-04-30]
           10.8 vine x parcels_per_farm interaction (Olson 1965) [2026-04-30]
           10.9 Gelbach (2016) decomposition of Simpson sign-flip [2026-04-30]
                IMPORTANT: read analysis/documentation/methods/gelbach_decomposition.md
                before modifying section 10.9. The methods-doc-reminder hook
                (.claude/hooks/methods-doc-reminder.sh) auto-surfaces this.
 Input:    $MyProject/processed/absinthe_analysis.dta
           $MyProject/processed/placebo_panel.dta
           $MyProject/results/intermediate/regressions.dta (for stability table)
 Output:   $MyProject/results/intermediate/regressions_expansion.dta
           $MyProject/results/intermediate/gelbach_decomp.dta
           $MyProject/results/tables/t04_placebo.tex
           $MyProject/results/tables/t05_subsample.tex
           $MyProject/results/tables/t06_weighted.tex
           $MyProject/results/tables/t07_alt_vineyard.tex
           $MyProject/results/tables/t08_interactions.tex (5 cols)
           $MyProject/results/tables/t09_outcomes.tex
           $MyProject/results/tables/t10_stability.tex
           $MyProject/results/tables/t12_absinthe_tier.tex
           $MyProject/results/tables/t13_placebo_panel.tex
           $MyProject/results/tables/t14_new_controls.tex
           $MyProject/results/tables/t15_gelbach.tex
           $MyProject/results/figures/f03_placebo_distribution.pdf
           $MyProject/results/figures/f04_marginsplot_french.pdf
 Author:   Nicholas A Jensen
 Date:     2026-04-30
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Load
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/absinthe_analysis.dta", clear
    assert c(N) == 25
    isid canton_code
    tempfile results_exp
}


**# 1. Same-day placebo: vote #67 (commerce) vs vote #68 (absinthe ban)
*------------------------------------------------------------------------------*
{
    * If vineyard_per_cap predicts the absinthe vote but NOT the commerce vote
    * (same voters, same day, different issue), the wine-protection mechanism
    * is issue-specific rather than a general "wine canton" attitude.

    * Absinthe vote (KEY spec): expect positive
    reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    estimates store placebo_absinthe
    regsave using "`results_exp'", t p autoid replace ///
        addlabel(spec, "placebo_absinthe", model, "ols")

    * Commerce vote (vote #67) — placebo: expect null
    reg vote67_yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    estimates store placebo_commerce
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "placebo_commerce", model, "ols")

    * Difference test: vineyard's effect on absinthe minus its effect on commerce
    di _n "*** PLACEBO TEST ***"
    di "vineyard_per_cap on yes_pct (absinthe):    " %8.2f _b[vineyard_per_cap]
    di "vineyard_per_cap on vote67 (commerce):     [see saved estimates]"

    estimates restore placebo_absinthe
    local b_abs = _b[vineyard_per_cap]
    estimates restore placebo_commerce
    local b_com = _b[vineyard_per_cap]
    di "Difference (absinthe − commerce):         " %8.2f `b_abs' - `b_com'
}


**# 2. Subsample / continuous-language analyses (no Simpson confound)
*------------------------------------------------------------------------------*
{
    * Two complementary approaches to handle the language confound without
    * controlling for it post-hoc:
    *   (a) BINARY SUBSAMPLE — drop French-majority cantons (arbitrary 0.5
    *       threshold; small N=20)
    *   (b) CONTINUOUS WEIGHTING — keep all cantons, weight by (1 - french_share)
    *       so German-dominant cantons get more influence (no arbitrary cutoff)
    *
    * (a) is in the prior Brainstorm-Absinthe analysis. (b) is preferable because
    * it avoids losing 5 cantons to an arbitrary threshold.

    * --- Binary subsample (a): German-only ---
    qui count if french_share < 0.5
    di _n "German-speaking cantons (french_share<0.5): N = " r(N)

    reg yes_pct vineyard_per_cap if french_share < 0.5, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "german_bivariate", model, "ols")

    reg yes_pct vineyard_per_cap catholic_share if french_share < 0.5, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "german_catholic", model, "ols")

    * Protestant cantons only (analogous binary cut on religion)
    qui count if catholic_share < 0.5
    di "Protestant cantons (catholic_share<0.5):   N = " r(N)
    reg yes_pct vineyard_per_cap french_share if catholic_share < 0.5, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "protestant_only", model, "ols")

    * --- Continuous weighting (b): inverse-French-share ---
    * Each canton's weight = (1 - french_share). Most German-dominant cantons
    * (french_share ~ 0) get weight ~1.0; French-dominant (NE, GE) get weight
    * ~0.15. This is the continuous analog of dropping French-majority cantons,
    * but uses ALL 25 observations and avoids the 0.5 cutoff.
    gen double w_german_lean = 1 - french_share_total
    label var w_german_lean "Continuous German-lean weight (1 - french_share_total)"
    reg yes_pct vineyard_per_cap catholic_share ///
        [aweight = w_german_lean], vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "german_lean_continuous", model, "ols")

    * Symmetric: French-lean weighting (= french_share). If wine effect persists
    * here, the result isn't just driven by German-dominant cantons.
    gen double w_french_lean = french_share_total
    label var w_french_lean "Continuous French-lean weight (= french_share_total)"
    reg yes_pct vineyard_per_cap catholic_share ///
        [aweight = w_french_lean] if w_french_lean > 0, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "french_lean_continuous", model, "ols")
}


**# 3. Pre-determined vineyard (1894 measure)
*------------------------------------------------------------------------------*
{
    * Using vineyard_per_cap_1894 (vineyard area 14 years before the vote)
    * addresses reverse-causality concerns: the 1908 vote could not have
    * caused vineyard area in 1894.
    reg yes_pct vineyard_per_cap_1894 french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "predetermined_1894", model, "ols")
}


**# 4. Vineyard change 1877-1905 ("desperation hypothesis")
*------------------------------------------------------------------------------*
{
    * Did cantons whose vineyards SHRANK 1877-1905 vote yes more strongly
    * (defensive response to wine-industry decline)? Or did GROWING vineyard
    * cantons drive the result (offensive market protection)?
    reg yes_pct vine_change_pct french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "vine_change", model, "ols")

    * Level + change horse race
    reg yes_pct vineyard_per_cap vine_change_pct french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "level_plus_change", model, "ols")
}


**# 5. Weighted regressions
*------------------------------------------------------------------------------*
{
    * Population weighting: larger cantons count more
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        [aweight = pop_1900], vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "weighted_pop", model, "ols")

    * Vote-weighted: weight by total ballots cast
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        [aweight = total_votes], vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "weighted_votes", model, "ols")

    * Eligible-voter weighted
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        [aweight = eligible], vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "weighted_eligible", model, "ols")

    * French-population weighted: upweights cantons with many French speakers
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        [aweight = french_1900] if french_1900 > 0, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "weighted_french", model, "ols")

    * German-population weighted: upweights cantons with many German speakers.
    * If result survives downweighting French cantons, the effect isn't just
    * a French-canton phenomenon.
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        [aweight = german_1900] if german_1900 > 0, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "weighted_german", model, "ols")
}


**# 6. Alternative vineyard operationalizations
*------------------------------------------------------------------------------*
{
    * Per 1000 population (rescaled per_cap, more interpretable)
    reg yes_pct vine_per_1000 french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "alt_per_1000", model, "ols")

    * Raw vineyard area (hectares) — tests absolute size
    reg yes_pct vineyard_1905 french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "alt_raw_ha", model, "ols")

    * NOTE: alt_log spec intentionally OMITTED. log(vineyard+1) is unsound
    * with ~32% zero-vineyard cantons (Chen & Roth 2023). Extensive margin is
    * captured by wine_canton (binary, below); intensity by per_km2 / agshare.

    * Wine-canton binary (>1000 ha)
    reg yes_pct wine_canton french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "alt_binary", model, "ols")

    * Vineyard per km^2 (intensity, not per-capita)
    reg yes_pct vine_per_km2 french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "alt_per_km2", model, "ols")

    * Vineyard share of agricultural land (%) — wine importance within agriculture
    reg yes_pct vine_share_agland french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "alt_agshare", model, "ols")
}


**# 6.5 Absinthe-canton tiering (NE only vs NE+VD vs NE+VD+GE)
*------------------------------------------------------------------------------*
{
    * Test whether broadening the absinthe-canton definition changes the
    * vineyard coefficient. NE was the heartland (Pernod, 1797 onwards), VD
    * housed Kübler & Wyss in Yverdon, GE had minor production. Three tiers:
    reg yes_pct vineyard_per_cap french_share catholic_share absinthe_dummy, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "absinthe_tier_ne", model, "ols")

    reg yes_pct vineyard_per_cap french_share catholic_share absinthe_dummy_broad, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "absinthe_tier_ne_vd", model, "ols")

    reg yes_pct vineyard_per_cap french_share catholic_share absinthe_dummy_any, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "absinthe_tier_ne_vd_ge", model, "ols")
}


**# 7. Heterogeneity interactions (N=25 → noisy but signs informative)
*------------------------------------------------------------------------------*
{
    gen double vine_x_french   = vineyard_per_cap * french_share
    gen double vine_x_catholic = vineyard_per_cap * catholic_share
    gen double vine_x_lnpop    = vineyard_per_cap * ln_pop
    label var vine_x_french   "vineyard_per_cap x french_share"
    label var vine_x_catholic "vineyard_per_cap x catholic_share"
    label var vine_x_lnpop    "vineyard_per_cap x ln_pop"

    * vine x french: does wine effect strengthen in French cantons?
    reg yes_pct vineyard_per_cap french_share catholic_share vine_x_french, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_french", model, "ols")

    * vine x catholic
    reg yes_pct vineyard_per_cap french_share catholic_share vine_x_catholic, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_catholic", model, "ols")

    * vine x lnpop
    reg yes_pct vineyard_per_cap french_share catholic_share ln_pop vine_x_lnpop, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_lnpop", model, "ols")
}


**# 8. Additional outcomes (margin, yes/eligible, turnout)
*------------------------------------------------------------------------------*
{
    * Margin of victory: more sensitive to landslide cantons
    reg margin vineyard_per_cap french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "outcome_margin", model, "ols")

    * Yes votes / eligible voters (combines yes-share and turnout)
    reg yes_eligible vineyard_per_cap french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "outcome_yes_elig", model, "ols")

    * Turnout — does wine-canton status predict who showed up?
    reg turnout vineyard_per_cap french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "outcome_turnout", model, "ols")
}


**# 9. NE prediction-gap (absinthe-industry effect estimate)
*------------------------------------------------------------------------------*
{
    * Fit KEY spec EXCLUDING NE; predict what NE would have voted as a "normal"
    * wine canton; compare to actual NE vote. The gap (actual − predicted)
    * estimates the net effect of NE's absinthe-production employment on its vote.
    qui reg yes_pct vineyard_per_cap french_share catholic_share ///
        if canton_code != "NE", vce(hc3)
    predict double yhat_no_ne
    qui sum yhat_no_ne if canton_code == "NE"
    local pred_NE = r(mean)
    qui sum yes_pct if canton_code == "NE"
    local actual_NE = r(mean)
    local ne_gap = `actual_NE' - `pred_NE'
    di _n "*** NE PREDICTION-GAP ANALYSIS ***"
    di "Predicted NE yes_pct (model fit without NE):  " %6.2f `pred_NE'
    di "Actual NE yes_pct:                            " %6.2f `actual_NE'
    di "Gap (actual − predicted):                     " %6.2f `ne_gap'
    di "Interpretation: NE voted " %4.1f abs(`ne_gap') " pp " ///
       cond(`ne_gap' < 0, "BELOW", "ABOVE") " what wine alone predicts."
    di "If gap is large negative, absinthe-industry employment plausibly"
    di "outweighed any wine-protection motive in NE specifically."
    drop yhat_no_ne
}


**# 10. Coefficient stability + Oster (2019) delta
*------------------------------------------------------------------------------*
{
    * Sequential addition of controls: track beta(vineyard) and R2.
    * Oster (2019) delta = how strong unobservables would need to be (relative
    * to observables) to drive beta to zero.
    qui reg yes_pct vineyard_per_cap, vce(hc3)
    local b1   = _b[vineyard_per_cap]
    local r2_1 = e(r2)

    qui reg yes_pct vineyard_per_cap catholic_share, vce(hc3)
    local b2   = _b[vineyard_per_cap]
    local r2_2 = e(r2)

    qui reg yes_pct vineyard_per_cap french_share, vce(hc3)
    local b3   = _b[vineyard_per_cap]
    local r2_3 = e(r2)

    qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    local b4   = _b[vineyard_per_cap]
    local r2_4 = e(r2)

    qui reg yes_pct vineyard_per_cap french_share catholic_share ln_pop, vce(hc3)
    local b5   = _b[vineyard_per_cap]
    local r2_5 = e(r2)

    * Oster delta: bivariate vs full (KEY spec)
    local R2_max = min(1.3 * `r2_4', 1.0)
    local denom  = (`b1' - `b4') * (`r2_4' - `r2_1')
    local delta  = cond(abs(`denom') > 1e-10, ///
                        `b4' * (`R2_max' - `r2_4') / `denom', .)

    di _n "*** COEFFICIENT STABILITY ***"
    di "  Bivariate:        beta = " %9.2f `b1' "  R2 = " %5.3f `r2_1'
    di "  +catholic:        beta = " %9.2f `b2' "  R2 = " %5.3f `r2_2'
    di "  +french:          beta = " %9.2f `b3' "  R2 = " %5.3f `r2_3'
    di "  +french+catholic: beta = " %9.2f `b4' "  R2 = " %5.3f `r2_4'
    di "  +ln_pop:          beta = " %9.2f `b5' "  R2 = " %5.3f `r2_5'
    di _n "  Oster (2019) delta = " %6.2f `delta'
    di "  CAVEAT: The Simpson-paradox sign-flip violates Oster's monotonicity"
    di "  assumption. Standard interpretation does not apply cleanly."
}


**# 10.5 Cross-referendum falsification panel (15 votes 1900-1910)
*------------------------------------------------------------------------------*
{
    * For each of the 15 federal votes 1900-1910, run the KEY-spec regression
    * of canton yes-vote share on vineyard_per_cap + french_share + catholic_share.
    * Save coefficients to feed t13_placebo_panel and f03_placebo_distribution.
    *
    * Logic (Brainstorm-Absinthe ProjectBook 2026-04-09_expansion-analysis.qmd
    * Section 2): if the absinthe vote (#68) coefficient (~+484) is the only
    * one significantly different from zero in this set, the wine-protection
    * mechanism is issue-specific. Hits at votes other than #68 would suggest
    * a spurious correlation with some omitted canton attribute.
    *
    * Prior analysis found non-null also at #65 (food safety, 1906) and
    * #57-58 (proportional representation 1900). Vote #63 (alcohol regulation,
    * 1903) is critical: a null there means vineyard cantons did NOT generically
    * oppose federal alcohol regulation -- their resistance was specific to
    * absinthe.
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    levelsof anr, local(placebos) clean
    foreach a of local placebos {
        qui reg yes_pct vineyard_per_cap french_share catholic_share ///
            if anr == `a', vce(hc3)
        regsave using "`results_exp'", t p autoid append ///
            addlabel(spec, "panel_anr`a'", model, "ols")
    }
    di "Placebo panel: ran KEY spec on " wordcount("`placebos'") " votes 1900-1910"
    restore
}


**# 10.6 Strategist new controls (per 2026-04-30 handoff): KEY + each
*------------------------------------------------------------------------------*
{
    * KEY + net_migration_pre_vote (econ-vitality control). Tests "wine cantons
    * were just declining anyway" alternative. If vineyard coef survives,
    * the absinthe story isn't a generic decline-canton effect.
    reg yes_pct vineyard_per_cap french_share catholic_share net_migration_pre_vote, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_migration", model, "ols")

    * KEY + net_migration_per_cap (per-capita variant; same logic, scale-invariant)
    reg yes_pct vineyard_per_cap french_share catholic_share net_migration_per_cap, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_migration_pc", model, "ols")

    * KEY + parcels_per_farm_1905 (Olson 1965 organizational-capacity control).
    * Imperfect concentration proxy: lower parcels/farm = consolidated holdings;
    * higher = fragmented. Mountain cantons confound this with topography.
    reg yes_pct vineyard_per_cap french_share catholic_share parcels_per_farm_1905, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_parcels", model, "ols")

    * KEY + avg_parcel_area_1905 (the strategist's PRIMARY Olson concentration
    * measure; constructed from agland_1912/(farms_1905*parcels_per_farm_1905)
    * because I.39c block 4 has no 1905 row). Higher = more consolidated land,
    * theoretically aligned with Olson 1965 prediction (concentrated holdings
    * → easier political mobilization → wine effect should be larger).
    reg yes_pct vineyard_per_cap french_share catholic_share avg_parcel_area_1905, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_parcel_area", model, "ols")

    * KEY + fruit_tree_density (1951 geographic proxy; competing-spirits
    * feedstock control). Per user 2026-04-30: with canton-level employment
    * search closed, the canonical wine-industry proxy set is
    * vineyard_per_cap + avg_parcel_area_1905 + fruit_tree_density.
    reg yes_pct vineyard_per_cap french_share catholic_share fruit_tree_density, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_fruit", model, "ols")

    * KEY + ALL THREE canonical wine-industry-size controls (avg parcel area
    * + fruit-tree density + migration level). Per-capita migration omitted
    * (collinear with level + ln_pop). parcels_per_farm omitted (parcel area
    * is preferred per Olson 1965 framing).
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        avg_parcel_area_1905 fruit_tree_density net_migration_pre_vote, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "ctrl_all_new", model, "ols")
}


**# 10.7 vine x german_share interaction (the "other side" of vine x french)
*------------------------------------------------------------------------------*
{
    * Per user 2026-04-30: french_share and german_share are two sides of the
    * same coin in the binary subset. With Italian/Romansh present in some
    * cantons, they're not exact complements. Run both interactions for symmetry.
    cap drop vine_x_german
    gen double vine_x_german = vineyard_per_cap * german_share
    label var vine_x_german "vineyard_per_cap x german_share"

    reg yes_pct vineyard_per_cap german_share catholic_share vine_x_german, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_german", model, "ols")
}


**# 10.8 vine x concentration interactions (Olson 1965 organizational tests)
*------------------------------------------------------------------------------*
{
    * Substantive prediction: in concentrated wine industries, the wine effect
    * on the absinthe vote should be STRONGER (Olson: small concentrated groups
    * mobilize politically more easily than large dispersed ones). Two
    * concentration proxies:
    *   parcels_per_farm: LOW = consolidated, HIGH = fragmented. Sign on
    *     interaction: NEGATIVE (effect attenuates with fragmentation).
    *   avg_parcel_area: HIGH = consolidated land, LOW = fragmented. Sign on
    *     interaction: POSITIVE (effect strengthens with bigger parcels).
    * N=25 makes this noisy.
    cap drop vine_x_parcels
    gen double vine_x_parcels = vineyard_per_cap * parcels_per_farm_1905
    label var vine_x_parcels "vineyard_per_cap x parcels_per_farm"

    reg yes_pct vineyard_per_cap french_share catholic_share ///
        parcels_per_farm_1905 vine_x_parcels, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_parcels", model, "ols")

    cap drop vine_x_parcel_area
    gen double vine_x_parcel_area = vineyard_per_cap * avg_parcel_area_1905
    label var vine_x_parcel_area "vineyard_per_cap x avg_parcel_area"

    reg yes_pct vineyard_per_cap french_share catholic_share ///
        avg_parcel_area_1905 vine_x_parcel_area, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_parcel_area", model, "ols")

    * vine x fruit_tree_density: does the wine effect attenuate where
    * competing-spirit (fruit-distillate) capacity is high?
    cap drop vine_x_fruit
    gen double vine_x_fruit = vineyard_per_cap * fruit_tree_density
    label var vine_x_fruit "vineyard_per_cap x fruit_tree_density"

    reg yes_pct vineyard_per_cap french_share catholic_share ///
        fruit_tree_density vine_x_fruit, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "interact_fruit", model, "ols")
}


**# 10.9 Gelbach (2016) decomposition: which controls drive the sign-flip?
*------------------------------------------------------------------------------*
{
    * METHODS: read analysis/documentation/methods/gelbach_decomposition.md
    * before modifying this section. b1x2 is Gelbach's official package
    * (vendored at libraries/stata/b/b1x2.ado, v4.1.0). Sign convention:
    * b1x2 reports b1base - b1full, so in our Simpson sign-flip case the
    * delta values will be NEGATIVE.
    *
    * Decomposes the change in vineyard_per_cap coefficient from the bivariate
    * spec to the KEY spec (adding french_share + catholic_share) into
    * contributions of language vs religion.
    *
    * Hand-validation block runs first to verify the b1x2 identity. Then we
    * call b1x2 with x2delta() grouping, save coefficients via regsave,
    * and use them to build t15_gelbach.tex.

    * --- Hand-validation block ---
    qui reg french_share vineyard_per_cap, vce(hc3)
    local pi_french = _b[vineyard_per_cap]

    qui reg catholic_share vineyard_per_cap, vce(hc3)
    local pi_catholic = _b[vineyard_per_cap]

    qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    local g_french   = _b[french_share]
    local g_catholic = _b[catholic_share]
    local b_full     = _b[vineyard_per_cap]

    qui reg yes_pct vineyard_per_cap, vce(hc3)
    local b_base = _b[vineyard_per_cap]

    local d_french   = `pi_french'   * `g_french'
    local d_catholic = `pi_catholic' * `g_catholic'
    local d_total    = `d_french' + `d_catholic'
    local check_diff = (`b_base' - `b_full') - `d_total'

    di _n "*** GELBACH DECOMPOSITION (HAND-COMPUTED) ***"
    di "  b1base (bivariate vineyard coef):   " %9.2f `b_base'
    di "  b1full (KEY spec vineyard coef):    " %9.2f `b_full'
    di "  b1base - b1full:                    " %9.2f (`b_base' - `b_full')
    di "  delta_french   = pi_fr  * g_fr:     " %9.2f `d_french'
    di "  delta_catholic = pi_cat * g_cat:    " %9.2f `d_catholic'
    di "  Sum of deltas:                      " %9.2f `d_total'
    di "  Identity check (should be ~0):      " %9.6f `check_diff'
    assert abs(`check_diff') < 1e-4

    * --- Run the official b1x2 package ---
    * x2delta groups: LANG (french_share) and RELIG (catholic_share)
    b1x2 yes_pct, x1all(vineyard_per_cap) ///
        x2all(french_share catholic_share) ///
        x2delta("LANG = french_share : RELIG = catholic_share") ///
        robust
    matrix gelbach_b = e(b)
    matrix gelbach_V = e(V)

    * Extract the LANG and RELIG deltas (b1x2 stores in matrix; element
    * names like "vineyard_per_cap:LANG", "vineyard_per_cap:RELIG", "vineyard_per_cap:__TC")
    local b_lang  = gelbach_b[1, "vineyard_per_cap:LANG"]
    local b_relig = gelbach_b[1, "vineyard_per_cap:RELIG"]
    local b_tc    = gelbach_b[1, "vineyard_per_cap:__TC"]
    local se_lang  = sqrt(gelbach_V["vineyard_per_cap:LANG", "vineyard_per_cap:LANG"])
    local se_relig = sqrt(gelbach_V["vineyard_per_cap:RELIG", "vineyard_per_cap:RELIG"])
    local se_tc    = sqrt(gelbach_V["vineyard_per_cap:__TC", "vineyard_per_cap:__TC"])

    di _n "*** GELBACH DECOMPOSITION (b1x2 package) ***"
    di "  delta_LANG  (french_share):  " %9.2f `b_lang'  "  SE=" %6.2f `se_lang'
    di "  delta_RELIG (catholic_share):" %9.2f `b_relig' "  SE=" %6.2f `se_relig'
    di "  __TC (sum):                  " %9.2f `b_tc'    "  SE=" %6.2f `se_tc'
    di "  (Identity: __TC = b1base - b1full = " %9.2f (`b_base' - `b_full') ")"

    * Cross-check b1x2 vs hand-calc (point estimates should be identical to
    * within numerical precision)
    assert abs(`b_lang'  - `d_french')   < 1e-3
    assert abs(`b_relig' - `d_catholic') < 1e-3

    * Save Gelbach point estimates + SEs as a synthetic regsave-style row for
    * t15_gelbach.tex builder. Use a tempfile so we don't pollute the main
    * regsave structure.
    preserve
    clear
    set obs 3
    gen str20 component = ""
    gen double coef = .
    gen double stderr = .
    replace component = "LANG"   in 1
    replace component = "RELIG"  in 2
    replace component = "TOTAL"  in 3
    replace coef   = `b_lang'  in 1
    replace coef   = `b_relig' in 2
    replace coef   = `b_tc'    in 3
    replace stderr = `se_lang'  in 1
    replace stderr = `se_relig' in 2
    replace stderr = `se_tc'    in 3
    gen double pval = 2 * (1 - normal(abs(coef / stderr))) if !missing(stderr)
    gen double base_coef = `b_base'
    gen double full_coef = `b_full'
    save "$MyProject/results/intermediate/gelbach_decomp.dta", replace
    restore
}


**# 11. Save expansion regression results
*------------------------------------------------------------------------------*
{
    use "`results_exp'", clear
    compress
    save "$MyProject/results/intermediate/regressions_expansion.dta", replace
    local nobs_e  = c(N)
    local nvars_e = c(k)
    di "Saved regressions_expansion.dta: N=`nobs_e' rows, K=`nvars_e' vars"
}


**# 12. Build expansion tables (LaTeX via texsave + regsave_tbl)
*------------------------------------------------------------------------------*

**# 12.1 t04_placebo: same-day placebo (absinthe vs commerce)
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "placebo_absinthe", "placebo_commerce")
    tempfile pb
    regsave_tbl using "`pb'" if spec == "placebo_absinthe", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`pb'" if spec == "placebo_commerce", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`pb'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn1 "Notes: Both votes held July 5, 1908. OLS, HC3 robust SEs in parentheses. "
    local fn2 "Col. 1: yes-vote share on absinthe ban (vote #68). Col. 2: yes-vote share on commerce article (vote #67, same day, different issue) -- placebo. "
    local fn3 "If vineyard predicts col. 1 but not col. 2, the wine-protection mechanism is issue-specific. Significance: * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 using "$MyProject/results/tables/t04_placebo.tex", ///
        replace autonumber varlabels marker(tab:placebo) ///
        title("Same-day placebo: absinthe ban (vote #68) vs commerce article (vote #67)") ///
        footnote("`fn1'`fn2'`fn3'")
}


**# 12.2 t05_subsample: subsamples + continuous-language weighting
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "german_bivariate", "german_catholic", ///
                                          "protestant_only", "german_lean_continuous", ///
                                          "french_lean_continuous")
    tempfile sub
    regsave_tbl using "`sub'" if spec == "german_bivariate", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`sub'" if spec == "german_catholic", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`sub'" if spec == "protestant_only", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`sub'" if spec == "german_lean_continuous", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`sub'" if spec == "french_lean_continuous", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`sub'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn1 "Notes: OLS with HC3 robust SEs in parentheses. "
    local fn2 "Cols. 1-2: BINARY subsample of German-speaking cantons (french_share < 0.5; N=20). Col. 3: Protestant-only (catholic_share < 0.5; N=18). "
    local fn3 "Cols. 4-5: CONTINUOUS weighting alternative (all 25 cantons). Col. 4 weights by (1 - french_share_total): German-dominant cantons get more influence. Col. 5 weights by french_share_total: French-dominant cantons get more influence. "
    local fn4 "Continuous weighting avoids the arbitrary 0.5 cutoff and uses the full sample. Significance: * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 using "$MyProject/results/tables/t05_subsample.tex", ///
        replace autonumber varlabels marker(tab:subsample) ///
        title("Subsample analysis (binary cuts) and continuous-language weighting") ///
        footnote("`fn1'`fn2'`fn3'`fn4'")
}


**# 12.2b t12_absinthe_tier: absinthe-canton tiering robustness
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "absinthe_tier_ne", "absinthe_tier_ne_vd", ///
                                          "absinthe_tier_ne_vd_ge")
    tempfile at
    regsave_tbl using "`at'" if spec == "absinthe_tier_ne", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`at'" if spec == "absinthe_tier_ne_vd", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`at'" if spec == "absinthe_tier_ne_vd_ge", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`at'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn1 "Notes: KEY spec with tiered absinthe-canton dummies. "
    local fn2 "Col. 1: NE only (Val-de-Travers heartland; Pernod 1797). Col. 2: NE + VD (incl. Yverdon Kübler & Wyss). Col. 3: NE + VD + GE (any documented production). "
    local fn3 "Vineyard coefficient should be stable across tiering choices if the wine-protection mechanism is distinct from absinthe-employment effects. HC3 SEs. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 using "$MyProject/results/tables/t12_absinthe_tier.tex", ///
        replace autonumber varlabels marker(tab:absinthe_tier) ///
        title("Absinthe-canton tiering: how does broadening the dummy change the vineyard effect?") ///
        footnote("`fn1'`fn2'`fn3'")
}


**# 12.3 t06_weighted: weighted regressions
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "weighted_pop", "weighted_votes", ///
                                          "weighted_eligible", "weighted_french", "weighted_german")
    tempfile wt
    regsave_tbl using "`wt'" if spec == "weighted_pop", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`wt'" if spec == "weighted_votes", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`wt'" if spec == "weighted_eligible", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`wt'" if spec == "weighted_french", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`wt'" if spec == "weighted_german", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`wt'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: KEY spec, weighted by 1900 population (1), 1908 ballots cast (2), eligible voters (3), French-speaking pop (4), German-speaking pop (5). HC3 robust SEs in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 using "$MyProject/results/tables/t06_weighted.tex", ///
        replace autonumber varlabels marker(tab:weighted) ///
        title("Weighted regressions: KEY spec under alternative weighting schemes") ///
        footnote("`fn'")
}


**# 12.4 t07_alt_vineyard: alternative vineyard operationalizations
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "predetermined_1894", "alt_per_1000", ///
                                          "alt_raw_ha", "alt_binary", ///
                                          "alt_per_km2", "alt_agshare")
    tempfile av
    regsave_tbl using "`av'" if spec == "predetermined_1894", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`av'" if spec == "alt_per_1000", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`av'" if spec == "alt_raw_ha", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`av'" if spec == "alt_binary", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`av'" if spec == "alt_per_km2", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`av'" if spec == "alt_agshare", ///
        name(col6) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`av'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: Each column substitutes a different vineyard measure into the KEY spec. (1) Pre-determined 1894 per capita; (2) per 1000 pop; (3) raw hectares; (4) binary >1000 ha; (5) per km^2; (6) % of agricultural land. The log(ha+1) spec is intentionally omitted: with ~32% of cantons at zero vineyards, the +1 is arbitrary and the resulting coefficient has no scale-invariant interpretation (Chen & Roth 2023, QJE). All include french_share + catholic_share. HC3 SEs. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 col6 using "$MyProject/results/tables/t07_alt_vineyard.tex", ///
        replace autonumber varlabels marker(tab:alt_vineyard) ///
        title("Alternative vineyard operationalizations: which measure matters?") ///
        footnote("`fn'")
}


**# 12.5 t08_interactions: heterogeneity (extended 2026-04-30: +german, +parcels)
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "interact_french", "interact_catholic", ///
                                          "interact_lnpop", "interact_german", ///
                                          "interact_parcels", "interact_parcel_area", ///
                                          "interact_fruit")
    tempfile ix
    regsave_tbl using "`ix'" if spec == "interact_french", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`ix'" if spec == "interact_german", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`ix'" if spec == "interact_catholic", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`ix'" if spec == "interact_lnpop", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`ix'" if spec == "interact_parcels", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`ix'" if spec == "interact_parcel_area", ///
        name(col6) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`ix'" if spec == "interact_fruit", ///
        name(col7) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`ix'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: KEY spec + one interaction term per column. (1) vineyard x french_share; (2) vineyard x german_share ('other side of the coin'); (3) vineyard x catholic_share; (4) vineyard x ln_pop; (5) vineyard x parcels_per_farm_1905; (6) vineyard x avg_parcel_area_1905; (7) vineyard x fruit_tree_density (does wine effect attenuate where fruit-spirit competing distillates dominate?). N=25 makes interactions noisy but signs are informative. french_share/german_share are not exact complements (Italian/Romansh). HC3 SEs. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 col6 col7 using "$MyProject/results/tables/t08_interactions.tex", ///
        replace autonumber varlabels marker(tab:interactions) ///
        title("Heterogeneity: vineyard interactions with language, religion, size, concentration, fruit-spirits") ///
        footnote("`fn'")
}


**# 12.6 t09_outcomes: alternative outcomes
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "outcome_margin", "outcome_yes_elig", "outcome_turnout")
    tempfile oc
    regsave_tbl using "`oc'" if spec == "outcome_margin", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`oc'" if spec == "outcome_yes_elig", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`oc'" if spec == "outcome_turnout", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`oc'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: KEY spec with alternative dependent variables. (1) Margin = (yes-no)/total x 100; (2) yes votes / eligible voters x 100; (3) turnout (%). HC3 SEs in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 using "$MyProject/results/tables/t09_outcomes.tex", ///
        replace autonumber varlabels marker(tab:outcomes) ///
        title("Alternative outcomes: margin, yes-per-eligible, turnout") ///
        footnote("`fn'")
}


**# 12.7 t10_stability: coefficient stability table
*------------------------------------------------------------------------------*
{
    * Build manually since the bivariate is in regressions.dta (script 03)
    use "$MyProject/results/intermediate/regressions.dta", clear
    keep if model == "ols" & inlist(spec, "bivariate", "catholic", "french", ///
                                          "french_catholic", "ln_pop")
    tempfile st
    regsave_tbl using "`st'" if spec == "bivariate", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`st'" if spec == "catholic", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`st'" if spec == "french", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`st'" if spec == "french_catholic", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`st'" if spec == "ln_pop", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`st'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: Sequential addition of controls (Oster 2019 framework). Vineyard coefficient sign-flips between cols. 2 and 3 (Simpson's paradox). Standard Oster monotonicity assumption is violated; the delta statistic is not interpretable here in the usual way. HC3 SEs. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 using "$MyProject/results/tables/t10_stability.tex", ///
        replace autonumber varlabels marker(tab:stability) ///
        title("Coefficient stability: sequential addition of controls (Oster 2019)") ///
        footnote("`fn'")
}


**# 12.8 t13_placebo_panel: cross-referendum falsification (15 votes 1900-1910)
*------------------------------------------------------------------------------*
{
    * One row per vote: anr, year, vineyard coef, SE, t, p, sig stars, short title.
    * Sorted by date (ascending) so the absinthe vote (#68) is in the middle.
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if var == "vineyard_per_cap" & strpos(spec, "panel_anr")
    gen int anr = real(substr(spec, 10, .))
    keep anr coef stderr tstat pval N
    rename (coef stderr tstat pval) (b se t p)

    * Merge in vote metadata (year + label) from placebo_panel
    tempfile meta
    preserve
        use "$MyProject/processed/placebo_panel.dta", clear
        keep anr vote_year vote_label
        duplicates drop
        save "`meta'", replace
    restore
    merge 1:1 anr using "`meta'", nogen keep(match)
    sort vote_year anr

    * Format coefficient with significance stars
    gen str20 b_str = ""
    replace b_str = string(b, "%9.1f") + "***" if p < 0.01
    replace b_str = string(b, "%9.1f") + "**"  if p >= 0.01 & p < 0.05
    replace b_str = string(b, "%9.1f") + "*"   if p >= 0.05 & p < 0.10
    replace b_str = string(b, "%9.1f")          if p >= 0.10
    gen str20 se_str  = "(" + string(se, "%6.0f") + ")"
    gen str8  p_str   = string(p, "%5.3f")
    gen str8  yr_str  = string(vote_year)
    gen str4  anr_str = string(anr)

    * Mark the treatment vote
    gen str4 marker = ""
    replace marker = "TREAT" if anr == 68

    * Truncate vote_label for table fit
    replace vote_label = substr(vote_label, 1, 55)

    keep anr_str yr_str vote_label b_str se_str p_str marker
    order anr_str yr_str vote_label b_str se_str p_str marker
    rename anr_str       anr
    rename yr_str        year
    rename vote_label    title
    rename b_str         vineyard_coef
    rename se_str        se
    rename p_str         pval
    label var anr           "Vote no."
    label var year          "Year"
    label var title         "Title (short)"
    label var vineyard_coef "Vineyard coef"
    label var se            "(SE)"
    label var pval          "p"
    label var marker        ""

    local fn "Notes: KEY-spec OLS (yes\_pct on vineyard\_per\_cap + french\_share + catholic\_share, HC3 SEs) run separately on each of the 15 federal popular votes between 1900 and 1910. The treatment vote (\#68, 1908 absinthe ban) is marked TREAT. Falsification logic: if vineyard\_per\_cap predicts yes-vote shares broadly, the absinthe finding is spurious; if only \#68 plus substantively related votes show non-null coefficients, the wine-protection mechanism is issue-specific. Vote \#65 (Lebensmittelgesetz, 1906) is NOT a clean placebo: this Federal Act established the alcohol-regulation authority later invoked against absinthe and was supported by wine producers because it cracked down on wine adulteration and substitute beverages. Treat \#65 as the regulatory prequel to \#68, not an independent comparison. Vote \#63 (1903 alcohol-trade regulation, distinct earlier coalition that failed) is the cleaner alcohol-regulation null. Stars: * p<0.10, ** p<0.05, *** p<0.01."
    texsave anr year title vineyard_coef se pval marker ///
        using "$MyProject/results/tables/t13_placebo_panel.tex", ///
        replace autonumber varlabels marker(tab:placebo_panel) ///
        title("Cross-referendum falsification: 15 federal votes 1900-1910") ///
        footnote("`fn'")
}


**# 12.9 f03_placebo_distribution: histogram of placebo coefs vs absinthe
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if var == "vineyard_per_cap" & strpos(spec, "panel_anr")
    gen int anr = real(substr(spec, 10, .))

    * Stata return for the absinthe coefficient (red reference line)
    summ coef if anr == 68, meanonly
    local b_absinthe = r(mean)

    * Coefficients on placebo (non-treatment) votes only
    gen byte is_treatment = (anr == 68)

    twoway (histogram coef if is_treatment == 0, ///
                width(150) start(-1500) ///
                fcolor(navy%50) lcolor(navy)) ///
           (scatteri 0 `b_absinthe' 0.005 `b_absinthe', ///
                connect(line) lcolor(red) lwidth(thick) lpattern(solid)), ///
        title("Cross-referendum falsification: vineyard coef across 1900-1910 votes") ///
        subtitle("KEY-spec coefficient on vineyard_per_cap; absinthe vote (#68) marked in red") ///
        xtitle("Vineyard_per_cap coefficient (KEY spec, HC3)") ///
        ytitle("Density (placebo votes, N=14)") ///
        legend(off) ///
        xlabel(-1500(500)1500) ///
        note("Red vertical line: absinthe vote (#68) coefficient = " + string(`b_absinthe', "%9.1f") + ". Histogram: 14 placebo votes (1900-1910 excluding #68).")
    graph export "$MyProject/results/figures/f03_placebo_distribution.pdf", replace as(pdf)
    graph close
}


**# 12.10 t14_new_controls: KEY + each strategist 2026-04-30 control
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    keep if model == "ols" & inlist(spec, "ctrl_migration", "ctrl_migration_pc", ///
                                          "ctrl_parcels", "ctrl_parcel_area", ///
                                          "ctrl_fruit", "ctrl_all_new")
    tempfile nc
    regsave_tbl using "`nc'" if spec == "ctrl_migration", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`nc'" if spec == "ctrl_migration_pc", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`nc'" if spec == "ctrl_parcels", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`nc'" if spec == "ctrl_parcel_area", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`nc'" if spec == "ctrl_fruit", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`nc'" if spec == "ctrl_all_new", ///
        name(col6) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    use "`nc'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"
    local fn "Notes: KEY spec (vineyard_per_cap + french_share + catholic_share) plus additional control(s). (1) net migration 1900/10 level; (2) per capita; (3) parcels per farm 1905 (operational fragmentation); (4) avg parcel area 1905 in ha/parcel (constructed: agland_1912/(farms_1905*parcels_per_farm_1905)); (5) fruit-tree density (1951 in trees/capita; geographic proxy for 1908 because pre-vote-year canton coverage is unavailable; competing-spirits feedstock control); (6) all three canonical proxies jointly: avg parcel area + fruit-tree density + migration level. Per user 2026-04-30 the canton-level wine-industry-employment search is definitively closed; vineyard_per_cap + avg_parcel_area_1905 + fruit_tree_density is the canonical proxy set. Substantive note: in the Swiss context avg_parcel_area is NEGATIVELY correlated with vineyard_per_cap (rho=-0.49) -- alpine cantons have huge parcels and no vineyards -- so the Olson 1965 'concentration -> mobilization' prediction does NOT cleanly apply to Swiss land geography. HC3 SEs. * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 col6 using "$MyProject/results/tables/t14_new_controls.tex", ///
        replace autonumber varlabels marker(tab:new_controls) ///
        title("Robustness to canonical wine-industry-size proxies (vineyard\_per\_cap + avg\_parcel\_area + fruit\_trees + migration)") ///
        footnote("`fn'")
}


**# 12.11 t15_gelbach: decomposition of bivariate-to-KEY coefficient change
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/gelbach_decomp.dta", clear

    * Format coefficient with significance stars
    gen str20 coef_str = ""
    replace coef_str = string(coef, "%9.1f") + "***" if pval < 0.01  & !missing(stderr)
    replace coef_str = string(coef, "%9.1f") + "**"  if pval >= 0.01 & pval < 0.05 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f") + "*"   if pval >= 0.05 & pval < 0.10 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f")          if pval >= 0.10 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f")          if missing(stderr)
    gen str20 se_str = "(" + string(stderr, "%6.1f") + ")" if !missing(stderr)
    replace se_str = "" if missing(stderr)
    gen str8  p_str  = string(pval, "%5.3f") if !missing(stderr)
    replace p_str = "" if missing(stderr)

    gen str30 component_label = ""
    replace component_label = "Language (french\_share)"  if component == "LANG"
    replace component_label = "Religion (catholic\_share)" if component == "RELIG"
    replace component_label = "Total (sum = b1base minus b1full)" if component == "TOTAL"

    keep component_label coef_str se_str p_str
    order component_label coef_str se_str p_str
    rename component_label component
    label var component "Contribution to coefficient change"
    label var coef_str  "Delta"
    label var se_str    "(SE)"
    label var p_str     "p"

    * Pull base/full vineyard coefficients for the table notes
    use "$MyProject/results/intermediate/gelbach_decomp.dta", clear
    summ base_coef in 1, meanonly
    local b_base_disp = r(mean)
    summ full_coef in 1, meanonly
    local b_full_disp = r(mean)
    local sum_check : di %5.1f (`b_base_disp' - `b_full_disp')

    * Re-load formatted table
    use "$MyProject/results/intermediate/gelbach_decomp.dta", clear
    gen str20 coef_str = ""
    replace coef_str = string(coef, "%9.1f") + "***" if pval < 0.01  & !missing(stderr)
    replace coef_str = string(coef, "%9.1f") + "**"  if pval >= 0.01 & pval < 0.05 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f") + "*"   if pval >= 0.05 & pval < 0.10 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f")          if pval >= 0.10 & !missing(stderr)
    replace coef_str = string(coef, "%9.1f")          if missing(stderr)
    gen str20 se_str = "(" + string(stderr, "%6.1f") + ")" if !missing(stderr)
    replace se_str = "" if missing(stderr)
    gen str8  p_str  = string(pval, "%5.3f") if !missing(stderr)
    replace p_str = "" if missing(stderr)
    gen str30 component_label = ""
    replace component_label = "Language (french\_share)"  if component == "LANG"
    replace component_label = "Religion (catholic\_share)" if component == "RELIG"
    replace component_label = "Total (sum)" if component == "TOTAL"
    keep component_label coef_str se_str p_str
    order component_label coef_str se_str p_str
    rename component_label component
    label var component "Contribution to vineyard coef. change (b1base - b1full)"
    label var coef_str  "Delta"
    label var se_str    "(SE)"
    label var p_str     "p"

    local b_base_str : di %6.1f `b_base_disp'
    local b_full_str : di %6.1f `b_full_disp'
    local diff_str   : di %6.1f (`b_base_disp' - `b_full_disp')
    local fn "Notes: Gelbach (2016) conditional decomposition of the change in the vineyard_per_cap coefficient between the bivariate spec (b1base = `b_base_str') and the KEY spec adding french_share + catholic_share (b1full = `b_full_str'). Delta is the contribution of each x2 group to b1base minus b1full (= `diff_str'). The Simpson sign-flip means deltas are NEGATIVE (the controls move the coefficient UP from negative to positive). Implementation: official b1x2 package by Gelbach (2014), v4.1.0, vendored at libraries/stata/b/. Hand-validated against the b1x2 identity (assertion in 05_expansion.do sec 10.9). Robust SEs (HC1; b1x2 does not support HC3). Methods reference: analysis/documentation/methods/gelbach_decomposition.md. Significance: * p<0.10, ** p<0.05, *** p<0.01."
    texsave component coef_str se_str p_str ///
        using "$MyProject/results/tables/t15_gelbach.tex", ///
        replace autonumber varlabels marker(tab:gelbach) ///
        title("Gelbach (2016) decomposition: which controls drive the Simpson sign-flip?") ///
        footnote("`fn'")
}


**# 12.12 f04_marginsplot_french: vineyard effect across (1 - french_share)
*------------------------------------------------------------------------------*
{
    * Per strategist 2026-04-30: marginal-effects plot of vine effect across
    * non-French intensity. Uses the existing vine x french_share interaction.
    * Marginal effect dy/dx(vineyard_per_cap) at french_share in (0, 0.25, 0.5, 0.75, 1).
    use "$MyProject/processed/absinthe_analysis.dta", clear

    qui reg yes_pct c.vineyard_per_cap##c.french_share catholic_share, vce(hc3)
    margins, dydx(vineyard_per_cap) at(french_share = (0(0.1)1))

    marginsplot, ///
        graphregion(fcolor(white)) ///
        title("Marginal effect of vineyard area, by French-language share", size(medsmall)) ///
        ytitle("dy/dx of vineyard_per_cap (HC3)") ///
        xtitle("French share (Ger.+Fr. denom.)") ///
        recast(line) recastci(rarea) ///
        ciopts(color(navy%30)) plotopts(lcolor(navy) lwidth(medthick)) ///
        addplot(scatteri 0 0 0 1, recast(line) lcolor(black) lpattern(dash) lwidth(thin) ///
                legend(label(1 "Marginal effect") label(2 "95% CI") label(3 "Zero line"))) ///
        note("Marginal effect of vineyard_per_cap on yes_pct evaluated across the observed range of french_share. Spec: yes_pct on vineyard x french_share + catholic_share, HC3 robust SEs. The 'two sides of the coin' note: substituting german_share = 1 - french_share would mirror this plot. Negative slope = wine effect attenuates in French cantons (Simpson confound).", size(vsmall))
    graph export "$MyProject/results/figures/f04_marginsplot_french.pdf", replace as(pdf)
    graph close
}


**# 13. Sanity-check assertions for the expansion analyses
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear

    * Placebo: vineyard coef on commerce (vote #67) should be SMALLER in
    * absolute value than on absinthe (vote #68). If the wine effect were
    * generic "wine canton attitude," it would show up on the commerce vote too.
    qui sum coef if var == "vineyard_per_cap" & spec == "placebo_absinthe"
    local b_abs = r(mean)
    qui sum coef if var == "vineyard_per_cap" & spec == "placebo_commerce"
    local b_com = r(mean)
    di _n "Placebo check: |b_absinthe|=" %6.1f abs(`b_abs') ///
       "  |b_commerce|=" %6.1f abs(`b_com')
    assert abs(`b_com') < abs(`b_abs')

    * German subsample: vineyard coef should still be POSITIVE (no Simpson)
    qui sum coef if var == "vineyard_per_cap" & spec == "german_catholic"
    di "German subsample (+catholic): vineyard coef = " %6.1f r(mean)
    assert r(mean) > 0

    * Pre-determined 1894 measure: vineyard coef should still be POSITIVE
    qui sum coef if var == "vineyard_per_cap_1894" & spec == "predetermined_1894"
    di "Pre-determined 1894 measure: vineyard coef = " %6.1f r(mean)
    assert r(mean) > 0

    * Weighted regressions: vineyard coef positive in at least 4 of 5 weighting schemes
    local pos_count = 0
    foreach s in weighted_pop weighted_votes weighted_eligible weighted_french weighted_german {
        qui sum coef if var == "vineyard_per_cap" & spec == "`s'"
        if r(mean) > 0 local ++pos_count
    }
    di "Weighted regressions: vineyard coef positive in `pos_count' of 5 schemes"
    assert `pos_count' >= 4

    * Cross-referendum falsification: absinthe vote (#68) coef should be in the
    * upper half of the placebo distribution. Less stringent than "extreme tail"
    * because we have known corroborating votes (#65 food safety, ~+1225).
    qui sum coef if var == "vineyard_per_cap" & spec == "panel_anr68"
    local b_treat = r(mean)
    qui count if var == "vineyard_per_cap" & strpos(spec, "panel_anr") & coef >= `b_treat'
    local n_extreme = r(N)
    di "Falsification: " `n_extreme' " of 15 placebo coefs >= absinthe coef (" %6.1f `b_treat' ")"
    * Absinthe should rank in the top 5 of 15 (i.e., n_extreme including itself <= 5)
    assert `n_extreme' <= 5

    * Vote #63 (alcohol regulation, 1903): vineyard coef should NOT be
    * significantly positive. If vineyard cantons opposed federal alcohol
    * regulation generically, the absinthe finding loses its issue-specificity.
    qui sum pval if var == "vineyard_per_cap" & spec == "panel_anr63"
    di "Vote #63 (alcohol regulation): vineyard p = " %5.3f r(mean)
    assert r(mean) > 0.10  // null at 10% level

    * --- Strategist 2026-04-30 controls ---
    * KEY + net_migration: vineyard coef should remain POSITIVE and reasonable
    qui sum coef if var == "vineyard_per_cap" & spec == "ctrl_migration"
    di "KEY + net_migration: vineyard coef = " %6.1f r(mean)
    assert r(mean) > 0
    assert inrange(r(mean), 200, 700)

    * KEY + parcels_per_farm: vineyard coef should remain POSITIVE
    qui sum coef if var == "vineyard_per_cap" & spec == "ctrl_parcels"
    di "KEY + parcels_per_farm: vineyard coef = " %6.1f r(mean)
    assert r(mean) > 0

    * Gelbach: language-group delta should be NEGATIVE (because adding language
    * moves the vineyard coef UP, so the delta in b1base - b1full is negative
    * for the language group). Religion-group delta near zero per Stigler/Simpson
    * framing (it's the language confound, not religion).
    use "$MyProject/results/intermediate/gelbach_decomp.dta", clear
    summ coef if component == "LANG", meanonly
    di "Gelbach LANG delta: " %6.1f r(mean)
    assert r(mean) < 0
    assert r(mean) < -300  // dominant contribution

    summ coef if component == "TOTAL", meanonly
    local gel_total = r(mean)
    di "Gelbach TOTAL (b1base - b1full): " %6.1f `gel_total'
    assert `gel_total' < 0  // negative because Simpson sign-flip moves coef up

    * Restore the regressions_expansion.dta context for downstream code (none
    * after this in the assertion block, but defensive)
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear

    di _n "*** ALL EXPANSION ASSERTIONS PASSED ***"
}


**# 14. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    _codebook_update using "$MyProject/results/intermediate/regressions_expansion.dta", ///
        script("05_expansion.do")
    use "$MyProject/results/intermediate/regressions_expansion.dta", clear
    local nobs  = c(N)
    local nvars = c(k)
    _inventory_append, sheet("datasets") ///
        row("created|results/intermediate/regressions_expansion.dta|`nobs'|`nvars'|.|05_expansion.do")

    foreach t in t04_placebo t05_subsample t06_weighted t07_alt_vineyard ///
                 t08_interactions t09_outcomes t10_stability t12_absinthe_tier ///
                 t13_placebo_panel t14_new_controls t15_gelbach {
        _inventory_append, sheet("outputs") ///
            row("generated|results/tables/`t'.tex|table|05_expansion.do")
    }
    foreach f in f03_placebo_distribution f04_marginsplot_french {
        _inventory_append, sheet("outputs") ///
            row("generated|results/figures/`f'.pdf|figure|05_expansion.do")
    }
    _inventory_append, sheet("scripts") ///
        row("05_expansion.do|.|expansion analyses: placebo, subsamples, weighting, alt measures, interactions, outcomes, NE gap, Oster, cross-referendum panel, new controls, Gelbach decomp, marginsplot|.")
}

** EOF
