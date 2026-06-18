/*==============================================================================
 12_canton_petition.do
 Purpose:  Run the same primary regression cascade as 09_canton_reg1.do §2.1
           but with a different Y: petition_share, the per-eligible-voter
           share of pre-vote-68 petition signatures.

           Sister to 09_canton_reg1.do.  Sources 09 in setup-only mode to
           inherit the §1.0-§1.5 setup (cohort load + renames + derived
           X1-X4 + cov* + spec globals + robustness vars), then adds the
           petition-specific data and runs cascades with Y=pet_per_eligible.

 Rationale (per data note in codebook.md / asymmetric-outcome design):
   - vote (yes_pct, Y1) = support - opposition revealed at the ballot box
   - petition (pet_per_eligible) = support-only revealed during collection
   Comparing beta_wine on both outcomes diagnoses whether wine-producer
   cantons mobilized on both margins (Peltzman confirmed), one margin only
   (asymmetric signal), or neither (no rent-seeking mechanism).

 Inputs:   $MyProject/processed/cohort_1908.dta                    (via 09)
           $Absinthe1Data/swissvotes_dataset.csv                   (vote 65 eligibility)
           $Absinthe1Data/translated/AbsinthePetition.xlsx         (petition counts)

 Output:   $MyProject/results/intermediate/estimates_petition/ols_pet_{k}_{j}.ster
                                                                   (20 OLS specs)

 Y outcomes (in order of preference, per data note):
   pet_per_eligible = pet_total / eligible_1906 * 100   [primary; pct scale]
   pet_per_cap      = pet_total / pop_1900     * 100    [robustness; pct scale]
   pet_natshare     = pet_total / 169377                [national-share alt; fraction]

 Author:   Nicholas A Jensen
 Date:     2026-05-20
 Version:  0.1
==============================================================================*/

/* Pre-run reminder
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do" %for setup
*/

version 19

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
    * Petition XLSX path (PI-curated translation from PDF; 2026-05-20)
    global PETITION_XLSX "$Absinthe1Data/translated/AbsinthePetition.xlsx"

    * Petition national total (Bundesblatt 1907 p.984 / swissvotes vote 68 cert)
    * Used for pet_natshare scaling and sanity-check assertions.
    global PET_NAT_TOTAL = 169377
}


**# 1. Setup: source 09 (skip regressions) + load petition + eligibility
*------------------------------------------------------------------------------*

**# 1.0 Source 09 in setup-only mode
*------------------------------------------------------------------------------*
* Sets $SKIP_09_REGRESSIONS=1 so 09 exits before §2; the §1.0-§1.5 setup
* completes, populating X1-X4, cov*, $X_spec*, $ctrl_*, wine_vol_log, etc.
* in memory.  After 09 returns, we have cohort_1908.dta loaded + all 09's
* derivations applied + spec globals defined.
{
    global SKIP_09_REGRESSIONS = 1
    do "$MyProject/scripts/09_canton_reg1.do"
    global SKIP_09_REGRESSIONS = ""

    * Sanity: 09's §1 setup must have completed
    cap confirm variable X1
    if _rc {
        di as error "  ERROR: 09 did not complete its §1 setup -- X1 absent."
        di as error "  Diagnostic: did 09 exit early before §1.5?"
        error 459
    }
    if "${X_spec1}" == "" {
        di as error "  ERROR: 09 did not set up spec globals -- \$X_spec1 unset."
        error 459
    }
    di as text _newline "  09 setup sourced; X1-X4, cov*, \$X_spec*, \$ctrl_* are ready."
}


