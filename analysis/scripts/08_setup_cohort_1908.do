/*==============================================================================
 08_setup_cohort_1908.do
 Purpose:  Minimalist from-scratch verification build for the 1908 referendum
           cohort (votes 67, 68, 69). Loads raw swissvotes per-canton yes-share
           and merges in PI's verified canton-level 1907 wine table. Output is
           one cohort-level .dta containing all three 1908 vote shares + wine
           variables for 25 cantons.

           Independent of 02_clean.do / absinthe_analysis.dta. Built fresh so
           we can verify the new wine measure against the model spec without
           inheriting any assumptions from the main pipeline.

 Input:    $Absinthe1Data/swissvotes_dataset.csv             (raw swissvotes)
           $MyProject/processed/canton_wine_1907_pi.csv      (PI Excel -> CSV,
                                                              built by
              scripts/python/build_canton_wine_1907_pi.py)
           $Absinthe1Data/translated/B.32_EN.xlsx            (HSSO language, 1900)
           $Absinthe1Data/translated/B.01a_EN.xlsx           (HSSO population, 1900 + 1910)
           $Absinthe1Data/translated/B.27_EN.xlsx            (HSSO religion, 1900)
           $Absinthe1Data/translated/B.01b_EN.xlsx           (HSSO pop density, 1900;
                                                              used to algebraically
                                                              derive canton land area
                                                              via pop_1900/density_1900)
           $Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx
                                                             (Milliet 1907 firm-level
                                                              absinthe industry; PI
                                                              translated/verified)

 Output:   $MyProject/processed/cohort_1908.dta   (25 cantons, 1908 cohort)

 Author:   Nicholas A Jensen
 Date:     2026-05-18
 Version:  1.0

 Variable naming convention (per PI 2026-05-18):
   - Vote variables suffixed with vote number: pct_yes_67, yes_count_67, etc.
   - Wine variables keep their canton-level names from the CSV
     (wine_area_canton_ha, etc.) since the 1907 wine data is cohort-orthogonal
     and applies to the whole 1908 cohort.
   - Construction variables (counts, eligible, turnout) kept alongside
     pct_yes_* so they can be dropped later if not needed.
   - Language: subset-denominator shares (fr/(de+fr), de/(de+fr)) are primary.
     Total-pop denominator variants can be added trivially by also loading
     B.01a_EN.xlsx; deferred until needed.
   - Religion: subset-denominator shares (cath/(cath+prot), prot/(cath+prot))
     are primary, following project precedent from 02_clean.do §2.1.  Other
     religions (Jewish, Orthodox, Other, None) are ~1.5% of 1900 pop nationally
     and orthogonal to the confessional cleavage M1A cares about; deferred.
   - Policy dummies (e.g., prior_canton_ban): hardcoded from primary archival
     sources -- no raw data file to read.  Provenance + canton-coding table
     documented in the section's leading comment block; section assertions
     encode the coding (e.g., "exactly {VD, GE} = 1") so any future edit that
     accidentally breaks the coding fires at re-run time.
==============================================================================*/

/* Pre-run reminder
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do" %for setup
*/

* Stata version control (set in _config.do; explicit here for standalone runs)
version 19

* Standalone-execution preamble
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}


**# 0. Preamble
*------------------------------------------------------------------------------*
{
    * Three referenda in the 1908 cohort. We process them as a unit because
    * they were voted on the same federal cycle (67 + 68 on 1908-07-05;
    * 69 on 1908-10-25) by the same electorate using the same cantonal
    * voter rolls. Same-day cross-vote comparisons (67 vs 68) and
    * within-year same-electorate placebos (69 vs 68) both live here.
    local cohort_votes 67 68 69

    * 25 cantons in the 1908 universe (BE absorbs JU; JU didn't exist as a
    * separate canton until 1979). Lowercase here to match swissvotes column
    * naming (e.g., zhja, beja, etc.).
    local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
}


**# 1. Load vote shares from raw swissvotes
*------------------------------------------------------------------------------*

**# 1.1 Import raw swissvotes and filter to the 1908 cohort
*------------------------------------------------------------------------------*
{
    * Semicolon-delimited UTF-8 BOM file. `case(lower)` makes every column
    * name lowercase; `bindquote(strict)` handles fields with embedded
    * delimiters cleanly. Hyphens in HSSO column names are stripped by
    * `import delimited` so e.g. `zh-ja` becomes `zhja`.
    import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
        delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear
    di "Imported swissvotes: " c(N) " votes, " c(k) " columns"

    keep if inlist(anr, 67, 68, 69)
    assert c(N) == 3
    di "Kept 3 rows for 1908 cohort (anr in 67/68/69)"
}


**# 1.2 Keep canton-vote columns; rename so canton code is the SUFFIX
*------------------------------------------------------------------------------*
{
    * For each canton + each metric we want, build the keep list.
    * Six per-canton metrics retained:
    *   <ct>ja       -> yes_count
    *   <ct>nein     -> no_count
    *   <ct>japroz   -> pct_yes (yes-vote share, %)
    *   <ct>bet      -> turnout (%)
    *   <ct>berecht  -> eligible voters
    *   <ct>stimmen  -> total ballots cast
    local keepvars "anr"
    foreach ct of local cantons {
        local keepvars "`keepvars' `ct'ja `ct'nein `ct'japroz `ct'bet `ct'berecht `ct'stimmen"
    }
    keep `keepvars'

    * `reshape long` requires the j-variable to be the SUFFIX of stub names.
    * Currently canton code is PREFIX (e.g., `zhja`); rename so the metric
    * is the prefix and the canton is the suffix (e.g., `ja_zh`).
    foreach ct of local cantons {
        rename `ct'ja       ja_`ct'
        rename `ct'nein     nein_`ct'
        rename `ct'japroz   japroz_`ct'
        rename `ct'bet      bet_`ct'
        rename `ct'berecht  berecht_`ct'
        rename `ct'stimmen  stimmen_`ct'
    }
}


**# 1.3 Reshape long: 3 votes × 25 cantons = 75 rows
*------------------------------------------------------------------------------*
{
    reshape long ja_ nein_ japroz_ bet_ berecht_ stimmen_, i(anr) j(canton_iso) string
    replace canton_iso = upper(canton_iso)
    rename ja_       yes_count
    rename nein_     no_count
    rename japroz_   pct_yes
    rename bet_      turnout
    rename berecht_  eligible
    rename stimmen_  total_votes

    * Coerce string-imported numerics
    foreach v of varlist yes_count no_count pct_yes turnout eligible total_votes {
        capture confirm numeric variable `v'
        if _rc destring `v', replace force ignore(",")
    }

    assert c(N) == 75   // 3 votes × 25 cantons
    isid anr canton_iso
    di "Long-format vote-canton panel: 75 rows (3 votes x 25 cantons)"
}


**# 1.4 Reshape wide on anr: 25 cantons × {metric}_{vote} columns
*------------------------------------------------------------------------------*
{
    * Now reshape WIDE on anr so each canton is a single row with one column
    * per (metric, vote). Resulting column names like ja67, ja68, ja69.
    reshape wide yes_count no_count pct_yes turnout eligible total_votes, ///
        i(canton_iso) j(anr)
    assert c(N) == 25
    isid canton_iso

    * Rename the auto-generated columns from `<metric><anr>` to PI's preferred
    * convention `<metric>_<anr>` (underscore-separated). After this block
    * we'll have: pct_yes_67, pct_yes_68, pct_yes_69, yes_count_67, ...
    foreach v of local cohort_votes {
        rename yes_count`v'   yes_count_`v'
        rename no_count`v'    no_count_`v'
        rename pct_yes`v'     pct_yes_`v'
        rename turnout`v'     turnout_`v'
        rename eligible`v'    eligible_`v'
        rename total_votes`v' total_votes_`v'

        * Labels — units in label per project convention
        label var pct_yes_`v'     "Vote `v' yes-share (%, 1908 cohort)"
        label var yes_count_`v'   "Vote `v' yes votes"
        label var no_count_`v'    "Vote `v' no votes"
        label var turnout_`v'     "Vote `v' turnout (%)"
        label var eligible_`v'    "Vote `v' eligible voters"
        label var total_votes_`v' "Vote `v' total ballots cast"
    }
    label var canton_iso "Canton (2-letter code, 1908)"

    di "Wide-format cohort panel: 25 cantons x 18 vote columns"
    di "  Cohort votes: pct_yes_67 (commerce), pct_yes_68 (absinthe ban), pct_yes_69 (employment proportional representation)"
}


