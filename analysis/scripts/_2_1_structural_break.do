/*==============================================================================
 _2_1_structural_break.do  —  Independent re-run of the C.16 Quandt-Andrews +
 Chow structural-break test on the wine/potato producer-price ratio.

 Purpose:  Produce draft-ready paper artifacts for §2.1:
           1. PNG + PDF figure: time series 1830-1915 with vertical lines at
              1875 (Banerjee 2010 phylloxera onset) and the data-estimated
              break year (Q-A sup-Wald).
           2. LaTeX table (.tex) with both test statistics for direct \input.
           3. Markdown explainer with primer + interpretation.

 Input:    processed/intermediate/h2a_substrate_prices_long.dta
 Outputs (auto-deployed direct-to-Overleaf to keep stale-free):
           $OverleafFigDir/f11_wine_potato_ratio_breaks.{png,pdf}
           $OverleafTabDir/t27_quandt_andrews_structural_break.tex
           output/notes/2026-05-22_structural_break_primer.md  (hand-authored)
 Author:   §2.1 dispatch (2026-05-22)
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

* Ensure libraries available (texsave)
cap which texsave
if _rc {
    adopath ++ "$MyProject/scripts/libraries/stata"
}

* --- Overleaf direct-deploy paths (Dropbox-synced) ---
* Output goes straight into the live Overleaf project to eliminate the
* local→Overleaf staleness window.  The local results/ tree is intentionally
* NOT used here (matches the workshop-pipeline convention where
* $WorkshopTables writes directly to Overleaf Tables/Workshop_draft/).
global OverleafFigDir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/files/fig/main"
global OverleafTabDir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"
cap mkdir "$OverleafFigDir"
cap mkdir "$OverleafTabDir"


**# 1. Load + verify
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta"
    if _rc {
        di as error "  Source missing: processed/intermediate/h2a_substrate_prices_long.dta"
        di as error "  Run scripts/02_load_h2a.do (or equivalent ingest step) first."
        error 601
    }
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear
    keep if inrange(year, 1830, 1915)
    tsset year

    qui count
    local nobs = r(N)
    qui count if missing(wine_potato_ratio)
    local nmiss = r(N)
    assert `nmiss' == 0
    di as text "  Window 1830-1915: " `nobs' " yearly obs, " `nmiss' " missing wine_potato_ratio."
}


**# 2. Tests
*------------------------------------------------------------------------------*
{
    * (1) Quandt-Andrews sup-Wald, unknown break, trim 15% from each end
    qui reg wine_potato_ratio year
    estat sbsingle, trim(15) swald
    local sup_wald      : di %7.3f r(chi2_swald)
    local sup_p_raw      = r(p_swald)
    local sup_df         = r(df)
    local break_year     = real("`r(breakdate)'")
    local ltrim_yr       = real("`r(ltrim)'")
    local rtrim_yr       = real("`r(rtrim)'")
    if `sup_p_raw' < 0.0001 {
        local sup_p_tbl     "< 0.0001"
        local sup_p_prose   "p < 0.0001"
    }
    else {
        local sup_p_tbl     : di %6.4f `sup_p_raw'
        local sup_p_prose = "p = " + string(`sup_p_raw', "%6.4f")
    }

    * (2) Chow Wald at known break 1875 (Banerjee et al. 2010)
    qui reg wine_potato_ratio year
    estat sbknown, break(1875)
    local chow_chi2     : di %6.3f r(chi2)
    local chow_p        : di %6.4f r(p)
    local chow_df        = r(df)

    di as text _n "{hline 78}"
    di as text "  STRUCTURAL-BREAK RESULTS (wine/potato ratio, 1830-1915, N=`nobs')"
    di as text "{hline 78}"
    di as text "  Quandt-Andrews Sup-Wald: W = `sup_wald' (df=`sup_df'), `sup_p_prose'"
    di as text "  Estimated break year   : `break_year'  (Q-A candidate window `ltrim_yr'-`rtrim_yr')"
    di as text "  Chow Wald at 1875      : chi2(`chow_df') = `chow_chi2', p = `chow_p'"
    di as text "{hline 78}"
}


**# 2b. HAC robustness (Newey-West, lag = 4) on both tests
*------------------------------------------------------------------------------*
* Newey-West lag = 4 (one above the plug-in floor(4*(T/100)^(2/9)) = 3 for T=86).
* Implementation: dummy + interaction representation of the break test.  The
* HAC matrix is computed from the FULL residual sequence, preserving the
* time-series autocorrelation structure.  HAC-robust Wald = q * F (exact for
* robust F; here q=2 for {intercept, slope} restrictions).  Andrews 1993
* sup-Wald asymptotic critical values still apply (Andrews' theory governs
* maxima of Wald-type statistics regardless of OLS/robust SE choice):
*   q=2, pi=0.15 : 10% CV = 9.84, 5% CV = 11.79, 1% CV = 16.45.
*------------------------------------------------------------------------------*
{
    local nwlag = 4

    *--- 2b.1 Chow at 1875 with HAC SEs ---
    qui gen byte D1875 = (year >= 1875)
    qui gen double year_x_D1875 = year * D1875
    qui newey wine_potato_ratio year D1875 year_x_D1875, lag(`nwlag')
    qui test D1875 year_x_D1875
    local chow_hac_F_raw  = r(F)
    local chow_hac_df1    = r(df)
    local chow_hac_df2    = r(df_r)
    local chow_hac_p_raw  = r(p)
    local chow_hac_F     : di %7.3f `chow_hac_F_raw'
    if `chow_hac_p_raw' < 0.0001 {
        local chow_hac_p_tbl  "< 0.0001"
    }
    else {
        local chow_hac_p_tbl  : di %6.4f `chow_hac_p_raw'
    }
    * Wald = q*F exactly for robust SEs
    local chow_hac_wald_val = `chow_hac_df1' * `chow_hac_F_raw'
    local chow_hac_wald  : di %7.3f `chow_hac_wald_val'
    drop D1875 year_x_D1875

    *--- 2b.2 Q-A sup-Wald HAC profile (manual loop over candidate years) ---
    gen qa_wald_hac = .
    forvalues cy = `=`ltrim_yr''/`=`rtrim_yr'' {
        cap drop _Dcy _yearXDcy
        qui gen byte _Dcy = (year >= `cy')
        qui gen double _yearXDcy = year * _Dcy
        qui newey wine_potato_ratio year _Dcy _yearXDcy, lag(`nwlag')
        qui test _Dcy _yearXDcy
        qui replace qa_wald_hac = r(df) * r(F) if year == `cy'
        drop _Dcy _yearXDcy
    }

    *--- 2b.3 Locate the HAC supremum and report it ---
    qui sum qa_wald_hac
    local sup_hac_wald_val = r(max)
    preserve
        qui keep if !missing(qa_wald_hac)
        gsort -qa_wald_hac
        local sup_hac_break = year[1]
    restore
    local sup_hac_wald  : di %7.3f `sup_hac_wald_val'

    *--- 2b.3b HAC Wald at the OLS-estimated break year (for table footnote) ---
    * Quantifies the "secondary peak near 1887" claim so the table is verifiable
    * without reading it off the figure.
    qui sum qa_wald_hac if year == `break_year', meanonly
    local hac_at_olsbreak : di %6.2f r(mean)
    di as text "  Q-A sup-Wald (HAC) at OLS break `break_year': W = `hac_at_olsbreak'"

    * Significance tier vs Andrews 1993 CVs (q=2, pi=0.15)
    if `sup_hac_wald_val' >= 16.45 {
        local sup_hac_p_tbl  "< 0.01"
    }
    else if `sup_hac_wald_val' >= 11.79 {
        local sup_hac_p_tbl  "< 0.05"
    }
    else if `sup_hac_wald_val' >= 9.84 {
        local sup_hac_p_tbl  "< 0.10"
    }
    else {
        local sup_hac_p_tbl  "n.s."
    }

    di as text _n "{hline 78}"
    di as text "  HAC ROBUSTNESS (Newey-West, lag = `nwlag')"
    di as text "{hline 78}"
    di as text "  Chow Wald at 1875 (HAC): Wald = `chow_hac_wald'  (F(`chow_hac_df1',`chow_hac_df2') = `chow_hac_F', p = `chow_hac_p_tbl')"
    di as text "  Q-A sup-Wald (HAC)     : W = `sup_hac_wald'   at year `sup_hac_break'  (`sup_hac_p_tbl' vs Andrews 1993)"
    di as text "{hline 78}"
}


**# 3. Figure: two-panel diagnostic (series+fits / Q-A profile)
*------------------------------------------------------------------------------*
* TOP:    raw series + pre/post OLS regime fits + vertical break markers.
*         The two regression lines make the structural break visible.
* BOTTOM: full Chow-Wald profile across all candidate break years in the
*         trim window (1843-1903), with horizontal Andrews-1993 sup-Wald
*         5% critical value (CV = 11.79 for q=2 restrictions, pi=0.15 trim).
*         The profile peaks at `break_year' -- this peak IS the sup-Wald
*         test statistic in section 2.
*------------------------------------------------------------------------------*
{
    *--- 3.1 Pre/post regime fits for top panel ---
    qui reg wine_potato_ratio year if year < `break_year'
    predict prefit  if year < `break_year'
    qui reg wine_potato_ratio year if year >= `break_year'
    predict postfit if year >= `break_year'

    *--- 3.2 Compute Q-A statistic profile by manual Chow-Wald loop ---
    * Restricted (no-break) full-sample SSR
    qui reg wine_potato_ratio year
    local ssr_r_full = e(rss)
    local n_total    = e(N)

    gen qa_wald = .
    forvalues cy = `=`ltrim_yr''/`=`rtrim_yr'' {
        qui reg wine_potato_ratio year if year < `cy'
        local ssr1 = e(rss)
        qui reg wine_potato_ratio year if year >= `cy'
        local ssr2 = e(rss)
        local ssr_u = `ssr1' + `ssr2'
        * Chow-Wald = 2 * F, F = ((SSR_R-SSR_U)/2) / (SSR_U/(n-4)) for k=2 params
        local f_stat = ((`ssr_r_full' - `ssr_u') / 2) / (`ssr_u' / (`n_total' - 4))
        qui replace qa_wald = 2 * `f_stat' if year == `cy'
    }

    * Sanity check: max of qa_wald should approximately equal sup_wald from section 2
    qui sum qa_wald
    local profile_max     : di %7.3f r(max)
    di as text "  Profile max (Wald) = " "`profile_max'" "  vs section-2 sup-Wald = " "`sup_wald'"

    *--- 3.3 Top panel: time series + regime fits + markers ---
    qui sum wine_potato_ratio
    local y_top  = r(max) * 0.97
    local y_bot  = r(min) + (r(max)-r(min)) * 0.05

    twoway (line wine_potato_ratio year, lcolor(black) lwidth(medthick)) ///
           (line prefit  year, lcolor(red) lpattern(solid) lwidth(medium)) ///
           (line postfit year, lcolor(red) lpattern(solid) lwidth(medium)) ///
        , xline(1875,         lcolor(gs6) lpattern(dash)         lwidth(thin)) ///
          xline(`break_year', lcolor(gs6) lpattern(longdash_dot) lwidth(thin)) ///
          text(`y_bot' 1875         "1875 Banerjee"   "(canonical)", place(w) size(vsmall) color(gs4)) ///
          text(`y_top' `break_year' "Q-A `break_year'" "(estimated)", place(e) size(vsmall) color(gs4)) ///
          title("(a) Wine/Potato producer-price ratio with regime fits", size(small)) ///
          subtitle("Black: observed series; Red: OLS linear trend per regime", size(vsmall)) ///
          xtitle("") ytitle("Ratio (indices, 1914 = 100)", size(small)) ///
          xlabel(1830(20)1910, format(%9.0f)) ///
          ylabel(, angle(horizontal) format(%4.1f)) ///
          graphregion(color(white)) bgcolor(white) ///
          legend(off) ///
          name(f11_top, replace)

    *--- 3.4 Bottom panel: Q-A profile (OLS + HAC overlay) with CV line ---
    * Andrews 1993 sup-Wald 5% asymptotic CV: q=2 restrictions, pi=0.15 trim
    local cv5 = 11.79

    * Compute y-axis upper bound from the maximum of either profile
    qui sum qa_wald
    local ymax_ols = r(max)
    qui sum qa_wald_hac
    local ymax_hac = r(max)
    local ymax     = max(`ymax_ols', `ymax_hac')
    local yupper   = ceil(`ymax' / 10) * 10  // round up to nearest 10

    twoway (line qa_wald     year, lcolor(navy)     lwidth(medthick) lpattern(solid)) ///
           (line qa_wald_hac year, lcolor(cranberry) lwidth(medium)  lpattern(longdash)), ///
        xline(1875,         lcolor(gs6) lpattern(dash)         lwidth(thin)) ///
        xline(`break_year', lcolor(gs6) lpattern(longdash_dot) lwidth(thin)) ///
        yline(`cv5',        lcolor(red) lpattern(dot)          lwidth(medium)) ///
        title("(b) Quandt-Andrews sup-Wald profile (peak at `break_year')", size(small)) ///
        subtitle("Chow-Wald at each candidate break year (trim 15%, 1843-1903)", size(vsmall)) ///
        xtitle("Candidate break year", size(small)) ytitle("Chow-Wald statistic", size(small)) ///
        xlabel(1830(20)1910, format(%9.0f)) ///
        ylabel(0(10)`yupper', angle(horizontal) format(%4.1f)) ///
        text(`cv5' 1832 "5% sup-Wald CV (Andrews 1993)", place(ne) size(vsmall) color(red)) ///
        legend(order(1 "OLS Wald" 2 "Newey-West HAC, lag=`nwlag'") ///
               cols(1) size(vsmall) ring(0) position(11) region(lcolor(none))) ///
        graphregion(color(white)) bgcolor(white) ///
        name(f11_bot, replace)

    *--- 3.5 Combine and direct-deploy to Overleaf ---
    graph combine f11_top f11_bot, ///
        cols(1) ///
        graphregion(color(white)) ///
        xsize(7) ysize(8) ///
        name(f11_combined, replace)

    graph export "$OverleafFigDir/f11_wine_potato_ratio_breaks.png", ///
        width(2400) replace
    graph export "$OverleafFigDir/f11_wine_potato_ratio_breaks.pdf", ///
        replace
    di as text "  Wrote f11_wine_potato_ratio_breaks.png + .pdf (2-panel) -> Overleaf files/fig/main/"
}


**# 4. LaTeX table — hand-build via texsave (4 rows: OLS + HAC for each test)
*------------------------------------------------------------------------------*
* 6 columns: Test | SE | Statistic | df | p-value | Break date.
* HAC rows report Newey-West (lag=`nwlag') Wald = q*F; p-value is the Andrews
* 1993 significance tier (Hansen 1997 p-value not directly computable without
* simulation).
*------------------------------------------------------------------------------*
{
    * Cache test results before preserve (since preserve clears them via use)
    local R1_test "Quandt-Andrews Sup-Wald"
    local R1_se   "OLS"
    local R1_stat "`sup_wald'"
    local R1_df   "`sup_df'"
    local R1_p    "`sup_p_tbl'"
    local R1_brk  "`break_year' (estimated)"

    local R2_test "Quandt-Andrews Sup-Wald"
    local R2_se   "HAC(`nwlag')"
    local R2_stat "`sup_hac_wald'"
    local R2_df    = 2
    local R2_p    "`sup_hac_p_tbl'"
    local R2_brk  "`sup_hac_break' (estimated)"

    local R3_test "Chow Wald at 1875"
    local R3_se   "OLS"
    local R3_stat "`chow_chi2'"
    local R3_df   "`chow_df'"
    local R3_p    "`chow_p'"
    local R3_brk  "1875 (fixed; Banerjee 2010)"

    local R4_test "Chow Wald at 1875"
    local R4_se   "HAC(`nwlag')"
    local R4_stat "`chow_hac_wald'"
    local R4_df   "`chow_hac_df1'"
    local R4_p    "`chow_hac_p_tbl'"
    local R4_brk  "1875 (fixed; Banerjee 2010)"

    preserve
        clear
        set obs 4
        gen str40  Test       = ""
        gen str10  SE         = ""
        gen str10  Statistic  = ""
        gen byte   DF         = .
        gen str10  Pvalue     = ""
        gen str30  BreakDate  = ""

        forvalues i = 1/4 {
            replace Test      = "`R`i'_test'" in `i'
            replace SE        = "`R`i'_se'"   in `i'
            replace Statistic = "`R`i'_stat'" in `i'
            replace DF        = `R`i'_df'     in `i'
            replace Pvalue    = "`R`i'_p'"    in `i'
            replace BreakDate = "`R`i'_brk'"  in `i'
        }

        label var Test       "Test"
        label var SE         "SE"
        label var Statistic  "Statistic"
        label var DF         "df"
        label var Pvalue     "p-value"
        label var BreakDate  "Break date"

        texsave Test SE Statistic DF Pvalue BreakDate ///
            using "$OverleafTabDir/t27_quandt_andrews_structural_break.tex", ///
            replace frag varlabels ///
            align(llrrrl) ///
            title("Structural-break tests on the wine/potato producer-price ratio (1830-1915, N=`nobs')") ///
            label("tab:t27_struct_break") ///
            footnote("OLS regression of the wine/potato producer-price ratio on a linear time trend; null hypothesis: no structural break in intercept or slope. Test statistic is Wald = q*F with q=2 (intercept and slope restrictions). The Quandt-Andrews supremum-Wald (Andrews 1993) searches all candidate break years in the trim window `ltrim_yr'-`rtrim_yr'; the Chow Wald test fixes the break at 1875 (Banerjee et al. 2010 phylloxera-arrival year for Switzerland). HAC rows use Newey-West (1987) with `nwlag' lags (one above the plug-in value floor(4*(T/100)^(2/9))=3 for T=`nobs'); HAC p-values for the Q-A row are reported as significance tiers against Andrews 1993 asymptotic critical values (5% CV = 11.79, 1% CV = 16.45). The HAC profile's supremum falls at `sup_hac_break', but attains a secondary maximum of `hac_at_olsbreak' at the OLS-estimated break year `break_year' (comparable to the OLS supremum, `sup_wald'), so the existence of the regime change is robust to the SE specification while its exact location is OLS-primary. Source: HSSO H.2a producer-price indexes (Ritzmann 1990; Swiss Farmers' Secretariat 1922-1984).", size(footnotesize))
    restore
    di as text "  Wrote t27_quandt_andrews_structural_break.tex (4 rows: OLS + HAC) -> Overleaf"
}


**# 5. Explainer markdown (primer + interpretation) — written separately
*------------------------------------------------------------------------------*
* The primer markdown is hand-authored at
*   analysis/output/notes/2026-05-22_structural_break_primer.md
* and committed alongside this script.  Embedding the prose in file_write here
* hit a Stata-parser issue: literal `\"` in the prose triggered "invalid syntax"
* mid-write because Stata uses compound quotes (`"..."') for embedded quotes,
* not C-style backslash-escapes.  Cleaner separation: numerics computed here,
* prose maintained as a static markdown file.
{
    di as text "  (primer markdown is static, hand-authored — see"
    di as text "   analysis/output/notes/2026-05-22_structural_break_primer.md)"
}


**# 6. Post-credits (optional inventory append)
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        cap _inventory_append, sheet("outputs") ///
            row("created|results/figures/f11_wine_potato_ratio_breaks.png|.|.|.|_2_1_structural_break.do")
        cap _inventory_append, sheet("outputs") ///
            row("created|results/tables/t27_quandt_andrews_structural_break.tex|.|.|.|_2_1_structural_break.do")
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
