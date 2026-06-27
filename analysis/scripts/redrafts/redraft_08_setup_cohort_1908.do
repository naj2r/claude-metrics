/*==============================================================================
 redrafts/redraft_08_setup_cohort_1908.do
 Purpose:  REDRAFT (scratch) of 08_setup_cohort_1908.do.  Rebuilds the cohort on
           the canonical Swiss-stat-tables-wine.xlsx yearbook workbook instead of
           the one-off canton_wine_1907_pi.csv.

           SINGLE SHEET ONLY (PI 2026-06-19): reads just the 1907 sheet directly.
           We do NOT assume other year-sheets share this layout, so there is no
           loop / year-parameterization here — generalize later, one verified
           sheet at a time.  Structural asserts below fail loudly if the sheet
           isn't shaped the way this code expects.

           Built ONE BIT AT A TIME.  This pass covers:
             - 0  preamble                 (preserved from 08)
             - 1  swissvotes import        (PRESERVED VERBATIM from 08 — do not edit)
             - 2  wine 1907 from workbook  (NEW — the redraft)
             - 3  pop 1907 + 1907 density  (NEW — yearbook pop + 1900-census area backout)
             - 4  Milliet absinthe producer (NEW — direct firm register; + §4.5 equivalence gate)
             - 5  language (cov1)           (NEW — B.32 1900; french_share x 100; + §5.4 gate)
             - 6  religion (cov3)           (NEW — B.27 1900; protestant_share x 100; + §6.4 gate)
             - 7  pop_1906 + 1906 density   (NEW — yearbook 1906 col; ln_density_1906 SPEC CHANGE; + §7.4 gate)
             - 8  petition arm             (NEW — Vote-65 elig + AbsinthePetition.xlsx + 3 outcomes; + §8.5 gate)
           ----------------------------------------------------------------------
           BUILD-PHASE MAP  (primary build vs late-stage additions)
           ----------------------------------------------------------------------
           PRIMARY BUILD = the shared right-hand-side covariate cohort, cleaned
           section-by-section with self-validating asserts + an equivalence gate.
           It feeds BOTH 1908 outcomes (#68 vote AND the petition), which ride one
           cohort because they share these covariate values:
             - 0-6  DONE  (votes, wine, pop_1907+ln_density, Milliet producer, language, religion)
             - 7-8  DONE  (petition arm: pop_1906+1906 density, eligibility, signatures, outcomes)
                    -> COHORT COMPLETE.  #68 vote arm + petition arm both built & gated.

           DEFERRED (PI keep-or-drop, default DROP per the lean rule):
             - prior_canton_ban -- built in prod 08 §6 but the usage audit found
               it consumed by NO live workshop spec; not a default-carry covariate.
               PI defers the keep/drop: the VD-1906 / GE-1907 cantonal bans are so
               close in time to the 1908 federal vote that whether they are a clean
               pre-treatment control vs contaminated is a JUDGEMENT CALL.  Add only
               if the PI elects it as a control during streamlining.

           PETITION ARM (§7-§8) -- BUILT + verified (the petition rides THIS cohort;
           it shares the §4/§5/§6 covariates).  One approved deviation from production:
             - §7  pop_1906 (yearbook 1906 col; nat 3,491,163) -> pop_density_1906
                   -> ln_density_1906.  SPEC CHANGE (PI-approved 2026-06-26): prod
                   REUSES #68's 1907 ln_density for the petition; the redraft uses a
                   1906-VINTAGE density (peak-signature year).  OUT of the gate (no
                   prod counterpart); CHANGES the petition col-5 coefficients vs prod.
                   pop_1906 itself IS gated.
             - §8  eligibility eligible_1906 = Vote 65 roll (Lebensmittelgesetz,
                   10 Jun 1906; nat ~784,769) + signatures pet_total/pet_valid/
                   pet_invalid (AbsinthePetition.xlsx; nat 169,377) + outcomes
                   pet_per_eligible (PRIMARY) / pet_per_cap / pet_natshare.  All gated.

           PLANNED (integration, PI 2026-06-27):
             - ADD n_firms_purchases to §4 (one `collapse (count)`): KEEP the absinthe
               producer back-matter for the appendix -- referees want the nuance.  The
               four absinthe producer flavors (all an input PROXY per Milliet's caveat):
               indicator abs_producer / purchase share cov2_total_share / export share
               cov2_exp / firm count abs_nfirms <- n_firms_purchases.
             - SAVE TWO cohort versions: (1) INTERMEDIATE = ALL variables preserved
               (superset; replication transparency); (2) MINIMALIST (cleaned) = the
               regression-AND-table input -- drops the dead intermediates (cov_land,
               ln_pop_1900/1907, dom_share_*, exp_share_abs, *_kg95_canton_yr means,
               n_firms_exports, X4) but KEEPS the absinthe appendix inputs.  Tables read
               the minimalist DIRECTLY (descriptives) or INDIRECTLY (regression .ster
               estimate objects produced from it).
             - Downstream rewrite (09 -> clean names; DELETE the dead-intermediate
               building since the redraft supplies cov1/cov2_total_share/cov3/ln_density
               finished; DROP white/red-wine specs) THEN wire the cohort in.
           ----------------------------------------------------------------------

           NOTE: redraft section numbers follow BUILD order, not the original 08
           numbering (original 08 split population across its 4 and 8).

           Scratch: lives in scripts redrafts dir; writes only a gitignored scratch
           checkpoint (NEVER the production processed cohort_1908.dta).

 Input:    $Absinthe1Data/swissvotes_dataset.csv   (raw swissvotes; section 1)
           $Absinthe1Data/original/Statistical Yearbooks of Switzerland/Swiss-stat-tables-wine.xlsx
                                                    (canonical wine workbook; section 2, sheet "1907 English")

 Output:   $MyProject/results/intermediate/redraft_cohort_1908.dta   (SCRATCH checkpoint,
           gitignored; the standalone preambles reload THIS, not production — so
           chunk (Ctrl+D) re-runs use the redraft's new wine names.  Never the
           production processed cohort_1908.dta, which keeps the old wine names.)

 Author:   Nicholas A Jensen
 Date:     2026-06-19
 Version:  0.6 (redraft; + section 3 pop/density via 1900-census land-area backout)

 Old -> new wine variable map (for the eventual diff vs current 08 section 2):
   wine_area_canton_ha          -> wine_area_ha
   wine_volume_canton_hl        -> wine_volume_hl        (sheet col C "Total yield")
   wine_revenue_canton_fr       -> wine_value_fr
   wine_yield_canton_hl_per_ha  -> wine_yield_per_ha_hl
   wine_revenue_share_canton    -> wine_value_share
   (new)                        -> wine_price_fr_per_hl  (sheet col L); year

 MAINTAINER NOTE: never write a slash immediately followed by a star inside any
 comment (e.g. a trailing-glob path).  Stata reads that two-character sequence as
 a block-comment OPEN and silently comments out everything until the next close
 — it ate this whole section once.  Write "results/intermediate" without a glob.
==============================================================================*/

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
    * Three referenda in the 1908 cohort (67 + 68 on 1908-07-05; 69 on 1908-10-25).
    local cohort_votes 67 68 69

    * 25 cantons in the 1908 universe (BE absorbs JU). Lowercase to match
    * swissvotes column naming (zhja, beja, ...).
    local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
}


**# 1. Load vote shares from raw swissvotes      [PRESERVED VERBATIM FROM 08]
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
    *   <ct>ja -> yes_count   <ct>nein -> no_count   <ct>japroz -> pct_yes
    *   <ct>bet -> turnout     <ct>berecht -> eligible <ct>stimmen -> total ballots
    local keepvars "anr"
    foreach ct of local cantons {
        local keepvars "`keepvars' `ct'ja `ct'nein `ct'japroz `ct'bet `ct'berecht `ct'stimmen"
    }
    keep `keepvars'

    * `reshape long` requires the j-variable to be the SUFFIX of stub names.
    foreach ct of local cantons {
        rename `ct'ja       ja_`ct'
        rename `ct'nein     nein_`ct'
        rename `ct'japroz   japroz_`ct'
        rename `ct'bet      bet_`ct'
        rename `ct'berecht  berecht_`ct'
        rename `ct'stimmen  stimmen_`ct'
    }
}


**# 1.3 Reshape long: 3 votes x 25 cantons = 75 rows
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

    assert c(N) == 75   // 3 votes x 25 cantons
    isid anr canton_iso
    di "Long-format vote-canton panel: 75 rows (3 votes x 25 cantons)"
}


