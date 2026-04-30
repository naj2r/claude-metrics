************
* PROGRAM: clean_vars.ado
* PURPOSE: formats the names of the variables reported in the tables
************

program define clean_vars, nclass

	* Program input: varname that contains the variable names
	syntax varname

	* --- Main analysis variables ---
	replace `varlist' = "Vineyard per capita (ha/person)"   if `varlist'=="vineyard_per_cap"
	replace `varlist' = "French share (Ger.+Fr.)"           if `varlist'=="french_share"
	replace `varlist' = "French share (total pop.)"         if `varlist'=="french_share_total"
	replace `varlist' = "Catholic share (Christians)"       if `varlist'=="catholic_share"
	replace `varlist' = "Catholic share (total pop.)"       if `varlist'=="catholic_share_total"
	replace `varlist' = "Log population (1900)"             if `varlist'=="ln_pop"
	replace `varlist' = "Absinthe canton (NE)"              if `varlist'=="absinthe_dummy"
	replace `varlist' = "Absinthe canton (NE+VD)"           if `varlist'=="absinthe_dummy_broad"
	replace `varlist' = "Absinthe canton (NE+VD+GE)"        if `varlist'=="absinthe_dummy_any"

	* --- Expansion-analysis variables (05_expansion.do) ---
	replace `varlist' = "Vineyard per cap. 1894 (pre-det.)" if `varlist'=="vineyard_per_cap_1894"
	replace `varlist' = "Vineyard per 1000 pop."            if `varlist'=="vine_per_1000"
	replace `varlist' = "Vineyard area 1905 (ha)"           if `varlist'=="vineyard_1905"
	replace `varlist' = "Wine canton (>1000 ha)"            if `varlist'=="wine_canton"
	replace `varlist' = "Vineyard per km^2"                 if `varlist'=="vine_per_km2"
	replace `varlist' = "Vineyard share of ag land (\\%)"   if `varlist'=="vine_share_agland"
	replace `varlist' = "Vineyard change 1877-1905 (\\%)"   if `varlist'=="vine_change_pct"
	replace `varlist' = "Vineyard x French share"           if `varlist'=="vine_x_french"
	replace `varlist' = "Vineyard x Catholic share"         if `varlist'=="vine_x_catholic"
	replace `varlist' = "Vineyard x log pop."               if `varlist'=="vine_x_lnpop"
	replace `varlist' = "Vineyard x German share"           if `varlist'=="vine_x_german"
	replace `varlist' = "Vineyard x parcels/farm"           if `varlist'=="vine_x_parcels"

	* --- New controls per strategist 2026-04-30 ---
	replace `varlist' = "German share (Ger.+Fr.)"           if `varlist'=="german_share"
	replace `varlist' = "German share (total pop.)"         if `varlist'=="german_share_total"
	replace `varlist' = "Net migration 1900/10 (avg/yr)"    if `varlist'=="net_migration_pre_vote"
	replace `varlist' = "Net migration 1900/10 per capita"  if `varlist'=="net_migration_per_cap"
	replace `varlist' = "Parcels per farm (1905)"           if `varlist'=="parcels_per_farm_1905"

	replace `varlist' = "Constant"                          if `varlist'=="_cons"

end

** EOF
