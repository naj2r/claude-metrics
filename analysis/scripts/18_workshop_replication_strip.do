/*==============================================================================
 18_workshop_replication_strip.do
 Purpose:  Generate the stripped replication cohort from the full workshop
           cohort.  This is a pure regenerable derivative — to adjust the
           strip, edit the KEEP_LIST below and re-run.  Do not hand-edit the
           output .dta.

 Input:    $MyProject/processed/cohort_1908_workshop.dta
 Output:   $MyProject/processed/cohort_1908_workshop_replication.dta
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21

 DESIGN PRINCIPLE
 ----------------
 The FULL cohort (cohort_1908_workshop.dta) is the canonical workshop source
 of truth.  All workshop scripts (09w, 12w, 14w, 10w, 11w, 13w, 15w, 16w)
 consume the FULL cohort.

 The STRIPPED cohort is built by loading the FULL and applying a single
 `keep` statement.  It exists only for journal-package distribution and
 external-replication purposes — nothing in the project's pipeline reads it.

 §3 verification asserts byte-identical regression results between FULL and
 STRIPPED for sentinel specs (tolerance 1e-12).  If any sentinel fails, the
 strip is over-aggressive and KEEP_LIST must be expanded.
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


**# 1. The KEEP LIST — single point of editing for strip aggressiveness
*------------------------------------------------------------------------------*
* To strip MORE: remove a variable from this list and re-run.
* To strip LESS: add a variable to this list and re-run.
* Verification (§3 below) will confirm the resulting strip still produces
* byte-identical workshop regression results.

local KEEP_LIST ""

* --- IDs ---
local KEEP_LIST `KEEP_LIST' canton_iso

* --- Workshop regression outcomes ---
local KEEP_LIST `KEEP_LIST' Y1 pct_yes_67 pct_yes_68 pct_yes_69 pet_per_eligible turnout_68

* --- Workshop wine regressors ---
local KEEP_LIST `KEEP_LIST' X1 X2_share X3_share

* --- Workshop cultural covariates ---
local KEEP_LIST `KEEP_LIST' cov1 cov3

* --- Workshop absinthe + interactions ---
local KEEP_LIST `KEEP_LIST' cov2_total_share abs_producer fr_x_producer

* --- Workshop geographic + demographic ---
local KEEP_LIST `KEEP_LIST' ln_density pop_1900

* --- Petition raw counts (for re-derivation transparency) ---
local KEEP_LIST `KEEP_LIST' pet_total pet_valid pet_invalid eligible_1906

* --- Cross-referendum parity (forward-looking, low cost) ---
local KEEP_LIST `KEEP_LIST' turnout_67 turnout_69 yes_count_68 no_count_68

* --- Geographic flexibility (recovers cov_land, ln_pop, density alts) ---
local KEEP_LIST `KEEP_LIST' canton_area_km2 pop_density_1900 cov_land ln_pop_1900

* --- Phase 9: wine-type decomposition (value-based) ---
local KEEP_LIST `KEEP_LIST' X3_white_num X3_red_num X3_white_share X3_red_share

* --- Phase 10: white-wine mechanism interactions ---
local KEEP_LIST `KEEP_LIST' X3_white_x_cov1 X3_white_x_absprod X3_white_x_cov2

* --- Phase 10b: volume-share variants + interaction ---
local KEEP_LIST `KEEP_LIST' wine_volume_white wine_volume_red
local KEEP_LIST `KEEP_LIST' X3_white_vol_share X3_red_vol_share X3_white_vol_ratio X3_white_vol_x_cov1

* --- Add additional variables here as needed for forward-looking robustness ---


**# 2. Load full cohort, apply keep, save stripped
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  cohort_1908_workshop.dta missing.  Run 08_workshop + 09_workshop first."
        error 601
    }

    use "$MyProject/processed/cohort_1908_workshop.dta", clear

    local N_FULL = c(N)
    local K_FULL = c(k)

    * Defensive: warn (not fail) if any KEEP_LIST var is missing
    foreach v of local KEEP_LIST {
        cap confirm variable `v'
        if _rc {
            di as text "  WARN: requested keep var `v' not in cohort — will skip"
        }
    }

    * Build the keep-list of vars that actually exist
    local KEEP_LIST_PRESENT ""
    foreach v of local KEEP_LIST {
        cap confirm variable `v'
        if !_rc {
            local KEEP_LIST_PRESENT `KEEP_LIST_PRESENT' `v'
        }
    }

    keep `KEEP_LIST_PRESENT'

    local N_STRIP = c(N)
    local K_STRIP = c(k)

    di as text _newline "  Strip applied:"
    di as text "    Observations: " `N_FULL' " (full) -> " `N_STRIP' " (strip)"
    di as text "    Variables:    " `K_FULL' " (full) -> " `K_STRIP' " (strip)"

    assert `N_FULL' == `N_STRIP'

    compress
    save "$MyProject/processed/cohort_1908_workshop_replication.dta", replace
    di as text "  Saved: cohort_1908_workshop_replication.dta"
}


**# 3. Verification: stripped cohort produces identical regression results
*------------------------------------------------------------------------------*
* Sentinel regressions: if any one diverges between full and strip, the strip
* is over-aggressive and the KEEP_LIST needs an addition.
*
* Tolerance: 1e-12 for byte-identical (strict).  Widen to 1e-10 if numerical
* noise from compression bites; investigate first before widening.
{
    local sentinel_1 "Y1 X3_share cov1 cov2_total_share cov3 ln_density"
    local sentinel_2 "pet_per_eligible X3_share cov1 cov2_total_share cov3 ln_density"
    local sentinel_3 "Y1 X2_share cov1 abs_producer fr_x_producer cov2_total_share cov3 ln_density"
    local sentinel_4 "pct_yes_67 X3_share cov1 cov2_total_share cov3 ln_density"
    * Phase 9 sentinel: white-wine cascade
    local sentinel_5 "Y1 X3_white_share cov1 cov2_total_share cov3 ln_density"
    * Phase 10 sentinel: white × French interaction (D1)
    local sentinel_6 "Y1 X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density"
    * Phase 10b sentinel: volume-share white × French (D1v)
    local sentinel_7 "Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density"

    di as text _newline "  --- Sentinel regression equivalence checks ---"

    forvalues s = 1/7 {
        local spec "`sentinel_`s''"
        local Y    : word 1 of `spec'
        local X    : word 2 of `spec'

        * Run on FULL cohort
        qui use "$MyProject/processed/cohort_1908_workshop.dta", clear
        cap noi qui regress `spec', vce(hc3)
        if _rc {
            di as error "  Sentinel `s' regression failed on FULL cohort (rc=" _rc ")"
            error 9
        }
        local b_full  = _b[`X']
        local se_full = _se[`X']

        * Run on STRIPPED cohort
        qui use "$MyProject/processed/cohort_1908_workshop_replication.dta", clear
        cap noi qui regress `spec', vce(hc3)
        if _rc {
            di as error "  Sentinel `s' regression failed on STRIPPED cohort (rc=" _rc ")"
            error 9
        }
        local b_strip  = _b[`X']
        local se_strip = _se[`X']

        local diff_b  = abs(`b_full'  - `b_strip')
        local diff_se = abs(`se_full' - `se_strip')

        if (`diff_b' > 1e-12) | (`diff_se' > 1e-12) {
            di as error "  DIVERGENCE on sentinel `s' [`spec']:"
            di as error "    Full:  b=" %12.8f `b_full'  ", se=" %12.8f `se_full'
            di as error "    Strip: b=" %12.8f `b_strip' ", se=" %12.8f `se_strip'
            di as error "    |Δb| = " %12.2e `diff_b' ", |Δse| = " %12.2e `diff_se'
            di as error "  ACTION: add variable(s) to KEEP_LIST or investigate."
            error 9
        }
        else {
            di as text "  Sentinel `s' OK: b=" %12.8f `b_full' " (Δ < 1e-12) — full ≡ strip"
        }
    }

    di as text _newline "  All sentinels verified — strip is regression-equivalent to full."
}


**# 4. Post-credits
*------------------------------------------------------------------------------*
{
    cap which _codebook_update
    if !_rc {
        _codebook_update using "$MyProject/processed/cohort_1908_workshop_replication.dta", ///
            script("18_workshop_replication_strip.do")
    }

    if "${RUN_POSTCREDITS}" == "1" {
        cap which _inventory_append
        if !_rc {
            _inventory_append, sheet("datasets") ///
                row("created|processed/cohort_1908_workshop_replication.dta|`=c(N)'|`=c(k)'|.|18_workshop_replication_strip.do")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
