/*==============================================================================
 11_canton_robustness_tables_workshop.do  —  Phase A'' rewrite (2026-05-22)

 Purpose:  Build Tables 5 (R4 mechanism), 6 (French-German turnout gap), and 7
           (appendix robustness: fraclogit-vs-OLS + R1-R6) for the workshop
           draft.  T5 + T7 use the _workshop_table wrapper; T6 is rebuilt fresh
           via texsave on a hand-built dataset; T5 conditional means is hand-
           written (texsave on hand-built dataset).

 Input:    $MyProject/results/intermediate/estimates_workshop/ols_k_5.ster
           $MyProject/results/intermediate/estimates_fraclogit_workshop/
                fl_me_k_5.ster   (post Phase A'' dydx(*))
           $MyProject/results/intermediate/estimates_robust_workshop/
                r4_fr_x_prod.ster, r4b_fr_x_prod_x3.ster
           $MyProject/results/intermediate/estimates_winetype_workshop/
                ols_white_5.ster, fl_me_white_5.ster (for X1_share equivalent)

 Output:   $WorkshopTables/T5_R4_mechanism_{X2,X3}.tex
           $WorkshopTables/T5_R4_conditional_means.tex   (hand-built)
           $WorkshopTables/T6_turnout_gap_collapse.tex   (hand-built, fresh)
           $WorkshopTables/T7_appendix_fraclogit_vs_ols_{OLS,FL}.tex  (split)
           $WorkshopTables/T7_appendix_canton_robustness_r1_r6.tex   (copy)

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


**# 1. Table 5 — R4 mechanism interaction panels (X2 + X3, OLS only — interaction has no FL twin)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 5: R4 mechanism interaction (X2 + X3, OLS) ---"

    local kvars_X2 "X2_share cov1 abs_producer fr_x_producer cov2_total_share cov3 ln_density _cons"
    local kvars_X3 "X3_share cov1 abs_producer fr_x_producer cov2_total_share cov3 ln_density _cons"

    * Panel A: X2 (wine volume share)
    local sters_A "$MyProject/results/intermediate/estimates_workshop/ols_2_5.ster $MyProject/results/intermediate/estimates_robust_workshop/r4_fr_x_prod.ster"
    _workshop_table, ///
        sters(`sters_A') ///
        output("$WorkshopTables/T5_R4_mechanism_X2.tex") ///
        title("R4 mechanism (Panel A: Wine volume share) --- OLS HC3") ///
        tlabel("tab:T5_X2") ///
        mtitles(`""(1) col 5" "(2) + French \$\times\$ Producer""') ///
        footnote("Col 1 = primary col 5 spec (no interaction). Col 2 = adds French \$\times\$ Absinthe-producer interaction. N=25 cantons.") ///
        model("ols") ///
        keep("`kvars_X2'")

    * Panel B: X3 (wine revenue share)
    local sters_B "$MyProject/results/intermediate/estimates_workshop/ols_3_5.ster $MyProject/results/intermediate/estimates_robust_workshop/r4b_fr_x_prod_x3.ster"
    _workshop_table, ///
        sters(`sters_B') ///
        output("$WorkshopTables/T5_R4_mechanism_X3.tex") ///
        title("R4 mechanism (Panel B: Wine revenue share) --- OLS HC3") ///
        tlabel("tab:T5_X3") ///
        mtitles(`""(1) col 5" "(2) + French \$\times\$ Producer""') ///
        footnote("Col 1 = primary col 5 spec. Col 2 = adds French \$\times\$ Absinthe-producer interaction. N=25 cantons.") ///
        model("ols") ///
        keep("`kvars_X3'")
}


**# 2. Table 5 — Conditional means (hand-built; computes from R4 interaction coefs)
*------------------------------------------------------------------------------*
{
    di as text _newline "  --- Table 5 conditional means (auxiliary, hand-built via texsave) ---"

    * Load R4 Panel B (X3) for the canonical R4 mechanism coefs
    estimates use "$MyProject/results/intermediate/estimates_robust_workshop/r4b_fr_x_prod_x3.ster"
    local b_cov1_B      = _b[cov1]
    local b_prod_B      = _b[abs_producer]
    local b_interact_B  = _b[fr_x_producer]
    local d_fr_np_B     = `b_cov1_B'
    local d_ge_prod_B   = `b_prod_B'
    local d_fr_prod_B   = `b_cov1_B' + `b_prod_B' + `b_interact_B'

    * Same for R4 Panel A (X2)
    estimates use "$MyProject/results/intermediate/estimates_robust_workshop/r4_fr_x_prod.ster"
    local b_cov1_A      = _b[cov1]
    local b_prod_A      = _b[abs_producer]
    local b_interact_A  = _b[fr_x_producer]
    local d_fr_np_A     = `b_cov1_A'
    local d_ge_prod_A   = `b_prod_A'
    local d_fr_prod_A   = `b_cov1_A' + `b_prod_A' + `b_interact_A'

    * Build dataset for texsave (3 rows × 3 cols)
    preserve
        clear
        set obs 3
        gen str40 Subgroup     = ""
        gen double PanelA_X2   = .
        gen double PanelB_X3   = .

        replace Subgroup   = "French non-producer (cov1 alone)"      in 1
        replace PanelA_X2  = `d_fr_np_A'                              in 1
        replace PanelB_X3  = `d_fr_np_B'                              in 1

        replace Subgroup   = "German producer (abs producer alone)"  in 2
        replace PanelA_X2  = `d_ge_prod_A'                            in 2
        replace PanelB_X3  = `d_ge_prod_B'                            in 2

        replace Subgroup   = "French producer (cov1+prod+interaction)" in 3
        replace PanelA_X2  = `d_fr_prod_A'                              in 3
        replace PanelB_X3  = `d_fr_prod_B'                              in 3

        format PanelA_X2 PanelB_X3 %7.3f

        label var Subgroup    "Subgroup (vs. German non-producer)"
        label var PanelA_X2   "Panel A (X2 share)"
        label var PanelB_X3   "Panel B (X3 share)"

        texsave using "$WorkshopTables/T5_R4_conditional_means.tex", ///
            replace frag nofix varlabels ///
            title("Conditional Yes-vote-share differences (vs. German non-producer baseline)") ///
            label("tab:T5_cond_means") ///
            footnote("Subgroup differences in pp Yes-vote share derived from R4 interaction (Table 5 Panel B). German non-producer is the omitted baseline.", size(footnotesize))
    restore
    di as text "  Wrote T5_R4_conditional_means.tex"
}


**# 3. Table 6 — French-German turnout gap collapse (REBUILT FRESH via texsave)
*------------------------------------------------------------------------------*
* Previous version copied a broken hand-rolled file (had \documentclass wrappers,
* missing \\ row terminators, \texttt\{ escape bugs).  Rebuild here from the
* known values (per dispatch / Phase C.6c documentation) as a clean texsave
* fragment.
{
    di as text _newline "  --- Table 6: French-German turnout gap collapse (fresh texsave) ---"

    preserve
        clear
        set obs 3
        gen str60 Row    = ""
        gen str20 French = ""
        gen str20 German = ""
        gen str20 Gap    = ""

        replace Row    = "Baseline turnout (median across 14 placebo votes 1907--1910)" in 1
        replace French = "44.40"                                                          in 1
        replace German = "56.62"                                                          in 1
        replace Gap    = "--12.22"                                                         in 1

        replace Row    = "Vote \#68 turnout (5 July 1908, absinthe ban)"                in 2
        replace French = "47.92"                                                          in 2
        replace German = "48.02"                                                          in 2
        replace Gap    = "--0.11"                                                          in 2

        replace Row    = "Change (gap collapse, row 2 minus row 1)"                      in 3
        replace French = "+3.52"                                                          in 3
        replace German = "--8.60"                                                          in 3
        replace Gap    = "\textbf{+12.12}"                                                 in 3

        label var Row    " "
        label var French "French (N=5)"
        label var German "German (N=20)"
        label var Gap    "Gap (Fr--Ge)"

        texsave using "$WorkshopTables/T6_turnout_gap_collapse.tex", ///
            replace frag nofix varlabels ///
            title("French--German turnout gap collapse on the absinthe ban (Vote \#68)") ///
            label("tab:T6_turnout_gap") ///
            footnote("French = cantons with French language share >50\% of (German+French) speakers (NE, GE, VD, FR, VS; N=5). German = remaining 20 cantons. Baseline turnout = canton-level median across 14 federal referenda 1907--1910 (placebo set used to detect mobilization deviation on \#68). Gap entries are arithmetic differences between French and German group means.", size(footnotesize))
    restore
    di as text "  Wrote T6_turnout_gap_collapse.tex (fresh, clean fragment)"
}


**# 4. Table 7 — Appendix (a) FL vs OLS at col 5 (split into 2 panels)
*------------------------------------------------------------------------------*
* Splitting into separate OLS-only and FL-only panels (4 wine variants each).
* The wrapper handles one model() at a time; readers compare side-by-side.
{
    di as text _newline "  --- Table 7a: FL vs OLS at col 5 (split: 2 panels via wrapper) ---"

    local kvars_t7 "X1 X2_share X3_share cov1 cov2_total_share cov3 ln_density _cons"

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
            output("$WorkshopTables/T7_appendix_at_col5_`file_suffix'.tex") ///
            title("T7 appendix: Wine specifications at col 5 --- `model_lbl'") ///
            tlabel("tab:T7_col5_`file_suffix'") ///
            mtitles(`""X1 (per-cap)" "X2 (volume share)" "X3 (revenue share)""') ///
            footnote("Workshop col-5 controls (cov1, cov2, cov3, ln\_density). N=25 cantons. Coefficients on the volume- and revenue-share columns are per percentage point of national wine share; the per-capita area column is per hectare per 1,000 population.") ///
            model("`model'") ///
            keep("`kvars_t7'")
    }
}


**# 5. Table 7b — R1-R6 robustness (copy from non-workshop pipeline if available)
*------------------------------------------------------------------------------*
{
    local src "$MyProject/results/tables/canton_robustness_r1_r6.tex"
    local dst "$WorkshopTables/T7_appendix_canton_robustness_r1_r6.tex"
    cap confirm file "`src'"
    if !_rc {
        copy "`src'" "`dst'", replace
        di as text "  Copied: R1-R6 robustness (all-OLS, no scale conversion needed)"
    }
    else {
        di as text "  Skipping R1-R6 copy: non-workshop pipeline not run."
    }
}


**# 6. Post-credits
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