**# 1.1 Load vote 65 eligibility from swissvotes raw
*------------------------------------------------------------------------------*
* Vote 65 (Lebensmittelgesetz, 10 June 1906) sits inside the petition
* collection window (Dec 1905 - 1907), making its eligibility roll the closest
* swissvotes snapshot to mid-collection (~1-2 pct/yr drift from
* aging+naturalizations).  See codebook data note for rationale and
* alternatives (1905 Nationalratswahl, vote 68, pop_1900).
*
* Mirrors 08 §1.1-§1.3 import pattern (semicolon, case(lower), reshape long
* on per-canton-prefix columns) but filtered to anr==65 and keeping only
* the berecht (eligibility) metric.
{
    preserve
        import delimited using "$Absinthe1Data/swissvotes_dataset.csv", ///
            delimiter(";") encoding("utf-8") case(lower) bindquote(strict) clear
        keep if anr == 65
        assert c(N) == 1

        * 25 cantons in 1906 (JU not separate until 1979)
        local cantons "zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge"

        local keepvars "anr"
        foreach ct of local cantons {
            local keepvars "`keepvars' `ct'berecht"
        }
        keep `keepvars'

        * Rename so canton code is the SUFFIX (required by reshape long stub form)
        foreach ct of local cantons {
            rename `ct'berecht berecht_`ct'
        }

        reshape long berecht_, i(anr) j(canton_iso) string
        replace canton_iso = upper(canton_iso)
        rename berecht_ eligible_1906

        * Coerce string-imported numeric
        cap confirm numeric variable eligible_1906
        if _rc destring eligible_1906, replace force ignore(",")

        drop anr
        assert c(N) == 25
        isid canton_iso

        tempfile elig65
        save `elig65'
    restore

    cap drop eligible_1906
    merge 1:1 canton_iso using `elig65', assert(match) nogenerate
    label var eligible_1906 "Vote 65 eligible voters (Lebensmittelgesetz, 10 Jun 1906; petition denom)"

    qui sum eligible_1906
    di as text "  Vote 65 national eligible total: " %9.0fc r(sum) " (across 25 cantons)"
}


