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
	replace `varlist' = "Avg parcel area, ha (1905)"        if `varlist'=="avg_parcel_area_1905"
	replace `varlist' = "Vineyard x avg parcel area"        if `varlist'=="vine_x_parcel_area"
	replace `varlist' = "Number of farms (1905)"            if `varlist'=="farms_1905"
	replace `varlist' = "Fruit trees per cap (1951 proxy)"  if `varlist'=="fruit_tree_density"
	replace `varlist' = "Vineyard x fruit-tree density"     if `varlist'=="vine_x_fruit"

	* --- Workshop pipeline variables (Phase A'', 2026-05-22) ---
	*     Match labels with 14_workshop_summary_stats.do labelvar block.
	replace `varlist' = "Yes-vote, Vote \#68 (absinthe ban)"   if `varlist'=="Y1"
	replace `varlist' = "Yes-vote fraction (0-1)"              if `varlist'=="Y1_frac"
	replace `varlist' = "Yes-vote, Vote \#67 (commerce)"       if `varlist'=="pct_yes_67"
	replace `varlist' = "Yes-vote, Vote \#69 (water power)"    if `varlist'=="pct_yes_69"
	replace `varlist' = "Petition signatures per 100 eligible" if `varlist'=="pet_per_eligible"
	replace `varlist' = "Petition signature fraction (0-1)"    if `varlist'=="pet_frac"
	replace `varlist' = "Turnout, Vote \#68"                   if `varlist'=="turnout_68"
	replace `varlist' = "Wine area per 1,000 pop. (ha)"        if `varlist'=="X1"
	replace `varlist' = "Wine area, national share (\%)"       if `varlist'=="X1_share"
	replace `varlist' = "Wine volume, national share (\%)"     if `varlist'=="X2_share"
	replace `varlist' = "Wine revenue, national share (\%)"    if `varlist'=="X3_share"
	replace `varlist' = "White wine revenue share (\%)"        if `varlist'=="X3_white_share"
	replace `varlist' = "Red wine revenue share (\%)"          if `varlist'=="X3_red_share"
	replace `varlist' = "White wine volume share (\%)"         if `varlist'=="X3_white_vol_share"
	replace `varlist' = "Red wine volume share (\%)"           if `varlist'=="X3_red_vol_share"
	replace `varlist' = "French language share (\%)"           if `varlist'=="cov1"
	replace `varlist' = "Absinthe trade share (\%)"           if `varlist'=="cov2_total_share"
	replace `varlist' = "Protestant share (\%)"                if `varlist'=="cov3"
	replace `varlist' = "Log population density"               if `varlist'=="ln_density"
	replace `varlist' = "Absinthe-producer indicator"          if `varlist'=="abs_producer"
	replace `varlist' = "French \$\times\$ Absinthe-producer"  if `varlist'=="fr_x_producer"
	replace `varlist' = "White \$\times\$ French"              if `varlist'=="X3_white_x_cov1"
	replace `varlist' = "White-vol \$\times\$ French"          if `varlist'=="X3_white_vol_x_cov1"
	replace `varlist' = "White \$\times\$ Abs-producer"        if `varlist'=="X3_white_x_absprod"
	replace `varlist' = "White \$\times\$ Abs-industry"        if `varlist'=="X3_white_x_cov2"
	replace `varlist' = "Population (1900)"                    if `varlist'=="pop_1900"

	replace `varlist' = "Constant"                          if `varlist'=="_cons"

end

** EOF
