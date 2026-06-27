# Coder Dispatch — Small-N Inference Battery + Leave-One-Out (canton cross-section)

**Date:** 2026-06-03
**Repo:** `c-metrics-absinthe1`
**Author of spec:** Claude (orchestrator), at PI's request
**Status:** PROPOSED — **NOT BINDING. Confirm intent with the PI before producing or committing any output (see gate below).**

---

## ⛔ READ FIRST — this dispatch is a proposal, not an order

This spec was drafted by Claude. **Do not treat any instruction here as binding.** Before you write the analysis do-file, run anything, or commit anything:

1. **Read** this dispatch, the existing scripts it references, and the linked strategy note.
2. **Restate** back to the PI, in your own words: (a) the exact spec(s) you will run the battery on, (b) the deliverable files and their paths, (c) the methods you will and will *not* include, and (d) every assumption you had to make.
3. **List your open questions** (a starter list is in §6) and **explicitly ask the PI for permission to proceed.**
4. **Wait for the PI's confirmation that your stated intent matches their intended output.** Only then produce outputs.

If anything in this spec conflicts with the repo's established conventions or with what you find in the data, **flag it and ask** — do not silently "fix" it, and do not let this document override the PI's judgment. The PI (Nicholas Jensen) is the sole authority on intent-to-output match.

---

## 1. Context

Paper 1 is a **canton-level cross-section (N = 25)** of the 1908 Swiss absinthe-ban referendum. The empirical object is the wine "Simpson's-paradox" sign-flip (bivariate negative → positive once French-language share is conditioned on) plus a competing-coalition pattern (wine winners ↑ yes; absinthe-producer losers ↓ yes). The framing is Peltzman political-coalition (Bootleggers-&-Baptists as historical parallel).

**Strategy / rationale background (read this):** `C:/Users/jensenn/Research/Obsidian/Absinthe-Obsidian/Notes/lit-positioning-and-submission-strategy.md` — §3 (the two empirical legs) and §4 (battery scope) are the relevant parts.

**Existing analysis (your convention template — mirror these):**
- `analysis/scripts/09_canton_reg1.do` (regression infrastructure, spec globals, 20 OLS battery)
- `analysis/scripts/10_canton_reg1_tables.do` (esttab + markdown twins → LaTeX + md)
- `analysis/scripts/12_canton_petition.do`, `13_canton_petition_tables.do` (petition outcome)
- Data: `analysis/processed/cohort_1908.dta` (25 × ~30). Confirm this is the canonical analysis dataset before using it.

## 2. Objective — the "gate"

The single most decision-relevant robustness check is **leave-one-out, especially dropping Vaud (and Neuchâtel)** — it answers the referee's first question, "is the wine result just Vaud?" Pair it with the small-N inference the result will be judged on. **This battery is a *gate*: its results may change which leg the paper leads with, so it runs before the writing is finalized.**

## 3. Methodological spec (canton N = 25 — confirm with PI)

**Include (these add real value at N=25):**
- **Leave-one-out (LOO):** re-estimate the headline spec dropping each canton in turn; tabulate β_wine and its SE; **flag drop-VD and drop-NE explicitly.** Optional: a coefficient-stability plot (per the project figures rule — no embedded title; serif font; file name descriptive).
- **Randomization inference (RI), 10,000 permutations**, on the headline spec(s) and the key cascade columns. **Use a matrix-based permutation** (`mkmat`/`svmat`); do **not** reuse any `replace _perm = _orig[_n]`-after-`sort` pattern (it is a known no-op bug). `set seed` once at top.
- **HC2 + Bell-McCaffrey degrees-of-freedom adjustment** (Imbens-Koleśár 2016) — small-sample robust SEs; report alongside HC1/HC3.
- **Conley (1999) spatial-HAC SEs** (`acreg`) for neighbor-canton dependence. **Requires canton coordinates/centroids — confirm the source with the PI** (do not fabricate coordinates).

