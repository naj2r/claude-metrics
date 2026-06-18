/*==============================================================================
 09_canton_reg1.do
 Purpose:  First set of canton-level regressions on the 1908 cohort.  Consumes
           cohort_1908.dta (built by 08_setup_cohort_1908.do) without writing
           back to it -- this script PRODUCES regression results and tables,
           it does not modify the underlying cohort dataset.

           [Spec details TBD -- file is preamble-only scaffold at this point.
           PI will describe the regression structure (M1A specs etc.) before
           we add any analysis logic.]

 Input:    $MyProject/processed/cohort_1908.dta   (25 cantons x 49 vars; built
                                                   by 08_setup_cohort_1908.do;
                                                   independent of 02_clean.do
                                                   and absinthe_analysis.dta)

 Output:   [TBD -- typical regression-script outputs are one or both of:
            $MyProject/results/intermediate/canton_reg1_results.dta
                                                   (regsave accumulator;
                                                    one row per spec)
            $MyProject/results/tables/canton_reg1.tex
                                                   (esttab publication table)
           Final destinations chosen once PI defines the regression battery.]

 Author:   Nicholas A Jensen
 Date:     2026-05-20
 Version:  0.1 (scaffold; no analysis logic yet)

 Conventions inherited from 08_setup_cohort_1908.do:
   - Standalone-execution preamble (lines below the docstring) so the script
     runs cleanly from any session that has $MyProject set.
   - Standalone-run preamble at the top of each main section (§N.0) for
     chunked Ctrl+D iteration in the do-file editor; sentinel = a variable
     from cohort_1908.dta that this script does NOT modify (ln_canton_area_km2
     chosen because it is the LAST variable saved by 08, so its presence
     transitively implies the full cohort is loaded).
   - Post-credits block gated on $RUN_POSTCREDITS == "1" so iteration runs
     don't pollute _inventory.xlsx (per the project-specific rule documented
     in .claude/rules/stata-gotchas.md, "_inventory_append is append-only").
   - All paths via $MyProject; no hardcoded absolutes; forward slashes only.
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
    * [Script-specific setup goes here once we define the regression battery.
    *  Likely candidates: estimate-store-name prefix; regsave accumulator
    *  path; list of treatment / control variable names from cohort_1908.dta;
    *  HC3 SE convention (per .claude/rules/methodology-integrity.md, "Robust
    *  SE family = HC3 for all OLS at N=25"); RI permutation count = 10,000
    *  if any inference uses randomization inference.  All placeholders for
    *  now -- empty until PI specifies.]
}
/* Manual mode!!!
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"
*/

**# 1. Load cohort + prepare any derived analysis variables
*------------------------------------------------------------------------------*

**# 1.0 Standalone-run preamble: load cohort_1908.dta if memory is empty / re-runnable
*------------------------------------------------------------------------------*
* Sentinel var = ln_canton_area_km2 (LAST var saved by 08_setup_cohort_1908.do
* §8.2).  If it's absent, in-memory state is either empty or a stale partial
* cohort -- either way, reload the canonical on-disk cohort_1908.dta.  This is
* the same predecessor-last-var pattern used throughout 08, applied here to
* enforce "the full 08 output is loaded" rather than just "something is in
* memory."  See .claude/rules/stata-gotchas.md "Standalone-preamble pattern"
* for the canonical rule.
{
    cap confirm variable ln_canton_area_km2
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §1 needs cohort_1908.dta (built by 08_setup_cohort_1908.do)"
            di as error "  but the file does not exist.  Run 08 first, then re-run 09."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    * Idempotency: any derived analysis vars this section adds go in the
    * `cap drop' list below so the section can be re-run cleanly.
    * Empty for now -- populate when §1.1 adds derivations.
    * foreach v in <vars_this_section_adds> {
    *     cap drop `v'
    * }
}


