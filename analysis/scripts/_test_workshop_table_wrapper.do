/*==============================================================================
 _test_workshop_table_wrapper.do  —  Phase A''.4 verification
 Calls _workshop_table on T2 X3 OLS (5 ster files) and outputs to a test path.
 Goal: confirm wrapper produces a clean texsave fragment.
==============================================================================*/

version 19

global MyProject "C:/Users/jensenn/Research/repos/c-metrics-absinthe1/analysis"

* Add libraries parent so Stata auto-finds appendfile (/a/), regsave (/r/),
* texsave (/t/), etc. via its first-letter subdirectory convention.
adopath ++ "$MyProject/scripts/libraries/stata"
adopath ++ "$MyProject/scripts/programs"

* Force-reload any cached versions of edited ados (essential during iteration)
discard
cap program drop _workshop_table
cap program drop clean_vars

* Sanity: confirm the helpers compile
cap which regsave
cap which regsave_tbl
cap which texsave
cap which clean_vars
cap which _workshop_table

* Output goes to a TEST path (NOT Overleaf)
local out "$MyProject/results/tables/_test/T2_X3_OLS_wrapper_test.tex"
cap mkdir "$MyProject/results/tables/_test"

* Build the sters list for T2 X3 OLS cascade (col 1..5)
local sters ""
forvalues j = 1/5 {
    local sters `sters' "$MyProject/results/intermediate/estimates_workshop/ols_3_`j'.ster"
}

* Invoke wrapper
_workshop_table, ///
    sters(`sters') ///
    output("`out'") ///
    title("Vote cascade (Panel A: Wine revenue share) --- OLS HC3") ///
    tlabel("tab:T2_X3_OLS_test") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("HC3 robust standard errors in parentheses. N=25 cantons.") ///
    model("ols") ///
    keep("X3_share cov1 cov2_total_share cov3 ln_density _cons")

di _newline "==== TEST DONE.  Output: ===="
di "  `out'"
