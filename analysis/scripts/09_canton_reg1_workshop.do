/*==============================================================================
 09_canton_reg1_workshop.do
 Purpose:  Workshop variant of 09.  Reads cohort_1908_workshop.dta
           (intermediate from 08_workshop), applies all derivations + the
           density-swap col 5 modification, runs the 20-spec primary battery
           + fraclogit parallel + R1-R6 + R4b (X3) + crossref 67/68/69, and
           OVERWRITES cohort_1908_workshop.dta with the canonical full cohort.
 Input:    $MyProject/processed/cohort_1908_workshop.dta  (from 08_workshop)
 Output:   $MyProject/processed/cohort_1908_workshop.dta  (OVERWRITTEN; full)
           $MyProject/results/intermediate/estimates_workshop/ols_k_j.ster (20)
           $MyProject/results/intermediate/estimates_fraclogit_workshop/
                fl_k_j.ster + fl_me_k_j.ster (40)
           $MyProject/results/intermediate/estimates_robust_workshop/
                r1_nfirms.ster, ..., r4_fr_x_prod.ster, r4b_fr_x_prod_x3.ster,
                r5_drop_ne.ster, r6_loglog.ster (7)
           $MyProject/results/intermediate/estimates_crossref/
                crossref_ols_{67,68,69}.ster + crossref_fl_*.ster (9)
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21

 KEY DEVIATIONS FROM 09 (all per 2026-05-21 workshop dispatch)
 -------------------------------------------------------------
 §1.0    : Reads cohort_1908_workshop.dta (not cohort_1908.dta)
 §1.2.2  : Adds ln_density = ln_pop_1900 - cov_land derivation (KEEPS
           cov_land + ln_pop_1900 too — workshop cohort is exhaustive)
 §1.4    : WORKSHOP col 5 globals — both ctrl_s_c5 and ctrl_1_c5 replace
           "cov_land + ln_pop_1900" with single "ln_density" composite.
           Rationale: at N=25, β_pop ≈ −β_area in original col 5 suggests
           density is doing the work and the size/density separation is
           not identified; ln_density is a parsimonious composite.
 §1.6    : NEW.  Petition Y outcomes (pet_per_eligible, pet_per_cap,
           pet_natshare) lifted from 12 §1.3, so the workshop cohort is
           self-sufficient for petition regressions in 12_workshop.
 §1.7    : NEW.  OVERWRITES cohort_1908_workshop.dta with the canonical
           augmented version (every raw var from 08, plus every derivation
           added in §1.x of 09_workshop).  This is the workshop source of
           truth — 12_workshop / 14_workshop / 15_workshop / 16_workshop /
           18_workshop all read this file.
 §2.1    : Routes to estimates_workshop/ (NOT estimates/).
           Judgment call: avoids overwriting non-workshop estimates, which
           would otherwise contaminate the non-workshop 10_canton_reg1_tables
           output.  Dispatch's "existing infrastructure" table suggested
           reusing estimates/, but the density-swap makes that incompatible.
 §2.5    : Routes to estimates_fraclogit_workshop/.  Same rationale.
 §2.6    : ln_density replaces (cov_land + ln_pop_1900) in R1-R6 control
           sets (consistency with workshop col 5).  Routes to
           estimates_robust_workshop/.  ADD R4b: same as R4 but with
           X3_share instead of X2_share, for Table 5 Panel B.
 §2.7    : Replaces the alt-referenda SKIP block with the crossref
           battery (67/68/69) — OLS + fracreg + AME — for Table 8.
           Generates pct_yes_68 alias from Y1 inside the loop because
           §1.2.1 renamed it.
 §2.8    : REMOVED.  12_workshop is the canonical petition battery.
==============================================================================*/

version 19


**# 0. Preamble
*------------------------------------------------------------------------------*
{
    * No script-specific setup needed beyond what 08_workshop already provided
    * (PETITION_XLSX global, cohort_1908_workshop.dta on disk).
    *
    * HC3 SEs throughout for OLS (project methodology rule, N=25 small-sample
    * bias correction).  fracreg uses vce(robust) (sandwich).
}
/* Manual mode helper
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"
*/


**# 1. Load workshop cohort + prepare all derived analysis variables
*------------------------------------------------------------------------------*

**# 1.0 Standalone-run preamble: ALWAYS load cohort_1908_workshop.dta from disk
*------------------------------------------------------------------------------*
* Originally used a sentinel-check (`cap confirm variable pet_total`) to skip
* the reload when memory already had the cohort.  But this fails if the in-
* memory state is the STRIPPED cohort (from 18_strip's tail) — pet_total is
* in the KEEP_LIST and survives the strip, so the sentinel says "loaded" but
* the raw vars 09 needs (wine_area_canton_ha, etc.) have been dropped.
*
* Simpler & more robust: always reload from disk.  The cost is one `use`
* operation (~ms on a 25-row cohort); the benefit is freedom from this
* class of state-pollution bug.
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  §1 needs cohort_1908_workshop.dta (built by 08_workshop)"
        di as error "  but the file does not exist.  Run 08_workshop first."
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear
    di as text "  (loaded cohort_1908_workshop.dta from disk; N=" c(N) ", K=" c(k) ")"
}


**# 1.1 Construct any derived variables needed for the regressions
*------------------------------------------------------------------------------*
{
    * (placeholder; all derivations in §1.2-§1.6 below)
}


