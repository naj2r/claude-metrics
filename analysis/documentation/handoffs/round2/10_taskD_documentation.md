# Round 2 — Task D: Documentation refresh

**Read first**: `00_MASTER.md`, all preceding task handoffs (01-09)
**Status**: PENDING — final task of round 2
**Prereqs**: All 9 prior round-2 tasks complete; pipeline at green baseline; all new tables and figures generated.
**Estimated time**: 1 hour
**Output**: Updates to `CONTEXT.md`, `analysis/documentation/HANDOFF_*.md` (new end-of-round handoff), `analysis/documentation/codebook.md` (auto-regenerated), and a final `/phase-review` audit pass

---

## Purpose

Round 2 produced 6 new tables (t16-t21) and 2 new figures (f05-f06) across 8-9 commits. Task D ties everything together with documentation that:
1. Updates `CONTEXT.md` with a "Round 2 additions" section so future readers (you, coauthors, referees) understand the new substantive results
2. Writes a fresh end-of-round handoff (`HANDOFF_2026-05-XX.md`) replacing/superseding the round-1 handoff for the next session
3. Updates `analysis/results/_inventory.xlsx` if any new variables were created in `absinthe_analysis.dta` (likely yes — `protestant_share_total`, possibly others)
4. Runs a final `/phase-review` pass on the entire round-2 work to catch any drift

## Sub-tasks

### D.1 — CONTEXT.md "Round 2 additions" section

Locate the existing CONTEXT.md (single file at repo root). Add a new section AFTER the existing "SECOND HEADLINE" paragraph and BEFORE the "Variable definitions (algebra)" section. The new section should be ≈40-60 lines and document:

