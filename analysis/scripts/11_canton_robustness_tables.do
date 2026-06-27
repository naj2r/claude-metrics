/*==============================================================================
 11_canton_robustness_tables.do
 Purpose:  Build LaTeX + markdown robustness-battery tables from the .ster
           files produced by 09_canton_reg1.do §2.5 (fraclogit), §2.6 (R1-R6),
           §2.7 (alt referenda), §2.8 (petition).  Decoupled from
           10_canton_reg1_tables.do (which handles the primary 20-OLS battery).

           IMPORTANT: this script DOES NOT touch the existing
           `all_tables_summary.md`.  It writes its own master summary at
           `results/tables/_md/robust/canton_robustness_summary.md`.

 Inputs:   results/intermediate/estimates/ols_*_5.ster              (5 primary OLS at col 5)
           results/intermediate/estimates_fraclogit/fl_me_*.ster    (20 marginal-effects stores from §2.5)
           results/intermediate/estimates_robust/r{1-6}_*.ster      (0-6 stores from §2.6)
           results/intermediate/estimates_altY/vote_{60,63,65}.ster (0-3 from §2.7; may be empty)
           results/intermediate/estimates_altY/petition.ster        (0-1 from §2.8; may be empty)

 Outputs:  results/tables/canton_robustness_*.tex                   (1-4 LaTeX, one per section)
           results/tables/_csv/robust/canton_robustness_*.csv       (parallel CSV intermediates)
           results/tables/_md/robust/canton_robustness_*.md         (parallel per-table MDs)
           results/tables/_md/robust/canton_robustness_summary.md   (combined master)

 Sections produced (each independent; if its .ster files are missing, the
 section emits a SKIPPED message and the script continues):
   1. Fraclogit AME vs OLS for the 4 wine variants at cascade col 5
   2. R1-R6 robustness (alt absinthe measures + drop-NE + interaction)
   3. Supplemental referenda (votes 60, 63, 65)
   4. Petition signatures as alternative Y

 Helper:   $MyProject/scripts/python/esttab_csv_to_markdown.py
           (invoked with 3-arg form so it also emits the combined summary)

 Author:   Nicholas A Jensen
 Date:     2026-05-20
 Version:  0.1
==============================================================================*/