**# 1.4 Reshape wide on anr: 25 cantons x {metric}_{vote} columns
*------------------------------------------------------------------------------*
{
    reshape wide yes_count no_count pct_yes turnout eligible total_votes, ///
        i(canton_iso) j(anr)
    assert c(N) == 25
    isid canton_iso

    foreach v of local cohort_votes {
        rename yes_count`v'   yes_count_`v'
        rename no_count`v'    no_count_`v'
        rename pct_yes`v'     pct_yes_`v'
        rename turnout`v'     turnout_`v'
        rename eligible`v'    eligible_`v'
        rename total_votes`v' total_votes_`v'

        label var pct_yes_`v'     "Vote `v' yes-share (%, 1908 cohort)"
        label var yes_count_`v'   "Vote `v' yes votes"
        label var no_count_`v'    "Vote `v' no votes"
        label var turnout_`v'     "Vote `v' turnout (%)"
        label var eligible_`v'    "Vote `v' eligible voters"
        label var total_votes_`v' "Vote `v' total ballots cast"
    }
    label var canton_iso "Canton (2-letter code, 1908)"

    di "Wide-format cohort panel: 25 cantons x 18 vote columns"
}


**# 1.5 Intermediate checkpoint save (redraft scratch; enables Ctrl+D chunk re-runs)
*------------------------------------------------------------------------------*
* Save the base cohort to a SCRATCH checkpoint so the section-2 standalone-run
* preamble reloads THIS redraft's state (new wine names) rather than the
* production cohort_1908.dta (old wine names).  Gitignored; never production.
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Saved redraft base checkpoint -> results intermediate redraft_cohort_1908.dta"
}


**# 2. Merge in canton wine 1907    [REDRAFT: read canonical workbook directly]
*------------------------------------------------------------------------------*

**# 2.0 Standalone-run preamble: load section-1 output if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel = total_votes_69 (last var added by 1.4). If absent, reload the base
* cohort from the redraft checkpoint (or require section 1 to have run).
{
    cap confirm variable total_votes_69
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 2 needs section 1 output (total_votes_69); run section 1 first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft base checkpoint from disk)"
    }
    foreach v in wine_area_ha wine_volume_hl wine_value_fr wine_yield_per_ha_hl ///
                 wine_price_fr_per_hl wine_area_share wine_volume_share        ///
                 wine_value_share year {
        cap drop `v'
    }

    * Buffer the merge key (str8) so downstream append/merge of multiple year
    * panels can't truncate or trip on a str-length mismatch (PI 2026-06-19).
    * Widening the 2-char codes to str8 is loss-free.
    recast str8 canton_iso
}


**# 2.1 Read the 1907 wine sheet from the canonical workbook (single sheet)
*------------------------------------------------------------------------------*
* SOURCE: Swiss-stat-tables-wine.xlsx, sheet "1907 English" — PI transcription of
* the Swiss statistical yearbook wine-harvest table for 1907.  Read directly, no
* year-parameterization (we do not assume other sheets match this layout).
*
* Expected sheet layout (1-indexed Excel rows and cols), guarded by asserts below:
*   rows 1-8   = multi-row header (titles, units, the column-number row)
*   rows 9-28  = 20 wine cantons       row 29 = Switzerland total (the normalizer)
*   rows 34-36 = PI transcription and QA notes (cells A34:A36) -> attached as notes
*   A=Cantons  B=Cultivated area(ha)  C=Total yield(hl)  D=Total value(Fr)
*   E=Yield-per-ha(hl)   [F-K = red, white, mixed yield and value — deferred]
*   L=Overall avg price per hl(Fr)   [M-O = per-colour price — deferred]
* Em-dash (—, U+2014) in any numeric cell = ZERO (PI 2026-06-19).
* The 5 alpine non-wine cantons (UR/OW/NW/ZG/AI) are ABSENT and padded as zeros.
* Measure variables are DOUBLE (cast via real(), so no float rounding); the key
* is str8-buffered.  These choices are PI-set 2026-06-19.
{
    preserve
        import excel using ///
            "$Absinthe1Data/original/Statistical Yearbooks of Switzerland/Swiss-stat-tables-wine.xlsx", ///
            sheet("1907 English") allstring clear

        * Capture the PI transcription and QA notes (cells A34:A36) BEFORE trimming
        * the sheet; attached as variable notes on wine_value_fr further down.
        local qa1 = strtrim(A[34])
        local qa2 = strtrim(A[35])
        local qa3 = strtrim(A[36])

        * Keep the data block (rows 9-29). Assert the block is where we expect; if
        * the sheet layout drifts this fails loudly instead of mis-reading.
        keep in 9/29
        assert _N == 21                          // 20 wine cantons + Switzerland

        keep A B C D E L
        rename (A B C D E L) ///
               (canton_name wine_area_ha wine_volume_hl wine_value_fr ///
                wine_yield_per_ha_hl wine_price_fr_per_hl)
        replace canton_name = strtrim(canton_name)
        assert canton_name == "Zurich"      in 1   // row 9  (first canton)
        assert canton_name == "Switzerland" in 21  // row 29 (the normalizer)

        * Cast measure columns to numeric DOUBLE via real().  CAUTION (PI): cells
        * other than the canton column can carry stray non-numeric tokens that would
        * silently miscode to missing.  Clear the known ones (em-dash=0, thousands
        * commas, spaces), cast, then ASSERT no present-canton measure is missing
        * (catches any unhandled token).  Re-check the token list per year.
        foreach v of varlist wine_area_ha wine_volume_hl wine_value_fr ///
                              wine_yield_per_ha_hl wine_price_fr_per_hl {
            replace `v' = subinstr(`v', uchar(8212), "0", .)   // em-dash -> 0
            replace `v' = subinstr(`v', ",", "", .)            // thousands separator
            replace `v' = strtrim(`v')
            tempvar num
            gen double `num' = real(`v')
            drop `v'
            rename `num' `v'
        }

        * Canton English-name -> 2-letter ISO; key buffered to str8.
        gen str8 canton_iso = ""
        replace canton_iso = "ZH" if canton_name == "Zurich"
        replace canton_iso = "BE" if canton_name == "Bern"
        replace canton_iso = "LU" if canton_name == "Lucerne"
        replace canton_iso = "SZ" if canton_name == "Schwyz"
        replace canton_iso = "GL" if canton_name == "Glarus"
        replace canton_iso = "FR" if canton_name == "Fribourg"
        replace canton_iso = "SO" if canton_name == "Solothurn"
        replace canton_iso = "BS" if canton_name == "Basel-City"
        replace canton_iso = "BL" if canton_name == "Basel-Country"
        replace canton_iso = "SH" if canton_name == "Schaffhausen"
        replace canton_iso = "AR" if canton_name == "Appenzell Outer Rhodes"
        replace canton_iso = "SG" if canton_name == "St. Gallen"
        replace canton_iso = "GR" if canton_name == "Grisons"
        replace canton_iso = "AG" if canton_name == "Aargau"
        replace canton_iso = "TG" if canton_name == "Thurgau"
        replace canton_iso = "TI" if canton_name == "Ticino"
        replace canton_iso = "VD" if canton_name == "Vaud"
        replace canton_iso = "VS" if canton_name == "Valais"
        replace canton_iso = "NE" if canton_name == "Neuchâtel"
        replace canton_iso = "GE" if canton_name == "Geneva"
        replace canton_iso = "CH" if canton_name == "Switzerland"
        assert canton_iso != ""        // every imported row mapped to an ISO code

        * Miscode guard: every imported row (20 cantons + CH) must be non-missing
        * across all five measures.
        foreach v of varlist wine_area_ha wine_volume_hl wine_value_fr ///
                              wine_yield_per_ha_hl wine_price_fr_per_hl {
            assert !missing(`v')
        }

        * Switzerland totals -> scalars (double) for shares, then drop the row.
        foreach m in area_ha volume_hl value_fr {
            qui sum wine_`m' if canton_iso == "CH", meanonly
            scalar nat_`m' = r(mean)
        }
        drop if canton_iso == "CH"
        assert _N == 20                // 20 wine cantons present in the table

        * National shares (the X1 / X2 / X3 sources), double.
        gen double wine_area_share   = wine_area_ha   / nat_area_ha
        gen double wine_volume_share = wine_volume_hl / nat_volume_hl
        gen double wine_value_share  = wine_value_fr  / nat_value_fr

        * Pad the cantons ABSENT from the table.  PI rule (2026-06-19): an OMITTED
        * canton = non-producer = ZERO ACROSS THE BOARD (every measure, incl.
        * yield-per-ha and price), UNLESS a note flags it as a non-REPORTER that
        * year (then missing, not zero).  For 1907 the 5 omitted cantons
        * UR/OW/NW/ZG/AI are all non-producers -> 0.
        * NOTE: this omission-to-zero call is YEAR-SPECIFIC; re-confirm from the
        * harvest notes before reuse — e.g. 1896/1897 omit SZ/ZG/BL as NON-REPORTERS
        * (= missing), not zeros (weinernte ledger).  Part of generalizing this.
        foreach c in UR OW NW ZG AI {
            local n1 = _N + 1
            set obs `n1'
            replace canton_iso           = "`c'" in `n1'
            replace wine_area_ha         = 0 in `n1'
            replace wine_volume_hl       = 0 in `n1'
            replace wine_value_fr        = 0 in `n1'
            replace wine_yield_per_ha_hl = 0 in `n1'
            replace wine_price_fr_per_hl = 0 in `n1'
            replace wine_area_share      = 0 in `n1'
            replace wine_volume_share    = 0 in `n1'
            replace wine_value_share     = 0 in `n1'
        }

        gen int year = 1907            // manual year tag (int, not double)
        drop canton_name

        * Labels (units in label per project convention).
        label var wine_area_ha          "Wine cultivated area, canton (ha, 1907)"
        label var wine_volume_hl        "Wine total harvest, canton (hl, 1907; sheet 'Total yield')"
        label var wine_value_fr         "Wine total value, canton (Fr, 1907)"
        label var wine_yield_per_ha_hl  "Wine yield per ha (hl per ha, 1907)"
        label var wine_price_fr_per_hl  "Wine overall average price (Fr per hl, 1907)"
        label var wine_area_share       "Wine area share of CH total (0-1, 1907)"
        label var wine_volume_share     "Wine volume share of CH total (0-1, 1907)"
        label var wine_value_share      "Wine value share of CH total (0-1, 1907; X3 source)"
        label var year                  "Harvest year of the wine measures"

        * Attach the A34:A36 transcription and QA notes to the wine data (variable
        * notes; they travel with the variable through save, merge, append).
        notes wine_value_fr: 1907 wine source = Swiss-stat-tables-wine.xlsx ("1907 English").
        notes wine_value_fr: `qa1'
        notes wine_value_fr: `qa2'
        notes wine_value_fr: `qa3'

        assert _N == 25
        isid canton_iso
        * Value-share sums to ~1 across the 25 cantons (zeros contribute 0).
        qui sum wine_value_share
        assert reldif(r(sum), 1) < 1e-6

        tempfile wine_tf
        save `wine_tf'
    restore
}


**# 2.2 Merge 1:1 on canton_iso; assert all 25 match
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `wine_tf', assert(match) nogenerate
    assert c(N) == 25
    isid canton_iso
    di "Merged wine 1907 (canonical workbook) into cohort: 25 cantons matched on canton_iso"
}


**# 2.3 Update the redraft checkpoint (base + wine; enables section-3+ chunk re-runs)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with wine 1907 -> results intermediate redraft_cohort_1908.dta"
}

