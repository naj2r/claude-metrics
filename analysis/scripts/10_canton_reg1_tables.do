/*==============================================================================
 10_canton_reg1_tables.do
 Purpose:  Build LaTeX + markdown tables from the 20 OLS estimates produced
           by 09_canton_reg1.do §2.  Decoupled from 09's in-memory state via
           the .ster files, so this script can be re-run independently after
           09 has produced the estimates.

           Outputs per spec set (k=1..4) plus 1 horse-race table:
             - LaTeX (paper-bound) in results/tables/
             - CSV intermediate (esttab native) in results/tables/_csv/
             - Markdown twin (via python helper) in results/tables/_md/

 Input:    $MyProject/results/intermediate/estimates/ols_{k}_{j}.ster
                                                   (20 files; k=1..4, j=1..5)

 Output:   $MyProject/results/tables/cascade_spec{k}.tex                (4 LaTeX)
           $MyProject/results/tables/altwine_horserace.tex              (1 LaTeX)
           $MyProject/results/tables/_csv/{same names}.csv              (5 CSV)
           $MyProject/results/tables/_md/{same names}.md                (5 MD)

 Helper:   $MyProject/scripts/python/esttab_csv_to_markdown.py
           (called via `shell python ...` at end of script -- user-authorized
           for markdown post-processing only; replaces the missing esttab_md
           helper that the orchestrator's dispatch referenced)

 Author:   Nicholas A Jensen
 Date:     2026-05-20
 Version:  0.1
==============================================================================*/

/* Pre-run reminder
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do" %for setup
*/

version 19

* Standalone-execution preamble
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

* Sanity: estout suite must be available (esttab is part of estout)
cap which esttab
if _rc {
    di as error "  esttab not found.  Source _install_stata_packages.do first."
    error 199
}


**# 1. Load all 20 estimates from .ster files
*------------------------------------------------------------------------------*
* Decouples this script from 09's in-memory state -- can re-run 10 at any time
* as long as the .ster files exist on disk.
{
    di as text _newline "  --- Loading 20 estimates from .ster files ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            cap confirm file "$MyProject/results/intermediate/estimates/ols_`k'_`j'.ster"
            if _rc {
                di as error "  Missing .ster for ols_`k'_`j'"
                di as error "  Run 09_canton_reg1.do §2 first to generate the .ster files."
                error 601
            }
            * Idempotency: drop existing estimates store under this name
            cap estimates drop ols_`k'_`j'
            estimates use "$MyProject/results/intermediate/estimates/ols_`k'_`j'.ster"
            estimates store ols_`k'_`j'
        }
    }
    di as text "  Loaded 20 estimates (4 wine variants x 5 cascade columns)"
}


