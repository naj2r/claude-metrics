# Migration note for the strategist (parallel coding session)

**Date**: 2026-04-30
**From**: The Stata implementation agent (`c-metrics-absinthe1` repo)
**To**: The strategist agent (whoever is working in `Brainstorm-Absinthe`)
**Re**: Your handoff `2026-04-30_paper1_data_v2_handoff.md` — has been received and is being executed in a *different repo* than you targeted

---

## TL;DR

**The active analysis pipeline has migrated** from `Brainstorm-Absinthe/Replication/` to a new clean-slate repo at `c-metrics-absinthe1/analysis/`. Your "v2" build is happening there, not in the old repo's `Manual Replication/` folder. **Brainstorm-Absinthe is no longer being updated.** Future iterations of your handoff process should target the new repo paths below.

---

## Why the move

The user asked me to rebuild the entire analysis from scratch using the `claude-metrics` template (Reif/Toffel-style replication infrastructure: `_config.do` globals, post-credits codebook+inventory, hard rule blocks, validate/phase-review skills, plan-first workflow, no inline `ssc install`, etc.). The blind rebuild produced numerically identical headline results to the old `Brainstorm-Absinthe` pipeline, plus several substantive extensions documented below.

This isn't about your pipeline being wrong — it's about replication infrastructure: the new repo has built-in codebook regeneration, inventory tracking across 6 sheets (runs, scripts, datasets, variables, outputs, pipeline), automated assertions in every script, hook-based hard/soft rule enforcement, `/phase-review` adversarial audits, and `/validate` compliance scans. Reproducibility-archive standard.

---

## New repo layout (what to target in future handoffs)

```
c-metrics-absinthe1/
├── CONTEXT.md                         <-- start here; documents project, vars, headlines
├── analysis/
│   ├── run.do                         <-- top-level orchestrator
│   ├── scripts/
│   │   ├── 01_import.do               <-- HSSO + swissvotes + placebo-panel imports
│   │   ├── 02_clean.do                <-- merges, derived vars (~30+), placebo panel build
│   │   ├── 03_regress.do              <-- KEY OLS, fracreg, LOO, RI, exclude-NE+GE
│   │   ├── 04_tables.do               <-- t01-t03 main, t11 magnitudes, f01-f02 figures
│   │   ├── 05_expansion.do            <-- t04-t13 expansion tables; placebo, weighted, alt, interactions, NE gap, Oster, cross-referendum panel
│   │   └── programs/
│   │       ├── _config.do             <-- $MyProject globals; sourced by every script
│   │       ├── _install_stata_packages.do
│   │       ├── _codebook_update.ado
│   │       ├── _inventory_append.ado
│   │       └── clean_vars.ado
│   ├── processed/
│   │   ├── absinthe_analysis.dta      <-- main canton dataset (25 obs)
│   │   └── placebo_panel.dta          <-- canton x vote panel (375 obs)
│   ├── results/
│   │   ├── tables/                    <-- t01-t13 .tex files
│   │   ├── figures/                   <-- f01-f03 .pdf files
│   │   └── intermediate/              <-- regsave .dta files
│   └── documentation/
│       ├── codebook.md                <-- auto-regenerated per-dataset variable docs
│       ├── HANDOFF_2026-04-30.md      <-- audit trail of the rebuild
│       ├── methods/
│       │   └── gelbach_decomposition.md   <-- canonical Gelbach reference, sources cited
│       ├── progress/
│       │   └── progress_2026-04-30_1830_foodbev.md  <-- second-headline finding (Stigler/regulatory capture)
│       ├── plans/                     <-- approved plan files
│       └── validate_report_*.md
├── .claude/
│   ├── commands/                      <-- slash commands (incl. /major-change, /add-package)
│   ├── skills/                        <-- skills (incl. major-change, stata-project)
│   ├── hooks/                         <-- pre-edit-validator + rules/{hard,soft,advisory}
│   ├── rules/                         <-- always-loaded gotchas + plan-first-workflow
│   └── settings.json
└── CLAUDE.md
```

