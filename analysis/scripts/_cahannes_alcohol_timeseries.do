/*==============================================================================
 _cahannes_alcohol_timeseries.do  —  Swiss per-capita alcohol consumption by
 beverage type, 1880-1979 (the paper's "Figure 1").

 Purpose:  Reconstruct the Cahannes/Muster (1981) Swiss alcohol-consumption
           time series as a publication figure. The draft (Brainstorm-Absinthe
           docs, Draft 1.3 line 164) carries this as [FIGURE 1 PLACEHOLDER]
           with a full caption at line 165 but no built asset. This script
           builds it from the transcribed source table.

 Input:    $Absinthe1Data/original/1981CahannesTableTranscribed.csv
           (E. Muster, "Zahlen und Fakten zu Alkohol- und Drogenproblemen",
            Lausanne: SFA, 1981; transcribed table reported in Cahannes 1981 p.41)

 Output:   Direct-deployed to the live Overleaf project (Dropbox-synced) to
           eliminate the local->Overleaf staleness window (F11 pattern):
           $OverleafFigDir/f01_alcohol_consumption_cahannes.{png,pdf}

 Provenance recipe: Obsidian vault note
   C:/Users/jensenn/Research/Obsidian/Absinthe-Obsidian/cahannes_timeseries.md

 Convention: the source data are PERIOD AVERAGES (e.g. 1903/1912). Each bin is
   plotted at its MIDPOINT year (e.g. 1907.5). Single-year rows (1976-1979)
   plot at the stated year. State this convention in the figure caption.

 Units caveat: the four beverage lines are in EFFECTIVE LITRES of beverage per
   capita; the dashed total is in LITRES OF 100% ALCOHOL per adult (15+). The
   original Muster/Cahannes table juxtaposes both measures, so plotting them
   together is faithful to the source, but the two are different unit systems.

 Author:   Figure-1 reconstruction (2026-06-03)
==============================================================================*/

version 19

* Batch/independent-run safety: suppress graph window (graph export still writes)
set graphics off

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}
cap assert !mi("$Absinthe1Data")
if _rc {
    di as error "Error: \$Absinthe1Data must be set in your Stata profile"
    error 9
}

* --- Overleaf direct-deploy path (Dropbox-synced) ---
* Writes straight into the live Overleaf project (same convention as F11 /
* _2_1_structural_break.do) so re-running can never leave a stale deployed copy.
global OverleafFigDir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/files/fig/main"
cap mkdir "$OverleafFigDir"


