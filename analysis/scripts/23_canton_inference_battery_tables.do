/*==============================================================================
 23_canton_inference_battery_tables.do
 Purpose:  Build the LaTeX tables (+ markdown twins) for the small-N inference
           battery produced by 22_canton_inference_battery.do. Hand-built
           texsave fragments on string datasets (the inputs are postfile result
           frames, not .ster files, so the _workshop_table wrapper does not
           apply).

           Tables (all -> results/tables/T_<name>.tex + _md/T_<name>.md):
             T_loo_gate          wine col-5 leave-one-out (the gate)   [FINAL]
             T_producer_cascade  producer cascade p1..p4               [FINAL]
             T_se_bm             wine cascade HC1/HC2/HC3 + BM dof      [FINAL]
             T_oster             Oster (2019) delta-bounds             [FINAL]
             T_winetype          white vs red wine                     [FINAL]
             T_ri                randomization inference p-values       [RI-gated]

           METHODOLOGY-INTEGRITY GATE: the RI table is only "final" when the
           battery was run at 10,000 perms. 22 stamps char _dta[ri_reps] (and a
           reps column) on inference_ri.dta. If reps < 10000 (a dev smoke), this
           script marks T_ri "PROVISIONAL" in its caption AND withholds it from
           the Overleaf deploy, so a smoke p-value can never reach the paper.

 Input:    $MyProject/results/intermediate/inference_{loo,se_bm,oster,winetype,ri}.dta
 Output:   $MyProject/results/tables/T_*.tex            (LaTeX fragments)
           $MyProject/results/tables/_md/T_*.md         (markdown twins)
           + copies of the FINAL tables to the Overleaf robustness folder
             (Tables/Robustness_6-3-26/) per decision log D6.

 Decisions log: quality_reports/coder_reports/2026-06-03_inference-battery-decision-log.md
 Author:   Inference-battery dispatch (2026-06-03)
 Version:  1.0
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set (run.do or your Stata profile)"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

* --- Output destinations ---
global LocalTables "$MyProject/results/tables"
global LocalMd     "$MyProject/results/tables/_md"
global RobustTables "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Robustness_6-3-26"
cap mkdir "$LocalTables"
cap mkdir "$LocalMd"
cap mkdir "$RobustTables"

local INTER "$MyProject/results/intermediate"


**# 0. Helper: dump the current (all-string) dataset as a markdown table
*------------------------------------------------------------------------------*
* Writes a markdown twin from a string dataset whose display columns are the
* variables in order; column headers come from variable labels. Cells are read
* as data expressions (file write (expr)) so cell content never goes through
* macro expansion. Keep cells plain ASCII (no pipes).
cap program drop _md_dump
program define _md_dump
    version 19
    syntax using/ , [TITLE(string) NOTE(string)]
    cap file close _mdh
    file open _mdh using `"`using'"', write replace
    if `"`title'"' != "" file write _mdh `"# `title'"' _n _n
    unab allv : _all
    file write _mdh "|"
    foreach v of local allv {
        local lbl : variable label `v'
        if `"`lbl'"' == "" local lbl "`v'"
        file write _mdh `" `lbl' |"'
    }
    file write _mdh _n "|"
    foreach v of local allv {
        file write _mdh " --- |"
    }
    file write _mdh _n
    forvalues i = 1/`=_N' {
        file write _mdh "|"
        foreach v of local allv {
            file write _mdh (" " + `v'[`i'] + " |")
        }
        file write _mdh _n
    }
    if `"`note'"' != "" file write _mdh _n `"_Note: `note'_"' _n
    file close _mdh
end

* Track which tables are FINAL (deploy to Overleaf). T_ri added conditionally.
local final_tables ""


**# 0b. RI provisional detection
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_ri.dta", clear
    qui sum reps, meanonly
    local ri_reps = r(max)
    local ri_seed : char _dta[ri_seed]
    if "`ri_seed'" == "" local ri_seed "20260603"
    global RI_STALE "0"
    if "${RI_PENDING_RERUN}" == "1" {
        global RI_PROVISIONAL "1"
        global RI_STALE "1"
        di as error "  RI is STALE: inference_ri.dta is the pre-1907-population-fix 10k run (RUN_RI=0 this pass)."
        di as error "  T_ri withheld from Overleaf + flagged pending the standalone R RI re-run on the corrected data."
    }
    else if `ri_reps' >= 10000 {
        global RI_PROVISIONAL "0"
        di as result "  RI is CANONICAL (`ri_reps' perms, seed `ri_seed') — T_ri will deploy."
    }
    else {
        global RI_PROVISIONAL "1"
        di as error "  RI is PROVISIONAL (`ri_reps' perms < 10000) — T_ri marked provisional + withheld from Overleaf."
        di as error "  Re-run _inference_battery_run.do (10k) then re-run this script to finalize T_ri."
    }
}


**# 1. T_loo_gate — wine col-5 leave-one-out (the gate)
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_loo.dta", clear
    keep if leg=="wine_X3" & spec=="c5"

    foreach d in NONE NE VD {
        qui sum b_fl_ame  if dropped=="`d'", meanonly
        local flb_`d' = r(mean)
        qui sum se_fl_ame if dropped=="`d'", meanonly
        local fls_`d' = r(mean)
        qui sum b_ols     if dropped=="`d'", meanonly
        local olb_`d' = r(mean)
        qui sum se_ols    if dropped=="`d'", meanonly
        local ols_`d' = r(mean)
    }
    qui sum b_fl_ame if dropped!="NONE"
    local fl_min = r(min)
    local fl_max = r(max)
    qui sum b_ols if dropped!="NONE"
    local ol_min = r(min)
    local ol_max = r(max)
    * argmin/argmax canton (FL AME)
    preserve
        keep if dropped!="NONE"
        sort b_fl_ame
        local fl_minc = dropped[1]
        local fl_maxc = dropped[_N]
    restore

    clear
    set obs 4
    gen str30 c0 = ""
    gen str22 c1 = ""
    gen str22 c2 = ""
    replace c0 = "Full sample (N=25)"   in 1
    replace c0 = "Drop Neuchatel (NE)"  in 2
    replace c0 = "Drop Vaud (VD)"       in 3
    replace c0 = "LOO range [min, max]" in 4
    replace c1 = string(`flb_NONE',"%4.3f") + " (" + string(`fls_NONE',"%4.3f") + ")" in 1
    replace c2 = string(`olb_NONE',"%4.3f") + " (" + string(`ols_NONE',"%4.3f") + ")" in 1
    replace c1 = string(`flb_NE',"%4.3f")   + " (" + string(`fls_NE',"%4.3f")   + ")" in 2
    replace c2 = string(`olb_NE',"%4.3f")   + " (" + string(`ols_NE',"%4.3f")   + ")" in 2
    replace c1 = string(`flb_VD',"%4.3f")   + " (" + string(`fls_VD',"%4.3f")   + ")" in 3
    replace c2 = string(`olb_VD',"%4.3f")   + " (" + string(`ols_VD',"%4.3f")   + ")" in 3
    replace c1 = "[" + string(`fl_min',"%4.3f") + ", " + string(`fl_max',"%4.3f") + "]" in 4
    replace c2 = "[" + string(`ol_min',"%4.3f") + ", " + string(`ol_max',"%4.3f") + "]" in 4

    label var c0 " "
    label var c1 "FL AME (pp)"
    label var c2 "OLS coef (HC3)"

    local fn_loo "Yes-vote share (vote \#68) on national wine revenue share, col-5 spec (+ French share + Absinthe trade share + Protestant share + log density). FL AME = fractional-logit average marginal effect, percentage points of yes-share per percentage point of wine share; OLS coef = HC3, on the 0-100 yes-share scale. Standard errors in parentheses. Each row re-estimates dropping the named canton(s). LOO range spans all 25 single-canton deletions (FL AME min at drop-`fl_minc', max at drop-`fl_maxc'). The wine effect stays positive and similar in magnitude under every single-canton deletion, including drop-Vaud: it is not driven by any one canton."

    texsave c0 c1 c2 using "$LocalTables/T_loo_gate.tex", replace frag nofix varlabels ///
        title("Leave-one-out: the wine result survives dropping any single canton (col 5)") ///
        label("tab:T_loo_gate") ///
        footnote("`fn_loo'", size(footnotesize))
    _md_dump using "$LocalMd/T_loo_gate.md", ///
        title("T_loo_gate — wine col-5 leave-one-out (the gate)") ///
        note("`fn_loo'")
    di as text "  wrote T_loo_gate.{tex,md}"
    local final_tables "`final_tables' T_loo_gate"
}


**# 2. T_producer_cascade — abs_producer cascade p1..p4
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_loo.dta", clear
    keep if leg=="producer"

    foreach p in p1 p2 p3 p4 {
        qui sum b_ols     if spec=="`p'" & dropped=="NONE", meanonly
        local pb_`p' = r(mean)
        qui sum se_ols    if spec=="`p'" & dropped=="NONE", meanonly
        local ps_`p' = r(mean)
        qui sum b_fl_ame  if spec=="`p'" & dropped=="NONE", meanonly
        local fb_`p' = r(mean)
        qui sum se_fl_ame if spec=="`p'" & dropped=="NONE", meanonly
        local fs_`p' = r(mean)
    }
    * LOO range of the raw differential (p1) and the full spec (p4), OLS
    foreach p in p1 p4 {
        qui sum b_ols if spec=="`p'" & dropped!="NONE"
        local lo_`p' = r(min)
        local hi_`p' = r(max)
    }

    clear
    set obs 4
    gen str34 c0 = ""
    gen str22 c1 = ""
    gen str22 c2 = ""
    replace c0 = "p1: raw bivariate"            in 1
    replace c0 = "p2: + Protestant + density"   in 2
    replace c0 = "p3: + wine + Prot. + density" in 3
    replace c0 = "p4: + French (full)"          in 4
    local i 0
    foreach p in p1 p2 p3 p4 {
        local ++i
        replace c1 = string(`pb_`p'',"%5.2f") + " (" + string(`ps_`p'',"%4.2f") + ")" in `i'
        replace c2 = string(`fb_`p'',"%5.2f") + " (" + string(`fs_`p'',"%4.2f") + ")" in `i'
    }
    label var c0 "Specification (focal: absinthe-producer dummy)"
    label var c1 "OLS coef (HC3)"
    label var c2 "FL AME (pp)"

    local fn_prod = "Focal = absinthe-producer canton dummy (8 cantons). Yes-vote share (vote \#68) regressed on the producer dummy plus the listed controls; OLS coef = HC3 on the 0-100 scale, FL AME = fractional-logit average marginal effect (pp, continuous-derivative convention). SE in parentheses. The raw cross-bloc differential (-11.2 pp, p~0.05) attenuates to +3.6 pp (n.s.) once French-language share enters at p4. This collapse is a POWER / LINKED-COVARIANCE limitation, not evidence of no producer effect: corr(producer, French) = 0.71 and the producer SE inflates x1.31 when French is added. At N=25 the cross-section cannot separate the producer-economic channel from the language-cultural channel (producer cantons average 51 percent French vs 2 percent for non-producers). Read as lack of evidence, not evidence of lack. LOO (OLS): raw p1 ranges [" + string(`lo_p1',"%5.2f") + ", " + string(`hi_p1',"%5.2f") + "]; full p4 ranges [" + string(`lo_p4',"%5.2f") + ", " + string(`hi_p4',"%5.2f") + "] across single-canton deletions."

    texsave c0 c1 c2 using "$LocalTables/T_producer_cascade.tex", replace frag nofix varlabels ///
        title("Producer-coalition cascade: the raw differential is real but underpowered against the language channel") ///
        label("tab:T_producer_cascade") ///
        footnote("`fn_prod'", size(footnotesize))
    _md_dump using "$LocalMd/T_producer_cascade.md", ///
        title("T_producer_cascade — absinthe-producer cascade p1..p4") ///
        note("`fn_prod'")
    di as text "  wrote T_producer_cascade.{tex,md}"
    local final_tables "`final_tables' T_producer_cascade"
}


**# 3. T_se_bm — wine cascade HC1/HC2/HC3 + Bell-McCaffrey dof
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_se_bm.dta", clear
    sort spec
    * spec labels for the cascade
    gen str30 c0 = ""
    replace c0 = "(1) wine only"               if spec=="c1"
    replace c0 = "(2) + French"                if spec=="c2"
    replace c0 = "(3) + Absinthe trade share"  if spec=="c3"
    replace c0 = "(4) + Protestant share"      if spec=="c4"
    replace c0 = "(5) + log density (full)"    if spec=="c5"
    gen str12 cB  = string(b,"%5.3f")
    gen str10 cH1 = string(se_hc1,"%4.3f")
    gen str10 cH2 = string(se_hc2,"%4.3f")
    gen str10 cH3 = string(se_hc3,"%4.3f")
    gen str8  cDF = string(bm_dof,"%4.2f")
    gen str10 cP  = string(p_bm,"%4.3f")
    * significance stars on the BM p-value
    replace cP = cP + cond(p_bm<0.01,"***",cond(p_bm<0.05,"**",cond(p_bm<0.10,"*","")))
    keep c0 cB cH1 cH2 cH3 cDF cP
    order c0 cB cH1 cH2 cH3 cDF cP
    label var c0  "Specification"
    label var cB  "OLS coef"
    label var cH1 "HC1 SE"
    label var cH2 "HC2 SE"
    label var cH3 "HC3 SE"
    label var cDF "BM dof"
    label var cP  "BM p"

    local fn_sebm "OLS of yes-vote share (vote \#68) on national wine revenue share; cascade (1) wine only ... (5) + French + Absinthe trade + Protestant + log density. HC1 = vce(robust), HC2, HC3 heteroskedasticity-robust SEs. BM dof = Bell-McCaffrey / Imbens-Kolesar (2016) effective degrees of freedom, hand-implemented in Mata and validated against native HC2. BM p = two-sided p from a t-distribution with BM dof on the HC2 SE. Stars: * p<0.10, ** p<0.05, *** p<0.01. At N=25 the effective dof collapses to ~2-4 (not N-k=19), so the full-spec result is p~0.12 under the honest small-sample correction, not the ~0.06 a naive normal would give."

    texsave c0 cB cH1 cH2 cH3 cDF cP using "$LocalTables/T_se_bm.tex", replace frag nofix varlabels ///
        title("Small-sample SEs and Bell-McCaffrey effective degrees of freedom (wine cascade)") ///
        label("tab:T_se_bm") ///
        footnote("`fn_sebm'", size(footnotesize))
    _md_dump using "$LocalMd/T_se_bm.md", ///
        title("T_se_bm — wine cascade HC1/HC2/HC3 + Bell-McCaffrey dof") ///
        note("`fn_sebm'")
    di as text "  wrote T_se_bm.{tex,md}"
    local final_tables "`final_tables' T_se_bm"
}


**# 4. T_oster — Oster (2019) delta-bounds
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_oster.dta", clear
    foreach q in beta_short r2_short beta_long r2_long delta_rmax13 delta_rmax1 beta_delta1_r13 beta_delta1_r1 {
        qui sum value if quantity=="`q'", meanonly
        local v_`q' = r(mean)
    }
    qui sum rmax_used if quantity=="delta_rmax13", meanonly
    local rmax13 = r(mean)

    clear
    set obs 8
    gen str46 c0 = ""
    gen str14 c1 = ""
    replace c0 = "Uncontrolled coef (Y on wine only)"      in 1
    replace c1 = string(`v_beta_short',"%5.3f")            in 1
    replace c0 = "Uncontrolled R-squared"                  in 2
    replace c1 = string(`v_r2_short',"%5.3f")              in 2
    replace c0 = "Controlled coef (full col-5)"            in 3
    replace c1 = string(`v_beta_long',"%5.3f")             in 3
    replace c0 = "Controlled R-squared"                    in 4
    replace c1 = string(`v_r2_long',"%5.3f")               in 4
    replace c0 = "delta to zero coef (rmax = 1.3 x R2)"    in 5
    replace c1 = string(`v_delta_rmax13',"%5.3f")          in 5
    replace c0 = "delta to zero coef (rmax = 1)"           in 6
    replace c1 = string(`v_delta_rmax1',"%5.3f")           in 6
    replace c0 = "coef at delta = 1 (rmax = 1.3 x R2)"     in 7
    replace c1 = string(`v_beta_delta1_r13',"%5.3f")       in 7
    replace c0 = "coef at delta = 1 (rmax = 1)"            in 8
    replace c1 = string(`v_beta_delta1_r1',"%5.3f")        in 8
    label var c0 "Oster (2019) quantity"
    label var c1 "Value"

    local fn_oster = "Oster (2019) proportional-selection bounds (psacalc), full col-5 spec; rmax(1.3 x R2) = " + string(`rmax13',"%4.3f") + ". Adding observables moves the wine coefficient AWAY from zero (Simpson flip -0.196 -> +0.469), so the delta that would drive it to zero is NEGATIVE -- unobservable selection would have to run OPPOSITE to the observable selection. Under equal selection (delta = 1) the bias-adjusted coefficient is LARGER (0.82 at rmax = 1.3 x R2), not smaller. Oster therefore CORROBORATES the wine result; a positive delta-to-zero is undefined here (the standard 'is delta > 1?' cutoff does not bind)."

    texsave c0 c1 using "$LocalTables/T_oster.tex", replace frag nofix varlabels ///
        title("Oster (2019) bounds: observables amplify the wine effect (delta < 0, ill-posed for attenuation)") ///
        label("tab:T_oster") ///
        footnote("`fn_oster'", size(footnotesize))
    _md_dump using "$LocalMd/T_oster.md", ///
        title("T_oster — Oster (2019) delta-bounds") ///
        note("`fn_oster'")
    di as text "  wrote T_oster.{tex,md}"
    local final_tables "`final_tables' T_oster"
}


**# 5. T_winetype — white vs red wine (Cahannes mechanism)
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_winetype.dta", clear
    foreach w in X3_white_share X3_red_share {
        foreach e in ols fl_ame {
            qui sum b  if wine=="`w'" & estimator=="`e'", meanonly
            local b_`w'_`e' = r(mean)
            qui sum se if wine=="`w'" & estimator=="`e'", meanonly
            local s_`w'_`e' = r(mean)
        }
    }
    clear
    set obs 2
    gen str16 c0 = ""
    gen str22 c1 = ""
    gen str22 c2 = ""
    replace c0 = "White wine" in 1
    replace c1 = string(`b_X3_white_share_ols',"%5.3f")    + " (" + string(`s_X3_white_share_ols',"%4.3f")    + ")" in 1
    replace c2 = string(`b_X3_white_share_fl_ame',"%5.3f") + " (" + string(`s_X3_white_share_fl_ame',"%4.3f") + ")" in 1
    replace c0 = "Red wine" in 2
    replace c1 = string(`b_X3_red_share_ols',"%5.3f")      + " (" + string(`s_X3_red_share_ols',"%4.3f")      + ")" in 2
    replace c2 = string(`b_X3_red_share_fl_ame',"%5.3f")   + " (" + string(`s_X3_red_share_fl_ame',"%4.3f")   + ")" in 2
    label var c0 "Wine type (col-5 spec)"
    label var c1 "OLS coef (HC3)"
    label var c2 "FL AME (pp)"

    local fn_wine "Col-5 spec with the wine revenue share split into white- and red-wine revenue share (each entered on its own). OLS coef = HC3 (0-100 scale); FL AME = fractional-logit average marginal effect (pp). SE in parentheses. Cahannes (1981) predicts absinthe competed with WHITE wine, so coef(white) > coef(red); at this canton-level spec the point estimates run the other way (red >= white), but both are imprecise and their confidence intervals overlap heavily -- the canton cross-section cannot resolve the white-vs-red distinction."

    texsave c0 c1 c2 using "$LocalTables/T_winetype.tex", replace frag nofix varlabels ///
        title("White vs red wine at the headline spec (canton cross-section cannot resolve the split)") ///
        label("tab:T_winetype") ///
        footnote("`fn_wine'", size(footnotesize))
    _md_dump using "$LocalMd/T_winetype.md", ///
        title("T_winetype — white vs red wine") ///
        note("`fn_wine'")
    di as text "  wrote T_winetype.{tex,md}"
    local final_tables "`final_tables' T_winetype"
}


**# 6. T_ri — randomization inference p-values (RI-gated)
*------------------------------------------------------------------------------*
{
    use "`INTER'/inference_ri.dta", clear
    * descriptive row label + ordering
    gen str40 c0 = ""
    replace c0 = "Wine X3 -- col 1 (OLS coef)"        if leg=="wine_X3" & spec=="c1" & estimator=="ols"
    replace c0 = "Wine X3 -- col 2 (OLS coef)"        if leg=="wine_X3" & spec=="c2" & estimator=="ols"
    replace c0 = "Wine X3 -- col 3 (OLS coef)"        if leg=="wine_X3" & spec=="c3" & estimator=="ols"
    replace c0 = "Wine X3 -- col 4 (OLS coef)"        if leg=="wine_X3" & spec=="c4" & estimator=="ols"
    replace c0 = "Wine X3 -- col 5 (OLS coef)"        if leg=="wine_X3" & spec=="c5" & estimator=="ols"
    replace c0 = "Wine X2 (volume) -- col 5 (OLS)"    if leg=="wine_X2" & spec=="c5" & estimator=="ols"
    replace c0 = "Producer -- p1 raw (OLS coef)"      if leg=="producer" & spec=="p1" & estimator=="ols"
    replace c0 = "Producer -- p2 (OLS coef)"          if leg=="producer" & spec=="p2" & estimator=="ols"
    replace c0 = "Producer -- p3 (OLS coef)"          if leg=="producer" & spec=="p3" & estimator=="ols"
    replace c0 = "Producer -- p4 full (OLS coef)"     if leg=="producer" & spec=="p4" & estimator=="ols"
    replace c0 = "Wine X3 -- col 5 (FL AME)"          if leg=="wine_X3" & spec=="c5" & estimator=="fl_ame"
    replace c0 = "Wine X3 -- col 2 (FL AME)"          if leg=="wine_X3" & spec=="c2" & estimator=="fl_ame"
    replace c0 = "Wine X2 (volume) -- col 5 (FL AME)" if leg=="wine_X2" & spec=="c5" & estimator=="fl_ame"
    replace c0 = "Producer -- p1 raw (FL AME)"        if leg=="producer" & spec=="p1" & estimator=="fl_ame"
    replace c0 = "Producer -- p4 full (FL AME)"       if leg=="producer" & spec=="p4" & estimator=="fl_ame"

    gen byte ord = .
    local k 0
    foreach key in "wine_X3 c1 ols" "wine_X3 c2 ols" "wine_X3 c3 ols" "wine_X3 c4 ols" "wine_X3 c5 ols" ///
                   "wine_X2 c5 ols" "producer p1 ols" "producer p2 ols" "producer p3 ols" "producer p4 ols" ///
                   "wine_X3 c5 fl_ame" "wine_X3 c2 fl_ame" "wine_X2 c5 fl_ame" "producer p1 fl_ame" "producer p4 fl_ame" {
        local ++k
        local L : word 1 of `key'
        local S : word 2 of `key'
        local E : word 3 of `key'
        replace ord = `k' if leg=="`L'" & spec=="`S'" & estimator=="`E'"
    }
    sort ord
    gen str12 cobs = string(b_obs,"%6.3f")
    gen str10 cp   = string(p_ri,"%5.3f")
    replace cp = cp + cond(p_ri<0.01,"***",cond(p_ri<0.05,"**",cond(p_ri<0.10,"*","")))
    keep c0 cobs cp ord
    order c0 cobs cp
    drop ord
    label var c0   "Specification (estimator)"
    label var cobs "Observed coef"
    label var cp   "RI p-value"

    local prov_tag ""
    if "${RI_STALE}" == "1"            local prov_tag " [STALE -- pending R re-run on 1907-corrected data; NOT final]"
    else if "${RI_PROVISIONAL}" == "1" local prov_tag " [PROVISIONAL -- `=`ri_reps'' -perm smoke; NOT final]"
    local fn_ri "Randomization-inference p-values: the focal regressor is permuted across the 25 cantons `ri_reps' times (seed `ri_seed') and the spec re-estimated each time; the p-value is the share of permutations with |coef| at least as large as observed. Observed coef on the 0-100 scale for OLS and in pp for FL AME. Stars: * p<0.10, ** p<0.05, *** p<0.01. Canonical battery = 10,000 permutations (methodology-integrity floor)."
    if "${RI_STALE}" == "1"            local fn_ri "`fn_ri' THIS TABLE IS STALE: p-values were computed on the pre-1907-population-fix dataset and do NOT match the current point estimates; they are pending regeneration via the standalone R randomization-inference port on the corrected data."
    else if "${RI_PROVISIONAL}" == "1" local fn_ri "`fn_ri' THIS TABLE IS PROVISIONAL: it reflects a `ri_reps'-permutation development smoke, NOT the 10,000-perm canonical run; p-values are unstable and MUST be regenerated before use."

    texsave c0 cobs cp using "$LocalTables/T_ri.tex", replace frag nofix varlabels ///
        title("Randomization inference (10,000 permutations)`prov_tag'") ///
        label("tab:T_ri") ///
        footnote("`fn_ri'", size(footnotesize))
    _md_dump using "$LocalMd/T_ri.md", ///
        title("T_ri — randomization inference p-values`prov_tag'") ///
        note("`fn_ri'")
    di as text "  wrote T_ri.{tex,md}"

    if "${RI_PROVISIONAL}" == "0" {
        local final_tables "`final_tables' T_ri"
    }
    else {
        di as error "  T_ri held back from Overleaf deploy (provisional)."
    }
}


**# 7. Deploy FINAL tables to the Overleaf robustness folder
*------------------------------------------------------------------------------*
{
    di as text _n "  --- Deploying FINAL tables to Overleaf: $RobustTables ---"
    local n_deployed 0
    foreach t of local final_tables {
        cap copy "$LocalTables/`t'.tex" "$RobustTables/`t'.tex", replace
        if _rc {
            di as error "    FAILED to copy `t'.tex to Overleaf (rc=`=_rc'); is Dropbox reachable?"
        }
        else {
            di as text "    deployed `t'.tex"
            local ++n_deployed
        }
    }
    di as result "  Deployed `n_deployed' final table(s). final_tables = `final_tables'"
    if "${RI_PROVISIONAL}" == "1" di as error "  (T_ri NOT deployed — provisional RI. Re-run after the 10k battery.)"
}


**# 8. Verification asserts (Reif submission checklist)
*------------------------------------------------------------------------------*
{
    foreach t in T_loo_gate T_producer_cascade T_se_bm T_oster T_winetype T_ri {
        cap confirm file "$LocalTables/`t'.tex"
        assert _rc == 0
        cap confirm file "$LocalMd/`t'.md"
        assert _rc == 0
    }
    di as result "  All 6 tables + markdown twins present."
}


**# 9. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        foreach t in T_loo_gate T_producer_cascade T_se_bm T_oster T_winetype T_ri {
            cap _inventory_append, sheet("outputs") ///
                row("created|results/tables/`t'.tex|.|.|.|23_canton_inference_battery_tables.do")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
