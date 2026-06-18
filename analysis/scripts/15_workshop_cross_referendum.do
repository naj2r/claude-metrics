/*==============================================================================
 15_workshop_cross_referendum.do  —  Phase A'' rewrite (2026-05-22)

 Purpose:  Build Table 8 (cross-referendum falsification: votes 67/68/69)
           via the _workshop_table wrapper.  Same voters, same ballot day,
           three different questions: wine coefficient should be near zero
           on #67 (commerce) and #69 (water power), positive on #68 (ban).

 Input:    $MyProject/results/intermediate/estimates_crossref/
                crossref_ols_{67,68,69}.ster
                crossref_fl_me_{67,68,69}.ster  (post-Phase A'' dydx(*))

 Output:   $WorkshopTables/T8_cross_referendum_OLS.tex
           $WorkshopTables/T8_cross_referendum_FL.tex

 Author:   Phase A'' refactor
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

global WorkshopTables "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"
cap mkdir "$WorkshopTables"

cap which _workshop_table
if _rc {
    di as error "  _workshop_table.ado not found — check adopath"
    error 199
}


**# 1. Table 8 — Cross-referendum (votes #67/#68/#69, OLS + FL)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 8: cross-referendum falsification (OLS + FL via wrapper) ---"

    local kvars_t8 "X3_share cov1 cov2_total_share cov3 ln_density _cons"

    foreach model in ols fl_pp {
        local file_suffix = cond("`model'"=="ols", "OLS", "FL")
        local ster_prefix = cond("`model'"=="ols", "crossref_ols", "crossref_fl_me")
        local model_lbl   = cond("`model'"=="ols", "OLS HC3", ///
                                 "fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)")

        local sters_list ""
        foreach r_id in 67 68 69 {
            local sters_list `sters_list' "$MyProject/results/intermediate/estimates_crossref/`ster_prefix'_`r_id'.ster"
        }

        _workshop_table, ///
            sters(`sters_list') ///
            output("$WorkshopTables/T8_cross_referendum_`file_suffix'.tex") ///
            title("Cross-referendum: votes \#67, \#68, \#69 --- `model_lbl'") ///
            tlabel("tab:T8_`file_suffix'") ///
            mtitles(`""(1) Vote \#67 (commerce)" "(2) Vote \#68 (absinthe ban)" "(3) Vote \#69 (water power)""') ///
            footnote("Same voters, same ballot day (5 July 1908); three different questions. Falsification: wine coefficient near zero on \#67 and \#69, positive on \#68. N=25 cantons throughout.") ///
            model("`model'") ///
            keep("`kvars_t8'")
    }
}


**# 2. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        di as text "  (inventory append: post-credits structure ready)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
