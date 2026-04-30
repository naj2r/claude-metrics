/*==============================================================================
 1_process_raw_data.do
 Purpose:  Import raw data from analysis/data/ and save in Stata format
 Input:    [your raw data files]
 Output:   analysis/processed/intermediate/<dataset>.dta
 Author:   [Author name]
 Date:     [YYYY-MM-DD]
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Setup
*------------------------------------------------------------------------------*
{
    * Any setup specific to this script (above and beyond _config.do)
}


**# 1. Import raw data
*------------------------------------------------------------------------------*
{
    * Replace with actual import command(s) for your raw data:
    *   import delimited using "$MyProject/data/<file>.csv", clear
    *   import excel using "$MyProject/data/<file>.xlsx", firstrow clear
    *   use "$MyProject/data/<file>.dta", clear
}


**# 2. Save uncleaned snapshot
*------------------------------------------------------------------------------*
{
    * compress
    * save "$MyProject/processed/intermediate/<dataset>_uncleaned.dta", replace
}


**# 3. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    * _codebook_update using "$MyProject/processed/intermediate/<dataset>_uncleaned.dta", script("1_process_raw_data.do")
    * _inventory_append, sheet("datasets") row("created|processed/intermediate/<dataset>_uncleaned.dta|`=c(N)'|`=c(k)'|.|1_process_raw_data.do")
    * _inventory_append, sheet("scripts") row("1_process_raw_data.do|.|imports raw data|.")
}

** EOF