/* Pre-run reminder
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do" %for setup
*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}
cap which esttab
if _rc {
    di as error "  esttab not found.  Source _install_stata_packages.do first."
    error 199
}

* Output directories
cap mkdir "$MyProject/results"
cap mkdir "$MyProject/results/tables"
cap mkdir "$MyProject/results/tables/_csv"
cap mkdir "$MyProject/results/tables/_csv/robust"
cap mkdir "$MyProject/results/tables/_md"
cap mkdir "$MyProject/results/tables/_md/robust"


**# 1. Section 1: Fraclogit AME vs OLS at cascade col 5
*------------------------------------------------------------------------------*
* Compare OLS beta to fracreg-logit average marginal effect for each of the 4
* wine variants at cascade col 5 (full controls).  Same coefficient scale; if
* both methods give similar magnitudes, OLS isn't getting bullied by the
* [0,100] boundedness of the outcome.
*
* Requires: ols_*_5.ster (5 OLS at col 5) AND fl_me_*_5.ster (5 fraclogit AMEs).
{
    local section1_ok = 1
    foreach k in 1 2 3 4 {
        cap confirm file "$MyProject/results/intermediate/estimates/ols_`k'_5.ster"
        if _rc local section1_ok = 0
        cap confirm file "$MyProject/results/intermediate/estimates_fraclogit/fl_me_`k'_5.ster"
        if _rc local section1_ok = 0
    }
    if !`section1_ok' {
        di as error "  Section 1 SKIPPED: requires ols_*_5.ster (run 09 §2.1) AND fl_me_*_5.ster (run 09 §2.5)"
    }
    else {
        foreach k in 1 2 3 4 {
            cap estimates drop ols_`k'_5
            estimates use "$MyProject/results/intermediate/estimates/ols_`k'_5.ster"
            estimates store ols_`k'_5

            cap estimates drop fl_me_`k'_5
            estimates use "$MyProject/results/intermediate/estimates_fraclogit/fl_me_`k'_5.ster"
            estimates store fl_me_`k'_5
        }

        local keeplist "X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons"

        * LaTeX
        esttab ols_1_5 fl_me_1_5 ols_2_5 fl_me_2_5 ols_3_5 fl_me_3_5 ols_4_5 fl_me_4_5 ///
            using "$MyProject/results/tables/canton_robustness_fraclogit_vs_ols.tex", ///
            replace booktabs ///
            title("Fraclogit AME vs OLS at cascade col 5 (4 wine variants)" \label{tab:flvsols}) ///
            mtitles("OLS X1" "FL X1" "OLS X2" "FL X2" "OLS X3" "FL X3" "OLS X4" "FL X4") ///
            keep(`keeplist') order(`keeplist') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("Cascade col 5 (full controls).  OLS HC3 robust SEs.  FL = fracreg logit average marginal effects via margins (sandwich SEs).  FL columns show only the wine-treatment AME because margins, dydx(\${X_spec\`k'}) post stores only that variable.")

        * CSV intermediate for Python -> MD
        esttab ols_1_5 fl_me_1_5 ols_2_5 fl_me_2_5 ols_3_5 fl_me_3_5 ols_4_5 fl_me_4_5 ///
            using "$MyProject/results/tables/_csv/robust/canton_robustness_fraclogit_vs_ols.csv", ///
            replace csv ///
            title("Fraclogit AME vs OLS at cascade col 5 (4 wine variants)") ///
            mtitles("OLS X1" "FL X1" "OLS X2" "FL X2" "OLS X3" "FL X3" "OLS X4" "FL X4") ///
            keep(`keeplist') order(`keeplist') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Section 1 done: Fraclogit AME vs OLS"
    }
}


**# 2. Section 2: R1-R6 robustness (alt absinthe, drop-NE, interaction)
*------------------------------------------------------------------------------*
{
    local section2_ok = 1
    foreach r in r1_nfirms r2_producer r3_abslog r4_fr_x_prod r5_drop_ne r6_loglog {
        cap confirm file "$MyProject/results/intermediate/estimates_robust/`r'.ster"
        if _rc local section2_ok = 0
    }
    if !`section2_ok' {
        di as error "  Section 2 SKIPPED: requires r1-r6 .ster files (run 09 §2.6)"
    }
    else {
        foreach r in r1_nfirms r2_producer r3_abslog r4_fr_x_prod r5_drop_ne r6_loglog {
            cap estimates drop `r'
            estimates use "$MyProject/results/intermediate/estimates_robust/`r'.ster"
            estimates store `r'
        }

        local keeplist_r "X2_share wine_vol_log cov1 cov2_total_share abs_nfirms abs_producer abs_log fr_x_producer cov3 cov_land ln_pop_1900 _cons"

        esttab r1_nfirms r2_producer r3_abslog r4_fr_x_prod r5_drop_ne r6_loglog ///
            using "$MyProject/results/tables/canton_robustness_r1_r6.tex", ///
            replace booktabs ///
            title("Robustness battery R1-R6: alt absinthe measures + drop-NE + interaction" \label{tab:r1r6}) ///
            mtitles("(R1) n_firms" "(R2) producer" "(R3) abs_log" "(R4) fr x prod" "(R5) drop-NE" "(R6) log-log") ///
            keep(`keeplist_r') order(`keeplist_r') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("All HC3 robust SEs.  R5 sample excludes NE (N=24); all other cols N=25.")

        esttab r1_nfirms r2_producer r3_abslog r4_fr_x_prod r5_drop_ne r6_loglog ///
            using "$MyProject/results/tables/_csv/robust/canton_robustness_r1_r6.csv", ///
            replace csv ///
            title("Robustness battery R1-R6") ///
            mtitles("(R1) n_firms" "(R2) producer" "(R3) abs_log" "(R4) fr x prod" "(R5) drop-NE" "(R6) log-log") ///
            keep(`keeplist_r') order(`keeplist_r') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Section 2 done: R1-R6 robustness"
    }
}


**# 3. Section 3: Supplemental referenda (votes 60, 63, 65)
*------------------------------------------------------------------------------*
* If 09 §2.7 found any of the vote_*.ster files, build a table with those that
* exist.  If none exist (the current cohort state -- 08 only loads 67/68/69),
* emit a skip message and move on.
{
    local found_votes ""
    foreach v in 60 63 65 {
        cap confirm file "$MyProject/results/intermediate/estimates_altY/vote_`v'.ster"
        if !_rc local found_votes "`found_votes' `v'"
    }

    if "`found_votes'" == "" {
        di as error "  Section 3 SKIPPED: no vote_*.ster found in estimates_altY/"
        di as error "    (Expected: run 09 §2.7 after extending 08 to load votes 60/63/65)"
    }
    else {
        local cols ""
        local mtitles_str ""
        foreach v of local found_votes {
            cap estimates drop vote_`v'
            estimates use "$MyProject/results/intermediate/estimates_altY/vote_`v'.ster"
            estimates store vote_`v'
            local cols "`cols' vote_`v'"
            local mtitles_str `mtitles_str' "Vote `v'"
        }

        local keeplist_v "X2_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons"

        esttab `cols' ///
            using "$MyProject/results/tables/canton_robustness_alt_votes.tex", ///
            replace booktabs ///
            title("Supplemental referenda: primary spec on alternative Y outcomes" \label{tab:altvotes}) ///
            mtitles(`mtitles_str') ///
            keep(`keeplist_v') order(`keeplist_v') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("HC3 robust SEs.  Primary spec (cascade col 5 with X2_share) applied to alternative referenda.")

        esttab `cols' ///
            using "$MyProject/results/tables/_csv/robust/canton_robustness_alt_votes.csv", ///
            replace csv ///
            title("Supplemental referenda") ///
            mtitles(`mtitles_str') ///
            keep(`keeplist_v') order(`keeplist_v') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Section 3 done: alt-referenda table (`found_votes')"
    }
}


**# 4. Section 4: Petition signatures vs vote 68
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/results/intermediate/estimates_altY/petition.ster"
    if _rc {
        di as error "  Section 4 SKIPPED: no petition.ster in estimates_altY/"
        di as error "    (Expected: run 09 §2.8 after petition_signatures_1907.csv lands)"
    }
    else {
        cap estimates drop petition
        estimates use "$MyProject/results/intermediate/estimates_altY/petition.ster"
        estimates store petition

        cap estimates drop ols_2_5
        estimates use "$MyProject/results/intermediate/estimates/ols_2_5.ster"
        estimates store ols_2_5

        local keeplist_p "X2_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons"

        esttab ols_2_5 petition ///
            using "$MyProject/results/tables/canton_robustness_petition.tex", ///
            replace booktabs ///
            title("Petition signatures vs vote 68 (parallel outcomes)" \label{tab:petition}) ///
            mtitles("Vote 68 (Y1)" "Petition share") ///
            keep(`keeplist_p') order(`keeplist_p') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("HC3 robust SEs.  Both columns use the primary spec (cascade col 5 with X2_share).  Y differs: yes-vote share vs petition-signature share.")

        esttab ols_2_5 petition ///
            using "$MyProject/results/tables/_csv/robust/canton_robustness_petition.csv", ///
            replace csv ///
            title("Petition signatures vs vote 68") ///
            mtitles("Vote 68 (Y1)" "Petition share") ///
            keep(`keeplist_p') order(`keeplist_p') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Section 4 done: petition table"
    }
}


**# 5. Invoke Python helper: convert robust CSV intermediates to MD + summary
*------------------------------------------------------------------------------*
* The 3-arg form of esttab_csv_to_markdown.py writes both per-table .md files
* AND a combined `canton_robustness_summary.md` master in the output dir.
*
* This explicitly targets the robust/ subdirectory so the existing
* all_tables_summary.md (in _md/, NOT _md/robust/) is not touched.
{
    local pyscript "$MyProject/scripts/python/esttab_csv_to_markdown.py"
    local indir    "$MyProject/results/tables/_csv/robust"
    local outdir   "$MyProject/results/tables/_md/robust"
    local summary  "canton_robustness_summary.md"

    cap confirm file "`pyscript'"
    if _rc {
        di as error "  Python helper not found: `pyscript'"
        di as error "  Skipping markdown generation."
    }
    else {
        di as text _newline "  --- Invoking python markdown converter (+ summary) ---"
        shell python "`pyscript'" "`indir'" "`outdir'" "`summary'"
        di as text _newline "  Robustness markdown done.  Outputs:"
        di as text "    LaTeX:   \$MyProject/results/tables/canton_robustness_*.tex"
        di as text "    CSV:     \$MyProject/results/tables/_csv/robust/*.csv"
        di as text "    MD:      \$MyProject/results/tables/_md/robust/*.md"
        di as text "    Summary: \$MyProject/results/tables/_md/robust/`summary'"
        di as text _newline "  NOTE: all_tables_summary.md (the primary OLS master) is untouched."
    }
}


**# 6. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        di as text "  (inventory append: post-credits structure ready for release runs)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
