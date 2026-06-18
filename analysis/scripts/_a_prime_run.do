/*==============================================================================
 _a_prime_run.do — Phase A' end-to-end: rebuild all workshop tables on pp scale
 09 (no change; .ster files unchanged) → re-run all table scripts that load
 FL AMEs to pick up the in-memory rescale-to-pp pattern → assemble master MD
==============================================================================*/

set graphics off
set more off

di as text _newline "{hline 79}"
di as text "  PHASE A' RUN: rescale all FL AMEs to pp Y per pp X"
di as text "{hline 79}"

di as text _newline "  >>> 14_workshop_summary_stats.do (T1; no FL, but rerun for completeness)"
do "$MyProject/scripts/14_workshop_summary_stats.do"

di as text _newline "  >>> 10_canton_reg1_tables_workshop.do (T2 + T3, FL rescaled to pp)"
do "$MyProject/scripts/10_canton_reg1_tables_workshop.do"

di as text _newline "  >>> 13_canton_petition_tables_workshop.do (T4; petition OLS, no FL)"
do "$MyProject/scripts/13_canton_petition_tables_workshop.do"

di as text _newline "  >>> 11_canton_robustness_tables_workshop.do (T5 + T6 + T7 REBUILT pp scale)"
do "$MyProject/scripts/11_canton_robustness_tables_workshop.do"

di as text _newline "  >>> 15_workshop_cross_referendum.do (T8 FL rescaled to pp)"
do "$MyProject/scripts/15_workshop_cross_referendum.do"

di as text _newline "  >>> 19_workshop_winetype_tables.do (T9 + T10v + T11; T10v_margins pp scale)"
do "$MyProject/scripts/19_workshop_winetype_tables.do"

di as text _newline "  >>> 21_workshop_desc_cleavage.do (T_desc)"
do "$MyProject/scripts/21_workshop_desc_cleavage.do"

di as text _newline "  >>> 16_workshop_figures.do (figures from cohort)"
do "$MyProject/scripts/16_workshop_figures.do"

di as text _newline "  >>> 17_workshop_assemble.do (master MD with pp-scale callout)"
do "$MyProject/scripts/17_workshop_assemble.do"

di as text _newline "  >>> 18_workshop_replication_strip.do (strip + 7 sentinels)"
do "$MyProject/scripts/18_workshop_replication_strip.do"

di as text _newline "{hline 79}"
di as text "  PHASE A' RUN: COMPLETED"
di as text "{hline 79}"

** EOF
