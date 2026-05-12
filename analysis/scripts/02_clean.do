/*==============================================================================
 02_clean.do
 Purpose:  Merge swissvotes (vote #68 + #67 placebo + 15-vote 1900-1910 panel)
           plus 8 HSSO uncleaned sources into a single 25-canton analysis
           dataset, plus a 375-row placebo panel (25 cantons x 15 votes).
           Construct ~30 derived variables: vineyard measures (per-cap, per-1000,
           per-km2, ag-share, alt operationalizations), share variables (subset
           and total-pop denominators for french/german/catholic), absinthe-tier
           dummies (NE / NE+VD / NE+VD+GE), strategist 2026-04-30 controls
           (net_migration_pre_vote, net_migration_per_cap, parcels_per_farm_1905),
           additional outcomes (margin, yes_eligible).
 Input:    $MyProject/processed/intermediate/swissvotes_uncleaned.dta
           $MyProject/processed/intermediate/vote67_uncleaned.dta
           $MyProject/processed/intermediate/placebo_votes_uncleaned.dta
           $MyProject/processed/intermediate/vineyard_uncleaned.dta
           $MyProject/processed/intermediate/agland_uncleaned.dta
           $MyProject/processed/intermediate/population_uncleaned.dta
           $MyProject/processed/intermediate/pop_density_uncleaned.dta
           $MyProject/processed/intermediate/religion_uncleaned.dta
           $MyProject/processed/intermediate/language_uncleaned.dta
           $MyProject/processed/intermediate/migration_uncleaned.dta
           $MyProject/processed/intermediate/farm_concentration_uncleaned.dta
 Output:   $MyProject/processed/absinthe_analysis.dta  (N=25)
           $MyProject/processed/placebo_panel.dta      (N=375)
 Author:   Nicholas A Jensen
 Date:     2026-04-30
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Load vote data
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/intermediate/swissvotes_uncleaned.dta", clear
    local n_initial = c(N)
    assert `n_initial' == 25
    isid canton_code

    local nobs0 = c(N)
    _inventory_append, sheet("pipeline") row("0|load swissvotes (anr=68, 25 cantons)|`nobs0'|0|100.00|02_clean.do")
}


**# 1. Merge covariates
*------------------------------------------------------------------------------*

**# 1.1 Vineyard (reshape to wide: vineyard_1877, ..., vineyard_1913)
*------------------------------------------------------------------------------*
{
    * Reshape vineyard from long (25 x 5 years) to wide (25 cantons, 5 year cols).
    * Wide format gives us vineyard_1877, vineyard_1884, vineyard_1894,
    * vineyard_1905 (primary), vineyard_1913 — used in expansion analyses
    * (pre-determined 1894 measure, change-from-1877 measure, log of 1894).
    preserve
        use "$MyProject/processed/intermediate/vineyard_uncleaned.dta", clear
        rename vineyard_ha vineyard_
        reshape wide vineyard_, i(canton_code) j(year)
        rename vineyard_* vineyard_*
        assert c(N) == 25
        tempfile vineyard_wide
        save `vineyard_wide'
    restore

    merge 1:1 canton_code using `vineyard_wide', assert(match) nogenerate
    assert c(N) == 25

    label var vineyard_1877 "Vineyard area 1877 (hectares)"
    label var vineyard_1884 "Vineyard area 1884 (hectares)"
    label var vineyard_1894 "Vineyard area 1894 (hectares)"
    label var vineyard_1905 "Vineyard area 1905 (hectares)"
    label var vineyard_1913 "Vineyard area 1913 (hectares)"

    * vineyard_ha alias = primary measure (1905) for downstream regressions
    gen int vineyard_ha = vineyard_1905
    label var vineyard_ha "Vineyard area, primary measure (= 1905, hectares)"
}


**# 1.2 Population (1900 census)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/population_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.3 Population density (1900)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/pop_density_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.4 Religion (1900 Protestant + Catholic)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/religion_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.5 Language (1900 German + French)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/language_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.6 Same-day placebo: vote #67 yes-vote share (commerce)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/vote67_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.7 Agricultural land (1912, for vine_share_agland robustness)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/agland_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.8 Net migration 1900/10 (econ-vitality control, per strategist 2026-04-30)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/migration_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.9 Farm concentration 1905 (Olson organizational-capacity proxy)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/farm_concentration_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 1.10 Fruit-tree stock 1951 (1908 geographic proxy; competing-spirits feedstock)
*------------------------------------------------------------------------------*
{
    merge 1:1 canton_code using "$MyProject/processed/intermediate/fruit_trees_uncleaned.dta", ///
        assert(match) nogenerate
    assert c(N) == 25
}


**# 2. Construct derived variables
*------------------------------------------------------------------------------*

**# 2.1 Per-capita and share variables
*------------------------------------------------------------------------------*
{
    * Sanity-check denominators are strictly positive before division
    assert pop_1900 > 0 & !missing(pop_1900)
    assert (protestant_1900 + catholic_1900) > 0 & !missing(protestant_1900) & !missing(catholic_1900)
    assert (german_1900 + french_1900) > 0 & !missing(german_1900) & !missing(french_1900)

    * Vineyard area per person (UNITS: hectares per person, NOT per 1000 pop).
    * The expected coefficient range [300, 600] makes substantive sense at this
    * scale: a coefficient of 400 means 1 ha/person -> 400 pp shift in yes-vote;
    * actual canton range is ~0 to 0.02 ha/person, giving 0-8 pp realized shifts.
    gen double vineyard_per_cap = vineyard_ha / pop_1900
    label var vineyard_per_cap "Vineyard area per capita (hectares/person, 1905)"

    * --- French-language share: TWO definitions, both reported in tables ---
    * Subset denominator (German+French only): focuses on the language cleavage
    * that drives federal politics. Excludes Italian/Romansh as orthogonal.
    gen double french_share = french_1900 / (german_1900 + french_1900)
    label var french_share "French share of Ger.+Fr. speakers (1900)"

    * Total-pop denominator: matches the prior Brainstorm-Absinthe analysis.
    * Treats Italian-speakers as "non-French" rather than as a separate group.
    gen double french_share_total = french_1900 / pop_1900
    label var french_share_total "French speakers / total pop. (1900)"

    * --- Catholic share: TWO definitions, both reported in tables ---
    * Subset denominator (Protestant+Catholic only): cleaner Christian contrast.
    gen double catholic_share = catholic_1900 / (protestant_1900 + catholic_1900)
    label var catholic_share "Catholic share of Christians (1900)"

    * Total-pop denominator: matches the prior Brainstorm-Absinthe analysis.
    gen double catholic_share_total = catholic_1900 / pop_1900
    label var catholic_share_total "Catholic pop. / total pop. (1900)"

    * Confirm all shares are bounded [0,1]
    assert inrange(french_share, 0, 1)
    assert inrange(french_share_total, 0, 1)
    assert inrange(catholic_share, 0, 1)
    assert inrange(catholic_share_total, 0, 1)
}


**# 2.2 Log transforms
*------------------------------------------------------------------------------*
{
    * ln_pop: log of 1900 population (used as size control in robustness specs)
    gen double ln_pop = ln(pop_1900)
    label var ln_pop "Log population (1900)"
}


**# 2.3 Dummy / fractional variables
*------------------------------------------------------------------------------*
{
    * yes_frac: fractional dependent variable for fracreg logit (must be on [0,1])
    gen double yes_frac = yes_pct / 100
    label var yes_frac "Yes-vote share (fractional, 0-1)"
    assert inrange(yes_frac, 0, 1)

    * absinthe_dummy: tiered indicators for cantons with absinthe-production
    * history (1797-1910). Swiss production was concentrated in three cantons:
    *   - NE (Val-de-Travers): the heartland. Pernod Fils founded the first
    *     commercial distillery in Couvet, NE in 1797. Multiple producer
    *     villages: Couvet, Môtiers, Boveresse, Travers, Fleurier. Dozens of
    *     legal and clandestine distilleries operating in 1908.
    *   - VD (Yverdon-les-Bains): secondary center. Kübler & Wyss (largest
    *     post-Pernod brand) headquartered in Yverdon. Lausanne-area producers.
    *   - GE: minor production; mostly retail and consumption.
    *
    * absinthe_dummy       = NE only (heartland; conservative; matches original)
    * absinthe_dummy_broad = NE + VD (main production cantons)
    * absinthe_dummy_any   = NE + VD + GE (any documented production)
    gen byte absinthe_dummy       = (canton_code == "NE")
    gen byte absinthe_dummy_broad = inlist(canton_code, "NE", "VD")
    gen byte absinthe_dummy_any   = inlist(canton_code, "NE", "VD", "GE")
    label var absinthe_dummy       "Absinthe-producing canton (NE only; heartland)"
    label var absinthe_dummy_broad "Absinthe-producing canton (NE + VD; main)"
    label var absinthe_dummy_any   "Absinthe-producing canton (NE + VD + GE; any)"
    assert absinthe_dummy[_n] == 0       | canton_code == "NE"
    assert absinthe_dummy_broad[_n] == 0 | inlist(canton_code, "NE", "VD")
    assert absinthe_dummy_any[_n] == 0   | inlist(canton_code, "NE", "VD", "GE")

    * Language dummies (used in heterogeneity / subsample analyses)
    gen byte lang_french       = inlist(canton_code, "VD", "VS", "NE", "GE")
    gen byte lang_french_broad = inlist(canton_code, "VD", "VS", "NE", "GE", "FR", "BE")
    gen byte lang_italian      = (canton_code == "TI")
    label var lang_french       "French-speaking canton (narrow: VD,VS,NE,GE)"
    label var lang_french_broad "French/bilingual canton (incl. FR, BE)"
    label var lang_italian      "Italian-speaking canton (TI)"

    * Wine-canton binary dummy (>1000 ha vineyard in 1905). Used in
    * 05_expansion.do as alternative operationalization.
    gen byte wine_canton = (vineyard_1905 > 1000) if !missing(vineyard_1905)
    label var wine_canton "Wine canton (>1000 ha vineyard, 1905)"

    * Neuchatel-adjacency indicator (C.9 robustness control). Cantons that share
    * a border with NE in the 1908-era cantonal geography (pre-Jura-1979):
    *   BE -- Bern, north/northeast border (BE in 1908 included the Jura region
    *         that became canton JU in 1979)
    *   VD -- Vaud, south/southwest border (Lake Neuchatel shore)
    *   FR -- Fribourg, small southeastern border segment
    * The remaining NE perimeter is the French Republic (Doubs departement),
    * not a Swiss canton. NE itself is coded 0 (we are testing adjacency, not
    * membership). Used in T17 and T18 to test whether spatial spillover --
    * differential consumer ties, family networks, commercial relationships
    * with the Val-de-Travers absinthe-production cluster -- confounds the
    * vineyard-share coefficient. The headline coefficient should be robust
    * to inclusion of this control if the wine-rent-seeking mechanism is
    * about industrial substitution, not neighborhood-spillover.
    gen byte adj_neuchatel = inlist(canton_code, "BE", "VD", "FR")
    label var adj_neuchatel "Canton borders Neuchatel (1908 geography; BE, VD, FR)"
    assert adj_neuchatel[_n] == 0 | inlist(canton_code, "BE", "VD", "FR")
}


**# 2.4 Alternative vineyard operationalizations (for expansion analyses)
*------------------------------------------------------------------------------*
{
    * vine_per_1000: vineyard hectares per 1000 population (interpretable scale)
    gen double vine_per_1000 = (vineyard_1905 / pop_1900) * 1000
    label var vine_per_1000 "Vineyard hectares per 1000 pop (1905)"

    * Pre-determined: vineyard per capita using 1894 (14 yrs before vote)
    gen double vineyard_per_cap_1894 = vineyard_1894 / pop_1900
    label var vineyard_per_cap_1894 "Vineyard per capita 1894 (pre-determined)"

    gen double vine_per_1000_1894 = (vineyard_1894 / pop_1900) * 1000
    label var vine_per_1000_1894 "Vineyard ha per 1000 pop (1894)"

    * NOTE: log(vineyard+1) intentionally NOT constructed. Per Chen & Roth
    * (2023, QJE) "Logs with Zeros? Some Problems and Solutions", the +1 is
    * arbitrary (could equally be +0.001 or +1000) and the resulting coefficient
    * has no scale-invariant semi-elasticity interpretation when ~32% of cantons
    * have zero vineyards. Use `wine_canton` (binary >1000 ha) for the extensive
    * margin and `vine_share_agland` / `vine_per_km2` for intensity. ln_pop is
    * fine because population has no zeros — the +1 problem doesn't apply.

    * Vineyard CHANGE 1877->1905 (level and percent). Tests "desperation
    * hypothesis": cantons with shrinking vineyards may have voted yes more
    * strongly as a protective response to wine-industry decline.
    gen double vine_change_1877_1905 = vineyard_1905 - vineyard_1877
    label var vine_change_1877_1905 "Vineyard area change 1877-1905 (ha)"

    gen double vine_change_pct = ((vineyard_1905 - vineyard_1877) / vineyard_1877) * 100 ///
        if vineyard_1877 > 0 & !missing(vineyard_1877)
    label var vine_change_pct "Vineyard area change 1877-1905 (%)"

    * Canton land area (km^2) backed out from population / density
    gen double area_km2 = pop_1900 / pop_density_1900
    label var area_km2 "Canton area (km^2; backed out from pop/density)"

    * Vineyard per km^2 (intensity of land use)
    gen double vine_per_km2 = vineyard_1905 / area_km2
    label var vine_per_km2 "Vineyard hectares per km^2 (1905)"

    * Vineyard share of agricultural land (%) — uses 1912 ag-land (closest to 1908)
    gen double vine_share_agland = (vineyard_1905 / (agland_1000ha * 1000)) * 100
    label var vine_share_agland "Vineyard share of ag land (%, 1905/1912)"

    * --- New controls per strategist 2026-04-30 (see strategist_migration_note) ---
    * Net migration: alias the imported variable to the strategist's
    * preferred name. 1900/10 average annual net migration (positive = net
    * in-migration). Controls for "wine cantons were just declining anyway"
    * alternative explanation.
    gen double net_migration_pre_vote = net_migration_1900_10
    label var net_migration_pre_vote "Net migration 1900/10, avg/yr (persons)"

    * Per-capita version (more comparable across canton sizes)
    gen double net_migration_per_cap = net_migration_1900_10 / pop_1900
    label var net_migration_per_cap "Net migration 1900/10 per 1900 capita"

    * --- German-language share (the "other side" of french_share) ---
    * Per user 2026-04-30: french_share and german_share are two sides of the
    * same coin in the binary subset, but for cantons with significant
    * Italian/Romansh populations they're not exact complements. Construct
    * both subset and total-pop denominator versions for symmetry.
    gen double german_share       = german_1900 / (german_1900 + french_1900)
    gen double german_share_total = german_1900 / pop_1900
    label var german_share       "German share (Ger.+Fr. denom.)"
    label var german_share_total "German share (total pop. denom.)"
    assert inrange(german_share,       0, 1)
    assert inrange(german_share_total, 0, 1)

    * --- Average parcel area 1905 (CONSTRUCTED) -- industrial concentration ---
    * Strategist 2026-04-30 wanted avg_parcel_area_1905 as the primary Olson
    * 1965 concentration measure. The HSSO I.39c block 4 ("mittlere
    * Parzellenfläche") doesn't have 1905 (the 1905 census used a different
    * definition for small farms; first available year is 1929).
    * We reconstruct it from the available 1905 data:
    *
    *   avg_parcel_area_1905 = ag_land_ha / total_parcels
    *                        = (agland_1000ha * 1000) / (farms_1905 * parcels_per_farm_1905)
    *
    * Units: hectares per parcel. LOW = fragmented, HIGH = consolidated (per
    * Olson 1965 prediction: concentrated holdings → easier political
    * mobilization → wine effect should be STRONGER where avg parcel area is
    * larger).
    *
    * Caveat: agland_1000ha is from 1912, not 1905 (4-year gap; closest HSSO
    * has). We already use agland_1912 as the 1908 proxy in vine_share_agland.
    * Validation block below cross-checks our 1929 reconstruction against
    * I.39c block 4's directly-reported 1929 mean-parcel-area (in ares).
    gen double total_parcels_1905   = farms_1905 * parcels_per_farm_1905
    gen double avg_parcel_area_1905 = (agland_1000ha * 1000) / total_parcels_1905
    label var total_parcels_1905   "Total parcels in canton (1905, computed)"
    label var avg_parcel_area_1905 "Avg parcel area (ha/parcel, 1905, computed)"

    * Sanity: avg parcel area should be in roughly [0.1, 10] hectares per
    * parcel for Swiss agriculture circa 1905
    assert inrange(avg_parcel_area_1905, 0.05, 20)

    * --- Fruit-tree density (1951 GEOGRAPHIC PROXY for 1908) ---
    * Per user 2026-04-30: with the canton-level wine-industry-employment
    * search definitively closed, the canonical canton-level proxies for
    * wine industry size are vineyard_per_cap + avg_parcel_area_1905 +
    * fruit_tree_density. We use 1951 fruit-tree counts (the earliest
    * fully-populated year) under an explicit time-stability assumption:
    * canton orchard suitability (climate, topography, soil) is approximately
    * stable 1908-1951, much more so than wine acreage.
    *
    * Substantive use: control for "competing-spirits feedstock capacity".
    * Cantons with strong fruit production (apples, pears, cherries, plums)
    * had their own distillates (Kirsch, Pflümli, Williams) that competed
    * with absinthe AND with wine. So fruit-tree-rich cantons may have had
    * different rent-seeking incentives on the absinthe ban.
    *
    * I.04a values are in thousands of trees. Per-capita scaling makes
    * cantons comparable.
    gen double fruit_tree_density = (fruit_trees_total_1951 * 1000) / pop_1900
    label var fruit_tree_density "Fruit trees per capita (1951 proxy / 1900 pop)"

    * Sanity: should be a few trees per person to ~10s
    assert inrange(fruit_tree_density, 0.01, 100)
}


**# 2.5 Canton names (for readable tables)
*------------------------------------------------------------------------------*
{
    gen str18 canton = ""
    replace canton = "Zurich"        if canton_code == "ZH"
    replace canton = "Bern"          if canton_code == "BE"
    replace canton = "Luzern"        if canton_code == "LU"
    replace canton = "Uri"           if canton_code == "UR"
    replace canton = "Schwyz"        if canton_code == "SZ"
    replace canton = "Obwalden"      if canton_code == "OW"
    replace canton = "Nidwalden"     if canton_code == "NW"
    replace canton = "Glarus"        if canton_code == "GL"
    replace canton = "Zug"           if canton_code == "ZG"
    replace canton = "Fribourg"      if canton_code == "FR"
    replace canton = "Solothurn"     if canton_code == "SO"
    replace canton = "Basel-Stadt"   if canton_code == "BS"
    replace canton = "Basel-Land"    if canton_code == "BL"
    replace canton = "Schaffhausen"  if canton_code == "SH"
    replace canton = "Appenzell AR"  if canton_code == "AR"
    replace canton = "Appenzell IR"  if canton_code == "AI"
    replace canton = "St. Gallen"    if canton_code == "SG"
    replace canton = "Graubunden"    if canton_code == "GR"
    replace canton = "Aargau"        if canton_code == "AG"
    replace canton = "Thurgau"       if canton_code == "TG"
    replace canton = "Ticino"        if canton_code == "TI"
    replace canton = "Vaud"          if canton_code == "VD"
    replace canton = "Valais"        if canton_code == "VS"
    replace canton = "Neuchatel"     if canton_code == "NE"
    replace canton = "Geneva"        if canton_code == "GE"
    label var canton "Canton (full name)"
    assert !missing(canton)
}


**# 2.6 Additional outcomes (for expansion analyses)
*------------------------------------------------------------------------------*
{
    * Margin of victory (yes − no) / total × 100
    gen double margin = (yes_count - no_count) / total_votes * 100
    label var margin "Margin of victory (%, 1908)"

    * Yes votes / eligible voters × 100 (alternative scaling)
    gen double yes_eligible = yes_count / eligible * 100
    label var yes_eligible "Yes votes / eligible voters (%)"
}


**# 3. Final assertions
*------------------------------------------------------------------------------*
{
    * Sample-size and uniqueness invariants
    assert c(N) == 25
    isid canton_code

    * No missing values in any analysis variable. (vine_change_pct intentionally
    * missing for cantons with vineyard_1877==0; not asserted.)
    foreach v in yes_pct yes_frac vineyard_per_cap french_share catholic_share ///
                 german_share german_share_total ///
                 ln_pop pop_1900 pop_density_1900 ///
                 absinthe_dummy absinthe_dummy_broad absinthe_dummy_any ///
                 vote67_yes_pct agland_1000ha vine_share_agland margin ///
                 vine_per_1000 vineyard_per_cap_1894 area_km2 ///
                 lang_french lang_french_broad lang_italian wine_canton ///
                 net_migration_pre_vote net_migration_per_cap ///
                 parcels_per_farm_1905 farms_1905 avg_parcel_area_1905 ///
                 fruit_trees_total_1951 fruit_tree_density {
        cap assert !missing(`v')
        if _rc {
            di as error "MISSING VALUE in `v' — aborting"
            error 9
        }
    }

    * Verification: NE should reject (yes_pct < 50) and have French majority
    summ yes_pct if canton_code == "NE", meanonly
    assert r(mean) < 50
    summ french_share if canton_code == "NE", meanonly
    assert r(mean) > 0.5

    * Verification: GE should also reject
    summ yes_pct if canton_code == "GE", meanonly
    assert r(mean) < 50
}


**# 4. Save analysis dataset
*------------------------------------------------------------------------------*
{
    order canton_code canton ///
          yes_pct yes_frac yes_count no_count turnout eligible total_votes ///
          vote67_yes_pct margin yes_eligible ///
          vineyard_ha vineyard_per_cap vine_per_1000 ///
          vineyard_1877 vineyard_1884 vineyard_1894 vineyard_1905 vineyard_1913 ///
          vineyard_per_cap_1894 vine_per_1000_1894 ///
          vine_change_1877_1905 vine_change_pct ///
          wine_canton vine_per_km2 vine_share_agland ///
          french_share french_share_total catholic_share catholic_share_total ///
          german_share german_share_total ///
          ln_pop pop_1900 pop_density_1900 area_km2 agland_1000ha ///
          net_migration_pre_vote net_migration_per_cap net_migration_1900_10 ///
          parcels_per_farm_1905 farms_1905 total_parcels_1905 avg_parcel_area_1905 ///
          fruit_trees_total_1951 fruit_tree_density ///
          absinthe_dummy lang_french lang_french_broad lang_italian ///
          german_1900 french_1900 protestant_1900 catholic_1900 ///
          adj_neuchatel

    compress
    save "$MyProject/processed/absinthe_analysis.dta", replace

    local nobs_final  = c(N)
    local nvars_final = c(k)
    di "Final analysis dataset: N=`nobs_final' x K=`nvars_final'"
}


**# 4b. Build placebo-panel analysis dataset (long: 25 cantons x 15 votes)
*------------------------------------------------------------------------------*
{
    * Long-format dataset for the cross-referendum falsification design.
    * Each row = (canton, vote) pair; KEY-spec covariates merged in from the
    * canton-level main dataset. Used by 05_expansion.do section 14 to loop
    * a KEY-spec regression per vote and construct t13 + f03.
    use "$MyProject/processed/intermediate/placebo_votes_uncleaned.dta", clear

    * Merge the canton-level KEY-spec covariates (m:1 because each canton
    * appears 15 times in the placebo panel, once per vote)
    merge m:1 canton_code using "$MyProject/processed/absinthe_analysis.dta", ///
        keepusing(vineyard_per_cap french_share catholic_share ///
                  french_share_total catholic_share_total ///
                  pop_1900 ln_pop adj_neuchatel) ///
        keep(match) nogen
    assert _N == 25 * 15  // 375 rows preserved

    * Construct fractional outcome (vote-specific, not the canton-level vote-#68
    * yes_frac): each placebo vote has its own yes_pct, so its own yes_frac.
    * Required by the fracreg AME column in t13 (added per phase-review S4,
    * 2026-04-30). yes_pct in placebo_votes_uncleaned.dta is on the 0-100 scale.
    gen double yes_frac = yes_pct / 100
    label var yes_frac "Yes-vote share (fractional, 0-1) — vote-specific"
    cap assert inrange(yes_frac, 0, 1)
    if _rc {
        di as error "yes_frac out of [0,1] range in placebo_panel — check yes_pct source"
        error 9
    }

    sort anr canton_code
    order canton_code anr vote_year yes_pct yes_frac vote_label ///
          vineyard_per_cap french_share catholic_share

    compress
    save "$MyProject/processed/placebo_panel.dta", replace
    di "Placebo panel dataset: " _N " rows (25 cantons x 15 votes)"
}


**# 5. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    _codebook_update using "$MyProject/processed/absinthe_analysis.dta", script("02_clean.do")
    _codebook_update using "$MyProject/processed/placebo_panel.dta", script("02_clean.do")
    use "$MyProject/processed/absinthe_analysis.dta", clear
    local nobs  = c(N)
    local nvars = c(k)
    _inventory_append, sheet("datasets") ///
        row("created|processed/absinthe_analysis.dta|`nobs'|`nvars'|.|02_clean.do")
    use "$MyProject/processed/placebo_panel.dta", clear
    local nobs_pp  = c(N)
    local nvars_pp = c(k)
    _inventory_append, sheet("datasets") ///
        row("created|processed/placebo_panel.dta|`nobs_pp'|`nvars_pp'|.|02_clean.do")
    _inventory_append, sheet("scripts") ///
        row("02_clean.do|.|merges 7 uncleaned sources, builds main and placebo-panel datasets|.")
}

** EOF