**# 3. Population 1907 (numerator) + 1907 density (land area backed out from 1900 census)
*------------------------------------------------------------------------------*
* Methodology (PI-confirmed 2026-06-19):
*   Land area is a fixed (time-invariant) geographic constant, NOT read as a number
*   directly.  Back it out of the 1900 census (which reports both population and
*   density, and density = population over area):
*       canton_area_km2  = pop_1900_census / pop_density_1900_census
*   Then apply the fixed area to the 1907 yearbook population:
*       pop_density_1907 = pop_1907 / canton_area_km2
*       ln_density       = ln(pop_density_1907)         <- the headline scale control
*   THREE inputs, three files (the two 1900 inputs MUST be the census values, not
*   the yearbook 1900 estimate, so the backed-out area is internally consistent):
*       pop_1907          <- SwissStats1908_population_1908-1867.xlsx (sheet English, col C)
*       pop_1900          <- B.01a_EN.xlsx  (row 31 = 1900 census)
*       pop_density_1900  <- B.01b_EN.xlsx  (row 12 = 1900 census)
*   Measures are double (PI 2026-06-19); merge keys str8-buffered.

**# 3.0 Standalone-run preamble: reload checkpoint if section 1-2 output is absent
*------------------------------------------------------------------------------*
* Sentinel = wine_value_share (last var added by section 2).
{
    cap confirm variable wine_value_share
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 3 needs sections 1-2 output; run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in pop_1907 pop_1900 pop_density_1900 canton_area_km2 ///
                 pop_density_1907 ln_pop_1907 ln_density {
        cap drop `v'
    }
}


**# 3.1 pop_1907 (numerator) from the yearbook workbook (cantons as rows; col C = 1907)
*------------------------------------------------------------------------------*
* Layout: Excel row 4 = year header (A=Canton, B=1908, C=1907, ... J=1900); cantons
* on Excel rows 5-29 (all 25 present, incl UR/OW/NW/ZG/AI); Switzerland on row 30.
* Canton names carry parentheticals ("Grisons (Graubünden)") -> strip before mapping.
{
    preserve
        import excel using ///
            "$Absinthe1Data/original/Statistical Yearbooks of Switzerland/SwissStats1908_population_1908-1867.xlsx", ///
            sheet("English") allstring clear
        assert A[4] == "Canton"          // header row where expected
        assert real(C[4]) == 1907        // col C is the 1907 column (guard vs drift)
        keep A C
        keep in 5/30                     // 25 cantons + Switzerland total
        rename (A C) (canton_name pop_1907)
        replace canton_name = strtrim(canton_name)
        * Strip a trailing parenthetical qualifier, then trim.
        replace canton_name = strtrim(substr(canton_name, 1, strpos(canton_name, "(") - 1)) ///
            if strpos(canton_name, "(") > 0
        replace pop_1907 = strtrim(subinstr(pop_1907, ",", "", .))
        tempvar p
        gen double `p' = real(pop_1907)
        drop pop_1907
        rename `p' pop_1907

        gen str8 canton_iso = ""
        replace canton_iso = "ZH" if canton_name == "Zurich"
        replace canton_iso = "BE" if canton_name == "Bern"
        replace canton_iso = "LU" if canton_name == "Lucerne"
        replace canton_iso = "UR" if canton_name == "Uri"
        replace canton_iso = "SZ" if canton_name == "Schwyz"
        replace canton_iso = "OW" if canton_name == "Obwalden"
        replace canton_iso = "NW" if canton_name == "Nidwalden"
        replace canton_iso = "GL" if canton_name == "Glarus"
        replace canton_iso = "ZG" if canton_name == "Zug"
        replace canton_iso = "FR" if canton_name == "Fribourg"
        replace canton_iso = "SO" if canton_name == "Solothurn"
        replace canton_iso = "BS" if canton_name == "Basel-City"
        replace canton_iso = "BL" if canton_name == "Basel-Country"
        replace canton_iso = "SH" if canton_name == "Schaffhausen"
        replace canton_iso = "AR" if canton_name == "Appenzell Outer Rhodes"
        replace canton_iso = "AI" if canton_name == "Appenzell Inner Rhodes"
        replace canton_iso = "SG" if canton_name == "St. Gallen"
        replace canton_iso = "GR" if canton_name == "Grisons"
        replace canton_iso = "AG" if canton_name == "Aargau"
        replace canton_iso = "TG" if canton_name == "Thurgau"
        replace canton_iso = "TI" if canton_name == "Ticino"
        replace canton_iso = "VD" if canton_name == "Vaud"
        replace canton_iso = "VS" if canton_name == "Valais"
        replace canton_iso = "NE" if canton_name == "Neuchâtel"
        replace canton_iso = "GE" if canton_name == "Geneva"
        replace canton_iso = "CH" if canton_name == "Switzerland"
        assert canton_iso != ""          // every imported row mapped to an ISO code
        assert !missing(pop_1907)        // miscode guard

        * Integrity checks.  The PRIMARY check uses NO external number:
        *   (a) SELF-VALIDATING: the 25 cantons must sum to the file's OWN printed
        *       Switzerland row (read at runtime) -> catches a dropped/misread canton.
        qui sum pop_1907 if canton_iso == "CH", meanonly
        scalar ch_total_1907 = r(mean)
        qui sum pop_1907 if canton_iso != "CH"
        assert reldif(r(sum), ch_total_1907) < 1e-6
        *   (b) SOURCE-VERSION PIN (documented; optional): the file's printed 1907
        *       Switzerland total is the 1908 Statistical Yearbook figure 3,524,529
        *       (same cross-check constant in build_pop_canton_yearbook.py + orig 08).
        *       This is NOT an independent ground truth -- it only pins the source
        *       edition, so a swapped/edited file fires.  Delete this one line for a
        *       purely self-validating check.
        assert reldif(ch_total_1907, 3524529) < 1e-6

        drop if canton_iso == "CH"
        assert _N == 25
        isid canton_iso
        keep canton_iso pop_1907
        tempfile pop1907_tf
        save `pop1907_tf'
    restore
}


**# 3.2 pop_1900 (census) from HSSO B.01a (row 31 = 1900)  [as original 08 sec 4.1a]
*------------------------------------------------------------------------------*
* HSSO layout: years as ROWS, cantons as COLUMNS (B,C,E..AA = 25 cantons; D skipped).
{
    preserve
        import excel using "$Absinthe1Data/translated/B.01a_EN.xlsx", clear allstring
        assert A[31] == "1900"
        keep in 31
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")   // strip HSSO footnote prefix
            replace `v' = regexr(`v', "[*]+", "")
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 pop_1900
        rename _varname canton_iso
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile pop1900_tf
        save `pop1900_tf'
    restore
}


**# 3.3 pop_density_1900 (census) from HSSO B.01b (row 12 = 1900)  [as original 08 sec 8.1]
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
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile dens1900_tf
        save `dens1900_tf'
    restore
}


**# 3.4 Merge the three inputs; back out land area; derive 1907 density + ln
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `pop1907_tf',  assert(match) nogenerate
    merge 1:1 canton_iso using `pop1900_tf',  assert(match) nogenerate
    merge 1:1 canton_iso using `dens1900_tf', assert(match) nogenerate
    assert c(N) == 25

    * Land area = 1900 census pop / 1900 census density (fixed, time-invariant).
    assert pop_1900 > 0 & !missing(pop_1900)
    assert pop_density_1900 > 0 & !missing(pop_density_1900)
    gen double canton_area_km2 = pop_1900 / pop_density_1900

    * Apply the fixed area to 1907 population.
    assert pop_1907 > 0 & !missing(pop_1907)
    gen double pop_density_1907 = pop_1907 / canton_area_km2
    gen double ln_pop_1907      = ln(pop_1907)
    gen double ln_density       = ln(pop_density_1907)

    label var pop_1907         "Resident population, canton (1907 yearbook mid-year estimate)"
    label var pop_1900         "Resident population, canton (1900 census)"
    label var pop_density_1900 "Population density, canton (per km^2, 1900 census; for area backout)"
    label var canton_area_km2  "Canton land area (km^2; = pop_1900 over pop_density_1900, fixed survey constant)"
    label var pop_density_1907 "Population density, canton (per km^2, 1907 = pop_1907 over fixed land area)"
    label var ln_pop_1907      "Log canton population (1907 yearbook estimate)"
    label var ln_density       "Log population density (1907 pop over fixed 1900-census land area; headline control)"

    * Derived-value identity check.  (The national total was already validated in
    * section 3.1 against the file's own Switzerland row, and the three merges are
    * assert(match), so the same 25 values came in -- no magic-number re-check here.)
    assert reldif(ln_density, ln(pop_1907 / canton_area_km2)) < 1e-12
    di "Derived: area = pop_1900 over density_1900; pop_density_1907 = pop_1907 over area; ln_density = ln(.)"
}


**# 3.5 Update the redraft checkpoint (base + wine + pop/density)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with pop/density 1907 -> results intermediate redraft_cohort_1908.dta"
}

**# 4. Absinthe producer (Milliet 1907) — firm register -> canton purchases & exports
*------------------------------------------------------------------------------*
* SOURCE: original/MillietTables/AbsintheEst1908.xlsx, sheet "English" — Milliet
* (Federal Alcohol Administration) firm-level register of absinthe distilleries'
* high-proof spirit PURCHASES from the monopoly and refund-eligible EXPORTS, as
* 5-YEAR totals 1902-1906 (the 5-year window is the only per-firm granularity; the
* "or per Year" trailer row is just Total/5).  40 firms across 8 producer cantons,
* a "Total" row, and a per-year row trail the firm block.
*
* This section (import + setup) lands the canton-level Milliet table in a tempfile:
*   purchases_kg95_canton  (col C, kg @ 95 deg)   exports_kg95_canton  (col D)
* The shares (cov2_total_share, cov2_exp) and the producer dummy (abs_producer)
* are built in the NEXT subsections after the merge.
*
* CONVENTIONS / WATCHES:
*  - Excel-number columns -> import NUMERIC directly (no allstring); blanks -> missing.
*    `confirm numeric` is the tripwire: a stray token would flip a column to string.
*  - Blanks (PI rule): export blank = no refund export = TRUE 0 (reliable column).
*    A blank PURCHASE for a LISTED firm is an ANOMALY (they're listed because they
*    purchased) -> FLAG it, don't silently zero.  L. Magnin, Eaux-Vives (Geneva) is
*    the one known case; the assert fires if a NEW blank appears in a future vintage.
*  - Non-listed cantons (the other 17) = structural 0; handled at the merge/zero-fill.
*  - str8 key; double measures; self-validating (canton sums == file's own totals).
*  - BE absorbs JU (BE is a non-producer -> 0 downstream); no JU anywhere.

**# 4.0 Standalone-run preamble: reload checkpoint if section 1-3 output is absent
*------------------------------------------------------------------------------*
* Sentinel = ln_density (last var added by section 3.4).
{
    cap confirm variable ln_density
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 4 needs sections 1-3 output (ln_density); run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in purchases_kg95_canton exports_kg95_canton ///
                 cov2_total_share cov2_exp abs_producer {
        cap drop `v'
    }
}

