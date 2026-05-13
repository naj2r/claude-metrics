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
    * Phase B.5 framing: substitution-INCENTIVE proxy (relative input cost),
    * NOT cross-price elasticity (which requires demand-quantity data we do
    * not observe for this period). The supply-and-demand framework predicts
    * ambiguous price movements (demand for substitutes up; supply of
    * substitute inputs up via land reallocation), so the ratio movements
    * are CONSISTENT WITH but not direct PROOF of substitution. Quantity-
    * side corroboration via Marrus (1974) consumption volumes and HSSO
    * I.01 substrate-crop areas (canton_substrate_availability_descriptive.md).
    label var wine_potato_ratio   "Wine/Potato producer-price ratio (substitution-INCENTIVE proxy; not cross-price elasticity)"
    label var wine_wheat_ratio    "Wine/Wheat producer-price ratio (substitution-INCENTIVE proxy; not cross-price elasticity)"
    label var wine_rye_ratio      "Wine/Rye producer-price ratio (substitution-INCENTIVE proxy; not cross-price elasticity)"

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

    local fn = "Notes: This table presents the substrate input-price environment faced by spirits distillers. It documents substitution INCENTIVE (relative input costs), not substitution behavior (which requires demand-quantity data we do not observe). Producer Price Indexes for vegetable products (1914 = 100). The Wine/Potato ratio is the primary substitution-incentive proxy: higher values indicate stronger cost-rational incentive for spirits distillers to use potato eau-de-vie in place of grape eau-de-vie. (P) marks the phylloxera-trough period 1880-1895 during which Swiss vineyard area collapsed (Banerjee et al. 2010; Simpson 2011); (B) marks the 1908 absinthe ban referendum year (vote \#68). The 1908 ratio was `ratio_1908_str', indicating ongoing cost-rational substitution incentive at the ban-year baseline. Convergent quantity-side evidence: Marrus (1974) consumption volumes; HSSO I.01 canton-level substrate-crop areas (canton\_substrate\_availability\_descriptive.md). Source: HSSO H.2a (Producer Price Indexes of Vegetable Products 1801-1983, citing Ritzmann 1990 and Swiss Farmers' Secretariat 1922-1984)."

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
        text(115 1892 "Peak ratio 2.30 (1892)", size(vsmall) color(black)) ///
        text(115 1908 "1908 ban (ratio 1.50)", size(vsmall) color(black)) ///
        legend(order(1 "Wine" 2 "Potato" 3 "Wine/Potato ratio (R)") rows(1) size(small) position(6)) ///
        graphregion(fcolor(white)) ///
        note("Substitution INCENTIVE evidence (relative input cost), not substitution behavior (which requires demand-quantity data unavailable for this period). The wine-potato divergence (wine prices rising during phylloxera scarcity; potato prices falling during the same period) is consistent with the joint supply-and-demand framework: phylloxera reduces wine supply (wine prices up); demand for substitute alcohols increases (upward pressure on substitute prices); concurrent supply of substitute inputs increases as producers reallocate land toward viable crops (downward pressure on substitute prices). Net effect on substitute prices is theoretically ambiguous; observed potato-price decline suggests supply response dominated demand response. Framework predicts unambiguous increase in substitute crop quantities (corroborated descriptively via I.01 canton substrate-area data, 1917 complete coverage). Peak substitution incentive 1892 (ratio 2.30); ban year 1908 (ratio 1.50). The 16-year peak-to-mobilization gap is consistent with the historical-political-economy argument that mobilization lags structural pressure and requires coalitional opportunity (cf. Prestwich 1979). Source: HSSO H.2a, 1914 = 100.", size(vsmall))

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


