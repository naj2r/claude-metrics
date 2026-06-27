/*==============================================================================
 _inference_battery_run.do — CANONICAL overnight run of the inference battery.

 RI = 10,000 permutations (methodology-integrity floor), seed 20260603.
 Estimated runtime ~100 min (5 FL-AME RI cells dominate; each rep re-fits
 fracreg + margins across the 25 cantons). Run this UNATTENDED (overnight).
 It regenerates ALL inference_*.dta with the canonical 10k RI and appends the
 inventory rows.

 LAUNCH (batch — recommended for an unattended overnight run):
   Git Bash / cmd:  stata-mp /e do "<repo>/analysis/scripts/_inference_battery_run.do"
   (Windows /e flag: use the .bat workaround from the stata skill if launching
    from Git Bash, or run via the MCP server in background mode.)

 DO NOT stop it mid-run. Stopping the MCP-Stata background task orphans the
 multiprocessing worker and wedges the single Stata license (session=error,
 init timeouts) — see decision log lesson (2026-06-03). Let it finish, or accept
 a license-recovery cycle (stata_manage_session stop + a trivial probe).
==============================================================================*/
clear all
set graphics off                       // batch/independent mode: suppress graph windows
set processors 1                       // N=25 RI: MP threading overhead > gain. Benchmark
                                       // 2026-06-09: 1 core ran the FL-AME cells ~20% FASTER
                                       // than 8 cores. Core count does NOT change ritest
                                       // results (seeded permutations identical) -- speed knob only.

do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"   // sets $MyProject etc.

* Pre-erase regenerable intermediates so an interrupted prior run can't trigger
* a "Replace existing file?" modal mid-batch. Source data ($Absinthe1Data) is
* NOT touched — only this script's own outputs.
foreach f in inference_loo inference_ri inference_se_bm inference_oster inference_winetype {
    cap erase "$MyProject/results/intermediate/`f'.dta"
}

global RUN_RI          "1"     // full 10k RI
global RI_REPS_TEST    ""      // MUST be empty for canonical (=> RI_REPS = 10000)
global RUN_POSTCREDITS "1"     // append canonical inventory rows on this release run

do "$MyProject/scripts/22_canton_inference_battery.do"

di as result _n "{hline 70}"
di as result "  CANONICAL inference battery complete (RI 10,000 perms, seed 20260603)."
di as result "  Next: re-run 23_canton_inference_battery_tables.do to refresh the RI"
di as result "  table with the canonical p-values, then deploy to Overleaf."
di as result "{hline 70}"
