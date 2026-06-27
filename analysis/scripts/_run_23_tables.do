/*==============================================================================
 _run_23_tables.do — standalone batch wrapper to rebuild the inference-battery
 tables (script 23) after the canonical 10k RI run (_inference_battery_run.do).

 Run INDEPENDENTLY (real stata-mp, not the MCP server) because 23 deploys the
 FINAL tables to the Dropbox/Overleaf folder, which the MCP path-sandbox blocks:
   StataMP-64.exe /e do "<repo>/analysis/scripts/_run_23_tables.do"

 With the canonical inference_ri.dta (char _dta[ri_reps]=10000) on disk, 23 marks
 T_ri FINAL and deploys it to Tables/Robustness_6-3-26/ alongside the other 5.
==============================================================================*/
clear all
set graphics off                       // batch/independent mode: suppress graph windows

do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"   // sets $MyProject etc.

do "$MyProject/scripts/23_canton_inference_battery_tables.do"

di as result _n "{hline 70}"
di as result "  _run_23_tables.do complete — T_ri refreshed from canonical inference_ri.dta."
di as result "{hline 70}"
