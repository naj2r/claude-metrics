/*==============================================================================
 19_workshop_winetype_tables.do  —  Phase A'' rewrite (2026-05-22)

 Purpose:  Build T9 (winetype cascade A=agg / B=white / C=red) and T11
           (drop-TI cascade, OLS only) via the _workshop_table wrapper.
           T10v + T10v_margins kept as hand-built (at()-based margins).

 Author:   Phase A'' refactor
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

global WorkshopTables "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"
cap mkdir "$WorkshopTables"


**# 1. Table 9 — Wine-type cascade (agg / white / red, OLS + FL)
*------------------------------------------------------------------------------*

* --- Panel A: AGG OLS (5-col cascade from estimates_workshop/ols_3_*) ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_workshop/ols_3_1.ster $MyProject/results/intermediate/estimates_workshop/ols_3_2.ster $MyProject/results/intermediate/estimates_workshop/ols_3_3.ster $MyProject/results/intermediate/estimates_workshop/ols_3_4.ster $MyProject/results/intermediate/estimates_workshop/ols_3_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_A_agg_OLS.tex") ///
    title("T9 Panel A: Aggregate wine (X3 share) cascade --- OLS HC3") ///
    tlabel("tab:T9_A_agg_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("All wine combined (X3 = total revenue share). N=25 cantons.") ///
    model("ols") ///
    keep("X3_share cov1 cov2_total_share cov3 ln_density _cons")

* --- Panel A: AGG FL (5-col cascade from estimates_fraclogit_workshop/fl_me_3_*) ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_1.ster $MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_2.ster $MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_3.ster $MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_4.ster $MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_A_agg_FL.tex") ///
    title("T9 Panel A: Aggregate wine cascade --- fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)") ///
    tlabel("tab:T9_A_agg_FL") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("All wine combined (X3 = total revenue share). Fractional-logit average marginal effects in percentage points of yes-share per percentage point of national wine share. N=25 cantons.") ///
    model("fl_pp") ///
    keep("X3_share cov1 cov2_total_share cov3 ln_density _cons")

* --- Panel B: WHITE OLS (5-col from estimates_winetype_workshop/ols_white_*) ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_1.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_2.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_3.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_4.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_B_white_OLS.tex") ///
    title("T9 Panel B: White wine cascade --- OLS HC3") ///
    tlabel("tab:T9_B_white_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("White wine only (Cahannes substitution test). Predicted positive and larger than aggregate. N=25 cantons.") ///
    model("ols") ///
    keep("X3_white_share cov1 cov2_total_share cov3 ln_density _cons")

* --- Panel B: WHITE FL col-5 only ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_white_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_B_white_FL.tex") ///
    title("T9 Panel B: White wine col 5 --- fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)") ///
    tlabel("tab:T9_B_white_FL") ///
    mtitles(`""(col 5)""') ///
    footnote("White wine FL AME at col-5 controls. Cahannes substitution test. N=25 cantons.") ///
    model("fl_pp") ///
    keep("X3_white_share cov1 cov2_total_share cov3 ln_density _cons")

* --- Panel C: RED OLS (5-col cascade) ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_1.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_2.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_3.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_4.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_C_red_OLS.tex") ///
    title("T9 Panel C: Red wine cascade --- OLS HC3") ///
    tlabel("tab:T9_C_red_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("Red wine only. Predicted closer to zero than white. N=25 cantons.") ///
    model("ols") ///
    keep("X3_red_share cov1 cov2_total_share cov3 ln_density _cons")

* --- Panel C: RED FL col-5 only ---
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_red_5.ster") ///
    output("$WorkshopTables/T9_winetype_cascade_C_red_FL.tex") ///
    title("T9 Panel C: Red wine col 5 --- fractional-logit average marginal effects (percentage points of yes-share per percentage point of national wine share)") ///
    tlabel("tab:T9_C_red_FL") ///
    mtitles(`""(col 5)""') ///
    footnote("Red wine FL AME at col-5 controls. N=25 cantons.") ///
    model("fl_pp") ///
    keep("X3_red_share cov1 cov2_total_share cov3 ln_density _cons")


**# 2. Table 11 — Drop-Ticino cascade (OLS only; no FL drop-TI ster files exist)
*------------------------------------------------------------------------------*

* Panel A: AGG drop-TI
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_1_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_2_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_3_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_4_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_5_noti.ster") ///
    output("$WorkshopTables/T11_drop_ti_A_agg_OLS.tex") ///
    title("T11 Panel A: Aggregate wine cascade (drop Ticino) --- OLS HC3 (N=24)") ///
    tlabel("tab:T11_A_agg_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("Sample excludes Ticino (Italian-language outlier). N=24 cantons.") ///
    model("ols") ///
    keep("X3_share cov1 cov2_total_share cov3 ln_density _cons")

* Panel B: WHITE drop-TI
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_1_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_2_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_3_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_4_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5_noti.ster") ///
    output("$WorkshopTables/T11_drop_ti_B_white_OLS.tex") ///
    title("T11 Panel B: White wine cascade (drop Ticino) --- OLS HC3 (N=24)") ///
    tlabel("tab:T11_B_white_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("Sample excludes Ticino. N=24 cantons.") ///
    model("ols") ///
    keep("X3_white_share cov1 cov2_total_share cov3 ln_density _cons")

* Panel C: RED drop-TI
_workshop_table, ///
    sters("$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_1_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_2_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_3_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_4_noti.ster $MyProject/results/intermediate/estimates_winetype_workshop/ols_red_5_noti.ster") ///
    output("$WorkshopTables/T11_drop_ti_C_red_OLS.tex") ///
    title("T11 Panel C: Red wine cascade (drop Ticino) --- OLS HC3 (N=24)") ///
    tlabel("tab:T11_C_red_OLS") ///
    mtitles(`""(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog (density)""') ///
    footnote("Sample excludes Ticino. N=24 cantons.") ///
    model("ols") ///
    keep("X3_red_share cov1 cov2_total_share cov3 ln_density _cons")


**# 3. Table 10v — White wine value-vs-volume comparison (hand-built via texsave)
*------------------------------------------------------------------------------*
* D1 / D1v / D2 / D2v are interaction models with at()-based margins; the
* wrapper isn't built for at()-extracted AMEs at multiple at-points.  Hand-
* build a small 10-row table (5 at-points × 2 stat-rows) for the 4 specs.
{
    di as text _newline "  --- Table 10v: white wine value-vs-volume margins (hand-built) ---"

    local at_vals 0 25 50 75 100

    * 4 specs × 5 at-points × {b, se}
    matrix B_d1  = J(5, 1, .)
    matrix S_d1  = J(5, 1, .)
    matrix B_d1v = J(5, 1, .)
    matrix S_d1v = J(5, 1, .)
    matrix B_d2  = J(5, 1, .)
    matrix S_d2  = J(5, 1, .)
    matrix B_d2v = J(5, 1, .)
    matrix S_d2v = J(5, 1, .)

    foreach spec in d1 d1v d2 d2v {
        local sterfile_d1   "fl_white_french_dummy_mg.ster"
        local sterfile_d1v  "fl_d1v_mg.ster"
        local sterfile_d2   "fl_white_french_cont_mg.ster"
        local sterfile_d2v  "fl_d2v_mg.ster"
        local sterfile "`sterfile_`spec''"

        cap confirm file "$MyProject/results/intermediate/estimates_winetype_workshop/`sterfile'"
        if !_rc {
            estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`sterfile'"
            forvalues k = 1/5 {
                cap matrix B_`spec'[`k', 1] = _b[`k'._at] * 100
                cap matrix S_`spec'[`k', 1] = _se[`k'._at] * 100
            }
        }
    }

    preserve
        clear
        set obs 10
        gen str10 cov1_lbl = ""
        gen str20 D1_value = ""
        gen str20 D1v_vol  = ""
        gen str20 D2_value = ""
        gen str20 D2v_vol  = ""

        local row 0
        forvalues k = 1/5 {
            local cv : word `k' of `at_vals'
            local ++row
            qui replace cov1_lbl = "`cv'\%" in `row'
            foreach spec in d1 d1v d2 d2v {
                local b = B_`spec'[`k', 1]
                if missing(`b') {
                    local cell_str = ""
                }
                else {
                    local b_str = trim(string(`b', "%5.3f"))
                    local stars ""
                    local s = S_`spec'[`k', 1]
                    if !missing(`s') & `s' > 0 {
                        local z = abs(`b' / `s')
                        if `z' > 1.645 local stars "*"
                        if `z' > 1.96  local stars "**"
                        if `z' > 2.576 local stars "***"
                    }
                    local cell_str = "`b_str'`stars'"
                }
                local col = cond("`spec'"=="d1", "D1_value", ///
                            cond("`spec'"=="d1v", "D1v_vol", ///
                            cond("`spec'"=="d2", "D2_value", "D2v_vol")))
                qui replace `col' = "`cell_str'" in `row'
            }
            local ++row
            qui replace cov1_lbl = "" in `row'
            foreach spec in d1 d1v d2 d2v {
                local s = S_`spec'[`k', 1]
                if missing(`s') {
                    local s_cell = ""
                }
                else {
                    local s_str = trim(string(`s', "%5.3f"))
                    local s_cell = "(`s_str')"
                }
                local col = cond("`spec'"=="d1", "D1_value", ///
                            cond("`spec'"=="d1v", "D1v_vol", ///
                            cond("`spec'"=="d2", "D2_value", "D2v_vol")))
                qui replace `col' = "`s_cell'" in `row'
            }
        }

        label var cov1_lbl "cov1"
        label var D1_value "D1 value (abs dummy)"
        label var D1v_vol  "D1v volume (abs dummy)"
        label var D2_value "D2 value (abs cont)"
        label var D2v_vol  "D2v volume (abs cont)"

        texsave cov1_lbl D1_value D1v_vol D2_value D2v_vol ///
            using "$WorkshopTables/T10v_margins.tex", ///
            replace frag varlabels ///
            align(rrrrr) ///
            title("T10v: White wine AME on Yes-vote, by cov1, value vs volume") ///
            label("tab:T10v_margins") ///
            footnote("FL AMEs of white wine share on Yes-vote share #68, evaluated at cov1 = 0, 25, 50, 75, 100\%. All average marginal effects are in percentage points of yes-share per percentage point of white-wine share. Robust SEs in parentheses below each estimate. * p<0.10, ** p<0.05, *** p<0.01.", size(footnotesize))
    restore

    di as text "  Wrote T10v_margins.tex"
}


**# 4. Post-credits
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