/*Above description:
	1. confirm variable is there otherwise do the error, then if true display... then capture drop those variables for idempotent code.
	
	
*/

**# 4.1 Read the Milliet firm register; collapse firms -> 8 producer cantons
*------------------------------------------------------------------------------*
* Excel rows 2-43 -> Stata obs 1-42: obs 1-40 = firms, obs 41 = "Total", obs 42 =
* "or per Year".  cellrange skips the header row, so vars take Excel column letters
* A B C D (A=canton, B=firm, C=purchases, D=exports).
{
    preserve
        import excel using ///
            "$Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx", ///
            sheet("English") cellrange(A2:D43) clear
        assert _N == 42
        assert B[41] == "Total"
        assert B[42] == "or per Year"

        * Tripwire: a stray non-numeric token would flip the whole column to string.
        confirm numeric variable C
        confirm numeric variable D

        * National 5-year totals (the share denominators), from the "Total" row.
        * The file's OWN published totals -> self-validating (re-checked vs the
        * canton sums after collapse).  The == pins are optional source-version pins.
        scalar nat_purch_5y = C[41]
        scalar nat_exp_5y   = D[41]
        assert nat_purch_5y == 5402342	// save values for national purchases
        assert nat_exp_5y   == 320553	// save values for national exports

        * Keep the 40 firm rows.
        keep in 1/40
        assert _N == 40
        rename (A B C D) (canton_name firm_name purchases_kg95_firm exports_kg95_firm)

        * Blank handling (PI rule).  Purchase blanks for listed firms are anomalies:
        * flag, assert there is at most the one known case (L. Magnin), then treat as
        * a 0 contribution (matches production's collapse-sum-of-nonmissing).  Export
        * blanks are genuine zeros (no refund export) and need no flag.
        qui count if missing(purchases_kg95_firm)
        local n_blank = r(N)
        if `n_blank' {
            di as text "  blank PURCHASE for listed firm(s) (flagged; treated as 0):"
            list canton_name firm_name if missing(purchases_kg95_firm), noobs
        }
        assert `n_blank' <= 1
        replace purchases_kg95_firm = 0 if missing(purchases_kg95_firm)
        replace exports_kg95_firm   = 0 if missing(exports_kg95_firm)

        * Firm -> canton ISO (str8 key).  8 distinct canton labels in column A.
        replace canton_name = strtrim(canton_name)
        gen str8 canton_iso = ""
        replace canton_iso = "NE" if canton_name == "Neuchâtel"
        replace canton_iso = "GE" if canton_name == "Geneva"
        replace canton_iso = "BS" if canton_name == "Basel"        // Basel-City
        replace canton_iso = "VD" if canton_name == "Vaud"
        replace canton_iso = "SZ" if canton_name == "Schwyz"
        replace canton_iso = "ZG" if canton_name == "Zug"
        replace canton_iso = "FR" if canton_name == "Fribourg"
        replace canton_iso = "VS" if canton_name == "Valais"
        assert canton_iso != ""                                     // every firm mapped

        * Firm -> canton aggregation (5-year totals summed within canton).
        collapse (sum) purchases_kg95_canton = purchases_kg95_firm ///
                       exports_kg95_canton   = exports_kg95_firm,   ///
                 by(canton_iso)
        assert _N == 8                                              // 8 producer cantons

        * Self-validating reconciliation: canton sums == file's printed nationals.
        qui sum purchases_kg95_canton
        assert reldif(r(sum), nat_purch_5y) < 1e-6
        qui sum exports_kg95_canton
        assert reldif(r(sum), nat_exp_5y) < 1e-6

        label var purchases_kg95_canton "Spirit purchases 1902-06, canton (kg @ 95 deg; Milliet)"
        label var exports_kg95_canton   "Refund-eligible exports 1902-06, canton (kg @ 95 deg; Milliet)"
        notes purchases_kg95_canton: source = AbsintheEst1908.xlsx ("English"); Milliet 5-year firm register 1902-1906.

        di as text "  Milliet: 40 firms -> 8 producer cantons; purchases & exports reconcile to national totals"

        tempfile milliet_tf
        save `milliet_tf'
    restore
}


**# 4.2 Merge Milliet into the cohort; headline dummy by firm identification
*------------------------------------------------------------------------------*
* The merge encodes producer status: a canton matching the register has >=1 listed
* firm (producer); one that doesn't is a structural non-producer.  Leave the raw kg
* columns MISSING for the 17 non-listed cantons -- production's representation: no
* Milliet record = no data; the *shares* (4.3) carry the structural 0.  abs_producer
* is defined by firm-register MEMBERSHIP (the merge match), independent of the
* purchase quantities Milliet flags as unreliable.
{
    merge 1:1 canton_iso using `milliet_tf'
    assert _merge != 2                     // every Milliet canton exists in the 25
    qui count if _merge == 3
    assert r(N) == 8                       // exactly 8 producer cantons matched

    gen byte abs_producer = (_merge == 3)
    label var abs_producer "Absinthe producer canton (Milliet firm-register membership; headline)"
    drop _merge

    * (No raw-kg zero-fill: purchases/exports stay MISSING for the 17 non-producers,
    *  matching production; only the shares in 4.3 are zero-filled.)

    assert _N == 25
    isid canton_iso
    assert abs_producer == 0 if canton_iso == "BE"   // BE (absorbs JU) is a non-producer
    assert canton_iso != "JU"                        // no separate Jura in 1908
    di as text "  Milliet merged: 8 producers (abs_producer=1); raw kg missing for 17 non-listed"
}


