*==============================================================================
* _pop1907_rebuild.do — rebuild the workshop cohort with the 1907 population fix
* Chain: 08 (adds pop_1907) -> 08_workshop -> 09w (ln_density/X1/pet on 1907).
* Independent/batch mode: graphics off (no window-steal); more off.
*==============================================================================
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"   // sets $MyProject etc.
set graphics off
set more off
do "$MyProject/scripts/08_setup_cohort_1908.do"
do "$MyProject/scripts/08_setup_cohort_1908_workshop.do"
do "$MyProject/scripts/09_canton_reg1_workshop.do"
di "REBUILD_DONE"