**# 2. Merge in PI's verified canton wine 1907
*------------------------------------------------------------------------------*

**# 2.0 Standalone-run preamble: load §1 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = total_votes_69 (last var added by §1.4).  If it's absent,
* in-memory state is missing §1 output entirely OR is a stale partial build --
* either way, reload the canonical on-disk cohort_1908.dta.  This is stricter
* than checking canton_iso (which would succeed for any nonempty memory state).
{
    cap confirm variable total_votes_69
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §2 needs §1 output (total_votes_69) but cohort_1908.dta not found."
            di as error "  Run §1 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in wine_area_canton_ha wine_volume_canton_hl wine_revenue_canton_fr ///
                 wine_yield_canton_hl_per_ha wine_revenue_share_canton {
        cap drop `v'
    }
}


**# 2.1 Import the cleaned wine CSV into a tempfile
*------------------------------------------------------------------------------*
{
    preserve
        import delimited using "$MyProject/processed/canton_wine_1907_pi.csv", ///
            varnames(1) stringcols(1) bindquote(strict) clear
        assert c(N) == 25
        isid canton_iso
        * Label wine vars (units already in the variable names)
        label var canton_iso                  "Canton (2-letter code, 1908)"
        label var wine_area_canton_ha         "Wine cultivated area, canton (ha, 1907)"
        label var wine_volume_canton_hl       "Wine total yield, canton (hl, 1907)"
        label var wine_revenue_canton_fr      "Wine total value, canton (Fr, 1907)"
        label var wine_yield_canton_hl_per_ha "Wine yield, canton (hl/ha, 1907)"
        label var wine_revenue_share_canton   "Wine revenue share of CH total (0-1, 1907)"
        tempfile wine_pi
        save `wine_pi'
    restore
}


**# 2.2 Merge 1:1 on canton_iso; assert all 25 match
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `wine_pi', assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso

    di "Merged wine 1907 into cohort: 25 cantons matched on canton_iso"
}


**# 3. Add language shares (French, German) from HSSO B.32 (1900 census)
*------------------------------------------------------------------------------*

**# 3.0 Standalone-run preamble: load §1+§2 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Lets you Ctrl+D this section standalone without first re-running §1+§2.
* Sentinel var = wine_revenue_share_canton (last var added by §2.1).  If it's
* absent, in-memory state is missing §2 output (you ran §3 in isolation, or
* memory is stale) -- reload the canonical on-disk cohort checkpoint.  Stricter
* than checking canton_iso (which would succeed for any nonempty memory state).
* Also drops language vars from any prior §3 run so the merge below doesn't
* collide -- §3 is idempotent under repeated Ctrl+D execution.
{
    cap confirm variable wine_revenue_share_canton
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §3 needs §1+§2 output (wine_revenue_share_canton) but cohort_1908.dta not found."
            di as error "  Run §1 + §2 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in german_1900 french_1900 french_share german_share {
        cap drop `v'
    }
}


* B.32 layout (verified 2026-05-18):
*   Row 3:  header row  -- col A = "Year", col B = "ZH", col C = "BE, JU",
*                          col D = "BE" (separate), col E = "LU", ...,
*                          col AA = "GE", col AB = "JU", col AC = "CH", col AD = year-dup
*   Row 5:  sub-block header "German, Schweizerdeutsch"   -> Row  9 = 1900 data
*   Row 20: sub-block header "French"                     -> Row 24 = 1900 data
*   Row 35: sub-block header "Italian"                    -> Row 39 = 1900 data
*   Row 50: sub-block header "Romansh"                    -> Row 54 = 1900 data
*   Row 65: sub-block header "Other native language"      -> Row 69 = 1900 data
*   Row 100: sub-block header "Total"                     -> Row 104 = 1900 data
*
* BE/JU rule (per project convention): Jura was not a separate canton in 1908.
* Use col C (combined BE+JU) as BE; drop D (BE-only), AB (JU-only), AC (CH-total),
* AD (Year-duplicate).  This yields exactly 25 canton columns: B C E F G H I J K
* L M N O P Q R S T U V W X Y Z AA.

**# 3.1 Helper: import one sub-block row, return tempfile with canton_iso + value
*------------------------------------------------------------------------------*
{
    * Each language sub-block has identical layout, only the target row + output
    * variable name differ.  We extract two (German row 9, French row 24) using
    * the same pattern; capture-replay rather than a callable program because
    * the pattern is short and the variability is just (row, varname).

    * --- 3.1a German 1900 (B.32 row 9) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.32_EN.xlsx", clear allstring
        assert A[9] == "1900"
        keep in 9
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        * Strip HSSO footnote prefixes ("a)1234" -> "1234") and asterisks
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 german_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile lang_german
        save `lang_german'
    restore

    * --- 3.1b French 1900 (B.32 row 24) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.32_EN.xlsx", clear allstring
        assert A[24] == "1900"
        keep in 24
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 french_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile lang_french
        save `lang_french'
    restore
}


**# 3.2 Merge both onto cohort_1908 in memory; assert all 25 match
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `lang_german', assert(match) nogenerate
    merge 1:1 canton_iso using `lang_french', assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso

    label var german_1900 "German speakers (HSSO B.32, 1900 census, persons)"
    label var french_1900 "French speakers (HSSO B.32, 1900 census, persons)"
}


**# 3.3 Construct subset-denominator shares
*------------------------------------------------------------------------------*
{
    * Subset denominator (German + French only) per project convention from
    * analysis/scripts/02_clean.do §2.1.  Focuses on the language cleavage that
    * drives federal politics; Italian/Romansh treated as orthogonal.  Sums to 1
    * exactly by construction.  Total-pop denominator variants are NOT generated
    * here; if needed later, load B.01a_EN.xlsx for pop_1900 and compute
    * french_share_total = french_1900 / pop_1900 (and symmetric for german).
    assert (german_1900 + french_1900) > 0 & !missing(german_1900) & !missing(french_1900)

    gen double french_share = french_1900 / (german_1900 + french_1900)
    gen double german_share = german_1900 / (german_1900 + french_1900)

    label var french_share "French share of Ger.+Fr. speakers (1900, subset denom)"
    label var german_share "German share of Ger.+Fr. speakers (1900, subset denom)"

    * Identity check: subset shares sum to 1 by construction
    assert abs((french_share + german_share) - 1) < 1e-9
}


**# 4. Add population from HSSO B.01a (1900 + 1910 decennial censuses)
*------------------------------------------------------------------------------*
* B.01a layout (verified 2026-05-18):
*   Row 3:  header row  -- same canton-column convention as B.32
*                          col A = "Year", col B = "ZH", col C = "BE, JU",
*                          col D = "BE" (separate), col E = "LU", ...,
*                          col AA = "GE", col AB = "JU", col AC = "CH", col AD = year-dup
*   Row 31: 1900 census  -- ZH = 431,036
*   Row 32: 1910 census  -- ZH = 503,915
*
* BE/JU rule (same as B.32): use col C (combined BE+JU) as BE; drop D/AB/AC/AD.
*
* Why both census years (no interpolation here): the 1908 vote falls between the
* 1900 and 1910 censuses.  Loading both as construction variables keeps the
* dataset agnostic about which to use as the per-capita denominator.  Primary
* spec uses pop_1900 (project default per 02_clean.do; pre-determined w.r.t.
* the vote).  Linear interpolation to pop_1907 is reserved for a future
* robustness step, NOT computed here.

