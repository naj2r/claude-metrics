/*==============================================================================
 03_regress.do
 Purpose:  Estimate OLS specifications (bivariate -> + controls -> KEY spec ->
           more controls), fractional logit, and robustness checks
           (leave-one-out, exclude NE+GE, randomization inference).
           Save coefficients via regsave for table assembly in script 4.
 Input:    $MyProject/processed/absinthe_analysis.dta
 Output:   $MyProject/results/intermediate/regressions.dta
           $MyProject/results/intermediate/ri_distribution.dta
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

    tempfile results
}


**# 1. OLS progressive specifications
*------------------------------------------------------------------------------*

**# 1.1 Bivariate: yes_pct ~ vineyard_per_cap
*------------------------------------------------------------------------------*
{
    reg yes_pct vineyard_per_cap, vce(hc3)
    estimates store ols_biv
    regsave using "`results'", t p autoid replace ///
        addlabel(spec, "bivariate", model, "ols")
}


**# 1.2 + catholic_share
*------------------------------------------------------------------------------*
{
    reg yes_pct vineyard_per_cap catholic_share, vce(hc3)
    estimates store ols_cath
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "catholic", model, "ols")
}


**# 1.3 + french_share
*------------------------------------------------------------------------------*
{
    reg yes_pct vineyard_per_cap french_share, vce(hc3)
    estimates store ols_french
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "french", model, "ols")
}


**# 1.4 + french_share + catholic_share  (KEY, subset denominators)
*------------------------------------------------------------------------------*
{
    * This is the headline specification — vineyard coef should flip to positive.
    * Uses subset denominators: french/(de+fr), catholic/(prot+cath).
    reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    estimates store ols_key
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "french_catholic", model, "ols")
}


**# 1.4b KEY spec with TOTAL-POP share denominators (matches prior analysis)
*------------------------------------------------------------------------------*
{
    * Same as 1.4 but with shares as fraction of total population. Reproduces
    * the Brainstorm-Absinthe coefficients exactly (vineyard ~437, p~0.063).
    reg yes_pct vineyard_per_cap french_share_total catholic_share_total, vce(hc3)
    estimates store ols_key_total
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "french_catholic_total", model, "ols")
}


**# 1.5 + ln_pop
*------------------------------------------------------------------------------*
{
    reg yes_pct vineyard_per_cap french_share catholic_share ln_pop, vce(hc3)
    estimates store ols_pop
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "ln_pop", model, "ols")
}


**# 1.6 + absinthe_dummy
*------------------------------------------------------------------------------*
{
    reg yes_pct vineyard_per_cap french_share catholic_share ln_pop absinthe_dummy, vce(hc3)
    estimates store ols_full
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "absinthe_dummy", model, "ols")
}


**# 2. Fractional logit
*------------------------------------------------------------------------------*

**# 2.1 Bivariate fracreg
*------------------------------------------------------------------------------*
{
    * fracreg requires DV on [0,1]; use yes_frac (= yes_pct/100). Cannot use
    * vce(hc3) — fracreg uses its own robust estimator.
    fracreg logit yes_frac vineyard_per_cap, vce(robust)
    margins, dydx(*) post
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "bivariate", model, "fracreg_ame")
}


**# 2.2 KEY spec fracreg with AMEs
*------------------------------------------------------------------------------*
{
    fracreg logit yes_frac vineyard_per_cap french_share catholic_share, vce(robust)
    margins, dydx(*) post
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "french_catholic", model, "fracreg_ame")
}


**# 2.3 Full-controls fracreg with AMEs
*------------------------------------------------------------------------------*
{
    fracreg logit yes_frac vineyard_per_cap french_share catholic_share ln_pop absinthe_dummy, ///
        vce(robust)
    margins, dydx(*) post
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "absinthe_dummy", model, "fracreg_ame")
}


**# 3. Robustness
*------------------------------------------------------------------------------*

**# 3.1 Leave-one-out (KEY spec, drop each canton in turn)
*------------------------------------------------------------------------------*
{
    * Loop over the 25 cantons, dropping one at a time and re-estimating the
    * KEY spec. Save the vineyard_per_cap coefficient from each.
    levelsof canton_code, local(cantons) clean
    foreach c of local cantons {
        qui reg yes_pct vineyard_per_cap french_share catholic_share ///
            if canton_code != "`c'", vce(hc3)
        regsave using "`results'", t p autoid append ///
            addlabel(spec, "loo", model, "ols", dropped, "`c'")
    }
}


**# 3.2 Exclude NE+GE (KEY spec on N=23)
*------------------------------------------------------------------------------*
{
    * The two cantons that rejected the ban — possible high-leverage outliers
    reg yes_pct vineyard_per_cap french_share catholic_share ///
        if canton_code != "NE" & canton_code != "GE", vce(hc3)
    estimates store ols_no_ne_ge
    regsave using "`results'", t p autoid append ///
        addlabel(spec, "excl_ne_ge", model, "ols")
}


**# 3.3 Randomization inference (10,000 permutations of vineyard_per_cap)
*------------------------------------------------------------------------------*
{
    * Permute vineyard_per_cap across cantons; re-estimate KEY spec each time;
    * record the t-stat on vineyard_per_cap. RI p-value is the share of
    * permuted t-stats with |t| >= |t_observed|.
    * Seed matches the prior Brainstorm-Absinthe analysis (20260409) so
    * differences in p-values reflect rep-count and method, not RNG draws.
    * (Original used 5,000 manual permutations; we use Stata's `permute`
    * with 10,000 reps. Bootstrap-style full inference is a later expansion.)
    set seed 20260409

    * Save the actual t-stat for reference
    qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    local t_obs = _b[vineyard_per_cap] / _se[vineyard_per_cap]
    di "Observed t-stat on vineyard_per_cap (KEY spec): " %6.3f `t_obs'

    * Permute and save the distribution
    permute vineyard_per_cap ///
        t_vineyard = (_b[vineyard_per_cap] / _se[vineyard_per_cap]), ///
        reps(10000) rseed(20260409) ///
        saving("$MyProject/results/intermediate/ri_distribution.dta", replace) ///
        nodots: ///
        reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)

    * Compute and report two-sided RI p-value
    preserve
        use "$MyProject/results/intermediate/ri_distribution.dta", clear
        gen byte more_extreme = abs(t_vineyard) >= abs(`t_obs')
        qui sum more_extreme
        local ri_pval = r(mean)
        di "Randomization-inference 2-sided p-value: " %6.4f `ri_pval'
        di "  (proportion of " c(N) " permutations with |t| >= |t_obs|=" %6.3f `t_obs' ")"
    restore
}


**# 4. Save regression results
*------------------------------------------------------------------------------*
{
    use "`results'", clear
    compress
    save "$MyProject/results/intermediate/regressions.dta", replace
    local nobs_reg  = c(N)
    local nvars_reg = c(k)
    di "Saved regressions.dta: N=`nobs_reg' rows, K=`nvars_reg' vars"
}


**# 5. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    _codebook_update using "$MyProject/results/intermediate/regressions.dta", ///
        script("03_regress.do")
    use "$MyProject/results/intermediate/regressions.dta", clear
    local nobs  = c(N)
    local nvars = c(k)
    _inventory_append, sheet("datasets") ///
        row("created|results/intermediate/regressions.dta|`nobs'|`nvars'|.|03_regress.do")
    _inventory_append, sheet("datasets") ///
        row("created|results/intermediate/ri_distribution.dta|10000|.|.|03_regress.do")
    _inventory_append, sheet("scripts") ///
        row("03_regress.do|.|estimates OLS, fracreg, leave-one-out, exclude-NE-GE, randomization inference|.")
}

** EOF
