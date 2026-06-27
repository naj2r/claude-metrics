/*==============================================================================
 12_canton_petition_workshop.do
 Purpose:  Workshop variant of 12.  Reads the canonical full workshop cohort
           (which already contains pet_per_eligible / pet_per_cap / pet_natshare
           from 09_workshop §1.6), runs the 20-spec petition battery on
           pet_per_eligible with the density-swap col 5 controls.
 Input:    $MyProject/processed/cohort_1908_workshop.dta  (canonical full;
           written by 09_workshop §1.7)
 Output:   $MyProject/results/intermediate/estimates_petition_workshop/
                ols_pet_k_j.ster (20 files)
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21

 LINEAGE / DESIGN CHOICE
 -----------------------
 Per dispatch Phase 3: "Reads cohort_1908_workshop.dta directly — it already
 contains the petition merge + eligible_1906 + all derivations, so 12_workshop's
 import logic (§1.1 vote 65 eligibility, §1.2 petition XLSX) becomes a
 defensive no-op."

 Therefore this script is much shorter than 12.  It sources 09_workshop in
 SKIP mode to guarantee the spec globals ($ctrl_s_c1-c5, $X_spec*) are
 populated in memory (those globals live in macro space, not in the .dta),
 and to apply any §1.x derivations defensively.  Then it runs the 20-spec
 petition battery on Y = pet_per_eligible with HC3 SEs.

 Routes .ster files to estimates_petition_workshop/ (separate from existing
 estimates_petition/ to keep workshop outputs distinct).
==============================================================================*/

version 19


**# 0. Preamble
*------------------------------------------------------------------------------*
{
    * Petition national total (Bundesblatt 1907 p.984) — also defined in
    * 09_workshop §1.6, but kept here for standalone runs.
    global PET_NAT_TOTAL = 169377
}
/* Manual mode helper
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"
*/


**# 1. Setup: source 09_workshop (skip regressions) to load cohort + globals
*------------------------------------------------------------------------------*
* 09_workshop in SKIP mode:
*   - Loads cohort_1908_workshop.dta (if not already in memory)
*   - Idempotently re-applies §1.x derivations (cap drop + gen pattern)
*   - Defines spec globals ($X_spec*, $ctrl_1_c*, $ctrl_s_c*)
*   - Defines petition Y outcomes (pet_per_eligible etc.)
*   - Overwrites cohort_1908_workshop.dta (idempotent — same content)
*   - Exits at §2.0 before any regressions
{
    global SKIP_09_REGRESSIONS = 1
    do "$MyProject/scripts/09_canton_reg1_workshop.do"
    global SKIP_09_REGRESSIONS = ""

    * Sanity: 09_workshop's §1 setup must have completed
    cap confirm variable X1
    if _rc {
        di as error "  09_workshop did not complete §1 setup -- X1 absent."
        error 459
    }
    if "${X_spec1}" == "" {
        di as error "  09_workshop did not set up spec globals -- \$X_spec1 unset."
        error 459
    }
    cap confirm variable pet_per_eligible
    if _rc {
        di as error "  pet_per_eligible absent -- 09_workshop §1.6 should have"
        di as error "  derived it.  Re-run 08_workshop and 09_workshop."
        error 459
    }
    di as text _newline "  09_workshop setup sourced; X1-X4, cov*, \$ctrl_*, pet_per_eligible ready."
}


**# 2. Primary regression battery on Y = pet_per_eligible
*------------------------------------------------------------------------------*
* Same 4 wine variants x 5 cascade cols as 09_workshop §2.1, but Y is the
* petition share instead of the vote share.  HC3 SEs throughout.
*
* Routes to estimates_petition_workshop/ (NEW dir) to keep separate from the
* existing estimates_petition/ (which has the non-workshop col-5 controls).
{
    cap mkdir "$MyProject/results"
    cap mkdir "$MyProject/results/intermediate"
    cap mkdir "$MyProject/results/intermediate/estimates_petition_workshop"

    * Petition fractional Y for fracreg logit (Phase A'', 2026-05-22).
    * pet_per_eligible is on 0-100 scale; divide by 100 to get fracreg-valid [0,1].
    cap drop pet_frac
    gen double pet_frac = pet_per_eligible / 100
    label var pet_frac "Petition signature fraction (0-1)"
    qui sum pet_frac
    assert r(min) >= 0 & r(max) <= 1

    di as text _newline "  --- Petition battery (workshop): 20 OLS + 20 FL specs ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            * --- OLS panel ---
            cap estimates drop ols_pet_`k'_`j'
            qui regress pet_per_eligible ${X_spec`k'} `ctrl', vce(hc3)
            local ols_beta = _b[${X_spec`k'}]
            local ols_N    = e(N)
            local ols_r2   = e(r2)
            estimates store ols_pet_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_petition_workshop/ols_pet_`k'_`j'.ster", replace

            * --- FL twin: fracreg logit on pet_frac (NEW, Phase A'') ---
            cap estimates drop fl_pet_`k'_`j'
            qui fracreg logit pet_frac ${X_spec`k'} `ctrl', vce(robust)
            estimates store fl_pet_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_petition_workshop/fl_pet_`k'_`j'.ster", replace

            cap estimates drop fl_me_pet_`k'_`j'
            qui margins, dydx(*) post
            local fl_ame = _b[${X_spec`k'}]
            estimates store fl_me_pet_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_petition_workshop/fl_me_pet_`k'_`j'.ster", replace

            di as text "  Spec pet`k'.`j': N=`ols_N', R^2=" %5.3f `ols_r2' ///
                       ", OLS beta=" %8.4f `ols_beta' ///
                       ", FL AME(x100)=" %8.4f `fl_ame'*100
        }
    }
    di as text _newline "  Petition battery complete: 20 OLS + 20 FL + 20 FL-AME specs"
    di as text "    saved to estimates_petition_workshop/"
}


**# 3. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    * No new dataset to codebook — this script only produces .ster files.
    if "${RUN_POSTCREDITS}" == "1" {
        cap which _inventory_append
        if !_rc {
            _inventory_append, sheet("scripts") ///
                row("12_canton_petition_workshop.do|.|20-spec petition battery on workshop cohort with density-swap col 5.|.")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
