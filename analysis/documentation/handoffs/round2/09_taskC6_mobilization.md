# Round 2 — Task C.6: Differential mobilization analysis

**Read first**: `00_MASTER.md` (especially "swissvotes_dataset.csv content inventory" section), `08_taskC5_cleavage_index.md`
**Status**: PENDING
**Prereqs**: Tasks C.1-C.5 complete. **Phase 0 below MUST be completed before C.6.1+ can proceed.**
**Estimated time**: 2 hours total (Phase 0 = 30-45 min; Phases 1-3 = 75-90 min)
**Output**: `analysis/results/tables/t20_turnout_by_language.tex`, `t21_canton_turnout_deviation.tex`, `analysis/results/figures/f06_sameday_turnout_differential.pdf`

---

## Purpose

Add a parallel empirical channel: **turnout**. The vote-share regression captures wine-industry rent-seeking on the *intensive margin* (yes-share among voters); turnout captures cultural-political mobilization on the *extensive margin* (who showed up).

On the absinthe vote, the typical −15 to −25 pp French-vs-German turnout gap collapsed to +1.5 pp — a 17-point swing that no other vote in the 1900-1915 panel exhibits. This is *complementary* to the wine-industry mechanism, not competing. Wine-industry interests operated within the cultural framework (vote-share); cultural-political mobilization operated along the cultural divide (turnout).

**Critical methodological note** (from strategist line 307-309): vote #67 (commerce, same day as absinthe) ALSO shows the gap collapse (+4.7 pp). This is mechanically expected (same-day voters voted on both items). The differential mobilization is a *ballot-day phenomenon*, not absinthe-specific within the day. The cross-vote pattern still pinpoints the absinthe ballot day because *other-day* votes (1900-1907, late 1908, 1910-1915) all show the typical −15 to −25 gap.

---

## Phase 0 — Back-extend `01_import.do` to pull turnout for all 15 panel votes

**Per MASTER §"swissvotes_dataset.csv content inventory"**: turnout (`{canton}-bet`), eligible voters (`{canton}-berecht`), and total votes (`{canton}-stimmen`) exist in the source CSV for every Swiss federal referendum since 1848. The Python pipeline (`run_expansion.py` Expansion 1.D ~lines 195-198 and Expansion 7 ~lines 505-518 at `C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/Replication/Python/run_expansion.py`) already extracts these for the 1900-1910 panel. This Phase 0 mirrors that pattern in Stata.

While back-extending, **also pull `{canton}-jastimmen` (yes-count) and `{canton}-neinstimmen` (no-count)** so future analyses don't need another extraction pass. Final cleaned panel = canton × vote × {turnout, eligible, total, yes_pct, yes_count, no_count} for the 15 panel votes.

### Phase 0 implementation

In `01_import.do`, locate the existing section that builds `placebo_votes_uncleaned.dta` (search for "placebo" or "vote_anr_panel" — likely around the section that filters swissvotes for the 15 panel anrs). Currently it extracts `{canton}-japroz` only.

Modify it to extract additional columns. Pattern (adapt to actual structure):

```stata
* In 01_import.do, in the placebo-votes extraction block:

import delimited "$Absinthe1Data/swissvotes_dataset.csv", ///
    delimiter(";") encoding("UTF-8") clear varnames(1) bindquote(strict) stripquote(yes)

keep if anr >= 56 & anr <= 70  // 15-vote panel range

* For each canton, keep japroz AND bet AND berecht AND stimmen AND jastimmen AND neinstimmen
* Existing code keeps japroz only; extend to also keep bet/berecht/stimmen/jastimmen/neinstimmen.
* The reshape will then produce 6 cell-level columns per (canton, vote) row.

* (existing reshape long logic, extended to include new columns)
```

Verify the new columns exist in the source CSV first:

```bash
head -1 "$Absinthe1Data/swissvotes_dataset.csv" | tr ';' '\n' | grep -E "(zh|be|lu|ge)-(bet|berecht|stimmen|jastimmen|neinstimmen)" | head -10
```