**# 1.2 ADD THE VARIABLE GLOBAL MACROS
{
    * 1.2.1 NAMING CONVENTIONS -- X-VARIABLES and Y1
    capture rename wine_area_canton_ha wine_ha        // shorter name
    capture rename pct_yes_68 Y1                       // Absinthe Ban Vote
    label var Y1 "Yes-vote share, vote #68 (pct, 0-100) [pct_yes_68]"
    capture drop X1
    gen X1 = wine_ha / pop_1907 * 1000  // Wine area per 1,000 pop (1907 pop; ha per 1k)
    label var X1 "Wine area per 1,000 pop., canton (ha per 1k people; wine 1907, pop 1907)"
    capture rename wine_volume_canton_hl X2_num        // Wine Regressor 2 -- Qty
    label var X2_num  "Wine volume, canton (hl, 1907) [wine_volume_canton_hl]"
    capture rename wine_revenue_canton_fr X3_num       // Wine Regressor 3 -- Revenue
    label var X3_num  "Wine revenue, canton (Fr, 1907) [wine_revenue_canton_fr]"
    capture rename wine_yield_canton_hl_per_ha X4      // Wine Regressor 4 -- Wine yield per hectare
    label var X4  "Wine yield, canton (hl/ha, 1907) [wine_yield_canton_hl_per_ha]"
}
{   // import and save 3 national values (Switzerland row 22) for bounded X*_share vars
    preserve
        import excel ///
            "C:/Users/jensenn/Dropbox/research_data_raw/c-metrics-absinthe1/original/Statistical Yearbooks of Switzerland/Canton1907_wine-data.xlsx", ///
            sheet("Sheet1") cellrange(C22:E22) clear allstring
        rename (*) (v_area v_volume v_value)
        local nat_area   = real(v_area[1])     // C22 = Cultivated area (ha)
        local nat_volume = real(v_volume[1])   // D22 = Total yield (hl)
        local nat_value  = real(v_value[1])    // E22 = Total value (Fr)
    restore

    global NAT_WINE_AREA   = `nat_area'
    global NAT_WINE_VOLUME = `nat_volume'
    global NAT_WINE_VALUE  = `nat_value'
    di "  national wine area    = $NAT_WINE_AREA   ha"
    di "  national wine volume  = $NAT_WINE_VOLUME hl"
    di "  national wine value   = $NAT_WINE_VALUE  Fr"
}
    * Fallback reload if preserve/restore went sideways
    cap confirm variable ln_canton_area_km2
    if _rc {
        use "$MyProject/processed/cohort_1908_workshop.dta", clear
        di as text "  (fallback: reloaded cohort_1908_workshop.dta from disk)"
    }

    cap drop X1_share X2_share X3_share
    gen X1_share = wine_ha / $NAT_WINE_AREA   * 100
    gen X2_share = X2_num  / $NAT_WINE_VOLUME * 100
    gen X3_share = X3_num  / $NAT_WINE_VALUE  * 100

    label var X1_share "Wine area, national share (%)"
    label var X2_share "Wine volume, national share (%)"
    label var X3_share "Wine revenue, national share (%)"

    foreach v in X1_share X2_share X3_share {
        qui sum `v'
        di "  sum(`v') = " %7.4f r(sum) cond(abs(r(sum)-100)<0.01, "  (OK)", "  (CHECK drift)")
    }

    * Workshop labels (per dispatch table) — apply to existing X1/X4 too
    label var X1 "Wine area per 1,000 pop. (ha)"
    label var X4 "Wine yield (hl/ha)"


    * --------------------------------------------------------------------------
    * 1.2.3 WHITE / RED WINE DECOMPOSITION (Cahannes 1981 substitution test)
    * --------------------------------------------------------------------------
    * Cahannes (1981) attests: "absinthe, particularly popular in the French part
    * of the country, competed with white wine, and the initiative was therefore
    * supported by the winegrowers."  Direct test: split X3_share into white and
    * red components.  Prediction: β(X3_white_share) on Y1 > β(X3_share) > β(X3_red_share).
    *
    * Source: Canton1907_wine-data.xlsx (same as X3_num).
    * National totals (Switzerland row 22):
    *   White wine value (Fr):  21,854,806  (73.4% of national wine value)
    *   Red wine value (Fr):     6,796,247  (22.8%)
    *   Mixed wine value (Fr):   1,131,880  ( 3.8%)
    *
    * The XLSX has 20 canton-rows + 1 Switzerland row (no entries for the 5 alpine
    * non-wine cantons UR/OW/NW/ZG/AI).  Structural-zero enforcement in §1.3 sets
    * these to 0, matching the X3_num convention.
    preserve
        import excel ///
            "$Absinthe1Data/original/Statistical Yearbooks of Switzerland/Canton1907_wine-data.xlsx", ///
            sheet("Sheet1") firstrow clear

        * Destring text-imported numeric columns (commas in source)
        * Phase 10b: also pull volume columns for the volume-share re-test
        foreach v in RedwinevalueFr WhitewinevalueFr Redwineyieldhl Whitewineyieldhl {
            cap destring `v', replace ignore(",")
        }

        * Drop Switzerland total row + non-canton rows; keep 20 canton rows
        keep if !missing(Code) & Code != "CH"
        assert c(N) == 20

        rename Code               canton_iso
        rename RedwinevalueFr     X3_red_num
        rename WhitewinevalueFr   X3_white_num
        rename Redwineyieldhl     wine_volume_red
        rename Whitewineyieldhl   wine_volume_white
        keep canton_iso X3_red_num X3_white_num wine_volume_red wine_volume_white
        isid canton_iso

        tempfile winetype
        save `winetype'
    restore

    * Merge into cohort.  20 canton-rows from XLSX merge into 25-canton master;
    * the 5 alpine non-wine cantons are unmatched and stay missing until the
    * structural-zero replacement below sets them to 0.
    cap drop X3_red_num X3_white_num wine_volume_red wine_volume_white
    merge 1:1 canton_iso using `winetype'
    assert _merge != 2   // no using-only rows
    drop _merge

    * Structural-zero convention for wine-type cells.  Three classes of missing:
    *   (a) 5 alpine non-wine cantons (UR/OW/NW/ZG/AI) — no wine of any type
    *   (b) Wine cantons that produced only ONE color — e.g., TI is 100% red so
    *       White is missing in source; some all-white cantons have Red missing.
    *   (c) Mixed-only wine (not modelled here) cells.
    * All three get coded as 0 (= "canton produced no wine of this color")
    * matching the omit-non-producers convention used for aggregate X3_num.
    * This is critical for regression coverage: missing → drop → N < 25.
    foreach v in X3_red_num X3_white_num wine_volume_red wine_volume_white {
        replace `v' = 0 if missing(`v')
    }

    label var X3_red_num         "Wine revenue, canton — RED (Fr, 1907) [Cahannes substitution test]"
    label var X3_white_num       "Wine revenue, canton — WHITE (Fr, 1907) [Cahannes substitution test]"
    label var wine_volume_red    "Wine volume, canton — RED (hL, 1907) [Phase 10b vol-share test]"
    label var wine_volume_white  "Wine volume, canton — WHITE (hL, 1907) [Phase 10b vol-share test]"

    * National denominators (Switzerland row totals, verified above)
    global NAT_WHITE_VALUE = 21854806
    global NAT_RED_VALUE   =  6796247

    * Canton shares of national white / red wine value (percent scale)
    cap drop X3_white_share X3_red_share
    gen double X3_white_share = X3_white_num / $NAT_WHITE_VALUE * 100
    gen double X3_red_share   = X3_red_num   / $NAT_RED_VALUE   * 100

    label var X3_white_share "Wine revenue, white, national share (%) [Cahannes substitute]"
    label var X3_red_share   "Wine revenue, red, national share (%) [no substitution channel]"

    di as text _newline "  Wine-type decomposition merged:"
    qui count if !missing(X3_white_num)
    di as text "    Cantons with X3_white_num present: " r(N) " (expected 20; 5 alpine non-wine → 0 via §1.3)"

    * 1.2.2 COVARIATE NAMING + percent rescaling + DENSITY DERIVATION
    cap drop cov1
    gen double cov1 = french_share * 100
    label var cov1 "French language share (%, 1900 census — nearest available)"

    capture rename share_of_total_domestic dom_share_abs
    capture rename share_of_total_exports exp_share_abs
    capture rename share_of_total_purchases dom_share_total

    cap drop cov2_dom cov2_exp cov2_total_share
    gen double cov2_dom         = dom_share_abs   * 100
    gen double cov2_exp         = exp_share_abs   * 100
    gen double cov2_total_share = dom_share_total * 100
    label var cov2_dom         "Absinthe domestic, national share (%)"
    label var cov2_exp         "Absinthe exports, national share (%)"
    label var cov2_total_share "Absinthe trade share (%)"

    cap drop cov3
    gen double cov3 = protestant_share * 100
    label var cov3 "Protestant share (%, 1900 census — nearest available)"

    capture rename ln_canton_area_km2 cov_land
    label var cov_land "Log canton area (km^2)"
    capture drop ln_pop_1900
    gen double ln_pop_1900 = ln(pop_1900)
    label var ln_pop_1900 "Log canton population (1900 census; retained, NOT the scale control)"

    * 1907 population-correctness fix (2026-06-17): the scale/density control is the
    * ACTUAL 1907 yearbook population, not the 1900 census.  cov_land (= ln canton
    * land area) is the FIXED survey constant (backed out of 1900 pop/density in 08
    * §8.2, unchanged).  pop_1907 / pop_density_1907 / ln_pop_1907 are built in 08 §8.2.
    capture drop ln_pop_1907
    gen double ln_pop_1907 = ln(pop_1907)
    label var ln_pop_1907 "Log canton population (1907 yearbook estimate; scale control)"

    * ln_density = ln(pop_1907 / land area) = ln(pop_1907) - cov_land = ln(pop_density_1907)
    * Replaces (cov_land + ln_pop_1900) in cascade col 5 as a single composite
    * geographic-scale regressor.  See §1.4 below for the spec-global change.
    cap drop ln_density
    gen double ln_density = ln_pop_1907 - cov_land
    label var ln_density "Log population density (1907 pop / fixed 1900 land area)"

    * Arithmetic-identity assertion (1907 pop / fixed land area)
    cap drop _ln_density_check
    gen double _ln_density_check = ln(pop_1907 / canton_area_km2)
    assert abs(ln_density - _ln_density_check) < 1e-10
    drop _ln_density_check
    di as text "  ln_density derived on 1907 pop; identity check passed (|ln_density - ln(pop_1907/area)| < 1e-10)"


