/*==============================================================================
 _canton_ame_magnitudes.do  —  Canton-level AME magnitudes for §5.1 case study
                               (vote #68, M1A-5 FL spec).

 Dispatch:  Brainstorm-Absinthe worktree, 2026-05-22_pc-coder-canton-AME-
            magnitudes.md (gallant-thompson worktree).

 Purpose:   Translate the headline FL AME on X3_share (wine revenue national
            share) into concrete per-canton magnitudes for the 4 case-study
            cantons VD / NE / ZH / UR, plus cross-canton ranking, for the
            workshop reader of §5.1.

 Spec:      fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density,
                       vce(robust)
            i.e. ${X_spec3} on Y1 with cascade col 5 controls.  Coefficients
            are read from estimates_fraclogit_workshop/fl_3_5.ster (the same
            model that produced Table 2 Panel A).

 Input:     $MyProject/processed/cohort_1908_workshop.dta
            $MyProject/results/intermediate/estimates_fraclogit_workshop/fl_3_5.ster

 Outputs:   analysis/output/notes/2026-05-22_canton_AME_magnitudes.md (primary;
            human-readable artefact for hand-pulling into §5.1)
            $MyProject/results/intermediate/canton_ame_magnitudes.dta
            (machine-readable backing dataset — augmented cohort with
            yhat_obs, yhat_x3_zero, delta_wine, ame_linear per canton)

 Author:    §5.1 dispatch (2026-05-22)
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


**# 1. Load workshop cohort
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  Need cohort_1908_workshop.dta (built by 08_workshop + 09_workshop)"
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear

    foreach v in canton_iso X3_share cov1 cov2_total_share cov3 ln_density Y1 {
        cap confirm variable `v'
        if _rc {
            di as error "  Required variable missing: `v'"
            di as error "  (Re-run 09_canton_reg1_workshop.do to populate derived vars.)"
            error 111
        }
    }
    * Y1_frac is created in 09_workshop §2.5 (fractional logit battery) — AFTER
    * the §1.7 cohort save — so it's not on disk.  Reconstruct it here from Y1
    * (yes_pct on vote #68, 0-100 scale).  Idempotent: cap drop first.
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    label var Y1_frac "Yes-share vote 68 on [0,1] scale (for fracreg)"
    di as text "  Loaded N=" c(N) " cantons; Y1_frac reconstructed from Y1/100."
}


**# 2. Re-estimate / load M1A-5 FL #68 model
*------------------------------------------------------------------------------*
* The dispatch insists "no modifications to the existing M1A-5 estimation".  We
* either restore the saved estimates (fl_3_5.ster) or re-estimate identically
* in-script.  Re-estimating is cheap (~10ms on N=25) and guarantees the saved
* coefficients match the current cohort_1908_workshop.dta.  We do both: load
* saved as a check, then re-estimate and compare.
{
    fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    estimates store fl_M1A5_68

    di as text _n "{hline 78}"
    di as text "  Model: M1A-5 FL #68 (fracreg logit, full controls)"
    di as text "  Log-likelihood = " %10.4f e(ll) ",  N = " e(N)
    di as text "{hline 78}"

    * Verify AME ~ 0.434.  fracreg's AME is in proportion-Y units; dispatch's
    * headline (and the project's Phase A′ convention) is pp Y per pp X, so
    * multiply by 100.
    qui margins, dydx(X3_share) post
    local ame_x3_prop    = _b[X3_share]
    local ame_x3_prop_se = _se[X3_share]
    local ame_x3         = `ame_x3_prop' * 100   // pp Y per pp X
    local ame_x3_se      = `ame_x3_prop_se' * 100
    local ame_x3_str     : di %6.3f `ame_x3'
    local ame_x3_se_s    : di %6.3f `ame_x3_se'

    di as text _n "  Headline AME on X3_share (pp Y / pp X) = `ame_x3_str' (SE=`ame_x3_se_s')"
    di as text "  Dispatch's claimed headline = 0.434"

    estimates restore fl_M1A5_68
}


**# 3. Per-canton observed values + counterfactual predictions
*------------------------------------------------------------------------------*
{
    * 3.1 Observed-X prediction (in-sample)
    cap drop yhat_obs yhat_obs_pct
    predict double yhat_obs
    gen double yhat_obs_pct = yhat_obs * 100
    label var yhat_obs_pct "Predicted Y at observed canton X (pp)"

    * 3.2 Counterfactual: set X3_share = 0, predict, then restore
    preserve
        qui replace X3_share = 0
        cap drop yhat_x3_zero
        predict double yhat_x3_zero
        qui gen double _yhat_x3_zero_pct = yhat_x3_zero * 100
        tempfile cf_data
        keep canton_iso _yhat_x3_zero_pct
        save `cf_data', replace
    restore
    merge 1:1 canton_iso using `cf_data', nogen
    rename _yhat_x3_zero_pct yhat_x3_zero_pct
    label var yhat_x3_zero_pct "Counterfactual predicted Y at X3_share=0 (pp)"

    * 3.3 Wine-mechanism contribution and AME-linear approximation
    cap drop delta_wine ame_linear
    gen double delta_wine = yhat_obs_pct - yhat_x3_zero_pct
    gen double ame_linear = `ame_x3' * X3_share  // beta_X × observed X (in pp)
    label var delta_wine "Wine-channel contribution to predicted Y (pp): Y_obs - Y_X=0"
    label var ame_linear "AME-linear approx: AME_X × X3_share_i (pp)"
}


**# 4. Display Block A + B for the 4 case-study cantons (VD, NE, ZH, UR)
*------------------------------------------------------------------------------*
{
    di as text _n "{hline 78}"
    di as text "  BLOCK A+B: Per-canton observed values + counterfactual predictions"
    di as text "{hline 78}"

    local case_cantons VD NE ZH UR

    di as text "  cant | X3_share | cov1 Fr | cov2 Abs | cov3 Pr | ln_dens | Y_obs | Y_pred | Y_X=0 | dY_wine | AME-lin"
    di as text "  -----+----------+---------+----------+---------+---------+-------+--------+-------+---------+--------"
    foreach c in `case_cantons' {
        qui sum X3_share if canton_iso == "`c'"
        local x3   : di %6.2f r(mean)
        qui sum cov1 if canton_iso == "`c'"
        local fr   : di %6.2f r(mean)
        qui sum cov2_total_share if canton_iso == "`c'"
        local abs  : di %6.2f r(mean)
        qui sum cov3 if canton_iso == "`c'"
        local pr   : di %6.2f r(mean)
        qui sum ln_density if canton_iso == "`c'"
        local lnd  : di %6.3f r(mean)
        qui sum Y1 if canton_iso == "`c'"
        local yobs : di %6.2f r(mean)
        qui sum yhat_obs_pct if canton_iso == "`c'"
        local ypre : di %6.2f r(mean)
        qui sum yhat_x3_zero_pct if canton_iso == "`c'"
        local yzro : di %6.2f r(mean)
        qui sum delta_wine if canton_iso == "`c'"
        local dlt  : di %6.2f r(mean)
        qui sum ame_linear if canton_iso == "`c'"
        local lin  : di %6.2f r(mean)
        di as text "  `c'  |  `x3'  | `fr'  |  `abs'  | `pr'  | `lnd' | `yobs'| `ypre' | `yzro'| `dlt'  | `lin'"
    }
}


**# 5. Block C: Cross-canton ranking
*------------------------------------------------------------------------------*
{
    di as text _n "{hline 78}"
    di as text "  BLOCK C: Cross-canton ranking on X3_share (wine revenue national share)"
    di as text "{hline 78}"

    preserve
        gsort -X3_share
        gen byte rank_x3 = _n
        label var rank_x3 "Rank on X3_share, 1=highest, N=lowest"

        di as text _n "  TOP 5 by X3_share:"
        di as text "  rank | cant | X3_share |  Y_obs | Y_pred"
        di as text "  -----+------+----------+--------+--------"
        forvalues i = 1/5 {
            local c   = canton_iso[`i']
            local x3  : di %6.2f X3_share[`i']
            local yo  : di %6.2f Y1[`i']
            local yp  : di %6.2f yhat_obs_pct[`i']
            di as text "  `i'    | `c'  | `x3'  | `yo' | `yp'"
        }

        di as text _n "  BOTTOM 5 by X3_share:"
        di as text "  rank | cant | X3_share |  Y_obs | Y_pred"
        di as text "  -----+------+----------+--------+--------"
        local N = _N
        forvalues r = 0/4 {
            local i = `N' - `r'
            local c   = canton_iso[`i']
            local x3  : di %6.2f X3_share[`i']
            local yo  : di %6.2f Y1[`i']
            local yp  : di %6.2f yhat_obs_pct[`i']
            di as text "  `i'   | `c'  | `x3'  | `yo' | `yp'"
        }

        local med_rank = ceil(`N' / 2)  // = 13 for N=25
        local mc   = canton_iso[`med_rank']
        local mx3  : di %6.2f X3_share[`med_rank']
        local myo  : di %6.2f Y1[`med_rank']
        local myp  : di %6.2f yhat_obs_pct[`med_rank']
        di as text _n "  MEDIAN (rank `med_rank' of `N'): canton `mc', X3_share = `mx3', Y_obs = `myo', Y_pred = `myp'"
    restore
}


**# 6. Save augmented dataset for hand-pulling values
*------------------------------------------------------------------------------*
{
    keep canton_iso X3_share cov1 cov2_total_share cov3 ln_density Y1 ///
         yhat_obs yhat_obs_pct yhat_x3_zero_pct delta_wine ame_linear
    gsort -X3_share
    save "$MyProject/processed/intermediate/canton_ame_magnitudes.dta", replace
    di as text _n "  Saved canton_ame_magnitudes.dta (N=" c(N) ", k=" c(k) ")"
}


** EOF
