/*==============================================================================
 08_setup_cohort_1908_workshop.do
 Purpose:  Workshop variant of 08 — builds an intermediate workshop cohort
           that includes vote 65 eligibility + petition signature counts on
           top of everything 08 already produces.
 Input:    $Absinthe1Data/swissvotes_dataset.csv  (vote 65 eligibility)
           $Absinthe1Data/translated/AbsinthePetition.xlsx  (petition counts)
           All standard 08 inputs (HSSO files etc.)
 Output:   $MyProject/processed/cohort_1908_workshop.dta  (INTERMEDIATE STATE)
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21

 LINEAGE / DESIGN CHOICE
 -----------------------
 The 2026-05-21 workshop dispatch specifies:
   "Duplicate of 08 + petition/eligibility merges from 12 §1.1-§1.2;
    intermediate state — 09_workshop overwrites with full augmented cohort."

 Two interpretations of "duplicate of 08":
   (A) Full byte-copy of 08's 1453 lines, then insert 12's import logic.
   (B) Source 08 (read-only), then lift 12's import logic (copy-paste).

 Choice: (B) — wrapper.  Rationale:
   - Dispatch says "use the EXACT import logic from 12 §1.1-§1.2; do NOT
     rewrite from scratch.  Just lift those sections into 08_workshop."
     The lift requirement is unambiguous; copy-paste preserves provenance.
   - For the 1453 lines of 08's body, sourcing avoids divergence risk
     (any future 08 fix would propagate automatically to 08_workshop).
   - Dispatch rule "DO NOT modify original 08-13 .do files" is honored;
     sourcing is read-only consumption.
   - Net script length ~150 vs ~1600 lines — much easier to audit.

 If the strategist prefers full duplication, replace the "do 08" line with a
 verbatim paste of 08's contents.

 STATE FLOW
 ----------
 08_workshop produces an INTERMEDIATE cohort_1908_workshop.dta containing:
   - Everything 08 produces in cohort_1908.dta
   - + pet_total, pet_valid, pet_invalid (from AbsinthePetition.xlsx)
   - + eligible_1906 (vote 65 eligibility roll)

 09_workshop then reads this file, applies all §1.x derivations (X-vars,
 covariates, shares, structural zeros, interactions, density swap, petition
 Y outcomes), and OVERWRITES cohort_1908_workshop.dta with the canonical
 full version.  After successful 08→09_workshop run, cohort_1908_workshop.dta
 is in its final state.
==============================================================================*/

version 19


**# 0. Preamble
*------------------------------------------------------------------------------*
{
    * Petition XLSX path (PI-curated translation from PDF; lifted from 12 §0)
    global PETITION_XLSX "$Absinthe1Data/translated/AbsinthePetition.xlsx"
}
/* Manual mode helper
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"
*/


**# 1. Source the canonical 08 to build cohort_1908.dta
*------------------------------------------------------------------------------*
* Read-only consumption.  08 writes its own cohort_1908.dta in
* $MyProject/processed/ as normal.  Below we LOAD that file and add two
* petition/eligibility merges to produce the workshop intermediate.
{
    di as text _newline "  --- 08_workshop §1: sourcing canonical 08 ---"
    do "$MyProject/scripts/08_setup_cohort_1908.do"

    * Sanity: 08 must have produced cohort_1908.dta
    cap confirm file "$MyProject/processed/cohort_1908.dta"
    if _rc {
        di as error "  08 did not produce cohort_1908.dta -- aborting"
        error 601
    }
    di as text "  08 sourced; cohort_1908.dta is on disk."
}


**# 2. Load cohort_1908 as the working file for workshop augmentation
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/cohort_1908.dta", clear
    assert c(N) == 25
    isid canton_iso
    di as text "  Loaded cohort_1908.dta; N=" c(N) ", K=" c(k)
}


**# 3. Merge vote 65 eligibility (LIFTED VERBATIM from 12 §1.1)
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
    assert inrange(r(sum), 780000, 790000)   // expected ~784,769
}


**# 4. Merge petition signatures (LIFTED VERBATIM from 12 §1.2)
*------------------------------------------------------------------------------*
* XLSX layout (per PI screenshot 2026-05-20):
*   Row 1:  header (Canton, Region Code, Total Signatures Received,
*                   Valid Signatures, Invalid Signatures)
*   Rows 2-26: 25 canton rows (Canton name | ISO code | 3 numeric counts)
*   Row 27: "Total" row with national totals (169,377 / 167,814 / 1,563)
*
* Sanity assertion uses the "Total" row to cross-validate against published
* national totals (Bundesblatt 1907 p.984), then drops it before merge.
{
    cap confirm file "$PETITION_XLSX"
    if _rc {
        di as error _newline "  Petition XLSX not found at:"
        di as error "      $PETITION_XLSX"
        error 601
    }

    preserve
        import excel "$PETITION_XLSX", cellrange(A1:E27) firstrow clear

        * Cross-validate the "Total" row vs. published national totals BEFORE
        * dropping it -- this gives a stronger provenance check than just
        * summing the 25 canton rows (which would always match by construction).
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

    di as text "  Petition national total submitted: " %9.0fc `nat_total' "  (expected 169,377)"
    di as text "  Petition national total valid:     " %9.0fc `nat_valid' "  (expected 167,814)"
    di as text "  Petition national total invalid:   " %9.0fc `nat_invalid' "  (expected 1,563)"

    qui sum pet_total
    assert inrange(r(sum), 169000, 170000)
    di as text "  25-canton sum (pet_total): " %9.0fc r(sum) "  (should match Total row)"
}


**# 5. Save workshop intermediate cohort
*------------------------------------------------------------------------------*
* This is the INTERMEDIATE state.  09_workshop will load this, add all §1.x
* derivations, and OVERWRITE the file with the canonical full version.
{
    assert c(N) == 25
    isid canton_iso

    compress
    save "$MyProject/processed/cohort_1908_workshop.dta", replace

    di as text _newline "{hline 79}"
    di as text "  08_workshop COMPLETE"
    di as text "{hline 79}"
    di as text "  Saved: $MyProject/processed/cohort_1908_workshop.dta"
    di as text "         (intermediate; 09_workshop will overwrite with full version)"
    di as text "  Observations: " c(N)
    di as text "  Variables:    " c(k)
    di as text "{hline 79}"
}


**# 6. Post-credits
*------------------------------------------------------------------------------*
{
    cap which _codebook_update
    if !_rc {
        _codebook_update using "$MyProject/processed/cohort_1908_workshop.dta", ///
            script("08_setup_cohort_1908_workshop.do")
    }

    if "${RUN_POSTCREDITS}" == "1" {
        cap which _inventory_append
        if !_rc {
            _inventory_append, sheet("datasets") ///
                row("created|processed/cohort_1908_workshop.dta|`=c(N)'|`=c(k)'|.|08_setup_cohort_1908_workshop.do")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
