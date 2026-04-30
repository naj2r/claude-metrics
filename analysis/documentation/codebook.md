# Project Codebook

_Auto-updated by _codebook_update.ado_

## Suffix conventions

- _cat — categorical
- _mz — missing-recoded-to-zero
- _mm — missing-recoded-to-mean
- _miss — imputation indicator
- _ln — natural log
- _lnp1 — natural log of (x+1)

## Datasets




































































<!-- codebook:processed/intermediate/canton_crosswalk.dta:start -->
### processed/intermediate/canton_crosswalk.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 25, vars = 2**

| Variable | Type | Format | Label |
|---|---|---|---|
| col_letter | str2 | %9s | Excel column letter in HSSO file |
| canton_code | str2 | %9s | Canton (2-letter code, 1908) |

<!-- codebook:processed/intermediate/canton_crosswalk.dta:end -->

<!-- codebook:processed/intermediate/swissvotes_uncleaned.dta:start -->
### processed/intermediate/swissvotes_uncleaned.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 25, vars = 7**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| yes_count | long | %12.0g | Yes votes (1908 absinthe ban) |
| no_count | int | %12.0g | No votes (1908 absinthe ban) |
| yes_pct | float | %9.0g | Yes-vote share (%, 1908 absinthe ban) |
| turnout | float | %9.0g | Turnout (%, 1908 absinthe ban) |
| eligible | long | %12.0g | Eligible voters (1908) |
| total_votes | long | %12.0g | Total ballots cast (1908) |

<!-- codebook:processed/intermediate/swissvotes_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/vote67_uncleaned.dta:start -->
### processed/intermediate/vote67_uncleaned.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 25, vars = 2**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| vote67_yes_pct | float | %9.0g | Yes-vote share (%, vote #67 commerce, same-day placebo) |

<!-- codebook:processed/intermediate/vote67_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/placebo_votes_uncleaned.dta:start -->
### processed/intermediate/placebo_votes_uncleaned.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 375, vars = 7**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| anr | byte | %9.0g | Vote number (swissvotes anr) |
| vote_year | int | %8.0g | Year of vote |
| yes_pct | float | %9.0g | Yes-vote share (%, this vote, this canton) |
| vote_label | str80 | %80s | Short title of vote (English if available) |
| rechtsform | byte | %8.0g | Vote type: 1=mandatory, 2=optional, 3=initiative, 4=counter |
| annahme | byte | %8.0g | 1 if vote passed nationally, 0 if rejected |

<!-- codebook:processed/intermediate/placebo_votes_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/vineyard_uncleaned.dta:start -->
### processed/intermediate/vineyard_uncleaned.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 125, vars = 3**

| Variable | Type | Format | Label |
|---|---|---|---|
| year | int | %10.0g | Year |
| canton_code | str2 | %9s | Canton (2-letter code) |
| vineyard_ha | double | %10.0g | Vineyard area (hectares) |

<!-- codebook:processed/intermediate/vineyard_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/agland_uncleaned.dta:start -->
### processed/intermediate/agland_uncleaned.dta

_Updated: 30 Apr 2026 18:10:40 by 01_import.do_

**N = 25, vars = 2**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| agland_1000ha | float | %9.0g | Productive ag+alpine land (1000 ha, 1912) |

<!-- codebook:processed/intermediate/agland_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/population_uncleaned.dta:start -->
### processed/intermediate/population_uncleaned.dta

_Updated: 30 Apr 2026 18:10:41 by 01_import.do_

**N = 25, vars = 2**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| pop_1900 | float | %9.0g | Resident population (persons, 1900 census) |

<!-- codebook:processed/intermediate/population_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/pop_density_uncleaned.dta:start -->
### processed/intermediate/pop_density_uncleaned.dta

_Updated: 30 Apr 2026 18:10:41 by 01_import.do_

**N = 25, vars = 2**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| pop_density_1900 | float | %9.0g | Population density (persons/km^2, 1900; excl. lake area) |

<!-- codebook:processed/intermediate/pop_density_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/religion_uncleaned.dta:start -->
### processed/intermediate/religion_uncleaned.dta

