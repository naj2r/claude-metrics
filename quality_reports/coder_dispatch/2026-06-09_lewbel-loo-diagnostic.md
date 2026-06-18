# Coder Dispatch — Lewbel IV: LOO + F/LM-tension diagnostic (decision-gating)

**Date:** 2026-06-09
**Repo:** `c-metrics-absinthe1` (Stata-first)
**Dataset:** `cohort_1908_workshop.dta` (N=25) — same as feasibility Task 4
**Status:** **DIAGNOSTIC ONLY.** Light run (seconds), single awaited Stata op. No paper / main-analysis / table-of-record edits. Do NOT touch the parked 10k RI.

## Why
The feasibility run returned a surprise: Lewbel IV on `X3_share` is **not weak** — KP rk Wald F = 222, Hansen J p = 0.13, coef 0.571 [0.27, 0.88]. **But** the KP under-identification LM p = 0.146 is in tension with that F, at N = 25. A huge weak-ID Wald F alongside a non-rejecting under-ID LM often means the first stage rests on one or two influential observations — **NE (the absinthe heartland) is the prime suspect.** Before the PI decides whether Lewbel earns an (online-appendix) robustness row, we need to know: is the identification real, or one-canton-driven?

## TASK 1 — Leave-one-out on the Lewbel IV (the crux)
Re-run the **same Lewbel spec as feasibility Task 4** (`ivreg2h` on `X3_share` with the col-5 controls), dropping each canton one at a time (25 fits). For each dropped canton, record: `X3_share` coef, robust SE, KP rk Wald F, KP under-id LM p, Hansen J p.
- Report: **min/max coef** across the 25 fits; does the coef keep the **same sign** and stay **significant** (5% / 10%)? does the **F stay strong** (say > 20)?
- **Call out the drop-NE fit explicitly**, plus any single drop that flips significance or craters the F.
- Mirror the existing `T_loo_gate` logic/format if convenient (this is the same discipline, applied to the IV).

## TASK 2 — Characterize the F-vs-LM tension
- Number of generated instruments; first-stage joint relevance.
- Is the F = 222 driven by one generated instrument / one canton? (The LOO-F range from Task 1 answers most of this.)
- One-paragraph interpretation: small-N artifact vs. genuine rank fragility.

## Verdict requested (drives the PI's appendix-row-vs-drop call)
- **ROBUST** = coef stable, same sign, still significant, F stays strong across all 25 LOO fits (incl. drop-NE) → Lewbel is genuine corroboration of the wine headline via a route needing no common support.
- **FRAGILE** = coef / significance / F collapses on dropping NE or any single canton → not robust at N = 25.

**PI decision rule (for your framing/calibration):** Lewbel is **NOT going in the main text** either way. ROBUST → *one online-appendix row + a single main-text sentence* (endogeneity-robustness; explicitly exploratory; untestable `cov(Z,ε²)=0` assumption noted). FRAGILE → drop, or a one-line "not robust at N=25, available on request." So scope the deliverable to an **appendix-grade check**, not a main result.

## Deliverable
Append a "Lewbel LOO diagnostic" section to the feasibility memo (`quality_reports/coder_reports/2026-06-09_feasibility-ipw-ebal-lewbel.md`), or a short addendum memo, with the LOO table + the ROBUST/FRAGILE verdict + key numbers (coef range, F range, the drop-NE row).

## Constraints
Diagnostic only; single awaited Stata op (light — distinct from the deferred 100-min RI); robust SEs; confirm/print any sample assertions; no edits to the paper, main analysis, or tables of record.