Expected output: should show `zh-bet`, `zh-berecht`, `zh-stimmen`, `zh-jastimmen`, `zh-neinstimmen` columns (and same for be, lu, ..., ge). If columns exist, proceed.

### Phase 0 then propagates to `02_clean.do` `placebo_panel.dta` construction

In `02_clean.do` section 4b (around line 503-525 currently), the panel-build merges canton-level covariates from `absinthe_analysis.dta`. **Also keep the new vote-specific columns** (`turnout`, `eligible_voters`, `total_votes`, `yes_count`, `no_count`) from `placebo_votes_uncleaned.dta`. They're already in the long-format intermediate; just extend the keep list.

### Phase 0 verification

```stata
use "$MyProject/processed/placebo_panel.dta", clear
describe turnout eligible_voters total_votes yes_count no_count   // should all exist
tab anr if !missing(turnout)                                       // should show all 15 anrs
assert _N == 25 * 15  // 375 rows preserved
assert !missing(turnout)
assert !missing(eligible_voters)
assert !missing(total_votes)
* These are HARD asserts — if they fail, the back-extension is incomplete
```

### Phase 0 commit

```
round2 Task C.6 Phase 0: back-extend swissvotes panel extraction

Extends 01_import.do to extract per-canton per-vote turnout, eligible
voters, total votes, yes-count, and no-count for all 15 votes in the
1900-1910 panel range. Previously only yes-pct was extracted.

These columns exist in the source swissvotes_dataset.csv for every
referendum since 1848 (per orchestration follow-up); the Python
pipeline run_expansion.py Expansions 1.D and 7 already extract them.
This commit mirrors that extraction in Stata so the canton-level
panel can support turnout-based analyses.

Final placebo_panel.dta schema: canton × vote × {yes_pct, yes_frac,
turnout, eligible_voters, total_votes, yes_count, no_count} for 15
votes; 375 rows × ~10 vote-specific cols + canton-level covariates.

5 new asserts (column existence + non-missing). Pipeline 39+5=44
assertions pass.
```

This Phase 0 is a complete commit on its own — DO NOT bundle it with the C.6 analytical phases. It's a pure data-pipeline change with its own assertion battery.

---

## Phase 1 — C.6.1 Cross-vote turnout-by-language table

Now using the back-extended panel:

