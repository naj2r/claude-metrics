/*==============================================================================
 04_tables.do
 Purpose:  Generate LaTeX tables, PDF figures, and assertion checks on key
           reported numbers (Reif submission checklist).
 Input:    $MyProject/processed/absinthe_analysis.dta
           $MyProject/results/intermediate/regressions.dta
 Output:   $MyProject/results/tables/t01_summary.tex
           $MyProject/results/tables/t02_ols.tex
           $MyProject/results/tables/t03_fracreg.tex
           $MyProject/results/figures/f01_scatter_raw.pdf
           $MyProject/results/figures/f02_scatter_partial.pdf
 Author:   Nicholas A Jensen
 Date:     2026-04-30
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Setup
*------------------------------------------------------------------------------*
{
    tempfile work
}


**# 1. Summary statistics table
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/absinthe_analysis.dta", clear

    * Compute mean, SD, min, max, count for each analysis variable
    preserve
        collapse (mean) mean_yes_pct=yes_pct mean_vine=vineyard_per_cap ///
                        mean_french=french_share mean_cath=catholic_share ///
                        mean_lnpop=ln_pop mean_density=pop_density_1900 ///
                 (sd)   sd_yes_pct=yes_pct sd_vine=vineyard_per_cap ///
                        sd_french=french_share sd_cath=catholic_share ///
                        sd_lnpop=ln_pop sd_density=pop_density_1900 ///
                 (min)  min_yes_pct=yes_pct min_vine=vineyard_per_cap ///
                        min_french=french_share min_cath=catholic_share ///
                        min_lnpop=ln_pop min_density=pop_density_1900 ///
                 (max)  max_yes_pct=yes_pct max_vine=vineyard_per_cap ///
                        max_french=french_share max_cath=catholic_share ///
                        max_lnpop=ln_pop max_density=pop_density_1900, ///
                 fast

        * Reshape to one row per variable
        gen byte rowid = 1
        reshape long mean_ sd_ min_ max_, i(rowid) j(varname) string
        drop rowid
        rename mean_ mean
        rename sd_   sd
        rename min_  min
        rename max_  max
        gen long n = 25

        * Map short names to display labels
        gen str40 variable = ""
        replace variable = "Yes-vote share (\%, 1908)"          if varname == "yes_pct"
        replace variable = "Vineyard per capita (ha/person)"    if varname == "vine"
        replace variable = "French-language share"              if varname == "french"
        replace variable = "Catholic share"                     if varname == "cath"
        replace variable = "Log population (1900)"              if varname == "lnpop"
        replace variable = "Population density (per km^2)"      if varname == "density"
        drop varname

        * Order by analytical importance
        gen byte sortord = .
        replace sortord = 1 if variable == "Yes-vote share (\%, 1908)"
        replace sortord = 2 if variable == "Vineyard per capita (ha/person)"
        replace sortord = 3 if variable == "French-language share"
        replace sortord = 4 if variable == "Catholic share"
        replace sortord = 5 if variable == "Log population (1900)"
        replace sortord = 6 if variable == "Population density (per km^2)"
        isid sortord  // confirm uniqueness before sort (soft rule 12)
        sort sortord
        drop sortord

        * Format numbers as strings (3 sig figs)
        format mean sd min max %9.3gc
        tostring mean sd min max, format(%9.3gc) replace force
        order variable mean sd min max n

        label var variable "Variable"
        label var mean     "Mean"
        label var sd       "Std. dev."
        label var min      "Min"
        label var max      "Max"
        label var n        "N"

        local fn1 "Notes: Cross-section of N=25 cantons (BE+JU combined; JU did not exist in 1908). "
        local fn2 "Yes-vote share is from the 5 July 1908 federal vote on the absinthe ban (vote no. 68). "
        local fn3 "Vineyard area is from HSSO Table I.01 (1905); other covariates from HSSO B.01a/b, B.27, B.32 (1900 census)."
        texsave variable mean sd min max n using "$MyProject/results/tables/t01_summary.tex", ///
            replace varlabels marker(tab:summary_stats) ///
            title("Summary statistics: 25 Swiss cantons in the 1908 absinthe-ban vote") ///
            footnote("`fn1'`fn2'`fn3'")
    restore
}


**# 2. OLS regression table
*------------------------------------------------------------------------------*

**# 2.1 Format with regsave_tbl (6 progressive specs)
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions.dta", clear
    keep if model == "ols" & inlist(spec, "bivariate", "catholic", "french", ///
                                          "french_catholic", "french_catholic_total", ///
                                          "ln_pop", "absinthe_dummy")

    * 7 columns: 3 progressive specs (biv, +cath, +french) + KEY (subset) + KEY (total-pop) + +ln_pop + +absinthe
    tempfile tbl
    regsave_tbl using "`tbl'" if spec == "bivariate", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`tbl'" if spec == "catholic", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`tbl'" if spec == "french", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`tbl'" if spec == "french_catholic", ///
        name(col4) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`tbl'" if spec == "french_catholic_total", ///
        name(col5) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`tbl'" if spec == "ln_pop", ///
        name(col6) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`tbl'" if spec == "absinthe_dummy", ///
        name(col7) asterisk(10 5 1) parentheses(stderr) sigfig(3) append


**# 2.2 Clean variable names (clean_vars)
*------------------------------------------------------------------------------*
    use "`tbl'", clear

    * Drop ID, t-stat, and pval rows; keep coefficient and SE rows
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")

    * Apply project-specific variable label mapping
    clean_vars var


**# 2.3 texsave to LaTeX
*------------------------------------------------------------------------------*
    label var var "Variable"

    local ols_fn1 "Notes: OLS with HC3 (Davidson-MacKinnon) robust standard errors in parentheses. "
    local ols_fn2 "N=25 Swiss cantons. DV: canton-level yes-vote share (0-100\%) for the 5 July 1908 federal vote on the absinthe ban. "
    local ols_fn3 "UNITS: vineyard\_per\_cap = hectares of vineyard area in 1905 / 1900 population (ha/person; canton range 0.000 [UR] to 0.023 [VD], mean 0.006). Substantive magnitudes in Table 11. "
    local ols_fn4 "SHARE DENOMINATORS: cols. 1-4 use SUBSET denominators (french/(de+fr); cath/(prot+cath)); col. 5 uses TOTAL-POP denominators (french/pop; cath/pop, matching prior Brainstorm-Absinthe analysis). Both yield the headline sign-flip. "
    local ols_fn5 "Col. 4 is the headline KEY spec. Vineyard coefficient sign-flips from negative (col. 1, bivariate) to positive (cols. 4-7) once language and religion are controlled. Significance: * p<0.10, ** p<0.05, *** p<0.01."
    texsave var col1 col2 col3 col4 col5 col6 col7 ///
        using "$MyProject/results/tables/t02_ols.tex", ///
        replace autonumber varlabels marker(tab:ols_main) ///
        title("Vineyard share and the 1908 absinthe-ban yes-vote: OLS specifications") ///
        footnote("`ols_fn1'`ols_fn2'`ols_fn3'`ols_fn4'`ols_fn5'")
}


**# 3. Fractional logit table
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions.dta", clear
    keep if model == "fracreg_ame" & inlist(spec, "bivariate", "french_catholic", "absinthe_dummy")

    tempfile fbl
    regsave_tbl using "`fbl'" if spec == "bivariate", ///
        name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    regsave_tbl using "`fbl'" if spec == "french_catholic", ///
        name(col2) asterisk(10 5 1) parentheses(stderr) sigfig(3) append
    regsave_tbl using "`fbl'" if spec == "absinthe_dummy", ///
        name(col3) asterisk(10 5 1) parentheses(stderr) sigfig(3) append

    use "`fbl'", clear
    drop if inlist(var, "_id") | strpos(var, "_id_") | strpos(var, "tstat") | strpos(var, "pval")
    clean_vars var
    label var var "Variable"

    local fr_fn1 "Notes: Average marginal effects from fractional logit (Papke and Wooldridge 1996). "
    local fr_fn2 "Dependent variable is yes-vote share on the [0,1] interval. Robust standard errors in parentheses. "
    local fr_fn3 "N=25 Swiss cantons. Significance: * p<0.10, ** p<0.05, *** p<0.01. "
    local fr_fn4 "Marginal effects are on the [0,1] scale; multiply by 100 to compare with OLS percentage-point coefficients."
    texsave var col1 col2 col3 ///
        using "$MyProject/results/tables/t03_fracreg.tex", ///
        replace autonumber varlabels marker(tab:fracreg) ///
        title("Fractional logit (average marginal effects): yes-vote share on vineyard per capita") ///
        footnote("`fr_fn1'`fr_fn2'`fr_fn3'`fr_fn4'")
}


**# 4. Raw scatter: yes_pct vs vineyard_per_cap
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/absinthe_analysis.dta", clear

    twoway (scatter yes_pct vineyard_per_cap, mlabel(canton_code) mlabposition(3) msize(small)) ///
           (lfit yes_pct vineyard_per_cap, lcolor(navy) lwidth(medthick)), ///
        graphregion(fcolor(white)) ///
        ytitle("Yes-vote share (%, 1908 absinthe ban)") ///
        xtitle("Vineyard area per capita (ha/person, 1905)") ///
        title("Raw bivariate: vineyard area vs absinthe-ban yes-vote", size(medsmall)) ///
        legend(off) ///
        note("N=25 Swiss cantons. Slope appears negative/null without controls.", size(small))

    graph export "$MyProject/results/figures/f01_scatter_raw.pdf", as(pdf) replace
}


**# 5. Partial-residuals scatter (Frisch-Waugh-Lovell)
*------------------------------------------------------------------------------*
{
    * Residualize yes_pct on french_share + catholic_share
    qui reg yes_pct french_share catholic_share, vce(hc3)
    predict double yres, residuals

    * Residualize vineyard_per_cap on french_share + catholic_share
    qui reg vineyard_per_cap french_share catholic_share, vce(hc3)
    predict double xres, residuals

    twoway (scatter yres xres, mlabel(canton_code) mlabposition(3) msize(small)) ///
           (lfit yres xres, lcolor(maroon) lwidth(medthick)), ///
        graphregion(fcolor(white)) ///
        ytitle("Yes-vote share, residual (%)") ///
        xtitle("Vineyard per capita, residual (ha/person)") ///
        title("Partial-residuals: vineyard vs yes-vote, conditional", size(medsmall)) ///
        legend(off) ///
        note("Residuals from regressing each variable on French-language share + Catholic share." ///
             " Slope = OLS coefficient on vineyard per cap. in the conditional regression (Frisch-Waugh-Lovell).", size(vsmall))

    graph export "$MyProject/results/figures/f02_scatter_partial.pdf", as(pdf) replace
}


**# 6. Sanity-check assertions (Reif submission checklist)
*------------------------------------------------------------------------------*
{
    use "$MyProject/results/intermediate/regressions.dta", clear

    * (a) Bivariate vineyard coefficient is NEGATIVE (Simpson's-paradox setup)
    qui sum coef if var == "vineyard_per_cap" & spec == "bivariate" & model == "ols", meanonly
    di "Bivariate vineyard coef: " %8.2f r(mean)
    assert r(mean) < 0

    * (b) KEY spec vineyard coefficient is POSITIVE and in [300, 600]
    *     (per-project verification target — sign-flip is the headline finding)
    qui sum coef if var == "vineyard_per_cap" & spec == "french_catholic" & model == "ols", meanonly
    di "Conditional KEY spec (subset shares) vineyard coef: " %8.2f r(mean)
    assert r(mean) > 0
    assert inrange(r(mean), 300, 600)

    * (b') KEY spec with TOTAL-POP share denominators: also in [300, 600]
    *     This reproduces the prior Brainstorm-Absinthe coefficient (~437).
    qui sum coef if var == "vineyard_per_cap" & spec == "french_catholic_total" & model == "ols", meanonly
    di "Conditional KEY spec (total-pop shares) vineyard coef: " %8.2f r(mean)
    assert r(mean) > 0
    assert inrange(r(mean), 300, 600)

    * (c) KEY spec (subset) p-value is significant at 5% level
    qui sum pval if var == "vineyard_per_cap" & spec == "french_catholic" & model == "ols", meanonly
    di "Conditional KEY spec (subset) p-value: " %6.4f r(mean)
    assert r(mean) < 0.05

    * (c') KEY spec (total-pop) p-value is at most 10% (loosely significant)
    qui sum pval if var == "vineyard_per_cap" & spec == "french_catholic_total" & model == "ols", meanonly
    di "Conditional KEY spec (total-pop) p-value: " %6.4f r(mean)
    assert r(mean) < 0.10

    * (d) Sample size is 25 for all main OLS specs
    qui sum N if var == "vineyard_per_cap" & model == "ols" & spec != "loo" & spec != "excl_ne_ge", meanonly
    di "OLS sample size (mean): " r(mean)
    assert r(mean) == 25

    * (e) Excluding NE+GE: sample size is 23 and coefficient remains positive
    qui sum coef if var == "vineyard_per_cap" & spec == "excl_ne_ge" & model == "ols", meanonly
    assert r(mean) > 0
    qui sum N if var == "vineyard_per_cap" & spec == "excl_ne_ge" & model == "ols", meanonly
    assert r(mean) == 23

    * (f) Leave-one-out: vineyard coefficient never reaches zero or negative
    qui sum coef if var == "vineyard_per_cap" & spec == "loo", meanonly
    di "Leave-one-out coef range: [" %6.1f r(min) ", " %6.1f r(max) "]"
    assert r(min) > 0

    di _n "*** ALL SANITY-CHECK ASSERTIONS PASSED ***"
}


**# 6.5 Magnitudes table (substantive translation of vineyard coefficients)
*------------------------------------------------------------------------------*
{
    * The vineyard_per_cap coefficient (ha/person scale) is mathematically
    * correct but reads as absurdly large to a non-specialist (no canton has
    * 1 ha/person). This table converts each spec's coefficient into a
    * predicted yes-vote shift at four meaningful canton contrasts:
    *
    *   - 1-SD increase    (one standard deviation in vineyard_per_cap)
    *   - Avg wine canton  (mean vineyard_per_cap)
    *   - NE vs UR         (Neuchatel vs no-vineyard Uri)
    *   - VD vs UR         (Vaud, the wine-richest, vs Uri)
    *
    * Each entry = spec_coefficient * delta_vineyard, in percentage points.

    * Step 1: get the canton-level vineyard values we need
    preserve
        use "$MyProject/processed/absinthe_analysis.dta", clear
        qui sum vineyard_per_cap
        local sd_vine   = r(sd)
        local mean_vine = r(mean)
        qui sum vineyard_per_cap if canton_code == "NE"
        local ne_vine = r(mean)
        qui sum vineyard_per_cap if canton_code == "UR"
        local ur_vine = r(mean)
        qui sum vineyard_per_cap if canton_code == "VD"
        local vd_vine = r(mean)
    restore

    * Step 2: get vineyard coefficients for the 5 main OLS specs
    preserve
        use "$MyProject/results/intermediate/regressions.dta", clear
        keep if model == "ols" & inlist(spec, "bivariate", "french_catholic", ///
                                              "french_catholic_total", "ln_pop", ///
                                              "absinthe_dummy")
        keep if var == "vineyard_per_cap"
        keep spec coef pval

        * Step 3: compute predicted shifts (in percentage points)
        gen double effect_1sd  = coef * `sd_vine'
        gen double effect_avg  = coef * (`mean_vine' - `ur_vine')
        gen double effect_ne   = coef * (`ne_vine'   - `ur_vine')
        gen double effect_vd   = coef * (`vd_vine'   - `ur_vine')

        * Step 4: format as strings for texsave
        gen str20 spec_label = ""
        replace spec_label = "Bivariate"                       if spec == "bivariate"
        replace spec_label = "KEY (subset shares)"             if spec == "french_catholic"
        replace spec_label = "KEY (total-pop shares)"          if spec == "french_catholic_total"
        replace spec_label = "KEY + log pop."                  if spec == "ln_pop"
        replace spec_label = "Full + absinthe dummy"           if spec == "absinthe_dummy"

        * Order specs by analytical importance
        gen byte sortord = .
        replace sortord = 1 if spec == "bivariate"
        replace sortord = 2 if spec == "french_catholic"
        replace sortord = 3 if spec == "french_catholic_total"
        replace sortord = 4 if spec == "ln_pop"
        replace sortord = 5 if spec == "absinthe_dummy"
        isid sortord
        sort sortord
        drop sortord spec

        * Format coefficient with stars based on p-value
        gen str20 coef_str = ""
        replace coef_str = string(coef, "%9.1f") + "***" if pval < 0.01
        replace coef_str = string(coef, "%9.1f") + "**"  if pval >= 0.01 & pval < 0.05
        replace coef_str = string(coef, "%9.1f") + "*"   if pval >= 0.05 & pval < 0.10
        replace coef_str = string(coef, "%9.1f")         if pval >= 0.10

        format effect_1sd effect_avg effect_ne effect_vd %5.2f
        tostring effect_1sd effect_avg effect_ne effect_vd, format(%5.2f) replace force

        order spec_label coef_str effect_1sd effect_avg effect_ne effect_vd
        drop coef pval

        label var spec_label  "Specification"
        label var coef_str    "Vineyard coef"
        label var effect_1sd  "+1-SD"
        label var effect_avg  "Avg wine"
        label var effect_ne   "NE vs UR"
        label var effect_vd   "VD vs UR"

        local mfn1 "Notes: Each cell shows the predicted yes-vote shift (in percentage points) holding language and religion constant. "
        local mfn2 "+1-SD: a one-standard-deviation increase in vineyard\_per\_cap (`=string(`sd_vine',"%5.4f")' ha/person). "
        local mfn3 "Avg wine: comparison from no-vineyard Uri (UR, 0.0000) to the cantonal mean (`=string(`mean_vine',"%5.4f")'). "
        local mfn4 "NE vs UR: Neuch\^{a}tel (`=string(`ne_vine',"%5.4f")') vs Uri. "
        local mfn5 "VD vs UR: Vaud, the wine-richest canton (`=string(`vd_vine',"%5.4f")'), vs Uri. "
        local mfn6 "Stars on coefficient: * p<0.10, ** p<0.05, *** p<0.01."

        texsave spec_label coef_str effect_1sd effect_avg effect_ne effect_vd ///
            using "$MyProject/results/tables/t11_magnitudes.tex", ///
            replace varlabels marker(tab:magnitudes) ///
            title("Substantive magnitudes: predicted yes-vote shifts (\\%) by canton contrast") ///
            footnote("`mfn1'`mfn2'`mfn3'`mfn4'`mfn5'`mfn6'")
    restore
}


**# 7. Post-credits: inventory
*------------------------------------------------------------------------------*
{
    _inventory_append, sheet("outputs") row("generated|results/tables/t01_summary.tex|table|04_tables.do")
    _inventory_append, sheet("outputs") row("generated|results/tables/t02_ols.tex|table|04_tables.do")
    _inventory_append, sheet("outputs") row("generated|results/tables/t03_fracreg.tex|table|04_tables.do")
    _inventory_append, sheet("outputs") row("generated|results/tables/t11_magnitudes.tex|table|04_tables.do")
    _inventory_append, sheet("outputs") row("generated|results/figures/f01_scatter_raw.pdf|figure|04_tables.do")
    _inventory_append, sheet("outputs") row("generated|results/figures/f02_scatter_partial.pdf|figure|04_tables.do")
    _inventory_append, sheet("scripts") row("04_tables.do|.|generates LaTeX tables, PDF figures, and assertion checks|.")
}

** EOF