**# 4.3 Continuous share measures (shares zero-filled) + dummy cross-check
*------------------------------------------------------------------------------*
* Shares = canton / national * 100 (double; denominators = the file's printed 5-year
* totals from 4.1, which survive restore because scalars aren't part of the dataset).
* Built from the raw kg (missing for the 17), then the SHARES get the structural 0 --
* a non-producer's share of the national total is a meaningful 0 even though its raw
* kg is "no data".  This split (raw missing, shares zero) is what makes the block
* byte-equal to production.  cov2_total_share is ported for continuity but DEMOTED
* (Milliet flags the purchase quantities as unreliable; prefer abs_producer + cov2_exp).
{
    gen double cov2_total_share = purchases_kg95_canton / nat_purch_5y * 100
    gen double cov2_exp         = exports_kg95_canton   / nat_exp_5y   * 100
    replace cov2_total_share = 0 if missing(cov2_total_share)
    replace cov2_exp         = 0 if missing(cov2_exp)

    label var cov2_total_share "Canton share of national absinthe purchases (%, Milliet)"
    label var cov2_exp         "Canton share of national absinthe exports (%, Milliet)"
    notes cov2_total_share: DEMOTED -- Milliet flags purchase quantities as not a reliable production measure; ported for continuity, not a headline/main-table measure. Prefer abs_producer (firm-register membership) and cov2_exp (exports, "considerably more reliable").

    * Cross-check: the membership dummy lands on the same 8 cantons as the quantity
    * rule (positive purchases iff a listed firm).  Validates membership == quantity.
    assert abs_producer == (cov2_total_share > 0 & !missing(cov2_total_share))
    qui count if abs_producer == 1
    assert r(N) == 8
    assert !missing(cov2_total_share) & !missing(cov2_exp)
    di as text "  cov2_total_share + cov2_exp built (shares zero-filled); dummy cross-check OK"
}


**# 4.4 Update the redraft checkpoint (base + wine + pop/density + Milliet producer)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with Milliet producer measures -> results intermediate redraft_cohort_1908.dta"
}


**# 4.5 Equivalence gate: 5 consumed producer columns vs frozen production snapshot
*------------------------------------------------------------------------------*
* Proves the redraft's producer block reproduces production byte-for-byte on the
* columns any downstream script actually reads (purchases/exports_kg95_canton,
* cov2_total_share, cov2_exp, abs_producer).  Gated against a FROZEN copy of the
* pre-consolidation production cohort -- NOT the live file -- so a future promotion
* of the redraft can't make the gate compare against itself.
* processed/ is gitignored, so a fresh clone / reviewer has no snapshot: the gate
* SKIPS (does not error) when the snapshot is absent.
{
    local snap "$MyProject/processed/cohort_1908_workshop_preconsolidation.dta"
    cap confirm file "`snap'"
    if _rc {
        di as text "  4.5 equivalence gate SKIPPED -- no frozen snapshot at `snap'"
        di as text "    (processed/ is gitignored; expected on a fresh clone / reviewer machine)."
    }
    else {
        preserve
            * Redraft side: the 5 consumed columns, suffixed _rd.
            keep canton_iso purchases_kg95_canton exports_kg95_canton ///
                 cov2_total_share cov2_exp abs_producer
            foreach v in purchases_kg95_canton exports_kg95_canton ///
                         cov2_total_share cov2_exp abs_producer {
                rename `v' `v'_rd
            }
            tempfile rd
            save `rd'

            * Frozen snapshot: same 5 columns; key recast str8 to match the redraft
            * (production stores canton_iso as str2 -- merge on VALUE, not datasignature).
            use "`snap'", clear
            keep canton_iso purchases_kg95_canton exports_kg95_canton ///
                 cov2_total_share cov2_exp abs_producer
            recast str8 canton_iso
            merge 1:1 canton_iso using `rd', assert(match) nogenerate
            assert _N == 25

            * (i) missing-pattern: raw kg missing on the same 17, present on the 8.
            foreach v in purchases_kg95_canton exports_kg95_canton {
                assert missing(`v') == missing(`v'_rd)
                qui count if !missing(`v')
                assert r(N) == 8
                qui count if missing(`v')
                assert r(N) == 17
            }
            * (ii) values: raw kg exact where both present (integers); shares reldif<1e-6.
            foreach v in purchases_kg95_canton exports_kg95_canton {
                assert `v' == `v'_rd if !missing(`v') & !missing(`v'_rd)
            }
            foreach v in cov2_total_share cov2_exp {
                assert reldif(`v', `v'_rd) < 1e-6
            }
            * abs_producer: exact 0/1 on all 25, and 1 for exactly the 8 named cantons.
            assert inlist(abs_producer, 0, 1)
            assert abs_producer == abs_producer_rd
            gen byte _is8 = inlist(canton_iso,"NE","GE","BS","VD","SZ","ZG","FR","VS")
            assert abs_producer == _is8
            di as text "  4.5 equivalence gate PASSED -- 5 consumed cols byte-equal to frozen production snapshot."
        restore
    }
}