**# 2. Per-spec-set cascade tables (4 LaTeX + 4 CSV intermediates)
*------------------------------------------------------------------------------*
{
    cap mkdir "$MyProject/results"
    cap mkdir "$MyProject/results/tables"
    cap mkdir "$MyProject/results/tables/_csv"
    cap mkdir "$MyProject/results/tables/_md"

    * Spec-set titles and corresponding wine variable names (parallel lists)
    local title_1 "Per-capita vineyard area (X1)"
    local title_2 "Wine volume share of national (X2_share)"
    local title_3 "Wine revenue share of national (X3_share)"
    local title_4 "Wine area share of national (X1_share)"

    local wine_1 "X1"
    local wine_2 "X2_share"
    local wine_3 "X3_share"
    local wine_4 "X1_share"

    di as text _newline "  --- Writing 4 cascade tables (LaTeX + CSV) ---"
    foreach k in 1 2 3 4 {
        * LaTeX cascade table (paper-bound)
        esttab ols_`k'_1 ols_`k'_2 ols_`k'_3 ols_`k'_4 ols_`k'_5 ///
            using "$MyProject/results/tables/cascade_spec`k'.tex", ///
            replace booktabs ///
            title("Spec set `k' cascade: `title_`k''" \label{tab:cascade`k'}) ///
            mtitles("(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog") ///
            keep(`wine_`k'' cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
            order(`wine_`k'' cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01) ///
            addnote("HC3 robust standard errors in parentheses." ///
                    "Spec set `k'. Cascade columns 1-5. Priorban tabled.")

        * CSV intermediate (for the Python markdown converter)
        esttab ols_`k'_1 ols_`k'_2 ols_`k'_3 ols_`k'_4 ols_`k'_5 ///
            using "$MyProject/results/tables/_csv/cascade_spec`k'.csv", ///
            replace csv ///
            title("Spec set `k' cascade: `title_`k''") ///
            mtitles("(1) baseline" "(2) +french" "(3) +absinthe" "(4) +protestant" "(5) +geog") ///
            keep(`wine_`k'' cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
            order(`wine_`k'' cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
            cells(b(star fmt(3)) se(par fmt(3))) ///
            stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
            starlevels(* 0.10 ** 0.05 *** 0.01)

        di as text "  Wrote cascade_spec`k'.{tex,csv}"
    }
}


**# 3. Alt-wine horse race table (1 LaTeX + 1 CSV)
*------------------------------------------------------------------------------*
* All 4 wine variants at cascade col 5 (full controls) side-by-side.
{
    di as text _newline "  --- Writing horse-race table (LaTeX + CSV) ---"

    esttab ols_1_5 ols_2_5 ols_3_5 ols_4_5 ///
        using "$MyProject/results/tables/altwine_horserace.tex", ///
        replace booktabs ///
        title("Wine-variant horse race: all spec sets at cascade col 5" \label{tab:horserace}) ///
        mtitles("(1) per-cap" "(2) vol share" "(3) rev share" "(4) area share") ///
        keep(X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
        order(X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
        starlevels(* 0.10 ** 0.05 *** 0.01) ///
        addnote("HC3 robust standard errors in parentheses." ///
                "All columns at cascade col 5 (full controls). N=25 cantons.")

    esttab ols_1_5 ols_2_5 ols_3_5 ols_4_5 ///
        using "$MyProject/results/tables/_csv/altwine_horserace.csv", ///
        replace csv ///
        title("Wine-variant horse race: all spec sets at cascade col 5") ///
        mtitles("(1) per-cap" "(2) vol share" "(3) rev share" "(4) area share") ///
        keep(X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
        order(X1 X2_share X3_share X1_share cov1 cov2_total_share cov3 cov_land ln_pop_1900 _cons) ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        stats(N r2 rmse, fmt(0 3 3) labels("N" "R-squared" "RMSE")) ///
        starlevels(* 0.10 ** 0.05 *** 0.01)

    di as text "  Wrote altwine_horserace.{tex,csv}"
}


**# 4. Markdown twins via python helper
*------------------------------------------------------------------------------*
* The orchestrator's dispatch referenced esttab_md.ado, which doesn't exist
* in this project.  Instead, we use Stata's `csv` export as a stable
* intermediate format and a small Python script to render proper markdown
* tables.  Python is the right tool here -- markdown rendering is text
* manipulation, which Python does cleanly with stdlib (csv + pathlib).
{
    di as text _newline "  --- Invoking python markdown converter ---"
    local pyscript "$MyProject/scripts/python/esttab_csv_to_markdown.py"
    local indir    "$MyProject/results/tables/_csv"
    local outdir   "$MyProject/results/tables/_md"

    cap confirm file "`pyscript'"
    if _rc {
        di as error "  Python helper not found: `pyscript'"
        di as error "  Skipping markdown twin generation."
    }
    else {
        shell python "`pyscript'" "`indir'" "`outdir'"
        di as text _newline "  Markdown generation done.  Outputs in:"
        di as text "    LaTeX: \$MyProject/results/tables/*.tex"
        di as text "    CSV:   \$MyProject/results/tables/_csv/*.csv"
        di as text "    MD:    \$MyProject/results/tables/_md/*.md"
    }
}


**# 5. Post-credits: codebook + inventory (inventory only on release runs)
*------------------------------------------------------------------------------*
* This script writes only .tex/.csv/.md tables (no .dta).  Codebook update is
* skipped (no dataset to describe).  Inventory append only fires on release
* runs to avoid polluting _inventory.xlsx during iteration.
{
    if "${RUN_POSTCREDITS}" == "1" {
        * _inventory_append, sheet("scripts") ///
        *     row("10_canton_reg1_tables.do|.|Generate LaTeX + MD tables from 09 .ster files|.")
        * _inventory_append, sheet("outputs") ///
        *     row("created|results/tables/cascade_spec1.tex|.|.|.|10_canton_reg1_tables.do")
        * (etc. for each output; uncomment when finalized)
        di as text "  (inventory append: post-credits structure ready for release runs)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