```stata
**# 10.16 Round-2 Task C.6.1: Cross-vote turnout by language group
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear

    * STRICT canton-set definition (per strategist; differs from C.5 threshold)
    gen byte french_canton_strict = inlist(canton_code, "VD", "VS", "NE", "GE")
    gen byte italian_canton = (canton_code == "TI")
    gen byte german_canton_strict = !french_canton_strict & !italian_canton

    * Note FR (Fribourg) is bilingual but treated as German per strategist line 334.
    * Result: 4 French / 20 German / 1 Italian (TI excluded from both groups).

    * Per-vote turnout means by language group
    bysort anr: egen turnout_fr = mean(turnout) if french_canton_strict == 1
    bysort anr: egen turnout_ge = mean(turnout) if german_canton_strict == 1
    bysort anr: egen turnout_fr_v = max(turnout_fr)
    bysort anr: egen turnout_ge_v = max(turnout_ge)
    gen turnout_lang_gap = turnout_fr_v - turnout_ge_v

    * Collapse to one row per vote
    collapse (first) turnout_fr_v turnout_ge_v turnout_lang_gap vote_year vote_label, by(anr)
    rename turnout_fr_v turnout_fr
    rename turnout_ge_v turnout_ge

    gen byte absinthe_vote = (anr == 68)
    gen byte same_day      = (anr == 67)
    gen byte alcohol_reg   = (anr == 63)

    * Test 1: is absinthe vote (#68) an outlier vs other-day votes?
    gen byte other_day = (anr != 67 & anr != 68)
    summ turnout_lang_gap if other_day == 1
    local mean_other = r(mean)
    local sd_other = r(sd)
    summ turnout_lang_gap if absinthe_vote == 1
    local gap_68 = r(mean)
    local z_68 = (`gap_68' - `mean_other') / `sd_other'
    di "Absinthe gap z-score vs other-day votes: " %6.2f `z_68'

    save "$MyProject/processed/intermediate/turnout_by_language.dta", replace
    restore
}
```

### t20 builder

19-row table (votes 56-74 if all available; otherwise 15 rows for the 1900-1910 panel range):
- Cols: anr, vote_year, vote_label, turnout_fr, turnout_ge, turnout_lang_gap, marker
- Marker shows `<-- ABSINTHE` for #68, `<-- same day` for #67, `<-- ALCOHOL REG 1903` for #63

Caption (from strategist line 452-453, adapted):
> Cross-vote turnout by language group, 1900-1910. The typical French-German turnout gap on Swiss federal referenda in this period is −15 to −25 percentage points (where French-cantons-defined as the strict {VD, VS, NE, GE} set, distinct from the threshold definition in Table 19). On the 1908 absinthe ballot day, this gap collapsed for both items voted simultaneously: the absinthe ban (#68, gap = +X pp) and the commerce article (#67, gap = +Y pp). The collapse is a same-day phenomenon — voters who showed up to vote on absinthe also voted on the same-day commerce item — but isolates the specific ballot day on which French-Swiss mobilization was anomalously high. No other vote in the panel shows comparable language-cleavage attenuation, supporting absinthe-specific cultural-political mobilization complementary to the wine-industry rent-seeking effect documented in the vote-share regressions.

### Acceptance for C.6.1

- [ ] T20 produced with all 15 panel votes (or 19 if extracting #56-74; depends on Phase 0 scope)
- [ ] gap_68 ≈ +1.5 pp (per strategist acceptance line 538; verify within ±1 pp)
- [ ] gap_67 ≈ +4.7 pp (within ±1 pp)
- [ ] |gap_68| z-score against other-day votes ≥ 1.5 (strategist line 539)
- [ ] Other-day gaps in [-25, -10] pp range

---

## Phase 2 — C.6.2 Clean turnout-deviation regression

```stata
**# 10.17 Round-2 Task C.6.2: Turnout-deviation regression
*------------------------------------------------------------------------------*
{
    * Compute per-canton baseline (mean turnout 1900-1910 excl #68)
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr >= 56 & anr <= 70 & anr != 68
    collapse (mean) baseline_turnout = turnout, by(canton_code)
    save "$MyProject/processed/intermediate/canton_baseline_turnout.dta", replace
    restore

    * Pull absinthe turnout
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr == 68
    keep canton_code turnout
    rename turnout absinthe_turnout
    save "$MyProject/processed/intermediate/canton_absinthe_turnout.dta", replace
    restore

    * Merge into the canton-level dataset
    use "$MyProject/processed/absinthe_analysis.dta", clear
    merge 1:1 canton_code using "$MyProject/processed/intermediate/canton_baseline_turnout.dta", nogen
    merge 1:1 canton_code using "$MyProject/processed/intermediate/canton_absinthe_turnout.dta", nogen

    gen turnout_dev = absinthe_turnout - baseline_turnout
    label var turnout_dev "Absinthe turnout - mean(non-absinthe 1900-1910 turnout) per canton"

    * Headline regression (replicates user's Python output)
    reg turnout_dev vineyard_per_cap french_share, vce(hc3)
    estimates store turnout_dev_clean
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "turnout_dev_clean", model, "ols")

    * v2 covariates: + catholic
    reg turnout_dev vineyard_per_cap french_share catholic_share, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "turnout_dev_v2_basic", model, "ols")

    * v2 full: + net_migration + ln_pop
    reg turnout_dev vineyard_per_cap french_share catholic_share ///
        net_migration_pre_vote ln_pop, vce(hc3)
    regsave using "`results_exp'", t p autoid append ///
        addlabel(spec, "turnout_dev_v2_full", model, "ols")

    * RI for both vine_per_cap and french_share
    set seed 20260430
    ritest vineyard_per_cap _b[vineyard_per_cap], reps(10000) seed(20260430): ///
        reg turnout_dev vineyard_per_cap french_share catholic_share, vce(hc3)
    local ri_p_vine = r(p)

    set seed 20260430
    ritest french_share _b[french_share], reps(10000) seed(20260430): ///
        reg turnout_dev vineyard_per_cap french_share catholic_share, vce(hc3)
    local ri_p_french = r(p)

    di "Mobilization regression — RI p-values:"
    di "  vineyard_per_cap: " %6.4f `ri_p_vine' " (expected: not significant; user's Python: 0.557)"
    di "  french_share:     " %6.4f `ri_p_french' " (expected: significant or marginal; user's Python: 0.117)"
}
```

### Expected results (per strategist line 432-437)

- R² ≈ 0.262, N = 25
- const ≈ −10.4*** (avg canton showed 10.4 pp LOWER turnout on absinthe vs baseline)
- vine_per_cap = +153.5 (n.s., t≈0.59) — vineyard does NOT predict turnout deviation
- french_share = +14.0 (p≈0.12, marginally significant) — French cantons mobilized differentially
- French-canton mean deviation: +9.0 pp; German-canton mean deviation: −5.1 pp; differential: +14.1 pp

If results materially deviate from these targets (e.g., R² < 0.15 or vine_per_cap is significant), investigate — possible spec/data issue.

### t21 builder

Per-canton turnout deviation table (one row per canton, sorted by deviation descending):
- Cols: canton name, code, vine_per_cap, baseline_turnout, absinthe_turnout, turnout_dev
- Highlight {VD, VS, NE, GE, TG, SO} as positive-deviation cantons (per strategist line 470)

Expected pattern: NE +20.0, SO +17.4, VD +10.9, GE +9.5; most German cantons in [-15, -5] range.

---

## Phase 3 — C.6.3 Same-day cantonal turnout differential figure

```stata
**# 10.18 Round-2 Task C.6.3: Same-day turnout differential (#68 vs #67)
*------------------------------------------------------------------------------*
{
    preserve
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr == 67 | anr == 68
    keep canton_code anr turnout
    reshape wide turnout, i(canton_code) j(anr)
    gen turnout_diff = turnout68 - turnout67

    gen byte french_canton_strict = inlist(canton_code, "VD", "VS", "NE", "GE")
    gen byte italian_canton = (canton_code == "TI")

    save "$MyProject/processed/intermediate/sameday_turnout_diff.dta", replace
    restore
}
```

### f06 builder

Horizontal bar chart:
- Y-axis: canton (sorted by `turnout_diff` ascending)
- X-axis: turnout_diff (= turnout_68 − turnout_67)
- Color: French-speaking cantons in red; German cantons in blue; TI in gray
- Annotate cantons with |diff| > 5 pp (Glarus +11.9, St. Gallen +7.6, Schaffhausen +7.3, Bern +6.9, Basel-Stadt +6.8, Graubünden +5.7 per strategist line 461)

Caption template (from strategist line 463-464):
> Same-day differential turnout, 5 July 1908. Each canton's turnout on the absinthe ban (#68) minus its turnout on the commerce article (#67), held simultaneously with the same electorate. Several German-speaking cantons (Glarus, St. Gallen, Schaffhausen) show meaningfully higher turnout on the absinthe ballot, indicating absinthe-specific extra voters within otherwise identical voting conditions. The contrast with vineyard-canton patterns suggests the extra mobilization ran along cultural rather than wine-industry lines.

---

## Acceptance criteria (full task)

(per strategist lines 472-547; subset matched to this implementation)

- [ ] Phase 0 back-extension complete: panel has turnout, eligible_voters, total_votes, yes_count, no_count for all 15 votes
- [ ] T20 cross-vote turnout-by-language: 15-19 rows, #68 and #67 flagged
- [ ] gap_68 ≈ +1.5 pp; gap_67 ≈ +4.7 pp (per strategist acceptance line 538)
- [ ] |gap_68| z-score reported (expected |z| > 1.5)
- [ ] F06 same-day cantonal differential figure produced with Fr/Ge/TI distinct colors
- [ ] T21 per-canton deviation table: NE +20.0, SO +17.4, VD +10.9, GE +9.5 confirmed (within ±1 pp)
- [ ] Clean regression replicates Python: const ≈ −10***, vine_per_cap n.s., french_share marginal
- [ ] French canton set strictly {VD, VS, NE, GE}; TI excluded; FR treated as German (DOCUMENTED in t20 + t21 captions to distinguish from C.5 threshold definition)
- [ ] CONTEXT.md updated with complementary-mechanism framing (intensive vote-share + extensive turnout)
- [ ] CONTEXT.md notes the same-day ballot-day phenomenon and cross-vote pinpointing
- [ ] All new asserts pass

## Pitfalls

1. **Phase 0 is the riskiest part.** The CSV-column verification (via `head -1 | tr ';' '\n' | grep`) is essential before assuming the back-extension will work. If columns are named differently (e.g., `bet-zh` instead of `zh-bet`), adapt the rename pattern.

2. **`reshape wide`** in Phase 3 may produce unexpected variable names if `anr` has decimal formatting. Verify with `describe` after reshape; rename `turnoutfloat68` → `turnout68` if needed.

3. **`net_migration_pre_vote` in `absinthe_analysis.dta`** — verify the variable name (might be `net_migration_1900_10` or `net_migration_per_cap`). Use whichever is the per-canton economic-vitality control already in the dataset.

4. **`ritest` runtime**: 2 ritest calls × 10k reps × N=25 ≈ 1-2 min. Acceptable. If much longer, check `ritest` syntax — the `_b[varname]` test-statistic spec might need adjustment.

5. **Documenting the dual-French-definition divergence** is critical. C.5 uses `french_share >= 0.5` (5 cantons typically); C.6 uses strict {VD, VS, NE, GE} (4 cantons). A naive reader will conflate these. Both are defensible; t19, t20, and t21 captions must each document which definition they use and that the other table uses a different one.

## Commit message templates

Two commits for this task (Phase 0 separate from analytics):

**Phase 0 commit** (see Phase 0 section above for template).

**Phases 1-3 commit**:

```
round2 Task C.6 Phases 1-3: Differential mobilization analysis