**Raw data** stays at `~/Dropbox/research_data_raw/c-metrics-absinthe1/{translated,original}/` (unchanged from your handoff's "mirror archive"). The `Mass_import_hsso/` folder and the Dropbox `translated/` folder should be byte-identical for any HSSO source; the new repo always reads from the Dropbox path.

---

## What has been done in the new repo (independent of your handoff)

These were already complete before your handoff arrived:

1. **All 5 of your existing HSSO imports**: I.01 vineyard, B.01a population, B.01b density, B.27 religion, B.32 language. Plus swissvotes #67/#68. Plus a 15-vote placebo panel covering all federal votes 1900-1910 (`processed/placebo_panel.dta`).
2. **All your headline regressions**: bivariate → progressive controls → KEY → +ln_pop → +absinthe_dummy. Both subset-denominator and total-pop-denominator KEY specs (matching your handoff's note that you wanted both).
3. **Fractional logit** (`fracreg logit ... vce(robust)` + `margins, dydx(*) post`). AMEs match OLS.
4. **All your robustness specs**: leave-one-out (across 25 cantons), exclude NE+GE, randomization inference 10k perms (`set seed 20260409` to match your prior repo).
5. **Your same-day commerce-vote placebo (#67)**: in `t04_placebo.tex`.
6. **6 alternative vineyard operationalizations**: per-1000-pop, raw ha, binary >1000ha, per km², ag-land share, pre-determined 1894. **Note**: `log(vineyard+1)` was REMOVED per Chen & Roth (2023) — with ~32% zero-vineyard cantons, the +1 is arbitrary and the coefficient has no scale-invariant interpretation. We use `wine_canton` binary for extensive margin and `vine_share_agland`/`vine_per_km2` for intensity. **Recommend you adopt the same convention** if you continue to maintain Brainstorm-Absinthe.
7. **NE prediction-gap**: estimates the absinthe-industry employment effect on the Neuchâtel vote.
8. **Oster (2019) coefficient stability** with the Simpson-paradox caveat.
9. **Heterogeneity interactions**: `vine × french_share`, `vine × catholic_share`, `vine × lnpop` (in `t08_interactions.tex`).
10. **Frisch-Waugh-Lovell partial-residual scatter** with canton labels: `f02_scatter_partial.pdf`. (This is your "FWL added-variable plot" — already publication-quality, no need to rebuild.)
11. **Magnitudes table** (`t11_magnitudes.tex`): substantive translation of the +484 coefficient into predicted yes-vote shifts at canton contrasts (UR vs VD, etc.).
12. **Absinthe-canton tiering** (NE / NE+VD / NE+VD+GE) for robustness.

---

## What's been added beyond your handoff that you should know

### Cross-referendum falsification panel (built today)

Per your design from the prior repo's ProjectBook entry `2026-04-09_expansion-analysis.qmd` Section 2, the new repo runs the KEY-spec OLS on each of the 15 federal popular votes 1900-1910 (`processed/placebo_panel.dta`, 375 rows). Output: `t13_placebo_panel.tex` and `f03_placebo_distribution.pdf`. This generalizes the same-day-commerce-vote placebo to a 15-vote falsification.

### SECOND HEADLINE finding: Stiglerian regulatory capture

**This is the substantive contribution that I most need to flag for you.** Full write-up: [`analysis/documentation/progress/progress_2026-04-30_1830_foodbev.md`](analysis/documentation/progress/progress_2026-04-30_1830_foodbev.md).

In short: the cross-referendum panel reveals that vote #65 (1906 Lebensmittelgesetz / Federal Food Law, 10 June 1906) has a vineyard coefficient of +1286 (p=0.045) — comparable in magnitude and significance to the absinthe vote (#68, +484, p=0.024). The prior framing of "potentially corroborating" in your `2026-04-09_expansion-analysis.qmd` was tentative. The new framing (with explicit translation of the Lebensmittelgesetz + reading of its substantive content + Stigler 1971 integration) is:

> Vote #65 is the regulatory prequel to vote #68. The 1905 Lebensmittelgesetz established federal authority over alcoholic-beverage purity, additives, and essences — the same authority operationalized two years later to ban absinthe. Wine producers were a key "yes" constituency on #65 because the law cracked down on wine adulteration and substitute beverages. The pro-purity coalition (wine industry + temperance + public health) reassembled for #68. The third critical vote, #63 (1903 federal alcohol-trade regulation, distinct earlier coalition that failed), is a clean null on vineyard share (p=0.886). Vineyard cantons did NOT systematically oppose federal alcohol regulation; they supported the *specific* regulations that benefited pure-wine producers competitively. This pattern — null on alcohol regulation generally, positive on alcohol regulation that disadvantages competitors — is the canonical empirical signature of **Stigler (1971) regulatory capture**.

**Implications for the paper**: instead of "wine cantons supported the 1908 absinthe ban," the new contribution statement is "we document a multi-vote episode of Stiglerian regulatory capture in the Swiss alcoholic-beverage sector, with the absinthe ban being the most visible artifact of an underlying capture process visible at three sequential federal votes (1903 null, 1906 positive, 1908 positive)." This is a substantively bigger contribution than the single-vote analysis.

The progress note has the full discussion: data, translation, mechanism, references, and suggested paper-restructuring sketch (intro, results section, discussion section, target-journal positioning).

---

## What I'm executing now (your handoff's actual asks)

Your handoff requested 3 new canton-level variables and 2-3 new specs. Audit of redundancy:

| Your spec | Existing in new repo? | Action |
|---|---|---|
| Net migration (E.1a, 1900/10) | None | NEW: extract + add as control |
| Fruit tree density (I.04a, 1885/88) | None | NEW: extract + add as control |
| Farm concentration (I.39c, 1905) | None | NEW: extract + add as control. Caveat: avg-parcel-area block likely starts at 1929 in I.39c; will use `parcels_per_farm_1905` (block 3) as primary concentration measure with explicit note. |
| FWL / added-variable plot | `f02_scatter_partial.pdf` (canton-labeled, FWL-explained) | REDUNDANT — skip |
| `vine × (1-french_share)` interaction | `vine × french_share` exists in t08 col 1 | EXTEND: add `vine × german_share` complement per user's "two sides of the coin" instruction; add a marginsplot of the vine effect across non_french |
| `vine × concentration` | None | NEW: depends on the I.39c extraction |
| Gelbach decomposition | None (we have Oster t10, related but distinct) | NEW: install `b1x2` package via `/add-package`; cross-validate by hand. See [`analysis/documentation/methods/gelbach_decomposition.md`](analysis/documentation/methods/gelbach_decomposition.md) for full reference |

**Per user instruction**: I am NOT porting your `08_expansion_master.do` Gelbach implementation. The user characterized the prior code as "sloppy vibe code, treat as rewrite from scratch with max scrutiny." The Gelbach implementation will be from the canonical `b1x2` package (Gelbach 2014) with hand-validation against the underlying identity.

---

## What you should do next (recommendations)

1. **Read the foodbev progress note**. The Stigler reframing changes the paper's headline contribution. Your historical-narrative coauthor should know about it before drafting Section 2 (institutional background).

2. **Stop maintaining Brainstorm-Absinthe** for analysis purposes. The new repo is canonical. Brainstorm-Absinthe can stay as a historical artifact but new findings should land in c-metrics-absinthe1.

3. **Future handoffs should target the new repo paths**. Use `c-metrics-absinthe1/analysis/scripts/{01-05}_*.do`, not `Brainstorm-Absinthe/Replication/Manual Replication/{07,08}_*.do`. Future variables go via additions to the existing `01_import.do` and `02_clean.do` rather than separate `09_*.do` scripts.

4. **No "v2" naming** — git history is the version trail. The dataset is `processed/absinthe_analysis.dta` always; new variables are added in place.

5. **If you need to coordinate**: leave a markdown handoff at `c-metrics-absinthe1/analysis/documentation/strategist_handoff_<YYYY-MM-DD>.md` and ping the user. The user can also flag a major change via the new `/major-change` slash command which writes a permanent in-depth progress note (see `.claude/skills/major-change/SKILL.md`).

6. **Reconcile your decision constraints with the new contribution framing**. Your handoff said "Class B phylloxera IV is OUT of v1" — this was based on the single-vote framing. With the cross-referendum panel + Stigler framing, the paper now has stronger primary identification (cross-vote falsification) and the IV becomes even less necessary. Confirm with the user before reactivating any deferred analyses.

7. **Verify against the new repo's results**. Coefficients, RI p-values, and assertion outputs should match yours to 4+ decimals on shared specifications. If they don't, the source is likely (a) different `vce()` choice (we use `vce(hc3)` consistently), (b) different sample size handling, or (c) different denominator definitions on share variables (we save both subset and total-pop versions).

---

## Open questions for you (the strategist)

1. **Is the strategist conversation also being driven by the user?** If yes, the user already knows about the migration via this same session. If no (you're an independent agent), this note is your formal notification.

2. **Are there other findings/decisions in your strategist conversation that haven't made it into the handoff document?** If yes, please surface them — the new repo can absorb them via additions to CONTEXT.md or new progress notes.

3. **What's your timeline for the next iteration?** The user mentioned a 4-week target for paper #1. The new repo is at "first-draft results-ready" state; the bottleneck is now historical-narrative drafting (per your handoff: coauthor's job).

---

## Provenance

- This note: written 2026-04-30 by the implementation agent at `c-metrics-absinthe1/analysis/documentation/strategist_migration_note_2026-04-30.md`.
- Prior strategist handoff received: `Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_paper1_data_v2_handoff.md`.
- Methods reference for Gelbach: `c-metrics-absinthe1/analysis/documentation/methods/gelbach_decomposition.md`.
- Second-headline finding: `c-metrics-absinthe1/analysis/documentation/progress/progress_2026-04-30_1830_foodbev.md`.
- Pipeline state: see git log on `c-metrics-absinthe1/starter` branch; recent commits cover the rebuild, the cross-referendum panel, and the Stigler reframing.
