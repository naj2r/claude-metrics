/*==============================================================================
 _lewbel_appendix_table.do
 Purpose:  Code-generate the EXPLORATORY Lewbel heteroskedasticity-IV appendix
           table from the LOO diagnostic dataset. Robustness is framed on
           LEAVE-ONE-OUT STABILITY, NOT the KP F>20 heuristic (only a rule of
           thumb for generated instruments at N=25). The untestable Lewbel
           identifying restriction is stated. Appendix-grade; NOT main-text.
 Dispatch: quality_reports/coder_dispatch/2026-06-09_lewbel-loo-diagnostic.md (PI go 2026-06-09)
 Input:    $MyProject/results/intermediate/inference_lewbel_loo.dta
 Output:   $MyProject/results/tables/T_lewbel_appendix.tex (+ _md/T_lewbel_appendix.md)
           + staged copy to Overleaf Tables/Robustness_6-3-26/ (NOT \input into the manuscript).
 Status:   appendix staging only; no main-analysis / manuscript prose edits.
==============================================================================*/
version 19
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}
cap which texsave
if _rc adopath ++ "$MyProject/scripts/libraries/stata"

global LocalTables  "$MyProject/results/tables"
global LocalMd      "$MyProject/results/tables/_md"
global RobustTables "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Robustness_6-3-26"
cap mkdir "$LocalTables"
cap mkdir "$LocalMd"

use "$MyProject/results/intermediate/inference_lewbel_loo.dta", clear

* --- full-sample reference + LOO summary ---
foreach v in b se kpF kp_lm_p hansenj_p {
    qui sum `v' if dropped=="NONE", meanonly
    local f_`v' = r(mean)
}
local ci_lo = `f_b' - 1.96*`f_se'
local ci_hi = `f_b' + 1.96*`f_se'
qui sum b   if dropped!="NONE"
local lo_min = r(min)
local lo_max = r(max)
qui sum kpF if dropped!="NONE"
local F_min = r(min)
qui sum b   if dropped=="NE", meanonly
local ne_b = r(mean)
qui sum kpF if dropped=="NE", meanonly
local ne_F = r(mean)
local fsign = sign(`f_b')
qui count if dropped!="NONE" & sign(b)!=`fsign' & !missing(b)
local nflip = r(N)
qui count if dropped!="NONE" & p>=0.05 & !missing(p)
local nins5 = r(N)

* --- assemble compact appendix table (ASCII only; no % ^ & # _ $ in cells) ---
clear
set obs 9
gen str54 c0 = ""
gen str26 c1 = ""
replace c0 = "Wine revenue-share coef (full sample, robust SE)"   in 1
replace c1 = string(`f_b',"%4.3f") + " (" + string(`f_se',"%4.3f") + ")" in 1
replace c0 = "95-percent confidence interval"                     in 2
replace c1 = "[" + string(`ci_lo',"%4.3f") + ", " + string(`ci_hi',"%4.3f") + "]" in 2
replace c0 = "Kleibergen-Paap rk Wald F (full sample)"            in 3
replace c1 = string(`f_kpF',"%6.1f")                              in 3
replace c0 = "Hansen J overidentification p"                      in 4
replace c1 = string(`f_hansenj_p',"%4.3f")                        in 4
replace c0 = "Generated instruments"                              in 5
replace c1 = "3"                                                  in 5
replace c0 = "Leave-one-out coef range (25 single-canton drops)"  in 6
replace c1 = "[" + string(`lo_min',"%4.3f") + ", " + string(`lo_max',"%4.3f") + "]" in 6
replace c0 = "Leave-one-out minimum KP F"                         in 7
replace c1 = string(`F_min',"%5.1f")                              in 7
replace c0 = "drop-NE (heartland): coef / KP F"                   in 8
replace c1 = string(`ne_b',"%4.3f") + " / " + string(`ne_F',"%5.1f") in 8
replace c0 = "LOO sign flips / fits insig. at 5 percent"          in 9
replace c1 = string(`nflip',"%2.0f") + " / " + string(`nins5',"%2.0f") in 9

label var c0 "Lewbel heteroskedasticity-IV (exploratory)"
label var c1 "Value"

local fn = "Lewbel (2012) heteroskedasticity-based IV (ivreg2h) for the wine revenue share, col-5 controls (French share, Catholic share, log population), N=25 cantons. EXPLORATORY endogeneity-robustness only -- NOT a main-text result. Robustness is assessed by LEAVE-ONE-OUT STABILITY: the coefficient keeps its sign and 5-percent significance and the KP F stays at or above 46 across all 25 single-canton deletions, including dropping Neuchatel (the absinthe heartland). It is NOT certified by the KP F greater-than-20 rule of thumb, which is only heuristic for generated instruments at N=25. The Lewbel identifying restriction (controls uncorrelated with the product of the structural and first-stage errors) is untestable. The estimate corroborates the OLS / fractional-logit headline (about 0.43 to 0.47) via a route that needs no common support."

texsave c0 c1 using "$LocalTables/T_lewbel_appendix.tex", replace frag nofix varlabels ///
    title("Lewbel heteroskedasticity-IV: exploratory endogeneity-robustness for the wine coefficient") ///
    label("tab:T_lewbel_appendix") ///
    footnote("`fn'", size(footnotesize))

* --- markdown twin ---
cap file close mdh
file open mdh using "$LocalMd/T_lewbel_appendix.md", write replace
file write mdh "# T_lewbel_appendix -- Lewbel exploratory endogeneity-robustness" _n _n
file write mdh "| Lewbel heteroskedasticity-IV (exploratory) | Value |" _n
file write mdh "| --- | --- |" _n
forvalues i = 1/`=_N' {
    file write mdh ("| " + c0[`i'] + " | " + c1[`i'] + " |") _n
}
file write mdh _n ("_Note: " + "`fn'" + "_") _n
file close mdh

* --- stage to Overleaf robustness folder (file copy only; not wired into the paper) ---
cap copy "$LocalTables/T_lewbel_appendix.tex" "$RobustTables/T_lewbel_appendix.tex", replace
if _rc di as error "  (could not stage to Overleaf rc=`=_rc'; Dropbox reachable?)"
else   di as result "  staged T_lewbel_appendix.tex to Overleaf Robustness_6-3-26/"

* --- verify ---
cap confirm file "$LocalTables/T_lewbel_appendix.tex"
assert _rc==0
cap confirm file "$LocalMd/T_lewbel_appendix.md"
assert _rc==0
di as result "  T_lewbel_appendix tex+md written (full coef " %4.3f `f_b' ", LOO range [" %4.3f `lo_min' ", " %4.3f `lo_max' "], min F " %4.1f `F_min' ")."

** EOF
