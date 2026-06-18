/*==============================================================================
 13_canton_petition_tables.do
 Purpose:  Build LaTeX + markdown tables from the 20 OLS estimates produced by
           12_canton_petition.do §2.1.  Decoupled from 12's in-memory state via
           the .ster files.  Writes its own markdown summary at
           `results/tables/_md/petition/canton_petition_summary.md` -- SEPARATE
           from both `all_tables_summary.md` (primary OLS, from 10) AND
           `canton_robustness_summary.md` (from 11).

 Inputs:   results/intermediate/estimates_petition/ols_pet_{k}_{j}.ster
                                                   (20 files; k=1..4, j=1..5)

 Outputs:  results/tables/canton_petition_cascade_spec{k}.tex      (4 LaTeX)
           results/tables/canton_petition_horserace.tex            (1 LaTeX)
           results/tables/_csv/petition/canton_petition_*.csv      (5 CSV)
           results/tables/_md/petition/canton_petition_*.md        (5 per-table MD)
           results/tables/_md/petition/canton_petition_summary.md  (combined master)

 Helper:   $MyProject/scripts/python/esttab_csv_to_markdown.py
           (3-arg form so it auto-emits the summary)

 Author:   Nicholas A Jensen
 Date:     2026-05-20
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
cap which esttab
if _rc {
    di as error "  esttab not found.  Source _install_stata_packages.do first."
    error 199
}

* Output dirs
cap mkdir "$MyProject/results"
cap mkdir "$MyProject/results/tables"
cap mkdir "$MyProject/results/tables/_csv"
cap mkdir "$MyProject/results/tables/_csv/petition"
cap mkdir "$MyProject/results/tables/_md"
cap mkdir "$MyProject/results/tables/_md/petition"


**# 1. Load 20 petition .ster files (gracefully skip whole script if missing)
*------------------------------------------------------------------------------*
* If 12 hasn't been run, OR the petition CSV was missing when 12 ran (so §2
* skipped), there will be no .ster files.  Detect and exit early with an
* actionable message rather than producing empty tables.
{
    local all_present = 1
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            cap confirm file "$MyProject/results/intermediate/estimates_petition/ols_pet_`k'_`j'.ster"
            if _rc local all_present = 0
        }
    }

    if !`all_present' {
        di as error _newline "  13 SKIPPED: petition .ster files incomplete or missing."
        di as error "  Expected 20 files at:"
        di as error "    \$MyProject/results/intermediate/estimates_petition/ols_pet_{1-4}_{1-5}.ster"
        di as error "  Run 12_canton_petition.do first (which requires the petition CSV at"
        di as error "  \$Absinthe1Data/petition_signatures_1907_VERIFIED.csv)."
        exit
    }

    di as text _newline "  --- Loading 20 petition estimates ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            cap estimates drop ols_pet_`k'_`j'
            estimates use "$MyProject/results/intermediate/estimates_petition/ols_pet_`k'_`j'.ster"
            estimates store ols_pet_`k'_`j'
        }
    }
    di as text "  Loaded 20 estimates (4 wine variants x 5 cascade cols)"
}


**# 2. Per-spec-set cascade tables (4 LaTeX + 4 CSV)
*------------------------------------------------------------------------------*
{
    local title_1 "Per-capita vineyard area (X1)"
    local title_2 "Wine volume share of national (X2_share)"
    local title_3 "Wine revenue share of national (X3_share)"
    local title_4 "Wine area share of national (X1_share)"

    local wine_1 "X1"
    local wine_2 "X2_share"
    local wine_3 "X3_share"
    local wine_4 "X1_share"

    local keeplist_base "cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons"

    di as text _newline "  --- Writing 4 petition cascade tables (LaTeX + CSV) ---"
    foreach k in 1 2 3 4 {
        local keeplist "`wine_`k'' `keeplist_base'"

        esttab ols_pet_`k'_1 ols_pet_`k'_2 ols_pet_`k'_3 ols_pet_`k'_4 ols_pet_`k'_5 ///
            using "$MyProject/results/tables/canton_petition_cascade_spec`k'.tex", ///
            replace booktabs ///
            title("Petition cascade `k': `title_`k''  (Y = pet_per_eligible)" \label{tab:petcasc`k'}) ///
            mtitles("(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog") ///
            keep(`keeplist') order(`keeplist') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("HC3 robust standard errors in parentheses." ///
                    "Y = pet_per_eligible (petition signatures per 100 eligible voters, vote 65 denom)." ///
                    "Spec set `k'. Cascade columns 1-5.")

        esttab ols_pet_`k'_1 ols_pet_`k'_2 ols_pet_`k'_3 ols_pet_`k'_4 ols_pet_`k'_5 ///
            using "$MyProject/results/tables/_csv/petition/canton_petition_cascade_spec`k'.csv", ///
            replace csv ///
            title("Petition cascade `k': `title_`k''") ///
            mtitles("(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog") ///
            keep(`keeplist') order(`keeplist') ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Wrote canton_petition_cascade_spec`k'.{tex,csv}"
    }
}


**# 3. Horse-race table: 4 wine variants at cascade col 5
*------------------------------------------------------------------------------*
{
    local keeplist_h "X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons"

    esttab ols_pet_1_5 ols_pet_2_5 ols_pet_3_5 ols_pet_4_5 ///
        using "$MyProject/results/tables/canton_petition_horserace.tex", ///
        replace booktabs ///
        title("Petition horse race: 4 wine variants at cascade col 5  (Y = pet_per_eligible)" \label{tab:pethr}) ///
        mtitles("(1) per-cap" "(2) vol share" "(3) rev share" "(4) area share") ///
        keep(`keeplist_h') order(`keeplist_h') ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
        starlevels(* 0.10 ** 0.05 *** 0.01) ///
        addnote("HC3 robust standard errors in parentheses." ///
                "Y = pet_per_eligible (petition signatures per 100 eligible voters, vote 65 denom)." ///
                "All columns at cascade col 5 (full controls). N=25 cantons.")

    esttab ols_pet_1_5 ols_pet_2_5 ols_pet_3_5 ols_pet_4_5 ///
        using "$MyProject/results/tables/_csv/petition/canton_petition_horserace.csv", ///
        replace csv ///
        title("Petition horse race: 4 wine variants at cascade col 5") ///
        mtitles("(1) per-cap" "(2) vol share" "(3) rev share" "(4) area share") ///
        keep(`keeplist_h') order(`keeplist_h') ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
        starlevels(* 0.10 ** 0.05 *** 0.01)

    di as text "  Wrote canton_petition_horserace.{tex,csv}"
}


**# 4. Invoke Python helper: per-CSV MDs + combined master summary
*------------------------------------------------------------------------------*
* 3-arg form of esttab_csv_to_markdown.py emits per-table MDs AND
* canton_petition_summary.md in the same output dir.  Targets the petition/
* subdirectory so the primary all_tables_summary.md and the robustness
* canton_robustness_summary.md are not touched.
{
    local pyscript "$MyProject/scripts/python/esttab_csv_to_markdown.py"
    local indir    "$MyProject/results/tables/_csv/petition"
    local outdir   "$MyProject/results/tables/_md/petition"
    local summary  "canton_petition_summary.md"

    cap confirm file "`pyscript'"
    if _rc {
        di as error "  Python helper not found: `pyscript'"
        di as error "  Skipping markdown generation."
    }
    else {
        di as text _newline "  --- Invoking python markdown converter (+ summary) ---"
        shell python "`pyscript'" "`indir'" "`outdir'" "`summary'"
        di as text _newline "  Petition markdown done.  Outputs:"
        di as text "    LaTeX:   \$MyProject/results/tables/canton_petition_*.tex"
        di as text "    CSV:     \$MyProject/results/tables/_csv/petition/*.csv"
        di as text "    MD:      \$MyProject/results/tables/_md/petition/*.md"
        di as text "    Summary: \$MyProject/results/tables/_md/petition/`summary'"
        di as text _newline "  NOTE: all_tables_summary.md AND canton_robustness_summary.md untouched."
    }
}


**# 5. Post-credits
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