_Updated: 30 Apr 2026 18:10:41 by 01_import.do_

**N = 25, vars = 3**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| protestant_1900 | float | %9.0g | Protestant population (persons, 1900 census) |
| catholic_1900 | float | %9.0g | Catholic population (Roman + Old Catholic, 1900 census) |

<!-- codebook:processed/intermediate/religion_uncleaned.dta:end -->

<!-- codebook:processed/intermediate/language_uncleaned.dta:start -->
### processed/intermediate/language_uncleaned.dta

_Updated: 30 Apr 2026 18:10:41 by 01_import.do_

**N = 25, vars = 3**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| german_1900 | float | %9.0g | German speakers (persons, 1900 census) |
| french_1900 | float | %9.0g | French speakers (persons, 1900 census) |

<!-- codebook:processed/intermediate/language_uncleaned.dta:end -->

<!-- codebook:processed/absinthe_analysis.dta:start -->
### processed/absinthe_analysis.dta

_Updated: 30 Apr 2026 18:10:41 by 02_clean.do_

**N = 25, vars = 46**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| canton | str12 | %12s | Canton (full name) |
| yes_pct | float | %9.0g | Yes-vote share (%, 1908 absinthe ban) |
| yes_frac | double | %10.0g | Yes-vote share (fractional, 0-1) |
| yes_count | long | %12.0g | Yes votes (1908 absinthe ban) |
| no_count | int | %12.0g | No votes (1908 absinthe ban) |
| turnout | float | %9.0g | Turnout (%, 1908 absinthe ban) |
| eligible | long | %12.0g | Eligible voters (1908) |
| total_votes | long | %12.0g | Total ballots cast (1908) |
| vote67_yes_pct | float | %9.0g | Yes-vote share (%, vote #67 commerce, same-day placebo) |
| margin | double | %10.0g | Margin of victory (%, 1908) |
| yes_eligible | double | %10.0g | Yes votes / eligible voters (%) |
| vineyard_ha | int | %8.0g | Vineyard area, primary measure (= 1905, hectares) |
| vineyard_per_cap | double | %10.0g | Vineyard area per capita (hectares/person, 1905) |
| vine_per_1000 | double | %10.0g | Vineyard hectares per 1000 pop (1905) |
| vineyard_1877 | int | %10.0g | Vineyard area 1877 (hectares) |
| vineyard_1884 | int | %10.0g | Vineyard area 1884 (hectares) |
| vineyard_1894 | double | %10.0g | Vineyard area 1894 (hectares) |
| vineyard_1905 | int | %10.0g | Vineyard area 1905 (hectares) |
| vineyard_1913 | int | %10.0g | Vineyard area 1913 (hectares) |
| vineyard_per_cap_1894 | double | %10.0g | Vineyard per capita 1894 (pre-determined) |
| vine_per_1000_1894 | double | %10.0g | Vineyard ha per 1000 pop (1894) |
| vine_change_1877_1905 | int | %10.0g | Vineyard area change 1877-1905 (ha) |
| vine_change_pct | double | %10.0g | Vineyard area change 1877-1905 (%) |
| wine_canton | byte | %8.0g | Wine canton (>1000 ha vineyard, 1905) |
| vine_per_km2 | double | %10.0g | Vineyard hectares per km^2 (1905) |
| vine_share_agland | double | %10.0g | Vineyard share of ag land (%, 1905/1912) |
| french_share | double | %10.0g | French share of Ger.+Fr. speakers (1900) |
| french_share_total | double | %10.0g | French speakers / total pop. (1900) |
| catholic_share | double | %10.0g | Catholic share of Christians (1900) |
| catholic_share_total | double | %10.0g | Catholic pop. / total pop. (1900) |
| ln_pop | double | %10.0g | Log population (1900) |
| pop_1900 | float | %9.0g | Resident population (persons, 1900 census) |
| pop_density_1900 | float | %9.0g | Population density (persons/km^2, 1900; excl. lake area) |
| area_km2 | double | %10.0g | Canton area (km^2; backed out from pop/density) |
| agland_1000ha | float | %9.0g | Productive ag+alpine land (1000 ha, 1912) |
| absinthe_dummy | byte | %8.0g | Absinthe-producing canton (NE only; heartland) |
| lang_french | byte | %8.0g | French-speaking canton (narrow: VD,VS,NE,GE) |
| lang_french_broad | byte | %8.0g | French/bilingual canton (incl. FR, BE) |
| lang_italian | byte | %8.0g | Italian-speaking canton (TI) |
| german_1900 | float | %9.0g | German speakers (persons, 1900 census) |
| french_1900 | float | %9.0g | French speakers (persons, 1900 census) |
| protestant_1900 | float | %9.0g | Protestant population (persons, 1900 census) |
| catholic_1900 | float | %9.0g | Catholic population (Roman + Old Catholic, 1900 census) |
| absinthe_dummy_broad | byte | %8.0g | Absinthe-producing canton (NE + VD; main) |
| absinthe_dummy_any | byte | %8.0g | Absinthe-producing canton (NE + VD + GE; any) |

<!-- codebook:processed/absinthe_analysis.dta:end -->

<!-- codebook:processed/placebo_panel.dta:start -->
### processed/placebo_panel.dta

_Updated: 30 Apr 2026 18:10:41 by 02_clean.do_

**N = 375, vars = 14**

| Variable | Type | Format | Label |
|---|---|---|---|
| canton_code | str2 | %9s | Canton (2-letter code) |
| anr | byte | %9.0g | Vote number (swissvotes anr) |
| vote_year | int | %8.0g | Year of vote |
| yes_pct | float | %9.0g | Yes-vote share (%, this vote, this canton) |
| vote_label | str80 | %80s | Short title of vote (English if available) |
| vineyard_per_cap | double | %10.0g | Vineyard area per capita (hectares/person, 1905) |
| french_share | double | %10.0g | French share of Ger.+Fr. speakers (1900) |
| catholic_share | double | %10.0g | Catholic share of Christians (1900) |
| rechtsform | byte | %8.0g | Vote type: 1=mandatory, 2=optional, 3=initiative, 4=counter |
| annahme | byte | %8.0g | 1 if vote passed nationally, 0 if rejected |
| french_share_total | double | %10.0g | French speakers / total pop. (1900) |
| catholic_share_total | double | %10.0g | Catholic pop. / total pop. (1900) |
| ln_pop | double | %10.0g | Log population (1900) |
| pop_1900 | float | %9.0g | Resident population (persons, 1900 census) |

<!-- codebook:processed/placebo_panel.dta:end -->

<!-- codebook:results/intermediate/regressions.dta:start -->
### results/intermediate/regressions.dta

_Updated: 30 Apr 2026 18:11:39 by 03_regress.do_

**N = 140, vars = 11**

| Variable | Type | Format | Label |
|---|---|---|---|
| var | str20 | %20s | Variable |
| coef | float | %9.0g | Coefficient |
| stderr | float | %9.0g | Standard error |
| tstat | float | %9.0g | t-statistic |
| pval | float | %9.0g | Two-tailed p-value |
| N | byte | %10.0g | Number of observations |
| r2 | float | %9.0g | R-squared |
| _id | byte | %9.0g | Regression ID number |
| spec | str21 | %21s |  |
| model | str11 | %11s | Model name |
| dropped | str2 | %9s |  |

<!-- codebook:results/intermediate/regressions.dta:end -->

<!-- codebook:results/intermediate/regressions_expansion.dta:start -->
### results/intermediate/regressions_expansion.dta

_Updated: 30 Apr 2026 18:11:44 by 05_expansion.do_

**N = 178, vars = 10**

| Variable | Type | Format | Label |
|---|---|---|---|
| var | str21 | %21s | Variable |
| coef | float | %9.0g | Coefficient |
| stderr | float | %9.0g | Standard error |
| tstat | float | %9.0g | t-statistic |
| pval | float | %9.0g | Two-tailed p-value |
| N | byte | %10.0g | Number of observations |
| r2 | float | %9.0g | R-squared |
| _id | byte | %9.0g | Regression ID number |
| spec | str22 | %22s |  |
| model | str3 | %9s | Model name |

<!-- codebook:results/intermediate/regressions_expansion.dta:end -->