**# 6. C.8 Federal subsidy time-series (I.33a + I.33b)
*------------------------------------------------------------------------------*
* Stages (iii) and (iv) of the substrate-substitution policy-economy arc:
*
*   (iii) 1908 viticulture-subsidy emergence (I.33a col C):
*         BLANK 1866-1907, FIRST APPEARS 1908 (133K CHF), then 237K (1909)
*         and 277K (1910). Cited as the third headline-candidate finding
*         in progress_2026-05-11_2215_viti1908.md. Disambiguation between
*         (a) actual program creation 1908 vs (b) categorical
*         reclassification of pre-existing spending requires Brugger 1968
*         archival lookup; here we present descriptive evidence consistent
*         with full-spectrum capture (positive transfers + competitor
*         elimination in the same calendar year).
*
*   (iv) Post-vote substrate-subsidy continuation (I.33b cols H/I/J):
*        - Col H viticulture continues 1911-1991 from the 1908 line item.
*        - Col I potato/fruit alcohol substrate subsidies emerge 1931+,
*          reflecting Federal Alcohol Administration policy that supports
*          the alternative-substrate distillation industry post-absinthe.
*        - Col J sugar-beet processing emerges 1961+ (a later substrate
*          for industrial alcohol).
*
* I.33a covers 1866-1915 yearly. I.33b covers 1911-1991 yearly. The two
* series overlap for 1911-1915; I.33a is canonical for that window
* (cross-checked: I.33a col C 1911 = 115 matches I.33b col H 1911 = 115).
{
    * --- I.33a extraction (1866-1915) ---
    * Layout (verified by openpyxl survey 2026-05-12):
    *   row 11: column headers ("Soil improvements", "Viticulture...", ..., "Total")
    *   row 13 onwards: yearly data (1866 at r13, 1908 at r55, 1915 at r62)
    *   Col A: Year
    *   Col C: Viticulture and grape processing (PRIMARY)
    *   Col K: Associations and exhibitions (SECONDARY, paper-text descriptive)
    import excel using "$Absinthe1Data/translated/I.33a_EN.xlsx", ///
        cellrange(A13:M62) allstring clear

    rename A year_raw
    rename C viticulture_raw
    rename K associations_raw
    keep year_raw viticulture_raw associations_raw

    gen long year = real(year_raw)
    drop if missing(year)
    keep if inrange(year, 1866, 1915)

    foreach v in viticulture associations {
        destring `v'_raw, gen(`v') force
        replace `v' = 0 if missing(`v')   // 0 = no line-item that year (blank in HSSO)
    }
    drop *_raw

    gen str10 source = "I.33a"
    label var year         "Year"
    label var viticulture  "Viticulture & grape processing subsidy (1000 CHF, I.33a col C)"
    label var associations "Ag associations & exhibitions subsidy (1000 CHF, I.33a col K)"
    label var source       "HSSO source file"

    isid year
    tempfile i33a_yearly
    save "`i33a_yearly'"

    * --- I.33b extraction (1911-1991) ---
    * Layout (verified by openpyxl survey 2026-05-12):
    *   row 21: 1911 (first data row)
    *   Col H: Viticulture (continuation of I.33a col C)
    *   Col I: Potato + fruit alcohol substrate subsidies (emerges 1931+)
    *   Col J: Sugar-beet processing subsidies (emerges 1961+)
    import excel using "$Absinthe1Data/translated/I.33b_EN.xlsx", ///
        cellrange(A21:M101) allstring clear

    rename A year_raw
    rename H viticulture_raw
    rename I potato_fruit_raw
    rename J sugar_beet_raw
    keep year_raw viticulture_raw potato_fruit_raw sugar_beet_raw

    gen long year = real(year_raw)
    drop if missing(year)
    keep if inrange(year, 1911, 1991)

    foreach v in viticulture potato_fruit sugar_beet {
        destring `v'_raw, gen(`v') force
        replace `v' = 0 if missing(`v')
    }
    drop *_raw

    label var year         "Year"
    label var viticulture  "Viticulture & grape processing subsidy (1000 CHF, I.33b col H)"
    label var potato_fruit "Potato + fruit alcohol substrate subsidy (1000 CHF, I.33b col I)"
    label var sugar_beet   "Sugar-beet processing subsidy (1000 CHF, I.33b col J)"

    isid year
    gen str10 source = "I.33b"
    tempfile i33b_yearly
    save "`i33b_yearly'"

    * --- Combine into one long-format series 1866-1991 ---
    * For 1911-1915 (overlap) keep I.33a as canonical. Drop I.33b 1911-1915.
    use "`i33b_yearly'", clear
    drop if inrange(year, 1911, 1915)
    * Ensure schema compatibility: add associations = . from I.33b
    gen double associations = .
    append using "`i33a_yearly'"
    * For pre-1911 years (where I.33a is the only source), potato/sugar-beet
    * are NaN (HSSO does not break out these line items pre-1911)
    foreach v in potato_fruit sugar_beet {
        cap confirm variable `v'
        if _rc {
            gen double `v' = .
        }
        else {
            replace `v' = . if source == "I.33a"
        }
    }
    sort year
    order year source viticulture associations potato_fruit sugar_beet

    label var potato_fruit "Potato + fruit alcohol substrate subsidy (1000 CHF, I.33b col I)"
    label var sugar_beet   "Sugar-beet processing subsidy (1000 CHF, I.33b col J)"
    notes _dta: HSSO I.33a (1866-1915) + I.33b (1911-1991 minus 1911-1915 overlap). National-level federal agricultural subsidy line items.
    notes _dta: Substrate-substitution arc descriptive evidence (C.8). Viticulture emerges 1908 (133K CHF); potato/fruit emerges 1931; sugar-beet emerges 1961.

    isid year
    compress
    save "$MyProject/processed/intermediate/i33_subsidies_long.dta", replace
    di as result "Saved i33_subsidies_long.dta: " %5.0f c(N) " yearly rows 1866-1991"
}


**# 7. T22 viticulture subsidy table (1900-1920 focus)
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/intermediate/i33_subsidies_long.dta", clear
    keep if inrange(year, 1900, 1920)
    keep year viticulture
    rename viticulture viticulture_1000chf

    gen str10 viti_str = string(viticulture_1000chf, "%6.0f")
    replace viti_str = "(blank)" if viticulture_1000chf == 0 & year <= 1907

    gen str20 era_note = ""
    replace era_note = "no line item"               if year <= 1907
    replace era_note = "FIRST APPEARS (ban year)"   if year == 1908
    replace era_note = "1909 implementing ordinance" if year == 1909
    replace era_note = "WWI budget"                 if inrange(year, 1914, 1918)

    keep year viti_str era_note
    order year viti_str era_note
    label var year     "Year"
    label var viti_str "Viticulture subsidy (1000 CHF)"
    label var era_note "Era / event marker"

    local fn_t22 = "Notes: Federal viticulture subsidy line item from HSSO I.33a column C (1866-1915) and I.33b column H (continuation). The line is BLANK from the start of the federal agricultural subsidy series in 1866 through 1907 and first appears in 1908 with 133K CHF -- the same calendar year as the absinthe-ban referendum (5 July 1908, vote \#68). The 1909 row reflects the implementing ordinance of the 1906 Lebensmittelgesetz that established federal thujone limits. Two interpretations of the 1908 emergence remain possible without Brugger 1968 disambiguation: (a) a genuinely new federal program emerged in 1908 (full-spectrum-capture interpretation: positive transfers + competitor elimination in the same year); or (b) a pre-existing program newly broken out from a previously-aggregated category (categorical-reclassification interpretation). The post-1908 trajectory (237K 1909, 277K 1910) shows the line item growing in scale, and the post-vote continuation in I.33b is the foundation for the substrate-substitution industrial policy documented in stage (iv) of the policy-economy arc. The post-1908 wine-index surge (1910 = 107 vs. 1905 ~ 50) coincides with the ban-imposed elimination of cheap-absinthe substitute demand. This pattern is consistent with regulatory-capture-induced demand redirection toward wine, distinct from the natural supply-recovery from phylloxera replanting (which occurred 1895-1905). The two sources of wine-market improvement are temporally separable and substantively distinct. WWI budget reallocation explains the 1914-1918 dip. Source: HSSO I.33a + I.33b, citing Brugger 1968. See progress\_2026-05-11\_2215\_viti1908.md for the full discovery context."

    texsave year viti_str era_note ///
        using "$MyProject/results/tables/t22_viticulture_subsidy.tex", ///
        replace autonumber varlabels marker(tab:viti_subsidy) ///
        title("Federal viticulture subsidy line item, 1900-1920 (HSSO I.33a + I.33b, 1000 CHF)") ///
        footnote("`fn_t22'")
    di as result "Saved t22_viticulture_subsidy.tex"
}


**# 8. F07 subsidy time-series figure (1866-1991 line plot)
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/intermediate/i33_subsidies_long.dta", clear

    twoway ///
        (line viticulture year if !missing(viticulture), lcolor(red) lwidth(medthick) lpattern(solid)) ///
        (line potato_fruit year if !missing(potato_fruit) & potato_fruit > 0, lcolor(orange) lwidth(medium) lpattern(solid)) ///
        (line sugar_beet  year if !missing(sugar_beet)  & sugar_beet  > 0, lcolor(green)  lwidth(medium) lpattern(solid)) ///
        , ///
        title("Federal substrate-related subsidies 1866-1991 (HSSO I.33a + I.33b)", size(medsmall)) ///
        subtitle("Substrate-substitution arc stages (iii) emergence 1908 + (iv) post-vote continuation", size(small)) ///
        ytitle("Subsidy (1000 CHF)") ///
        xtitle("Year") ///
        xline(1908, lcolor(black) lpattern(dash)) ///
        xline(1931, lcolor(gs10) lpattern(dot)) ///
        xline(1961, lcolor(gs10) lpattern(dot)) ///
        text(1500 1908 "#68 ban", size(vsmall) color(black)) ///
        text(1500 1931 "potato/fruit emerges", size(vsmall) color(gs6)) ///
        text(1500 1961 "sugar-beet emerges", size(vsmall) color(gs6)) ///
        legend(order(1 "Viticulture (I.33a col C / I.33b col H)" 2 "Potato + fruit (I.33b col I)" 3 "Sugar-beet (I.33b col J)") rows(2) size(small) position(6)) ///
        graphregion(fcolor(white)) ///
        note("Substrate-substitution policy-economy arc stages (iii) and (iv): viticulture line emerges 1908 (133K CHF) -- same year as absinthe ban. The post-1908 wine-index surge (1910 = 107 vs. 1905 ~ 50) coincides with the ban-imposed elimination of cheap-absinthe substitute demand: consistent with regulatory-capture-induced demand redirection toward wine, distinct from the natural supply-recovery from phylloxera replanting 1895-1905. Substrate-subsidy continuation: potato/fruit alcohol 1931+, sugar-beet 1961+. Source: HSSO I.33a (1866-1915) + I.33b (1916-1991, 1911-1915 overlap dropped).", size(vsmall))

    graph export "$MyProject/results/figures/f07_subsidy_timeseries.pdf", replace as(pdf)
    graph close
    di as result "Saved f07_subsidy_timeseries.pdf"
}