**# 1.2 Load petition signatures from PI-translated XLSX (skip-gracefully if missing)
*------------------------------------------------------------------------------*
* XLSX layout (per PI screenshot 2026-05-20):
*   Row 1:  header (Canton, Region Code, Total Signatures Received,
*                   Valid Signatures, Invalid Signatures)
*   Rows 2-26: 25 canton rows (Canton name | ISO code | 3 numeric counts)
*   Row 27: "Total" row with national totals (169,377 / 167,814 / 1,563)
*
* With firstrow, Stata-friendly var names: Canton, RegionCode,
*   TotalSignaturesReceived, ValidSignatures, InvalidSignatures.
*
* Sanity assertion uses the "Total" row to cross-validate against published
* national totals (Bundesblatt 1907 p.984), then drops it before merge.
{
    cap confirm file "$PETITION_XLSX"
    if _rc {
        di as error _newline "  §1.2 SKIPPED: petition XLSX not found at:"
        di as error "      $PETITION_XLSX"
        di as error "    Per PI data note, expected to be present.  Once XLSX lands,"
        di as error "    re-run 12 to populate petition Y outcomes + regressions."
        global PETITION_DATA_AVAILABLE = 0
    }
    else {
        preserve
            import excel "$PETITION_XLSX", cellrange(A1:E27) firstrow clear
            * Stata-imported var names (from firstrow): Canton, RegionCode,
            *   TotalSignaturesReceived, ValidSignatures, InvalidSignatures.
            *
            * Cross-validate the "Total" row vs. published national totals BEFORE
            * dropping it -- this gives us a stronger provenance check than just
            * summing the 25 canton rows (would always match by construction).
            qui sum TotalSignaturesReceived if Canton == "Total"
            assert inrange(r(sum), 169000, 170000)   // expected 169,377
            local nat_total = r(sum)

            qui sum ValidSignatures if Canton == "Total"
            assert inrange(r(sum), 167000, 168500)   // expected 167,814
            local nat_valid = r(sum)

            qui sum InvalidSignatures if Canton == "Total"
            assert inrange(r(sum), 1500, 1700)       // expected 1,563
            local nat_invalid = r(sum)

            * Drop the Total row, keep the 25 canton rows for merge
            drop if Canton == "Total"
            assert c(N) == 25

            * Rename for merge / project conventions
            rename RegionCode               canton_iso
            rename TotalSignaturesReceived  pet_total
            rename ValidSignatures          pet_valid
            rename InvalidSignatures        pet_invalid

            * Defensive: ensure canton_iso is upper-case string, drop Canton name
            cap tostring canton_iso, replace
            replace canton_iso = upper(strtrim(canton_iso))
            drop Canton

            isid canton_iso
            tempfile pet
            save `pet'
        restore

        cap drop pet_total pet_valid pet_invalid
        merge 1:1 canton_iso using `pet', assert(match) nogenerate

        label var pet_total   "Petition signatures submitted, canton (AbsinthePetition.xlsx)"
        label var pet_valid   "Petition signatures valid, canton (AbsinthePetition.xlsx)"
        label var pet_invalid "Petition signatures invalid, canton (AbsinthePetition.xlsx)"

        * Echo national totals from the dropped Total row
        di as text "  Petition national total submitted: " %9.0fc `nat_total' "  (expected 169,377)"
        di as text "  Petition national total valid:     " %9.0fc `nat_valid' "  (expected 167,814)"
        di as text "  Petition national total invalid:   " %9.0fc `nat_invalid' "  (expected 1,563)"

        * Cross-check: 25-canton sum should also match the published totals
        qui sum pet_total
        assert inrange(r(sum), 169000, 170000)
        di as text "  25-canton sum (pet_total): " %9.0fc r(sum) "  (should match Total row)"

        global PETITION_DATA_AVAILABLE = 1
    }
}


**# 1.3 Derive petition Y outcomes
*------------------------------------------------------------------------------*
* Three Y vars constructed per data note:
*   pet_per_eligible (PRIMARY) -- pct scale (0-100), matches Y1's scale
*   pet_per_cap      (FALLBACK) -- pct scale, denominator is pop_1900
*   pet_natshare     (ALT SCALE) -- fraction (0-1), denominator is national total
{
    if "${PETITION_DATA_AVAILABLE}" != "1" {
        di as text "  §1.3 SKIPPED: no petition data (see §1.2 skip message)"
    }
    else {
        * Primary Y: per 100 eligible voters at vote 65 (mid-collection-window)
        cap drop pet_per_eligible
        gen double pet_per_eligible = pet_total / eligible_1906 * 100
        label var pet_per_eligible "Petition signatures per 100 eligible voters at vote 65 (PRIMARY Y; pct)"

        * Robustness fallback: per 100 of 1900 population
        cap drop pet_per_cap
        gen double pet_per_cap = pet_total / pop_1900 * 100
        label var pet_per_cap "Petition signatures per 100 pop. 1900 (robustness denom; pct)"

        * National-share alternative scaling (percent; sums to 100 across cantons)
        cap drop pet_natshare
        gen double pet_natshare = pet_total / $PET_NAT_TOTAL * 100
        label var pet_natshare "Petition signatures as percent of national total (%, sums to ~100)"

        di as text _newline "  Petition Y outcomes derived:"
        qui sum pet_per_eligible
        di as text "    pet_per_eligible (PRIMARY): mean=" %5.2f r(mean) ", range [" %5.2f r(min) ", " %5.2f r(max) "]"
        qui sum pet_per_cap
        di as text "    pet_per_cap (fallback):     mean=" %5.2f r(mean) ", range [" %5.2f r(min) ", " %5.2f r(max) "]"
        qui sum pet_natshare
        di as text "    pet_natshare (alt scale):   sum =" %7.4f r(sum) " (should = 100.0000 if all 25 cantons covered)"
    }
}


**# 2. Primary regression battery on Y=pet_per_eligible
*------------------------------------------------------------------------------*
* Same RHS as 09 §2.1's primary OLS battery -- 4 wine variants x 5 cascade cols.
* HC3 SEs throughout.  Only Y differs (pet_per_eligible instead of Y1).

**# 2.0 Standalone-run preamble: confirm setup ready for regressions
*------------------------------------------------------------------------------*
{
    if "${PETITION_DATA_AVAILABLE}" != "1" {
        di as error _newline "  §2 SKIPPED: petition data not loaded; cannot run Y=petition regressions."
        di as error "  Resolve §1.2 first (place petition CSV at \$PETITION_CSV)."
        exit
    }
    cap confirm variable pet_per_eligible
    if _rc {
        di as error "  §2 needs pet_per_eligible (built in §1.3) but it's absent."
        error 459
    }
    if "${X_spec1}" == "" {
        di as error "  §2 needs 09's spec globals (\$X_spec1, etc.) but they are unset."
        error 459
    }
}


**# 2.1 Run 20 specs and save each to .ster
*------------------------------------------------------------------------------*
{
    cap mkdir "$MyProject/results/intermediate/estimates_petition"

    di as text _newline "  --- Petition battery: 20 OLS specs (Y = pet_per_eligible) ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            * Per-cap (k=1) uses ctrl_1_*; share forms (k=2,3,4) use ctrl_s_*
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            cap estimates drop ols_pet_`k'_`j'
            qui regress pet_per_eligible ${X_spec`k'} `ctrl', vce(hc3)
            estimates store ols_pet_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_petition/ols_pet_`k'_`j'.ster", replace

            di as text "  Spec pet`k'.`j': N=" e(N) ", R^2=" %5.3f e(r2) ///
                       ", beta(${X_spec`k'})=" %8.4f _b[${X_spec`k'}]
        }
    }
    di as text _newline "  Petition battery complete: 20 OLS specs saved to estimates_petition/"
}


**# 3. Post-credits: codebook + inventory (inventory only on release runs)
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        di as text "  (inventory append: post-credits structure ready for release runs)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
