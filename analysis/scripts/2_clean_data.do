/*==============================================================================
 2_clean_data.do
 Purpose:  Clean the imported data — handle missingness, outliers, recodes
 Input:    analysis/processed/intermediate/<dataset>_uncleaned.dta
 Output:   analysis/processed/<dataset>.dta
 Author:   [Author name]
 Date:     [YYYY-MM-DD]
 Version:  1.0
==============================================================================*/

version 19

* Preamble (unnecessary when executing run.do)
run "$MyProject/scripts/programs/_config.do"


**# 0. Load
*------------------------------------------------------------------------------*
{
    * use "$MyProject/processed/intermediate/<dataset>_uncleaned.dta", clear
    * local n_initial = c(N)
}


**# 1. Sample restrictions
*------------------------------------------------------------------------------*
{
    * Document each restriction with an inventory pipeline entry:
    *   drop if <condition>
    *   _inventory_append, sheet("pipeline") row("1|<description>|`=c(N)'|`=`n_initial' - c(N)''|`=string((c(N)/`n_initial')*100, "%9.2f")'|2_clean_data.do")
}


**# 2. Variable cleaning
*------------------------------------------------------------------------------*
{
    * Recoding, label fixes, type conversions, etc.
    * Use Ouellet/Toffel suffix conventions:
    *   gen <var>_ln = log(<var>) if <var> > 0 & !missing(<var>)
    *   gen <var>_mz = cond(missing(<var>), 0, <var>)
    *   gen <var>_miss = missing(<var>)
}


**# 3. Save cleaned dataset
*------------------------------------------------------------------------------*
{
    * compress
    * save "$MyProject/processed/<dataset>.dta", replace
}


**# 4. Post-credits: codebook + inventory
*------------------------------------------------------------------------------*
{
    * _codebook_update using "$MyProject/processed/<dataset>.dta", script("2_clean_data.do")
    * _inventory_append, sheet("datasets") row("created|processed/<dataset>.dta|`=c(N)'|`=c(k)'|.|2_clean_data.do")
    * _inventory_append, sheet("scripts") row("2_clean_data.do|.|cleans and applies sample restrictions|.")
}

** EOF
