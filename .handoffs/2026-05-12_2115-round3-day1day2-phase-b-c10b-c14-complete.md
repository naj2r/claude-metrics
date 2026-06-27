# Recap: Round 3 batch — Day 1 + Day 2 of verify_reconstruct_expand handoff complete

**Type**: manual /recap (end-of-session, mid-batch — pausing to resume at home)
**Date**: 2026-05-12 21:15
**Builds on prior recap**: `.handoffs/2026-05-12_1820-tier1-batch-complete.md`
**Auto-snapshot upgraded**: `.handoffs/2026-05-12T19-02-05-auto-precompact.md` (combined with narrative below)
**Session continues**: paused — user will resume at home

---

## Goals (this batch)

Execute the strategist's revised verify_reconstruct_expand handoff at `C:\Users\jensenn\Research\repos\Brainstorm-Absinthe\quality_reports\handoffs\2026-05-12_coder_handoff_verify_reconstruct_expand.md`. Three threads:

1. **Phase A verification** — read-only audit of April 2026 work vs current pipeline state; produce status report.
2. **Phase B reconstruction** — rebuild missing/outdated items from scratch in current pipeline conventions (NOT adapted from April code, which lives in Brainstorm-Absinthe repo and is non-canonical).
3. **Phase C new work** — substrate-substitution arc extension, mobilization heterogeneity, Olson × Wine interaction, etc.

Mid-session the user delivered a major dispatch revision adding C.14 (I.21a national quantities) and C.15 (Olson × Wine with Gini-primary). Both integrated into the plan; C.14 completed.

## Decisions made

1. **All Phase A items (A.1–A.8) verified end-to-end**:
   - A.1 KEY headline reconciled — April +436 = current `french_catholic_total` β=+436.58 (TOTAL-POP denoms, exact match). Current canonical KEY=+484 uses SUBSET denoms. Both committed in T02 cols 4/5.
   - A.2 LOO 0/25 sign flips confirmed (range [+413, +594] around mean +484).
   - A.3 drop-NE+GE present (β=+362, p=0.109); **drop-NE-only WAS missing** → added as patch in B.1 commit.
   - A.4 turnout-deviation regression `mobilization_dev_v68 ~ french_share` was MISSING → critical B.1 reconstruction.
   - A.5 outcome_yes_elig + outcome_margin both present (HC3-only, no RI).
   - A.6 v67 turnout in placebo_panel; April pattern (GL +11.86, SG +7.61, SH +7.34) replicates EXACTLY when computed from current data.
   - A.7 substrate-arc outputs all present at HEAD ce371ae.
   - A.8 dispersion descriptive PRODUCED: French-German turnout gap collapse −12.22→−0.11 pp (12-pp swing). Within-French-wine SD on yes_pct = 12.51 pp >> 2pp hard-stop → C.6b Phase A unblocked.

2. **Phase B reconstruction COMPLETE (B.1 + B.2 + B.3 + B.4 + B.5 + B.6)**:
   - **B.1 chain established**: language → mobilization (β=+15.0, RI p=0.047) is the missing complement to T20's mobilization → vote-share. Now both directions documented in T20 + T20b.
   - **B.4 same-day comparison**: April top-3 (GL/SG/SH) replicate exactly; full 25-canton table in `output/notes/same_day_v67_v68_comparison.md`.
   - **B.5 framing**: substitution-INCENTIVE language throughout T22/T23/F07/F08; supply-and-demand framework note in F08; 1908→1910 wine surge framed as regulatory-capture demand redirection.
   - **B.6 C.7 INCONCLUSIVE**: T17 col 6 + T18 row 9 footnotes; horticulture_per_cap label updated to flag backmatter status.
   - **B.2/B.3 RI for outcomes** + critical reconciliation: April's "margin RI p=0.254 n.s." came from COUNT-DV; current pipeline's percentage-DV gives RI p=0.043 (sig). Both DVs now in pipeline; the difference is DV construction, not inference method.

3. **Phase C Day 2 done (C.10b + C.14)**:
   - **C.10b H.2a long-run**: extended F08 to 1830-1915, added T23b period-mean table. **NEW substantive finding**: pre-phylloxera wine/potato ratio sat at PARITY (1.00). Phylloxera era pushed it to 1.29; recovery+ban era 1.34. Post-ban wine-index differential 1905→1910 = +57.9 idx pts (+118% in 5 yrs).
   - **C.14 I.21a quantity-side**: new dataset (i21a_quantities_long.dta, 155 yearly obs 1837-1991), T26 + F10 + c14_quantity_arc.md. **Pillar 2 framework predictions SUPPORTED**: wine production -29% pre-to-recovery, potato production +38% pre-to-phylloxera. Strategist's 8 cited values matched EXACTLY (1875 wine=2350, 1908 wine=1033, 1910 wine=222, 1885 potato=11521, etc.).

