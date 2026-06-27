# Plan — pipeline consolidation (production vs out-of-production)

**Date:** 2026-06-19
**Branch:** `pop1907-correctness` @ `9957667`
**Gating for:** the cross-referendum placebo battery (its dispatch is explicitly **POST-CLEANUP** — this is the "system-of-record decision" it waits on).
**Process rule (PI):** *one step at a time; stop and show references + logic after each step before the next.* This doc is the roadmap; each step below is individually approved/executed.
**Lane (binding):** mechanical only — classify / archive / rename / fold / **diff to prove equivalence** / port. Paper-inclusion of any ported analysis is the PI's later call. See `coder-mechanical-provenance-boundary` memory + the scope-boundary dispatch.

---

## Context

`analysis/scripts/` holds **53 `.do` files** spanning two generations: the deprecated v1 analysis (`absinthe_analysis.dta`, `01→02→03→05`) and the current workshop pipeline (`cohort_1908_workshop.dta`, `08→09w→…`). Names/dates/folder-presence are unreliable (verified repeatedly). Ground truth = the `main.tex` `\input`/`\includegraphics` graph + dependency closure. The cleanup makes the canonical replication pipeline self-evident before new modules (the referenda battery) land on top of it.

## Decisions folded in (PI, 2026-06-19)

- **v1 chain (`01/02/04/05`) is deprecated, not patched** — the pop-1907 fix correctly landed only in the workshop chain.
- **Deprecate `05_expansion`; rebuild its salvageable analyses on `cohort_1908_workshop`** (do NOT repoint 05 — that perpetuates the split). Salvage = **Gelbach** (port; PI leans add — quantifies the cleavage claim) + **Belsley condition number** (keep — cheap, N-robust "not just collinearity / EEH" rebuttal). **Drop PDS-LASSO** (wrong tool at N=25 with ~3–4 controls). Coder ports → numbers exist; PI decides paper-inclusion after.
- **Worktree dispatches/notes copy-in is DEFERRED to battery-build** (post-cleanup), into `analysis/documentation/handoffs/` with the scope-boundary doc alongside. Not part of this cleanup.

## Approach

Do the **safe, mechanical moves first** (archive scratch → quarantine v1 → fold runners → salvage 05 → prove equivalence). Treat the **rename-to-clean-numbered-chain as a separate, optional, explicitly-approved final step** — it is the most invasive (touches every `do` call, cross-script ref, post-credits path, codebook) and mostly cosmetic once the v1 chain is quarantined (the `_workshop` suffix becomes redundant). Every step ends with a git-visible diff and a stop.

---

## Proposed classification (to be CONFIRMED file-by-file in Step 1)

**KEEP — compiled spine (live):** `08_setup_cohort_1908`, `08_setup_cohort_1908_workshop`, `09_canton_reg1_workshop`, `12_canton_petition_workshop`, `10_canton_reg1_tables_workshop`, `11_canton_robustness_tables_workshop`, `13_canton_petition_tables_workshop`, `14_workshop_summary_stats`, `15_workshop_cross_referendum`, `07_substrate_descriptives` (§1 only feeds compiled — **split candidate**), `_2_1_structural_break` (compiled `t27`+`f11`), `_cahannes_alcohol_timeseries` (compiled `f01`).

**KEEP — staged / appendix / robustness:** `22_canton_inference_battery`, `23_canton_inference_battery_tables`, `_lewbel_appendix_table`, `_lewbel_loo_diagnostic`, `_feasibility_ipw_ebal_lewbel` (back-pocket — IPW/ebal machinery archives per triage, but the script is kept), `_canton_ame_magnitudes`, `21_workshop_desc_cleavage`, `18_workshop_replication_strip`.

**KEEP — context (paper prose):** `06_national_descriptives`.

**CREATE — salvage from 05 (new, on `cohort_1908_workshop`):** Gelbach decomposition; Belsley condition number.

**QUARANTINE → `v1_deprecated/`:** `01_import`, `02_clean`, `03_regress`, `05_expansion`, `04_tables`, and the superseded suffix-less canton chain `09_canton_reg1`, `10_canton_reg1_tables`, `11_canton_robustness_tables`, `12_canton_petition`, `13_canton_petition_tables`, plus `19_workshop_winetype_tables` (winetype DEAD; T10v dropped from paper). (`05` stays here as the reference source for the Gelbach/Belsley port.)

