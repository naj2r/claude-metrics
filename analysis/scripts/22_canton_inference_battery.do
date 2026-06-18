/*==============================================================================
 22_canton_inference_battery.do
 Purpose:  Small-N inference battery + leave-one-out for the canton cross-section
           (N=25), 1908 absinthe-ban referendum. The "gate" robustness check:
           does the wine leg survive drop-Vaud? Pairs LOO with the small-N
           inference the result will be judged on.

           Methods (per dispatch 2026-06-03 + PI decisions D1-D7):
             §1  Leave-one-out (wine cascade 1-5; producer leg) — flag VD, NE
             §2  Randomization inference, 10,000 perms (ritest), OLS beta + FL AME
             §3  HC1/HC2/HC3 SEs + Bell-McCaffrey / Imbens-Koleśár (2016)
                 effective dof (hand-implemented in Mata, validated vs native HC2)
             §4  Oster (2019) delta-bounds (psacalc)
             §5  White-vs-red wine split (Cahannes mechanism)
             §6  Conley (1999) spatial-HAC — DEFERRED (no coords yet); stub

 Pipeline: WORKSHOP (audit-confirmed paper-identical: frozen fl_me_3_5 AME=0.4338
           = deployed 0.434; newest cohort). Reads cohort_1908_workshop.dta
           directly (NOT sourcing 09_workshop, which overwrites the cohort).

 Input:    $MyProject/processed/cohort_1908_workshop.dta
 Output:   $MyProject/results/intermediate/inference_loo.dta
           $MyProject/results/intermediate/inference_ri.dta        (if RUN_RI)
           $MyProject/results/intermediate/inference_se_bm.dta
           $MyProject/results/intermediate/inference_oster.dta
           $MyProject/results/intermediate/inference_winetype.dta
           (tables built by 23_canton_inference_battery_tables.do)

 Decisions log: quality_reports/coder_reports/2026-06-03_inference-battery-decision-log.md
 Plan:          analysis/documentation/plans/2026-06-03_inference-battery-loo.md

 Replicability:
   - set seed ONCE below (RI). Seed = 20260603, documented here + in memo.
   - RUN_RI toggle: "1" (default) runs the 10k RI; set "0" for a fast non-RI
     verification pass. RI is gated only for dev speed; the canonical run is RUN_RI=1.
   - Y1_frac reconstructed = Y1/100 with an ASSERT re-pinning the headline FL AME
     to 0.4338 (paper anchor) — the script refuses to run if the data/derivation
     drifts from the deployed paper number.

 Author:   Inference-battery dispatch (2026-06-03)
 Version:  1.0
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
* Vendored libraries (ritest, psacalc, regsave, texsave, ...)
cap which ritest
if _rc adopath ++ "$MyProject/scripts/libraries/stata"
cap which psacalc
if _rc {
    di as error "  psacalc not found — run /add-package psacalc (see decision log D5)."
    error 111
}

* --- Reproducibility knobs ---
set seed 20260603                         // RI permutation seed (documented)
if "${RUN_RI}" == "" global RUN_RI "1"    // 1 = full 10k RI; 0 = fast non-RI pass
local RI_REPS 10000                       // methodology-integrity: 10k, never reduced
if "${RI_REPS_TEST}" != "" local RI_REPS ${RI_REPS_TEST}  // dev smoke-test ONLY; canonical run = 10000

cap mkdir "$MyProject/results/intermediate"


**# 0. Load + paper-anchor assert
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  Source missing: processed/cohort_1908_workshop.dta (build via 08/09 workshop)."
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear

    * FL outcome on [0,1] — the ONLY analysis var not persisted in the cohort.
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    label var Y1_frac "Yes-vote share #68, fractional [0,1] (= Y1/100)"

    * Integrity: N=25, no missing in the headline analysis vars.
    qui count
    assert r(N) == 25
    isid canton_iso
    foreach v in Y1 Y1_frac X3_share X2_share abs_producer cov1 cov2_total_share cov3 ln_density {
        qui count if missing(`v')
        assert r(N) == 0
    }

    * PAPER ANCHOR: re-estimate the headline FL AME from this cohort; it MUST
    * reproduce the deployed 0.434 (frozen fl_me_3_5 = 0.4338). If the cohort or
    * derivation ever drifts from the paper, the script halts here.
    qui fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    qui margins, dydx(X3_share) post
    local anchor_ame = _b[X3_share] * 100
    di as text "  Paper-anchor FL AME x100 = " %7.4f `anchor_ame' "   [deployed 0.434 / frozen 0.4338]"
    assert reldif(`anchor_ame', 0.4338) < 0.01
    di as result "  ANCHOR OK — cohort reproduces the paper headline."
}


**# 1. Leave-one-out (the gate)
*------------------------------------------------------------------------------*
* Wine leg across the full cascade (cols 1-5): drop each canton, record beta_wine
* + SE for OLS (Y1, HC3) and the FL AME (Y1_frac). Producer leg (D8): a 4-step
* cascade on the absinthe-producer dummy abs_producer — p1 raw bivariate ->
* p2 +Protestant+density -> p3 +wine+Prot+density -> p4 +French (full). The OLS
* coefficient on the 0/1 dummy IS the cross-bloc producer differential; p1
* reproduces the -11.2pp anchor and p4 the +French collapse (a power /
* linked-covariance limitation, NOT an indemnification — decision log D8).
* drop-VD and drop-NE are flagged downstream by canton_iso.
*------------------------------------------------------------------------------*
{
    * Cascade control sets (col1 = none)
    local ctrl1 ""
    local ctrl2 "cov1"
    local ctrl3 "cov1 cov2_total_share"
    local ctrl4 "cov1 cov2_total_share cov3"
    local ctrl5 "cov1 cov2_total_share cov3 ln_density"

    preserve
        * Build a results frame: one row per (leg, spec, dropped_canton)
        tempfile loo
        postfile loohandle str12 leg str8 spec str8 dropped double(b_ols se_ols b_fl_ame se_fl_ame) ///
            using "`loo'", replace

        levelsof canton_iso, local(cantons)

        * --- Wine leg: X3_share, cascade cols 1-5 ---
        forvalues j = 1/5 {
            local cset "`ctrl`j''"
            * full sample (dropped = "NONE") then each leave-one-out
            foreach drop in NONE `cantons' {
                qui {
                    if "`drop'" == "NONE"  reg Y1 X3_share `cset', vce(hc3)
                    else                   reg Y1 X3_share `cset' if canton_iso != "`drop'", vce(hc3)
                    local bo = _b[X3_share]
                    local so = _se[X3_share]

                    if "`drop'" == "NONE"  fracreg logit Y1_frac X3_share `cset', vce(robust)
                    else                   fracreg logit Y1_frac X3_share `cset' if canton_iso != "`drop'", vce(robust)
                    margins, dydx(X3_share) post
                    local bf = _b[X3_share] * 100
                    local sf = _se[X3_share] * 100
                }
                post loohandle ("wine_X3") ("c`j'") ("`drop'") (`bo') (`so') (`bf') (`sf')
            }
        }

        * --- Producer leg: abs_producer cascade (mirrors the D8 cascade) ---
        * Focal = abs_producer. For this 0/1 dummy the OLS coefficient IS the
        * exact producer-vs-non-producer differential; the FL AME keeps the wine
        * leg's continuous-dydx convention (reported for shape-consistency, not
        * as the producer headline). p1 raw -> p4 +French (full).
        local pctrl1 ""                                  // p1 raw bivariate
        local pctrl2 "cov3 ln_density"                   // p2 +Protestant+density
        local pctrl3 "X3_share cov3 ln_density"          // p3 +wine+Prot+density
        local pctrl4 "X3_share cov1 cov3 ln_density"     // p4 +French (full)
        forvalues j = 1/4 {
            local pset "`pctrl`j''"
            foreach drop in NONE `cantons' {
            qui {
                if "`drop'" == "NONE"  reg Y1 abs_producer `pset', vce(hc3)
                else                   reg Y1 abs_producer `pset' if canton_iso != "`drop'", vce(hc3)
                local bo = _b[abs_producer]
                local so = _se[abs_producer]

                if "`drop'" == "NONE"  fracreg logit Y1_frac abs_producer `pset', vce(robust)
                else                   fracreg logit Y1_frac abs_producer `pset' if canton_iso != "`drop'", vce(robust)
                margins, dydx(abs_producer) post
                local bf = _b[abs_producer] * 100
                local sf = _se[abs_producer] * 100
            }
            post loohandle ("producer") ("p`j'") ("`drop'") (`bo') (`so') (`bf') (`sf')
            }
        }

        postclose loohandle
        use "`loo'", clear
        gen byte is_VD = (dropped == "VD")
        gen byte is_NE = (dropped == "NE")
        compress
        save "$MyProject/results/intermediate/inference_loo.dta", replace
        di as result "  §1 LOO saved: inference_loo.dta (" _N " rows)"

        * Console flag of the gate: drop-VD vs full sample, wine col 5
        di as text _n "  --- GATE: wine X3 col-5 AME (pp), full vs drop-VD vs drop-NE ---"
        list spec dropped b_fl_ame se_fl_ame if leg=="wine_X3" & spec=="c5" & inlist(dropped,"NONE","VD","NE"), ///
            noobs sep(0) abbrev(12)

        * Producer-anchor: full-sample raw bivariate must reproduce -11.199 (D8).
        qui sum b_ols if leg=="producer" & spec=="p1" & dropped=="NONE", meanonly
        di as text _n "  Producer-anchor raw bivariate b = " %7.3f r(mean) "   [D8 anchor: -11.199]"
        assert reldif(r(mean), -11.199) < 0.01
        di as result "  PRODUCER-ANCHOR OK — raw cross-bloc differential reproduced."
        di as text _n "  --- Producer cascade (OLS HC3, full sample): p1 raw -> p4 +French ---"
        list spec b_ols se_ols if leg=="producer" & dropped=="NONE", noobs sep(0) abbrev(10)
    restore
}


**# 2. Randomization inference (10,000 perms) — gated by RUN_RI
*------------------------------------------------------------------------------*
* ritest physically permutes the focal regressor across the 25 cantons and
* re-estimates, RI_REPS times, seeded. Design (plan + D4/D8):
*   OLS beta RI : ALL cascade cols — wine X3 (c1-c5), co-headline X2 (c5),
*                 producer cascade (p1 raw .. p4 full).            [cheap]
*   FL AME  RI : TARGETED endpoints — wine X3 headline c5 + c2 flip, X2 c5,
*                 producer raw p1 + full p4.  [expensive: each rep re-fits
*                 fracreg + margins, so only the decision-relevant cells]
* Every row stamps `reps' so 23_tables can refuse to present a smoke run as
* final (methodology-integrity: canonical = 10,000, never silently reduced).
* FL AME RI wraps a small eclass program returning the margins AME per perm.
*------------------------------------------------------------------------------*
capture program drop _fl_ame_x3
program define _fl_ame_x3, eclass
    fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    margins, dydx(X3_share) post
end
capture program drop _fl_ame_x3_c2
program define _fl_ame_x3_c2, eclass
    fracreg logit Y1_frac X3_share cov1, vce(robust)
    margins, dydx(X3_share) post
end
capture program drop _fl_ame_x2
program define _fl_ame_x2, eclass
    fracreg logit Y1_frac X2_share cov1 cov2_total_share cov3 ln_density, vce(robust)
    margins, dydx(X2_share) post
end
capture program drop _fl_ame_prod_raw
program define _fl_ame_prod_raw, eclass
    fracreg logit Y1_frac abs_producer, vce(robust)
    margins, dydx(abs_producer) post
end
capture program drop _fl_ame_prod_full
program define _fl_ame_prod_full, eclass
    fracreg logit Y1_frac abs_producer X3_share cov1 cov3 ln_density, vce(robust)
    margins, dydx(abs_producer) post
end

if "${RUN_RI}" == "1" {
    tempname rihandle
    tempfile rifile
    postfile `rihandle' str12 leg str8 spec str8 estimator double(p_ri b_obs reps) ///
        using "`rifile'", replace

    * wine cascade control sets
    local ctrl1 ""
    local ctrl2 "cov1"
    local ctrl3 "cov1 cov2_total_share"
    local ctrl4 "cov1 cov2_total_share cov3"
    local ctrl5 "cov1 cov2_total_share cov3 ln_density"
    * producer cascade control sets (focal = abs_producer; mirrors D8 / §1)
    local pctrl1 ""                                  // p1 raw bivariate
    local pctrl2 "cov3 ln_density"                   // p2 +Protestant+density
    local pctrl3 "X3_share cov3 ln_density"          // p3 +wine+Prot+density
    local pctrl4 "X3_share cov1 cov3 ln_density"     // p4 +French (full)

    * --- OLS beta RI: wine X3, all cascade cols (fast) ---
    forvalues j = 1/5 {
        qui reg Y1 X3_share `ctrl`j'', vce(hc3)
        local bobs = _b[X3_share]
        qui ritest X3_share _b[X3_share], reps(`RI_REPS') seed(20260603) nodots: ///
            reg Y1 X3_share `ctrl`j'', vce(hc3)
        matrix p = r(p)
        post `rihandle' ("wine_X3") ("c`j'") ("ols") (p[1,1]) (`bobs') (`RI_REPS')
    }
    * --- OLS beta RI: co-headline X2 col-5 ---
    qui reg Y1 X2_share `ctrl5', vce(hc3)
    local bobs = _b[X2_share]
    qui ritest X2_share _b[X2_share], reps(`RI_REPS') seed(20260603) nodots: ///
        reg Y1 X2_share `ctrl5', vce(hc3)
    matrix p = r(p)
    post `rihandle' ("wine_X2") ("c5") ("ols") (p[1,1]) (`bobs') (`RI_REPS')

    * --- OLS beta RI: producer cascade p1..p4 ---
    forvalues j = 1/4 {
        qui reg Y1 abs_producer `pctrl`j'', vce(hc3)
        local bobs = _b[abs_producer]
        qui ritest abs_producer _b[abs_producer], reps(`RI_REPS') seed(20260603) nodots: ///
            reg Y1 abs_producer `pctrl`j'', vce(hc3)
        matrix p = r(p)
        post `rihandle' ("producer") ("p`j'") ("ols") (p[1,1]) (`bobs') (`RI_REPS')
    }

    * --- FL AME RI: wine headline c5, c2 flip, co-headline X2 c5 ---
    qui _fl_ame_x3
    local bobs = _b[X3_share]*100
    qui ritest X3_share _b[X3_share], reps(`RI_REPS') seed(20260603) nodots: _fl_ame_x3
    matrix p = r(p)
    post `rihandle' ("wine_X3") ("c5") ("fl_ame") (p[1,1]) (`bobs') (`RI_REPS')

    qui _fl_ame_x3_c2
    local bobs = _b[X3_share]*100
    qui ritest X3_share _b[X3_share], reps(`RI_REPS') seed(20260603) nodots: _fl_ame_x3_c2
    matrix p = r(p)
    post `rihandle' ("wine_X3") ("c2") ("fl_ame") (p[1,1]) (`bobs') (`RI_REPS')

    qui _fl_ame_x2
    local bobs = _b[X2_share]*100
    qui ritest X2_share _b[X2_share], reps(`RI_REPS') seed(20260603) nodots: _fl_ame_x2
    matrix p = r(p)
    post `rihandle' ("wine_X2") ("c5") ("fl_ame") (p[1,1]) (`bobs') (`RI_REPS')

    * --- FL AME RI: producer endpoints (raw p1 + full p4) ---
    qui _fl_ame_prod_raw
    local bobs = _b[abs_producer]*100
    qui ritest abs_producer _b[abs_producer], reps(`RI_REPS') seed(20260603) nodots: _fl_ame_prod_raw
    matrix p = r(p)
    post `rihandle' ("producer") ("p1") ("fl_ame") (p[1,1]) (`bobs') (`RI_REPS')

    qui _fl_ame_prod_full
    local bobs = _b[abs_producer]*100
    qui ritest abs_producer _b[abs_producer], reps(`RI_REPS') seed(20260603) nodots: _fl_ame_prod_full
    matrix p = r(p)
    post `rihandle' ("producer") ("p4") ("fl_ame") (p[1,1]) (`bobs') (`RI_REPS')

    postclose `rihandle'
    preserve
        use "`rifile'", clear
        compress
        char _dta[ri_reps] `RI_REPS'
        char _dta[ri_seed] 20260603
        save "$MyProject/results/intermediate/inference_ri.dta", replace
        di as result "  §2 RI saved: inference_ri.dta (" _N " rows, `RI_REPS' perms each, seed 20260603)"
        if `RI_REPS' < 10000 di as error "  >>> PROVISIONAL: RI_REPS=`RI_REPS' < 10000 — re-run RUN_RI=1 with NO RI_REPS_TEST for the canonical battery."
        list leg spec estimator b_obs p_ri reps, noobs sep(0) abbrev(12)
    restore
}
else {
    di as text "  §2 RI SKIPPED (\$RUN_RI=0, fast verification pass)."
}


**# 3. HC1 / HC2 / HC3 SEs + Bell-McCaffrey (Imbens-Koleśár 2016) dof — Mata
*------------------------------------------------------------------------------*
* HC1/HC2/HC3 SEs are native; the BM/IK effective dof is hand-implemented and
* VALIDATED in-script: the Mata HC2 SE must equal Stata's native vce(hc2) SE
* (assert < 1e-6). BM dof formula (homoskedastic working cov):
*   K = (c'(X'X)^-1 c)^2 / sum_ij g2_i g2_j M_ij^2,
*   g_i = (x_i'(X'X)^-1 c)/sqrt(1-h_i), M = I - X(X'X)^-1 X', g2=g^2.
* Reported on the headline OLS col-5 (X3_share) + cascade for context.
*------------------------------------------------------------------------------*
mata:
mata clear
real rowvector ikbm(real matrix X, real colvector y, real scalar fc) {
    // returns (hc2_se, bm_dof, beta_fc)
    N = rows(X); k = cols(X)
    XtXi = invsym(cross(X,X))
    b  = XtXi*cross(X,y)
    e  = y - X*b
    H  = X*XtXi*X'
    h  = diagonal(H)
    M  = I(N) - H
    c  = J(k,1,0); c[fc,1] = 1
    Aic = XtXi*c                         // (X'X)^-1 c
    gx  = X*Aic                          // x_i'(X'X)^-1 c
    hc2v = sum( (gx:^2) :* (e:^2) :/ (1:-h) )
    g2  = (gx:^2) :/ (1:-h)              // g_i^2
    num = (c'Aic)^2
    den = g2' * (M:*M) * g2
    return( (sqrt(hc2v), num/den, b[fc,1]) )
}
end

{
    local ctrl1 ""
    local ctrl2 "cov1"
    local ctrl3 "cov1 cov2_total_share"
    local ctrl4 "cov1 cov2_total_share cov3"
    local ctrl5 "cov1 cov2_total_share cov3 ln_density"

    tempname sehandle
    tempfile sefile
    postfile `sehandle' str8 spec double(b se_hc1 se_hc2 se_hc3 bm_dof t_hc2 p_bm) ///
        using "`sefile'", replace

    forvalues j = 1/5 {
        local cset "`ctrl`j''"
        * native HC1/HC2/HC3 SEs on X3_share  (Stata: vce(robust) == HC1)
        qui reg Y1 X3_share `cset', vce(robust)
        local b1  = _b[X3_share]
        local s1  = _se[X3_share]
        qui reg Y1 X3_share `cset', vce(hc2)
        local s2n = _se[X3_share]                // native HC2 (validation target)
        qui reg Y1 X3_share `cset', vce(hc3)
        local s3  = _se[X3_share]

        * Mata IK-BM: build X (focal first + controls + constant), focal col = 1.
        * putmata takes a space-separated varlist in parens (no commas).
        local xv "X3_share `cset'"
        qui putmata yM = (Y1) if e(sample), replace
        qui putmata XM = (`xv') if e(sample), replace
        mata: XM = (XM, J(rows(XM),1,1))         // append constant
        mata: r = ikbm(XM, yM, 1)
        mata: st_local("se_hc2_m", strofreal(r[1])); st_local("bm", strofreal(r[2]))
        local kbm = real("`bm'")
        * VALIDATE: Mata HC2 SE must match native HC2 SE
        assert reldif(real("`se_hc2_m'"), `s2n') < 1e-6
        local tval = abs(`b1'/`s2n')
        local pbm  = 2*ttail(`kbm', `tval')
        post `sehandle' ("c`j'") (`b1') (`s1') (`s2n') (`s3') (`kbm') (`tval') (`pbm')
    }
    postclose `sehandle'
    preserve
        use "`sefile'", clear
        compress
        save "$MyProject/results/intermediate/inference_se_bm.dta", replace
        di as result "  §3 SE+BM saved: inference_se_bm.dta (HC2 Mata==native validated)"
        list spec b se_hc3 se_hc2 bm_dof p_bm, noobs sep(0) abbrev(10)
    restore
}


**# 4. Oster (2019) delta-bounds (psacalc) — headline OLS col-5
*------------------------------------------------------------------------------*
* delta = strength of selection on UNOBSERVABLES (relative to observables)
* needed to drive the wine coefficient to zero. Short (uncontrolled) model =
* Y1 ~ X3_share alone; long (controlled) model = the full col-5 spec.
*
* CRITICAL: psacalc's mcontrol() is LEFT EMPTY. mcontrol() lists controls held
* fixed in BOTH the short and long models; listing the col-5 controls there
* (an earlier bug) forces short==long, degenerating the bound to missing. With
* no mcontrol, psacalc uses the bivariate as the short model (the standard Oster
* setup), so the -0.196 -> +0.469 Simpson movement drives the bound.
*
* RESULT IS ILL-POSED FOR ATTENUATION (report honestly; do NOT force a delta):
* observables move the coefficient AWAY from zero (Simpson flip -0.196 ->
* +0.469), so the delta that would zero it out is NEGATIVE (delta<0 means
* unobservable selection would have to run OPPOSITE to observable selection).
* Under equal selection (delta=1) the bias-adjusted beta is LARGER (~0.82 at
* rmax=1.3*R2), not smaller. Oster therefore CORROBORATES the wine result
* rather than threatening it. rmax = 1.3*R2 (Oster's recommended bound) + rmax=1.
*------------------------------------------------------------------------------*
{
    * Short (uncontrolled) vs long (controlled) betas + R2 for the narrative.
    qui reg Y1 X3_share, vce(hc3)
    local b_short  = _b[X3_share]
    local r2_short = e(r2)
    qui reg Y1 X3_share cov1 cov2_total_share cov3 ln_density, vce(hc3)
    local b_long   = _b[X3_share]
    local r2_long  = e(r2)
    local rmax13   = min(1, 1.3*`r2_long')

    tempname ohandle
    tempfile ofile
    postfile `ohandle' str16 quantity double(value rmax_used delta_used) using "`ofile'", replace

    post `ohandle' ("beta_short")  (`b_short')  (.)        (.)
    post `ohandle' ("r2_short")    (`r2_short') (.)        (.)
    post `ohandle' ("beta_long")   (`b_long')   (.)        (.)
    post `ohandle' ("r2_long")     (`r2_long')  (.)        (.)

    * delta to zero out beta, at rmax = 1.3*R2 and rmax = 1 (NO mcontrol)
    qui psacalc delta X3_share, rmax(`rmax13')
    post `ohandle' ("delta_rmax13") (r(delta)) (`rmax13') (.)
    qui psacalc delta X3_share, rmax(1)
    post `ohandle' ("delta_rmax1")  (r(delta)) (1)        (.)
    * beta bound at delta = 1, rmax = 1.3*R2 and rmax = 1
    qui psacalc beta X3_share, rmax(`rmax13') delta(1)
    post `ohandle' ("beta_delta1_r13") (r(beta)) (`rmax13') (1)
    qui psacalc beta X3_share, rmax(1) delta(1)
    post `ohandle' ("beta_delta1_r1")  (r(beta)) (1)        (1)

    postclose `ohandle'
    preserve
        use "`ofile'", clear
        compress
        save "$MyProject/results/intermediate/inference_oster.dta", replace
        di as result "  §4 Oster saved: inference_oster.dta (delta<0 => ill-posed for attenuation; corroborates)"
        list quantity value rmax_used delta_used, noobs sep(0) abbrev(16)
    restore
}


**# 5. White-vs-red wine split (Cahannes mechanism) — col 5
*------------------------------------------------------------------------------*
* Prediction (Cahannes 1981): absinthe competed with WHITE wine, so
* beta(white) > beta(red). OLS (Y1, HC3) + FL AME for each.
*------------------------------------------------------------------------------*
{
    tempname whandle
    tempfile wfile
    postfile `whandle' str10 wine str8 estimator double(b se) using "`wfile'", replace

    foreach w in X3_white_share X3_red_share {
        qui reg Y1 `w' cov1 cov2_total_share cov3 ln_density, vce(hc3)
        post `whandle' ("`w'") ("ols") (_b[`w']) (_se[`w'])
        qui fracreg logit Y1_frac `w' cov1 cov2_total_share cov3 ln_density, vce(robust)
        margins, dydx(`w') post
        post `whandle' ("`w'") ("fl_ame") (_b[`w']*100) (_se[`w']*100)
    }
    postclose `whandle'
    preserve
        use "`wfile'", clear
        compress
        save "$MyProject/results/intermediate/inference_winetype.dta", replace
        di as result "  §5 white/red saved: inference_winetype.dta"
        list wine estimator b se, noobs sep(0) abbrev(12)
    restore
}


**# 6. Conley (1999) spatial-HAC — DEFERRED (no canton coordinates yet)
*------------------------------------------------------------------------------*
* Decision D2: deferred until period-appropriate Swiss canton centroids are
* sourced (1908 boundaries; never fabricated) AND acreg is vendored via
* /add-package. When ready: build distance/contiguity from centroids, then
* acreg Y1 X3_share <controls>, spatial latitude(lat) longitude(lon) dist(cutoff).
*------------------------------------------------------------------------------*
di as text "  §6 Conley spatial-HAC: DEFERRED (see decision log D2)."


**# 7. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        foreach ds in inference_loo inference_se_bm inference_oster inference_winetype {
            cap _inventory_append, sheet("outputs") ///
                row("created|results/intermediate/`ds'.dta|.|.|.|22_canton_inference_battery.do")
        }
        if "${RUN_RI}" == "1" {
            cap _inventory_append, sheet("outputs") ///
                row("created|results/intermediate/inference_ri.dta|.|.|.|22_canton_inference_battery.do")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
