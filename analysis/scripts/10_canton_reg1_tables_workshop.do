/*==============================================================================
 10_canton_reg1_tables_workshop.do  —  Phase A'' rewrite (2026-05-22)

 Purpose:  Build Tables 2 (vote cascade panels A+B) and 3 (vote horse race
           at col 5) for the workshop draft, via the single _workshop_table
           wrapper.  OLS and FL panels are sibling calls differing only in
           model() and the sters list.

 Input:    $MyProject/results/intermediate/estimates_workshop/ols_k_j.ster
           $MyProject/results/intermediate/estimates_fraclogit_workshop/
                fl_me_k_j.ster  (post-Phase A'' dydx(*); covariate AMEs included)

 Output:   $WorkshopTables/T2_vote_cascade_{X3,X2}_{OLS,FL}.tex
           $WorkshopTables/T3_vote_horserace_{OLS,FL}.tex

 Wrapper:  _workshop_table.ado handles the regsave→clean_vars→texsave pipeline,
           hardcoded house style (sigfig 3, asterisks 10/5/1, parentheses on SE,
           autonumber, headerlines, hlines(-2), frag, nofix).  FL ×100 rescale
           happens inside the wrapper when model("fl_pp") is passed.

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


**# 1. Table 2 — Vote regression cascade (X3_share + X2_share, OLS + FL)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 2: vote cascade (X3 + X2, OLS + FL via wrapper) ---"

    * Maps for parameterization
    local title_X3 "Vote cascade (Panel A: Wine revenue share)"
    local title_X2 "Vote cascade (Panel B: Wine volume share)"
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
            local sterdir     = cond("`model'"=="ols", ///
                                     "estimates_workshop", ///
                                     "estimates_fraclogit_workshop")
            local ster_prefix = cond("`model'"=="ols", "ols", "fl_me")
            local model_lbl   = cond("`model'"=="ols", "OLS HC3", "fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)")

            * Build sters list for col 1..5
            local sters_list ""
            forvalues j = 1/5 {
                local sters_list `sters_list' "$MyProject/results/intermediate/`sterdir'/`ster_prefix'_`k'_`j'.ster"
            }

            _workshop_table, ///
                sters(`sters_list') ///
                output("$WorkshopTables/T2_vote_cascade_`variant'_`file_suffix'.tex") ///
                title("`title' --- `model_lbl'") ///
                tlabel("tab:T2_`variant'_`file_suffix'") ///
                mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
                footnote("N=25 cantons. Col 5 adds Log population density as scale control.") ///
                model("`model'") ///
                keep("`kvars'")
        }
    }
}


**# 2. Table 3 — Vote horse race at col 5 (X1 + X2_share + X3_share)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 3: horse race at col 5 (X1, X2_share, X3_share; OLS + FL) ---"

    local kvars_hr "X1 X2_share X3_share cov1 cov2_total_share cov3 ln_density _cons"

    foreach model in ols fl_pp {
        local file_suffix = cond("`model'"=="ols", "OLS", "FL")
        local sterdir     = cond("`model'"=="ols", ///
                                 "estimates_workshop", ///
                                 "estimates_fraclogit_workshop")
        local ster_prefix = cond("`model'"=="ols", "ols", "fl_me")
        local model_lbl   = cond("`model'"=="ols", "OLS HC3", "fractional-logit average marginal effects (percentage points of yes-share)")

        local sters_list ""
        foreach k in 1 2 3 {
            local sters_list `sters_list' "$MyProject/results/intermediate/`sterdir'/`ster_prefix'_`k'_5.ster"
        }

        _workshop_table, ///
            sters(`sters_list') ///
            output("$WorkshopTables/T3_vote_horserace_`file_suffix'.tex") ///
            title("Vote horse race at col 5 --- `model_lbl'") ///
            tlabel("tab:T3_`file_suffix'") ///
            mtitles(`""(1) Per-cap" "(2) Volume share" "(3) Revenue share""') ///
            footnote("N=25 cantons. All cols include col-5 control set. Coefficients on the volume- and revenue-share columns are per percentage point of national wine share; the per-capita area column is per hectare per 1,000 population.") ///
            model("`model'") ///
            keep("`kvars_hr'")
    }
}


**# 3. Post-credits
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
