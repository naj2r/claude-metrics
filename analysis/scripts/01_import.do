/*==============================================================================
 01_import.do
 Purpose:  Import raw swissvotes CSV and 5 HSSO Excel files; save uncleaned
           Stata snapshots in processed/intermediate/.
 Input:    $Absinthe1Data/swissvotes_dataset.csv
           $Absinthe1Data/translated/{I.01,B.01a,B.01b,B.27,B.32}_EN.xlsx
 Output:   $MyProject/processed/intermediate/canton_crosswalk.dta
           $MyProject/processed/intermediate/swissvotes_uncleaned.dta  (vote #68)
           $MyProject/processed/intermediate/vote67_uncleaned.dta      (same-day placebo)
           $MyProject/processed/intermediate/vineyard_uncleaned.dta    (5 years)
           $MyProject/processed/intermediate/agland_uncleaned.dta      (1912 ag-land)
           $MyProject/processed/intermediate/population_uncleaned.dta
           $MyProject/processed/intermediate/pop_density_uncleaned.dta
           $MyProject/processed/intermediate/religion_uncleaned.dta
           $MyProject/processed/intermediate/language_uncleaned.dta
 Author:   Nicholas A Jensen
 Date:     2026-04-30
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Setup
*------------------------------------------------------------------------------*
{
    * Confirm raw-data global is defined (set in user's stata_profile.do)
    cap assert !mi("$Absinthe1Data")
    if _rc {
        di as error "Error: \$Absinthe1Data must be set in your Stata profile"
        error 9
    }

    * Canton column-letter -> 2-letter-code mapping for HSSO Excel files.
    * All HSSO files share this layout (verified empirically across all 5 files):
    *   A=Year, B=ZH, C=BE,JU (combined), D=BE-only, E=LU, ..., AA=GE,
    *   AB=JU-only, AC=CH (national), AD=Year (duplicate)
    * For the 1908 cross-section we want the 25 cantons that existed pre-1979.
    * BE/JU handling: Use column C (combined BE+JU) as the BE value because Jura
    * was not a separate canton until 1979. Drop column D (BE-only), AB (JU-only),
    * AC (CH total), AD (duplicate Year header).
    global hsso_excel_cols   "B C E F G H I J K L M N O P Q R S T U V W X Y Z AA"
    global hsso_canton_codes "ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE"
}


**# 1. Build canton crosswalk
*------------------------------------------------------------------------------*
{
    * The HSSO files have canton names as column headers, in the same order in
    * every file. We build a one-time mapping from Excel column letter to
    * 2-letter canton code, then use it to attach canton codes after each
    * HSSO import via xpose+merge (see helper logic in sections 3-7 below).
    clear
    set obs 25
    gen str3 col_letter  = ""
    gen str2 canton_code = ""

    local i = 1
    foreach col of global hsso_excel_cols {
        local code : word `i' of $hsso_canton_codes
        replace col_letter  = "`col'"  in `i'
        replace canton_code = "`code'" in `i'
        local ++i
    }

    isid canton_code
    isid col_letter
    assert c(N) == 25
    label var col_letter  "Excel column letter in HSSO file"
    label var canton_code "Canton (2-letter code, 1908)"

    compress
    save "$MyProject/processed/intermediate/canton_crosswalk.dta", replace
}


**# 2. Import swissvotes
*------------------------------------------------------------------------------*
{
    * Semicolon-delimited, UTF-8 with BOM, ~870 columns (one row per vote).
    * import delimited STRIPS hyphens from column names (preserves underscores):
    *   CSV "zh-japroz" -> Stata "zhjaproz"
    *   CSV "pdev-fdp_ZH" -> Stata "pdevfdp_zh" (existing _ kept)
    import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
        delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear

    di "Imported swissvotes: " c(N) " votes, " c(k) " columns"


**# 2.1 Filter to vote anr==68 (1908 absinthe ban)
*------------------------------------------------------------------------------*
    keep if anr == 68
    assert c(N) == 1


**# 2.2 Reshape canton columns to long (25 rows)
*------------------------------------------------------------------------------*
    * Canton-vote columns are <ct>ja, <ct>nein, <ct>japroz, <ct>bet, <ct>berecht,
    * <ct>stimmen (no separators — hyphens stripped on import). Drop JU (didn't
    * exist as canton in 1908). berecht/stimmen needed for weighted regressions
    * in 05_expansion.do.
    local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
    local keepvars "anr"
    foreach ct of local cantons {
        local keepvars "`keepvars' `ct'ja `ct'nein `ct'japroz `ct'bet `ct'berecht `ct'stimmen"
    }
    keep `keepvars'

    * Rename so the canton code is the SUFFIX (reshape long requires j at end)
    foreach ct of local cantons {
        rename `ct'ja       ja`ct'
        rename `ct'nein     nein`ct'
        rename `ct'japroz   japroz`ct'
        rename `ct'bet      bet`ct'
        rename `ct'berecht  berecht`ct'
        rename `ct'stimmen  stimmen`ct'
    }

    gen byte rowid = 1
    reshape long ja nein japroz bet berecht stimmen, i(rowid) j(canton_code) string
    drop rowid anr

    * Standardize canton codes to uppercase
    replace canton_code = upper(canton_code)

    assert c(N) == 25
    isid canton_code

    rename ja       yes_count
    rename nein     no_count
    rename japroz   yes_pct
    rename bet      turnout
    rename berecht  eligible
    rename stimmen  total_votes

    order canton_code, first
    label var canton_code "Canton (2-letter code)"
    label var yes_count   "Yes votes (1908 absinthe ban)"
    label var no_count    "No votes (1908 absinthe ban)"
    label var yes_pct     "Yes-vote share (%, 1908 absinthe ban)"
    label var turnout     "Turnout (%, 1908 absinthe ban)"
    label var eligible    "Eligible voters (1908)"
    label var total_votes "Total ballots cast (1908)"

    compress
    save "$MyProject/processed/intermediate/swissvotes_uncleaned.dta", replace
}


**# 2.3 Same-day placebo: vote #67 (commerce, also July 5 1908)
*------------------------------------------------------------------------------*
{
    * Constitutional article on commerce/trades legislation.
    * Same voters, same day, different issue. If vineyard predicts vote #68
    * but NOT vote #67, the wine-protection mechanism is issue-specific.
    import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
        delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear
    keep if anr == 67
    assert c(N) == 1

    local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
    local keepvars "anr"
    foreach ct of local cantons {
        * Phase B.4 (verify_reconstruct_expand): also extract turnout, eligible
        * voters, total ballots for v67. Together with their v68 analogs in the
        * main extraction (section 2.2), these support the same-day-excess
        * voter analysis: cantons where #68 turnout exceeded #67 turnout had
        * voters who came specifically for the absinthe question.
        local keepvars "`keepvars' `ct'japroz `ct'bet `ct'berecht `ct'stimmen"
    }
    keep `keepvars'
    foreach ct of local cantons {
        rename `ct'japroz japroz`ct'
        rename `ct'bet bet`ct'
        rename `ct'berecht berecht`ct'
        rename `ct'stimmen stimmen`ct'
    }
    gen byte rowid = 1
    reshape long japroz bet berecht stimmen, i(rowid) j(canton_code) string
    drop rowid anr
    replace canton_code = upper(canton_code)
    rename japroz   vote67_yes_pct
    rename bet      turnout_v67
    rename berecht  eligible_v67
    rename stimmen  total_votes_v67

    assert c(N) == 25
    isid canton_code
    label var canton_code      "Canton (2-letter code)"
    label var vote67_yes_pct   "Yes-vote share (%, vote #67 commerce, same-day placebo)"
    label var turnout_v67      "Turnout (%, vote #67 commerce, same-day placebo)"
    label var eligible_v67     "Eligible voters (vote #67, same as #68)"
    label var total_votes_v67  "Total ballots cast (vote #67)"
    order canton_code

    compress
    save "$MyProject/processed/intermediate/vote67_uncleaned.dta", replace
}


**# 2.4 Placebo-referenda panel: all 15 federal votes 1900-1910 (anr 56-70)
*------------------------------------------------------------------------------*
{
    * Falsification design: KEY-spec vineyard coefficient should be null on
    * unrelated federal votes from the same era. If vineyard predicts yes-vote
    * shares broadly across votes, the absinthe finding is a spurious correlation
    * with some omitted canton attribute. If only the absinthe vote (#68) shows
    * a positive coefficient, the wine-protection mechanism is issue-specific.
    *
    * Design ported from Brainstorm-Absinthe ProjectBook entry
    * 2026-04-09_expansion-analysis.qmd Section 2 ("Placebo Referenda Panel
    * 1900-1910"). Window matches: 15 referenda total (anr 56 through 70).
    * Includes vote #68 (treatment) and #67 (same-day placebo) for comparability.
    import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
        delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear
    keep if inrange(anr, 56, 70)
    assert c(N) == 15

    * Keep yes-vote share + turnout/eligible/total_votes (C.6 Phase 0) for each
    * canton + vote metadata. Per-vote turnout and eligible-voter counts are
    * required to compute the differential-mobilization measure on vote #68
    * vs the 14 placebo baseline (Becker-Olson producer-side mobilization
    * channel of the bootleggers-and-baptists coalition).
    local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
    local keepvars "anr datum titel_kurz_d titel_kurz_e rechtsform annahme"
    foreach ct of local cantons {
        local keepvars "`keepvars' `ct'japroz `ct'bet `ct'berecht `ct'stimmen"
    }
    keep `keepvars'

    * Rename canton columns so the canton code is the SUFFIX (reshape requires it)
    foreach ct of local cantons {
        rename `ct'japroz   japroz`ct'
        rename `ct'bet      bet`ct'
        rename `ct'berecht  berecht`ct'
        rename `ct'stimmen  stimmen`ct'
    }

    * Reshape to long: one row per (vote, canton) = 15 * 25 = 375 rows
    reshape long japroz bet berecht stimmen, i(anr) j(canton_code) string
    replace canton_code = upper(canton_code)
    rename japroz   yes_pct
    rename bet      turnout
    rename berecht  eligible
    rename stimmen  total_votes

    * Coerce to numeric (some cells are blank for cantons that didn't vote)
    foreach v in yes_pct turnout eligible total_votes {
        destring `v', replace force ignore(",")
    }

    * Drop observations missing yes_pct (cantons that did not vote on this anr).
    * In our 15-vote / 25-canton design every cell should be populated, but the
    * filter is defensive: a missing yes_pct would propagate through the
    * downstream Simpson analyses.
    drop if missing(yes_pct)
    assert _N == 25 * 15  // 375 placebo observations

    * Parse year from datum (DD.MM.YYYY)
    gen int vote_year = real(substr(datum, -4, 4))

    * Short label for table rows: prefer English title, fall back to German truncated
    gen str80 vote_label = titel_kurz_e
    replace vote_label = substr(titel_kurz_d, 1, 80) if missing(vote_label)

    keep canton_code anr vote_year vote_label rechtsform annahme ///
         yes_pct turnout eligible total_votes
    order canton_code anr vote_year yes_pct turnout eligible total_votes ///
          vote_label rechtsform annahme

    label var canton_code "Canton (2-letter code)"
    label var anr         "Vote number (swissvotes anr)"
    label var vote_year   "Year of vote"
    label var yes_pct     "Yes-vote share (%, this vote, this canton)"
    label var turnout     "Turnout (%, this vote, this canton)"
    label var eligible    "Eligible voters (this vote, this canton)"
    label var total_votes "Total ballots cast (this vote, this canton)"
    label var vote_label  "Short title of vote (English if available)"
    label var rechtsform  "Vote type: 1=mandatory, 2=optional, 3=initiative, 4=counter"
    label var annahme     "1 if vote passed nationally, 0 if rejected"

    * --- C.6 Phase 0 hard-stop verification ---
    qui count
    assert r(N) == 375
    bysort anr: assert _N == 25  // 25 cantons per vote
    qui count if missing(eligible) | eligible == 0
    local n_missing_eligible = r(N)
    qui count if missing(turnout)
    local n_missing_turnout = r(N)
    qui count if !missing(turnout) & !missing(eligible) & total_votes > eligible & !missing(total_votes)
    local n_violation = r(N)
    di _n "*** C.6 Phase 0 placebo-panel data plumbing verification ***"
    di "  Total observations:                   " %5.0f c(N) " (expect 375 = 15 votes x 25 cantons)"
    di "  Missing eligible-voter count:         " %5.0f `n_missing_eligible'
    di "  Missing turnout (%):                  " %5.0f `n_missing_turnout'
    di "  Cells where total_votes > eligible:   " %5.0f `n_violation'

    * Per-vote turnout/eligible coverage table
    di _n "  Per-vote coverage (anr | n_obs | n_miss_eligible | n_miss_turnout):"
    qui levelsof anr, local(allvotes)
    foreach v of local allvotes {
        qui count if anr == `v'
        local n_v = r(N)
        qui count if anr == `v' & missing(eligible)
        local nme = r(N)
        qui count if anr == `v' & missing(turnout)
        local nmt = r(N)
        di "    " %4.0f `v' "    " %2.0f `n_v' "    " %2.0f `nme' "    " %2.0f `nmt'
    }

    * Hard-stop conditions
    if `n_violation' > 0 {
        di as error "  HARD STOP: turnout > eligible in `n_violation' cells. Saving as _DRAFT."
        compress
        save "$MyProject/processed/intermediate/placebo_votes_uncleaned_DRAFT.dta", replace
        error 9
    }

    compress
    save "$MyProject/processed/intermediate/placebo_votes_uncleaned.dta", replace

    di "Placebo panel: " _N " rows (15 votes x 25 cantons = 375)"
    di "Per-vote turnout + eligible coverage verified; saved with full schema."
}


**# 3. Helper macro: HSSO row extractor (defined here for sections 4-7)
*------------------------------------------------------------------------------*
{
    * For each HSSO file we want a single census-year row, transposed to long
    * with one observation per canton. The pattern is identical for all files:
    *   1. import excel ... clear allstring
    *   2. assert A[<row>] == "<year>" then keep in <row>
    *   3. keep B C E F ... AA (the 25 canton columns)
    *   4. strip footnote prefixes ("a)123" -> "123") and asterisks
    *   5. destring _all, replace force
    *   6. xpose, clear varname  (value -> v1; column letter -> _varname)
    *   7. rename v1 <output_var>; recode _varname as col_letter (uppercase)
    *   8. merge 1:1 col_letter using canton_crosswalk; drop col_letter
    *
    * We inline this 8-step pattern in each import section below rather than
    * defining a callable program, because the per-file specifics (target row,
    * output variable name, label) need to be visible at the call site.
}


**# 4. Import I.01 vineyard data (multi-year)
*------------------------------------------------------------------------------*
{
    * Sub-block layout (verified):
    *   Row  4: "Productive agricultural and alpine land..."
    *   Row 16: "Open arable land..."
    *   Row 41: "Cereal cultivation area..."
    *   Row 69: "Potato cultivation area..."
    *   Row 95: "Vineyard area (in hectares)"      <-- target sub-block
    * Vineyard data rows: 99-125. We keep single-year rows {1877, 1884, 1894,
    * 1905, 1913}; drop range-year rows like "1840/55", "1877/90".

    import excel using "$Absinthe1Data/translated/I.01_EN.xlsx", clear allstring

    * Slice the vineyard sub-block (after header row 97)
    keep in 99/125

    * Extract year from column A; strip footnote asterisks; drop year ranges
    rename A year_str
    replace year_str = regexr(year_str, "[*]+", "")
    drop if strpos(year_str, "/") > 0

    destring year_str, gen(year) force
    drop if missing(year)
    keep if inlist(year, 1877, 1884, 1894, 1905, 1913)
    assert c(N) == 5
    drop year_str

    * Keep the 25 canton columns; strip footnotes; destring; rename for reshape
    keep year B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist B-AA {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring B-AA, replace force

    * For multi-year data, we cannot xpose directly (xpose preserves rows->cols
    * and we'd lose year as a dimension). Instead, rename Excel-letter columns
    * to their canton-code equivalents using the crosswalk, then reshape long.
    * (The xpose+merge tidy pattern works only for the single-year HSSO files
    * in sections 5-8 below, where we have one row to transpose.)
    local fromvars "$hsso_excel_cols"
    local tovars ""
    foreach c of global hsso_canton_codes {
        local tovars "`tovars' vha_`c'"
    }
    rename (`fromvars') (`tovars')

    reshape long vha_, i(year) j(canton_code) string
    rename vha_ vineyard_ha

    assert c(N) == 125    // 5 years x 25 cantons
    isid year canton_code

    label var year         "Year"
    label var canton_code  "Canton (2-letter code)"
    label var vineyard_ha  "Vineyard area (hectares)"

    order year canton_code vineyard_ha

    compress
    save "$MyProject/processed/intermediate/vineyard_uncleaned.dta", replace
}


**# 4.05 Import I.01 cereal + potato cultivation sub-blocks (C.12)
*------------------------------------------------------------------------------*
* Substrate-availability descriptive evidence to complement C.10's national
* H.2a producer-price series (07_substrate_descriptives.do).
*
* DATA-AVAILABILITY DISCOVERY (2026-05-12): HSSO I.01's cereal and potato
* sub-blocks have SPARSE pre-vote canton-level coverage. Pre-WWI, only a
* handful of major arable cantons report (1905 cereal: 3 cantons -- ZH,
* BE+JU, VD; 1910 potato: 1 canton -- ZH only). Full canton-level coverage
* (all 25 cantons populated) begins in 1917, presumably tied to WWI-era
* federal substitution surveys. The pre-1917 sub-blocks aggregate to the
* CH national total but break out only the largest contributors.
*
* Decision: extract BOTH (a) the sparse 1905 cereal snapshot for the
* major arable cantons (pre-vote but incomplete) and (b) the 1917
* cereal + potato complete snapshots (9 years post-vote but full
* canton coverage). The 1917 data is appropriate as a descriptive
* PROXY for canton substrate-availability under a geographic-stability
* assumption (canton cereal/potato cultivation distribution is much
* more stable across decades than wine acreage, which fluctuated with
* phylloxera). Paper-text use should explicitly flag the 9-year gap.
*
* Sub-block layout (verified 2026-05-12):
*   Row 41 header: "Cereal cultivation area (in 1000 hectares)"
*   Row 47 = 1905 (3 cantons populated)
*   Row 49 = 1917 (25 cantons populated -- FIRST COMPLETE YEAR)
*   Row 69 header: "Potato cultivation area (in 1000 hectares)"
*   Row 74 = 1910 (1 canton populated -- ZH only)
*   Row 75 = 1917 (25 cantons populated -- FIRST COMPLETE YEAR)
*
* DESCRIPTIVE USE ONLY: these variables are NOT added to the main
* regression spec. Used by paper Background and Discussion sections to
* characterize substrate-availability variation across cantons. Per
* strategist's C.12 dispatch (rev 2 2026-05-12): pairs the H.2a national
* price story with canton-level substrate-availability variation.
{
    * --- Cereal area 1905 (sparse pre-vote snapshot, 3 cantons) + ---
    *     Cereal area 1917 (complete post-vote snapshot, 25 cantons)
    foreach spec in "47 1905" "49 1917" {
        local row : word 1 of `spec'
        local yr  : word 2 of `spec'
        import excel using "$Absinthe1Data/translated/I.01_EN.xlsx", clear allstring
        assert A[`row'] == "`yr'"
        keep in `row'
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        xpose, clear varname
        rename v1 cereal_area_`yr'
        gen str3 col_letter = upper(_varname)
        drop _varname
        merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
            assert(match) nogenerate
        drop col_letter
        order canton_code cereal_area_`yr'
        assert c(N) == 25
        isid canton_code
        tempfile cereal_`yr'
        save "`cereal_`yr''"
    }

    * --- Potato area 1910 (1-canton sparse) + 1917 (25-canton complete) ---
    foreach spec in "74 1910" "75 1917" {
        local row : word 1 of `spec'
        local yr  : word 2 of `spec'
        import excel using "$Absinthe1Data/translated/I.01_EN.xlsx", clear allstring
        assert A[`row'] == "`yr'"
        keep in `row'
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        xpose, clear varname
        rename v1 potato_area_`yr'
        gen str3 col_letter = upper(_varname)
        drop _varname
        merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
            assert(match) nogenerate
        drop col_letter
        order canton_code potato_area_`yr'
        assert c(N) == 25
        isid canton_code
        tempfile potato_`yr'
        save "`potato_`yr''"
    }

    * Combine all four single-year extracts into one canton-level dta
    use "`cereal_1905'", clear
    merge 1:1 canton_code using "`cereal_1917'", assert(match) nogenerate
    merge 1:1 canton_code using "`potato_1910'", assert(match) nogenerate
    merge 1:1 canton_code using "`potato_1917'", assert(match) nogenerate
    order canton_code cereal_area_1905 cereal_area_1917 potato_area_1910 potato_area_1917

    label var canton_code      "Canton (2-letter code)"
    label var cereal_area_1905 "Cereal area (1000 ha, 1905; HSSO I.01; SPARSE -- 3 cantons only)"
    label var cereal_area_1917 "Cereal area (1000 ha, 1917; HSSO I.01; first complete canton year, 9y post-vote)"
    label var potato_area_1910 "Potato area (1000 ha, 1910; HSSO I.01; SPARSE -- ZH only)"
    label var potato_area_1917 "Potato area (1000 ha, 1917; HSSO I.01; first complete canton year, 9y post-vote)"

    compress
    save "$MyProject/processed/intermediate/cereal_potato_area_uncleaned.dta", replace
}


**# 4.1 Import I.01 ag-land sub-block (year 1912, row 10)
*------------------------------------------------------------------------------*
{
    * Productive agricultural and alpine land sub-block (rows 4-14).
    * Header: row 6. Year 1912 = row 10. Units: 1000 hectares.
    * Used for vineyard-share-of-agricultural-land robustness (vine_share_agland).
    import excel using "$Absinthe1Data/translated/I.01_EN.xlsx", clear allstring
    assert A[10] == "1912"
    keep in 10
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force
    xpose, clear varname
    rename v1 agland_1000ha
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code agland_1000ha

    assert c(N) == 25
    isid canton_code
    label var canton_code   "Canton (2-letter code)"
    label var agland_1000ha "Productive ag+alpine land (1000 ha, 1912)"

    compress
    save "$MyProject/processed/intermediate/agland_uncleaned.dta", replace
}


**# 5. Import B.01a population (1900 row only)
*------------------------------------------------------------------------------*
{
    * Tidy xpose+merge pattern. Target: row 31 (1900 census).
    import excel using "$Absinthe1Data/translated/B.01a_EN.xlsx", clear allstring

    assert A[31] == "1900"
    keep in 31
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA

    * Strip footnote prefixes (e.g., "a)119400" -> "119400") and trailing asterisks
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force

    xpose, clear varname
    rename v1 pop_1900
    gen str3 col_letter = upper(_varname)
    drop _varname

    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code pop_1900

    assert c(N) == 25
    isid canton_code
    label var canton_code "Canton (2-letter code)"
    label var pop_1900    "Resident population (persons, 1900 census)"

    compress
    save "$MyProject/processed/intermediate/population_uncleaned.dta", replace
}


**# 6. Import B.01b population density (1900 row only)
*------------------------------------------------------------------------------*
{
    * Target: row 12 (1900). Disclaimer in B.01b: density excludes lake area
    * for cantons with substantial lake territory (e.g., GE, NE).
    import excel using "$Absinthe1Data/translated/B.01b_EN.xlsx", clear allstring

    assert A[12] == "1900"
    keep in 12
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA

    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force

    xpose, clear varname
    rename v1 pop_density_1900
    gen str3 col_letter = upper(_varname)
    drop _varname

    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code pop_density_1900

    assert c(N) == 25
    isid canton_code
    label var canton_code      "Canton (2-letter code)"
    label var pop_density_1900 "Population density (persons/km^2, 1900; excl. lake area)"

    compress
    save "$MyProject/processed/intermediate/pop_density_uncleaned.dta", replace
}


**# 7. Import B.27 religion (1900 Protestant + Catholic counts)
*------------------------------------------------------------------------------*
{
    * Sub-blocks (verified):
    *   Row  6: "Protestant (incl. Protestant sects)"   -> 1900 row = 13
    *   Row 24: "Catholic (Roman + Old Catholic, ...)"  -> 1900 row = 31
    *   Row 42: "Of which: Roman Catholic" (subset)
    *   Rows 55, 68, 86, 93: Eastern Orthodox, Jewish, Muslim, Non-religious
    * We use the broad Catholic definition (row 31), not "Roman only" (row 49).

    * --- Protestant (row 13) ---
    import excel using "$Absinthe1Data/translated/B.27_EN.xlsx", clear allstring
    assert A[13] == "1900"
    keep in 13
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force
    xpose, clear varname
    rename v1 protestant_1900
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    tempfile prot_tmp
    save `prot_tmp'

    * --- Catholic (row 31) ---
    import excel using "$Absinthe1Data/translated/B.27_EN.xlsx", clear allstring
    assert A[31] == "1900"
    keep in 31
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force
    xpose, clear varname
    rename v1 catholic_1900
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter

    * Combine: merge Protestant in
    merge 1:1 canton_code using `prot_tmp', assert(match) nogenerate
    order canton_code protestant_1900 catholic_1900

    assert c(N) == 25
    isid canton_code
    label var canton_code     "Canton (2-letter code)"
    label var protestant_1900 "Protestant population (persons, 1900 census)"
    label var catholic_1900   "Catholic population (Roman + Old Catholic, 1900 census)"

    compress
    save "$MyProject/processed/intermediate/religion_uncleaned.dta", replace
}


**# 8. Import B.32 language (1900 German + French counts)
*------------------------------------------------------------------------------*
{
    * Sub-blocks (verified):
    *   Row  5: "German, Schweizerdeutsch"  -> 1900 row =  9
    *   Row 20: "French"                    -> 1900 row = 24
    *   Rows 35, 50, 65, 80, 90: Italian, Romansh, Other, English, Spanish

    * --- German (row 9) ---
    import excel using "$Absinthe1Data/translated/B.32_EN.xlsx", clear allstring
    assert A[9] == "1900"
    keep in 9
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force
    xpose, clear varname
    rename v1 german_1900
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    tempfile de_tmp
    save `de_tmp'

    * --- French (row 24) ---
    import excel using "$Absinthe1Data/translated/B.32_EN.xlsx", clear allstring
    assert A[24] == "1900"
    keep in 24
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    foreach v of varlist _all {
        replace `v' = regexr(`v', "^[a-z]\)", "")
        replace `v' = regexr(`v', "[*]+", "")
    }
    destring _all, replace force
    xpose, clear varname
    rename v1 french_1900
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter

    * Combine: merge German in
    merge 1:1 canton_code using `de_tmp', assert(match) nogenerate
    order canton_code german_1900 french_1900

    assert c(N) == 25
    isid canton_code
    label var canton_code "Canton (2-letter code)"
    label var german_1900 "German speakers (persons, 1900 census)"
    label var french_1900 "French speakers (persons, 1900 census)"

    compress
    save "$MyProject/processed/intermediate/language_uncleaned.dta", replace
}


**# 9. Import E.1a migration (1900/10 period)
*------------------------------------------------------------------------------*
{
    * E.1a Wanderungsbilanz zwischen zwei Population censuses nach Kantonen.
    * Per-period AVERAGE ANNUAL net migration (positive = net in-migration).
    * We use the 1900/10 row (obs 12 after 1-row title + 1 blank + 1 header + 2
    * blanks + 6 prior year-period rows). 1900/10 is the most recent pre-1908
    * observation period, capturing economic vitality just before the absinthe
    * vote.
    * Strategist's rationale (handoff 2026-04-30): controls for "wine cantons
    * were just declining anyway" alternative explanation.
    *
    * Layout: row 3 = canton header (B=ZH, C=BE,JU, D=BE-only [drop],
    * E=LU, ..., AA=GE), data rows 7-21 are year periods.
    import excel using "$Absinthe1Data/translated/E.1a_EN.xlsx", clear allstring
    assert A[12] == "1900/10"
    keep in 12
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA

    destring _all, replace force

    xpose, clear varname
    rename v1 net_migration_1900_10
    gen str3 col_letter = upper(_varname)
    drop _varname

    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code net_migration_1900_10

    assert c(N) == 25
    isid canton_code
    qui count if missing(net_migration_1900_10)
    assert r(N) == 0
    label var canton_code           "Canton (2-letter code)"
    label var net_migration_1900_10 "Net migration 1900/10, avg per year (persons)"

    compress
    save "$MyProject/processed/intermediate/migration_uncleaned.dta", replace
}


**# 10. Import I.39c parcels per farm (1905, concentration proxy)
*------------------------------------------------------------------------------*
{
    * I.39c Landwirtschaftliche Betriebszählungen — sub-block "Anzahl Parzellen
    * je Betrieb" (parcels per farm). 1905 is the pre-vote year of interest.
    * Strategist's rationale: Olson (1965) collective-action prediction —
    * concentrated industries mobilize politically more easily. Parcels-per-farm
    * is an imperfect concentration proxy: low values can mean either consolidated
    * holdings OR very small subsistence farms; high values can mean either
    * fragmented smallholdings OR mountainous geography. Strategist's preferred
    * `avg_parcel_area_1905` block is NOT in the data — block 4 (mittlere
    * Parzellenfläche) starts at 1929. Documenting this limitation in the
    * footnote of any table that uses parcels_per_farm.
    *
    * Layout (verified row-by-row 2026-04-30, see methods/I39c_inspection.md if
    * created later). 4 blocks per (year, canton):
    *   Block 1 (Anzahl Betriebe / number of farms):       row  8 = 1905
    *   Block 2 (Anzahl Parzellen berechnet / parcels):    row 19 = 1905*
    *   Block 3 (Anzahl Parzellen je Betrieb / parcels/farm): row 30 = 1905*
    *   Block 4 (mittlere Parzellenfläche / mean parcel area in ares):
    *                                                      row 41 = 1929 (NO 1905!)
    * Per the row-54 footnote, the 1905 census used a slightly different
    * definition for small farms (0-0.5 ha range). Block 4 (mean parcel area)
    * was apparently not computed for 1905 due to this. We reconstruct it
    * below in 02_clean.do as agland * 1000 / (farms * parcels_per_farm).

    * --- Block 1: number of farms 1905 (row 8) ---
    import excel using "$Absinthe1Data/translated/I.39c_EN.xlsx", clear allstring
    assert A[8] == "1905"
    keep in 8
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    destring _all, replace force
    xpose, clear varname
    rename v1 farms_1905
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code farms_1905
    assert c(N) == 25
    qui count if missing(farms_1905)
    assert r(N) == 0
    tempfile farms_tmp
    save `farms_tmp'

    * --- Block 3: parcels per farm 1905 (row 30) ---
    import excel using "$Absinthe1Data/translated/I.39c_EN.xlsx", clear allstring
    assert A[30] == "1905*"
    keep in 30
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    destring _all, replace force
    xpose, clear varname
    rename v1 parcels_per_farm_1905
    gen str3 col_letter = upper(_varname)
    drop _varname
    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code parcels_per_farm_1905
    assert c(N) == 25
    qui count if missing(parcels_per_farm_1905)
    assert r(N) == 0

    * --- Combine: merge farms_1905 in ---
    merge 1:1 canton_code using `farms_tmp', assert(match) nogenerate
    order canton_code farms_1905 parcels_per_farm_1905

    isid canton_code
    label var canton_code           "Canton (2-letter code)"
    label var farms_1905            "Number of farms (1905, I.39c block 1)"
    label var parcels_per_farm_1905 "Avg parcels per farm (1905, concentration proxy)"

    compress
    save "$MyProject/processed/intermediate/farm_concentration_uncleaned.dta", replace
}

**# 10.5 Import I.04a fruit-tree stock (1951 — geographic proxy for 1908)
*------------------------------------------------------------------------------*
{
    * I.04a Feldobstbaumbestand nach Kantonen ("Sämtliche Obstbäume" = Total).
    * Pre-vote years (1885/88, 1910, 1926/28) have <=3 cantons populated.
    * First fully-populated year is 1951.
    *
    * STATUS RECONSIDERATION (2026-04-30 user update): the canton-level wine-
    * industry-employment search is now definitively closed. With no better
    * pre-1908 data available, the canonical canton-level proxies for wine-
    * industry size are: vineyard_per_cap + avg_parcel_area_1905 +
    * fruit_tree_density. We therefore IMPORT fruit-tree stock from 1951 as
    * a geographic proxy under an explicit time-stability assumption: canton
    * orchard suitability (climate + topography + soil) is approximately stable
    * over 1908-1951, much more so than wine acreage (which fluctuated with
    * phylloxera and the post-phylloxera replanting). The 43-year gap is the
    * cost of accepting that no 1900-era canton-level fruit-tree data exists.
    *
    * Use of fruit_tree_density: control for "competing-spirits feedstock
    * capacity" — fruit-spirit-producing cantons (Kirsch, Pflümli, Williams)
    * may have had different rent-seeking incentives on the absinthe ban
    * because they had their own competitor distillates.
    *
    * Layout (verified): row 1 = title, row 4 = canton header (B=ZH, C=BE,JU,
    * D=BE-only [drop], E=LU, ..., AA=GE), block 1 ("Sämtliche Obstbäume" total
    * fruit trees) at rows 7-15, with year labels in column A: 1885/88 (row 7),
    * 1910 (8), 1926/28 (9), blank (10), 1951 (11), 1961 (12), 1971 (13),
    * 1981 (14), 1991 (15). 1951 is at obs 11.
    import excel using "$Absinthe1Data/translated/I.04a_EN.xlsx", clear allstring
    assert A[11] == "1951"
    keep in 11
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    destring _all, replace force
    xpose, clear varname
    rename v1 fruit_trees_total_1951
    gen str3 col_letter = upper(_varname)
    drop _varname

    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code fruit_trees_total_1951

    assert c(N) == 25
    isid canton_code
    qui count if missing(fruit_trees_total_1951)
    assert r(N) == 0
    label var canton_code             "Canton (2-letter code)"
    label var fruit_trees_total_1951  "Total fruit trees (1951, in 1000s; geographic proxy for 1908)"

    compress
    save "$MyProject/processed/intermediate/fruit_trees_uncleaned.dta", replace
}


**# 10.5 Import I.51 horticulture (Gartenbau) enterprises 1905 (C.7)
*------------------------------------------------------------------------------*
{
    * Source: HSSO I.51 Federal Horticulture Censuses 1905-1990 by Canton.
    * Sub-table 1 (rows 5-16): "Betriebe" (Enterprises). Year column A,
    * canton columns B-AC. 1905 row is row 7.
    *
    * IMPORTANT TERMINOLOGY: Swiss Gartenbau (horticulture) = vegetable
    * gardens, ornamentals, fruit orchards, plant nurseries. EXCLUDES
    * viticulture (Weinbau, separate industry, captured in I.01). Only the
    * fruit-orchard component directly produces Obstler-substrate spirits;
    * horticulture density is a NOISY proxy for fruit-brandy substrate
    * capacity. Used in C.7 as a co-explanatory test of multi-Bootlegger
    * coalition structure: a positive coefficient on horticulture density
    * (separate from vineyard share) corroborates the claim that the anti-
    * absinthe coalition extended beyond grape-wine producers to include
    * fruit-brandy / Obstler producers.
    *
    * Pre-vote canton matrix is COMPLETE for 1905 (all 25 cantons populated;
    * national total 2,467 enterprises). This is the highest-value unused
    * canton-level pre-vote asset in the HSSO portfolio (per the
    * 2026-05-11 HSSO survey + viti1908 progress note).
    import excel using "$Absinthe1Data/translated/I.51_EN.xlsx", clear allstring
    assert A[7] == "1905"
    keep in 7
    keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
    destring _all, replace force
    xpose, clear varname
    rename v1 horticulture_n_1905
    gen str3 col_letter = upper(_varname)
    drop _varname

    merge 1:1 col_letter using "$MyProject/processed/intermediate/canton_crosswalk.dta", ///
        assert(match) nogenerate
    drop col_letter
    order canton_code horticulture_n_1905

    assert c(N) == 25
    isid canton_code
    qui count if missing(horticulture_n_1905)
    assert r(N) == 0
    label var canton_code         "Canton (2-letter code)"
    label var horticulture_n_1905 "Horticulture enterprises (Gartenbau, 1905; HSSO I.51)"

    * Sanity check: national-level total should be 2,467 enterprises (1905)
    qui summ horticulture_n_1905, meanonly
    local sum_check = r(sum)
    di "  Horticulture 1905 sum across 25 cantons: " %5.0f `sum_check' " (national reference: 2,467)"
    assert abs(`sum_check' - 2467) < 5

    compress
    save "$MyProject/processed/intermediate/horticulture_uncleaned.dta", replace
}


**# 11. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    foreach ds in canton_crosswalk swissvotes_uncleaned vote67_uncleaned ///
                  placebo_votes_uncleaned ///
                  vineyard_uncleaned agland_uncleaned ///
                  population_uncleaned pop_density_uncleaned ///
                  religion_uncleaned language_uncleaned ///
                  migration_uncleaned farm_concentration_uncleaned ///
                  fruit_trees_uncleaned horticulture_uncleaned ///
                  cereal_potato_area_uncleaned {
        _codebook_update using "$MyProject/processed/intermediate/`ds'.dta", ///
            script("01_import.do")
        use "$MyProject/processed/intermediate/`ds'.dta", clear
        local nobs  = c(N)
        local nvars = c(k)
        _inventory_append, sheet("datasets") ///
            row("created|processed/intermediate/`ds'.dta|`nobs'|`nvars'|.|01_import.do")
    }
    _inventory_append, sheet("scripts") ///
        row("01_import.do|.|imports swissvotes CSV and 5 HSSO Excel files|.")
}

** EOF
