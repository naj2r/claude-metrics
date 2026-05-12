/*==============================================================================
 07_substrate_descriptives.do
 Purpose:  Extract NATIONAL-LEVEL substrate-economics and federal-subsidy
           descriptive series for the substrate-substitution policy-economy arc
           (Tasks C.10 and C.8 of the Tier 1 P1 workshop draft batch).

           The arc has four stages and this script provides descriptive
           empirical content for stages (i), (iii), and (iv):

             (i)   Phylloxera shock 1880s-90s -> wine-supply collapse +
                   relative-price reversal favoring potato/grain substrate
                   [C.10: H.2a producer prices]
             (ii)  Cheap potato-alcohol absinthe expands in mass market
                   [mechanism inferred from (i); no direct national consumption
                   data is in HSSO]
             (iii) Wine industry mobilizes for anti-competitor regulation
                   (votes #65, #68) AND positive transfers (1908 viticulture
                   subsidy line item I.33a column C)
                   [C.8: I.33a viticulture line + col K associations subsidies]
             (iv)  Post-vote federal industrial policy subsidizes alternative
                   substrates (I.33b col I potato/fruit alcohol 1931+, col J
                   sugar-beet 1961+) -- closing the policy-economy arc
                   [C.8: I.33b substrate-subsidy continuation]

           These outputs are NATIONAL-LEVEL and never merged into the
           canton-level absinthe_analysis.dta. Same invariant as the F-series
           extracts in 06_national_descriptives.do.

 Input:    $Absinthe1Data/translated/H.2a_EN.xlsx
           $Absinthe1Data/translated/I.33a_EN.xlsx  (C.8 -- added later)
           $Absinthe1Data/translated/I.33b_EN.xlsx  (C.8 -- added later)

 Output:   $MyProject/processed/intermediate/h2a_substrate_prices_long.dta
           $MyProject/results/tables/t23_substrate_prices.tex
           $MyProject/results/figures/f08_substrate_prices.pdf
           [C.8 outputs added in subsequent commit]

 Author:   Nicholas A Jensen
 Date:     2026-05-12
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}


**# 0. Setup
*------------------------------------------------------------------------------*
{
    cap assert !mi("$Absinthe1Data")
    if _rc {
        di as error "Error: \$Absinthe1Data must be set in your Stata profile"
        error 9
    }

    * H.2a column map (verified by openpyxl survey, 2026-05-12):
    *   row 6:  German commodity names (Brot, Mehl, Weizen, ..., Wein)
    *   row 8:  French commodity names
    *   row 10: units (Index / Indice for cols B-L; Fr./q or Fr./hl for cols N-X)
    *   row 12 onwards: yearly data, col A = year (1801 starting at r12, 1983 at r194)
    *   rows 246-249: 4-year periodic averages (1971/74, 1975/78, 1979/82, 1983)
    *                 -- ignored; would duplicate yearly data
    *   rows 251+: footnotes and sources
    *
    * Price-index columns we extract (1914 = 100):
    *   col E: Weizen     (Wheat)        -- grain-alcohol substrate
    *   col G: Roggen     (Rye)          -- grain-alcohol substrate
    *   col I: Hafer      (Oats)         -- grain-alcohol substrate
    *   col J: Kartoffeln (Potatoes)     -- PRIMARY cheap-spirits substrate
    *   col K: Aepfel     (Apples)       -- Obstler/fruit-brandy substrate
    *   col L: Wein       (Wine)         -- "true" absinthe substrate
}


**# 1. H.2a producer-price series 1801-1983 (yearly)
*------------------------------------------------------------------------------*
* Approach: import the full sheet as allstring, parse year + commodity index
* columns we care about, destring, save as long-format archive .dta. Filter to
* yearly rows only (drop the four periodic-average rows at 246-249).
{
    * Rows 12-194 cover yearly data 1801-1983. Rows 246-249 are periodic
    * averages (1971/74, 1975/78, 1979/82, 1983) -- skipped to avoid
    * duplicate-year collisions with the yearly 1983 row at r194.
    import excel using "$Absinthe1Data/translated/H.2a_EN.xlsx", ///
        cellrange(A12:L194) allstring clear

    * Imported columns A..L become A,B,C,...,L (Stata strips header row when
    * cellrange starts mid-sheet, so we use generic var names).
    rename A   year_raw
    rename E   wheat_idx_raw
    rename G   rye_idx_raw
    rename I   oats_idx_raw
    rename J   potato_idx_raw
    rename K   apple_idx_raw
    rename L   wine_idx_raw

    keep year_raw wheat_idx_raw rye_idx_raw oats_idx_raw ///
         potato_idx_raw apple_idx_raw wine_idx_raw

    * Drop rows where year is non-numeric (periodic averages like "1971/74",
    * footnote text, blank rows). We want only single-year rows.
    gen long year = real(year_raw)
    drop if missing(year)
    keep if inrange(year, 1801, 1983)

    foreach v in wheat rye oats potato apple wine {
        destring `v'_idx_raw, gen(`v'_idx) force
    }
    drop *_raw

    order year wheat_idx rye_idx oats_idx potato_idx apple_idx wine_idx

    * Compute substitution-incentive ratios (wine cost / substrate cost).
    * Higher = stronger substitution incentive for spirits distillers.
    gen double wine_potato_ratio = wine_idx / potato_idx if !missing(potato_idx) & potato_idx > 0
    gen double wine_wheat_ratio  = wine_idx / wheat_idx  if !missing(wheat_idx)  & wheat_idx  > 0
    gen double wine_rye_ratio    = wine_idx / rye_idx    if !missing(rye_idx)    & rye_idx    > 0

    * Labels (units = price index, 1914 = 100, per HSSO H.2a)
    label var year                "Year"
    label var wheat_idx           "Wheat producer-price index (1914=100)"
    label var rye_idx             "Rye producer-price index (1914=100)"
    label var oats_idx            "Oats producer-price index (1914=100)"
    label var potato_idx          "Potato producer-price index (1914=100)"
    label var apple_idx           "Apple producer-price index (1914=100)"
    label var wine_idx            "Wine producer-price index (1914=100)"
    label var wine_potato_ratio   "Wine/Potato price ratio (substitution-incentive proxy)"
    label var wine_wheat_ratio    "Wine/Wheat price ratio (substitution-incentive proxy)"
    label var wine_rye_ratio      "Wine/Rye price ratio (substitution-incentive proxy)"

    notes _dta: HSSO H.2a (Producer Price Indexes of Vegetable Products 1801-1983, 1914=100). National-level only. Source: Ritzmann 1990 + Swiss Farmers' Secretariat 1922-1984.
    notes _dta: Substrate-substitution arc descriptive evidence (C.10). Wine/Potato ratio is the primary substitution-incentive proxy for spirits distillers' substrate choice between grape eau-de-vie and potato eau-de-vie.

    isid year
    compress
    save "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", replace
    di as result "Saved h2a_substrate_prices_long.dta with `=c(N)' yearly rows (1801-1983)."
}


**# 2. T23 substrate prices table (1875-1915 focus window)
*------------------------------------------------------------------------------*
* Display: year, wine_idx, potato_idx, apple_idx, wine/potato ratio.
* Window: 1875-1915 -- spans the phylloxera era (1880s-1890s) and the post-ban
* wine recovery (1909-1910). Pre-1875 and post-1915 yearly data is preserved in
* the underlying .dta for any future extensions.
{
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear

    * Pull the 1908 wine/potato ratio for the footnote sentence
    qui summ wine_potato_ratio if year == 1908, meanonly
    local ratio_1908_str : di %5.2f r(mean)

    keep if inrange(year, 1875, 1915)

    * Format display strings (1 decimal, en-dash for blanks)
    foreach v in wheat_idx rye_idx oats_idx potato_idx apple_idx wine_idx {
        gen str10 `v'_str = string(`v', "%6.1f") if !missing(`v')
        replace `v'_str = "---"            if missing(`v')
    }
    gen str10 ratio_wp_str = string(wine_potato_ratio, "%5.2f") if !missing(wine_potato_ratio)
    replace ratio_wp_str = "---" if missing(wine_potato_ratio)

    * Mark phylloxera trough (1880-1895) and ban year (1908) with a flag column
    gen str4 era_marker = ""
    replace era_marker = "(P)" if inrange(year, 1880, 1895)
    replace era_marker = "(B)" if year == 1908

    keep year wine_idx_str potato_idx_str apple_idx_str ratio_wp_str era_marker
    order year wine_idx_str potato_idx_str apple_idx_str ratio_wp_str era_marker

    label var year            "Year"
    label var wine_idx_str    "Wine index"
    label var potato_idx_str  "Potato index"
    label var apple_idx_str   "Apple index"
    label var ratio_wp_str    "Wine/Potato"
    label var era_marker      "Era"

    local fn = "Notes: Producer Price Indexes for vegetable products (1914 = 100). The Wine/Potato ratio is the primary substitution-incentive proxy: higher values indicate stronger cost-rational incentive for spirits distillers to use potato eau-de-vie in place of grape eau-de-vie. (P) marks the phylloxera-trough period 1880-1895 during which Swiss vineyard area collapsed (Banerjee et al. 2010; Simpson 2011); (B) marks the 1908 absinthe ban referendum year (vote \#68). The 1908 ratio was `ratio_1908_str', indicating ongoing cost-rational substitution incentive at the ban-year baseline. Source: HSSO H.2a (Producer Price Indexes of Vegetable Products 1801-1983, citing Ritzmann 1990 and Swiss Farmers' Secretariat 1922-1984)."

    texsave year wine_idx_str potato_idx_str apple_idx_str ratio_wp_str era_marker ///
        using "$MyProject/results/tables/t23_substrate_prices.tex", ///
        replace autonumber varlabels marker(tab:substrate_prices) ///
        title("Substrate producer prices and substitution-incentive ratio, 1875-1915 (HSSO H.2a, 1914 = 100)") ///
        footnote("`fn'")
    di as result "Saved t23_substrate_prices.tex"
}


**# 3. F08 substrate prices figure (1875-1915, line plot + ratio overlay)
*------------------------------------------------------------------------------*
* Plot: wine index (red) + potato index (blue) on left axis (price index, 1914 =
* 100). Wine/Potato ratio (gray dashed) on right axis (substitution incentive).
* Vertical lines at 1880 (phylloxera onset) and 1908 (absinthe ban).
{
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear
    keep if inrange(year, 1875, 1915)

    twoway ///
        (line wine_idx   year, lcolor(red)  lwidth(medthick) lpattern(solid))   ///
        (line potato_idx year, lcolor(blue) lwidth(medthick) lpattern(solid))   ///
        (line wine_potato_ratio year, lcolor(gs8) lwidth(medium) lpattern(dash) yaxis(2)) ///
        , ///
        title("Wine vs Potato producer prices, 1875-1915 (HSSO H.2a)", size(medsmall)) ///
        subtitle("Substitution-incentive ratio (right axis, dashed): wine cost / potato cost", size(small)) ///
        ytitle("Producer price index (1914 = 100)", axis(1)) ///
        ytitle("Wine/Potato ratio", axis(2)) ///
        xtitle("Year") ///
        xline(1880, lcolor(gs10) lpattern(dot)) ///
        xline(1908, lcolor(black) lpattern(dash)) ///
        text(115 1882 "Phylloxera era 1880-1895", size(vsmall) color(gs6)) ///
        text(115 1908 "1908 ban", size(vsmall) color(black)) ///
        legend(order(1 "Wine" 2 "Potato" 3 "Wine/Potato ratio (R)") rows(1) size(small) position(6)) ///
        graphregion(fcolor(white)) ///
        note("Substrate-substitution arc stage (i): phylloxera shock drove the relative-price reversal favoring potato substrate. At 1908 the wine/potato ratio remained {bf:>1}, indicating cost-rational substitution incentive at the ban-year baseline. Source: HSSO H.2a, 1914 = 100.", size(vsmall))

    graph export "$MyProject/results/figures/f08_substrate_prices.pdf", replace as(pdf)
    graph close
    di as result "Saved f08_substrate_prices.pdf"
}


**# 4. Sanity-check assertions on key cited values
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear

    * From the strategist's preview table (verified by openpyxl survey 2026-05-12):
    *   1881: wine=45.6  potato=61.4  ratio=0.74
    *   1885: wine=56.5  potato=38.3  ratio=1.48
    *   1900: wine=43.9  potato=36.7  ratio=1.20
    *   1908: wine=63.2  potato=42.2  ratio=1.50
    *   1910: wine=107.0 potato=82.0  ratio=1.30
    foreach spec in "1881 45.6 61.4 0.74" "1885 56.5 38.3 1.48" "1900 43.9 36.7 1.20" "1908 63.2 42.2 1.50" "1910 107.0 82.0 1.30" {
        local y     : word 1 of `spec'
        local wine  : word 2 of `spec'
        local pot   : word 3 of `spec'
        local rat   : word 4 of `spec'
        qui summ wine_idx if year == `y', meanonly
        assert abs(r(mean) - `wine') < 0.5
        qui summ potato_idx if year == `y', meanonly
        assert abs(r(mean) - `pot') < 0.5
        qui summ wine_potato_ratio if year == `y', meanonly
        assert abs(r(mean) - `rat') < 0.05
    }
    di as result "All H.2a sanity-check assertions passed."
}


**# 5. Display headline 1908 paper-text statistics
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear
    di _n "=== Substrate-substitution arc (C.10) headline 1908 numbers ==="
    list year wine_idx potato_idx apple_idx wine_potato_ratio if year == 1908, abbrev(20)
    di _n "=== Phylloxera-trough vs pre-trough wine prices ==="
    list year wine_idx wine_potato_ratio if inlist(year, 1875, 1880, 1885, 1890, 1895, 1900, 1908, 1910), abbrev(20)
}


**# 6. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    _codebook_update using "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", ///
        script("07_substrate_descriptives.do")
    use "$MyProject/processed/intermediate/h2a_substrate_prices_long.dta", clear
    local nobs  = c(N)
    local nvars = c(k)
    _inventory_append, sheet("datasets") ///
        row("created|processed/intermediate/h2a_substrate_prices_long.dta|`nobs'|`nvars'|.|07_substrate_descriptives.do")

    foreach t in t23_substrate_prices {
        _inventory_append, sheet("outputs") ///
            row("generated|results/tables/`t'.tex|table|07_substrate_descriptives.do")
    }
    foreach f in f08_substrate_prices {
        _inventory_append, sheet("outputs") ///
            row("generated|results/figures/`f'.pdf|figure|07_substrate_descriptives.do")
    }
    _inventory_append, sheet("scripts") ///
        row("07_substrate_descriptives.do|.|extracts national-level substrate prices (H.2a) and federal subsidies (I.33a/b) for the substrate-substitution policy-economy arc|.")
}

** EOF
