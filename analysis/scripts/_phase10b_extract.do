/*==============================================================================
 _phase10b_extract.do  - Phase 10b comparison: D1/D2 (value) vs D1v/D2v (volume)
==============================================================================*/

use "$MyProject/processed/cohort_1908_workshop.dta", clear

di _newline "===== Phase 10b: VOLUME-share re-test ====="

di _newline "  --- Diagnostic: cov1 correlations ---"
qui corr X3_white_share cov1
di "  corr(X3_white_share, cov1)     = " %6.4f r(rho) "   (value-based; Phase 10 baseline)"
qui corr X3_white_vol_share cov1
di "  corr(X3_white_vol_share, cov1) = " %6.4f r(rho) "   (volume-based; Phase 10b)"

di _newline "  --- Diagnostic: white_share vs white_vol_share ---"
qui corr X3_white_share X3_white_vol_share
di "  corr(X3_white_share, X3_white_vol_share) = " %6.4f r(rho)

di _newline _newline "===== COMPARISON TABLE: D1 (value) vs D1v (volume), D2 vs D2v ====="

foreach pair in "ols_white_french_dummy X3_white_share X3_white_x_cov1 D1__value_dummy" ///
                "ols_d1v X3_white_vol_share X3_white_vol_x_cov1 D1v_volume_dummy" ///
                "ols_white_french_cont X3_white_share X3_white_x_cov1 D2__value_cont" ///
                "ols_d2v X3_white_vol_share X3_white_vol_x_cov1 D2v_volume_cont" {
    local fn  : word 1 of `pair'
    local main: word 2 of `pair'
    local int : word 3 of `pair'
    local lab : word 4 of `pair'
    estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`fn'.ster"

    local b_m  = _b[`main']
    local se_m = _se[`main']
    local p_m  = 2*ttail(e(df_r), abs(`b_m'/`se_m'))

    local b_c  = _b[cov1]
    local se_c = _se[cov1]
    local p_c  = 2*ttail(e(df_r), abs(`b_c'/`se_c'))

    local b_i  = _b[`int']
    local se_i = _se[`int']
    local p_i  = 2*ttail(e(df_r), abs(`b_i'/`se_i'))

    di _newline "  `lab' (N=" e(N) ", R²=" %5.3f e(r2) "):"
    di "    β(white main):      " %8.4f `b_m' "  SE " %6.4f `se_m' "  p " %5.3f `p_m'
    di "    β(cov1 main):       " %8.4f `b_c' "  SE " %6.4f `se_c' "  p " %5.3f `p_c'
    di "    β(white × cov1):    " %8.4f `b_i' "  SE " %6.4f `se_i' "  p " %5.3f `p_i'
}

di _newline _newline "===== FL AME margins at cov1 ∈ {0, 50, 100}  --  D1 vs D1v ====="

foreach pair in "fl_d1_mg    D1__VALUE_dummy   X3_white_share" ///
                "fl_d1v_mg   D1v_VOLUME_dummy  X3_white_vol_share" ///
                "fl_d2_mg    D2__VALUE_cont    X3_white_share" ///
                "fl_d2v_mg   D2v_VOLUME_cont   X3_white_vol_share" {
    local fn  : word 1 of `pair'
    local lab : word 2 of `pair'
    local x   : word 3 of `pair'
    estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`fn'.ster"

    di _newline "  `lab' (AME of `x' at cov1 = 0, 25, 50, 75, 100):"
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
        di "    cov1=`val': AME=" %8.5f `b' ", SE=" %7.5f `se' ", z=" %5.2f `z' ", p=" %5.3f `p' ///
            cond(`p' < 0.05, "  *", cond(`p' < 0.10, "  †", ""))
    }
}

** EOF
