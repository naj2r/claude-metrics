/*==============================================================================
 _workshop_tables_run.do
 Purpose:  Drive all 5 workshop table scripts in sequence.
 Author:   workshop-dispatch coder (2026-05-21)
==============================================================================*/

set graphics off
set more off

di as text _newline "{hline 79}"
di as text "  WORKSHOP TABLES: 14 → 10w → 13w → 11w → 15w"
di as text "{hline 79}"

di as text _newline "  >>> 14_workshop_summary_stats.do"
do "$MyProject/scripts/14_workshop_summary_stats.do"

di as text _newline "  >>> 10_canton_reg1_tables_workshop.do"
do "$MyProject/scripts/10_canton_reg1_tables_workshop.do"

di as text _newline "  >>> 13_canton_petition_tables_workshop.do"
do "$MyProject/scripts/13_canton_petition_tables_workshop.do"

di as text _newline "  >>> 11_canton_robustness_tables_workshop.do"
do "$MyProject/scripts/11_canton_robustness_tables_workshop.do"

di as text _newline "  >>> 15_workshop_cross_referendum.do"
do "$MyProject/scripts/15_workshop_cross_referendum.do"

di as text _newline "{hline 79}"
di as text "  WORKSHOP TABLES: ALL 5 SCRIPTS COMPLETED"
di as text "{hline 79}"

** EOF
