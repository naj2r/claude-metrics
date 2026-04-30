/*==============================================================================
 3_regressions.do
 Purpose:  Estimate regression models and save coefficients
 Input:    analysis/processed/<dataset>.dta
 Output:   analysis/results/intermediate/regressions.dta
 Author:   [Author name]
 Date:     [YYYY-MM-DD]
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Load
*------------------------------------------------------------------------------*
{
    * use "$MyProject/processed/<dataset>.dta", clear
    * tempfile results
}


**# 1. Main estimation
*------------------------------------------------------------------------------*
{
    * Examples:
    *   reg <y> <x>, robust
    *   reghdfe <y> <x>, absorb(<fe>) cluster(<cluster>)
    *   ivreg2 <y> (<endog> = <iv>) <controls>, cluster(<cluster>)
    *
    * After each regression, save with regsave:
    *   regsave using "`results'", t p autoid replace addlabel(spec, "main")
    *   regsave using "`results'", t p autoid append addlabel(spec, "alt")
}


**# 2. Save regression results
*------------------------------------------------------------------------------*
{
    * use "`results'", clear
    * compress
    * save "$MyProject/results/intermediate/regressions.dta", replace
}


**# 3. R regressions (if applicable)
*------------------------------------------------------------------------------*
{
    * if "$DisableR" != "1" {
    *     rscript using "$MyProject/scripts/programs/regressions.R", ///
    *         args("$MyProject/processed/<dataset>.dta" "$MyProject/results/intermediate/regressions_r.dta")
    * }
}


**# 4. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    * _codebook_update using "$MyProject/results/intermediate/regressions.dta", script("3_regressions.do")
    * _inventory_append, sheet("datasets") row("created|results/intermediate/regressions.dta|`=c(N)'|`=c(k)'|.|3_regressions.do")
    * _inventory_append, sheet("scripts") row("3_regressions.do|.|estimates regression models|.")
}

** EOF
