*==============================================================================
* _pop1907_capture.do  — before/after snapshot for the 1907 population fix
* Loads cohort_1908_workshop.dta, runs the headline + per-cap col-5 specs and
* the invariant checks, prints scalars between RBSTART/RBEND markers.
* Run UNCHANGED before and after the fix; diff the marker blocks.
*==============================================================================
version 19
if "$MyProject" == "" global MyProject "C:/Users/jensenn/Research/repos/c-metrics-absinthe1/analysis"
use "$MyProject/processed/cohort_1908_workshop.dta", clear
cap drop Y1_frac
gen double Y1_frac = Y1 / 100

* --- Headline (X3_share, value share — should be ROBUST to the fix) ---
qui reg Y1 X3_share cov1 cov2_total_share cov3 ln_density, vce(hc3)
scalar b_ols_X3      = _b[X3_share]
scalar b_ols_lndens  = _b[ln_density]
qui fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
qui margins, dydx(X3_share) post
scalar ame_X3_pp     = _b[X3_share]*100

* --- Per-cap robustness (X1 = wine area per 1,000 pop — denominator moves) ---
qui reg Y1 X1 cov1 cov2_total_share cov3 ln_density, vce(hc3)
scalar b_ols_X1      = _b[X1]

* --- Invariants: shares + land area MUST be unchanged; density/per-cap MUST move ---
qui sum cov1,            meanonly
scalar s_cov1   = r(sum)
qui sum cov3,            meanonly
scalar s_cov3   = r(sum)
qui sum canton_area_km2, meanonly
scalar s_area   = r(sum)
qui sum ln_density,      meanonly
scalar s_lndens = r(sum)
qui sum X1,              meanonly
scalar s_X1     = r(sum)
qui sum pet_per_cap,     meanonly
scalar s_pet    = r(sum)

di "RBSTART"
di "b_ols_X3="      %12.6f b_ols_X3
di "ame_X3_pp="     %12.6f ame_X3_pp
di "b_ols_lndens="  %12.6f b_ols_lndens
di "b_ols_X1="      %12.6f b_ols_X1
di "sum_cov1="      %14.6f s_cov1
di "sum_cov3="      %14.6f s_cov3
di "sum_area_km2="  %16.6f s_area
di "sum_ln_density="%14.6f s_lndens
di "sum_X1="        %14.6f s_X1
di "sum_pet_per_cap="%14.6f s_pet
di "RBEND"