**# 1.3 Structural-zeros enforcement and missing-data convention
*------------------------------------------------------------------------------*
* Identical to 09 §1.3 — wine: 5 alpine cantons → 0 (yield → missing);
* absinthe: 17 non-producer cantons → 0 across all share vars.

* Wine: 5 non-producer cantons (UR, OW, NW, ZG, AI)
{
    local wine_zero_cantons "UR OW NW ZG AI"

    foreach v in wine_ha X1 X2_num X3_num X1_share X2_share X3_share ///
                 X3_white_num X3_red_num X3_white_share X3_red_share ///
                 wine_volume_white wine_volume_red {
        capture confirm variable `v'
        if !_rc {
            replace `v' = 0 if inlist(canton_iso, "UR", "OW", "NW", "ZG", "AI")
        }
    }

    capture confirm variable X4
    if !_rc {
        replace X4 = . if inlist(canton_iso, "UR", "OW", "NW", "ZG", "AI")
    }

    di "  Wine zero-canton enforcement: 5 cantons (UR/OW/NW/ZG/AI) set to 0"
    di "    (includes white + red wine vars; X4 yield set to missing)"
}

* Absinthe: 17 non-producer cantons -- !inlist with 8 producers (avoids 10-arg cap)
{
    foreach v in cov2_dom cov2_exp cov2_total_share dom_share_abs exp_share_abs dom_share_total {
        capture confirm variable `v'
        if !_rc {
            replace `v' = 0 if !inlist(canton_iso, "NE","GE","BS","VD","SZ","ZG","FR","VS")
        }
    }

    di "  Absinthe zero-canton enforcement: 17 non-producer cantons set to 0 across all share vars"
}

* Sanity check: producer-canton counts
{
    qui count if X1_share > 0 & !missing(X1_share)
    assert r(N) == 20  // 20 wine-producing cantons
    di "  Confirmed: 20 wine-producer cantons (5 zeros at UR/OW/NW/ZG/AI)"

    qui count if cov2_total_share > 0 & !missing(cov2_total_share)
    assert r(N) == 8   // 8 absinthe-producing cantons
    di "  Confirmed: 8 absinthe-producer cantons (17 zeros)"

    * Wine-type share sums should be ~100 (each is canton share of national)
    foreach v in X3_white_share X3_red_share {
        qui sum `v'
        di "  sum(`v') = " %7.4f r(sum) cond(abs(r(sum)-100)<0.01, "  (OK)", "  (CHECK drift)")
    }
}


**# 1.4 Define regression spec globals (4 wine variants x 5 cascade cols)
*------------------------------------------------------------------------------*
* WORKSHOP VARIANT: col 5 uses single ln_density composite instead of
* (cov_land + ln_pop_1900).  Both per-cap (k=1) and share (k=2,3,4) families
* share the same col-5 controls in the workshop variant; the original 09 had
* them diverge (ln_pop_1900 only for shares) but the density composite is
* construction-agnostic so both can use it.
*
* Wine variants ($X_spec*):
*   k=1 -> X1        (wine area per 1,000 pop, ha)
*   k=2 -> X2_share  (wine volume share of national, 1907; %)
*   k=3 -> X3_share  (wine revenue share of national, 1907; %)
*   k=4 -> X1_share  (wine area share of national, 1907; %)
*
* Cascade columns (M1A-style, baseline -> full):
*   c1: treatment only
*   c2: + cov1 (French language share)
*   c3: + cov2_total_share (Milliet absinthe purchases share)
*   c4: + cov3 (Protestant share)
*   c5: + ln_density [WORKSHOP CHANGE: was cov_land + ln_pop_1900 in 09]
{
    global X_spec1 "X1"
    global X_spec2 "X2_share"
    global X_spec3 "X3_share"
    global X_spec4 "X1_share"

    global ctrl_1_c1 ""
    global ctrl_1_c2 "cov1"
    global ctrl_1_c3 "cov1 cov2_total_share"
    global ctrl_1_c4 "cov1 cov2_total_share cov3"
    global ctrl_1_c5 "cov1 cov2_total_share cov3 ln_density"

    global ctrl_s_c1 ""
    global ctrl_s_c2 "cov1"
    global ctrl_s_c3 "cov1 cov2_total_share"
    global ctrl_s_c4 "cov1 cov2_total_share cov3"
    global ctrl_s_c5 "cov1 cov2_total_share cov3 ln_density"

    di "  Workshop spec globals defined: 4 wine variants x 5 cascade cols (col 5 uses ln_density)"
}


**# 1.5 Robustness-layer derived variables and interactions
*------------------------------------------------------------------------------*
* Identical to 09 §1.5.  These derived vars feed §2.6 (R1-R6 + R4b) and
* potentially the workshop Tables 5 / 7.
{
    cap drop wine_vol_log
    gen double wine_vol_log = ln(1 + X2_num)
    label var wine_vol_log "Log wine volume"

    cap drop abs_log
    gen double abs_log = ln(1 + purchases_kg95_canton)
    label var abs_log "Log absinthe purchases"

    cap drop abs_nfirms
    gen byte abs_nfirms = n_firms_purchases
    replace abs_nfirms = 0 if missing(abs_nfirms)
    label var abs_nfirms "N absinthe firms"

    cap drop abs_producer
    gen byte abs_producer = (cov2_total_share > 0 & !missing(cov2_total_share))
    label var abs_producer "Absinthe-trade-interest canton (Milliet any-purchase; headline)"

    cap drop fr_x_producer
    gen double fr_x_producer = cov1 * abs_producer
    label var fr_x_producer "French x Absinthe-producer"

    * --- Phase 10 mechanism-interaction vars (constructed here so they
    *     persist in §1.7 cohort save and survive the 18_strip KEEP_LIST) ---
    cap drop X3_white_x_cov1
    gen double X3_white_x_cov1 = X3_white_share * cov1
    label var X3_white_x_cov1 "White wine national share x French language share"

    cap drop X3_white_x_absprod
    gen double X3_white_x_absprod = X3_white_share * abs_producer
    label var X3_white_x_absprod "White wine national share x Absinthe-producer indicator"

    cap drop X3_white_x_cov2
    gen double X3_white_x_cov2 = X3_white_share * cov2_total_share
    label var X3_white_x_cov2 "White wine national share x Absinthe trade share"

    global X_wine_log    wine_vol_log
    global X_abs_log     abs_log
    global X_abs_nfirms  abs_nfirms
    global X_abs_prod    abs_producer
    global X_fr_x_prod   fr_x_producer

    di as text "  §1.5 derived variables ready:"
    di as text "    wine_vol_log, abs_log, abs_nfirms, abs_producer, fr_x_producer"
    di as text "    + Phase 10: X3_white_x_cov1, X3_white_x_absprod, X3_white_x_cov2"
}


