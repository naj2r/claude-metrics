/*==============================================================================
 _phase9_exhaustive.do  -- Full disaggregation of wine-type results +
                          pairwise correlation matrix with covariates.
 Author: workshop-dispatch coder (2026-05-21 Phase 9 diagnostic)
==============================================================================*/

version 19

* Make sure we read fresh — full workshop cohort with all wine-type derivations
use "$MyProject/processed/cohort_1908_workshop.dta", clear


**# 1. Pairwise correlations: wine-type shares vs covariates
*------------------------------------------------------------------------------*
* Goal: identify whether multicollinearity between wine types and covariates
* (esp. French language share cov1) is absorbing the wine-type effects.
{
    di _newline "{hline 79}"
    di "  PAIRWISE CORRELATIONS  (N=25 cantons, all wine zeros enforced)"
    di "{hline 79}"

    local winevars   "X1 X1_share X2_share X3_share X3_white_share X3_red_share"
    local covarvars  "cov1 cov2_total_share cov3 cov_land ln_pop_1900 ln_density abs_producer"

    di _newline "  --- (a) Wine-types vs. covariates (the key diagnostic) ---"
    pwcorr `winevars' `covarvars', star(0.05) sig

    di _newline "  --- (b) Just the wine variants vs each other (mutual collinearity) ---"
    pwcorr `winevars', star(0.05) sig
}


**# 2. Full cascade for X3_white_share (col 1 through col 5)
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  X3_WHITE_SHARE CASCADE on Y1 (vote 68)  --  HC3 OLS, N=25"
    di "{hline 79}"
    di "  col   ctrl-set                                  beta(X3_w)   SE      p"
    di "  ----- ----------------------------------------- ----------  ------  ------"
    forvalues j = 1/5 {
        estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_`j'.ster"
        local b  = _b[X3_white_share]
        local se = _se[X3_white_share]
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        local r2 = e(r2)
        local ctrl_desc "${ctrl_s_c`j'}"
        di "  " %5.0f `j' "  " %-40s "`ctrl_desc'" "  " %8.4f `b' "  " %6.4f `se' "  " %5.3f `p'
    }
}


**# 3. Full cascade for X3_red_share (col 1 through col 5)
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  X3_RED_SHARE CASCADE on Y1 (vote 68)  --  HC3 OLS, N=25"
    di "{hline 79}"
    di "  col   ctrl-set                                  beta(X3_r)   SE      p"
    di "  ----- ----------------------------------------- ----------  ------  ------"
    forvalues j = 1/5 {
        estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_`j'.ster"
        local b  = _b[X3_red_share]
        local se = _se[X3_red_share]
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        local r2 = e(r2)
        local ctrl_desc "${ctrl_s_c`j'}"
        di "  " %5.0f `j' "  " %-40s "`ctrl_desc'" "  " %8.4f `b' "  " %6.4f `se' "  " %5.3f `p'
    }
}


**# 4. Full cascade for X3_share (aggregate) — reference comparison
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  X3_SHARE (AGGREGATE) CASCADE on Y1 (vote 68)  --  HC3 OLS, N=25  [reference]"
    di "{hline 79}"
    di "  col   beta(X3)     SE      p        R^2"
    di "  ----- ----------  ------  ------   ------"
    forvalues j = 1/5 {
        estimates use "$MyProject/results/intermediate/estimates_workshop/ols_3_`j'.ster"
        local b  = _b[X3_share]
        local se = _se[X3_share]
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        local r2 = e(r2)
        di "  " %5.0f `j' "  " %8.4f `b' "  " %6.4f `se' "  " %5.3f `p' "    " %5.3f `r2'
    }
}


