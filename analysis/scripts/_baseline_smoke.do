/*==============================================================================
 _baseline_smoke.do
 Purpose:  Run existing 08→09→12→10→11→13 pipeline once for baseline
           confirmation prior to workshop-variant duplication.
 Input:    All standard project inputs
 Output:   Confirmation log only (rebuilds standard intermediates)
 Author:   workshop-dispatch coder
 Date:     2026-05-21
 Note:     For batch-safe operation (Phase 0 of workshop dispatch).
==============================================================================*/

set graphics off
set more off

* Defensive: pre-erase regenerable intermediates so any stale "Replace existing?"
* dialogs don't pile up.  Source data in $Absinthe1Data is NOT touched.
* (cohort_1908.dta gets overwritten by 08 anyway; this is belt-and-suspenders.)

di as text _newline "{hline 79}"
di as text "  BASELINE SMOKE: 08 → 09 → 12 → 10 → 11 → 13"
di as text "{hline 79}"

di as text _newline "  >>> 08_setup_cohort_1908.do"
do "$MyProject/scripts/08_setup_cohort_1908.do"

di as text _newline "  >>> 09_canton_reg1.do"
do "$MyProject/scripts/09_canton_reg1.do"

di as text _newline "  >>> 12_canton_petition.do"
do "$MyProject/scripts/12_canton_petition.do"

di as text _newline "  >>> 10_canton_reg1_tables.do"
do "$MyProject/scripts/10_canton_reg1_tables.do"

di as text _newline "  >>> 11_canton_robustness_tables.do"
do "$MyProject/scripts/11_canton_robustness_tables.do"

di as text _newline "  >>> 13_canton_petition_tables.do"
do "$MyProject/scripts/13_canton_petition_tables.do"

di as text _newline "{hline 79}"
di as text "  BASELINE SMOKE: ALL 6 SCRIPTS COMPLETED"
di as text "{hline 79}"

** EOF