**# 5. Language: French share (cov1) from HSSO B.32 (1900 census)
*------------------------------------------------------------------------------*
* SOURCE: $Absinthe1Data/translated/B.32_EN.xlsx (HSSO B.32, mother-tongue census).
* Single sheet; years are ROWS within per-language sub-blocks, cantons are COLUMNS.
*   German 1900 = row 9 (col A == "1900");  French 1900 = row 24.
*   keep B C E..AA = 25 cantons (col C = "BE, JU" COMBINED; separate-BE col D and the
*   JU/CH/year cols are skipped) -- same column set as §3.2/§3.3 (B.01a/B.01b).
*   Cells carry HSSO footnote prefixes ("a)1234") + asterisks -> allstring + regex-
*   strip + destring (NOT auto-type; unlike Milliet, these data cells have cruft).
* LEAN SCOPE (PI): build french_share (subset denom) -> cov1 only.  german_share and
*   french_share_total are NOT built.  german_1900/french_1900 kept as raw inputs.

**# 5.0 Standalone-run preamble: reload checkpoint if §1-§4 output is absent
*------------------------------------------------------------------------------*
* Sentinel = abs_producer (last var added by §4.2).
{
    cap confirm variable abs_producer
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 5 needs sections 1-4 output (abs_producer); run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in german_1900 french_1900 french_share cov1 {
        cap drop `v'
    }
}


**# 5.1 Read German (row 9) and French (row 24) speaker counts from B.32
*------------------------------------------------------------------------------*
* Same HSSO extract pattern as §3.2/§3.3: keep the 25 canton columns (skip D),
* strip footnote prefixes + asterisks, destring, then xpose to canton rows.
{
    * --- German 1900 (row 9) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.32_EN.xlsx", clear allstring
        assert A[9] == "1900"
        keep in 9
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")    // strip HSSO "a)" footnote prefix
            replace `v' = regexr(`v', "[*]+", "")         // strip asterisks
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 german_1900
        rename _varname canton_iso
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile lang_german
        save `lang_german'
    restore

    * --- French 1900 (row 24) ---
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
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile lang_french
        save `lang_french'
    restore
}


**# 5.2 Merge onto cohort; French share (subset denom) -> cov1
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `lang_german', assert(match) nogenerate
    merge 1:1 canton_iso using `lang_french', assert(match) nogenerate
    assert _N == 25

    gen double french_share = french_1900 / (german_1900 + french_1900)   // subset denom (de+fr)
    gen double cov1         = french_share * 100                          // percent (matches prod)

    assert inrange(french_share, 0, 1)
    assert !missing(french_share) & !missing(cov1)

    label var german_1900  "German speakers, canton (HSSO B.32, 1900 census, persons)"
    label var french_1900  "French speakers, canton (HSSO B.32, 1900 census, persons)"
    label var french_share "French share of Ger.+Fr. speakers (1900, subset denom)"
    label var cov1         "French language share (%, 1900 census)"
    di as text "  Language: german_1900 + french_1900 -> french_share -> cov1 (subset denom)"
}


**# 5.3 Update the redraft checkpoint (+ language)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with language (cov1) -> results intermediate redraft_cohort_1908.dta"
}


**# 5.4 Equivalence gate: language columns vs frozen production snapshot
*------------------------------------------------------------------------------*
{
    local snap "$MyProject/processed/cohort_1908_workshop_preconsolidation.dta"
    cap confirm file "`snap'"
    if _rc {
        di as text "  5.4 equivalence gate SKIPPED -- no frozen snapshot at `snap'"
    }
    else {
        preserve
            keep canton_iso german_1900 french_1900 french_share cov1
            foreach v in german_1900 french_1900 french_share cov1 {
                rename `v' `v'_rd
            }
            tempfile rd
            save `rd'
            use "`snap'", clear
            keep canton_iso german_1900 french_1900 french_share cov1
            recast str8 canton_iso
            merge 1:1 canton_iso using `rd', assert(match) nogenerate
            assert _N == 25
            foreach v in german_1900 french_1900 french_share cov1 {
                assert reldif(`v', `v'_rd) < 1e-6
            }
            di as text "  5.4 equivalence gate PASSED -- language cols byte-equal to frozen production snapshot."
        restore
    }
}


**# 6. Religion: Protestant share (cov3) from HSSO B.27 (1900 census)
*------------------------------------------------------------------------------*
* SOURCE: $Absinthe1Data/translated/B.27_EN.xlsx.  Same layout family as B.32/B.01a
* (col C = "BE, JU" combined; skip D/AB/AC/AD).  Protestant 1900 = row 13, Catholic
* 1900 = row 31 (Roman + Old; the row-42 "Of which: Roman Catholic" block is SKIPPED).
* allstring + footnote-strip + destring (data cells carry HSSO "a)" / asterisk cruft).
* LEAN SCOPE (PI): build protestant_share (subset denom) -> cov3 only.  catholic_share
* is NOT built (= 1 - protestant_share; unconsumed by live workshop specs).  Raw counts
* protestant_1900/catholic_1900 kept (catholic_1900 is the denominator input).

**# 6.0 Standalone-run preamble: reload checkpoint if §1-§5 output is absent
*------------------------------------------------------------------------------*
* Sentinel = cov1 (last var added by §5.2).
{
    cap confirm variable cov1
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 6 needs sections 1-5 output (cov1); run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in protestant_1900 catholic_1900 protestant_share cov3 {
        cap drop `v'
    }
}


**# 6.1 Read Protestant (row 13) and Catholic (row 31) counts from B.27
*------------------------------------------------------------------------------*
{
    * --- Protestant 1900 (row 13) ---
    preserve
        import excel using "$Absinthe1Data/translated/B.27_EN.xlsx", clear allstring
        assert A[13] == "1900"
        keep in 13
        keep B C E F G H I J K L M N O P Q R S T U V W X Y Z AA
        foreach v of varlist _all {
            replace `v' = regexr(`v', "^[a-z]\)", "")    // strip HSSO "a)" footnote prefix
            replace `v' = regexr(`v', "[*]+", "")         // strip asterisks
        }
        destring _all, replace force
        rename (B C E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
               (ZH BE LU UR SZ OW NW GL ZG FR SO BS BL SH AR AI SG GR AG TG TI VD VS NE GE)
        xpose, clear varname
        rename v1 protestant_1900
        rename _varname canton_iso
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile rel_prot
        save `rel_prot'
    restore

    * --- Catholic 1900 (row 31; Roman + Old, NOT the row-42 Roman-only block) ---
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
        recast str8 canton_iso
        assert c(N) == 25
        isid canton_iso
        tempfile rel_cath
        save `rel_cath'
    restore
}


**# 6.2 Merge onto cohort; Protestant share (subset denom) -> cov3
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `rel_prot', assert(match) nogenerate
    merge 1:1 canton_iso using `rel_cath', assert(match) nogenerate
    assert _N == 25

    gen double protestant_share = protestant_1900 / (protestant_1900 + catholic_1900)
    gen double cov3             = protestant_share * 100        // percent (matches prod)

    assert inrange(protestant_share, 0, 1)
    assert !missing(protestant_share) & !missing(cov3)
    * Confession spot-check (no catholic_share needed): AR Protestant, AI Catholic.
    qui sum protestant_share if canton_iso == "AR"
    assert r(mean) > 0.85
    qui sum protestant_share if canton_iso == "AI"
    assert r(mean) < 0.15

    label var protestant_1900  "Protestant population (HSSO B.27, 1900 census, persons; incl. sects)"
    label var catholic_1900    "Catholic population (HSSO B.27, 1900 census, persons; Roman + Old)"
    label var protestant_share "Protestant share of Christians (1900, subset denom = Prot + Cath)"
    label var cov3             "Protestant share (%, 1900 census)"
    di as text "  Religion: protestant_1900 + catholic_1900 -> protestant_share -> cov3 (subset denom)"
}


**# 6.3 Update the redraft checkpoint (+ religion)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with religion (cov3) -> results intermediate redraft_cohort_1908.dta"
}