4. **All work built FROM SCRATCH using current pipeline conventions** per user's explicit instruction. April code (in Brainstorm-Absinthe repo) is NOT in this codebase and was not adapted.

5. **Margin DV reconciliation is a substantive finding**, not just a discrepancy resolution: the percentage-margin and count-margin DVs give different inferences (one sig, one null) because count is dominated by population. The paper can choose explicitly; both are committed.

## Lessons

1. **Stata `file write` does not accept inline format specs** like `display` does. `file write fh "..." %6.0f \`local'` errors with r(198) "invalid syntax". Workaround: pre-format into a string local first (`local x : di %6.0f \`val'` then `file write fh "...\`x'..."`).

2. **Stata does not support `%+` format flag** for forced sign prefix. `display %+5.2f x` errors with r(109) "invalid %format". Workaround: format with `%5.2f` then prepend "+" manually via Stata logic for positive values.

3. **Crashed Stata runs leave file handles open**. Subsequent `file open <name>` fails with r(110) "file handle already exists". Workaround: defensive `cap file close <name>` immediately before every `file open` (now embedded in 05_expansion.do § 10.18 and 07_substrate_descriptives.do § 9c.4).

4. **HSSO Excel files commonly have periodic-average rows after the yearly data block** that contain duplicate years. H.2a had rows 246-249 (1971/74...1983); I.21a had rows 217-219 (1981/85...1991). Always tighten cellrange to exclude these (matches the H.2a precedent of `cellrange(A12:L194)`).

5. **MCP-Stata `code=` parameter mangles backslashes to forward slashes** when the inline string contains LaTeX-escape sequences (`\_`, `\#`, `\to`, `\ref`). Workaround: use `is_file=true` for any Stata code containing literal backslashes; the script-file path preserves them. Encountered this on T20b footnote rebuild.

6. **MCP-Stata profile-inheritance gap remains**: sessions don't inherit user's stata_profile.do. Defensive globals + `do "$MyProject/scripts/programs/_config.do"` required at session start. Encountered AGAIN this session (documented previously but worth noting for stata-gotchas.md update).

7. **`isid year` is a fast-fail diagnostic for HSSO yearly data** — it surfaces the periodic-average duplicate-year issue immediately. Worth keeping as the first post-extraction assertion on any time-series Excel import.

## Blockers / decision points (RESOLVED in this batch)

The three pending decisions from the prior recap are all addressed:

