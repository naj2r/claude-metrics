************
* SCRIPT: 2_clean_data.do
* PURPOSE: processes the main dataset in preparation for analysis
************

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"

************
* Code begins
************

use "$MyProject/processed/intermediate/auto_uncleaned.dta", clear
local n_initial = c(N)

* Replace missing values with median for that variable
foreach v of varlist * {
	cap confirm numeric var `v'
	if _rc continue

	gen imp_`v' = mi(`v')
	label var imp_`v' "Imputed value for `v'"
	summ `v', detail
	replace `v' = r(p50) if mi(`v')
}

compress
save "$MyProject/processed/auto.dta", replace

************
* Post-credits: codebook + inventory + pipeline updates
************
_codebook_update using "$MyProject/processed/auto.dta", script("2_clean_data.do")
_inventory_append, sheet("datasets") row("created|processed/auto.dta|`=c(N)'|`=c(k)'|.|2_clean_data.do")
_inventory_append, sheet("scripts") row("2_clean_data.do|.|imputes missing values to median, generates imp_* indicators|.")
_inventory_append, sheet("pipeline") row("1|Median imputation of missing numeric values (no rows excluded)|`=c(N)'|0|0.0|2_clean_data.do")

** EOF