**# 6.4 Equivalence gate: religion columns vs frozen production snapshot
*------------------------------------------------------------------------------*
{
    local snap "$MyProject/processed/cohort_1908_workshop_preconsolidation.dta"
    cap confirm file "`snap'"
    if _rc {
        di as text "  6.4 equivalence gate SKIPPED -- no frozen snapshot at `snap'"
    }
    else {
        preserve
            keep canton_iso protestant_1900 catholic_1900 protestant_share cov3
            foreach v in protestant_1900 catholic_1900 protestant_share cov3 {
                rename `v' `v'_rd
            }
            tempfile rd
            save `rd'
            use "`snap'", clear
            keep canton_iso protestant_1900 catholic_1900 protestant_share cov3
            recast str8 canton_iso
            merge 1:1 canton_iso using `rd', assert(match) nogenerate
            assert _N == 25
            foreach v in protestant_1900 catholic_1900 protestant_share cov3 {
                assert reldif(`v', `v'_rd) < 1e-6
            }
            di as text "  6.4 equivalence gate PASSED -- religion cols byte-equal to frozen production snapshot."
        restore
    }
}


**# 7. Population 1906 (petition vintage) + 1906 density  [LATE-STAGE, vintage-matched]
*------------------------------------------------------------------------------*
* The petition is a 1906 event (peak-signature year), so its population/scale inputs
* are 1906-vintage -- the deliberate SINGLE-CASE EXCEPTION to the rest of the cohort
* (1900-census covariates + 1907 for #68).  pop_1906 comes from the SAME yearbook as
* pop_1907 (§3), just the 1906 column (col D); national total 3,491,163.  pop_1906 is
* itself an inter-census annual estimate (a "rough midpoint" between the 1900 and 1910
* censuses), per the yearbook.
*
* SPEC CHANGE (PI-approved 2026-06-26): production REUSES #68's 1907 ln_density for the
* petition spec (08 §8.2 is explicit: "no density derived on 1906").  The redraft
* instead builds a 1906-VINTAGE ln_density_1906 via the SAME fixed-area backout as §3
* (canton_area_km2 = 1900-census pop/density, time-invariant).  This DEVIATES from
* production -> it is OUT of the equivalence gate (no prod counterpart) and CHANGES the
* petition col-5 coefficients vs prod; validated by the derived-identity assert, not a
* gate.  pop_1906 itself IS in production -> gated (§7.4).  See methods note
* analysis/documentation/methods/petition_arm_construction.md.

**# 7.0 Standalone-run preamble: reload checkpoint if §1-§6 output is absent
*------------------------------------------------------------------------------*
* Sentinel = cov3 (last var added by §6.2).
{
    cap confirm variable cov3
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 7 needs sections 1-6 output (cov3); run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in pop_1906 pop_density_1906 ln_density_1906 {
        cap drop `v'
    }
}


**# 7.1 Read pop_1906 from the yearbook (col D = 1906), self-validating
*------------------------------------------------------------------------------*
* Same sheet/pattern as §3.1 (pop_1907), col D instead of C.  Self-validating: the 25
* cantons sum to the file's own Switzerland row (= 3,491,163, the optional pin).
{
    preserve
        import excel using ///
            "$Absinthe1Data/original/Statistical Yearbooks of Switzerland/SwissStats1908_population_1908-1867.xlsx", ///
            sheet("English") allstring clear
        assert A[4] == "Canton"
        assert real(D[4]) == 1906          // col D = 1906 (B=1908, C=1907, D=1906)
        keep A D
        keep in 5/30
        rename (A D) (canton_name pop_1906)
        replace canton_name = strtrim(canton_name)
        replace canton_name = strtrim(substr(canton_name, 1, strpos(canton_name, "(") - 1)) ///
            if strpos(canton_name, "(") > 0
        replace pop_1906 = strtrim(subinstr(pop_1906, ",", "", .))
        tempvar p
        gen double `p' = real(pop_1906)
        drop pop_1906
        rename `p' pop_1906
        gen str8 canton_iso = ""
        replace canton_iso = "ZH" if canton_name == "Zurich"
        replace canton_iso = "BE" if canton_name == "Bern"
        replace canton_iso = "LU" if canton_name == "Lucerne"
        replace canton_iso = "UR" if canton_name == "Uri"
        replace canton_iso = "SZ" if canton_name == "Schwyz"
        replace canton_iso = "OW" if canton_name == "Obwalden"
        replace canton_iso = "NW" if canton_name == "Nidwalden"
        replace canton_iso = "GL" if canton_name == "Glarus"
        replace canton_iso = "ZG" if canton_name == "Zug"
        replace canton_iso = "FR" if canton_name == "Fribourg"
        replace canton_iso = "SO" if canton_name == "Solothurn"
        replace canton_iso = "BS" if canton_name == "Basel-City"
        replace canton_iso = "BL" if canton_name == "Basel-Country"
        replace canton_iso = "SH" if canton_name == "Schaffhausen"
        replace canton_iso = "AR" if canton_name == "Appenzell Outer Rhodes"
        replace canton_iso = "AI" if canton_name == "Appenzell Inner Rhodes"
        replace canton_iso = "SG" if canton_name == "St. Gallen"
        replace canton_iso = "GR" if canton_name == "Grisons"
        replace canton_iso = "AG" if canton_name == "Aargau"
        replace canton_iso = "TG" if canton_name == "Thurgau"
        replace canton_iso = "TI" if canton_name == "Ticino"
        replace canton_iso = "VD" if canton_name == "Vaud"
        replace canton_iso = "VS" if canton_name == "Valais"
        replace canton_iso = "NE" if canton_name == "Neuchâtel"
        replace canton_iso = "GE" if canton_name == "Geneva"
        replace canton_iso = "CH" if canton_name == "Switzerland"
        assert canton_iso != ""
        assert !missing(pop_1906)
        qui sum pop_1906 if canton_iso == "CH", meanonly
        scalar ch_1906 = r(mean)
        qui sum pop_1906 if canton_iso != "CH"
        assert reldif(r(sum), ch_1906) < 1e-6
        assert reldif(ch_1906, 3491163) < 1e-6     // optional source-version pin
        drop if canton_iso == "CH"
        assert _N == 25
        keep canton_iso pop_1906
        tempfile pop1906_tf
        save `pop1906_tf'
    restore
}


**# 7.2 Merge pop_1906; back out 1906 density (fixed §3 area) -> ln_density_1906
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_iso using `pop1906_tf', assert(match) nogenerate
    assert _N == 25

    * Same fixed land area as §3 (canton_area_km2 = 1900-census pop / density).
    assert canton_area_km2 > 0 & !missing(canton_area_km2)
    gen double pop_density_1906 = pop_1906 / canton_area_km2
    gen double ln_density_1906  = ln(pop_density_1906)
    assert reldif(ln_density_1906, ln(pop_1906 / canton_area_km2)) < 1e-12
    assert pop_density_1906 > 0 & !missing(ln_density_1906)

    label var pop_1906         "Resident population, canton (1906 yearbook annual estimate; petition denom)"
    label var pop_density_1906 "Population density, canton (per km^2, 1906 = pop_1906 over fixed §3 land area)"
    label var ln_density_1906  "Log pop density 1906 (petition vintage; SPEC CHANGE vs prod's 1907 ln_density)"
    di as text "  pop_1906 + 1906 density: ln_density_1906 (vintage-matched petition scale control)"
}


**# 7.3 Update the redraft checkpoint (+ pop_1906 + 1906 density)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with pop_1906 + 1906 density -> results intermediate redraft_cohort_1908.dta"
}


**# 7.4 Equivalence gate: pop_1906 vs frozen snapshot (density is the spec-change)
*------------------------------------------------------------------------------*
* Only pop_1906 is gated -- it exists in production.  pop_density_1906 / ln_density_1906
* are the approved spec-change (no prod counterpart) and are validated by the §7.2
* derived-identity assert instead.
{
    local snap "$MyProject/processed/cohort_1908_workshop_preconsolidation.dta"
    cap confirm file "`snap'"
    if _rc {
        di as text "  7.4 equivalence gate SKIPPED -- no frozen snapshot at `snap'"
    }
    else {
        preserve
            keep canton_iso pop_1906
            rename pop_1906 pop_1906_rd
            tempfile rd
            save `rd'
            use "`snap'", clear
            keep canton_iso pop_1906
            recast str8 canton_iso
            merge 1:1 canton_iso using `rd', assert(match) nogenerate
            assert _N == 25
            assert reldif(pop_1906, pop_1906_rd) < 1e-6
            di as text "  7.4 equivalence gate PASSED -- pop_1906 byte-equal to frozen snapshot (ln_density_1906 is the approved spec-change, ungated)."
        restore
    }
}


**# 8. Petition arm: eligibility + signatures + outcomes  [LATE-STAGE]
*------------------------------------------------------------------------------*
* The petition rides THIS cohort (it shares the §4/§5/§6 covariates).  Numerator =
* signatures (AbsinthePetition.xlsx); two denominators -> two per-capita outcomes:
*   pet_per_eligible (PRIMARY) = pet_total / eligible_1906 * 100
*   pet_per_cap      (fallback)= pet_total / pop_1906      * 100  (1906 pop, §7)
*   pet_natshare     (alt)     = pet_total / 169377        * 100  (canton share of nat)
* eligible_1906 = Vote 65's roll (Lebensmittelgesetz, 10 Jun 1906) -- a same-year (1906)
* federal vote used as the petition's eligibility PROXY (no standalone petition-
* eligibility count exists); national ~784,769.  All §8 columns exist in production ->
* fully gated (§8.5).  See analysis/documentation/methods/petition_arm_construction.md.

**# 8.0 Standalone-run preamble: reload checkpoint if §1-§7 output is absent
*------------------------------------------------------------------------------*
* Sentinel = ln_density_1906 (last var added by §7.2).
{
    cap confirm variable ln_density_1906
    if _rc {
        cap confirm file "$MyProject/results/intermediate/redraft_cohort_1908.dta"
        if _rc {
            di as error "  section 8 needs sections 1-7 output (ln_density_1906); run them first or run end-to-end."
            error 601
        }
        use "$MyProject/results/intermediate/redraft_cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded redraft checkpoint from disk)"
    }
    foreach v in eligible_1906 pet_total pet_valid pet_invalid ///
                 pet_per_eligible pet_per_cap pet_natshare {
        cap drop `v'
    }
}


**# 8.1 Eligibility proxy = Vote 65 roll (swissvotes anr==65 berecht)
*------------------------------------------------------------------------------*
* Separate swissvotes read (§1 is preserved verbatim, filtered to votes 67/68/69).
* Vote 65 = Lebensmittelgesetz, 10 Jun 1906 -> the same-year 1906 eligibility proxy.
{
    preserve
        import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
            delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear
        keep if anr == 65
        assert c(N) == 1
        local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"
        local keepvars "anr"
        foreach ct of local cantons {
            local keepvars "`keepvars' `ct'berecht"
        }
        keep `keepvars'
        foreach ct of local cantons {
            rename `ct'berecht berecht_`ct'
        }
        reshape long berecht_, i(anr) j(canton_iso) string
        replace canton_iso = upper(canton_iso)
        rename berecht_ eligible_1906
        cap confirm numeric variable eligible_1906
        if _rc destring eligible_1906, replace force ignore(",")
        drop anr
        assert c(N) == 25
        recast str8 canton_iso
        isid canton_iso
        tempfile elig65
        save `elig65'
    restore
    merge 1:1 canton_iso using `elig65', assert(match) nogenerate
    label var eligible_1906 "Vote 65 eligible voters (Lebensmittelgesetz, 10 Jun 1906; petition denom)"
    qui sum eligible_1906
    assert inrange(r(sum), 780000, 790000)      // ~784,769
    di as text "  eligible_1906 (Vote 65 roll): national " %9.0fc r(sum)
}