**# 4.0 Standalone-run preamble: load §1+§2+§3 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = german_share (last var added by §3.3).  See §2.0 / §3.0 for
* the rationale -- checking the immediately-preceding section's last var is
* stricter than checking canton_iso and catches partial-state in-memory bugs.
{
    cap confirm variable german_share
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §4 needs §1+§2+§3 output (german_share) but cohort_1908.dta not found."
            di as error "  Run §1-§3 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in pop_1900 pop_1910 {
        cap drop `v'
    }
}


**# 4.1 Extract 1900 and 1910 census rows into tempfiles
*------------------------------------------------------------------------------*
{
    * --- 4.1a 1900 population (B.01a row 31) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.01a_EN.xlsx", clear allstring
        assert A[31] == "1900"
        keep in 31
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 pop_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile pop_1900_tf
        save `pop_1900_tf'
    restore

    * --- 4.1b 1910 population (B.01a row 32) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.01a_EN.xlsx", clear allstring
        assert A[32] == "1910"
        keep in 32
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 pop_1910
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile pop_1910_tf
        save `pop_1910_tf'
    restore
}


**# 4.2 Merge both onto cohort_1908 in memory; assert all 25 match
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `pop_1900_tf', assert(match) nogenerate
    merge 1:1 canton_iso using `pop_1910_tf', assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso

    label var pop_1900 "Resident population per canton (HSSO B.01a, 1900 federal census)"
    label var pop_1910 "Resident population per canton (HSSO B.01a, 1910 federal census)"

    di "Merged 1900+1910 population into cohort: 25 cantons matched on canton_iso"
}


**# 5. Add religion shares (Catholic, Protestant) from HSSO B.27 (1900 census)
*------------------------------------------------------------------------------*
* B.27 layout (verified 2026-05-18 via Python peek at row 3 + subblock headers):
*   Row 3:  header row  -- same canton-column convention as B.32 / B.01a
*                          col A = "Year", col B = "ZH", col C = "BE, JU",
*                          col D = "BE" (separate), col E = "LU", ...,
*                          col AA = "GE", col AB = "JU", col AC = "CH", col AD = year-dup
*   Row 6:  sub-block header "Protestant (incl. Protestant sects)"  -> Row 13 = 1900 data
*   Row 24: sub-block header "Catholic (Roman and Old Catholic)"    -> Row 31 = 1900 data
*   Row 42: sub-block "Of which: Roman Catholic"                    -> SKIP (we want
*                                                                     ALL Catholics: Roman + Old)
*   Row 55: sub-block "Eastern Orthodox..."                         -> not loaded (small)
*   Row 68: sub-block "Jewish..."                                   -> not loaded (small)
*
* BE/JU rule (same as B.32 / B.01a): use col C (combined BE+JU) as BE; drop D/AB/AC/AD.
*
* Why exactly two religions: M1A spec calls for catholic_share (the Baptist/
* temperance-coalition control).  Protestant is loaded for symmetry + subset-
* denominator construction.  Jewish/Orthodox/Other/None (~1.5% of 1900 pop
* nationally; up to ~5% in cosmopolitan GE/BS) are orthogonal to the wine /
* Romande-Alemannic / confessional cleavage M1A cares about.  If a referee
* asks, add row 75 (Jewish 1900) etc. via the same extraction pattern.

**# 5.0 Standalone-run preamble: load §1-§4 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = pop_1910 (last var added by §4.2).  See §2.0 / §3.0 for the
* rationale -- checking the immediately-preceding section's last var is
* stricter than checking canton_iso and catches partial-state in-memory bugs.
* Without this, a chunk run with stale vote/wine/lang-only memory state will
* let §5 proceed but crash §6.1 on missing pop_1900 (observed 2026-05-18).
{
    cap confirm variable pop_1910
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §5 needs §1-§4 output (pop_1910) but cohort_1908.dta not found."
            di as error "  Run §1-§4 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in protestant_1900 catholic_1900 protestant_share catholic_share {
        cap drop `v'
    }
}


**# 5.1 Extract 1900 Protestant + Catholic rows into tempfiles
*------------------------------------------------------------------------------*
{
    * --- 5.1a Protestant 1900 (B.27 row 13) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.27_EN.xlsx", clear allstring
        assert A[13] == "1900"
        keep in 13
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 protestant_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile rel_protestant
        save `rel_protestant'
    restore

    * --- 5.1b Catholic 1900 (B.27 row 31) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.27_EN.xlsx", clear allstring
        assert A[31] == "1900"
        keep in 31
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 catholic_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile rel_catholic
        save `rel_catholic'
    restore
}


**# 5.2 Merge both onto cohort_1908 in memory; assert all 25 match
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `rel_protestant', assert(match) nogenerate
    merge 1:1 canton_iso using `rel_catholic',   assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso

    label var protestant_1900 "Protestant population (HSSO B.27, 1900 census, persons; incl. Protestant sects)"
    label var catholic_1900   "Catholic population (HSSO B.27, 1900 census, persons; Roman + Old Catholic)"

    di "Merged 1900 Protestant + Catholic into cohort: 25 cantons matched on canton_iso"
}


**# 5.3 Construct subset-denominator shares
*------------------------------------------------------------------------------*
{
    * Subset denominator (Catholic + Protestant only) per project precedent from
    * analysis/scripts/02_clean.do §2.1.  Focuses on the confessional cleavage that
    * drove 19th/early-20th-century Swiss federal politics (Kulturkampf, Sonderbund
    * legacy).  Jewish/Orthodox/Other/None (~1.5% nationally) treated as orthogonal.
    * Sums to 1 exactly by construction.  Total-pop denominator variants are NOT
    * generated here; if needed later, use pop_1900 (loaded in §4) as denominator:
    *   catholic_share_total   = catholic_1900   / pop_1900
    *   protestant_share_total = protestant_1900 / pop_1900
    assert (protestant_1900 + catholic_1900) > 0 ///
        & !missing(protestant_1900) & !missing(catholic_1900)

    gen double catholic_share   = catholic_1900   / (protestant_1900 + catholic_1900)
    gen double protestant_share = protestant_1900 / (protestant_1900 + catholic_1900)

    label var catholic_share   "Catholic share of Christian pop. (1900, subset denom = Cath + Prot)"
    label var protestant_share "Protestant share of Christian pop. (1900, subset denom = Cath + Prot)"

    * Identity check: subset shares sum to 1 by construction
    assert abs((catholic_share + protestant_share) - 1) < 1e-9
}