**# 9. C.8 secondary: ag-association subsidies notes file
*------------------------------------------------------------------------------*
* Extract I.33a col K "Associations and exhibitions" values for key years
* (1866, 1875, 1890, 1900, 1907, 1915) to a notes file for Background-section
* prose use. The col K series is a quantitative proxy for organized
* agricultural-interest-group landscape pre-ban -- noisy because it pools
* all ag association subsidies, but informative for the "wine industry was
* not the only organized constituency" framing.
{
    use "$MyProject/processed/intermediate/i33_subsidies_long.dta", clear
    keep if inlist(year, 1866, 1875, 1890, 1900, 1907, 1915) & source == "I.33a"

    cap mkdir "$MyProject/output"
    cap mkdir "$MyProject/output/notes"

    cap file close notes_fh
    file open notes_fh using "$MyProject/output/notes/ag_association_subsidies_descriptive.md", write replace
    file write notes_fh "# Federal Agricultural Association Subsidies, Key Years 1866-1915" _n _n
    file write notes_fh "Source: HSSO I.33a column K (Associations and exhibitions; 1000 CHF)." _n _n
    file write notes_fh "Generated automatically by 07_substrate_descriptives.do section 9 (C.8 secondary output)." _n _n
    file write notes_fh "## Year-by-year values" _n _n
    file write notes_fh "| Year | Associations subsidy (1000 CHF) |" _n
    file write notes_fh "|------|---:|" _n
    forvalues i = 1/`=c(N)' {
        local y = year[`i']
        local v : di %6.0f associations[`i']
        file write notes_fh "| `y' | `v' |" _n
    }
    file write notes_fh _n
    file write notes_fh "## Paper-text use" _n _n
    file write notes_fh "These values document that the Swiss agricultural interest-group landscape -- of which the wine-grower associations were one constituency -- received a steady (and growing) flow of federal subsidies for associations and exhibitions throughout the pre-ban period 1866-1915. The line item is national-level only; HSSO does not break it down to specific associations." _n
    file close notes_fh
    di as result "Saved output/notes/ag_association_subsidies_descriptive.md"
}