**# 1. Import + parse the transcribed source table
*------------------------------------------------------------------------------*
{
    local src "$Absinthe1Data/original/1981CahannesTableTranscribed.csv"
    cap confirm file "`src'"
    if _rc {
        di as error "  Source missing: `src'"
        error 601
    }

    * Import all columns as string (footer rows have text in col 1, blanks
    * elsewhere); use positional names so header sanitisation can't surprise us.
    import delimited using "`src'", varnames(nonames) stringcols(_all) clear
    rename (v1 v2 v3 v4 v5 v6 v7) ///
        (period wine_s beer_s cider_s spirits_s total100_s total100adult_s)

    * Drop the header row (row 1) and any footer prose (source line, caption
    * fragment). Keep only rows whose period field starts with 4 digits.
    drop in 1
    keep if regexm(period, "^[0-9][0-9][0-9][0-9]")

    * Destring the numeric columns (force: any stray non-numeric -> missing,
    * but the footer is already gone so nothing legitimate is lost).
    destring wine_s beer_s cider_s spirits_s total100_s total100adult_s, ///
        gen(wine beer cider spirits total100 total100adult) force
    drop *_s

    * Midpoint year for plotting. Period is either "YYYY/YYYY" or "YYYY".
    gen byte has_slash = strpos(period, "/") > 0
    gen double yr1 = real(substr(period, 1, 4))
    gen double yr2 = real(substr(period, strpos(period, "/") + 1, 4)) if has_slash
    gen double year_mid = .
    replace year_mid = (yr1 + yr2) / 2 if has_slash
    replace year_mid = yr1            if !has_slash
    drop has_slash yr1 yr2

    label var wine          "Wine (effective L/capita)"
    label var beer          "Beer (effective L/capita)"
    label var cider         "Cider (effective L/capita)"
    label var spirits       "Distilled spirits (effective L/capita)"
    label var total100      "Total at 100% alcohol (L/capita, all pop.)"
    label var total100adult "Total at 100% alcohol (L/adult 15+)"
    label var year_mid      "Year (midpoint of averaging period)"

    * Integrity checks: 17 data rows, no missing in the plotted series.
    qui count
    assert r(N) == 17
    foreach v in wine beer cider spirits total100adult year_mid {
        qui count if missing(`v')
        assert r(N) == 0
    }

    * Console table for verification (matches vault-note layout)
    di as text _n "{hline 70}"
    di as text "  Cahannes/Muster 1981 — Swiss per-capita alcohol consumption"
    di as text "{hline 70}"
    list period year_mid wine beer cider spirits total100adult, ///
        sep(0) noobs divider abbreviate(20)
}


**# 2. Build synthetic war-band rectangles for shading
*------------------------------------------------------------------------------*
* Vertical shaded bands (WWI 1914-1918, WWII 1939-1945) need >=2 obs each to
* form an rarea. We append 4 helper obs carrying their own x/low/high coords;
* they have missing year_mid + beverage values, so the line series ignore them.
{
    local N0 = _N
    set obs `=`N0' + 4'
    gen double bx  = .
    gen double blo = .
    gen double bhi = .
    local r1 = `N0' + 1
    local r2 = `N0' + 2
    local r3 = `N0' + 3
    local r4 = `N0' + 4
    replace bx = 1914 in `r1'
    replace bx = 1918 in `r2'
    replace bx = 1939 in `r3'
    replace bx = 1945 in `r4'
    replace blo = 0   in `r1'/`r4'
    replace bhi = 100 in `r1'/`r4'
}


**# 3. Figure
*------------------------------------------------------------------------------*
{
    twoway ///
        (rarea blo bhi bx if inrange(bx, 1914, 1918), color(gs14)) ///
        (rarea blo bhi bx if inrange(bx, 1939, 1945), color(gs14)) ///
        (line wine          year_mid, lcolor("139 26 26") lwidth(medthick) lpattern(solid) msymbol(O) msize(small) mcolor("139 26 26")) ///
        (line beer          year_mid, lcolor("200 134 10") lwidth(medthick) lpattern(solid) msymbol(S) msize(small) mcolor("200 134 10")) ///
        (line cider         year_mid, lcolor("58 107 71") lwidth(medthick) lpattern(solid) msymbol(T) msize(small) mcolor("58 107 71")) ///
        (line spirits       year_mid, lcolor("43 76 126") lwidth(medthick) lpattern(solid) msymbol(D) msize(small) mcolor("43 76 126")) ///
        (line total100adult year_mid, lcolor("80 80 80") lwidth(medthick) lpattern(dash) msymbol(X) msize(small) mcolor("80 80 80")) ///
        , ///
        xline(1908, lpattern(dot) lcolor(black) lwidth(thin)) ///
        text(96 1908 "1908 absinthe ban", place(e) size(vsmall) color(black) orientation(vertical)) ///
        ytitle("Litres per capita", size(medsmall)) ///
        xtitle("Year (midpoint of averaging period)", size(medsmall)) ///
        title("Swiss Per Capita Alcohol Consumption by Type, 1880-1979", size(medsmall)) ///
        subtitle("Beverage lines: effective litres; dashed total: litres of 100% alcohol per adult (15+)", size(vsmall)) ///
        legend(order(3 "Wine" 4 "Beer" 5 "Cider" 6 "Distilled spirits" ///
                     7 "Total (100% alc, 15+)" 1 "War years") ///
               position(2) ring(0) cols(1) size(vsmall) region(lcolor(none))) ///
        xlabel(1880(10)1980, angle(45) labsize(small)) ///
        ylabel(0(10)100, angle(horizontal) labsize(small)) ///
        graphregion(color(white)) plotregion(margin(small)) ///
        name(cahannes_ts, replace)

    graph export "$OverleafFigDir/f01_alcohol_consumption_cahannes.png", ///
        width(2200) replace
    graph export "$OverleafFigDir/f01_alcohol_consumption_cahannes.pdf", ///
        replace
    di as text "  Wrote f01_alcohol_consumption_cahannes.{png,pdf} -> Overleaf files/fig/main/"
}

** EOF