**# 6. Add prior_canton_ban dummy (VD-1906 + GE-1907 cantonal bans pre-1908 federal vote)
*------------------------------------------------------------------------------*
* PROVENANCE
* Source: Schweizerischer Bundesrat (1907), "Botschaft des Bundesrates an die
*         Bundesversammlung uber das Volksbegehren betreffend das Verbot des
*         Absinths", 9 Dezember 1907.  Bundesblatt 1907 Vol. VI, pp. 344, 346.
*
* DEFINITION
* prior_canton_ban = 1 if the canton had enacted a sub-federal ban on RETAIL
* SALE of absinthe before the 5 July 1908 federal referendum; 0 otherwise.
*
* CODING (N_priorban = 2; all 23 others = 0)
*   VD = 1  Grand Council statute 15 May 1906; confirmed by cantonal popular
*           vote; entered into force 1906-07.  Federal confirmation:
*           Bundesrat decision 22 Mar 1907 dismissed VD/NE/GE absinthe-
*           producer appeals against the VD law as unfounded.
*   GE = 1  Grand Council law 2 Feb 1907 (vote 55-21); entered into force
*           1 Jan 1908.  Covers retail sale of absinthe AND any beverage
*           that "presents itself as an imitation of absinthe".
*
* SCOPE WARNING (IMPORTANT for coefficient interpretation)
* VD/GE cantonal bans cover RETAIL SALE only -- NOT manufacture or wholesale.
* Federal Art. 32ter is broader (manufacture + importation + transport + sale
* + storage for sale).  Don't conflate the scopes when interpreting the
* coefficient on prior_canton_ban.
*
* SATURATION WARNING (IMPORTANT for inference)
* With N_priorban = 2 (VD + GE), any `prior_canton_ban' x X interaction is
* effectively a VD-vs-GE contrast against the other 23 cantons.  Flag in
* robustness; don't lean on these interactions for inference.
*
* GE TEMPORAL CODING
* GE law entered force 1 Jan 1908; legislative date was 2 Feb 1907.  Both
* meet the "before 5 July 1908" cutoff -- using in-force date (1 Jan 1908)
* as the "ban in effect at time of vote" date is the operative choice.
*
* OPEN VERIFICATION ITEM
* Exact in-force date of the GE law: Botschaft confirms 1 Jan 1908.  For
* primary-source corroboration check Recueil authentique des lois et actes
* du gouvernement de Geneve.  Botschaft itself is sufficient for the dummy.

**# 6.0 Standalone-run preamble: load §1-§5 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = protestant_share (last var added by §5.3).  See §2.0 / §3.0
* for the rationale -- checking the immediately-preceding section's last var
* catches partial-state in-memory bugs.
{
    cap confirm variable protestant_share
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §6 needs §1-§5 output (protestant_share) but cohort_1908.dta not found."
            di as error "  Run §1-§5 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    cap drop prior_canton_ban
}


**# 6.1 Code the binary dummy with provenance-encoding assertions
*------------------------------------------------------------------------------*
{
    gen byte prior_canton_ban = inlist(canton_iso, "VD", "GE")
    label var prior_canton_ban ///
        "=1 if canton had pre-1908 sub-federal absinthe ban (VD-1906 statute, GE-1907 law in force 1 Jan 1908)"
    label define priorban_lbl 0 "no prior ban" 1 "prior ban", replace
    label values prior_canton_ban priorban_lbl

    * Provenance-encoding assertions: exactly {VD, GE} = 1, exactly 23 others = 0.
    * These assertions ARE the policy-coding spec; a future edit that
    * accidentally breaks the coding (adds/removes a canton) will fire here.
    qui count if prior_canton_ban == 1
    assert r(N) == 2
    qui count if prior_canton_ban == 1 & inlist(canton_iso, "VD", "GE")
    assert r(N) == 2
    qui count if prior_canton_ban == 0
    assert r(N) == 23

    di "  prior_canton_ban: coded 1 for VD + GE (N_priorban = 2; 23 cantons = 0)"
    di "    Source: Schweizerischer Bundesrat (1907), Botschaft, BBl 1907 Vol. VI, pp. 344, 346"
}


**# 7. Add Milliet 1907 absinthe-industry variables (firm-level -> canton-level)
*------------------------------------------------------------------------------*
* PROVENANCE
* Source: Milliet, A. (1907), table reproduced in Schweizerischer Bundesrat
*         (1907), "Botschaft des Bundesrates...", BBl 1907 Vol. VI, p. 361.
*         PI-translated + verified into:
*           $Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx
*           sheet "English" (supersedes prior CSVs from sibling Brainstorm-
*           Absinthe repo -- resolves 3 spelling errors + Dornier-Tueller
*           export ambiguity, 4,033 not 4,693).
*
* LAYOUT (verified PI 2026-05-19, sheet "English")
*   Row 1:       Column headers (Canton | Company Name | Spirit Purchases ... |
*                Refund-Eligible Export ...).  Canton column fully populated by
*                PI (every firm row has a canton entry).
*   Rows 2-41:   40 firms across 8 producer cantons (NE, GE, BS, VD, SZ, ZG,
*                FR, VS).
*   Row 42:      National Total row (Canton blank; B42="Total"; C42=5,402,342;
*                D42=320,553).  Direct cell extract for the 5-year denominator.
*   Row 43:      Per-Year row (B43="or per Year"; C43=1,080,468; D43=64,111).
*                Annual-mean denominator; reconciles to row42/5 modulo rounding.
*
* UNITS
* All kg figures = kg of spirit at 95-degree ABV (federal alcohol monopoly's
* accounting standard for "trois-six" / Sprit a 95 Grad).  This is the input
* proxy for distilled absinthe (vs. cold-process essence-based imitations,
* which Milliet's table does not cover).
*
* TIME WINDOW
* All firm-level figures are 5-year totals 1902-1906 (federal alcohol monopoly's
* prior reporting window).  Annual means stored as parallel `_yr' variables
* (= 5-year total / 5).  Shares are scale-invariant (5y_canton / 5y_national =
* 1y_canton / 1y_national), so no annual variants for the 3 share vars.
*
* MISSING-VALUE RULE (PI 2026-05-19, overrides prior "blanks = 0" spec)
* Blank cells in the source Excel = MISSING, not zero.  Per-variable exclusion:
* a firm with blank purchases is excluded from the purchases sum; a firm with
* blank exports is excluded from the exports sum.  Stata's `egen total' (and
* `collapse (sum)') treat missing as 0 in summation, which has the same effect
* as excluding for SUMS (0 + X = X).  Critically: DO NOT compute domestic at
* the FIRM level via `gen domestic_firm = purchases_firm - exports_firm', which
* would propagate missing into the firm value and then drop that firm from the
* canton domestic sum (under-counting cantons with blank-export firms).
* Instead compute domestic at the CANTON level via `canton purchases - canton
* exports' so blank-export firms still contribute their purchases to the canton
* total (matching Milliet's printed canton accounting).
*
* SCOPE CAVEAT (Milliet's own signed caveat, BBl 1907 VI 361)
* Assumes all spirit purchases went to absinthe.  Spirit may have gone to other
* liqueurs; firms could buy spirit/absinthe through middlemen.  Inherit these
* caveats in coefficient interpretation.
*
* NON-PRODUCER CANTON HANDLING (PI 2026-05-19 directive: missing, NOT zero)
* The 17 cantons not in Milliet's annex (ZH, BE, LU, UR, OW, NW, GL, SO, BL,
* SH, AR, AI, SG, GR, AG, TG, TI) receive MISSING values for all canton-level
* Milliet variables -- NOT zero.  Rationale: "missing means they're treated as
* not part of that variable's total."  Per Bundesrat's 1907 Botschaft, absinthe
* production was concentrated in the 8 producer cantons, but encoding that as
* a structural zero would conflate "no data" with "data = 0" in downstream
* regressions and inflate the effective sample size for Milliet-using specs.
* Under the missing-treatment, any regression using Milliet vars naturally
* drops the 17 to the 8-producer-canton subsample (N=8 effective for those
* specs).  Shares correctly sum to 1.0 across the 8 producers via Stata's
* missing-aware `sum' statistic (which ignores missing rows).

**# 7.0 Standalone-run preamble: load §1-§6 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = prior_canton_ban (last var added by §6.1).  See §2.0 / §3.0
* for the rationale.
{
    cap confirm variable prior_canton_ban
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §7 needs §1-§6 output (prior_canton_ban) but cohort_1908.dta not found."
            di as error "  Run §1-§6 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in n_firms_purchases n_firms_exports ///
                 purchases_kg95_canton exports_kg95_canton domestic_kg95_canton ///
                 share_of_total_purchases share_of_total_exports share_of_total_domestic ///
                 purchases_kg95_canton_yr exports_kg95_canton_yr domestic_kg95_canton_yr {
        cap drop `v'
    }
}


**# 7.1 Extract firm-level data + national-total cell denominators from Milliet Excel
*------------------------------------------------------------------------------*
{
    preserve
        * Load all data rows (excel rows 2-43 = 40 firms + 2 total rows).
        * Headers in row 1 skipped via cellrange.  allstring preserves blanks
        * as "" which destring..force converts to . (missing) -- per the
        * MISSING-VALUE RULE in the §7 leading comment.
        import excel using "$Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx", ///
            sheet("English") cellrange(A2:D43) clear allstring
        assert _N == 42
        assert B[41] == "Total"
        assert B[42] == "or per Year"

        * Extract national totals as scalars from rows 41-42 (excel 42-43)
        * BEFORE destring touches the firm rows.  Strings have commas; strip.
        scalar nat_purch_5y = real(subinstr(C[41], ",", "", .))
        scalar nat_exp_5y   = real(subinstr(D[41], ",", "", .))
        scalar nat_purch_1y = real(subinstr(C[42], ",", "", .))
        scalar nat_exp_1y   = real(subinstr(D[42], ",", "", .))

        * Verify totals match BBl 1907 VI 361 (the canonical Milliet citation)
        assert nat_purch_5y == 5402342
        assert nat_exp_5y   == 320553
        scalar nat_dom_5y = nat_purch_5y - nat_exp_5y   // 5,081,789
        scalar nat_dom_1y = nat_purch_1y - nat_exp_1y   // 1,016,357 (rounding)

        di "  Milliet 5y national totals: purchases=" %9.0fc nat_purch_5y ///
           " exports=" %9.0fc nat_exp_5y " domestic=" %9.0fc nat_dom_5y
        di "  Milliet 1y national means:  purchases=" %9.0fc nat_purch_1y ///
           " exports=" %9.0fc nat_exp_1y " domestic=" %9.0fc nat_dom_1y

        * Drop the 2 total rows -- leaves 40 firm rows
        drop in 41/42
        assert _N == 40

        * Rename Excel columns to project conventions; cast numeric (blanks -> .)
        rename (A B) (firm_canton_name firm_name)
        destring C, gen(purchases_kg95_firm) force ignore(",")
        destring D, gen(exports_kg95_firm)   force ignore(",")
        drop C D

        * Map Excel canton names -> 2-letter ISO codes.  Use 4-char prefix
        * to avoid encoding-dependent matching on accented chars (Neuchatel).
        gen str4 _pfx = substr(firm_canton_name, 1, 4)
        gen str2 canton_iso = ""
        replace canton_iso = "NE" if _pfx == "Neuc"
        replace canton_iso = "GE" if _pfx == "Gene"
        replace canton_iso = "BS" if _pfx == "Base"
        replace canton_iso = "VD" if _pfx == "Vaud"
        replace canton_iso = "SZ" if _pfx == "Schw"
        replace canton_iso = "ZG" if _pfx == "Zug"
        replace canton_iso = "FR" if _pfx == "Frib"
        replace canton_iso = "VS" if _pfx == "Vala"
        drop _pfx

        * Assert every firm got mapped to one of the 8 producer cantons
        assert !missing(canton_iso)
        qui count if !inlist(canton_iso, "NE","GE","BS","VD","SZ","ZG","FR","VS")
        assert r(N) == 0

        * Collapse firms -> 8 producer cantons under STRICT missing rule.
        *
        * Firm-count vars are variable-specific (NOT a single roster count):
        *   _has_purch flag = 1 iff firm has non-missing purchases (else 0).
        *   _has_exp   flag = 1 iff firm has non-missing exports   (else 0).
        * Summing these flags per canton gives n_firms_purchases / n_firms_exports
        * = "count of firms that ACTUALLY CONTRIBUTED to that variable's canton
        * total."  This honors PI's missing rule: a firm with blank purchases
        * (L. Magnin in GE, the only one) is NOT counted toward n_firms_purchases;
        * a firm with blank exports (15 firms across 3 cantons) is NOT counted
        * toward n_firms_exports.  Avoids the "_present = 1" cut-corner where
        * every roster firm counts regardless of whether it had any data.
        *
        * The earlier-spec single n_firms (= Milliet roster count, 11 for GE
        * including L. Magnin) is intentionally DROPPED: it conflates "appears
        * in Milliet's annex" with "contributes to the kg aggregates" -- the
        * two are not the same once blanks are treated as missing.
        *
        * (sum) on kg vars treats missing as 0 in sum (= excludes blanks) per
        * the MISSING-VALUE RULE.
        *
        * Rebate-accounting context (PI 2026-05-19 clarification):
        * The export column ("Rueckvergueutungsberechtigter Export") is a
        * SUBSET of purchases -- specifically, "the portion of purchases for
        * which the firm filed a rebate claim because the spirit ended up in
        * exported product."  Under Art. 32bis, distillers paid Fr. ~116/q on
        * every kg of Trinksprit purchased; rebate refunded the markup on the
        * portion that was re-exported.  Blank in the export column = "no
        * rebate claim filed" = 0 rebate-eligible exports (NOT unknown).  Blank
        * in the purchases column = unknown firm activity (= L. Magnin only,
        * who has both blank) -- per the strict missing rule for purchases.
        *
        * Domestic computed at CANTON LEVEL as `purchases - exports`, matching
        * Milliet's own national-aggregate arithmetic on BBl 1907 VI 362:
        *   "for the manufacture of 72,575 hl of absinthe at 65 deg,
        *   4,049,250 kg [of 95-deg spirit] are required, i.e., on annual
        *   average 809,850 kg.  [...] the mean annual consumption of 95-deg
        *   spirit in the form of absinthe liqueur, leaving aside imports, may
        *   finally be estimated at 809,850 kg minus 64,111 kg = 745,739 kg."
        * Our domestic_kg95 is a proxy for canton-level absinthe-industry
        * exposure ("spirit purchased and not exported under rebate"), distinct
        * from Milliet's 745,739 published figure (which factors in the ~75%
        * spirit-actually-used-for-absinthe deduction).  Both use the same
        * `total - exports' subtraction structure.
        gen byte _has_purch = !missing(purchases_kg95_firm)
        gen byte _has_exp   = !missing(exports_kg95_firm)
        collapse (sum) n_firms_purchases = _has_purch ///
                 (sum) n_firms_exports   = _has_exp ///
                 (sum) purchases_kg95_canton = purchases_kg95_firm ///
                 (sum) exports_kg95_canton   = exports_kg95_firm, ///
                 by(canton_iso)
        assert _N == 8

        * Canton-level domestic identity: purchases - exports (Milliet accounting)
        gen double domestic_kg95_canton = purchases_kg95_canton - exports_kg95_canton

        * Sanity: sum over 8 producer cantons should match Milliet national totals
        qui sum purchases_kg95_canton
        assert r(sum) == nat_purch_5y
        qui sum exports_kg95_canton
        assert r(sum) == nat_exp_5y
        qui sum domestic_kg95_canton
        assert r(sum) == nat_dom_5y

        * Firm-count sanity: 39 firms have non-missing purchases (40 - L. Magnin
        * in GE); 25 firms have non-missing refund-eligible exports (40 - 15
        * blank-export firms across NE, GE, VD).  Note: blank exports treated
        * as 0 rebate claim (per rebate-accounting context), so the 15 firms
        * with blank exports DO contribute their purchases to canton domestic
        * (consistent with their 0 rebate-eligible-export contribution).
        qui sum n_firms_purchases
        assert r(sum) == 39
        qui sum n_firms_exports
        assert r(sum) == 25

        tempfile milliet_8
        save `milliet_8'
    restore
}


**# 7.2 Merge into cohort (17 non-producer cantons remain MISSING per PI rule)
*------------------------------------------------------------------------------*
{
    * 8 producer cantons match; 17 non-producer cantons stay master-only with
    * the new Milliet vars = MISSING.  Per PI 2026-05-19 directive, do NOT
    * zero-pad the 17 -- "missing means they're treated as not part of that
    * variable's total" (see §7 leading comment, NON-PRODUCER CANTON HANDLING).
    merge 1:1 canton_iso using `milliet_8', assert(match master) nogenerate

    assert c(N) == 25
    isid canton_iso

    * Sanity: exactly 8 cantons have non-missing Milliet vars; exactly 17 missing.
    qui count if !missing(purchases_kg95_canton)
    assert r(N) == 8
    qui count if missing(purchases_kg95_canton)
    assert r(N) == 17

    label var n_firms_purchases     "Number of firms contributing to canton purchases (non-missing purchase cell; missing for 17 non-producer cantons)"
    label var n_firms_exports       "Number of firms with non-missing rebate-claim exports in canton (15 firms with blank exports excluded; missing for 17 non-producer cantons)"
    label var purchases_kg95_canton "Spirit purchases, 5y total 1902-1906, canton (kg @ 95 deg ABV; Milliet; missing for non-producers)"
    label var exports_kg95_canton   "Rebate-eligible exports, 5y total 1902-1906, canton (kg @ 95 deg ABV; subset of purchases; missing for non-producers)"
    label var domestic_kg95_canton  "Domestic spirit retained = purchases - exports, 5y total, canton (kg @ 95 deg ABV; Milliet canton identity; missing for non-producers)"

    di "Merged Milliet 1907: 8 producer cantons populated; 17 non-producer cantons MISSING (per PI rule, not zero)"
}


**# 7.3 Construct canton shares (5y) and 1-year-mean parallels (_yr)
*------------------------------------------------------------------------------*
{
    * Shares: canton value / Milliet's printed national total (from row 42).
    * Three shares: purchases, exports, domestic.  All canton/national.
    * For the M1A headline, share_of_total_purchases is the cleanest (Regie
    * ledger row totals, free of any allocation assumption).  The export and
    * domestic shares answer "which margin drives ban-resistance: domestic-
    * market exposure vs. export-market exposure?" -- robustness specs.
    gen double share_of_total_purchases = purchases_kg95_canton / nat_purch_5y
    gen double share_of_total_exports   = exports_kg95_canton   / nat_exp_5y
    gen double share_of_total_domestic  = domestic_kg95_canton  / nat_dom_5y

    label var share_of_total_purchases "Canton share of national spirit purchases (0-1; Milliet 1902-06; missing for non-producers)"
    label var share_of_total_exports   "Canton share of national rebate-eligible exports (0-1; Milliet 1902-06; missing for non-producers)"
    label var share_of_total_domestic  "Canton share of national domestic spirit retention (0-1; Milliet 1902-06; missing for non-producers)"

    * 1-year mean parallels (= 5-year total / 5).  Stored as separate variables
    * per PI 2026-05-19 directive to preserve both 5y and 1y representations.
    * Shares NOT re-stored at 1y level (ratio invariance: 5y/5y = 1y/1y).
    gen double purchases_kg95_canton_yr = purchases_kg95_canton / 5
    gen double exports_kg95_canton_yr   = exports_kg95_canton   / 5
    gen double domestic_kg95_canton_yr  = domestic_kg95_canton  / 5

    label var purchases_kg95_canton_yr "Spirit purchases, 1y mean (= 5y/5), canton (kg @ 95 deg ABV; Milliet; missing for non-producers)"
    label var exports_kg95_canton_yr   "Rebate-eligible exports, 1y mean (= 5y/5), canton (kg @ 95 deg ABV; Milliet; missing for non-producers)"
    label var domestic_kg95_canton_yr  "Domestic spirit retained, 1y mean (= 5y/5), canton (kg @ 95 deg ABV; missing for non-producers)"

    * Identity check: each share sums to 1 across the 8 producer cantons.
    * Stata's `sum` r(sum) ignores missing, so r(sum) over all 25 = sum over 8.
    foreach s in share_of_total_purchases share_of_total_exports share_of_total_domestic {
        qui sum `s'
        assert r(N) == 8
        assert abs(r(sum) - 1) < 1e-9
    }
}


**# 8. Add canton land area from HSSO B.01b (population density, 1900) via algebra
*------------------------------------------------------------------------------*
* PROVENANCE
* Source: HSSO B.01b (translated): $Absinthe1Data/translated/B.01b_EN.xlsx
*         Row 12 = 1900 population density (persons/km^2), same canton column
*         convention as B.01a/B.27/B.32 (col B = ZH, col C = combined BE+JU
*         per project precedent, ..., col AA = GE).
*
* DERIVATION
* B.01b does not publish canton AREA directly -- only DENSITY = persons/km^2.
* Canton land area derived algebraically as:
*   canton_area_km2 = pop_1900 / pop_density_1900
* This is the inverse-of-density identity: density (persons / km^2) inverted
* and multiplied by population (persons) gives km^2.  Matches the operative
* approach in the main pipeline (02_clean.do line 342).
*
* DISCLAIMER (B.01b's own note, propagated through density derivation)
* Density EXCLUDES lake area for cantons with substantial lake territory
* (GE and NE specifically per B.01b's note; "e.g." phrasing leaves open
* whether other lake-adjacent cantons VD/SG/TG/SZ/UR also exclude their
* lake share).  This means the algebra-derived `canton_area_km2` is LAND
* AREA EXCLUDING LAKES for GE/NE -- not total surveyed cantonal area.
* For cantons with negligible lake share, the distinction is immaterial.
* Variable labels and §9.1 sanity assertions document this convention;
* a 5% tolerance on the CH-total spot-check absorbs the ambiguity.
*
* RAW DENSITY KEPT for data comparability (parallel to keeping german_1900
* + french_1900 alongside the derived shares).  Permits re-deriving area
* if needed and supports referee spot-checks against external sources.
*
* ln transform
* `ln_canton_area_km2 = ln(canton_area_km2)` provided as the M1A regressor
* (standard log-linear specification for canton-size controls).

**# 8.0 Standalone-run preamble: load §1-§7 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = domestic_kg95_canton_yr (last var added by §7.3).  See §2.0 /
* §3.0 for the rationale.
{
    cap confirm variable domestic_kg95_canton_yr
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §8 needs §1-§7 output (domestic_kg95_canton_yr) but cohort_1908.dta not found."
            di as error "  Run §1-§7 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in pop_density_1900 canton_area_km2 ln_canton_area_km2 {
        cap drop `v'
    }
}


**# 8.1 Extract 1900 population density row from B.01b into tempfile
*------------------------------------------------------------------------------*
{
    preserve
        import excel using "$Absinthe1Data/translated/B.01b_EN.xlsx", clear allstring
        assert A[12] == "1900"
        keep in 12
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 pop_density_1900
        rename _varname canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile density_1900_tf
        save `density_1900_tf'
    restore
}


**# 8.2 Merge density into cohort; derive canton_area_km2 + ln_canton_area_km2
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `density_1900_tf', assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso

    label var pop_density_1900 ///
        "Population density 1900 (persons/km^2; HSSO B.01b; excludes lake area for GE/NE)"

    * Algebra: canton_area_km2 = pop_1900 / pop_density_1900.  Same derivation
    * as 02_clean.do §3 (main pipeline).  For GE/NE this gives land area
    * excluding lakes (per B.01b's lake-exclusion convention).
    assert pop_density_1900 > 0 & !missing(pop_density_1900)
    assert pop_1900 > 0 & !missing(pop_1900)
    gen double canton_area_km2 = pop_1900 / pop_density_1900
    label var canton_area_km2 ///
        "Canton land area, km^2 (= pop_1900 / pop_density_1900; excludes lake area for GE/NE)"

    * Natural log (M1A canton-size control)
    gen double ln_canton_area_km2 = ln(canton_area_km2)
    label var ln_canton_area_km2 ///
        "Natural log of canton land area (M1A regressor; canton-size control)"

    * --- 1907 population correctness (2026-06-17): actual 1907 yearbook estimate ---
    * pop_1907 from the 1908 Statistical Yearbook volume (1907 back-column), 25/25
    * cantons, national total cross-validated to 3,524,529 in
    * scripts/python/build_pop_canton_yearbook.py.  canton_area_km2 above is the FIXED
    * land-area constant; 1907 density is recomputed on it (land area is time-invariant).
    cap drop pop_1907 pop_density_1907 ln_pop_1907
    preserve
        import delimited "$MyProject/processed/pop_1907_canton.csv", varnames(1) case(preserve) clear
        tempfile pop1907_tf
        save `pop1907_tf'
    restore
    merge 1:1 canton_iso using `pop1907_tf', assert(match) nogenerate
    label var pop_1907 "Resident population per canton (Statistical Yearbook annual estimate, 1907)"
    assert pop_1907 > 0 & !missing(pop_1907)
    qui count if missing(pop_1907)
    assert r(N) == 0
    gen double pop_density_1907 = pop_1907 / canton_area_km2
    label var pop_density_1907 ///
        "Population density (persons/km^2, 1907 = pop_1907 / fixed 1900 land area)"
    gen double ln_pop_1907 = ln(pop_1907)
    label var ln_pop_1907 "Log canton population (1907 yearbook estimate)"
    * consistency checks (dispatch §2): national sum + density identity
    qui sum pop_1907, meanonly
    di as text "  pop_1907 national sum = " %15.0fc r(sum) " (expect 3,524,529)"
    assert reldif(r(sum), 3524529) < 1e-6
    assert reldif(pop_1907 / pop_density_1907, canton_area_km2) < 1e-9

    * --- 1906 population (petition denominator; the petition is a 1906 event,
    * matching eligible_1906). Raw denominator only — no density derived on 1906. ---
    cap drop pop_1906
    preserve
        import delimited "$MyProject/processed/pop_1906_canton.csv", varnames(1) case(preserve) clear
        tempfile pop1906_tf
        save `pop1906_tf'
    restore
    merge 1:1 canton_iso using `pop1906_tf', assert(match) nogenerate
    label var pop_1906 "Resident population per canton (Statistical Yearbook annual estimate, 1906)"
    assert pop_1906 > 0 & !missing(pop_1906)
    qui sum pop_1906, meanonly
    di as text "  pop_1906 national sum = " %15.0fc r(sum) " (expect 3,491,163)"
    assert reldif(r(sum), 3491163) < 1e-6

    di "Merged 1900 density + canton_area_km2 + ln_canton_area_km2 + 1907 pop (pop_1907/pop_density_1907) + 1906 pop (petition): 25 cantons"
}


**# 9. Sanity-check the merged dataset
*------------------------------------------------------------------------------*

**# 9.0 Standalone-run preamble: load latest checkpoint if memory is empty
*------------------------------------------------------------------------------*
* Sentinel var = ln_canton_area_km2 (last var added by §8.2).  See §2.0 / §3.0
* for the rationale.
{
    cap confirm variable ln_canton_area_km2
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §9 needs §1-§8 output (ln_canton_area_km2) but cohort_1908.dta not found."
            di as error "  Run §1-§8 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
}


**# 9.1 Run all sanity assertions
*------------------------------------------------------------------------------*
{
    * --- Vote shares: bounded [0, 100] across all three votes ---
    foreach v of local cohort_votes {
        assert inrange(pct_yes_`v', 0, 100) | missing(pct_yes_`v')
    }

    * --- Wine area: non-negative; exactly 5 zero cantons (UR OW NW ZG AI) ---
    assert wine_area_canton_ha >= 0
    count if wine_area_canton_ha == 0
    assert r(N) == 5
    count if inlist(canton_iso, "UR","OW","NW","ZG","AI") & wine_area_canton_ha == 0
    assert r(N) == 5

    * --- Wine revenue share sums to ~1.0 (CH = sum of cantons) ---
    qui sum wine_revenue_share_canton
    di "  W6 share sum across 25 cantons: " %7.6f r(sum) " (expect 1.000000)"
    assert abs(r(sum) - 1.0) < 1e-5

    * --- VD spot-check: wine area should match PI Excel (6352.9 ha) ---
    qui sum wine_area_canton_ha if canton_iso == "VD"
    assert abs(r(mean) - 6352.9) < 0.1
    di "  VD wine area: " %6.1f r(mean) " ha (PI Excel: 6352.9 ha) -- match"

    * --- Language shares: bounded [0,1]; sum to 1 by construction ---
    assert inrange(french_share, 0, 1)
    assert inrange(german_share, 0, 1)
    assert abs((french_share + german_share) - 1) < 1e-9

    * --- Language spot-checks against the canonical Swiss-Romande / Alemannic cleavage ---
    * The 5 traditionally French-influenced cantons should all be French-majority
    * (subset share > 0.5).  Empirically (B.32 1900): VD=0.91, GE=0.89, NE=0.86,
    * FR=0.69, VS=0.68.  Threshold of 0.60 catches all 5 with slack.
    qui sum french_share if inlist(canton_iso, "NE", "GE", "VD", "FR", "VS")
    assert r(min) >= 0.60
    di "  French-majority spot-check (NE/GE/VD/FR/VS): min french_share = " %5.3f r(min) " (>= 0.60)"

    * UR and AI are essentially monolingual German (>= 0.99 of DE+FR speakers).
    qui sum german_share if inlist(canton_iso, "UR", "AI")
    assert r(min) >= 0.99
    di "  German-majority spot-check (UR/AI): min german_share = " %5.3f r(min) " (>= 0.99)"

    * --- Population: strictly positive in both census years ---
    assert pop_1900 > 0 & !missing(pop_1900)
    assert pop_1910 > 0 & !missing(pop_1910)

    * --- Cross-source population check: B.32 1900 Total per canton should equal
    *     B.01a 1900 (both pull from the same 1900 federal census).  Reconstruct
    *     the B.32 implied total = german + french + (Italian + Romansh + other).
    *     We don't have I/R/O loaded, so check via subset: pop_1900 >= german_1900
    *     + french_1900 (the part of B.32 we loaded).  Should hold for every canton.
    assert pop_1900 >= (german_1900 + french_1900)
    qui gen double _nonge_fr = pop_1900 - german_1900 - french_1900
    qui sum _nonge_fr
    di "  Cross-source check: pop_1900 - (german_1900 + french_1900) >= 0 for all 25 cantons"
    di "    range of residual (Italian + Romansh + other + foreign-language speakers): " ///
       %7.0f r(min) " to " %7.0f r(max)
    drop _nonge_fr

    * --- National-total sanity: sum across 25 cantons should match HSSO CH totals ---
    * HSSO B.01a CH 1900 = 3,315,443 ; CH 1910 = 3,753,293 (per col AC, not loaded here).
    * Allow 0.5% tolerance for rounding in individual canton entries.
    qui sum pop_1900
    di "  Pop 1900 sum across 25 cantons: " %9.0fc r(sum) "  (CH total ~3,315,443; tol 0.5%)"
    assert abs(r(sum) - 3315443) / 3315443 < 0.005
    qui sum pop_1910
    di "  Pop 1910 sum across 25 cantons: " %9.0fc r(sum) "  (CH total ~3,753,293; tol 0.5%)"
    assert abs(r(sum) - 3753293) / 3753293 < 0.005

    * --- Decade growth direction: Swiss national pop grew ~13% from 1900 to 1910 ---
    * Individual cantons may have declined (TI/GR emigration), but at least 20 of 25
    * should show positive growth.
    qui count if pop_1910 > pop_1900
    di "  Cantons with positive 1900-1910 growth: " r(N) " / 25"
    assert r(N) >= 20

    * --- Religion: non-negative; subset shares bounded; sum to 1 by construction ---
    assert protestant_1900 >= 0 & !missing(protestant_1900)
    assert catholic_1900   >= 0 & !missing(catholic_1900)
    assert inrange(catholic_share,   0, 1)
    assert inrange(protestant_share, 0, 1)
    assert abs((catholic_share + protestant_share) - 1) < 1e-9

    * --- Religion spot-checks against canonical confessional geography ---
    * AI + AR (Appenzell): the 1597 schism split Appenzell specifically over
    * religion -- AI took the Catholic half, AR the Protestant.  Empirically
    * (B.27 1900): AI catholic_share = 0.94, AR protestant_share = 0.90.
    * Threshold 0.85 catches both with slack but still demands strong
    * majority on the expected side (would fire on a religion-source data flip).
    qui sum catholic_share if canton_iso == "AI"
    assert r(mean) >= 0.85
    di "  AI confession spot-check: catholic_share   = " %5.3f r(mean) " (>= 0.85, AI = Catholic half)"
    qui sum protestant_share if canton_iso == "AR"
    assert r(mean) >= 0.85
    di "  AR confession spot-check: protestant_share = " %5.3f r(mean) " (>= 0.85, AR = Protestant half)"

    * Traditional Catholic cantons (UR/SZ/OW/NW/FR/VS/TI/AI -- the Sonderbund
    * core + Ticino + Fribourg).  FR has the largest Protestant minority among
    * these (~15% in 1900), so min should sit ~0.85.  Threshold 0.80 with slack.
    qui sum catholic_share if inlist(canton_iso, "UR","SZ","OW","NW","FR","VS","TI","AI")
    assert r(min) >= 0.80
    di "  Catholic-stronghold spot-check (UR/SZ/OW/NW/FR/VS/TI/AI): min catholic_share = " ///
       %5.3f r(min) " (>= 0.80)"

    * ZH alone (canton of Zwingli, no BE/JU merging): >=0.80 Protestant in 1900.
    * Skipping BE here because the BE+JU merge dilutes the Bernese Protestant
    * share with Catholic Jura -- canonical combined value lands ~0.70.
    qui sum protestant_share if canton_iso == "ZH"
    assert r(mean) >= 0.80
    di "  Protestant spot-check (ZH, canton of Zwingli): protestant_share = " ///
       %5.3f r(mean) " (>= 0.80)"

    * --- Cross-source religion check: (protestant + catholic) / pop_1900 in
    *     [0.90, 1.005] for all cantons.  Residual = Jewish + Orthodox + Other
    *     + None (~1.5% of 1900 pop nationally; up to ~5% in GE/BS).  Upper
    *     bound has 0.005 slack for canton-year minor discrepancies between
    *     B.01a and B.27 (both 1900 federal census, should align very tightly).
    qui gen double _christian_cover = (protestant_1900 + catholic_1900) / pop_1900
    qui sum _christian_cover
    di "  Cross-source check: (protestant + catholic) / pop_1900 range = " ///
       %5.3f r(min) " to " %5.3f r(max) " (expect ~0.95-1.00)"
    assert r(min) >= 0.90
    assert r(max) <= 1.005
    drop _christian_cover

    * --- Prior canton ban: binary 0/1; exactly {VD, GE} coded 1 (Botschaft 1907) ---
    * This re-asserts the §6.1 provenance check at the sanity-battery level too,
    * so a future edit that drops/breaks §6 (or a stale on-disk cohort_1908.dta
    * loaded by an upstream preamble) gets caught here even if §6 itself ran fine.
    assert inlist(prior_canton_ban, 0, 1)
    qui count if prior_canton_ban == 1
    di "  Prior-canton-ban count: " r(N) " (expect 2: VD + GE per Bundesrat Botschaft 1907)"
    assert r(N) == 2
    qui count if prior_canton_ban == 1 & inlist(canton_iso, "VD", "GE")
    assert r(N) == 2

    * --- Milliet 1907: missing-for-non-producers + national-total identities ---
    * Exactly 8 cantons have non-missing Milliet vars; 17 stay missing per PI rule.
    qui count if !missing(purchases_kg95_canton)
    assert r(N) == 8
    qui count if missing(purchases_kg95_canton)
    assert r(N) == 17

    * Each canton-level sum (over 8 producers; missing-aware) matches Milliet's
    * printed national totals from BBl 1907 VI 361 row 42 exactly.
    qui sum purchases_kg95_canton
    di "  Milliet sum check: 8-canton purchases_kg95 = " %9.0fc r(sum) ///
       " (expect 5,402,342 per BBl 1907 VI 361)"
    assert r(sum) == 5402342
    qui sum exports_kg95_canton
    di "  Milliet sum check: 8-canton exports_kg95   = " %9.0fc r(sum) ///
       " (expect   320,553 per BBl 1907 VI 361)"
    assert r(sum) == 320553
    qui sum domestic_kg95_canton
    di "  Milliet sum check: 8-canton domestic_kg95  = " %9.0fc r(sum) ///
       " (expect 5,081,789 = 5,402,342 - 320,553 per Milliet canton identity)"
    assert r(sum) == (5402342 - 320553)
    qui sum n_firms_purchases
    di "  Milliet sum check: 8-canton n_firms_purchases = " %4.0f r(sum) ///
       " (expect 39 = 40 - L.Magnin GE blank purchases)"
    assert r(sum) == 39
    qui sum n_firms_exports
    di "  Milliet sum check: 8-canton n_firms_exports   = " %4.0f r(sum) ///
       " (expect 25 = 40 - 15 blank-export firms across NE/GE/VD)"
    assert r(sum) == 25

    * Shares: bounded [0,1] over the 8 producers; sum to 1.0 exactly.
    foreach s in share_of_total_purchases share_of_total_exports share_of_total_domestic {
        qui sum `s'
        assert inrange(r(min), 0, 1) & inrange(r(max), 0, 1)
        assert abs(r(sum) - 1) < 1e-9
        assert r(N) == 8
    }

    * NE spot-check (largest producer; PI spec table: 17 firms (all with
    * purchases; 13 with non-blank exports), 3,178,714 kg purchases, 300,420
    * kg exports, share_purchases = 0.5884).
    qui sum purchases_kg95_canton if canton_iso == "NE"
    assert r(mean) == 3178714
    qui sum n_firms_purchases if canton_iso == "NE"
    assert r(mean) == 17
    qui sum n_firms_exports if canton_iso == "NE"
    assert r(mean) == 13
    qui sum share_of_total_purchases if canton_iso == "NE"
    assert abs(r(mean) - 0.5884) < 0.001
    di "  NE Milliet spot-check: 17 firms with purchases, 13 with non-blank exports, share_purch = " %5.4f r(mean)

    * GE spot-check (L. Magnin diagnostic: 11 in Milliet roster, but only 10
    * with purchases and 2 with exports -- this is the canton where the
    * "roster vs. variable-specific count" distinction visibly differs).
    qui sum n_firms_purchases if canton_iso == "GE"
    assert r(mean) == 10
    qui sum n_firms_exports if canton_iso == "GE"
    assert r(mean) == 2
    di "  GE Milliet spot-check: 10 firms with purchases (L.Magnin excluded), 2 with exports"

    * 1-year-mean parallels: must equal 5y / 5 exactly for producer cantons
    foreach v in purchases exports domestic {
        qui count if !missing(`v'_kg95_canton) & ///
                     abs(`v'_kg95_canton_yr - `v'_kg95_canton/5) > 1e-6
        assert r(N) == 0
    }
    di "  Milliet 1y means: all 8 producer cantons satisfy purchases/exports/domestic _yr == 5y/5"

    * --- Canton land area: derived via algebra from pop_1900 / pop_density_1900 ---
    * Strictly positive; raw density also positive (no zero-density cantons).
    assert pop_density_1900 > 0 & !missing(pop_density_1900)
    assert canton_area_km2  > 0 & !missing(canton_area_km2)
    assert !missing(ln_canton_area_km2)

    * National-total spot-check: sum across 25 cantons should land near
    * Swiss total area.  Reference points (modern, 26-canton, BE/JU split):
    *   Total area (incl. water):       41,285 km^2
    *   Land area (excl. inland water): 39,997 km^2
    * Our 25-canton 1908 boundaries (BE incl. JU) should give the same total
    * area as the modern 26-canton scheme because Jura is part of Bern here.
    * Tolerance 5% absorbs the GE/NE lake-exclusion convention and any
    * ambiguity over whether other lake-adjacent cantons also exclude lakes.
    qui sum canton_area_km2
    di "  Canton area sum across 25 cantons: " %7.0fc r(sum) ///
       " km^2  (CH total ~41,285 km^2 incl water / ~39,997 excl water; tol 5%)"
    assert inrange(r(sum), 41285 * 0.95, 41285 * 1.05) | ///
           inrange(r(sum), 39997 * 0.95, 39997 * 1.05)

    * Smallest/largest extreme-canton spot-checks
    qui sum canton_area_km2 if canton_iso == "BS"
    di "  BS area spot-check: " %5.0f r(mean) " km^2 (expect ~37 km^2 -- smallest)"
    assert inrange(r(mean), 30, 50)
    qui sum canton_area_km2 if canton_iso == "GR"
    di "  GR area spot-check: " %6.0f r(mean) " km^2 (expect ~7,105 km^2 -- largest)"
    assert inrange(r(mean), 6500, 7500)

    * ln transform identity: ln_canton_area_km2 == ln(canton_area_km2) exactly
    qui count if abs(ln_canton_area_km2 - ln(canton_area_km2)) > 1e-10
    assert r(N) == 0
    di "  ln_canton_area_km2 identity check: ln(area) match for all 25 cantons"
}


**# 10. Save
*------------------------------------------------------------------------------*
{
    order canton_iso ///
          pct_yes_67 pct_yes_68 pct_yes_69 ///
          wine_area_canton_ha wine_volume_canton_hl wine_revenue_canton_fr ///
          wine_yield_canton_hl_per_ha wine_revenue_share_canton ///
          pop_1900 pop_1910 pop_density_1900 canton_area_km2 ln_canton_area_km2 ///
          german_1900 french_1900 german_share french_share ///
          protestant_1900 catholic_1900 protestant_share catholic_share ///
          prior_canton_ban ///
          n_firms_purchases n_firms_exports ///
          purchases_kg95_canton exports_kg95_canton domestic_kg95_canton ///
          share_of_total_purchases share_of_total_exports share_of_total_domestic ///
          purchases_kg95_canton_yr exports_kg95_canton_yr domestic_kg95_canton_yr

    compress
    save "$MyProject/processed/cohort_1908.dta", replace
    di _newline "=== Saved cohort_1908.dta: " c(N) " cantons x " c(k) " vars ==="
    describe, short
}


**# 11. Post-credits: codebook + inventory (inventory only on release runs)
*------------------------------------------------------------------------------*
* _codebook_update is upsert-safe (refreshes the existing entry in codebook.md
* in place) -- always fires.
*
* _inventory_append is APPEND-ONLY (no dedupe).  Calling it on every iteration
* run would accumulate duplicate rows in _inventory.xlsx, polluting the shared
* pipeline-state tracker.  So it's gated behind $RUN_POSTCREDITS == "1".
*
* USAGE:
*   - Interactive iteration (default):  do "...08_setup_cohort_1908.do"
*     (RUN_POSTCREDITS unset -> inventory skipped, no _inventory.xlsx churn)
*   - Release / production run:         global RUN_POSTCREDITS = 1
*                                       do "...08_setup_cohort_1908.do"
*     (inventory.xlsx gets the canonical "I ran this and saved X" rows)
{
    _codebook_update using "$MyProject/processed/cohort_1908.dta", ///
        script("08_setup_cohort_1908.do")

    if "${RUN_POSTCREDITS}" == "1" {
        use "$MyProject/processed/cohort_1908.dta", clear
        local nobs  = c(N)
        local nvars = c(k)
        _inventory_append, sheet("datasets") ///
            row("created|processed/cohort_1908.dta|`nobs'|`nvars'|.|08_setup_cohort_1908.do")
        _inventory_append, sheet("scripts") ///
            row("08_setup_cohort_1908.do|.|Minimalist from-scratch 1908 cohort build: raw swissvotes 67/68/69 + PI verified 1907 wine + HSSO B.32 language (DE/FR shares) + HSSO B.01a population (1900+1910) + HSSO B.27 religion (Cath/Prot shares 1900) + prior_canton_ban dummy (VD-1906 + GE-1908) + Milliet 1907 absinthe industry (8 producer cantons; n_firms_purchases + n_firms_exports + purchases/exports/domestic kg95 5y+1y + 3 shares; 17 non-producers MISSING per PI strict rule) + HSSO B.01b density 1900 -> canton_area_km2 + ln_canton_area_km2 (algebra-derived; lake-excluded for GE/NE)|.")
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1; codebook still refreshed)"
    }
}

** EOF
