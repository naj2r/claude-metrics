*==============================================================================
* _pop1907_phase2.do — propagate the 1907/1906 population fix downstream
* Regressions (12w) -> table builders -> inference (point/HC3 only, RI->R)
* -> figures/assembly/replication -> headline AME. Deploys to $WorkshopTables.
* Independent/batch mode: graphics off; more off.
*==============================================================================
do "C:/Users/jensenn/Dropbox/Scripts/stata_absinthe_init.do"   // sets $MyProject etc.
set graphics off
set more off

* --- Regressions not yet rerun (petition; 09w already done) ---
do "$MyProject/scripts/12_canton_petition_workshop.do"
di "PH2_MARK: 12w done"

* --- Table builders (deploy to Overleaf) ---
do "$MyProject/scripts/14_workshop_summary_stats.do"
do "$MyProject/scripts/10_canton_reg1_tables_workshop.do"
do "$MyProject/scripts/13_canton_petition_tables_workshop.do"
do "$MyProject/scripts/11_canton_robustness_tables_workshop.do"
do "$MyProject/scripts/15_workshop_cross_referendum.do"
do "$MyProject/scripts/19_workshop_winetype_tables.do"
do "$MyProject/scripts/21_workshop_desc_cleavage.do"
di "PH2_MARK: builders done"

* --- Inference: point estimates + HC1/HC2/HC3 + BM + LOO + Oster; SKIP 10k RI ---
global RUN_RI "0"                  // RI migrated to standalone R port; skip Stata permute
do "$MyProject/scripts/22_canton_inference_battery.do"
global RI_PENDING_RERUN "1"        // 23: flag T_ri stale + withhold from Overleaf
do "$MyProject/scripts/23_canton_inference_battery_tables.do"
di "PH2_MARK: inference done"

* --- Figures + assembly + replication ---
do "$MyProject/scripts/16_workshop_figures.do"
do "$MyProject/scripts/17_workshop_assemble.do"
do "$MyProject/scripts/18_workshop_replication_strip.do"
di "PH2_MARK: finals done"

* --- Headline FL-AME magnitude write-up ---
do "$MyProject/scripts/_canton_ame_magnitudes.do"
di "PHASE2_DONE"
