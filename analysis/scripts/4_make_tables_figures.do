/*==============================================================================
 4_make_tables_figures.do
 Purpose:  Generate LaTeX tables and PDF figures for the paper
 Input:    analysis/processed/<dataset>.dta, analysis/results/intermediate/regressions.dta
 Output:   analysis/results/figures/*.pdf, analysis/results/tables/*.tex
 Author:   [Author name]
 Date:     [YYYY-MM-DD]
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Setup
*------------------------------------------------------------------------------*
{
    * tempfile work
}


**# 1. Summary statistics table
*------------------------------------------------------------------------------*
{
    * use "$MyProject/processed/<dataset>.dta", clear
    *
    * collapse (mean) mean=<var> (sd) sd=<var> (min) min=<var> (max) max=<var> ///
    *     (count) count=<var>, fast
    *
    * tostring mean sd min max, format(%9.3gc) replace force
    *
    * label var mean "Mean"
    * label var sd "Stdev."
    * label var min "Min"
    * label var max "Max"
    *
    * texsave using "$MyProject/results/tables/summary_stats.tex", replace ///
    *     varlabels marker(tab:summary_stats) title("Summary statistics") ///
    *     footnote("Notes: ...")
}


**# 2. Regression table
*------------------------------------------------------------------------------*
{
    * use "$MyProject/results/intermediate/regressions.dta", clear
    *
    * regsave_tbl using "`work'", name(col1) asterisk(10 5 1) parentheses(stderr) sigfig(3) replace
    *
    * use "`work'", clear
    * drop if inlist(var,"_id") | strpos(var,"_cons") | strpos(var,"tstat") | strpos(var,"pval")
    *
    * texsave using "$MyProject/results/tables/regressions.tex", replace ///
    *     autonumber varlabels marker(tab:regressions) title("Main results") ///
    *     footnote("Notes: ...")
}


**# 3. Figures
*------------------------------------------------------------------------------*
{
    * use "$MyProject/processed/<dataset>.dta", clear
    *
    * histogram <var>, frequency xtitle("<label>") graphregion(fcolor(white))
    * graph export "$MyProject/results/figures/<name>.pdf", as(pdf) replace
}


**# 4. Sanity-check assertions (Reif submission checklist)
*------------------------------------------------------------------------------*
{
    * Add assert statements that pin key reported numbers, so future data updates
    * that change the result fail loudly:
    *   assert abs(mean - <reported_value>) < 0.01 if var == "<key_var>"
}


**# 5. Post-credits: inventory
*------------------------------------------------------------------------------*
{
    * _inventory_append, sheet("outputs") row("generated|results/tables/summary_stats.tex|table|4_make_tables_figures.do")
    * _inventory_append, sheet("outputs") row("generated|results/tables/regressions.tex|table|4_make_tables_figures.do")
    * _inventory_append, sheet("outputs") row("generated|results/figures/<name>.pdf|figure|4_make_tables_figures.do")
    * _inventory_append, sheet("scripts") row("4_make_tables_figures.do|.|generates LaTeX tables and PDF figures|.")
}

** EOF