**# 1.1 Construct any derived variables needed for the regressions
*------------------------------------------------------------------------------*
{
    * [Derived-variable construction goes here once we define what the
    *  regression battery needs.  Likely candidates given the M1A spec
    *  inputs already loaded in cohort_1908:
    *    - vineyard_per_cap = wine_area_canton_ha / pop_1900 * 1000
    *    - yes_frac = pct_yes_68 / 100 (for fractional logit if used)
    *    - any interactions or polynomials
    *  Each new var gets a `label var' with units in parentheses.
    *  All derivations placeholder until PI specifies.]
}

**# 1.2 ADD THE VARIABLE GLOBAL MACROS
{
	* 1.2.1 NAMING CONVENTIONS -- X-VARIABLES and Y1
	capture rename wine_area_canton_ha wine_ha		// shorter name
	capture rename pct_yes_68 Y1 					// Absinthe Ban Vote
	label var Y1 "Yes-vote share, vote #68 (pct, 0-100) [pct_yes_68]"
	capture drop X1
	gen X1 = wine_ha / pop_1900 * 1000	// Wine area per 1,000 pop (ha per 1k people)
	label var X1 "Wine area per 1,000 pop., canton (ha per 1k people, 1907)"
	capture rename wine_volume_canton_hl X2_num // Wine Regressor 2 -- Qty
	label var X2_num  "Wine volume, canton (hl, 1907) [wine_volume_canton_hl]"
	capture rename wine_revenue_canton_fr X3_num // Wine Regressor 3 -- Revenue
	label var X3_num  "Wine revenue, canton (Fr, 1907) [wine_revenue_canton_fr]"
	capture rename wine_yield_canton_hl_per_ha X4 // Wine Regressor 4 -- Wine yield per hectare
	label var X4  "Wine yield, canton (hl/ha, 1907) [wine_yield_canton_hl_per_ha]"
	* (X4 missing-convention for 5 non-wine cantons enforced in §1.3 alongside the
	*  rest of the structural-zeros / missing-data policy)
}
{	// import and save 3 national values (Switzerland row 22) for bounded X*_share vars
	preserve
	    import excel ///
	        "C:/Users/jensenn/Dropbox/research_data_raw/c-metrics-absinthe1/original/Statistical Yearbooks of Switzerland/Canton1907_wine-data.xlsx", ///
	        sheet("Sheet1") cellrange(C22:E22) clear allstring
	    * Row 22 cols C:E arrive as 3 string vars (Stata auto-names by Excel column
	    * letter -- could be C/D/E, A/B/C, or something else depending on Stata
	    * version).  Rename (*) by position to known names so the next 3 lines
	    * don't depend on Stata's naming convention.
	    rename (*) (v_area v_volume v_value)
	    local nat_area   = real(v_area[1])     // C22 = Cultivated area (ha)
	    local nat_volume = real(v_volume[1])   // D22 = Total yield (hl)
	    local nat_value  = real(v_value[1])    // E22 = Total value (Fr)
	restore

	// save values (globals so they survive across Ctrl+D chunks)
	global NAT_WINE_AREA   = `nat_area'
	global NAT_WINE_VOLUME = `nat_volume'
	global NAT_WINE_VALUE  = `nat_value'
	di "  national wine area    = $NAT_WINE_AREA   ha"
	di "  national wine volume  = $NAT_WINE_VOLUME hl"
	di "  national wine value   = $NAT_WINE_VALUE  Fr"
}
	// reload data if needed
	* preserve/restore above already restored the cohort.  Sentinel fallback in case
	* something went sideways (e.g., a prior chunk ran the import without preserve):
	cap confirm variable ln_canton_area_km2
	if _rc {
	    use "$MyProject/processed/cohort_1908.dta", clear
	    di as text "  (fallback: reloaded cohort_1908.dta from disk)"
	}

	cap drop X1_share X2_share X3_share
	gen X1_share = wine_ha / $NAT_WINE_AREA   * 100
	gen X2_share = X2_num  / $NAT_WINE_VOLUME * 100
	gen X3_share = X3_num  / $NAT_WINE_VALUE  * 100

	label var X1_share "Canton share of national wine area (%, 1907)"
	label var X2_share "Canton share of national wine volume (%, 1907)"
	label var X3_share "Canton share of national wine value (%, 1907)"

	* Sanity: extensive shares should sum to ~100 (pct scale) across 25 cantons
	foreach v in X1_share X2_share X3_share {
	    qui sum `v'
	    di "  sum(`v') = " %7.4f r(sum) cond(abs(r(sum)-100)<0.01, "  (OK)", "  (CHECK drift)")
	}
	
	* 1.2.2 COVARIATE NAMING + percent rescaling
	*
	* Convention (2026-05-20): all share-form covariates on percent (0-100)
	* scale to match Y outcomes (Y1, pet_per_eligible).  Pattern: cap drop +
	* gen from the original fraction-scale source.  Keeps source vars named
	* in the cohort for descriptive use; derives cov* alias on percent scale
	* for regression use.  Idempotent under chunked re-runs (no compounding).

	// cov1: French language share -> percent
	cap drop cov1
	gen double cov1 = french_share * 100
	label var cov1 "French share of Ger.+Fr. speakers (%, 1900, subset denom)"

	// Absinthe-share intermediate renames (originals kept on fraction scale)
	capture rename share_of_total_domestic dom_share_abs // domestic absinthe share
	capture rename share_of_total_exports exp_share_abs // export absinthe share
	capture rename share_of_total_purchases dom_share_total // total absinthe share

	// cov2_*: Absinthe shares -> percent
	cap drop cov2_dom cov2_exp cov2_total_share
	gen double cov2_dom         = dom_share_abs   * 100
	gen double cov2_exp         = exp_share_abs   * 100
	gen double cov2_total_share = dom_share_total * 100
	label var cov2_dom         "Canton share of national absinthe domestic (%, Milliet)"
	label var cov2_exp         "Canton share of national absinthe exports (%, Milliet)"
	label var cov2_total_share "Canton share of national absinthe purchases (%, Milliet)"

	// cov3: Protestant share -> percent
	cap drop cov3
	gen double cov3 = protestant_share * 100
	label var cov3 "Protestant share of Christian pop. (%, 1900, subset denom)"

	// cov_land: log of canton area (km^2) -- stays on log scale, not a share
	capture rename ln_canton_area_km2 cov_land
	// ln_pop_1900: log of 1900 population -- stays on log scale, not a share
	capture drop ln_pop_1900
	gen double ln_pop_1900 = ln(pop_1900)
	label var ln_pop_1900 "Log of 1900 census population"

**# 1.3 Structural-zeros enforcement and missing-data convention
*------------------------------------------------------------------------------*
* The 1907 Swiss yearbook wine table (HSSO Canton1907_wine-data.xlsx) and the
* Milliet 1907 firm-level absinthe annex (BBl 1907 VI 360-361) both follow the
* omit-non-producers convention: cantons that contributed nothing are simply
* absent from the source.  National-total identities confirm omitted cantons
* contributed exactly zero (wine national total = 27,214.8 ha sums across 20
* listed cantons; absinthe purchases total = 5,402,342 kg sums across 8 listed
* producer cantons).  We therefore treat omissions as STRUCTURAL ZEROS where
* the variable is mathematically defined at zero, and as MISSING where the
* variable is undefined (i.e., yield ratio at zero area = 0/0).
*
* Wine non-producers (5 cantons, alpine geography): UR OW NW ZG AI
*   - Levels and shares -> 0 (structural zero)
*   - Yield X4 (hl/ha) -> . (mathematically undefined at zero area)
* Absinthe non-producers (17 cantons, no federal-monopoly distillation): all
*   share vars -> 0 (structural zero per Milliet omit-non-producers convention)
*
* Paper-appendix methodology text lives in the comment block at the bottom of
* this section.  Promote to analysis/documentation/methods/ as a standalone
* .md if/when it grows beyond a paragraph.

* Wine: 5 non-producer cantons (UR, OW, NW, ZG, AI)
*  - Levels and shares = 0 (structural zero; yearbook omit-non-producers convention)
*  - Yield = . (mathematically undefined at zero area)
{
    local wine_zero_cantons "UR OW NW ZG AI"

    foreach v in wine_ha X1 X2_num X3_num X1_share X2_share X3_share {
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
    di "    (yield X4 set to missing; ratio undefined at zero area)"
}

* Absinthe: 17 non-producer cantons -- all share vars = 0 (structural zero;
* Milliet 1907 omit-non-producers convention; national-total identity confirms).
*
* PATTERN: `!inlist(canton_iso, <8 producers>)` instead of
* `inlist(canton_iso, <17 non-producers>)`.  The 17-canton positive list
* exceeds Stata's string-arg inlist cap (var + 9 values = 10 args max) and
* throws r(130) "expression too long".  Negating the 8-producer list is one
* clean call (var + 8 = 9 args, well under cap) and expresses the convention
* positively: "producers are NE GE BS VD SZ ZG FR VS; everyone else = 0".
* See .claude/rules/stata-gotchas.md "inlist() string-arg cap" for context.
*
* (NB: ZG appears in the absinthe producers list but NOT in the wine producers
* list -- ZG had a federal-monopoly distillery but no commercial vineyards in
* 1907.  The two sectoral classifications are independent.)
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
}

* METHODOLOGY FOOTNOTE (for paper appendix; verbatim text)
* -------------------------------------------------------
* Cantons absent from source tables are coded as structural zeros, consistent
* with the omit-non-producers convention of the underlying primary sources.
* For wine, the five alpine cantons (UR, OW, NW, ZG, AI) had zero commercial
* vineyard area in 1907 per HSSO geographic-historical convention; wine yield
* (a ratio) is coded missing for these cantons since 0 over 0 is undefined.
* For absinthe, the seventeen non-listed cantons had no federal-alcohol-
* monopoly distillation industry per the Milliet 1907 annex (BBl 1907 VI
* 360-361); national-total identities (sum of purchases = 5,402,342 kg; sum of
* exports = 320,553 kg) confirm zero contribution.  Milliet's own caveat
* regarding cold-process essence-based producers does not materially affect
* these zeros, since such activity was below federal tracking threshold and
* not relevant to organized-producer political mobilization.


**# 1.4 Define regression spec globals (4 wine variants x 5 cascade cols)
*------------------------------------------------------------------------------*
* 4 wine-variant treatment vars x 5 cascade columns = 20 OLS specs total.
*
* Wine variants ($X_spec*):
*   k=1 -> X1        (wine area per capita; ha per person)
*   k=2 -> X2_share  (wine volume share of national, 1907)
*   k=3 -> X3_share  (wine revenue share of national, 1907)
*   k=4 -> X1_share  (wine area share of national, 1907)
*
* Cascade columns (M1A-style, baseline -> full):
*   c1: treatment only
*   c2: + cov1 (French language share)
*   c3: + cov2_total_share (Milliet absinthe purchases share)
*   c4: + cov3 (Protestant share)
*   c5: + cov_land (ln canton area); + ln_pop_1900 for share specs only
*
* Per-cap specs (k=1) use ctrl_1_*; share specs (k=2,3,4) use ctrl_s_*.
* The two cascade families differ ONLY at col 5: ctrl_s_c5 includes
* ln_pop_1900 as a scale control (shares don't have pop in their construction);
* ctrl_1_c5 omits it because per-cap (X1 = wine_ha / pop_1900) already has
* pop in the LHS denominator, so adding it RHS creates a definitional
* dependency.  Cascade cols 1-4 are identical across families.
*
* NB: priorban is intentionally OMITTED (tabled per coder dispatch); RI 10k
* is deferred to a later inference layer.  This is the primary OLS battery.
{
    global X_spec1 "X1"
    global X_spec2 "X2_share"
    global X_spec3 "X3_share"
    global X_spec4 "X1_share"

    global ctrl_1_c1 ""
    global ctrl_1_c2 "cov1"
    global ctrl_1_c3 "cov1 cov2_total_share"
    global ctrl_1_c4 "cov1 cov2_total_share cov3"
    global ctrl_1_c5 "cov1 cov2_total_share cov3 cov_land"

    global ctrl_s_c1 ""
    global ctrl_s_c2 "cov1"
    global ctrl_s_c3 "cov1 cov2_total_share"
    global ctrl_s_c4 "cov1 cov2_total_share cov3"
    global ctrl_s_c5 "cov1 cov2_total_share cov3 cov_land ln_pop_1900"

    di "  Regression spec globals defined: 4 wine variants x 5 cascade cols"
}


**# 1.5 Robustness-layer derived variables and interactions
*------------------------------------------------------------------------------*
* Transforms and binary/count alternatives to address the absinthe-side
* concentration (17 zeros + NE outlier dominates the share variables).  Also
* the French x absinthe-producer interaction for the cultural-vs-industry
* identification test.
*
* DEVIATIONS FROM DISPATCH (made in service of correctness, not change of intent):
*  - dispatch back-computed kg from share via (cov2_total_share * 5,402,342);
*    we use the RAW purchases_kg95_canton var directly (verified present in
*    cohort_1908.dta via 08 §7.2).  Cleaner, avoids round-trip precision risk,
*    preserves direct provenance to Milliet 1907 source.
*  - dispatch expected n_absinthe_firms; the actual var name (per 08 §7.2) is
*    n_firms_purchases.  Aliased.  08 leaves it missing for the 17 non-producer
*    cantons; we recode missing -> 0 to mirror the structural-zero convention
*    used for cov2_* in §1.3.
{
    * Wine volume in log space.  +1 shift cleanly handles the 5 alpine zeros;
    * non-zero range 4 - 175,000 hl means the shift is numerically negligible
    * for the 20 producer cantons.
    *
    * NOTE: source var wine_volume_canton_hl was renamed to X2_num in §1.2.1
    * (the rename happens before this section runs).  Use X2_num as input.
    cap drop wine_vol_log
    gen double wine_vol_log = ln(1 + X2_num)
    label var wine_vol_log "log(1 + X2_num [wine_volume_canton_hl]), 1907"

    * Absinthe purchases in log space (17 structural zeros + NE outlier).
    cap drop abs_log
    gen double abs_log = ln(1 + purchases_kg95_canton)
    label var abs_log "log(1 + absinthe purchases kg), Milliet 1907 5y total"

    * Absinthe firm count (aliased from 08's n_firms_purchases).  Missing in
    * source for the 17 non-producer cantons; recode to 0 (structural zero)
    * to match the cov2_* convention from §1.3.
    cap drop abs_nfirms
    gen byte abs_nfirms = n_firms_purchases
    replace abs_nfirms = 0 if missing(abs_nfirms)
    label var abs_nfirms "Count of Milliet-listed absinthe firms in canton (alias of n_firms_purchases; missing->0)"

    * Absinthe-producer binary (extensive margin).  Missing-safe construction
    * even though cov2_total_share has no missing after §1.3 (defensive).
    cap drop abs_producer
    gen byte abs_producer = (cov2_total_share > 0 & !missing(cov2_total_share))
    label var abs_producer "Absinthe-trade-interest canton (Milliet any-purchase; headline)"

    * French x absinthe-producer interaction (cultural cleavage x industry presence).
    cap drop fr_x_producer
    gen double fr_x_producer = cov1 * abs_producer
    label var fr_x_producer "Interaction: french_share x absinthe-producer dummy"

    * Globals for robustness-spec invocations
    global X_wine_log    wine_vol_log
    global X_abs_log     abs_log
    global X_abs_nfirms  abs_nfirms
    global X_abs_prod    abs_producer
    global X_fr_x_prod   fr_x_producer

    di as text "  §1.5 derived variables ready:"
    di as text "    wine_vol_log, abs_log, abs_nfirms, abs_producer, fr_x_producer"
}


**# 2. Primary regression battery -- 4 wine variants x 5 cascade cols (20 OLS)
*------------------------------------------------------------------------------*
* HC3 SEs throughout (project methodology rule for OLS at N=25).
* Each estimate stored in memory AND saved to .ster for 10_canton_reg1_tables.do
* to consume independently of in-memory state.

**# 2.0 Standalone-run preamble: confirm §1 outputs are loaded
*------------------------------------------------------------------------------*
* Sentinel = X1 (created in §1.2.1).  If absent, §1.0-§1.4 haven't been run
* (or the cohort was cleared).  Bail with an actionable message rather than
* silently running regressions on a stale/partial state.
*
* SETUP-ONLY MODE: sister scripts (e.g. 12_canton_petition.do) source 09 to
* get the §1.0-§1.5 setup (cohort load + renames + derived vars + spec
* globals + robustness vars) and then run their own regressions with a
* different Y.  Such scripts set $SKIP_09_REGRESSIONS=1 before sourcing 09;
* we exit here before running the §2-§2.8 regression battery.  The setup
* state (X1-X4, cov*, $X_spec*, $ctrl_*, wine_vol_log, abs_log, etc.) is
* fully populated in memory at this point and available to the caller.
{
    if "${SKIP_09_REGRESSIONS}" == "1" {
        di as text _newline "  09: setup complete (§1.0-§1.5); §2-§2.8 SKIPPED per \$SKIP_09_REGRESSIONS=1"
        di as text "  Caller (e.g. 12_canton_petition.do) now has X1-X4, cov*, \$X_spec*, \$ctrl_*, etc."
        exit
    }

    cap confirm variable X1
    if _rc {
        di as error "  §2 needs §1 output (X1, X*_share, cov*) but X1 is absent."
        di as error "  Run §1.0 through §1.4 first (or re-run the whole script)."
        error 459
    }
    if "${X_spec1}" == "" {
        di as error "  §2 needs §1.4 spec globals (\$X_spec1, etc.) but they are unset."
        di as error "  Run §1.4 first (or re-run the whole script)."
        error 459
    }
}


**# 2.1 Run 20 specs and save each to .ster
*------------------------------------------------------------------------------*
{
    cap mkdir "$MyProject/results"
    cap mkdir "$MyProject/results/intermediate"
    cap mkdir "$MyProject/results/intermediate/estimates"

    di as text _newline "  --- Primary battery: 20 OLS specs ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            * Per-cap (k=1) uses ctrl_1_*; share forms (k=2,3,4) use ctrl_s_*
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            * Idempotency: drop any prior estimates store under this name
            cap estimates drop ols_`k'_`j'

            * Run the regression
            qui regress Y1 ${X_spec`k'} `ctrl', vce(hc3)

            * Store in memory for in-session use
            estimates store ols_`k'_`j'

            * Save to .ster for the table-generation script
            estimates save ///
                "$MyProject/results/intermediate/estimates/ols_`k'_`j'.ster", replace

            di as text "  Spec ols`k'.`j': N=" e(N) ", R^2=" %5.3f e(r2) ///
                       ", beta(${X_spec`k'})=" %8.4f _b[${X_spec`k'}]
        }
    }
    di as text _newline "  Battery complete: 20 OLS specs saved to results/intermediate/estimates/"
}


**# 2.5 Fractional logit parallel for the 20 primary OLS specs
*------------------------------------------------------------------------------*
* Same RHS as §2.1, but fracreg logit (Papke-Wooldridge QMLE) instead of
* OLS+HC3.  Saves both the raw fracreg estimates AND the margins-based average
* marginal effects so the table-gen script can present either.
*
* Notes: fracreg requires Y on [0,1] (rescale pct_yes_68 -> Y1_frac).
* fracreg does NOT support vce(hc3); uses vce(robust) (sandwich SEs).
{
    cap mkdir "$MyProject/results/intermediate/estimates_fraclogit"

    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    label var Y1_frac "Yes-share vote 68 on [0,1] scale (for fracreg)"

    di as text _newline "  --- Fractional logit battery: 20 specs + 20 AME stores ---"
    foreach k in 1 2 3 4 {
        forvalues j = 1/5 {
            if `k' == 1 {
                local ctrl "${ctrl_1_c`j'}"
            }
            else {
                local ctrl "${ctrl_s_c`j'}"
            }

            * fracreg
            cap estimates drop fl_`k'_`j'
            qui fracreg logit Y1_frac ${X_spec`k'} `ctrl', vce(robust)
            estimates store fl_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_fraclogit/fl_`k'_`j'.ster", replace

            * Average marginal effect of treatment (OLS-comparable scale)
            cap estimates drop fl_me_`k'_`j'
            qui margins, dydx(${X_spec`k'}) post
            estimates store fl_me_`k'_`j'
            estimates save ///
                "$MyProject/results/intermediate/estimates_fraclogit/fl_me_`k'_`j'.ster", replace

            di as text "  Spec fl`k'.`j': N=" e(N) ", AME(${X_spec`k'})=" %8.4f _b[${X_spec`k'}]
        }
    }
    di as text _newline "  Fraclogit battery complete: 40 stores (20 raw + 20 AME)"
}


**# 2.6 Robustness specs (R1-R6): alt absinthe measures + drop-NE + interaction
*------------------------------------------------------------------------------*
* All at the headline-spec equivalent of cascade col 5 (full share controls).
* Wine variant held at X2_share (volume share) as the working primary; swap to
* whichever wins the horse race if a clear winner emerges.
{
    cap mkdir "$MyProject/results/intermediate/estimates_robust"

    local Xwine "X2_share"

    di as text _newline "  --- Robustness battery: R1-R6 specs ---"

    * R1: n_firms instead of total_share
    cap estimates drop r1_nfirms
    qui regress Y1 `Xwine' cov_land cov1 abs_nfirms cov3 ln_pop_1900, vce(hc3)
    estimates store r1_nfirms
    estimates save "$MyProject/results/intermediate/estimates_robust/r1_nfirms.ster", replace
    di as text "  R1 (n_firms):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R2: producer dummy instead of total_share
    cap estimates drop r2_producer
    qui regress Y1 `Xwine' cov_land cov1 abs_producer cov3 ln_pop_1900, vce(hc3)
    estimates store r2_producer
    estimates save "$MyProject/results/intermediate/estimates_robust/r2_producer.ster", replace
    di as text "  R2 (producer dum):  N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R3: log(1+kg) instead of share
    cap estimates drop r3_abslog
    qui regress Y1 `Xwine' cov_land cov1 abs_log cov3 ln_pop_1900, vce(hc3)
    estimates store r3_abslog
    estimates save "$MyProject/results/intermediate/estimates_robust/r3_abslog.ster", replace
    di as text "  R3 (abs_log):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R4: French x producer interaction (added to primary; abs_producer also as main effect)
    cap estimates drop r4_fr_x_prod
    qui regress Y1 `Xwine' cov_land cov1 cov2_total_share cov3 ln_pop_1900 fr_x_producer abs_producer, vce(hc3)
    estimates store r4_fr_x_prod
    estimates save "$MyProject/results/intermediate/estimates_robust/r4_fr_x_prod.ster", replace
    di as text "  R4 (fr x producer): N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine'] ", beta(fr_x_producer)=" %8.4f _b[fr_x_producer]

    * R5: drop-NE sample (the absinthe heartland; tests if NE's outlier status drives the result)
    cap estimates drop r5_drop_ne
    qui regress Y1 `Xwine' cov_land cov1 cov2_total_share cov3 ln_pop_1900 if canton_iso != "NE", vce(hc3)
    estimates store r5_drop_ne
    estimates save "$MyProject/results/intermediate/estimates_robust/r5_drop_ne.ster", replace
    di as text "  R5 (drop-NE):       N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']

    * R6: log-wine + log-absinthe (both treatment + absinthe control in log space)
    cap estimates drop r6_loglog
    qui regress Y1 wine_vol_log cov_land cov1 abs_log cov3 ln_pop_1900, vce(hc3)
    estimates store r6_loglog
    estimates save "$MyProject/results/intermediate/estimates_robust/r6_loglog.ster", replace
    di as text "  R6 (log-log):       N=" e(N) ", beta(wine_vol_log)=" %8.4f _b[wine_vol_log]

    di as text _newline "  Robustness battery complete: 6 specs saved to estimates_robust/"
}


**# 2.7 Supplemental referenda -- same primary spec, different Y outcomes
*------------------------------------------------------------------------------*
* Wine-corroborating votes: 60, 63, 65 (alcohol/wine-adjacent referenda from
* the 1900-1910 window).  Primary outcome (68) is in §2.1 already.
*
* PRE-FLIGHT NOTE: 08_setup_cohort_1908.do §1 currently extracts only votes
* 67, 68, 69 (per its docstring).  In the current cohort_1908.dta these three
* vote IDs are NOT loaded, so all three skip messages WILL fire.  To populate
* this section, extend 08's vote-extraction list (search for `foreach v in`
* in §1.2 of 08) to include 60, 63, 65 -- then re-run 08, then re-run 09.
{
    cap mkdir "$MyProject/results/intermediate/estimates_altY"

    local Xwine "X2_share"

    di as text _newline "  --- Supplemental referenda (votes 60, 63, 65) ---"
    foreach r_id in 60 63 65 {
        cap confirm variable pct_yes_`r_id'
        if _rc {
            di as error "  pct_yes_`r_id' not in cohort_1908.dta -- extend 08 §1 to pull this vote"
            continue
        }
        cap estimates drop vote_`r_id'
        qui regress pct_yes_`r_id' `Xwine' cov_land cov1 cov2_total_share cov3 ln_pop_1900, vce(hc3)
        estimates store vote_`r_id'
        estimates save "$MyProject/results/intermediate/estimates_altY/vote_`r_id'.ster", replace
        di as text "  Vote `r_id': N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']
    }
}


**# 2.8 Petition signatures as alternative Y outcome
*------------------------------------------------------------------------------*
* Petition = support-only signal (proponents sign); vote = support minus
* opposition.  Different functional form, same underlying preference structure.
*
* PRE-FLIGHT NOTE: petition_signatures_1907.csv does NOT exist in $Absinthe1Data
* or $MyProject/processed/ as of this checkpoint.  Section will hit the
* skip-and-message path.  When the petition data lands:
*   - Place CSV at $Absinthe1Data/petition_signatures_1907.csv (preferred) OR
*     $MyProject/processed/petition_signatures_1907.csv
*   - Required cols: canton_iso, signatures_count
*   - Optional col: eligible_voters_1907 (otherwise falls back to pop_1900)
*   - National total: 167,814 (verification: swissvotes.ch/vote/68.00/
*     zustandekommen-de.pdf p.2 / 1907 Bundesblatt)
{
    cap mkdir "$MyProject/results/intermediate/estimates_altY"

    local petition_csv = ""
    foreach candidate in "$Absinthe1Data/petition_signatures_1907.csv" ///
                         "$MyProject/processed/petition_signatures_1907.csv" {
        cap confirm file "`candidate'"
        if !_rc {
            local petition_csv "`candidate'"
            continue, break
        }
    }
    if "`petition_csv'" == "" {
        di as error _newline "  §2.8 SKIPPED: petition_signatures_1907.csv not found."
        di as error "    Candidates tried:"
        di as error "      \$Absinthe1Data/petition_signatures_1907.csv"
        di as error "      \$MyProject/processed/petition_signatures_1907.csv"
        di as error "    Verification chain when data lands:"
        di as error "      swissvotes.ch/vote/68.00/zustandekommen-de.pdf p.2"
        di as error "      Expected national total = 167,814 signatures across 25 cantons."
    }
    else {
        preserve
            import delimited using "`petition_csv'", varnames(1) clear
            tempfile pet
            save `pet'
        restore
        merge 1:1 canton_iso using `pet', nogenerate keep(match)

        cap drop petition_share
        * Prefer per-eligible-voter if available; else per-1900-pop
        cap confirm variable eligible_voters_1907
        if !_rc {
            gen double petition_share = signatures_count / eligible_voters_1907 * 100
            label var petition_share "Petition signatures as pct of 1907 eligible voters"
        }
        else {
            gen double petition_share = signatures_count / pop_1900 * 100
            label var petition_share "Petition signatures as pct of 1900 population (fallback denom)"
        }

        qui sum signatures_count
        di "  Petition national total = " %9.0fc r(sum) "  (expected ~167,814)"

        local Xwine "X2_share"
        cap estimates drop petition
        qui regress petition_share `Xwine' cov_land cov1 cov2_total_share cov3 ln_pop_1900, vce(hc3)
        estimates store petition
        estimates save "$MyProject/results/intermediate/estimates_altY/petition.ster", replace
        di as text "  Petition spec: N=" e(N) ", beta(`Xwine')=" %8.4f _b[`Xwine']
    }
}


**# 3. Save regression results
*------------------------------------------------------------------------------*
{
    * [Save accumulator dataset and/or LaTeX table.  Typical pattern:
    *    regsave using "$MyProject/results/intermediate/canton_reg1_results.dta", ///
    *        replace addlabel(spec, "<spec_name>", model, "ols")
    *  followed by esttab to a .tex file in results/tables/.
    *  Placeholder until spec battery is defined.]
}


**# 4. Post-credits: codebook + inventory (inventory only on release runs)
*------------------------------------------------------------------------------*
* _codebook_update is upsert-safe (refreshes the existing entry in codebook.md
* in place) -- always fires.
*
* _inventory_append is APPEND-ONLY (no dedupe).  Calling it on every iteration
* run would accumulate duplicate rows in _inventory.xlsx, polluting the shared
* pipeline-state tracker.  So it's gated behind $RUN_POSTCREDITS == "1".
*
* USAGE:
*   - Interactive iteration (default):  do "$MyProject/scripts/09_canton_reg1.do"
*     (RUN_POSTCREDITS unset -> inventory skipped, no _inventory.xlsx churn)
*   - Release / production run:         global RUN_POSTCREDITS = 1
*                                       do "$MyProject/scripts/09_canton_reg1.do"
*     (inventory.xlsx gets the canonical "I ran this and saved X" rows)
{
    * Codebook for the regression-results dataset (if §3 saves one).  Replace
    * the path placeholder once §3 is filled in.
    * _codebook_update using "$MyProject/results/intermediate/canton_reg1_results.dta", ///
    *     script("09_canton_reg1.do")

    if "${RUN_POSTCREDITS}" == "1" {
        * _inventory_append, sheet("datasets") ///
        *     row("created|results/intermediate/canton_reg1_results.dta|`=c(N)'|`=c(k)'|.|09_canton_reg1.do")
        * _inventory_append, sheet("scripts") ///
        *     row("09_canton_reg1.do|.|First canton-level regression battery on cohort_1908.dta [TBD spec details]|.")
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