**# 8.2 Petition signatures (AbsinthePetition.xlsx; Total row cross-validated)
*------------------------------------------------------------------------------*
* XLSX: row 1 header (firstrow), rows 2-26 = 25 cantons, row 27 = "Total".  The printed
* Total is cross-validated vs Bundesblatt 1907 p.984 (169,377 / 167,814 / 1,563) BEFORE
* it is dropped -- a stronger provenance check than a self-sum (which matches by build).
{
    preserve
        import excel "$Absinthe1Data/translated/AbsinthePetition.xlsx", ///
            cellrange(A1:E27) firstrow clear
        qui sum TotalSignaturesReceived if Canton == "Total"
        assert inrange(r(sum), 169000, 170000)      // 169,377
        qui sum ValidSignatures if Canton == "Total"
        assert inrange(r(sum), 167000, 168500)      // 167,814
        qui sum InvalidSignatures if Canton == "Total"
        assert inrange(r(sum), 1500, 1700)          // 1,563
        drop if Canton == "Total"
        assert c(N) == 25
        rename RegionCode               canton_iso
        rename TotalSignaturesReceived  pet_total
        rename ValidSignatures          pet_valid
        rename InvalidSignatures        pet_invalid
        cap tostring canton_iso, replace
        replace canton_iso = upper(strtrim(canton_iso))
        drop Canton
        recast str8 canton_iso
        isid canton_iso
        tempfile pet
        save `pet'
    restore
    merge 1:1 canton_iso using `pet', assert(match) nogenerate
    assert pet_valid + pet_invalid == pet_total     // integrity: valid + invalid = total
    label var pet_total   "Petition signatures submitted, canton (AbsinthePetition.xlsx)"
    label var pet_valid   "Petition signatures valid, canton (AbsinthePetition.xlsx)"
    label var pet_invalid "Petition signatures invalid, canton (AbsinthePetition.xlsx)"
    qui sum pet_total
    assert inrange(r(sum), 169000, 170000)
    di as text "  petition signatures: national pet_total " %9.0fc r(sum)
}


**# 8.3 Petition outcomes (two denominators + national share)
*------------------------------------------------------------------------------*
* pet_per_eligible is PRIMARY (denominator = Vote-65 1906 roll, vintage-matched);
* pet_per_cap is the per-capita fallback (denominator = pop_1906); pet_natshare is the
* canton's share of the 169,377 national total (sums to 100 across cantons).
{
    gen double pet_per_eligible = pet_total / eligible_1906 * 100    // PRIMARY
    gen double pet_per_cap      = pet_total / pop_1906      * 100    // fallback (1906 pop)
    gen double pet_natshare     = pet_total / 169377        * 100    // alt (Bundesblatt 1907 p.984)
    assert !missing(pet_per_eligible) & !missing(pet_per_cap) & !missing(pet_natshare)
    qui sum pet_natshare
    assert reldif(r(sum), 100) < 1e-6               // canton shares sum to 100
    label var pet_per_eligible "Petition signatures per 100 eligible voters (PRIMARY Y)"
    label var pet_per_cap      "Petition signatures per 100 pop. (1906 pop; petition is a 1906 event)"
    label var pet_natshare     "Petition canton share of national (%)"
    di as text "  petition outcomes: pet_per_eligible (primary), pet_per_cap, pet_natshare"
}


**# 8.4 Update the redraft checkpoint (+ petition arm)
*------------------------------------------------------------------------------*
{
    save "$MyProject/results/intermediate/redraft_cohort_1908.dta", replace
    di "Updated redraft checkpoint with petition arm -> results intermediate redraft_cohort_1908.dta"
}


**# 8.5 Equivalence gate: petition columns vs frozen production snapshot
*------------------------------------------------------------------------------*
* All 7 petition columns exist in production -> fully gated.  (ln_density_1906 from §7
* is the only petition-adjacent var NOT gated; it's the approved spec change.)
{
    local snap "$MyProject/processed/cohort_1908_workshop_preconsolidation.dta"
    cap confirm file "`snap'"
    if _rc {
        di as text "  8.5 equivalence gate SKIPPED -- no frozen snapshot at `snap'"
    }
    else {
        preserve
            keep canton_iso eligible_1906 pet_total pet_valid pet_invalid ///
                 pet_per_eligible pet_per_cap pet_natshare
            foreach v in eligible_1906 pet_total pet_valid pet_invalid ///
                         pet_per_eligible pet_per_cap pet_natshare {
                rename `v' `v'_rd
            }
            tempfile rd
            save `rd'
            use "`snap'", clear
            keep canton_iso eligible_1906 pet_total pet_valid pet_invalid ///
                 pet_per_eligible pet_per_cap pet_natshare
            recast str8 canton_iso
            merge 1:1 canton_iso using `rd', assert(match) nogenerate
            assert _N == 25
            foreach v in eligible_1906 pet_total pet_valid pet_invalid ///
                         pet_per_eligible pet_per_cap pet_natshare {
                assert reldif(`v', `v'_rd) < 1e-6
            }
            di as text "  8.5 equivalence gate PASSED -- 7 petition cols byte-equal to frozen production snapshot."
        restore
    }
}

* END OF REDRAFT.  §0-§6 primary covariate build + §7-§8 petition arm, all gated except
* ln_density_1906 (approved 1906-vintage SPEC CHANGE vs prod's 1907; self-validated).
* DEFERRED: prior_canton_ban (keep-or-drop judgement call; default drop).