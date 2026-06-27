/*==============================================================================
 _phase10_extract.do  - Pull beta/SE/p for all Phase 10 specs.
==============================================================================*/

di _newline "===== Phase 10: WHITE × FRENCH (D1, D2) ====="
di "  (interaction term β(X3_white_x_cov1) tests Cahannes cultural conditioning)"
di ""

foreach pair in "ols_white_french_dummy D1-OLS" ///
                "ols_white_french_cont  D2-OLS" {
    local fn  : word 1 of `pair'
    local lab : word 2 of `pair'
    estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`fn'.ster"
    di "  `lab' (N=" e(N) ", R²=" %5.3f e(r2) "):"
    foreach v in X3_white_share cov1 X3_white_x_cov1 {
        local b  = _b[`v']
        local se = _se[`v']
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        di "    " %-18s "`v'" ": β=" %8.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'
    }
}

di _newline _newline "===== Phase 10: WHITE × ABSINTHE (E1, E2) ====="
di ""

foreach pair in "ols_white_absprod E1-OLS" ///
                "ols_white_cov2    E2-OLS" {
    local fn  : word 1 of `pair'
    local lab : word 2 of `pair'
    estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`fn'.ster"
    di "  `lab' (N=" e(N) ", R²=" %5.3f e(r2) "):"
    if "`fn'" == "ols_white_absprod" {
        foreach v in X3_white_share abs_producer X3_white_x_absprod {
            local b  = _b[`v']
            local se = _se[`v']
            local p  = 2*ttail(e(df_r), abs(`b'/`se'))
            di "    " %-22s "`v'" ": β=" %8.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'
        }
    }
    else {
        foreach v in X3_white_share cov2_total_share X3_white_x_cov2 {
            local b  = _b[`v']
            local se = _se[`v']
            local p  = 2*ttail(e(df_r), abs(`b'/`se'))
            di "    " %-22s "`v'" ": β=" %8.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'
        }
    }
}

di _newline _newline "===== Phase 10 Spec F: DROP-TI CASCADES (N=24) ====="

foreach setpair in "agg X3_share AGG" ///
                   "white X3_white_share WHITE" ///
                   "red X3_red_share RED" {
    local nm  : word 1 of `setpair'
    local x   : word 2 of `setpair'
    local lab : word 3 of `setpair'

    di _newline "  `lab' cascade (drop-TI, X = `x'):"
    forvalues j = 1/5 {
        estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_`nm'_`j'_noti.ster"
        local b  = _b[`x']
        local se = _se[`x']
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        di "    col `j': β=" %8.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'
    }
}

di _newline _newline "===== COMPARISON: full N=25 vs drop-TI N=24 at col 5 ====="

di _newline "  AGGREGATE (X3_share):"
estimates use "$MyProject/results/intermediate/estimates_workshop/ols_3_5.ster"
local b_full = _b[X3_share]
local p_full = 2*ttail(e(df_r), abs(_b[X3_share]/_se[X3_share]))
di "    N=25 col 5: β=" %8.4f `b_full' ", p=" %5.3f `p_full'
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_5_noti.ster"
local b_noti = _b[X3_share]
local p_noti = 2*ttail(e(df_r), abs(_b[X3_share]/_se[X3_share]))
di "    N=24 noTI:  β=" %8.4f `b_noti' ", p=" %5.3f `p_noti'
di "    Δ = " %8.4f `b_noti' - `b_full'

di _newline "  WHITE (X3_white_share):"
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5.ster"
local b_full = _b[X3_white_share]
local p_full = 2*ttail(e(df_r), abs(_b[X3_white_share]/_se[X3_white_share]))
di "    N=25 col 5: β=" %8.4f `b_full' ", p=" %5.3f `p_full'
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5_noti.ster"
local b_noti = _b[X3_white_share]
local p_noti = 2*ttail(e(df_r), abs(_b[X3_white_share]/_se[X3_white_share]))
di "    N=24 noTI:  β=" %8.4f `b_noti' ", p=" %5.3f `p_noti'
di "    Δ = " %8.4f `b_noti' - `b_full'

di _newline "  RED (X3_red_share):"
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_5.ster"
local b_full = _b[X3_red_share]
local p_full = 2*ttail(e(df_r), abs(_b[X3_red_share]/_se[X3_red_share]))
di "    N=25 col 5: β=" %8.4f `b_full' ", p=" %5.3f `p_full'
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_5_noti.ster"
local b_noti = _b[X3_red_share]
local p_noti = 2*ttail(e(df_r), abs(_b[X3_red_share]/_se[X3_red_share]))
di "    N=24 noTI:  β=" %8.4f `b_noti' ", p=" %5.3f `p_noti'
di "    Δ = " %8.4f `b_noti' - `b_full'

** EOF
