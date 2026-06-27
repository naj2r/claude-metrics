/*==============================================================================
 _run_table_builders.do — Phase A''.6 run the refactored table-builder scripts
 sequentially.  Each uses the _workshop_table wrapper.
==============================================================================*/

clear all
set graphics off

* Standard init (sets $MyProject, $Absinthe1Data, adopaths, etc.)
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"

* Ensure wrapper + extended clean_vars are picked up fresh
discard
cap program drop _workshop_table
cap program drop clean_vars

di as text _newline "{hline 78}"
di as text "  Running 10_workshop (T2 cascades + T3 horserace, OLS + FL via wrapper)"
di as text "{hline 78}"
do "$MyProject/scripts/10_canton_reg1_tables_workshop.do"

di as text _newline "{hline 78}"
di as text "  Running 11_workshop (T5 R4 + T6 turnout + T7 fl-vs-ols, via wrapper)"
di as text "{hline 78}"
do "$MyProject/scripts/11_canton_robustness_tables_workshop.do"

di as text _newline "{hline 78}"
di as text "  Running 13_workshop (T4 petition cascade OLS + FL, via wrapper)"
di as text "{hline 78}"
do "$MyProject/scripts/13_canton_petition_tables_workshop.do"

di as text _newline "{hline 78}"
di as text "  Running 15_workshop (T8 cross-referendum, OLS + FL via wrapper)"
di as text "{hline 78}"
do "$MyProject/scripts/15_workshop_cross_referendum.do"

di as text _newline "{hline 78}"
di as text "  Table-builder run complete (10 + 11 + 13 + 15 via wrapper)."
di as text "{hline 78}"