**# 9b. C.12 canton-level substrate-availability descriptive (I.01)
*------------------------------------------------------------------------------*
* Pairs the national H.2a substrate-price series (C.10) with canton-level
* substrate-availability variation. Loads cereal_potato_area_uncleaned.dta
* (built in 01_import.do section 4.05), merges canton population for per-
* capita scaling, and writes a descriptive notes file.
*
* CAVEAT: I.01 has NO pre-vote canton-level potato area; the closest year
* is 1910 (2 years post-vote). Cereal area is available for 1905 (perfect
* pre-vote snapshot). Documented in the notes file.
{
    use "$MyProject/processed/intermediate/cereal_potato_area_uncleaned.dta", clear
    merge 1:1 canton_code using "$MyProject/processed/intermediate/population_uncleaned.dta", ///
        assert(match) nogenerate

    * Per-capita scaling: areas are in 1000 hectares, population in persons.
    * To get hectares per person: (1000 ha * 1000) / pop = 1,000,000 / pop.
    foreach v in cereal_area_1905 cereal_area_1917 potato_area_1910 potato_area_1917 {
        gen double `v'_per_cap = (`v' * 1000) / pop_1900
    }

    label var cereal_area_1905_per_cap "Cereal/pop (ha/person, 1905; SPARSE -- 3 cantons)"
    label var cereal_area_1917_per_cap "Cereal/pop (ha/person, 1917; first complete canton-year)"
    label var potato_area_1910_per_cap "Potato/pop (ha/person, 1910; SPARSE -- ZH only)"
    label var potato_area_1917_per_cap "Potato/pop (ha/person, 1917; first complete canton-year)"

    notes _dta: HSSO I.01 cereal (rows 47, 49) + potato (rows 74, 75) sub-blocks. Canton-level substrate-availability descriptive (C.12). NOT a main-regression input.
    notes _dta: Pre-vote canton-level coverage is sparse (1905 cereal: 3 cantons; 1910 potato: 1 canton). First complete canton-level snapshot is 1917 (9 years post-vote). 1917 used under geographic-stability assumption: canton cereal/potato cultivation distribution is much more stable across decades than wine acreage.

    isid canton_code
    compress
    save "$MyProject/processed/intermediate/cereal_potato_area_long.dta", replace
    di as result "Saved cereal_potato_area_long.dta (canton-level substrate-availability descriptive)"

    * --- Descriptive notes file ---
    cap mkdir "$MyProject/output"
    cap mkdir "$MyProject/output/notes"

    * Merge in vineyard_per_cap for cross-reference
    merge 1:1 canton_code using "$MyProject/processed/absinthe_analysis.dta", ///
        keepusing(vineyard_per_cap) keep(match) nogen
    sort canton_code

    cap file close notes_fh
    file open notes_fh using "$MyProject/output/notes/canton_substrate_availability_descriptive.md", write replace
    file write notes_fh "# Canton-Level Substrate Availability (HSSO I.01, C.12 descriptive)" _n _n
    file write notes_fh "**PRELIMINARY**: descriptive complement to the national H.2a producer-price evidence (C.10). NOT a main-regression input." _n _n
    file write notes_fh "## Data-availability discovery" _n _n
    file write notes_fh "HSSO I.01's cereal and potato sub-blocks have **sparse pre-vote canton-level coverage**. Pre-WWI, only a handful of major arable cantons report:" _n _n
    file write notes_fh "- 1905 cereal: 3 cantons populated (ZH, BE+JU, VD). Other 22 cantons aggregate into CH national total only." _n
    file write notes_fh "- 1910 potato: 1 canton populated (ZH only)." _n _n
    file write notes_fh "**Full canton-level coverage begins in 1917**, presumably tied to WWI-era federal substrate-substitution surveys. We therefore extract both:" _n _n
    file write notes_fh "1. 1905 cereal + 1910 potato (sparse pre-vote snapshots; useful only for major arable cantons)" _n
    file write notes_fh "2. 1917 cereal + potato (complete canton-level snapshots; 9 years post-vote)" _n _n
    file write notes_fh "Paper-text use should explicitly flag the 9-year gap for 1917 data. The geographic-stability assumption is much more defensible for cereal/potato than for wine: arable land distribution across cantons is stable over decades, whereas wine area fluctuated with phylloxera and replantation." _n _n
    file write notes_fh "## Per-canton values (hectares per person)" _n _n
    file write notes_fh "| Canton | Cereal/pop 1905 | Cereal/pop 1917 | Potato/pop 1910 | Potato/pop 1917 | Vineyard/pop 1905 |" _n
    file write notes_fh "|---|---:|---:|---:|---:|---:|" _n
    forvalues i = 1/`=c(N)' {
        local cc = canton_code[`i']
        local c05 : di %5.4f cereal_area_1905_per_cap[`i']
        local c17 : di %5.4f cereal_area_1917_per_cap[`i']
        local p10 : di %5.4f potato_area_1910_per_cap[`i']
        local p17 : di %5.4f potato_area_1917_per_cap[`i']
        local vi  : di %5.4f vineyard_per_cap[`i']
        file write notes_fh "| `cc' | `c05' | `c17' | `p10' | `p17' | `vi' |" _n
    }

    qui summ cereal_area_1917_per_cap
    local c17_mean : di %5.4f r(mean)
    local c17_min  : di %5.4f r(min)
    local c17_max  : di %5.4f r(max)
    qui summ potato_area_1917_per_cap
    local p17_mean : di %5.4f r(mean)
    local p17_min  : di %5.4f r(min)
    local p17_max  : di %5.4f r(max)

    file write notes_fh _n
    file write notes_fh "## Summary statistics (1917 complete-coverage snapshot, 25 cantons)" _n _n
    file write notes_fh "| Variable | Mean | Min | Max |" _n
    file write notes_fh "|---|---:|---:|---:|" _n
    file write notes_fh "| Cereal area / person (1917, ha) | `c17_mean' | `c17_min' | `c17_max' |" _n
    file write notes_fh "| Potato area / person (1917, ha) | `p17_mean' | `p17_min' | `p17_max' |" _n
    file write notes_fh _n
    file write notes_fh "## Paper-text use" _n _n
    file write notes_fh "Documents canton-level variation in substrate availability complementing the national H.2a price series (C.10). Use in Background or Discussion paragraphs that contextualize the substrate-substitution arc with canton-level heterogeneity: cantons with high cereal or potato area had locally cheap substrate availability for grain/potato-alcohol distillation, contributing to the cheap-spirits supply that competed with grape eau-de-vie." _n _n
    file write notes_fh "**Recommended framing**: use the 1917 numbers as the canonical canton substrate-availability snapshot (complete coverage), with a footnote acknowledging the 9-year gap from the 1908 vote and the geographic-stability assumption. The 1905/1910 columns are flagged as sparse and shown only to document the data-availability gap." _n _n
    file write notes_fh "The vineyard/per/cap column (1905) is shown for cross-reference -- distinct industries with distinct geographic patterns. Cantons with the highest cereal area (BE, FR, VD) are NOT the same as those with the highest vineyard area (NE, GE, VS, VD)." _n
    file close notes_fh
    di as result "Saved output/notes/canton_substrate_availability_descriptive.md"
}


**# 10. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    foreach ds in h2a_substrate_prices_long i33_subsidies_long cereal_potato_area_long {
        _codebook_update using "$MyProject/processed/intermediate/`ds'.dta", ///
            script("07_substrate_descriptives.do")
        use "$MyProject/processed/intermediate/`ds'.dta", clear
        local nobs  = c(N)
        local nvars = c(k)
        _inventory_append, sheet("datasets") ///
            row("created|processed/intermediate/`ds'.dta|`nobs'|`nvars'|.|07_substrate_descriptives.do")
    }
    foreach t in t23_substrate_prices t22_viticulture_subsidy {
        _inventory_append, sheet("outputs") ///
            row("generated|results/tables/`t'.tex|table|07_substrate_descriptives.do")
    }
    foreach f in f08_substrate_prices f07_subsidy_timeseries {
        _inventory_append, sheet("outputs") ///
            row("generated|results/figures/`f'.pdf|figure|07_substrate_descriptives.do")
    }
    _inventory_append, sheet("scripts") ///
        row("07_substrate_descriptives.do|.|extracts national-level substrate prices (H.2a) and federal subsidies (I.33a/b) for the substrate-substitution policy-economy arc|.")
}

** EOF
