/*==============================================================================
 _workshop_finals_run.do
 Purpose:  Drive 16 (figures) → 17 (assemble) → 18 (strip) in sequence.
==============================================================================*/

set graphics off
set more off

di as text _newline "{hline 79}"
di as text "  WORKSHOP FINALS: 16 → 17 → 18"
di as text "{hline 79}"

di as text _newline "  >>> 16_workshop_figures.do"
do "$MyProject/scripts/16_workshop_figures.do"

di as text _newline "  >>> 17_workshop_assemble.do"
do "$MyProject/scripts/17_workshop_assemble.do"

di as text _newline "  >>> 18_workshop_replication_strip.do"
do "$MyProject/scripts/18_workshop_replication_strip.do"

di as text _newline "{hline 79}"
di as text "  WORKSHOP FINALS: 16+17+18 COMPLETED"
di as text "{hline 79}"

** EOF
