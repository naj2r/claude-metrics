/*==============================================================================
 _phase10b_diag.do — diagnose D1v N=24 + correct FL file paths
==============================================================================*/

use "$MyProject/processed/cohort_1908_workshop.dta", clear

di _newline "===== DIAGNOSIS: which canton drops in D1v? ====="
di "  Total N = " c(N)
di ""
di "  --- Missing in any D1v RHS var? ---"
foreach v in Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density {
    qui count if missing(`v')
    if r(N) > 0 {
        di "    MISSING in `v': " r(N) " canton(s)"
        qui list canton_iso `v' if missing(`v')
    }
}
di ""
di "  --- Canton-level inspection of vol-share vars (all 25 cantons) ---"
list canton_iso wine_volume_white wine_volume_red X3_white_vol_ratio X3_white_vol_share, abbrev(20) sep(0) clean

di _newline _newline "===== FL AME margins comparison (correct file paths) ====="

foreach pair in "fl_white_french_dummy_mg D1__VALUE_dummy X3_white_share" ///
                "fl_d1v_mg                D1v_VOLUME_dummy X3_white_vol_share" ///
                "fl_white_french_cont_mg  D2__VALUE_cont   X3_white_share" ///
                "fl_d2v_mg                D2v_VOLUME_cont  X3_white_vol_share" {
    local fn  : word 1 of `pair'
    local lab : word 2 of `pair'
    local x   : word 3 of `pair'

    cap estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`fn'.ster"
    if _rc {
        di _newline "  `lab': FILE NOT FOUND (`fn'.ster)"
        continue
    }

    di _newline "  `lab' (AME of `x' at cov1 ∈ {0, 25, 50, 75, 100}):"
    foreach i of numlist 1/5 {
        local b  = _b[`i'._at]
        local se = _se[`i'._at]
        local z  = `b'/`se'
        local p  = 2*(1 - normal(abs(`z')))
        if `i' == 1 local val "  0"
        if `i' == 2 local val " 25"
        if `i' == 3 local val " 50"
        if `i' == 4 local val " 75"
        if `i' == 5 local val "100"
        local star ""
        if `p' < 0.05 local star "  *"
        if `p' < 0.01 local star "  **"
        if `p' < 0.001 local star "  ***"
        if `p' >= 0.05 & `p' < 0.10 local star "  †"
        di "    cov1=`val': AME=" %8.5f `b' ", SE=" %7.5f `se' ", z=" %5.2f `z' ", p=" %5.3f `p' "`star'"
    }
}

** EOF
