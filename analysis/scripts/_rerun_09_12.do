/*==============================================================================
 _rerun_09_12.do — Phase A'' regeneration of all .ster files.
 Runs 09_workshop (with dydx(*) fix) then 12_workshop (with petition FL added).
==============================================================================*/

clear all
set graphics off

* Source the standard init script (sets $MyProject + $Absinthe1Data + all
* per-machine paths from $DROPBOX/stata_profile.do)
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"

* Don't skip regressions — we WANT them to run this time
global SKIP_09_REGRESSIONS = ""

di as text "{hline 78}"
di as text "  STARTING 09_workshop re-run (regenerates FL .ster with dydx(*))"
di as text "{hline 78}"
do "$MyProject/scripts/09_canton_reg1_workshop.do"

di as text _newline "{hline 78}"
di as text "  STARTING 12_workshop re-run (adds petition FL specs)"
di as text "{hline 78}"
do "$MyProject/scripts/12_canton_petition_workshop.do"

di as text _newline "{hline 78}"
di as text "  09 + 12 re-run complete."
di as text "{hline 78}"