**# 5. FL AME side-by-side (col 5 only since that's the headline spec)
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  FL AME COMPARISON at col 5  --  white vs aggregate vs red"
    di "{hline 79}"
    di "  Y1 (vote 68):"
    foreach pair in "WHITE fl_me_white_5 X3_white_share winetype" ///
                    "AGG   fl_me_3_5     X3_share       fraclogit" ///
                    "RED   fl_me_red_5   X3_red_share   winetype" {
        local lab : word 1 of `pair'
        local nm  : word 2 of `pair'
        local x   : word 3 of `pair'
        local dir : word 4 of `pair'
        if "`dir'" == "fraclogit" {
            estimates use "$MyProject/results/intermediate/estimates_fraclogit_workshop/`nm'.ster"
        }
        else {
            estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`nm'.ster"
        }
        local b  = _b[`x']*100
        local se = _se[`x']*100
        local p  = 2*(1 - normal(abs(`b'/`se')))
        di "    `lab': AMEx100=" %7.4f `b' ", SE=" %6.4f `se' ", p=" %5.3f `p'
    }
}


**# 6. Petition cascade for white + red (col 5 only — was the only col we ran)
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  PETITION OLS at col 5  --  white vs aggregate vs red"
    di "{hline 79}"
    foreach pair in "WHITE ols_pet_white_5 X3_white_share winetype" ///
                    "AGG   ols_pet_3_5     X3_share       petition" ///
                    "RED   ols_pet_red_5   X3_red_share   winetype" {
        local lab : word 1 of `pair'
        local nm  : word 2 of `pair'
        local x   : word 3 of `pair'
        local dir : word 4 of `pair'
        if "`dir'" == "petition" {
            estimates use "$MyProject/results/intermediate/estimates_petition_workshop/`nm'.ster"
        }
        else {
            estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/`nm'.ster"
        }
        local b  = _b[`x']
        local se = _se[`x']
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        di "    `lab': beta=" %7.4f `b' ", SE=" %6.4f `se' ", p=" %5.3f `p'
    }
}


**# 7. DIAGNOSTIC: full white+red horse race (both in same regression)
*------------------------------------------------------------------------------*
* If multicollinearity dilutes both, adding red AND white together (mutually
* partialling) might show one dominant.  Or both insig.  Either way, informative.
{
    di _newline "{hline 79}"
    di "  DIAGNOSTIC HORSE RACE: white + red in SAME regression (col 5 controls)"
    di "{hline 79}"

    cap estimates drop ols_wr_horserace
    qui regress Y1 X3_white_share X3_red_share cov1 cov2_total_share cov3 ln_density, vce(hc3)
    estimates store ols_wr_horserace

    di "  N = " e(N) ", R^2 = " %5.3f e(r2)
    foreach v in X3_white_share X3_red_share cov1 cov2_total_share cov3 ln_density _cons {
        local b  = _b[`v']
        local se = _se[`v']
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        di "    " %-22s "`v'" ": beta=" %8.4f `b' ", SE=" %6.4f `se' ", p=" %5.3f `p'
    }

    di _newline "  (Same diagnostic via FL AME)"
    cap drop Y1f
    gen double Y1f = Y1/100
    cap estimates drop fl_wr_horserace
    qui fracreg logit Y1f X3_white_share X3_red_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    cap estimates drop fl_me_wr_horserace
    qui margins, dydx(X3_white_share X3_red_share) post

    foreach v in X3_white_share X3_red_share {
        local b  = _b[`v']*100
        local se = _se[`v']*100
        local p  = 2*(1 - normal(abs(`b'/`se')))
        di "    " %-22s "`v' (FL AMEx100)" ": " %8.4f `b' ", SE=" %6.4f `se' ", p=" %5.3f `p'
    }
    drop Y1f
}


**# 8. DIAGNOSTIC: pure bivariate correlations (no controls) for visual
*------------------------------------------------------------------------------*
{
    di _newline "{hline 79}"
    di "  BIVARIATE (no controls) Y1 on each wine variant"
    di "{hline 79}"
    foreach x in X3_share X3_white_share X3_red_share X1 X2_share {
        qui regress Y1 `x', vce(hc3)
        local b  = _b[`x']
        local se = _se[`x']
        local p  = 2*ttail(e(df_r), abs(`b'/`se'))
        local r2 = e(r2)
        di "    Y1 on " %-18s "`x'" ": beta=" %8.4f `b' ", SE=" %6.4f `se' ", p=" %5.3f `p' ", R^2=" %5.3f `r2'
    }
}

** EOF
