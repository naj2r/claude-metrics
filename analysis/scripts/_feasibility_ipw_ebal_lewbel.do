/*==============================================================================
 _feasibility_ipw_ebal_lewbel.do
 Purpose:  DIAGNOSTIC-ONLY feasibility check for three robustness/identification
           methods on the absinthe-PRODUCER leg (and the wine leg for Lewbel):
             1. Common-support / overlap diagnostics (the crux)
             2. Entropy balancing (ebalance)         trial
             3. IPW (teffects ipw)                    trial
             4. Lewbel heteroskedasticity-IV (ivreg2h) precheck
           Classifies each method GO / NO-GO / DOCUMENT-AS-LIMIT. NO paper-facing
           results, NO edits to the main analysis / tables-of-record.

 Dispatch: quality_reports/coder_dispatch/2026-06-09_feasibility-ipw-ebal-lewbel.md
           (CORRECTED 2026-06-09: dataset = workshop cohort; treatment = abs_producer,
            NOT absinthe_dummy [which is NE-only in absinthe_analysis.dta]).
 Dataset:  $MyProject/processed/cohort_1908_workshop.dta  (N=25; tables-of-record)
 Treatment: abs_producer (= cov2_total_share>0; Milliet "any absinthe purchases").
            Per dispatch this = 8 cantons; the script ASSERTS + prints the realized
            treated set so the definition is on the record and never re-conflated.
 Covariates (dispatch col-5 controls, native workshop-cohort names):
            french_share, catholic_share, ln_pop_1900.
 Wine (Lewbel endogenous): X3_share (national wine revenue share).
 Outcome:   yes_pct = Y1 (0-100); yes_frac = Y1/100.

 Method note (parked metrics decision, non-blocking): abs_producer is an
 excise-PURCHASE indicator ("handles/sells absinthe per Milliet records"), not
 strictly "manufactures." Robustness ladder (NE / NE+VD / NE+VD+GE) lives in the
 absinthe_dummy* tiers of the original pipeline. Flagged for a later footnote.

 Output:   console/log diagnostics (RESULT-tagged scalars for the memo) +
           a best-effort propensity-overlap figure. Memo authored separately at
           quality_reports/coder_reports/2026-06-09_feasibility-ipw-ebal-lewbel.md.
 Author:   Feasibility dispatch (2026-06-09)
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set (run.do or your Stata profile)"
    error 9
}
cap which _codebook_update
if _rc run "$MyProject/scripts/programs/_config.do"
cap which ebalance
if _rc adopath ++ "$MyProject/scripts/libraries/stata"
foreach c in ebalance ivreg2h teffects {
    cap which `c'
    if _rc {
        di as error "  Required command missing: `c' (run /add-package or _install_stata_packages.do)."
        error 111
    }
}

set seed 20260609            // teffects/anything stochastic; documented
set graphics off             // batch/independent mode (Claude automation layer)


**# 0. Load + realized treated set (MANDATORY first — print the 8-canton def)
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/cohort_1908_workshop.dta", clear
    qui count
    assert r(N) == 25
    isid canton_iso

    * outcome + language-majority dummy (workshop cohort stores French as a share)
    cap drop yes_pct yes_frac lang_french
    gen double yes_pct  = Y1
    gen double yes_frac = Y1/100
    gen byte   lang_french = (french_share > 0.5) & !missing(french_share)
    label var lang_french "French-majority canton (french_share>0.5)"

    * Integrity: no missing in the diagnostic vars
    foreach v in yes_pct abs_producer french_share catholic_share ln_pop_1900 X3_share {
        qui count if missing(`v')
        assert r(N) == 0
    }

    di as text _n "{hline 78}"
    di as result "  REALIZED TREATED SET (abs_producer==1):"
    qui count if abs_producer==1
    local n_treat = r(N)
    di as result "  RESULT n_treated = `n_treat'  (dispatch expects 8)"
    list canton_iso french_share lang_french if abs_producer==1, noobs sep(0) abbrev(14)
    assert `n_treat' == 8
    di as text "{hline 78}"
}


**# 1. Common-support / overlap diagnostics  (the crux)
*------------------------------------------------------------------------------*
local X "french_share catholic_share ln_pop_1900"
{
    di as text _n "==== TASK 1: common support ===="

    * 1.1 producer x language-majority crosstab; the off-diagonal cell
    tab abs_producer lang_french, row col
    qui count if lang_french==1 & abs_producer==0
    di as result "  RESULT french_majority_nonproducer_n = " r(N) "   (expected 0)"
    qui count if lang_french==1 & abs_producer==1
    di as result "  RESULT french_majority_producer_n = " r(N)

    * 1.2 french_share moments by producer status
    tabstat french_share, by(abs_producer) stats(n mean sd min max p25 p75)
    qui sum french_share if abs_producer==1
    local t_mean = r(mean)
    local t_min  = r(min)
    qui sum french_share if abs_producer==0
    local c_mean = r(mean)
    local c_min  = r(min)
    local c_max  = r(max)
    di as result "  RESULT french_treated_mean = " %6.3f `t_mean'
    di as result "  RESULT french_control_mean = " %6.3f `c_mean'
    di as result "  RESULT french_control_max  = " %6.3f `c_max'
    di as result "  RESULT french_treated_min  = " %6.3f `t_min'

    * 1.3 propensity model + separation / tail mass
    cap drop ps
    cap noi logit abs_producer `X'
    local logit_rc = _rc
    di as result "  RESULT logit_rc = `logit_rc'"
    if `logit_rc'==0 {
        di as result "  RESULT logit_eN = " e(N) "  (of 25; <25 => obs dropped by separation)"
        cap predict double ps, pr
        qui sum ps if abs_producer==1
        di as result "  RESULT ps_treated_mean = " %6.4f r(mean) "  min=" %6.4f r(min)
        qui sum ps if abs_producer==0
        di as result "  RESULT ps_control_mean = " %6.4f r(mean) "  max=" %6.4f r(max)
        qui count if ps<.1 & !missing(ps)
        di as result "  RESULT ps_lt_0.1_n = " r(N)
        qui count if ps>.9 & !missing(ps)
        di as result "  RESULT ps_gt_0.9_n = " r(N)
        di as text "  Cantons in PS tails (<.1 or >.9):"
        list canton_iso abs_producer french_share ps if ps<.1 | ps>.9, noobs sep(0) abbrev(14)
    }

    * 1.4 entropy-balance feasibility precheck: treated mean inside control [min,max]?
    local ebal_feas = (`t_mean' >= `c_min' & `t_mean' <= `c_max')
    di as result "  RESULT ebal_french_feasible = `ebal_feas'   (treated mean " %5.3f `t_mean' " vs control [" %5.3f `c_min' ", " %5.3f `c_max' "])"
}


**# 2. Entropy balancing trial
*------------------------------------------------------------------------------*
{
    di as text _n "==== TASK 2: entropy balancing ===="

    * 2a full (with language). NB: ebalance signals non-convergence via a MESSAGE
    * + by NOT creating the weight var (rc stays 0), so detect via _webal existence.
    cap drop _webal
    cap noi ebalance abs_producer `X', generate(_webal)
    cap confirm variable _webal
    local ebal_full_conv = (_rc==0)
    di as result "  RESULT ebal_full_converged = `ebal_full_conv'  (0 = FAILED: no weights produced)"
    if `ebal_full_conv' {
        cap qui sum french_share if abs_producer==0 [aw=_webal]
        if _rc==0 di as result "  RESULT ebal_full_postwt_control_frenchmean = " %6.3f r(mean) "  (target = treated mean " %6.3f `t_mean' ")"
        cap qui sum _webal if abs_producer==0
        if _rc==0 di as result "  RESULT ebal_full_wt_min = " %8.4f r(min) "  max = " %8.4f r(max)
    }

    * 2b without language (religion + density only) — does NOT address language confound
    cap drop _webal
    cap noi ebalance abs_producer catholic_share ln_pop_1900, generate(_webal)
    cap confirm variable _webal
    local ebal_nl_conv = (_rc==0)
    di as result "  RESULT ebal_nolang_converged = `ebal_nl_conv'  (0 = FAILED)"
    if `ebal_nl_conv' {
        * NB: vce(hc3) is NOT allowed with pweights; HC1 (vce(robust)) is the
        * weighted-estimation analogue.
        cap noi reg yes_pct abs_producer [pw=_webal], vce(robust)
        if _rc==0 {
            di as result "  RESULT ebal_nolang_producer_b  = " %7.3f _b[abs_producer]
            di as result "  RESULT ebal_nolang_producer_se = " %7.3f _se[abs_producer]
        }
        cap qui sum _webal if abs_producer==0
        if _rc==0 di as result "  RESULT ebal_nolang_wt_min = " %8.4f r(min) "  max = " %8.4f r(max)
        di as error "  NOTE: this version drops french_share — does NOT address the language confound."
    }
}


**# 3. IPW trial
*------------------------------------------------------------------------------*
{
    di as text _n "==== TASK 3: IPW (teffects ipw) ===="
    cap noi teffects ipw (yes_pct) (abs_producer `X'), atet
    local ipw_atet_rc = _rc
    di as result "  RESULT ipw_atet_rc = `ipw_atet_rc'  (nonzero => overlap/estimation failure)"
    if `ipw_atet_rc'==0 {
        cap noi lincom r1vs0.abs_producer
        di as result "  RESULT ipw_atet_b = " %7.3f r(estimate) "  se = " %7.3f r(se)
        cap noi tebalance summarize
    }
    cap noi teffects ipw (yes_pct) (abs_producer `X'), ate
    local ipw_ate_rc = _rc
    di as result "  RESULT ipw_ate_rc = `ipw_ate_rc'"
    if `ipw_ate_rc'==0 {
        cap noi lincom r1vs0.abs_producer
        di as result "  RESULT ipw_ate_b = " %7.3f r(estimate) "  se = " %7.3f r(se)
    }
    * overlap figure: prefer teffects overlap; fallback to manual PS dotplot from §1.3
    cap noi teffects overlap, name(ovl, replace)
    if _rc==0 {
        cap graph export "$MyProject/results/figures/feasibility_ps_overlap.png", replace width(1400)
        di as result "  RESULT overlap_fig = teffects (results/figures/feasibility_ps_overlap.png)"
    }
    else {
        cap noi dotplot ps, over(abs_producer) ///
            ytitle("Propensity score (logit)") title("")
        cap graph export "$MyProject/results/figures/feasibility_ps_overlap.png", replace width(1400)
        di as result "  RESULT overlap_fig = manual PS dotplot (teffects overlap unavailable)"
    }
}


**# 4. Lewbel heteroskedasticity-IV precheck (continuous wine, X3_share)
*------------------------------------------------------------------------------*
{
    di as text _n "==== TASK 4: Lewbel IV (ivreg2h) ===="

    * 4a first-stage heteroskedasticity (Lewbel REQUIRES it)
    qui reg X3_share `X'
    estat hettest
    local bp_p = r(p)
    di as result "  RESULT lewbel_firststage_BP_p = " %6.4f `bp_p' "   (need het => small p)"
    cap noi estat imtest, white
    * (White test echoed in log; BP p above is the machine-readable flag)

    * 4b OLS reference (dispatch col-5 reduced set) + the published col-5 (~0.469)
    qui reg yes_pct X3_share `X', vce(hc3)
    di as result "  RESULT ols_x3_b_reducedset = " %6.4f _b[X3_share] "  (cf. published col-5 ~0.469)"

    * 4c Lewbel IV: generated heteroskedasticity-based instruments
    cap noi ivreg2h yes_pct (X3_share = ) `X', robust
    local lewbel_rc = _rc
    di as result "  RESULT lewbel_rc = `lewbel_rc'"
    if `lewbel_rc'==0 {
        di as result "  RESULT lewbel_x3_b  = " %7.4f _b[X3_share]
        di as result "  RESULT lewbel_x3_se = " %7.4f _se[X3_share]
        local lo = _b[X3_share] - 1.96*_se[X3_share]
        local hi = _b[X3_share] + 1.96*_se[X3_share]
        di as result "  RESULT lewbel_x3_ci95 = [" %7.4f `lo' ", " %7.4f `hi' "]"
        cap di as result "  RESULT lewbel_KP_F = " %8.3f e(widstat) "   (weak-IV; rule-of-thumb >10)"
        cap di as result "  RESULT lewbel_HansenJ = " %7.3f e(j) "  p = " %6.4f e(jp)
        cap di as result "  RESULT lewbel_n_instruments = " e(ninsts)
    }
}

di as text _n "{hline 78}"
di as result "  FEASIBILITY DIAGNOSTIC COMPLETE — grep 'RESULT ' for the memo numbers."
di as text "{hline 78}"

** EOF
