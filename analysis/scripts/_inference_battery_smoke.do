/*==============================================================================
 _inference_battery_smoke.do — VERIFICATION wrapper for 22_canton_inference_battery.do

 Runs the FULL battery but with a TINY RI (RI_REPS_TEST=30) so §2's code path
 (including the new producer cascade) is exercised end-to-end WITHOUT the
 ~100-min canonical 10k run. Purpose: de-risk the unattended overnight launch —
 if anything in §1/§2 is going to crash, it crashes here in ~5 min, not at hour
 one of the overnight job.

 IMPORTANT: the inference_ri.dta this produces is a SMOKE file (reps=30, stamped
 provisional via char _dta[ri_reps]). The LOO / SE-BM / Oster / winetype outputs
 are deterministic, so THOSE are canonical. For the canonical RI, run
 _inference_battery_run.do (RUN_RI=1, no RI_REPS_TEST => 10,000 perms).
==============================================================================*/
clear all
set graphics off                       // batch/independent mode (Claude automation layer)

do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"   // sets $MyProject etc.

global RUN_RI          "1"
global RI_REPS_TEST    "30"    // SMOKE ONLY — canonical run leaves this empty (=10000)
global RUN_POSTCREDITS ""      // do NOT append inventory rows during a smoke run

do "$MyProject/scripts/22_canton_inference_battery.do"

di as result _n "  SMOKE run complete (RI=30 perms — PROVISIONAL; rerun canonical for 10k)."