**# 1.5b Phase 10b: Volume-share variants (Cahannes substitution channel re-test)
*------------------------------------------------------------------------------*
* Per Phase 10b dispatch + PI correction (2026-05-21):
*
* Re-test D1/D2 with VOLUME-based shares instead of VALUE-based shares.
* Rationale: X3_white_share is constructed from CHF revenue; price/yield
* heterogeneity (premium Vaud ~55 CHF/hL vs. bulk Ticino ~23 CHF/hL) loads
* onto value-share.  If Cahannes's substitution channel runs through volume
* (what consumers drink, what growers plant) — not revenue — then value-
* share is a mis-specified test.
*
* CORRECTED CONSTRUCTION (per PI correction):  parallel to X3_white_share.
*   X3_white_share     = canton's white VALUE  / national white VALUE  × 100
*   X3_white_vol_share = canton's white VOLUME / national white VOLUME × 100
*
* The dispatch's earlier hybrid formula `(vol_white/(vol_white+vol_red))*X3_share`
* was a hybrid of color-mix and national-intensity that does NOT preserve the
* canton/national share interpretation.  PI flagged this; corrected here.
*
* National denominators (Switzerland row 22 of XLSX):
*   White wine volume:  486,278.9 hL  (71.3% of national wine volume)
*   Red wine volume:    165,102.4 hL  (24.2%)
*   Mixed wine volume:   30,322.6 hL  ( 4.4%)
*
* AREA-share variants (D1a/D2a) NOT constructed: 1907 XLSX source has only
* total cultivated area, not red/white area split.  Source-level limitation,
* not coder skip.
{
    * National denominators (Switzerland row 22 totals from XLSX)
    global NAT_WHITE_VOLUME = 486278.9     // hL
    global NAT_RED_VOLUME   = 165102.4     // hL

    * Volume-based national shares (CORRECTED: parallel to X3_white_share form)
    cap drop X3_white_vol_share
    cap drop X3_red_vol_share
    gen double X3_white_vol_share = wine_volume_white / $NAT_WHITE_VOLUME * 100
    gen double X3_red_vol_share   = wine_volume_red   / $NAT_RED_VOLUME   * 100

    label var X3_white_vol_share "Canton share of national white wine volume (%, 1907)"
    label var X3_red_vol_share   "Canton share of national red wine volume (%, 1907)"

    * Diagnostic ratio (canton's own white/red color mix) — kept for descriptive
    * use in T_desc table; NOT a regression input.
    cap drop X3_white_vol_ratio
    gen double X3_white_vol_ratio = .
    replace X3_white_vol_ratio = wine_volume_white / (wine_volume_white + wine_volume_red) ///
        if (wine_volume_white + wine_volume_red) > 0
    replace X3_white_vol_ratio = 0 if inlist(canton_iso, "UR","OW","NW","ZG","AI")
    label var X3_white_vol_ratio "White vol / (White+Red vol), canton-internal color mix"

    * Interaction: white-vol-share × cov1 (parallel to X3_white_x_cov1)
    cap drop X3_white_vol_x_cov1
    gen double X3_white_vol_x_cov1 = X3_white_vol_share * cov1
    label var X3_white_vol_x_cov1 "White wine vol-share x French language share"

    * Sanity: shares should sum to ~100 (parallel to value-share check in §1.3)
    qui sum X3_white_vol_share
    di as text "  sum(X3_white_vol_share) = " %7.4f r(sum) cond(abs(r(sum)-100)<0.01, "  (OK)", "  (CHECK drift)")
    qui sum X3_red_vol_share
    di as text "  sum(X3_red_vol_share)   = " %7.4f r(sum) cond(abs(r(sum)-100)<0.01, "  (OK)", "  (CHECK drift)")

    * KEY DIAGNOSTIC: does volume-share correlate less with cov1 than value-share?
    qui corr X3_white_share cov1
    local r_val = r(rho)
    qui corr X3_white_vol_share cov1
    local r_vol = r(rho)
    di as text "  corr(X3_white_share, cov1)     = " %6.4f `r_val' "  (value-based)"
    di as text "  corr(X3_white_vol_share, cov1) = " %6.4f `r_vol' "  (volume-based)"
    di as text "  diff (vol - value) = " %6.4f `r_vol' - `r_val' ///
        cond(abs(`r_vol' - `r_val') > 0.1, "  (MATERIAL change)", "  (similar)")
}


**# 1.6 Petition Y outcomes (LIFTED from 12 §1.3 for workshop self-sufficiency)
*------------------------------------------------------------------------------*
* Derives the three petition Y vars from the petition raw counts that
* 08_workshop merged.  Including these in the canonical workshop cohort means
* 12_workshop can just load cohort_1908_workshop.dta and run regressions —
* no further derivation needed.
*
* Three Y vars (per PI data note in 12 §1.3):
*   pet_per_eligible (PRIMARY) -- pct scale (0-100), matches Y1's scale
*   pet_per_cap      (FALLBACK) -- pct scale, denominator is pop_1900
*   pet_natshare     (ALT SCALE) -- pct scale, denominator is national total
{
    * Confirm petition raw counts are present (from 08_workshop §4)
    cap confirm variable pet_total
    if _rc {
        di as error "  §1.6 ERROR: pet_total absent.  08_workshop §4 should have"
        di as error "  merged it from AbsinthePetition.xlsx.  Re-run 08_workshop."
        error 459
    }
    cap confirm variable eligible_1906
    if _rc {
        di as error "  §1.6 ERROR: eligible_1906 absent.  08_workshop §3 should have"
        di as error "  merged it from swissvotes.  Re-run 08_workshop."
        error 459
    }

    * Petition national total (Bundesblatt 1907 p.984)
    local pet_nat_total = 169377

    cap drop pet_per_eligible
    gen double pet_per_eligible = pet_total / eligible_1906 * 100
    label var pet_per_eligible "Petition signatures per 100 eligible voters"

    cap drop pet_per_cap
    gen double pet_per_cap = pet_total / pop_1906 * 100
    label var pet_per_cap "Petition signatures per 100 pop. (1906 pop; petition is a 1906 event)"

    cap drop pet_natshare
    gen double pet_natshare = pet_total / `pet_nat_total' * 100
    label var pet_natshare "Petition canton share of national (%)"

    di as text _newline "  Petition Y outcomes derived (lifted from 12 §1.3):"
    qui sum pet_per_eligible
    di as text "    pet_per_eligible (PRIMARY): mean=" %5.2f r(mean) ", range [" %5.2f r(min) ", " %5.2f r(max) "]"
    qui sum pet_per_cap
    di as text "    pet_per_cap (fallback):     mean=" %5.2f r(mean) ", range [" %5.2f r(min) ", " %5.2f r(max) "]"
    qui sum pet_natshare
    di as text "    pet_natshare (alt scale):   sum =" %7.4f r(sum) " (should = 100.0000)"
}


**# 1.7 OVERWRITE cohort_1908_workshop.dta with the canonical full cohort
*------------------------------------------------------------------------------*
* Per dispatch: at end of §1.x (after all derivations + interactions, BEFORE
* §2 regressions), overwrite the intermediate from 08_workshop with the
* canonical full version.  This is THE workshop source of truth.
{
    assert c(N) == 25
    isid canton_iso

    * Recreate pct_yes_68 as alias of Y1 for downstream code that expects
    * the original swissvotes naming (cross-referendum loop in §2.7 etc.).
    * Keeping both makes the cohort transparent: Y1 is the renamed primary,
    * pct_yes_68 is the swissvotes-native name for symmetry with 67 / 69.
    cap drop pct_yes_68
    gen double pct_yes_68 = Y1
    label var pct_yes_68 "Yes-vote, Vote #68 (absinthe ban)"

    compress
    save "$MyProject/processed/cohort_1908_workshop.dta", replace
    di as text _newline "  §1.7: OVERWROTE cohort_1908_workshop.dta with canonical full cohort"
    di as text "        Observations: " c(N) ", Variables: " c(k)
    di as text "        This is THE workshop source of truth.  All downstream"
    di as text "        workshop scripts read this file."
}


**# 2. Primary regression battery -- 4 wine variants x 5 cascade cols (20 OLS)
*------------------------------------------------------------------------------*

**# 2.0 Standalone-run preamble: confirm §1 outputs are loaded
*------------------------------------------------------------------------------*
* Same SKIP gate as 09 §2.0 — sister scripts (e.g., 12_workshop) source 09_workshop
* to get §1.0-§1.6 setup and then run their own regressions.
{
    if "${SKIP_09_REGRESSIONS}" == "1" {
        di as text _newline "  09_workshop: setup complete (§1.0-§1.7); §2-§2.7 SKIPPED per \$SKIP_09_REGRESSIONS=1"
        di as text "  Caller (e.g., 12_workshop) now has all derivations + spec globals + cohort save."
        exit
    }

    cap confirm variable X1
    if _rc {
        di as error "  §2 needs §1 output (X1) but X1 is absent."
        error 459
    }
    if "${X_spec1}" == "" {
        di as error "  §2 needs §1.4 spec globals but they are unset."
        error 459
    }
}


**# 2.1 Run 20 primary OLS specs and save each to .ster (WORKSHOP dir)
*------------------------------------------------------------------------------*
* Routes to estimates_workshop/ to avoid overwriting non-workshop estimates/.
{
    cap mkdir "$MyProject/results"
    cap mkdir "$MyProject/results/intermediate"
    cap mkdir "$MyProject/results/intermediate/estimates_workshop"

    di as text _newline "  --- Primary battery (workshop): 20 OLS specs ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            cap estimates drop ols_`k'_`j'
            qui regress Y1 ${X_spec`k'} `ctrl', vce(hc3)
            estimates store ols_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_workshop/ols_`k'_`j'.ster", replace

            di as text "  Spec ols`k'.`j': N=" e(N) ", R^2=" %5.3f e(r2) ///
                       ", beta(${X_spec`k'})=" %8.4f _b[${X_spec`k'}]
        }
    }
    di as text _newline "  Battery complete: 20 OLS specs saved to results/intermediate/estimates_workshop/"
}


**# 2.5 Fractional logit parallel for the 20 primary OLS specs (WORKSHOP dir)
*------------------------------------------------------------------------------*
{
    cap mkdir "$MyProject/results/intermediate/estimates_fraclogit_workshop"

    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    label var Y1_frac "Yes-share vote 68 on [0,1] scale (for fracreg)"

    di as text _newline "  --- Fractional logit battery (workshop): 20 specs + 20 AME stores ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            cap estimates drop fl_`k'_`j'
            qui fracreg logit Y1_frac ${X_spec`k'} `ctrl', vce(robust)
            estimates store fl_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_`k'_`j'.ster", replace

            cap estimates drop fl_me_`k'_`j'
            * Phase A'' fix (2026-05-22): dydx(*) instead of dydx(WINE) so
            * covariate AMEs populate e(b); downstream FL panels (T2/T3/T7)
            * render full coefficient columns instead of blank covariate rows.
            qui margins, dydx(*) post
            estimates store fl_me_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_`k'_`j'.ster", replace

            di as text "  Spec fl`k'.`j': N=" e(N) ", AME(${X_spec`k'})=" %8.4f _b[${X_spec`k'}]
        }
    }
    di as text _newline "  Fraclogit battery complete: 40 stores in estimates_fraclogit_workshop/"
}


**# 2.6 Robustness specs (R1-R6 + R4b): WORKSHOP-density controls
*------------------------------------------------------------------------------*
* All at the workshop-equivalent of cascade col 5 (cov1 cov2_total_share cov3
* ln_density) — replacing the original (cov_land cov1 ... ln_pop_1900) used
* in non-workshop 09 §2.6.  R4b is NEW: same as R4 but with X3_share
* instead of X2_share, for Table 5 Panel B.
{
    cap mkdir "$MyProject/results/intermediate/estimates_robust_workshop"

    local Xwine "X2_share"

    di as text _newline "  --- Robustness battery (workshop): R1-R6 + R4b ---"

    * R1: n_firms instead of total_share
    cap estimates drop r1_nfirms
    qui regress Y1 `Xwine' cov1 abs_nfirms cov3 ln_density, vce(hc3)
    estimates store r1_nfirms
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r1_nfirms.ster", replace
    di as text "  R1 (n_firms):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R2: producer dummy instead of total_share
    cap estimates drop r2_producer
    qui regress Y1 `Xwine' cov1 abs_producer cov3 ln_density, vce(hc3)
    estimates store r2_producer
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r2_producer.ster", replace
    di as text "  R2 (producer dum):  N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R3: log(1+kg) instead of share
    cap estimates drop r3_abslog
    qui regress Y1 `Xwine' cov1 abs_log cov3 ln_density, vce(hc3)
    estimates store r3_abslog
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r3_abslog.ster", replace
    di as text "  R3 (abs_log):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R4: French x producer interaction (added to primary; abs_producer also as main effect)
    *     X2_share (volume) version — Table 5 Panel A.
    cap estimates drop r4_fr_x_prod
    qui regress Y1 `Xwine' cov1 cov2_total_share cov3 ln_density fr_x_producer abs_producer, vce(hc3)
    estimates store r4_fr_x_prod
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r4_fr_x_prod.ster", replace
    di as text "  R4 (fr x producer): N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine'] ", beta(fr_x_producer)=" %8.4f _b[fr_x_producer]

    * R4b: NEW — French x producer with X3_share (revenue) — Table 5 Panel B.
    cap estimates drop r4b_fr_x_prod_x3
    qui regress Y1 X3_share cov1 cov2_total_share cov3 ln_density fr_x_producer abs_producer, vce(hc3)
    estimates store r4b_fr_x_prod_x3
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r4b_fr_x_prod_x3.ster", replace
    di as text "  R4b (fr x prod, X3): N=" e(N) ", beta(X3_share)=" %8.4f _b[X3_share] ", beta(fr_x_prod)=" %8.4f _b[fr_x_producer]

    * R5: drop-NE sample (the absinthe heartland)
    cap estimates drop r5_drop_ne
    qui regress Y1 `Xwine' cov1 cov2_total_share cov3 ln_density if canton_iso != "NE", vce(hc3)
    estimates store r5_drop_ne
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r5_drop_ne.ster", replace
    di as text "  R5 (drop-NE):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R6: log-wine + log-absinthe (both treatment + absinthe control in log space)
    cap estimates drop r6_loglog
    qui regress Y1 wine_vol_log cov1 abs_log cov3 ln_density, vce(hc3)
    estimates store r6_loglog
    estimates save "$MyProject/results/intermediate/estimates_robust_workshop/r6_loglog.ster", replace
    di as text "  R6 (log-log):       N=" e(N) ", beta(wine_vol_log)=" %8.4f _b[wine_vol_log]

    di as text _newline "  Robustness battery complete: 7 specs (R1-R6 + R4b) saved to estimates_robust_workshop/"
}


**# 2.7 Cross-referendum battery (votes 67, 68, 69) -- workshop ADDITION
*------------------------------------------------------------------------------*
* Falsification logic: same voters, same ballot day, three different questions.
* Expectation: β_wine ≈ 0 on #67 (commerce) and #69 (water power); positive on #68.
*
* Both OLS and fracreg parallel, like the §2.1 / §2.5 split.  Routes to
* estimates_crossref/ (new dir).
*
* Note: §1.7 created pct_yes_68 as alias of Y1, so the foreach loop below
* works uniformly across 67/68/69 without special-casing.
{
    cap mkdir "$MyProject/results/intermediate/estimates_crossref"

    di as text _newline "  --- Cross-referendum battery (votes 67, 68, 69) ---"

    foreach r_id in 67 68 69 {
        cap confirm variable pct_yes_`r_id'
        if _rc {
            di as error "  pct_yes_`r_id' not in cohort -- extend 08 §1 to pull this vote"
            continue
        }

        * OLS
        cap estimates drop crossref_ols_`r_id'
        qui regress pct_yes_`r_id' X3_share cov1 cov2_total_share cov3 ln_density, vce(hc3)
        estimates store crossref_ols_`r_id'
        estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_ols_`r_id'.ster", replace
        di as text "  Vote `r_id' OLS:    N=" e(N) ", beta(X3_share)=" %8.4f _b[X3_share]

        * Fractional logit
        cap drop _yfrac
        gen double _yfrac = pct_yes_`r_id' / 100
        cap estimates drop crossref_fl_`r_id'
        qui fracreg logit _yfrac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
        estimates store crossref_fl_`r_id'
        estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_fl_`r_id'.ster", replace

        cap estimates drop crossref_fl_me_`r_id'
        * Phase A'' fix (2026-05-22): dydx(*) so T8 FL crossref panel shows
        * full covariate AMEs (cov1, cov2, cov3, ln_density) not just X3_share.
        qui margins, dydx(*) post
        estimates store crossref_fl_me_`r_id'
        estimates save "$MyProject/results/intermediate/estimates_crossref/crossref_fl_me_`r_id'.ster", replace
        di as text "  Vote `r_id' FL AME: " %8.4f _b[X3_share]

        drop _yfrac
    }

    di as text _newline "  Crossref battery complete: 9 stores (3 OLS + 3 FL + 3 AME) in estimates_crossref/"
}


**# 2.9 Wine-type decomposition (Cahannes 1981 white wine substitution test)
*------------------------------------------------------------------------------*
* Motivation: Cahannes (1981) attests "absinthe, particularly popular in the
* French part of the country, competed with white wine".  Direct test: split
* X3_share into white/red components and re-run the headline spec.
*
* Prediction (if Cahannes is right):
*   β(X3_white_share) on Y1 > β(X3_share aggregate) on Y1 > β(X3_red_share)
*
* Battery:
*   1. Cascade for X3_white_share + X3_red_share (5 cols each, OLS HC3) — for
*      visual parallel to spec set 3 / X3_share in Table 2.
*   2. FL AME at col 5 for white + red — for headline-comparable inference.
*   3. Petition cascade at col 5 for white + red — asymmetric-outcome parallel.
*
* Routes to estimates_winetype_workshop/ (new dir).
{
    cap mkdir "$MyProject/results/intermediate/estimates_winetype_workshop"

    di as text _newline "  --- Wine-type battery (Cahannes test) ---"

    * --- 1. OLS cascade for white + red ---
    foreach k_label in white red {
        local Xspec X3_`k_label'_share
        forvalues j = 1/5 {
            local ctrl "${ctrl_s_c`j'}"
            cap estimates drop ols_`k_label'_`j'
            qui regress Y1 `Xspec' `ctrl', vce(hc3)
            estimates store ols_`k_label'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_winetype_workshop/ols_`k_label'_`j'.ster", ///
                replace
            di as text "  OLS `k_label'.`j': N=" e(N) ", R^2=" %5.3f e(r2) ", β(`Xspec')=" %8.4f _b[`Xspec']
        }
    }

    * --- 2. FL AME at col 5 for white + red (headline-comparable) ---
    cap drop Y1_frac_wt
    gen double Y1_frac_wt = Y1 / 100

    foreach k_label in white red {
        local Xspec X3_`k_label'_share
        cap estimates drop fl_`k_label'_5
        qui fracreg logit Y1_frac_wt `Xspec' ${ctrl_s_c5}, vce(robust)
        estimates store fl_`k_label'_5
        estimates save ///
            "$MyProject/results/intermediate/estimates_winetype_workshop/fl_`k_label'_5.ster", replace

        cap estimates drop fl_me_`k_label'_5
        * Phase A'' fix (2026-05-22): dydx(*) so T9 wine-type cascade FL
        * panels (white/red) show full covariate AMEs alongside the wine slope.
        qui margins, dydx(*) post
        estimates store fl_me_`k_label'_5
        estimates save ///
            "$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_`k_label'_5.ster", replace
        di as text "  FL AME `k_label'.5: " %8.4f _b[`Xspec']
    }
    drop Y1_frac_wt

    * --- 3. Petition cascade at col 5 for white + red (asymmetric-outcome parallel) ---
    foreach k_label in white red {
        local Xspec X3_`k_label'_share
        cap estimates drop ols_pet_`k_label'_5
        qui regress pet_per_eligible `Xspec' ${ctrl_s_c5}, vce(hc3)
        estimates store ols_pet_`k_label'_5
        estimates save ///
            "$MyProject/results/intermediate/estimates_winetype_workshop/ols_pet_`k_label'_5.ster", ///
            replace
        di as text "  Petition `k_label'.5: N=" e(N) ", β(`Xspec')=" %8.4f _b[`Xspec']
    }

    di as text _newline "  Wine-type battery complete: 14 stores in estimates_winetype_workshop/"
    di as text "    (10 OLS cascade + 2 FL + 2 FL AME + 2 petition OLS)"
}


**# 2.10 Phase 10: white-wine mechanism interactions + drop-Ticino robustness
*------------------------------------------------------------------------------*
* Per Phase 10 dispatch (2026-05-21):
*   D1 — White × French (cov1) interaction, abs_producer dummy control
*   D2 — White × French (cov1) interaction, cov2_total_share continuous control
*   E1 — White × Absinthe-producer dummy interaction
*   E2 — White × Absinthe trade share continuous interaction
*   F  — Drop-Ticino sample restriction on full Table 9 cascades (15 specs)
*
* Each interaction: OLS HC3 + FL AME + marginal effects at moderator values.
* Identification: each interaction term is the partial derivative of the
* white-wine effect with respect to the moderator (French share, abs producer,
* absinthe share).  Marginal-effects table makes interpretation transparent.
{
    cap mkdir "$MyProject/results/intermediate/estimates_winetype_workshop"

    di as text _newline "  --- Phase 10 battery: D1, D2, E1, E2, F ---"

    * ============================================================
    * Construct interaction variables (idempotent via cap drop)
    * ============================================================
    cap drop X3_white_x_cov1
    gen double X3_white_x_cov1 = X3_white_share * cov1
    label var X3_white_x_cov1 "White wine national share × French language share"

    cap drop X3_white_x_absprod
    gen double X3_white_x_absprod = X3_white_share * abs_producer
    label var X3_white_x_absprod "White wine national share × Absinthe-producer indicator"

    cap drop X3_white_x_cov2
    gen double X3_white_x_cov2 = X3_white_share * cov2_total_share
    label var X3_white_x_cov2 "White wine national share × Absinthe trade share"

    cap drop Y1_frac_p10
    gen double Y1_frac_p10 = Y1 / 100


    * NOTE on estimates-store naming: Stata's `_est_` internal-prefix forces the
    * user-facing store name to be ≤ 27 chars (32 minus 5 for `_est_`).  We use
    * short codes (D1/D2/E1/E2/etc.) for the in-memory stores; the .ster
    * filenames retain descriptive long names for human readability on disk.

    * ============================================================
    * D1: White × French interaction, abs_producer DUMMY control
    * ============================================================
    {
        * OLS HC3
        cap estimates drop ols_d1
        qui regress Y1 X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density, vce(hc3)
        estimates store ols_d1
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_french_dummy.ster", replace
        di as text "  D1 OLS:    β(white)=" %7.4f _b[X3_white_share] ", β(cov1)=" %7.4f _b[cov1] ", β(W×F)=" %7.4f _b[X3_white_x_cov1]

        * FL parallel
        cap estimates drop fl_d1
        qui fracreg logit Y1_frac_p10 X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density, vce(robust)
        estimates store fl_d1
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_dummy.ster", replace

        * Marginal effects of X3_white_share at cov1 ∈ {0, 25, 50, 75, 100}
        cap estimates drop fl_d1_mg
        qui margins, dydx(X3_white_share) at(cov1=(0 25 50 75 100)) post
        estimates store fl_d1_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_dummy_mg.ster", replace
        di as text "  D1 margins (dy/dx of X3_white at cov1=0/25/50/75/100):"
        di as text "    cov1=  0: AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    cov1= 25: AME=" %8.5f _b[2._at] ", SE=" %8.5f _se[2._at]
        di as text "    cov1= 50: AME=" %8.5f _b[3._at] ", SE=" %8.5f _se[3._at]
        di as text "    cov1= 75: AME=" %8.5f _b[4._at] ", SE=" %8.5f _se[4._at]
        di as text "    cov1=100: AME=" %8.5f _b[5._at] ", SE=" %8.5f _se[5._at]
    }


    * ============================================================
    * D2: White × French interaction, cov2_total_share CONTINUOUS control
    * ============================================================
    {
        * OLS HC3
        cap estimates drop ols_d2
        qui regress Y1 X3_white_share cov1 X3_white_x_cov1 cov2_total_share cov3 ln_density, vce(hc3)
        estimates store ols_d2
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_french_cont.ster", replace
        di as text "  D2 OLS:    β(white)=" %7.4f _b[X3_white_share] ", β(cov1)=" %7.4f _b[cov1] ", β(W×F)=" %7.4f _b[X3_white_x_cov1]

        * FL parallel
        cap estimates drop fl_d2
        qui fracreg logit Y1_frac_p10 X3_white_share cov1 X3_white_x_cov1 cov2_total_share cov3 ln_density, vce(robust)
        estimates store fl_d2
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_cont.ster", replace

        * Marginal effects of X3_white_share at cov1 ∈ {0, 25, 50, 75, 100}
        cap estimates drop fl_d2_mg
        qui margins, dydx(X3_white_share) at(cov1=(0 25 50 75 100)) post
        estimates store fl_d2_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_cont_mg.ster", replace
        di as text "  D2 margins (dy/dx of X3_white at cov1=0/25/50/75/100):"
        di as text "    cov1=  0: AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    cov1= 50: AME=" %8.5f _b[3._at] ", SE=" %8.5f _se[3._at]
        di as text "    cov1=100: AME=" %8.5f _b[5._at] ", SE=" %8.5f _se[5._at]
    }


    * ============================================================
    * E1: White × Absinthe-producer DUMMY interaction
    * ============================================================
    {
        * OLS HC3
        cap estimates drop ols_e1
        qui regress Y1 X3_white_share abs_producer X3_white_x_absprod cov1 cov3 ln_density, vce(hc3)
        estimates store ols_e1
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_absprod.ster", replace
        di as text "  E1 OLS:    β(white)=" %7.4f _b[X3_white_share] ", β(absprod)=" %7.4f _b[abs_producer] ", β(W×P)=" %7.4f _b[X3_white_x_absprod]

        * FL parallel
        cap estimates drop fl_e1
        qui fracreg logit Y1_frac_p10 X3_white_share abs_producer X3_white_x_absprod cov1 cov3 ln_density, vce(robust)
        estimates store fl_e1
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_absprod.ster", replace

        * Marginal effects of X3_white_share at abs_producer ∈ {0, 1}
        cap estimates drop fl_e1_mg
        qui margins, dydx(X3_white_share) at(abs_producer=(0 1)) post
        estimates store fl_e1_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_absprod_mg.ster", replace
        di as text "  E1 margins (dy/dx of X3_white at abs_producer=0/1):"
        di as text "    abs_producer=0 (non-producer): AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    abs_producer=1 (producer):     AME=" %8.5f _b[2._at] ", SE=" %8.5f _se[2._at]
    }


    * ============================================================
    * E2: White × Absinthe trade share CONTINUOUS interaction
    * ============================================================
    {
        * OLS HC3
        cap estimates drop ols_e2
        qui regress Y1 X3_white_share cov2_total_share X3_white_x_cov2 cov1 cov3 ln_density, vce(hc3)
        estimates store ols_e2
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_cov2.ster", replace
        di as text "  E2 OLS:    β(white)=" %7.4f _b[X3_white_share] ", β(cov2)=" %7.4f _b[cov2_total_share] ", β(W×C2)=" %7.4f _b[X3_white_x_cov2]

        * FL parallel
        cap estimates drop fl_e2
        qui fracreg logit Y1_frac_p10 X3_white_share cov2_total_share X3_white_x_cov2 cov1 cov3 ln_density, vce(robust)
        estimates store fl_e2
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_cov2.ster", replace

        * Marginal effects of X3_white_share at cov2_total_share ∈ {0, 5, 25, 50}
        cap estimates drop fl_e2_mg
        qui margins, dydx(X3_white_share) at(cov2_total_share=(0 5 25 50)) post
        estimates store fl_e2_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_cov2_mg.ster", replace
        di as text "  E2 margins (dy/dx of X3_white at cov2=0/5/25/50):"
        di as text "    cov2= 0: AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    cov2= 5: AME=" %8.5f _b[2._at] ", SE=" %8.5f _se[2._at]
        di as text "    cov2=25: AME=" %8.5f _b[3._at] ", SE=" %8.5f _se[3._at]
        di as text "    cov2=50: AME=" %8.5f _b[4._at] ", SE=" %8.5f _se[4._at]
    }

    drop Y1_frac_p10


    * ============================================================
    * F: Drop-Ticino sample restriction on full cascade (15 specs)
    * ============================================================
    * Re-run cascades for aggregate, white, red wine with TI excluded (N=24).
    * Tests whether the cascade patterns in Table 9 are sensitive to TI's
    * cultural-yes-vote channel.
    {
        di as text _newline "  --- Spec F: Drop-Ticino cascades (N=24) ---"

        * Aggregate wine cascade, no TI
        forvalues j = 1/5 {
            cap estimates drop ols_agg_`j'_noti
            qui regress Y1 X3_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
            estimates store ols_agg_`j'_noti
            estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_`j'_noti.ster", replace
            di as text "    AGG no-TI col `j': N=" e(N) ", β(X3_share)=" %7.4f _b[X3_share]
        }

        * White wine cascade, no TI
        forvalues j = 1/5 {
            cap estimates drop ols_white_`j'_noti
            qui regress Y1 X3_white_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
            estimates store ols_white_`j'_noti
            estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_`j'_noti.ster", replace
            di as text "    WHITE no-TI col `j': N=" e(N) ", β(X3_white_share)=" %7.4f _b[X3_white_share]
        }

        * Red wine cascade, no TI
        forvalues j = 1/5 {
            cap estimates drop ols_red_`j'_noti
            qui regress Y1 X3_red_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
            estimates store ols_red_`j'_noti
            estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_`j'_noti.ster", replace
            di as text "    RED no-TI col `j': N=" e(N) ", β(X3_red_share)=" %7.4f _b[X3_red_share]
        }

        di as text "  Spec F: Drop-Ticino cascades complete (15 specs, N=24)"
    }

    di as text _newline "  Phase 10 battery complete: 23 NEW stores in estimates_winetype_workshop/"
    di as text "    (4 OLS interactions + 4 FL + 4 FL margins + 15 drop-TI cascade = 27 total"
    di as text "     minus the 4 interaction OLS already produced via post-margins ... ≈ 23 unique stores)"
}


**# 2.10b Phase 10b: Volume-share re-test of D1 / D2 (Cahannes substitution channel)
*------------------------------------------------------------------------------*
* Re-runs D1 and D2 with X3_white_vol_share replacing X3_white_share.  Tests
* whether the null interactions in Phase 10 (β(W×F) ≈ 0) reflect a real null
* OR a value/yield confound masking the substitution channel.  D1a/D2a (area-
* based) skipped per Step 0 — area not split by color in 1907 source.
{
    cap mkdir "$MyProject/results/intermediate/estimates_winetype_workshop"

    di as text _newline "  --- Phase 10b: D1v + D2v (volume-share re-test) ---"

    cap drop Y1_frac_p10b
    gen double Y1_frac_p10b = Y1 / 100

    * ============================================================
    * D1v: White-VOL × French interaction, abs_producer DUMMY control
    * ============================================================
    {
        cap estimates drop ols_d1v
        qui regress Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density, vce(hc3)
        estimates store ols_d1v
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_d1v.ster", replace
        di as text "  D1v OLS:   β(white_vol)=" %7.4f _b[X3_white_vol_share] ", β(cov1)=" %7.4f _b[cov1] ", β(W_vol×F)=" %7.4f _b[X3_white_vol_x_cov1]

        cap estimates drop fl_d1v
        qui fracreg logit Y1_frac_p10b X3_white_vol_share cov1 X3_white_vol_x_cov1 abs_producer cov3 ln_density, vce(robust)
        estimates store fl_d1v
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d1v.ster", replace

        cap estimates drop fl_d1v_mg
        qui margins, dydx(X3_white_vol_share) at(cov1=(0 25 50 75 100)) post
        estimates store fl_d1v_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d1v_mg.ster", replace
        di as text "  D1v margins (dy/dx of white_vol at cov1=0/25/50/75/100):"
        di as text "    cov1=  0: AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    cov1= 25: AME=" %8.5f _b[2._at] ", SE=" %8.5f _se[2._at]
        di as text "    cov1= 50: AME=" %8.5f _b[3._at] ", SE=" %8.5f _se[3._at]
        di as text "    cov1= 75: AME=" %8.5f _b[4._at] ", SE=" %8.5f _se[4._at]
        di as text "    cov1=100: AME=" %8.5f _b[5._at] ", SE=" %8.5f _se[5._at]
    }

    * ============================================================
    * D2v: White-VOL × French interaction, cov2_total_share CONTINUOUS control
    * ============================================================
    {
        cap estimates drop ols_d2v
        qui regress Y1 X3_white_vol_share cov1 X3_white_vol_x_cov1 cov2_total_share cov3 ln_density, vce(hc3)
        estimates store ols_d2v
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_d2v.ster", replace
        di as text "  D2v OLS:   β(white_vol)=" %7.4f _b[X3_white_vol_share] ", β(cov1)=" %7.4f _b[cov1] ", β(W_vol×F)=" %7.4f _b[X3_white_vol_x_cov1]

        cap estimates drop fl_d2v
        qui fracreg logit Y1_frac_p10b X3_white_vol_share cov1 X3_white_vol_x_cov1 cov2_total_share cov3 ln_density, vce(robust)
        estimates store fl_d2v
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d2v.ster", replace

        cap estimates drop fl_d2v_mg
        qui margins, dydx(X3_white_vol_share) at(cov1=(0 25 50 75 100)) post
        estimates store fl_d2v_mg
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_d2v_mg.ster", replace
        di as text "  D2v margins (dy/dx of white_vol at cov1=0/25/50/75/100):"
        di as text "    cov1=  0: AME=" %8.5f _b[1._at] ", SE=" %8.5f _se[1._at]
        di as text "    cov1= 50: AME=" %8.5f _b[3._at] ", SE=" %8.5f _se[3._at]
        di as text "    cov1=100: AME=" %8.5f _b[5._at] ", SE=" %8.5f _se[5._at]
    }

    drop Y1_frac_p10b

    di as text _newline "  Phase 10b battery complete: 6 NEW stores in estimates_winetype_workshop/"
    di as text "    (2 OLS + 2 FL + 2 FL margins)"
}


**# 3. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    cap which _codebook_update
    if !_rc {
        _codebook_update using "$MyProject/processed/cohort_1908_workshop.dta", ///
            script("09_canton_reg1_workshop.do")
    }

    if "${RUN_POSTCREDITS}" == "1" {
        cap which _inventory_append
        if !_rc {
            _inventory_append, sheet("datasets") ///
                row("updated|processed/cohort_1908_workshop.dta|`=c(N)'|`=c(k)'|.|09_canton_reg1_workshop.do")
        }
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
