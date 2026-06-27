/*==============================================================================
 16_workshop_figures.do
 Purpose:  Build Figures 1 and 2 for the workshop draft (monochrome, paper-bound).
 Input:    $MyProject/processed/cohort_1908_workshop.dta
 Output:   $WorkshopFigures/F1_petition_protestant.pdf + .png
           $WorkshopFigures/F2_canton_bars.pdf + .png
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

global WorkshopFigures "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Figures"


**# 1. Load workshop cohort
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  cohort_1908_workshop.dta missing.  Run 08_workshop + 09_workshop first."
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear
    assert c(N) == 25
}


**# 2. Figure 1 — Petition rate vs Protestant share (monochrome scatter)
*------------------------------------------------------------------------------*
{
    cap mkdir "$WorkshopFigures"

    cap drop lang_group
    * Default: German.  Then override for French (6 + var = 7 args, safe) and Italian.
    * (German = 19 cantons; the explicit positive-list would exceed inlist's 10-arg
    * string-arg cap.  Default-then-override is cleaner than chained OR-inlists.)
    gen byte lang_group = 1
    replace lang_group = 2 if inlist(canton_iso, "FR","VD","NE","GE","VS","JU")
    replace lang_group = 3 if canton_iso == "TI"
    cap label drop lang_lbl
    label define lang_lbl 1 "German" 2 "French" 3 "Italian"
    label values lang_group lang_lbl

    qui count if lang_group == 1
    di as text "  German cantons:  N=" r(N)
    qui count if lang_group == 2
    di as text "  French cantons:  N=" r(N)
    qui count if lang_group == 3
    di as text "  Italian cantons: N=" r(N)

    twoway ///
        (scatter pet_per_eligible cov3 if lang_group==1, ///
            msymbol(circle_hollow) mcolor(black) msize(medium) ///
            mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
        (scatter pet_per_eligible cov3 if lang_group==2, ///
            msymbol(square) mcolor(black) msize(medium) mfcolor(black) ///
            mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
        (scatter pet_per_eligible cov3 if lang_group==3, ///
            msymbol(triangle) mcolor(black) msize(medium) mfcolor(black) ///
            mlabel(canton_iso) mlabsize(vsmall) mlabcolor(black) mlabposition(3)) ///
        (lfit pet_per_eligible cov3, lcolor(black) lpattern(solid) lwidth(medium)), ///
        xtitle("Protestant share of Christian population (%)") ///
        ytitle("Petition signatures per 100 eligible voters") ///
        xlabel(0(20)100) ylabel(0(10)50) ///
        legend(order(1 "German" 2 "French" 3 "Italian" 4 "Linear fit") ///
               cols(4) size(vsmall) position(6) region(lwidth(none))) ///
        graphregion(color(white)) bgcolor(white) ///
        name(F1_petition_protestant, replace)

    graph export "$WorkshopFigures/F1_petition_protestant.pdf", replace
    graph export "$WorkshopFigures/F1_petition_protestant.png", replace width(2000)
    di as text "  Wrote F1_petition_protestant.{pdf,png}"
}


**# 3. Figure 2 — Vote and petition rates by canton (grouped bars)
*------------------------------------------------------------------------------*
{
    cap drop sort_order
    gen byte sort_order = .
    local i = 0
    * German cantons (alphabetical)
    foreach c in AG AI AR BE BL BS GL GR LU NW OW SG SH SO SZ TG UR ZG ZH {
        local i = `i' + 1
        replace sort_order = `i' if canton_iso == "`c'"
    }
    * French cantons (alphabetical)
    foreach c in FR GE NE VD VS {
        local i = `i' + 1
        replace sort_order = `i' if canton_iso == "`c'"
    }
    * Italian
    foreach c in TI {
        local i = `i' + 1
        replace sort_order = `i' if canton_iso == "`c'"
    }

    assert !missing(sort_order)
    qui sum sort_order
    di as text "  Canton sort order: 1 to " r(max) " (German | French | Italian clusters)"

    graph bar (asis) Y1 pet_per_eligible, ///
        over(canton_iso, sort(sort_order) label(angle(45) labsize(vsmall))) ///
        bar(1, color(gs6) fcolor(gs6)) ///
        bar(2, color(black) fcolor(black) fintensity(50) lpattern(solid)) ///
        legend(order(1 "Yes-vote, Vote #68 (%)" 2 "Petition signatures per 100 eligible (%)") ///
               cols(2) size(vsmall) position(6) region(lwidth(none))) ///
        ytitle("Percent") ylabel(0(20)100) ///
        note("Cantons grouped by language cluster (German | French | Italian).", size(vsmall)) ///
        graphregion(color(white)) bgcolor(white) ///
        name(F2_canton_bars, replace)

    graph export "$WorkshopFigures/F2_canton_bars.pdf", replace
    graph export "$WorkshopFigures/F2_canton_bars.png", replace width(2400)
    di as text "  Wrote F2_canton_bars.{pdf,png}"
}


**# 4. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        di as text "  (inventory append: post-credits structure ready)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