**ARCHIVE → `_scratch_archive/`:** `_phase9_exhaustive`, `_phase9_extract`, `_phase10_extract`, `_phase10b_diag`, `_phase10b_extract`, `_baseline_smoke`, `_inference_battery_smoke`, `_a_prime_run`, `_a_prime_spotcheck`, `_test_workshop_table_wrapper`, `_section_2_1_anchor_stats`, `_pop1907_capture`, `_pop1907_rebuild`, `_pop1907_phase2`. ⚠ Verify first: provenance flag #3 says `_phase9_exhaustive` *writes into production estimate dirs* — confirm no live wrapper invokes it before moving.

**FOLD into one `run.do` (toggles `RUN_RI`, `RUN_APPENDIX`):** `_rerun_09_12`, `_run_table_builders`, `_run_23_tables`, `_workshop_tables_run`, `_workshop_finals_run`, `_inference_battery_run`.

**CLASSIFICATION PENDING (resolve in Step 1):**
- `16_workshop_figures`, `17_workshop_assemble` — recap calls them LIMBO; provenance-spine line calls them "finals {16,17,18}." Pin via `main.tex` (do their outputs compile?).
- `07` split — §1 (`h2a_substrate_prices_long.dta` → compiled `t27`/`f11`) is live; §6–§9 (federal subsidy/crop/Quandt-Andrews stats), §9e (farm-size), §9f (Land-Gini) are context/deprecated. Decide split vs keep-whole.
- **Headline wine input (ELEVATED — data-correctness, not cleanup; PI 2026-06-19).** Provenance doc says `08` reads `canton_wine_1907_pi.csv`; source-matrix note calls that a **discarded-era OCR artifact** superseded by the canonical workbook (`Swiss-stat-tables-wine.xlsx`, 1907 sheet, col `value_fr`). Do the **complete** check, both halves: **(a)** which wine file `08` reads in the *live* code (the doc may be stale — `08` may already point at the workbook); **(b)** whether those values are **byte-identical to the workbook 1907 sheet**. If they MATCH → hygiene (stale source-of-record; repoint `08` at the workbook, numbers unchanged) — report, repoint as its own follow-on. If they DIFFER → **real headline bug** (the 0.437 X3 safeguard would sit on superseded wine input): **STOP and surface to the PI as a fix that jumps ahead of the cleanup** — do not fold it in silently. Both halves are mechanical (which-file · values-match y/n), so in-lane; resolve this FIRST in Step 1.

---

## Step sequence (each ends with a git diff + STOP for review)

**Step 1 — Bring `pipeline_provenance_2026-06-18.md` current.** Extend it from data-layer-only to the full 5-tier classification above (confirmed file-by-file), fold in the PI decisions, resolve the three PENDING items + the `t27←_2_1` and wine-input flags. *Doc only, low risk.* → STOP.

**Step 2 — Archive pure scratch** → `_scratch_archive/` (after verifying nothing live calls them; special-case `_phase9_exhaustive`). → STOP.

**Step 3 — Quarantine v1** → `v1_deprecated/` (the original analytic chain + superseded suffix-less canton chain + winetype). Add a `v1_deprecated/README.md` stating why and that `05` is retained as the Gelbach/Belsley salvage source. → STOP.

**Step 4 — Author `run.do`** that reproduces the current spine, folding the 6 wrappers behind `RUN_RI` / `RUN_APPENDIX` toggles. Delete the wrappers only after run.do is proven. → STOP.

**Step 5 — Salvage from 05.** New scripts porting Gelbach + Belsley onto `cohort_1908_workshop` (governed by `methods/gelbach_decomposition.md`; FL/OLS HC3, N=25). Report corrected-cohort numbers; **no paper-inclusion decision** (PI's, later). → STOP.

**Step 6 — Prove functional equivalence.** Run `run.do` end-to-end; diff every regenerated table/figure against the pre-cleanup outputs (expect byte-identical for unmoved producers; the only intended *new* outputs are the Gelbach/Belsley ports). → STOP.

**Step 7 — DEFERRED (PI 2026-06-19), maybe permanently.** Keep the `_workshop` names (harmless once v1 is quarantined — no non-workshop twin left). A clean contiguous renumber, if ever worth it, is a single polish pass done **once, AFTER the battery** (which itself adds numbered slots), eating the one-time doc-reference update then. Do NOT tangle a rename into this cleanup or into the per-file documentation churn.

## Verification

- After each move: `git status` clean-and-intentional; `run.do` still completes.
- Step 6 is the acceptance gate: outputs equivalent ⇒ consolidation is provably behavior-preserving.
- Codebook + inventory refreshed via the post-credits protocol on the final run.

## Out of scope (this cleanup)

- The referenda placebo battery (strictly after; this is its precondition).
- Copying worktree dispatches/notes in (deferred to battery-build).
- Any paper-inclusion decision (Gelbach, Belsley, white-vs-red wine, etc. — PI's lane).
- Re-OCR / new data capture.