1. **C.6 follow-up (B.1 reconstruction)** — DONE. Spec selected: full multivariate (`mobil_dev ~ french + cath + vine + RI`) plus univariates (lang-only, religion-only) plus vineyard placebo. All 5 specs in T20b.
2. **C.7 reframe** — DONE. T17 col 6 + T18 row 9 INCONCLUSIVE labeling applied; horticulture_per_cap variable label updated.
3. **C.10 backward extension** — DONE. C.10b chose 1830-1915 window (per strategist's revised handoff spec) yielding the new pre-phylloxera parity finding.

## Blockers / decision points (NEW for next session)

None blocking — the strategist's Day 3-5 plan provides clear next steps. Open scope choices:

1. **C.6c** (T25 French-German gap-collapse table) — descriptive paper-text-ready table from existing data; ~45 min. Natural next item.
2. **C.6b Phases A-D** (heterogeneity decomposition + cross-vote comparison + baseline robustness + integration prose) — ~3.5-4 hrs. Phase A unblocked (SD=12.51 ✓).
3. **C.15 NEW** (Olson × Wine interaction with Gini-primary + threshold-sweep + placebo battery + NE-OVB controls; uses I.38 farm-size data) — ~5-6 hrs. Largest new task in revised handoff. The new headline-candidate substantive analysis. Requires inspecting newly-translated I.38_EN.xlsx structure first.
4. **Tier 1.1 + 1.2** (placebo battery + fractional logit) — ~2.5 hrs combined.
5. **Tier 2.1-2.4** (subsamples, alt vine, Moran's I) — ~2.5 hrs.
6. **End-of-batch smoke test** — ~30 min.

Total remaining: ~15-17 hrs focused work; ~20+ hrs realistic with iteration overhead. Workshop deadline May 22 (10 days from May 12) so no rush.

## Files touched (this batch — committed)

### New scripts
None. All new sections added to existing scripts.

### Modified scripts
- `analysis/scripts/01_import.do` — § 2.3 extended v67 extraction to also pull bet/berecht/stimmen (turnout, eligible, total_votes for vote #67, per Phase B.4 patch)
- `analysis/scripts/02_clean.do` — § 2.6 added `margin_alt` (B.3 diagnostic, count-DV) + `same_day_excess_v68_v67` (B.4 derived); § 3 assertion list extended with new vars; § 4 keep order extended; horticulture_per_cap label updated to flag INCONCLUSIVE/backmatter (B.6)
- `analysis/scripts/03_regress.do` — § 3.2b NEW: drop-NE-only spec (A.3 patch)
- `analysis/scripts/05_expansion.do` — § 10.17 NEW: B.1 turnout-deviation specs (5 specs + 10k-perm RI permuting french_share); § 10.18 NEW: B.4 same-day comparison notes-file generator; § 8b NEW: B.2+B.3 RI permutations for outcome_yes_elig + outcome_margin + outcome_margin_alt; § 12.14 NEW: T20b builder; T17 footnote (col 5/6 descriptions + INCONCLUSIVE); T18 footnote (rows 8/9 descriptions); outcome_margin_alt spec added in § 8
- `analysis/scripts/07_substrate_descriptives.do` — § 2b NEW: T23b period-mean summary; § 2c NEW: post-ban wine-index differential scalar; § 3 EXTENDED: F08 window to 1830-1915 + new annotations; § 9c NEW: C.14 I.21a extraction; § 9c.2 NEW: T26 builder; § 9c.3 NEW: F10 builder; § 9c.4 NEW: c14_quantity_arc.md notes generator; T22 + T23 + F07 + F08 captions extended (substitution-INCENTIVE framing, B.5); wine_potato_ratio + wine_wheat_ratio + wine_rye_ratio variable labels updated; codebook update list extended with i21a_quantities_long

### New tables
- `analysis/results/tables/t20b_mobil_lang_relig.tex` — 5-col B.1 table (language predicts mobilization)
- `analysis/results/tables/t23b_substrate_prices_periods.tex` — 3-row period-mean H.2a summary (C.10b)
- `analysis/results/tables/t26_quantity_periods.tex` — 3-row period-mean I.21a quantities (C.14)

### Modified tables (caption/footnote updates)
- `analysis/results/tables/t17_formal_hypotheses.tex` (col 5/6 descriptions; INCONCLUSIVE label on col 6)
- `analysis/results/tables/t18_food65_robustness.tex` (rows 8/9 descriptions; INCONCLUSIVE label on row 9)
- `analysis/results/tables/t22_viticulture_subsidy.tex` (1908→1910 wine-surge regulatory-capture framing)
- `analysis/results/tables/t23_substrate_prices.tex` (substitution-INCENTIVE prefix)

### New figures
- `analysis/results/figures/f10_quantity_arc.pdf` — wine + potato + cereal time series 1837-1915 (C.14 Pillar 2 visualization)

### Modified figures (regenerated)
- `analysis/results/figures/f07_subsidy_timeseries.pdf` (caption update)
- `analysis/results/figures/f08_substrate_prices.pdf` (window extended to 1830-1915 + new annotations)

### New intermediate datasets (gitignored .dta files exist locally)
- `analysis/processed/intermediate/i21a_quantities_long.dta` (155 yearly rows 1837-1991, 8 vars)
- `analysis/results/intermediate/ri_distribution_B1_french.dta` (10,000 perms, B.1 RI)
- `analysis/results/intermediate/ri_distribution_B2_yes_elig.dta` (10,000 perms, B.2 RI)
- `analysis/results/intermediate/ri_distribution_B3_margin.dta` (10,000 perms, B.3 RI)
- `analysis/results/intermediate/ri_distribution_B3_margin_alt.dta` (10,000 perms, B.3 alt-DV RI)

Plus updated:
- `absinthe_analysis.dta` — added turnout_v67, eligible_v67, total_votes_v67, margin_alt, same_day_excess_v68_v67
- `vote67_uncleaned.dta` — added turnout/eligible/total_votes columns

### New notes files
- `analysis/output/notes/2026-05-12_verification_status.md` (Phase A status report)
- `analysis/output/notes/dispersion_descriptive_stats.md` (Phase A.8)
- `analysis/output/notes/same_day_v67_v68_comparison.md` (B.4)
- `analysis/output/notes/c14_quantity_arc.md` (C.14 Pillar 2)

### Inventory + codebook
- `analysis/results/_inventory.xlsx` — multiple new rows added (gitignored; regenerable)
- `analysis/documentation/codebook.md` — refreshed for 5 new + 3 modified datasets

## Commits made (this batch — 7 commits + 1 docs commit)

```
e577c86 round3 Phase C.14 NEW: I.21a national crop quantities (Pillar 2 quantity-side)
ddd3b6a Add auto-precompact handoffs from round 3 verification work
ad1cb1d round3 Phase C.10b: H.2a long-run extension (1830-1915, three-period structure)
f43c380 round3 Phase B.2 + B.3: RI for additional outcomes (yes_eligible, margin, margin_alt)
11f5dbf round3 Phase B.4: same-day v67 vs v68 comparison (turnout extraction + notes)
30e927e round3 Phase B.5 + B.6: framing fixes per strategist critique
52ead3c round3 Phase B.1: turnout-deviation regression (language predicts mobilization)
c823c25 round3 Phase A: verification status report + dispersion descriptive
```

Plus carryover from prior session ending at `ce371ae`:
```
ce371ae round2 docs: checkpoint + recap for Tier 1 batch (C.6-C.12) end-of-batch
```

8 commits forward of `ce371ae` (the prior recap's HEAD). 7 substantive + 1 docs.

## Substantive new findings worth surfacing for next session

1. **B.1 chain established**: `language → mobilization → vote-share` all three pieces statistically supported in current pipeline. Section 6 architecture has a clean integration prose target (C.6b Phase D).

2. **A.8 dispersion**: French-German turnout gap collapse −12.22 → −0.11 pp on #68 (12-pp swing). Within-French-wine SD = 12.51 pp >> 2pp threshold. C.6b Phase A heterogeneity decomposition is well-powered to proceed.

3. **A.3 drop-NE-only**: β = +413.20, HC3 SE 204.65, **p = 0.057 (still 10%-significant)**. Wine effect on absinthe ban is NOT just NE driving it; even excluding the absinthe heartland canton the effect survives.

4. **B.2/B.3 reconciliation finding**: April's `margin RI p=0.254 (n.s.)` came from COUNT-DV. Current pipeline's percentage-DV is significant (RI p=0.043). The two DVs give substantively different inferences because count-DV is dominated by population size. Both DVs now in pipeline; paper chooses explicitly.

5. **C.10b new finding**: Pre-phylloxera wine/potato ratio sat at PARITY (1.00). Phylloxera era pushed it to 1.29, recovery+ban era 1.34. The 1830-1862 baseline didn't exist in the prior 1875-1915 window — this is a genuinely new descriptive piece for the structural-break narrative.

6. **C.10b post-ban wine-surge scalar**: wine_idx 1905=49.1 → 1910=107.0, **+57.9 idx pts (+118%) in 5 years**. This is the regulatory-capture demand-redirection scalar referenced in T22/F07 captions.

7. **C.14 Pillar 2 framework predictions SUPPORTED**:
   - WINE production: 1418 (pre-phyl) → 1360 (phyl) → 1014 (recovery+ban) — sustained decline (-29%)
   - POTATO production: 5849 (pre-phyl) → 8060 (phyl) — substrate-supply surge (+38%)
   - Cereal: secular decline pattern, framework not strongly identified

8. **Strategist's column map for I.21a verified end-to-end**: exact-match on all 8 cited values (wine 1875=2350, 1890=1047, 1908=1033, 1910=222; potato 1875=7634, 1885=11521, 1892=10691, 1900=9029).

## Recommended next-session action

**Resume at home with one of these natural next items** (in order of marginal value):

1. **C.6c (T25 gap-collapse table)** — quickest win (~45 min). Builds the paper-text-ready French-German turnout gap table from already-computed dispersion stats. Clean output for the workshop draft.

2. **C.15 Olson × Wine** (~5-6 hrs) — largest new task in revised handoff; the new headline-candidate substantive analysis. Requires:
   - Inspecting newly-translated `$Absinthe1Data/translated/I.38_EN.xlsx` (farm-size distribution)
   - Constructing Gini coefficient on land distribution (PRIMARY measure per Galor-Moav-Vollrath et al. literature)
   - Threshold-sweep robustness (6 alternative measures)
   - Placebo battery (interaction across 14 placebo referenda)
   - NE-OVB controls (adj_neuchatel + drop-NE subsample)
   - Critical methodological discipline: GINI primary, NOT HHI; OVB confounding NOT collider bias.

3. **C.6b Phases A-D** (~3.5-4 hrs) — heterogeneity decomposition + cross-vote comparison + baseline construction robustness + integration prose.

4. **Tier 1.1 + 1.2** (~2.5 hrs) — placebo battery + fractional logit.

5. **Tier 2.1-2.4** (~2.5 hrs) — German subsample, wine subsample, alt vine measures, Moran's I.

6. **End-of-batch smoke test** (~30 min) — full run.do regeneration after all C/Tier work.

Total remaining: ~15-17 hrs focused work; ~20+ hrs with iteration overhead. Workshop deadline May 22.

**Working tree at recap**: clean (HEAD = `e577c86`). All 7 substantive commits + 1 docs commit pushed-ready on `starter`. Two carryover untracked auto-precompact files (`.handoffs/2026-05-11T23-14-10-auto-precompact.md`, `.handoffs/2026-05-12T19-02-05-auto-precompact.md`) — same as prior recap state.

**Status of MCP-Stata session**: still alive (no need to restart). All globals set ($MyProject, $Absinthe1Data); _config.do sourced; deterministic seeds preserve all RI numbers across reruns.
