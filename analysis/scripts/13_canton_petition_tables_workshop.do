/*==============================================================================
 13_canton_petition_tables_workshop.do  —  Phase A'' rewrite (2026-05-22)

 Purpose:  Build Table 4 (petition cascade panels A+B) via the _workshop_table
           wrapper.  NEW: FL twin panels alongside OLS (petition FL margins
           added to 12_workshop in Phase A''.3).

 Input:    $MyProject/results/intermediate/estimates_petition_workshop/
                ols_pet_k_j.ster      (20 files: OLS)
                fl_me_pet_k_j.ster    (20 files: FL AMEs, post Phase A'')

 Output:   $WorkshopTables/T4_petition_cascade_X3_OLS.tex
           $WorkshopTables/T4_petition_cascade_X3_FL.tex   (NEW)
           $WorkshopTables/T4_petition_cascade_X2_OLS.tex
           $WorkshopTables/T4_petition_cascade_X2_FL.tex   (NEW)

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


**# 1. Table 4 — Petition cascade (X3 + X2, OLS + FL)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 4: petition cascade (X3 + X2, OLS + FL via wrapper) ---"

    local title_X3 "Petition cascade (Panel A: Wine revenue share)"
    local title_X2 "Petition cascade (Panel B: Wine volume share)"
    local kvars_X3 "X3_share cov1 cov2_total_share cov3 ln_density _cons"
    local kvars_X2 "X2_share cov1 cov2_total_share cov3 ln_density _cons"
    local k_X3 "3"
    local k_X2 "2"

    foreach variant in X3 X2 {
        local kvars "`kvars_`variant''"
        local title "`title_`variant''"
        local k     "`k_`variant''"

        foreach model in ols fl_pp {
            local file_suffix = cond("`model'"=="ols", "OLS", "FL")
            local ster_prefix = cond("`model'"=="ols", "ols_pet", "fl_me_pet")
            local model_lbl   = cond("`model'"=="ols", "OLS HC3", ///
                                     "fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)")
            local y_lbl       = cond("`model'"=="ols", ///
                                     "Y = petition signatures per 100 eligible voters", ///
                                     "Y = petition fraction (0--1)")

            local sters_list ""
            forvalues j = 1/5 {
                local sters_list `sters_list' "$MyProject/results/intermediate/estimates_petition_workshop/`ster_prefix'_`k'_`j'.ster"
            }

            _workshop_table, ///
                sters(`sters_list') ///
                output("$WorkshopTables/T4_petition_cascade_`variant'_`file_suffix'.tex") ///
                title("`title' --- `model_lbl'") ///
                tlabel("tab:T4_`variant'_`file_suffix'") ///
                mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
                footnote("`y_lbl'. N=25 cantons. Col 5 adds Log population density as scale control.") ///
                model("`model'") ///
                keep("`kvars'")
        }
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
