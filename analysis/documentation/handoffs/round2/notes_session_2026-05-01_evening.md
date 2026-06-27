# Round 2 — Session handoff for resumption 2026-05-02

**Compiled**: 2026-05-02 ~01:00 (end of 2026-05-01 evening session)
**Last green pipeline commit**: `734194e` (round2 Task C.4 extension: dual classification + vote-LOO)
**Pending in working tree**: C.5 cleavage-index code (committed in this handoff commit but NOT yet pipeline-verified)
**Status**: PAUSED on a Windows-Stata-batch environmental issue, not a substantive issue

---

## TL;DR for tomorrow

Round 2 is approximately 60% complete. Tasks 01 (setup), A (diagnostics), B (formal hypothesis tests), C.1-C.4 (food-law Simpson + robustness + RI consistency + true-placebo rank with #60 finding) are all complete, committed, and pushed. **Task C.5 (Language Cleavage Index)** code is implemented in `05_expansion.do` and committed but its pipeline verification was blocked by a Windows-Stata batch-mode dialog cascade; tomorrow's first task is to get a clean pipeline run that confirms the C.5 code works.

---

## What is committed and pushed (origin/starter)

- `f6e9503` Task 01 setup (vendored coldiag2, lassopack, pdslasso, ritest)
- `9daa9f5` Task A diagnostics (VIF + BKW + PDS-LASSO → t16)
- `a6d3b91` Task B initial (H3, H6 nulls)
- `fd203d0` Task B refactor (dual-spec t17 main + t17b backmatter)
- `81e3256` Round-2 documentation (3 progress notes + framing handoff)
- `d6d3ae5` /update-codebook + engineering-review caveats note
- `11451d1` Task C.1 food-law #65 Simpson sign-flip diagnostic
- `ff41243` Task C.2 food-law #65 robustness battery
- `bd73ba3` Task C.3 RI consistency for #63/#65/#68
- `bb08a5d` Task C.4 true-placebo rank with #60 finding
- `734194e` Task C.4 extension: dual classification + vote-LOO + dual_classification progress note
- **THIS COMMIT**: C.5 code + Windows-Stata-batch rule + this handoff (pipeline verification deferred)

---

## What's in this commit (NOT yet pipeline-verified)

### `analysis/scripts/05_expansion.do` — Task C.5 Cleavage Index

New section `**# 10.15` computes per-vote `rho` (between-language variance share) and `lang_gap` (mean-yes-pct difference between French- and German-majority cantons under the threshold definition `french_share >= 0.5`). Saves two intermediate datasets:
- `processed/intermediate/language_cleavage_index.dta` (15 votes × computed columns)
- `processed/intermediate/language_cleavage_index_excl_ne_ge.dta` (robustness with NE+GE dropped, N=23)

New section `**# 12.11.9` builds:
- `t19_cleavage_index.tex` (15-row table with caption that leads on the Gelbach LANG channel per `notes_post_taskB.md` framing)
- `f05_cleavage_coefficient_scatter.pdf` (per-vote rho on x-axis, vineyard coef on y-axis, color-coded by wine-relevance)

New asserts in section 13:
- Sanity: all 15 rho values in [0, 1]
- REPORT (not assert): `rho_68 < rho_63` prediction. The handoff predicted YES, but the Round-2 partial-run data showed rho_68 = 0.343 > rho_63 = 0.073. The substantive interpretation is in the t19 caption: under the threshold definition, French cantons coincide with wine cantons, so on the absinthe vote the language partition reinforces (rather than cuts across) the wine partition. Vote #65 attenuation IS confirmed (rho_65 = 0.003); vote #68 attenuation is NOT.

Defensive batch-mode handling added to `12.12 f04_marginsplot_french`:
- All `graph close` calls → `cap graph close` (safe with `set graphics off`)
- `marginsplot` wrapped in `cap noi` (failure doesn't abort downstream)

### `.claude/rules/stata-gotchas.md` — new "Independent vs manual Stata runs" rule

Documented permanent rule per user dispatch 2026-05-01: when invoking Stata independently (background batch, `/e do`, cmd.exe wrapper), the wrapper `.do` MUST set `set graphics off` + `set more off` + `cap erase` regenerable intermediates. When invoking manually (interactive session, human at keyboard), do NOT add `set graphics off`. The rule is permanent and applies to all future automation work.

### `test_full_pipeline.do` (NOT in repo; lives in `$TEMP`)

Wrapper updated with:
- `set graphics off` (prevent graph windows from stealing focus)
- `set more off`, `set varabbrev off`, `set linesize 132` (suppress all known interactive interrupt sources)
- `cap erase` on regressions.dta, regressions_expansion.dta, ri_distribution.dta, gelbach_decomp.dta (prevent "Replace existing file?" dialog)

Despite all this, the dialog still appeared on this Windows install — see "Open environmental issue" below.

---

## Substantive findings from this session (preserved in commits + progress notes)

### Task A diagnostics (commit `9daa9f5`, no progress note)

- VIFs: vineyard 1.42, french 1.36, catholic 1.07 — collinearity critique empirically refuted
- BKW condition: 2.39 (well below 30 threshold)
- PDS-LASSO vineyard coef: +275 (positive sign, p=0.379) — sign agreement with OLS

### Task B (commits `a6d3b91`, `fd203d0`; `progress_2026-05-01_2030_bbtests.md`)

H3 (coalition) and H6 (Olsonian) interaction tests both NULL at conventional significance with positive direction. At N=25 these tests are structurally underpowered. Results are "lack of evidence, not evidence of lack." KEY-spec headline survives in all 5 spec variants.

Plus design defect caught and documented (`progress_2026-05-01_2031_collinearity_design.md`): catholic_share + protestant_c are near-mechanically collinear in 1900 Switzerland (Catholic+Protestant = 99.4% of population), so joint religion-main-effect VIFs hit 25,800. Resolved via dual-spec reporting (t17 main strategist's pre-spec + t17b backmatter cleaner variant).

### Task C.1 (commit `11451d1`)

Vote #65 (Lebensmittelgesetz) does NOT exhibit Simpson sign-flip like #68. Bivariate vineyard coef on #65 is ALREADY +583 (p=0.175); conditional is +1286 (p=0.033). Coalition was assembled differently: broader public-health coalition reached across language cleavage from the start.

### Task C.2 (commit `ff41243`)

Vote #65 robustness: SURVIVES strongly. LOO median +1283 (range [+1047, +1670]); RI 10k p=0.038; weighted regressions all positive (range +455 to +1987).

### Task C.3 (commit `bd73ba3`)

RI 10k for #63/#65/#68 all match analytical inferences:
- #63 RI p = 0.867 (analytical 0.886) — null
- #65 RI p = 0.038 (analytical 0.045) — sig
- #68 RI p = 0.037 (analytical 0.024) — sig

### Task C.4 + extension (commits `bb08a5d`, `734194e`; `progress_2026-05-01_2210_vote60.md`, `progress_2026-05-01_2230_dual_classification.md`)

True-placebo rank under #65-reclassified: absinthe ranks **#2 of 14** (NOT #1 as expected). The single exceeding vote is **#60 (federal customs tariff law 1903)**, vineyard coef +737 (p=0.328 not significant). Substantive reading: a customs tariff has obvious wine-rent-seeking interpretation — possibly a third member of the cluster, extending the Stiglerian-capture story from 2 votes to 3.

User dispatched dual-classification mandate: paper MUST present BOTH classifications side-by-side:
- Classification A (#60 retained as placebo): rank #2 of 14, p ≈ 0.143
- Classification B (#60 + #65 BOTH reclassified): rank #1 of 13, p ≈ 0.077

Plus vote-LOO sensitivity confirms the rank ambiguity is single-vote-driven: of 13 vote-LOO drops, only the drop of #60 changes rank from #2 to #1; the other 12 leave rank unchanged.

### Task C.5 (THIS COMMIT, partial)

Cleavage index showed an interesting EMPIRICAL HETEROGENEITY in the partial run before the pipeline got blocked:
- rho_63 (alcohol-reg null): 0.073 (low)
- rho_65 (food law): **0.003** (very low — predicted attenuation CONFIRMED)
- rho_68 (absinthe ban): **0.343** (HIGH — predicted attenuation NOT confirmed)
- 12 other placebos: mean 0.089 (low)

Interpretive reading (in the t19 caption): under the threshold definition, French-majority cantons (5: VD, VS, NE, GE, FR) ARE the wine-producing cantons. So on the absinthe vote where wine cantons vote yes, the language partition COINCIDES with the wine partition rather than cutting across it. Vote #65 shows the predicted attenuation because the food-law's coalition was broader than wine alone (public-health support cross-cut the language line). This is a substantive finding worth highlighting in the paper, not a methodology failure.

---

## Open environmental issue (the reason this session paused)

**Symptom**: when running the pipeline via `cmd.exe /e do test_full_pipeline.do` (the proven approach for commits ff41243 → 734194e), Windows showed a Stata modal dialog: "test_full_pipeline.do has been interrupted. Would you like the batch job to continue?" The dialog appeared MULTIPLE times in succession; user clicks (Yes or No) generated more dialogs. User clicking No aborts the run; clicking Yes continues but generates the next dialog.

**What we tried (in order)**:
1. `set graphics off` in wrapper — did not eliminate the dialog
2. PowerShell `-WindowStyle Hidden` launcher — did not eliminate the dialog (Stata GUI binary creates its own window)
3. `set more off`, `set linesize 132`, `set varabbrev off` — did not eliminate the dialog
4. `cap erase` regenerable intermediates — eliminates the "Replace existing file?" dialog specifically (different dialog), keep this fix
5. MCP-Stata as alternative channel — wedged on a tiny test command (`di "MCP alive"` hung 10+ min)

**What we have NOT tried** (for tomorrow's session):
- A. Restart the MCP-Stata server entirely (close Claude Code, reopen, see if MCP responds to fresh commands)
- B. Run the pipeline interactively (open Stata GUI manually, do `do "$Absinthe1/run.do"` from the GUI, watch it complete in front of you with graphs visible — this avoids batch mode entirely)
- C. Investigate whether some background Windows process (Defender, antivirus, screen recorder) is sending Ctrl+Break to Stata. Disable suspect processes one at a time.
- D. Check if `/e do` syntax has been deprecated in Stata 19 in favor of `-b do` Unix-style batch (would need to find a console binary or use a different invocation)
- E. Run the pipeline directly without the wrapper preamble (skip `set graphics off`, since it didn't help anyway, and just do `do "$Absinthe1/run.do"` from a fresh Stata)

**Diagnostic data we have**:
- The dialog appears even with `-WindowStyle Hidden`, suggesting it's NOT focus-stealing from a visible window
- The dialog appears in the middle of the pipeline (after some sections complete), not at startup
- The Stata process IS still running at 1.4 GB RAM when the dialog appears (consistent with mid-ritest state)
- User reported the dialog "is open in stata but not pulled to front it just exists" — passive notification, not modal-blocking
- BUT user reports it pulls to front 3-5 times in succession — implying clicks generate cascades

**Working hypothesis**: Stata batch mode on this specific Windows install has a bug or quirk where Ctrl+Break-like events get generated by some background process. Each event surfaces as a modal dialog. The batch CONTINUES executing in the background regardless of what the user clicks.

---

## Concrete first steps for tomorrow's session

1. **Read `00_MASTER.md` + this handoff** to recover context.
2. **Verify everything is committed and pushed**: `git log --oneline origin/starter | head -5` should show this handoff commit at top.
3. **Clean Stata environment**: kill all StataMP-64.exe processes, restart Claude Code (to restart MCP-Stata server), confirm zero Stata processes via Task Manager.
4. **Diagnose MCP-Stata**: send `mcp__stata__create_session` + `mcp__stata__run_command` with a tiny `di "hello"`. If it responds in <2 sec, MCP is working. If it hangs again, MCP is broken on this install — fall back to one of options A-E above.
5. **If MCP works**: dispatch the pipeline via `mcp__stata__run_do_file_background` pointing at `$Absinthe1/run.do`. The MCP path bypasses cmd.exe and avoids all Windows-batch-dialog issues by design.
6. **Verify Task C.5**: when the pipeline completes, check that `EXPANSION ASSERTIONS PASSED` appears, that `t19_cleavage_index.tex` and `f05_cleavage_coefficient_scatter.pdf` are generated, and that the rho values match the partial-run results documented above (rho_63 ≈ 0.073, rho_65 ≈ 0.003, rho_68 ≈ 0.343).
7. **If C.5 verifies**: commit any auto-updated artifacts (codebook.md, regressions_expansion.dta), push, then proceed to **Task C.6 (mobilization)** per `09_taskC6_mobilization.md`.
8. **If C.5 has substantive issues**: read the t19 caption carefully — the rho_68 high finding is documented and contextualized; no code change needed unless an assertion bug surfaces.

---

## Pending tasks (after C.5 verifies)

- **Task C.6** (`09_taskC6_mobilization.md`) — Differential mobilization across the language divide. Phase 0 = back-extension of `01_import.do` to extract per-vote turnout/eligible counts (same per-canton-per-vote columns as the existing `{canton}-japroz` extraction; see `00_MASTER.md` "swissvotes_dataset.csv content inventory"). Phases 1-3 = compute turnout deviation regression, build t20 (turnout-by-language summary), build t21 (canton turnout deviation), build f06 (same-day turnout differential figure). Apply the THREE caveats from `progress_2026-05-01_2035_c6_caveats.md`: (a) frame C.6.1 as "high effect size + adequate panel leverage" not "high power"; (b) acknowledge wine-French collinearity in C.6.2; (c) treat #67 vs #68 as a ballot-day phenomenon not absinthe-specific. ~2 hours.

- **Task D** (`10_taskD_documentation.md`) — Documentation refresh + final phase-review. CONTEXT round-2 section update + inventory + final phase-review. ~1 hour.

---

## Files preserved in this commit

- `analysis/scripts/05_expansion.do` — C.5 implementation + dual-classification + vote-LOO + defensive batch-mode handling for f04
- `.claude/rules/stata-gotchas.md` — new "Independent vs manual Stata runs" rule
- `analysis/documentation/handoffs/round2/notes_session_2026-05-01_evening.md` — THIS file

NOT touched by this commit (already at `734194e` baseline):
- All `.dta` files in `processed/intermediate/` and `results/intermediate/`
- All `.tex` files in `results/tables/`
- All `.pdf` files in `results/figures/`
- `CONTEXT.md` (round-2 dual-classification update committed in `734194e`)
- `analysis/documentation/codebook.md` (last clean state at `bb08a5d`; subsequent partial runs may have made non-functional whitespace updates)

---

## Provenance

This handoff written 2026-05-02 ~01:00 after a long session that spanned Tasks C.1 through C.5 (partial) plus the dual-classification work and three progress notes. The session paused on a Windows-Stata batch-mode environmental issue (modal dialog cascade) that is unrelated to the project's analytical content. All analytical work is preserved; only the C.5 pipeline verification is deferred.

The next session should treat this handoff as the canonical "where did we stop" record and read it before any other Round-2 partitioned handoff.