Adds the extensive-margin (turnout) channel as complementary to the
intensive-margin (vote-share) wine-industry effect. Cultural-political
mobilization runs along the language divide; wine-industry rent-seeking
runs across it.

Phase 1 (C.6.1) — Cross-vote turnout-by-language table T20:
  - gap_68 = +X.X pp [target: ~+1.5; actual: <X>]
  - gap_67 = +X.X pp [target: ~+4.7; actual: <X>]
  - mean(gap | other_day) = X.X pp; SD = Y.Y pp
  - z-score(gap_68): X.X (expected |z| > 1.5)

Phase 2 (C.6.2) — Turnout-deviation regression + T21:
  - turnout_dev = absinthe_turnout - mean(1900-1910 baseline) per canton
  - Headline regression (vine + french): R² = X.XX
    const = X.X (***), vine = +X (n.s.), french = +X (p=Y)
  - RI p-values: vine = X.XXX, french = X.XXX
  - Replicates user's Python output within tolerance

Phase 3 (C.6.3) — Same-day cantonal differential figure F06:
  - turnout_diff = turnout_68 - turnout_67 per canton
  - Top positive-diff cantons (German): GL, SG, SH, BE, BS, GR
  - F06 horizontal bar chart with Fr/Ge/TI colored distinctly

CONTEXT.md updated:
  - Complementary-mechanism framing (intensive + extensive margins)
  - Same-day ballot-day phenomenon noted
  - Dual French-canton definition documented (C.5 threshold vs C.6 strict)

t20_turnout_by_language.tex, t21_canton_turnout_deviation.tex,
f06_sameday_turnout_differential.pdf produced.

5 new asserts (gap_68 ≈ +1.5, gap_67 ≈ +4.7, z > 1.5, NE deviation ≈ +20,
clean-reg const negative significant). Pipeline 44+5=49 assertions pass.
```

## Done when

- Phase 0 commit pushed; pipeline passes back-extension asserts
- Phases 1-3 commit pushed; T20, T21, F06 all generated; all asserts pass
- Move to `10_taskD_documentation.md`
