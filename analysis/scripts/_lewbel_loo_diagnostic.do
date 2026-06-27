/*==============================================================================
 _lewbel_loo_diagnostic.do
 Purpose:  DIAGNOSTIC-ONLY leave-one-out on the Lewbel heteroskedasticity-IV
           (feasibility Task 4 spec) to decide whether the surprising KP rk
           Wald F = 222 is genuine or one-canton-driven. The F-vs-underID-LM
           tension (LM p = 0.146 at N=25) suggests the first stage may rest on
           one/two influential cantons; NE (absinthe heartland) = prime suspect.

 Dispatch: quality_reports/coder_dispatch/2026-06-09_lewbel-loo-diagnostic.md
 Dataset:  $MyProject/processed/cohort_1908_workshop.dta (N=25)
 Spec:     ivreg2h yes_pct (X3_share = ) french_share catholic_share ln_pop_1900, robust
           (yes_pct = Y1; identical to feasibility Task 4)
 Output:   $MyProject/results/intermediate/inference_lewbel_loo.dta (26 rows: NONE + 25 LOO)
           + console RESULT scalars + ROBUST/FRAGILE verdict.
           Memo section appended to
           quality_reports/coder_reports/2026-06-09_feasibility-ipw-ebal-lewbel.md.
 Status:   diagnostic only; no paper / main-analysis / table-of-record edits;
           single light Stata op; do NOT touch the parked 10k RI.
 Author:   Lewbel-LOO dispatch (2026-06-09)
==============================================================================*/
version 19
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}
cap which _codebook_update
if _rc run "$MyProject/scripts/programs/_config.do"
cap which ivreg2h
if _rc adopath ++ "$MyProject/scripts/libraries/stata"
cap which ivreg2h
if _rc {
    di as error "  ivreg2h missing (run /add-package ivreg2h)."
    error 111
}
set graphics off

use "$MyProject/processed/cohort_1908_workshop.dta", clear
qui count
assert r(N) == 25
isid canton_iso
cap drop yes_pct
gen double yes_pct = Y1
local X "french_share catholic_share ln_pop_1900"

tempname lh
tempfile lf
postfile `lh' str8 dropped double(b se z p kpF kp_lm_p hansenj_p) using "`lf'", replace

levelsof canton_iso, local(cantons)
foreach d in NONE `cantons' {
    if "`d'" == "NONE"  cap noi ivreg2h yes_pct (X3_share = ) `X', robust
    else                cap noi ivreg2h yes_pct (X3_share = ) `X' if canton_iso != "`d'", robust
    if _rc == 0 {
        local b  = _b[X3_share]
        local se = _se[X3_share]
        local z  = `b'/`se'
        local pv = 2*(1-normal(abs(`z')))
        post `lh' ("`d'") (`b') (`se') (`z') (`pv') (e(widstat)) (e(idp)) (e(jp))
    }
    else {
        di as error "  LOO drop-`d': ivreg2h rc=`=_rc'"
        post `lh' ("`d'") (.) (.) (.) (.) (.) (.) (.)
    }
}
postclose `lh'

preserve
    use "`lf'", clear
    compress
    save "$MyProject/results/intermediate/inference_lewbel_loo.dta", replace

    * full-sample reference (should reproduce feasibility Task 4)
    foreach v in b se p kpF kp_lm_p hansenj_p {
        qui sum `v' if dropped=="NONE", meanonly
        local full_`v' = r(mean)
    }
    di as result _n "  RESULT lewbel_full: b=" %7.4f `full_b' "  se=" %6.4f `full_se' "  p=" %6.4f `full_p' "  KP_F=" %8.2f `full_kpF' "  LM_p=" %6.4f `full_kp_lm_p' "  J_p=" %6.4f `full_hansenj_p'

    * LOO ranges (exclude full sample)
    qui sum b   if dropped!="NONE"
    di as result "  RESULT loo_coef_min=" %7.4f r(min) "  max=" %7.4f r(max)
    qui sum kpF if dropped!="NONE"
    di as result "  RESULT loo_KPF_min="  %8.2f r(min) "  max=" %8.2f r(max)
    qui sum p   if dropped!="NONE"
    di as result "  RESULT loo_p_min="    %6.4f r(min) "  max=" %6.4f r(max)

    * stability counts (focal sign = full-sample sign)
    local fsign = sign(`full_b')
    qui count if dropped!="NONE" & sign(b)!=`fsign' & !missing(b)
    local nflip = r(N)
    di as result "  RESULT loo_n_signflip   = `nflip'"
    qui count if dropped!="NONE" & p>=0.10 & !missing(p)
    local nins10 = r(N)
    di as result "  RESULT loo_n_insig_10pct = `nins10'"
    qui count if dropped!="NONE" & p>=0.05 & !missing(p)
    local nins5 = r(N)
    di as result "  RESULT loo_n_insig_5pct  = `nins5'"
    qui count if dropped!="NONE" & kpF<=20 & !missing(kpF)
    local nweak = r(N)
    di as result "  RESULT loo_n_KPF_le20    = `nweak'"
    qui count if dropped!="NONE" & missing(b)
    local nfail = r(N)
    di as result "  RESULT loo_n_failed     = `nfail'"

    * drop-NE row explicitly (the prime suspect)
    di as text _n "  --- drop-NE (Neuchatel, absinthe heartland) Lewbel fit ---"
    list dropped b se p kpF kp_lm_p hansenj_p if dropped=="NE", noobs sep(0) abbrev(12)

    * full LOO table
    di as text _n "  --- Lewbel LOO: coef / SE / p / KP F by dropped canton ---"
    gen byte _ord = (dropped!="NONE")
    sort _ord dropped
    list dropped b se p kpF if !missing(b), noobs sep(0) abbrev(10)

    * verdict (ROBUST requires: no sign flip, all p<0.10, all KP F>20, no failed fit)
    if (`nflip'==0 & `nins10'==0 & `nweak'==0 & `nfail'==0) {
        di as result _n "  VERDICT = ROBUST  (all 25 LOO fits keep sign, p<0.10, KP F>20, incl. drop-NE)"
    }
    else {
        di as result _n "  VERDICT = FRAGILE (signflip=`nflip', insig@10%=`nins10', KP_F<=20=`nweak', failed=`nfail')"
    }
restore

di as text _n "  Lewbel LOO diagnostic complete — grep 'RESULT '/'VERDICT'."

** EOF
