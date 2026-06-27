/*==============================================================================
 06_national_descriptives.do
 Purpose:  Extract NATIONAL-LEVEL descriptive statistics from HSSO F-series
           files (F.7a, F.8a, F.13) into long-format archive DTAs.

           CRITICAL: these datasets are NEVER merged into the canton-level
           absinthe_analysis.dta. They have no canton dimension. They serve
           only as paper-text descriptive context (e.g., "In 1905, Switzerland
           had 1,481 spirits/beverage enterprises [F.13]").

           Background: per strategist handoff 2026-04-30, the canton-level
           employment search is definitively closed — HSSO does not have
           pre-1908 canton-by-occupation employment data. F.7a/F.7b/F.8a/F.8b
           and F.13 are all national. These DTAs archive what we found so
           future referees who ask "what about employment data?" can be
           pointed at this archive showing the search was exhausted.

           F.7b and F.8b are translated + mirrored to $Absinthe1Data/translated
           but NOT extracted here — they cover post-vote years (1960-1990 and
           1930-1980 respectively) and are reserved for Paper #2 industry-
           dynamics work.

 Input:    $Absinthe1Data/translated/F.7a_EN.xlsx
           $Absinthe1Data/translated/F.8a_EN.xlsx
           $Absinthe1Data/translated/F.13_EN.xlsx

 Output:   $MyProject/processed/intermediate/f07a_employment_long.dta
           $MyProject/processed/intermediate/f08a_agric_pop_long.dta
           $MyProject/processed/intermediate/f13_business_sector_long.dta

 Author:   Nicholas A Jensen
 Date:     2026-04-30
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

    * --- Year coordinates (verified by inspection of translated _EN.xlsx) ---
    * F.7a: 3 gender blocks at rows 17-24 (Total), 28-35 (Male), 39-46 (Female)
    * F.8a: 3 gender blocks at rows 19-26 (Total), 30-37 (Male), 41-48 (Female)
    * F.13: 6 metric blocks per section; see Section 3 below

    * --- F.7a employment-status mapping ---
    * Cols B-J: 9 employment categories of the active population
    * Col L:    Total active population (Total der berufstaetigen Bev.)
    * Col U:    Total non-active population (Total Nichtaktive)
    * (Cols K and M-T are intermediate aggregates / family-member breakdowns;
    *  not extracted because col L + col U is the cleanest "total population"
    *  decomposition for the R12 fingerprint check vs B.01a.)
    global f7a_letters  "B C D E F G H I J L U"
    global f7a_status   ///
        "solo_workers employers self_employed_total coop_family_members salaried_employees wage_workers home_workers apprentices domestic_workers total_active total_nonactive"

    * --- F.8a worker-category mapping (cols B-Q, in order) -------------------
    * Cols B-I: hauptberuflich (main occupation) breakdown
    * Cols J-M: nebenberuflich (side occupation) breakdown
    * Cols N-Q: total agricultural population
    global f8a_category ///
        "indep_farmers coop_family_farmers nonfamily_workers total_main_occ adults_family children_family total_family total_main_pop side_with_other_main without_main_occ from_farmer_relatives total_side_occ employed_in_ag total_relatives total_ag_pop index_1930_100"

    * --- F.13 industry/sector mappings ---------------------------------------
    * Section A (Industrie und Handwerk): cols B-U = 20 classes
    global f13a_indus   ///
        "foodstuffs spirits_beverages tobacco textiles clothing leather rubber_plastics paper graphic_arts chemical wood_cork toys_carriages stone_earth metals machinery precision_mech music_radio_tv jewelry watches total_industry_handicraft"

    * Section B (Bergbau/Bau/Energie + Tertiaer): cols B-U = 20 classes
    *   B=mining, C=construction, D=utilities,
    *   E=subtotal_bergbau_bau_energie (HSSO "Total" of cols B+C+D),
    *   F=total_secondary (HSSO "Zweiter Sektor" = col E + Section A total),
    *   G-L=wholesale/retail/banks/insurance/real_estate/brokerage,
    *   M=total_commerce (G+H+I+J+K+L subtotal),
    *   N-S=transport/hospitality/health/education/sports_film/other_services,
    *   T=total_tertiary (HSSO "Dritter Sektor"),
    *   U=grand_total (HSSO "Gesamt-total" = col F + col T)
    global f13b_indus   ///
        "mining construction utilities subtotal_bergbau_bau_energie total_secondary wholesale retail banks insurance real_estate brokerage total_commerce transport hospitality health education sports_film other_services total_tertiary grand_total"
}


**# 1. F.7a — Resident population by employment status x gender (1888-1960)
*------------------------------------------------------------------------------*
* National only. Values are in thousands of persons (per F.7b row 15 unit note).
* Translated _EN.xlsx still contains German fragments in headers because the
* dictionary doesn't cover all multi-syllable terms; we hardcode column meanings.
*
* Year block layout (verified 2026-04-30):
*   Total (Gesamtbev.):   rows 17-24  years 1888,1900,1910,1920,1930,1941,1950,1960
*   Male  (Maenner):      rows 28-35  same year sequence
*   Female (Frauen):      rows 39-46  same year sequence
{
    * --- Verify file structure with year anchors ---
    import excel using "$Absinthe1Data/translated/F.7a_EN.xlsx", ///
        sheet("Worksheet") clear allstring
    assert A[17] == "1888"
    assert A[18] == "1900"
    assert A[24] == "1960"
    assert A[28] == "1888"
    assert A[35] == "1960"
    assert A[39] == "1888"
    assert A[46] == "1960"

    * --- Extract 3 gender blocks (cols A-U; we keep A,B-J,L,U; drop K,M-T) ---
    tempfile f7a_total f7a_male

    import excel using "$Absinthe1Data/translated/F.7a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A17:U24) clear allstring
    gen str50 gender_group = "total"
    save `f7a_total'

    import excel using "$Absinthe1Data/translated/F.7a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A28:U35) clear allstring
    gen str50 gender_group = "male"
    save `f7a_male'

    import excel using "$Absinthe1Data/translated/F.7a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A39:U46) clear allstring
    gen str50 gender_group = "female"
    append using `f7a_total' `f7a_male'

    * --- Rename and destring (paired letter+name globals; skip unwanted cols) -
    rename A year_str
    destring year_str, gen(year)
    drop year_str

    local n_cats : word count $f7a_status
    forvalues i = 1/`n_cats' {
        local letter : word `i' of $f7a_letters
        local status : word `i' of $f7a_status
        rename `letter' val_`status'
        destring val_`status', replace force
    }

    * Drop intermediate aggregate / family-member breakdown cols we didn't keep
    drop K M N O P Q R S T

    * --- Reshape long ---
    reshape long val_, i(year gender_group) j(employment_status) string
    rename val_ value

    * --- Tag pre-vote (year <= 1908) ---
    gen byte pre_vote = (year <= 1908)
    label var pre_vote "1 = pre-absinthe-ban (year <= 1908)"

    * --- Order, label, save ---
    order year gender_group employment_status value pre_vote
    sort year gender_group employment_status

    label var year              "Census year (national)"
    label var gender_group      "Gender block (total / male / female)"
    label var employment_status "Employment status category"
    label var value             "Population in thousands of persons"

    notes drop _all
    notes : Source: HSSO Table F.7a, "Wohnbevoelkerung nach Erwerbszugehoerigkeit und Geschlecht 1888-1960 (excl. part-time)"
    notes : Coverage: 1888, 1900, 1910, 1920, 1930, 1941, 1950, 1960 (national only).
    notes : NATIONAL-LEVEL data only -- DO NOT merge into canton-level absinthe_analysis.dta.
    notes : Pre-vote rows: pre_vote==1 (1888 and 1900). Use for paper-text descriptives.

    compress
    save "$MyProject/processed/intermediate/f07a_employment_long.dta", replace
    di as text "  -> f07a_employment_long.dta saved (N=" c(N) ")"
}


**# 2. F.8a — Agricultural population x gender (1888-1960)
*------------------------------------------------------------------------------*
* National only. Values are absolute counts (persons), not thousands.
*
* Year block layout (verified 2026-04-30):
*   Total (Gesamtbev.):  rows 19-26  years 1888,1900,1910,1920*,1930,1941**,1950**,1960
*   Male  (Maenner):     rows 30-37  same sequence
*   Female (Frauen):     rows 41-48  same sequence
* * = 1920 ohne Pensionaere d'etablissements; ** = 1941/1950 with restricted def.
{
    * --- Verify ---
    import excel using "$Absinthe1Data/translated/F.8a_EN.xlsx", ///
        sheet("Worksheet") clear allstring
    assert A[19] == "1888"
    assert A[20] == "1900"
    assert A[26] == "1960"
    assert A[30] == "1888"
    assert A[37] == "1960"
    assert A[41] == "1888"
    assert A[48] == "1960"

    * --- Extract 3 gender blocks (cols A-Q = year + 16 categories) -----------
    tempfile f8a_total f8a_male

    import excel using "$Absinthe1Data/translated/F.8a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A19:Q26) clear allstring
    gen str50 gender_group = "total"
    save `f8a_total'

    import excel using "$Absinthe1Data/translated/F.8a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A30:Q37) clear allstring
    gen str50 gender_group = "male"
    save `f8a_male'

    import excel using "$Absinthe1Data/translated/F.8a_EN.xlsx", ///
        sheet("Worksheet") cellrange(A41:Q48) clear allstring
    gen str50 gender_group = "female"
    append using `f8a_total' `f8a_male'

    * --- Strip year suffix flags (e.g., "1920*", "1941**") and store flag ----
    gen str50 year_flag = ""
    replace year_flag = "*"  if strpos(A, "*") > 0 & strpos(A, "**") == 0
    replace year_flag = "**" if strpos(A, "**") > 0
    replace A = subinstr(A, "*", "", .)
    rename A year_str
    destring year_str, gen(year)
    drop year_str

    * --- Rename and destring 16 category cols ---
    local i = 0
    foreach categ of global f8a_category {
        local i = `i' + 1
        local letter : word `i' of B C D E F G H I J K L M N O P Q
        rename `letter' val_`categ'
        destring val_`categ', replace force
    }

    * --- Reshape long ---
    reshape long val_, i(year gender_group) j(worker_category) string
    rename val_ value

    gen byte pre_vote = (year <= 1908)
    label var pre_vote "1 = pre-absinthe-ban (year <= 1908)"

    order year year_flag gender_group worker_category value pre_vote
    sort year gender_group worker_category

    label var year             "Census year (national)"
    label var year_flag        "HSSO year-asterisk footnote (* or **)"
    label var gender_group     "Gender block (total / male / female)"
    label var worker_category  "Agricultural worker category"
    label var value            "Persons (absolute count)"

    notes drop _all
    notes : Source: HSSO Table F.8a, "Landwirtschaftliche Bevoelkerung 1888-1960 (excl. part-time)"
    notes : Coverage: 1888, 1900, 1910, 1920*, 1930, 1941**, 1950**, 1960 (national only).
    notes : Year-flag *: 1920 ohne Pensionaere d'etablissements
    notes : Year-flag **: 1941/1950 use restricted definition; see HSSO source notes.
    notes : NATIONAL-LEVEL data only -- DO NOT merge into canton-level absinthe_analysis.dta.
    notes : Pre-vote rows: pre_vote==1 (1888 and 1900). Use for paper-text descriptives.

    compress
    save "$MyProject/processed/intermediate/f08a_agric_pop_long.dta", replace
    di as text "  -> f08a_agric_pop_long.dta saved (N=" c(N) ")"
}


**# 3. F.13 — Industrial business census, by industry x metric x gender (1905, 1929, 1939, 1955)
*------------------------------------------------------------------------------*
* National only. F.13 has TWO sections each with 6 metric blocks of 4 year rows.
*
* Section A (rows 4-53): Industrie und Handwerk, 20 industry classes (cols B-U)
*   Block 1 (rows 15-18): n_enterprises (Betriebe)
*   Block 2 (rows 22-25): n_employees_total (Total beschaeftigte Personen)
*   Block 3 (rows 29-32): mean_employees_per_enterprise (Mittlere Zahl)
*   Block 4 (rows 36-39): n_employees_male (Beschaeftigte Maenner)
*   Block 5 (rows 43-46): n_employees_female (Beschaeftigte Frauen)
*   Block 6 (rows 50-53): n_women_per_1000_men (Auf 1000 Maenner kommen Frauen)
*
* Section B (rows 55-108): Bergbau/Bau/Energie + Tertiaer, 20 industry classes (cols B-U)
*   Block 1 (rows 66-69): n_enterprises
*   Block 2 (rows 73-76): n_employees_total
*   Block 3 (rows 80-83): mean_employees_per_enterprise
*   Block 4 (rows 87-90): n_employees_male
*   Block 5 (rows 94-97): n_employees_female
*   Block 6 (rows 101-104): n_women_per_1000_men
{
    * --- Verify file structure (use year anchors in both sections) -----------
    import excel using "$Absinthe1Data/translated/F.13_EN.xlsx", ///
        sheet("Worksheet") clear allstring
    assert A[15] == "1905"
    assert A[18] == "1955"
    assert A[22] == "1905"
    assert A[36] == "1905"
    assert A[43] == "1905"
    assert A[50] == "1905"
    assert A[66] == "1905"
    assert A[69] == "1955"
    assert A[73] == "1905"
    assert A[87] == "1905"
    assert A[94] == "1905"
    assert A[101] == "1905"

    * --- Helper: extract one metric block, tag, save to tempfile -------------
    * Approach: 6 metrics x 2 sections = 12 blocks. Each block has 4 rows
    * (years 1905, 1929, 1939, 1955) and N industry cols. We extract each as
    * cellrange, rename cols, reshape long, append to running master.

    tempfile master
    local first_save = 1

    * --- Section A: Industrie und Handwerk (cols B-U = 20 classes) ----------
    foreach pair in "15:18 n_enterprises" "22:25 n_employees_total" ///
                    "29:32 mean_employees_per_enterprise" ///
                    "36:39 n_employees_male" "43:46 n_employees_female" ///
                    "50:53 n_women_per_1000_men" {
        tokenize "`pair'"
        local rng `1'
        local mtr `2'
        local r1 = substr("`rng'", 1, strpos("`rng'",":")-1)
        local r2 = substr("`rng'", strpos("`rng'",":")+1, .)

        import excel using "$Absinthe1Data/translated/F.13_EN.xlsx", ///
            sheet("Worksheet") cellrange(A`r1':U`r2') clear allstring

        rename A year_str
        destring year_str, gen(year)
        drop year_str

        local i = 0
        foreach ind of global f13a_indus {
            local i = `i' + 1
            local letter : word `i' of B C D E F G H I J K L M N O P Q R S T U
            rename `letter' val_`ind'
            destring val_`ind', replace force
        }

        gen str50 metric  = "`mtr'"
        gen str50 section = "industry_handicraft"

        reshape long val_, i(year metric section) j(industry_class) string
        rename val_ value

        if `first_save' {
            save `master'
            local first_save = 0
        }
        else {
            append using `master'
            save `master', replace
        }
    }

    * --- Section B: Bergbau/Bau/Energie + Tertiaer (cols B-U = 20 classes) --
    foreach pair in "66:69 n_enterprises" "73:76 n_employees_total" ///
                    "80:83 mean_employees_per_enterprise" ///
                    "87:90 n_employees_male" "94:97 n_employees_female" ///
                    "101:104 n_women_per_1000_men" {
        tokenize "`pair'"
        local rng `1'
        local mtr `2'
        local r1 = substr("`rng'", 1, strpos("`rng'",":")-1)
        local r2 = substr("`rng'", strpos("`rng'",":")+1, .)

        import excel using "$Absinthe1Data/translated/F.13_EN.xlsx", ///
            sheet("Worksheet") cellrange(A`r1':U`r2') clear allstring

        rename A year_str
        destring year_str, gen(year)
        drop year_str

        local i = 0
        foreach ind of global f13b_indus {
            local i = `i' + 1
            local letter : word `i' of B C D E F G H I J K L M N O P Q R S T U
            rename `letter' val_`ind'
            destring val_`ind', replace force
        }

        gen str50 metric  = "`mtr'"
        gen str50 section = "secondary_tertiary"

        reshape long val_, i(year metric section) j(industry_class) string
        rename val_ value

        append using `master'
        save `master', replace
    }

    * --- Final cleanup ---
    use `master', clear

    gen byte pre_vote = (year <= 1908)
    label var pre_vote "1 = pre-absinthe-ban (year <= 1908)"

    order year section industry_class metric value pre_vote
    sort year section industry_class metric

    label var year           "Census year (national)"
    label var section        "industry_handicraft (cols B-U) or secondary_tertiary (cols B-U)"
    label var industry_class "Industry/sector class"
    label var metric         "Reported metric (enterprises, employees, ratios)"
    label var value          "Reported value (units depend on metric)"

    notes drop _all
    notes : Source: HSSO Table F.13, "Gewerbliche Betriebszaehlungen 1905, 1929, 1939, 1955"
    notes : Two sections: industry_handicraft (20 classes) and secondary_tertiary (20 classes)
    notes : 6 metrics per section: n_enterprises, n_employees_total, mean_employees_per_enterprise, n_employees_male, n_employees_female, n_women_per_1000_men
    notes : Coverage: 1905, 1929, 1939, 1955 (national only). pre_vote==1 only at year==1905.
    notes : NATIONAL-LEVEL data only -- DO NOT merge into canton-level absinthe_analysis.dta.
    notes : Spirits/beverages industry (industry_class=="spirits_beverages") in 1905: 1481 enterprises, 6539 employees -- paper-text descriptive context for absinthe-ban competitive landscape.

    compress
    save "$MyProject/processed/intermediate/f13_business_sector_long.dta", replace
    di as text "  -> f13_business_sector_long.dta saved (N=" c(N) ")"
}


**# 4. Sanity-check assertions on key reported numbers
*------------------------------------------------------------------------------*
* These are paper-text-relevant quantities. If any assertion fails, the data
* extraction has drifted and downstream paper claims are wrong.
{
    * --- F.7a 1900 total active population (Selbstandige + Arbeitnehmer) -----
    use "$MyProject/processed/intermediate/f07a_employment_long.dta", clear
    summ value if year==1900 & gender_group=="total" ///
                & employment_status=="self_employed_total", meanonly
    * 1900 self-employed total: 425.46 thousand (per F.7a R18 col D)
    assert abs(r(mean) - 425.46) < 0.01

    summ value if year==1900 & gender_group=="total" ///
                & employment_status=="salaried_employees", meanonly
    * 1900 salaried employees: 134.224 thousand
    assert abs(r(mean) - 134.224) < 0.01

    * --- R12 cross-data fingerprint: F.7a 1900 total pop = active + nonactive
    *     ~3.32M (matches B.01a 1900 national sum across cantons) ------------
    summ value if year==1900 & gender_group=="total" ///
                & employment_status=="total_active", meanonly
    local active_1900 = r(mean)         // expected ~1555.247 thousand
    summ value if year==1900 & gender_group=="total" ///
                & employment_status=="total_nonactive", meanonly
    local nonact_1900 = r(mean)         // expected ~1760.196 thousand
    local total_1900 = `active_1900' + `nonact_1900'
    di as text "F.7a 1900 active+nonactive = " %9.3f `total_1900' " thousand"
    * Expected ~3315 thousand (cross-checks against B.01a national 1900 ~3.32M)
    assert abs(`total_1900' - 3315.443) < 1

    * Cross-data check: B.01a canton-pop sum 1900 should match F.7a national
    preserve
    use "$MyProject/processed/intermediate/population_uncleaned.dta", clear
    qui summ pop_1900
    local b01a_canton_sum = r(sum) / 1000   // convert to thousands
    restore
    di as text "B.01a 1900 canton-pop sum    = " %9.3f `b01a_canton_sum' " thousand"
    * Both sources should agree to <0.5% (small rounding/reclassification gaps OK)
    assert abs(`total_1900' - `b01a_canton_sum') / `total_1900' < 0.005

    * --- F.8a 1900 grand total agricultural population -----------------------
    use "$MyProject/processed/intermediate/f08a_agric_pop_long.dta", clear
    summ value if year==1900 & gender_group=="total" ///
                & worker_category=="total_main_pop", meanonly
    * 1900 total main-occupation ag pop: 1,033,427 (per F.8a R20 col I)
    assert abs(r(mean) - 1033427) < 1

    summ value if year==1900 & gender_group=="total" ///
                & worker_category=="indep_farmers", meanonly
    * 1900 independent farmers: 211,641
    assert abs(r(mean) - 211641) < 1

    * --- F.13 1905 spirits/beverages: paper-text headline number -------------
    use "$MyProject/processed/intermediate/f13_business_sector_long.dta", clear
    summ value if year==1905 & section=="industry_handicraft" ///
                & industry_class=="spirits_beverages" ///
                & metric=="n_enterprises", meanonly
    assert abs(r(mean) - 1481) < 1   // 1,481 spirits/beverage firms in 1905

    summ value if year==1905 & section=="industry_handicraft" ///
                & industry_class=="spirits_beverages" ///
                & metric=="n_employees_total", meanonly
    assert abs(r(mean) - 6539) < 1   // 6,539 employees in spirits/beverages

    * --- F.13 1905 foodstuffs (largest food sector for context) --------------
    summ value if year==1905 & section=="industry_handicraft" ///
                & industry_class=="foodstuffs" ///
                & metric=="n_enterprises", meanonly
    assert abs(r(mean) - 18660) < 1  // 18,660 food enterprises

    * --- R12-style fingerprint for F.13: 1905 row totals (cross-check vs the
    *     "Total" column shipped by HSSO at end of each section) -------------
    summ value if year==1905 & section=="industry_handicraft" ///
                & industry_class=="total_industry_handicraft" ///
                & metric=="n_enterprises", meanonly
    * 1905 industry+handicraft total enterprises: 108,859 (per F.13 R15 col U)
    assert abs(r(mean) - 108859) < 1

    summ value if year==1905 & section=="secondary_tertiary" ///
                & industry_class=="grand_total" ///
                & metric=="n_enterprises", meanonly
    * 1905 secondary+tertiary grand total enterprises: 237,989 (per F.13 R66 col U)
    assert abs(r(mean) - 237989) < 1

    di as text ""
    di as text "ALL F-SERIES SANITY-CHECK ASSERTIONS PASSED"
    di as text ""
}


**# 5. Display headline 1905 paper-text statistics
*------------------------------------------------------------------------------*
* These are descriptive numbers the paper text can cite. Pre-vote only.
{
    use "$MyProject/processed/intermediate/f13_business_sector_long.dta", clear
    keep if year==1905 & metric=="n_employees_total" & section=="industry_handicraft"
    keep industry_class value
    rename value n_employees_1905
    sort n_employees_1905
    di as text ""
    di as text "==== 1905 employment by industry class (Industrie und Handwerk, national) ===="
    list industry_class n_employees_1905, noobs sep(0) ab(35)
    di as text ""

    * Show spirits-vs-food contrast for the paper:
    use "$MyProject/processed/intermediate/f13_business_sector_long.dta", clear
    keep if year==1905 & section=="industry_handicraft" ///
            & inlist(industry_class, "spirits_beverages", "foodstuffs", "tobacco")
    keep industry_class metric value
    di as text "==== 1905 spirits vs food vs tobacco (national) ===="
    list industry_class metric value, noobs sepby(industry_class) ab(35)
    di as text ""
}


**# 6. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    foreach ds in f07a_employment_long f08a_agric_pop_long f13_business_sector_long {
        _codebook_update using "$MyProject/processed/intermediate/`ds'.dta", ///
            script("06_national_descriptives.do")
        use "$MyProject/processed/intermediate/`ds'.dta", clear
        local nobs  = c(N)
        local nvars = c(k)
        _inventory_append, sheet("datasets") ///
            row("created|processed/intermediate/`ds'.dta|`nobs'|`nvars'|.|06_national_descriptives.do")
    }
    _inventory_append, sheet("scripts") ///
        row("06_national_descriptives.do|.|extracts NATIONAL-LEVEL HSSO F-series (F.7a/F.8a/F.13) into long-format archive DTAs|.")
}

** EOF