- **Diagnostics (Task A, t16)**: report VIF range, BKW condition number, PDS-LASSO selected coefficient and selected covariates. State whether the multicollinearity critique is closed.
- **Formal B&B hypothesis tests (Task B, t17)**: report H3 (coalition) and H6 (Olsonian) interaction signs and p-values. State whether the framework is supported, partially supported, or null.
- **Food-law (#65) Simpson check (Task C.1)**: report whether bivariate→conditional shows the same sign-flip as #68. State implication for mechanism comparability.
- **Food-law (#65) robustness (Task C.2, t18)**: report whether the +1286 OLS coefficient survives the LOO + drop-NE+GE + RI + weighted battery. State whether the food-law evidence is comparably robust to absinthe.
- **RI consistency (Task C.3)**: list RI p-values for #63 (alcohol regulation), #65 (food law), #68 (absinthe) and confirm methodological consistency with headline.
- **True-placebo rank (Task C.4)**: state that absinthe ranks #1 of 14 (treatment + 13 true placebos) with permutation-style p ≈ 1/14 = 0.071.
- **Cleavage index (Task C.5, t19, f05)**: report mean rho_wine vs mean rho_other and ttest p; state whether the variance-decomposition channel corroborates the wine-rent-seeking interpretation.
- **Mobilization (Task C.6, t20, t21, f06)**: report gap_68, gap_67, z-score of gap_68 vs other-day votes, regression headlines (R², const, vine, french). State the complementary-mechanism framing (intensive margin = wine-industry; extensive margin = cultural-political).

Template for the new section:

```markdown
---

## Round 2 additions (2026-05-XX)

Round 2 (per strategist handoff `2026-04-30_paper1_coder_handoff_round2.md` and 10 partitioned task handoffs at `analysis/documentation/handoffs/round2/`) extended the round-1 paper from "consistent with B&B" to "tests B&B against rival explanations" and added two complementary empirical channels (cleavage index, turnout mobilization).

### Diagnostics (Task A, t16_diagnostics.tex)
[fill in after Task A complete]

### Formal hypothesis tests (Task B, t17_formal_hypotheses.tex)
[fill in after Task B complete; this is the section most likely to require reframing if H3/H6 are null]

### Food-law (#65) follow-ups (Tasks C.1-C.4)
[summary of Simpson check + robustness + RI + rank recompute]

### Language Cleavage Index (Task C.5, t19, f05)
[summary of rho_wine vs rho_other comparison]

### Differential mobilization (Task C.6, t20, t21, f06)
[summary of gap_68, regression results, complementary-mechanism framing]

### Round-2 file inventory
- 6 new tables: t16_diagnostics, t17_formal_hypotheses, t18_food65_robustness, t19_cleavage_index, t20_turnout_by_language, t21_canton_turnout_deviation
- 2 new figures: f05_cleavage_coefficient_scatter, f06_sameday_turnout_differential
- 1 extended table: t13_placebo_panel (added panel B for #65 Simpson check + RI p column for #63/#65/#68)
- 1 extended figure: f03_placebo_distribution (caption + y-axis updated to true-placebo N=13)
- 4 new vendored Stata packages: coldiag2, lassopack, pdslasso, ritest
- 5 new asserts on top of round-1 baseline (final pipeline assertion count: ~50)
```

### D.2 — End-of-round HANDOFF refresh

Write a new top-level handoff `analysis/documentation/HANDOFF_2026-05-XX.md` (use today's date) that supersedes `HANDOFF_2026-04-30.md`. The new handoff should:

- Carry forward the TWO HEADLINE FINDINGS section from the prior handoff (do not regress on round-1 narrative)
- Add the round-2 substantive findings as a third headline-section (formal B&B test results) IF H3 and/or H6 supported
- Update the "Where everything lives" path inventory to include the new tables/figures
- Update the "Recent git log" section to include round-2 commits
- Update "Where to audit" priorities
- Update "What's NOT done" for the next round (commune-level data, H7 panel event study, archival mobilization evidence)

Mark the old `HANDOFF_2026-04-30.md` as superseded by the new one (add a top-of-file note: `**SUPERSEDED by HANDOFF_2026-05-XX.md** as of 2026-05-XX. Retained for git-history continuity.`). Don't delete the old one.

### D.3 — Inventory regeneration (if needed)

If any new variables were added to `absinthe_analysis.dta` (e.g., `protestant_share_total` if it was computed once and saved rather than computed on-the-fly in each task), regenerate the inventory via:

```
/inventory-rebuild
```

This is the project's slash command that scans all .do files and datasets and rebuilds `analysis/results/_inventory.xlsx` from scratch. It's safer than incremental updates.

If no new variables were saved to canton-level dataset (most round-2 work uses derived locals or panel-only vars), skip this step.

### D.4 — Methods doc additions

If any round-2 task introduced a method that future sessions might re-encounter, drop a methods doc into `analysis/documentation/methods/`. Candidates:

- **PDS-LASSO methodology** (`pds_lasso.md`?) — auto-trigger on "lasso", "pds", "selection" keywords. Brief reference for what `pdslasso` does, the Belloni-Chernozhukov-Hansen 2014 reference, and the small-N caveats. ~50 lines.
- **Language Cleavage Index** (`language_cleavage_index.md`?) — auto-trigger on "cleavage", "variance", "decomposition". Document the rho computation, the dual French-canton definitions (threshold vs strict), and the t-test-of-means design.

These auto-surface via `methods-doc-reminder.sh` hook on future user prompts. Worth ~30 min of investment now to save context for future Claude sessions.

If the task didn't introduce a genuinely new method (e.g., it just used a vanilla OLS spec), skip the methods doc.

### D.5 — Final `/phase-review`

Run `/phase-review` on the entire round-2 work. Pass these arguments to capture the full scope:

```
/phase-review Round 2 final audit: all 6 new tables (t16-t21), all 2 new figures (f05-f06), all 4 vendored packages, all CONTEXT.md and HANDOFF updates
```

Address any ✗ FAIL findings before final commit. Don't loop more than 2 fix attempts on the same finding (per `/phase-review` escalation rule).

### D.6 — Final commit + push

```
git add CONTEXT.md \
        analysis/documentation/HANDOFF_2026-05-XX.md \
        analysis/documentation/HANDOFF_2026-04-30.md \
        analysis/results/_inventory.xlsx \
        analysis/documentation/methods/pds_lasso.md \
        analysis/documentation/methods/language_cleavage_index.md \
        analysis/documentation/codebook.md

git commit -m "round2 Task D: documentation refresh + final phase-review

Round 2 complete. CONTEXT.md updated with 'Round 2 additions' section
documenting all 6 new tables (t16-t21), 2 new figures (f05-f06), and the
substantive findings from Tasks A through C.6.

End-of-round handoff at HANDOFF_2026-05-XX.md (supersedes HANDOFF_2026-04-30.md
which is retained as superseded for git-history continuity).

New methods docs:
- methods/pds_lasso.md (auto-surfaces on 'lasso'/'pds'/'selection')
- methods/language_cleavage_index.md (auto-surfaces on 'cleavage'/'variance'/'decomposition')

Inventory regenerated.

Final pipeline state: ~50 assertions pass; runtime ~3-4 min (the new
RI calls add ~1.5 min on top of round-1 baseline).

phase-review verdict: <quality score> / 100; <list any deductions>.
"

git push origin starter
```

## Acceptance criteria

- [ ] CONTEXT.md "Round 2 additions" section in place with all 8 sub-results filled in (not template placeholders)
- [ ] New HANDOFF_2026-05-XX.md exists; old HANDOFF_2026-04-30.md marked superseded
- [ ] Inventory regenerated (if needed) OR skip-decision documented
- [ ] 0-2 new methods docs added (depending on what's substantively new)
- [ ] Final `/phase-review` ≥ 90/100; no critical FAILs
- [ ] Commit pushed; tag/branch state clean
- [ ] Top-level pointer in `HANDOFF_2026-04-30.md` to `handoffs/round2/00_MASTER.md` updated to point to new HANDOFF_2026-05-XX.md (so navigation chain isn't broken)

## Pitfalls

1. **CONTEXT.md may bloat** — round-1 added a lot, round-2 adds more. If the file exceeds ~250 lines, refactor by moving the "Notes" subsections to a `analysis/documentation/notes.md` and link from CONTEXT.md. CONTEXT.md should remain digestible at one read.

2. **`/inventory-rebuild` runs the full pipeline implicitly** (it scans datasets) — don't run while another Stata session has the .dta files locked. Close any active Stata sessions first.

3. **Methods docs filename keyword choice matters** — pick keywords that future user prompts will plausibly contain ("lasso" likely, "pds" maybe, "cleavage" likely, "variance decomposition" likely). Avoid generic words ("test", "data") that fire on every prompt.

4. **`/phase-review` may flag the same R12-style fingerprint gap** for new work. If reviewer suggests cross-data fingerprints for new tables (e.g., "verify t20 gap_68 against an independent computation"), implement them — that discipline caught a real bug in round 1's F-series work.

5. **Final commit message** should reference the round-2 master handoff path so future archaeology has a clear pointer.

## Done when

- All round-2 sub-results documented in CONTEXT.md
- New end-of-round HANDOFF written and pushed
- Final `/phase-review` clean
- Final commit pushed
- ROUND 2 IS COMPLETE — recommend creating an annotated git tag for the round-2 endpoint:

```bash
cd "$Absinthe1"
git tag -a round2-complete -m "Round 2 complete: diagnostics + formal hypothesis tests + food-law follow-up + cleavage index + mobilization"
git push origin round2-complete
```