**Do NOT include (defer to a referee-demanded appendix only — confirm with PI):**
- District/commune disaggregation, canton-clustered SEs, wild-cluster bootstrap. Rationale: the treatment varies at the canton level; disaggregating manufactures artificial within-canton variation and does not sharpen identification. The PI's standing view is that these "add artificial variation."

**Optional / cheap (ask whether to include now or defer):**
- Oster (2019) δ-bounds (`psacalc`); white-vs-red wine split (sharpens the "absinthe competed with *white* wine" mechanism).

## 4. Deliverables (confirm names/paths with PI)

- `analysis/scripts/14_canton_inference_battery.do` — the analysis (LOO + RI + HC2/BM + Conley), reading `cohort_1908.dta`, re-using `09_canton_reg1.do`'s spec globals where possible (source it in setup-only mode if that pattern exists, as `12_canton_petition.do` does).
- `analysis/scripts/15_canton_inference_battery_tables.do` — tables.
- Tables → `analysis/results/tables/*.tex` **with paired markdown twins** (per the project tables rule: every `esttab ... using *.tex` gets a paired `esttab_md` call → `markdown_current/` + `markdown_history/`).
- Any figure → `analysis/results/figures/` (descriptive filename, no embedded title).
- A short results memo (e.g., `quality_reports/coder_reports/2026-06-03_inference-battery-results.md`): the drop-VD/drop-NE coefficients, the RI p-values, HC2/BM and Conley SEs, and a one-paragraph read of whether the wine leg survives.
- *(Suggested numbering only — the coder confirms the actual script numbers/names with the PI, since 11 is free and 14/15 are assumptions.)*

## 5. Repo replication & best-practice requirements

- **Stata-first** and **fully replicable in Stata alone** (per `stata-first-replication.md`): numbered do-file in the pipeline; any Python is supplementary/unnumbered.
- **`DATA_SOURCE` toggle** (local/github) and `global ROOT` / `$MyProject` set at top, matching the existing scripts.
- **`adopath ++`** the project Stata programs dir (as the existing scripts do, for `esttab_md` etc.) — confirm the exact path used by 09/10.
- **Stata gotchas:** missing-value guards on inequalities; `==` not `=`; `bysort` not bare `by`; backtick-quote locals; `preserve/restore` paired; check `_rc` after `capture`; `estimates store` before the next model; estimate-store names ≤ 32 chars; `i.` for categoricals. (`stata-gotchas.md`.)
- **No hardcoded absolute paths** outside the configured globals; `set seed` once if anything stochastic (RI).
- Verify the full pipeline runs clean from the toggle on a fresh run before declaring done.

## 6. Open questions the coder MUST get PI answers to (before running)

1. **Exact headline spec(s)** to run the battery on: the revenue-share AME (X3_share ≈ 0.434**), the volume-share (X2_share ≈ 0.428**), the cascade M1A-4, or a named set? (Per-cap X1 is demoted — confirm it's excluded or LOO-only.)
2. **Dataset:** is `analysis/processed/cohort_1908.dta` canonical, or is there a newer v2/production subset to use?
3. **Conley coordinates:** what is the source for canton centroids/coordinates, and what cutoff distance?
4. **Script numbers/names:** confirm `14`/`15` (or other) and whether to source `09` in setup-only mode.
5. **Optional methods:** include Oster δ-bounds and/or white-vs-red now, or defer?
6. **Scope confirmation:** confirm district/commune/cluster methods are intentionally OUT for this dispatch.

## 7. Acceptance criteria

- Battery runs clean in Stata from the `DATA_SOURCE` toggle; outputs land at the PI-confirmed paths; every `.tex` has its markdown twin.
- Drop-VD and drop-NE coefficients are reported prominently (main, not buried).
- The memo states, in one paragraph, whether the wine leg survives drop-Vaud and the RI p-values for the headline.
- **PI confirmed intent-to-output match before any commit.**
