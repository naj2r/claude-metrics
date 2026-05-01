# Round 2 — Master Handoff

**Compiled**: 2026-04-30 evening
**Source strategist handoff**: `C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_paper1_coder_handoff_round2.md`
**Pipeline state at compile time**: commit `cfc2493` on branch `starter`, 28 assertions pass, runtime ~113s
**Author of these handoffs**: Claude (coder session, 2026-04-30 night)
**Intended audience**: Claude (coder session, 2026-05-01+, possibly post-compact)

---

## TL;DR for tomorrow's first session

Read this file completely. Then read `01_setup.md` and execute that task. Then `02_taskA_diagnostics.md`. Then `03_taskB_formal_hypotheses.md`. **STOP after Task B and report back to user before continuing to C.5/C.6** — H3 and H6 results change the framing for those downstream tasks.

After user re-confirms (or modifies the C-task plan based on B results), continue with `04_*` through `10_taskD_*`.

---

## Why this handoff is partitioned (and what each file is)

Round 2 is 2-3 working days of work spanning 10 sub-tasks. A single Claude context window cannot hold all 10 tasks + active code edits + log inspection + strategist spec without hitting compaction risk during execution. So each task gets its own self-contained handoff that a post-compact Claude session can pick up cold.

| File | Task | Est. time | Outputs | Stop after? |
|---|---|---|---|---|
| `00_MASTER.md` | This file (read first) | — | — | — |
| `01_setup.md` | Vendor 3 packages | 30 min | Updated `_install_stata_packages.do`, 3 new package files in `libraries/stata/` | No |
| `02_taskA_diagnostics.md` | VIF + BKW + PDS-LASSO | 3-4 hrs | `t16_diagnostics.tex` | No |
| `03_taskB_formal_hypotheses.md` | H3 + H6 interaction tests | 3-4 hrs | `t17_formal_hypotheses.tex` | **YES — check in with user** |
| `04_taskC1_food65_simpson.md` | #65 bivariate vs conditional | 30 min | Extension to `t13_placebo_panel.tex` (panel B) | No |
| `05_taskC2_food65_robustness.md` | #65 LOO + drop NE+GE + RI + weighted | 2 hrs | `t18_food65_robustness.tex` | No |
| `06_taskC3_RI_three_votes.md` | RI for #63/#65/#68 (10k each) | 1 hr | RI p-value column added to `t13_placebo_panel.tex` | No |
| `07_taskC4_rank_recompute.md` | True-placebo rank stat (#65 reclassified) | 30 min | CONTEXT.md update + figure caption update | No |
| `08_taskC5_cleavage_index.md` | Language Cleavage Index across votes | 45 min | `t19_cleavage_index.tex`, `f05_cleavage_coefficient_scatter.pdf` | No |
| `09_taskC6_mobilization.md` | Cross-vote turnout + same-day differential | 2 hrs | `t20_turnout_by_language.tex`, `t21_canton_turnout_deviation.tex`, `f06_sameday_turnout_differential.pdf` | No |
| `10_taskD_documentation.md` | CONTEXT round-2 section + inventory + final phase-review | 1 hr | CONTEXT.md, methods doc updates | No |

---

## Decisions already made (do not re-litigate)

These were resolved in the 2026-04-30 evening dispatch from the user (after orchestration feedback from the strategist):

### Naming and numbering

The strategist's table numbers collide with this repo's existing tables. Resolution: **shift strategist's numbers up by 2** and continue from `t16`.

| Strategist's name | Reason for collision | Use this name instead |
|---|---|---|
| `t14_diagnostics.tex` | `t14_new_controls.tex` already exists | **`t16_diagnostics.tex`** |
| `t15_formal_hypotheses.tex` | `t15_gelbach.tex` already exists | **`t17_formal_hypotheses.tex`** |
| `t16_food65_robustness.tex` | n/a | **`t18_food65_robustness.tex`** |
| `t17_cleavage_index.tex` | n/a | **`t19_cleavage_index.tex`** |
| `t18_turnout_by_language.tex` | n/a | **`t20_turnout_by_language.tex`** |
| `t19_canton_turnout_deviation.tex` | n/a | **`t21_canton_turnout_deviation.tex`** |
| `f04_cleavage_coefficient_scatter.pdf` | `f04_marginsplot_french.pdf` already exists | **`f05_cleavage_coefficient_scatter.pdf`** |
| `f05_sameday_turnout_differential.pdf` | n/a | **`f06_sameday_turnout_differential.pdf`** |

### Variable / dataset name mappings (strategist → this repo)

| Strategist | This repo | Notes |
|---|---|---|
| `vote_id` | `anr` | Same semantic: federal-vote sequence number |
| `vine_per_cap` | `vineyard_per_cap` | Strategist is inconsistent (sometimes uses both); always use `vineyard_per_cap` |
| `swiss_referendum_1908_master.dta` | `absinthe_analysis.dta` | Canton-level cross-section, N=25 |
| `agric_kha_1912` | `agland_1000ha` | Same variable, different name |
| `vote_date` | (not available; have `vote_year` only) | Tables that need full dates use year only; note in caption |
| `vote_topic` | `vote_label` | Same field |

### Data availability fallbacks (already approved by user)

| Strategist asks for | Available? | Approved fallback |
|---|---|---|
| Blue Cross / Croix-Bleue / IOGT membership | NO | Use `protestant_share = 1 - catholic_share_total` (total-pop denominator); note construction in t17 footnote |
| `italian_share` (continuous) | NO (have `lang_italian` binary only) | Use `lang_italian` binary in PDS-LASSO covariate set; document as limitation in t16 caption |
| `urban_share` | NO | Omit from PDS-LASSO; document omission in t16 caption (urbanization partially proxied by `ln_pop`) |
| `agric_kha_1912` | YES (named `agland_1000ha`) | Use as-is |
| `vote_date` (full date) | NO (have `vote_year` only) | Use year only; note "full dates available in swissvotes_dataset.csv if needed" |
| `vote_topic` | YES (named `vote_label`) | Use as-is |
| Per-canton turnout for all 15 placebo votes | **AVAILABLE in source CSV** (per orchestration follow-up); placebo_panel.dta currently only has yes_pct | Mirror existing Python extraction in Stata via back-extension of `01_import.do`. See "swissvotes_dataset.csv content inventory" section below. Pattern is identical to existing `{canton}-japroz` extraction. ~30-45 min one-time fix. |

### Process decisions

- **Per-task commits, NOT one big PR.** Each task ends with its own commit. The strategist's one-big-commit message template is overridden. Each partitioned handoff includes a per-task commit message template.
- **Project rules supersede strategist rules.** Specifically:
  - No inline `ssc install` / `net install` (HARD rule). Use `/add-package` slash command.
  - No hardcoded paths — use `$MyProject` / `$Absinthe1Data`.
  - Forward slashes only in Stata paths.
  - Numbered scripts pattern (`NN_description.do`) for any new top-level script.
  - Post-credits codebook+inventory blocks for any script that creates a `.dta`.
  - `version 19` declaration at top.
  - `**#` chapter-style section headers (0., 1., 1.1, ...).
  - String-literal vars use `str50` (project norm; widen further if needed).
  - All variables labeled.
  - `assert` discipline on key numbers + cross-data fingerprints (R12 lesson).
- **Plan-first for non-trivial changes** (`.claude/rules/plan-first-workflow.md`). Most round-2 tasks pass the "non-trivial" threshold; this handoff stack IS the plan, so individual tasks may execute directly without a separate plan-mode pass.

### Stop-points

After **Task B** (formal hypothesis tests on H3 and H6), STOP and report results to user before continuing to C.5 (cleavage index) and C.6 (mobilization). Reason from orchestration feedback:

> If H3 (coalition interaction) is null, the cleavage index work in C.5 may need reframing because the variance-decomposition story partly depended on the interaction holding. If H6 (Olsonian) is null, the formal hypothesis section becomes less ambitious. Either way, you want to know after Task B before committing 1+ days to Tasks C.5 and C.6.

After Task B, write a short status update with:
- H3 sign and p-value
- H6 sign and p-value
- Whether C.5/C.6 framing should change

Do NOT proceed to C.* automatically. Wait for user dispatch.

---

## Vendored packages required (Task: 01_setup)

These are needed across multiple tasks and must be vendored ONCE at the start, not per-task:

| Package | Source | Used by | Why |
|---|---|---|---|
| `coldiag2` | SSC | Task A | BKW condition number (Belsley-Kuh-Welsch) for multicollinearity diagnostic |
| `pdslasso` | SSC | Task A | Post-double-selection LASSO (Belloni-Chernozhukov-Hansen 2014) |
| `lassopack` | SSC | Task A | Dependency of `pdslasso` |
| `ritest` | SSC (or GitHub via `net install`) | Task C.3 + Task C.6 | Permutation inference (10k reps × 3 votes for C.3, × 2 specs for C.6) |

Vendor via `/add-package <name>` (the project's slash command that wraps `ssc install` to write into `analysis/scripts/libraries/stata/<letter>/` and update `_install_stata_packages.do`). DO NOT use inline `ssc install`.

---

## Pre-existing analysis state (what tomorrow's session inherits)

### Outputs already on disk (from commit `cfc2493`)

| Path | Content |
|---|---|
| `analysis/processed/absinthe_analysis.dta` | 25 cantons × ~50 vars (canton-level cross-section) |
| `analysis/processed/placebo_panel.dta` | 375 rows = 25 cantons × 15 votes 1900-1910 (long format). Includes `yes_pct`, `yes_frac`, `vineyard_per_cap`, `french_share`, `catholic_share`, `pop_1900`, `ln_pop`. **Turnout coverage uncertain — verify in Task C.6 prereqs.** |
| `analysis/processed/intermediate/f07a_employment_long.dta` (N=264) | National employment by status × gender 1888-1960 (NEVER merge into canton chain) |
| `analysis/processed/intermediate/f08a_agric_pop_long.dta` (N=384) | National ag population 1888-1960 (NEVER merge) |
| `analysis/processed/intermediate/f13_business_sector_long.dta` (N=960) | National business census 1905/29/39/55, 40 industry classes × 6 metrics × 4 years (NEVER merge) |
| `analysis/results/intermediate/regressions.dta` | OLS + fracreg + LOO + RI (headline) |
| `analysis/results/intermediate/regressions_expansion.dta` | All expansion specs incl. 15-vote panel (OLS + fracreg AMEs) + Gelbach + new controls |
| `analysis/results/intermediate/ri_distribution.dta` | 10k RI t-stats for headline KEY spec |
| `analysis/results/intermediate/gelbach_decomp.dta` | LANG/RELIG/TOTAL deltas + SEs |
| `analysis/results/tables/t01_summary.tex` ... `t15_gelbach.tex` | 15 LaTeX tables |
| `analysis/results/figures/f01-f04.pdf` | 4 PDF figures |

### Code already on disk

| Path | Status |
|---|---|
| `analysis/run.do` | Pipeline orchestrator: 01 → 02 → 03 → 04 → 05 → 06 |
| `analysis/scripts/01_import.do` | Imports + canton crosswalk + 8 HSSO files. Note: turnout for placebo panel may need back-extension here if Task C.6 prereqs fail. |
| `analysis/scripts/02_clean.do` | Constructs `absinthe_analysis.dta` AND `placebo_panel.dta` |
| `analysis/scripts/03_regress.do` | OLS + fracreg + LOO + exclude-NE+GE + RI 10k for headline |
| `analysis/scripts/04_tables.do` | t01-t03 main, t11 magnitudes, f01-f02 figures, sanity assertions |
| `analysis/scripts/05_expansion.do` | t04-t10, t12-t15, f03-f04, expansion assertions. **This is where Tasks A, B, C.1-C.5 will mostly live (extending it).** |
| `analysis/scripts/06_national_descriptives.do` | F-series (national, descriptive only) |
| `analysis/scripts/programs/_install_stata_packages.do` | Vendored package installer; needs Group 8 added in Task 01_setup |
| `analysis/scripts/programs/clean_vars.ado` | Variable display labels for table prettification |

### Methods docs that auto-surface (post-compact safe)

The `.claude/hooks/methods-doc-reminder.sh` hook scans `analysis/documentation/methods/*.md` filenames for keywords ≥4 chars and emits reminders on user prompts. Currently active:

| File | Triggers on keywords |
|---|---|
| `methods/gelbach_decomposition.md` | "gelbach", "decomposition" |
| `methods/hsso_national_descriptives.md` | "hsso", "national", "descriptives" |

If round-2 work creates new methods docs (e.g., for post-double-selection LASSO or for the language cleavage index methodology), drop them in `methods/` and the hook auto-fires on relevant prompts.

### Existing infrastructure

| Path | Purpose |
|---|---|
| `.claude/skills/major-change/` | Slash command + skill for documenting major findings as `progress_*.md` notes |
| `.claude/hooks/methods-doc-reminder.sh` | UserPromptSubmit hook, auto-surfaces methods refs |
| `.claude/rules/stata-gotchas.md` | Top critical Stata pitfalls (always loaded into CLAUDE.md context) |
| `.claude/rules/plan-first-workflow.md` | Plan-first rule for non-trivial changes |

---

## Two strategist STOP rules to internalize

From the strategist's round-2 handoff (Section "STOP HERE — do NOT do these"):

1. ❌ Do NOT touch `Paper/main.tex` or any prose section files (this repo doesn't have a paper anyway, but the principle applies — round-2 is code/tables only)
2. ❌ Do NOT introduce a new theoretical model (theory work happens in a separate session)
3. ❌ Do NOT change the headline KEY spec (round 1 results are locked)
4. ❌ Do NOT pursue archival mobilization evidence (separate effort)
5. ❌ Do NOT pursue commune-level data extraction (deferred decision)
6. ❌ Do NOT attempt the H7 panel event study (depends on commune-level data scoping)

Plus user's standing rule: **project rules supersede strategist rules** when they conflict.

---

## swissvotes_dataset.csv content inventory (critical for Task C.6)

**Source of this section**: orchestration follow-up from strategist via user, 2026-04-30 evening (after the Round 2 handoff was already written). Encodes infrastructure visibility I (the coder) didn't initially have.

The source CSV at `$Absinthe1Data/swissvotes_dataset.csv` contains **per-canton per-vote columns for every Swiss federal referendum since 1848**, following this naming pattern (one set per canton abbreviation `zh`, `be`, ..., `ge`):

| CSV column pattern | Semantic | Currently extracted? |
|---|---|---|
| `{canton}-japroz` | Yes-vote percentage | YES — for all 15 panel votes (used to build `placebo_panel.dta`) |
| `{canton}-bet` | Turnout percentage | NO — only for vote #68 (lives in `absinthe_analysis.dta`) |
| `{canton}-berecht` | Eligible voters (count) | NO — only for vote #68 |
| `{canton}-stimmen` | Total votes cast (count) | NO — only for vote #68 |
| `{canton}-jastimmen` | Yes votes (count) | NO — only for vote #68 |
| `{canton}-neinstimmen` | No votes (count) | NO — only for vote #68 |

**Implication for Task C.6**: my initial worry that "panel coverage may be partial" was a visibility gap, not a data gap. The fix is to mirror the Python pipeline's pattern (`run_expansion.py` Expansion 1.D ~lines 195-198, and Expansion 7 ~lines 505-518 at `C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/Replication/Python/run_expansion.py`) and pull these columns for all 15 panel votes when extending `01_import.do`.

**Recommendation from strategist (per orchestration follow-up)**: while back-extending, pull all 6 per-canton per-vote columns (`bet`, `berecht`, `stimmen`, `japroz` already done, `jastimmen`, `neinstimmen`) so future analyses don't need another extraction pass. Final cleaned panel = canton × vote × {turnout, eligible, total, yes_pct, yes_count, no_count} for the 15 votes in the panel range. Trivial dataset size (25 × 15 × 6 = 2,250 cells).

**This work belongs in Task C.6's prereq step**, but it's BIG enough that the Task C.6 partitioned handoff treats it as a Phase 0 of that task with its own commit. See `09_taskC6_mobilization.md`.

---

## Cross-task data invariants

These hold across all round-2 tasks; don't break them:

1. **N=25 cantons** in canton-level analysis. BE includes pre-1979 BE+JU.
2. **placebo_panel.dta = 25 × 15 = 375 rows** (cross-referendum panel)
3. **`yes_frac = yes_pct / 100`** — exists in both `absinthe_analysis.dta` (vote #68 only) and `placebo_panel.dta` (vote-specific)
4. **HC3 robust SEs** for all OLS regressions (project standard); fracreg uses `vce(robust)` because it can't accept `vce(hc3)`
5. **Random seed `20260430`** for round-2 RI work (matches strategist's example code; differs from headline `20260409`); each `set seed` block must declare it
6. **Vendored packages are checked in** under `libraries/stata/` — never `ssc install` inline
7. **Post-credits block on every numbered script** that creates a .dta — `_codebook_update` + `_inventory_append`

---

## Re-running the pipeline (any task)

After making any code change, verify end-to-end:

```bash
# Windows / Git Bash batch-mode pattern (use this; MCP-Stata sometimes silently hangs)
STATA_BIN="/c/Program Files/StataNow19/StataMP-64.exe"
WIN_BIN=$(cygpath -w "$STATA_BIN")
WIN_DO=$(cygpath -w "C:/Users/jensenn/AppData/Local/Temp/test_full_pipeline.do")
WIN_DIR=$(cygpath -w "C:/Users/jensenn/AppData/Local/Temp")
cat > /tmp/_run.bat << BATEOF
@echo off
cd /d "$WIN_DIR"
"$WIN_BIN" /e do "$WIN_DO"
BATEOF
cmd //c "$(cygpath -w /tmp/_run.bat)"
rm /tmp/_run.bat
LATEST=$(ls -t "C:/Users/jensenn/Research/repos/c-metrics-absinthe1/analysis/scripts/logs/"*.log.txt | head -1)
grep -nE "ALL .+ PASSED|assertion is false|Runtime" "$LATEST"
```

The wrapper at `C:/Users/jensenn/AppData/Local/Temp/test_full_pipeline.do` already exists from the F-series session. It contains:

```stata
version 19
global HOME    "C:/Users/jensenn"
global DROPBOX "C:/Users/jensenn/Dropbox"
do "$DROPBOX/stata_profile.do"
do "$Absinthe1/run.do"
```

If the temp wrapper got cleaned up, recreate it with that content.

Expected output: 3 PASSED messages (sanity / expansion / F-series), runtime ~110-120s. Each round-2 task adds new asserts; the count grows.

---

## Order of partitioned handoffs (read in this order tomorrow)

1. `01_setup.md` — vendor packages
2. `02_taskA_diagnostics.md`
3. `03_taskB_formal_hypotheses.md` ← **STOP after this; report H3/H6 to user**
4. (after user re-confirms): `04_taskC1_food65_simpson.md`
5. `05_taskC2_food65_robustness.md`
6. `06_taskC3_RI_three_votes.md`
7. `07_taskC4_rank_recompute.md`
8. `08_taskC5_cleavage_index.md`
9. `09_taskC6_mobilization.md`
10. `10_taskD_documentation.md`

Each partitioned handoff is **self-contained** — read it + this master + `CONTEXT.md` + the auto-surfaced methods refs and you have everything needed to execute that one task.

---

## When in doubt

1. If a strategist instruction conflicts with a project rule: **project rule wins.** Document the deviation in the task's handoff.
2. If a data variable is missing: check this master's "Data availability fallbacks" table; fall back per the approved plan; flag in the task's commit message.
3. If a Stata package is missing: check `01_setup.md`; if it should have been vendored but wasn't, vendor it via `/add-package` (don't `ssc install` inline).
4. If an assertion fails: read the value, re-derive what the expected value should be from the source data, fix the calculation if it's a code bug or update the assertion if the source data has shifted. Don't comment out the assertion.
5. If runtime exceeds 5 min: investigate which task is slow; if RI (10k perms × 3 votes) is the culprit, that's expected and fine.
6. If you genuinely don't know what the user wants: **stop and ask.** "Cautious procedural work is the name of the game." (User instruction, 2026-04-30 evening.)

---

## Provenance

This handoff stack was written 2026-04-30 evening after:
- Reading the strategist's `2026-04-30_paper1_coder_handoff_round2.md` in full
- Two clarifying-questions exchanges with user (Q1 numbering scheme, Q2 commit cadence)
- Receiving orchestration feedback from the strategist via the user that resolved data-availability fallbacks and added the C.6 turnout-coverage prerequisite
- User decision to write planning docs first rather than start implementation immediately, to avoid context loss across compactions during 2-3 days of work

The strategist's original spec is at:
`C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_paper1_coder_handoff_round2.md`

If any of these partitioned handoffs disagrees with the strategist's spec, the partitioned handoff wins (it incorporates the user's overrides and the orchestration feedback that the strategist wrote).
