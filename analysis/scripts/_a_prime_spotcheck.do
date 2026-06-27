/*==============================================================================
 _a_prime_spotcheck.do — Phase A' verification:
   (1) rebuilt FL AME = raw .ster × 100 (exact linear scaling)
   (2) OLS β vs FL AME convergence sanity (should be within ~20% given near-
       center yes-vote range; large divergence would flag scale or nonlinearity)
==============================================================================*/

di _newline "{hline 79}"
di "  PHASE A' SPOT-CHECK 1: rebuilt FL AME = raw .ster × 100"
di "{hline 79}"
di ""

* Sample 1: T2 FL Panel A (X3 cascade col 5) — fl_me_3_5
estimates use "$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_5.ster"
local b_raw  = _b[X3_share]
local se_raw = _se[X3_share]
di "  fl_me_3_5 (T2 FL Panel A col 5):"
di "    raw      AME=" %10.8f `b_raw' ", SE=" %10.8f `se_raw'
di "    × 100    AME=" %10.6f `b_raw'*100 ", SE=" %10.6f `se_raw'*100

* Sample 2: T8 FL crossref #68 — crossref_fl_me_68
estimates use "$MyProject/results/intermediate/estimates_crossref/crossref_fl_me_68.ster"
local b_raw  = _b[X3_share]
local se_raw = _se[X3_share]
di _newline "  crossref_fl_me_68 (T8 FL #68 absinthe-ban):"
di "    raw      AME=" %10.8f `b_raw' ", SE=" %10.8f `se_raw'
di "    × 100    AME=" %10.6f `b_raw'*100 ", SE=" %10.6f `se_raw'*100

* Sample 3: T8 FL crossref #67 (placebo)
estimates use "$MyProject/results/intermediate/estimates_crossref/crossref_fl_me_67.ster"
local b_raw  = _b[X3_share]
local se_raw = _se[X3_share]
di _newline "  crossref_fl_me_67 (T8 FL #67 commerce-placebo):"
di "    raw      AME=" %10.8f `b_raw' ", SE=" %10.8f `se_raw'
di "    × 100    AME=" %10.6f `b_raw'*100 ", SE=" %10.6f `se_raw'*100

* Sample 4: T10v margins D1v at cov1=50 — fl_d1v_mg
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d1v_mg.ster"
local b_raw  = _b[3._at]
local se_raw = _se[3._at]
di _newline "  fl_d1v_mg at cov1=50 (T10v margins D1v):"
di "    raw      AME=" %10.8f `b_raw' ", SE=" %10.8f `se_raw'
di "    × 100    AME=" %10.6f `b_raw'*100 ", SE=" %10.6f `se_raw'*100


di _newline _newline "{hline 79}"
di "  PHASE A' SPOT-CHECK 2: OLS β vs FL AME convergence (estimator-comparability)"
di "  Expectation: within ~20% if yes-vote range is near logistic-center."
di "{hline 79}"
di ""

* Pair 1: AGGREGATE wine cascade at col 5 (T9 Panel A vs T2 FL Panel A col 5)
estimates use "$MyProject/results/intermediate/estimates_workshop/ols_3_5.ster"
local b_ols = _b[X3_share]
estimates use "$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_5.ster"
local b_fl_pp = _b[X3_share] * 100
local ratio = `b_fl_pp' / `b_ols'
di "  AGGREGATE X3_share at col 5:"
di "    OLS β     = " %7.4f `b_ols' " pp/pp"
di "    FL AME×100= " %7.4f `b_fl_pp' " pp/pp"
di "    ratio FL/OLS = " %5.3f `ratio' cond(abs(`ratio' - 1) < 0.2, "  (CONVERGES within 20%)", "  (DIVERGENCE > 20%)")

* Pair 2: WHITE wine cascade at col 5 (T9 Panel B vs T2-equivalent if existed)
* Note: T2 doesn't have a white-wine FL panel; use Phase 9 §2.9 fl_white_5 AME
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5.ster"
local b_ols = _b[X3_white_share]
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_white_5.ster"
local b_fl_pp = _b[X3_white_share] * 100
local ratio = `b_fl_pp' / `b_ols'
di _newline "  WHITE wine X3_white_share at col 5:"
di "    OLS β     = " %7.4f `b_ols' " pp/pp"
di "    FL AME×100= " %7.4f `b_fl_pp' " pp/pp"
di "    ratio FL/OLS = " %5.3f `ratio' cond(abs(`ratio' - 1) < 0.2, "  (CONVERGES within 20%)", "  (DIVERGENCE > 20%)")

* Pair 3: D1v at cov1=50 — OLS D1v vs FL D1v margins at cov1=50
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_d1v.ster"
* D1v OLS doesn't give a direct "AME at cov1=50" — need to compute β(white_vol) + 50×β(W_vol×F)
local b_main = _b[X3_white_vol_share]
local b_int  = _b[X3_white_vol_x_cov1]
local b_ols_at50 = `b_main' + 50 * `b_int'
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d1v_mg.ster"
local b_fl_pp = _b[3._at] * 100
local ratio = `b_fl_pp' / `b_ols_at50'
di _newline "  D1v white-vol marginal effect at cov1=50 (OLS implied):"
di "    OLS β(main) + 50·β(int) = " %7.4f `b_main' " + 50·" %7.4f `b_int' " = " %7.4f `b_ols_at50' " pp/pp"
di "    FL AME×100 at cov1=50    = " %7.4f `b_fl_pp' " pp/pp"
di "    ratio FL/OLS = " %5.3f `ratio' cond(abs(`ratio' - 1) < 0.2, "  (CONVERGES within 20%)", "  (DIVERGENCE > 20%)")

* Pair 4: Cross-referendum #68 — OLS β vs FL AME×100 (same spec, both at col 5)
estimates use "$MyProject/results/intermediate/estimates_crossref/crossref_ols_68.ster"
local b_ols = _b[X3_share]
estimates use "$MyProject/results/intermediate/estimates_crossref/crossref_fl_me_68.ster"
local b_fl_pp = _b[X3_share] * 100
local ratio = `b_fl_pp' / `b_ols'
di _newline "  Crossref #68 X3_share (T8 OLS vs T8 FL):"
di "    OLS β     = " %7.4f `b_ols' " pp/pp"
di "    FL AME×100= " %7.4f `b_fl_pp' " pp/pp"
di "    ratio FL/OLS = " %5.3f `ratio' cond(abs(`ratio' - 1) < 0.2, "  (CONVERGES within 20%)", "  (DIVERGENCE > 20%)")

di _newline "{hline 79}"
di "  END SPOT-CHECK"
di "{hline 79}"

** EOF
