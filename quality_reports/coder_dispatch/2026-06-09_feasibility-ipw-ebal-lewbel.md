# Coder Dispatch — Feasibility check: IPW · Entropy balancing · Lewbel IV

**Date:** 2026-06-09
**Repo:** `c-metrics-absinthe1` (Stata-first per project rule)
**Dataset:** `processed/cohort_1908_workshop.dta` (canton cross-section, **N = 25**) — the dataset behind the inference-battery tables of record (`T_producer_cascade`, `T_loo_gate`, the FL cascade), built by `23_canton_inference_battery_tables.do`.
**Status:** **DIAGNOSTIC ONLY.** No new headline results, no edits to the main analysis or paper. This run *decides* whether each method is viable before any implementation.

> **CORRECTION (2026-06-09, post-coder-flag).** An earlier draft of this dispatch named the treatment `absinthe_dummy` and called it "8 producer cantons." That conflated two *different* variables in two *different* datasets:
> - **`absinthe_dummy`** (in `absinthe_analysis.dta`) = **NE only** (`gen byte absinthe_dummy = (canton_code=="NE")`, `02_clean.do:266`), labeled "heartland; conservative." Its broadest sibling `absinthe_dummy_any` (NE+VD+GE) tops out at 3 cantons. **None of these is the paper's headline producer treatment** — the name reads like "produces absinthe (binary)" but it encodes "is Neuchâtel."
> - **`abs_producer`** (in `cohort_1908_workshop.dta`) = `cov2_total_share > 0` — "canton has any Milliet-listed absinthe purchases" (`09_canton_reg1_workshop.do:411`). **This is the treatment behind `T_producer_cascade`**, and per the coder it = 8 cantons.
>
> **Use `cohort_1908_workshop.dta` + `abs_producer`.** Throughout Tasks 1–4, read every `absinthe_dummy` as **`abs_producer`**; read `french_share`/`catholic_share`/`ln_pop` as the **inference-battery col-5 controls** (confirm exact names via `describe` — script 23 uses `cov1`/`cov3`/`ln_density` aliases); wine = **`X3_share`**; interaction available = **`fr_x_producer`**; outcome = **`Y1`/`Y1_frac`**. **First command:** `tab canton_code if abs_producer==1` — print the realized treated set into the memo so the 8-canton definition is on the record and never re-conflated.

---

## Why this dispatch
Post-workshop, three robustness/identification methods are on the table for the wine / absinthe-producer result. Before implementing any of them we need feasibility numbers, because the **producer ⟂ language separation** almost certainly creates:
- a **common-support failure** that defeats reweighting (IPW, entropy balancing), and
- a **weak-instrument** problem for Lewbel IV at N=25.

Known going in: corr(producer, French) ≈ 0.71; producers average ~51% French vs ~2% for non-producers; **all four French-majority cantons (VD, VS, NE, GE) are producers, and zero French-majority cantons are non-producers.** The job is to **quantify** this precisely so each method can be classified: **(a) corroborating robustness check, (b) documented infeasibility/limit, or (c) drop.**

## Variables (confirm with `describe`; names from `02_clean.do` / `03_regress.do`)
| Role | Variable |
|---|---|
| Outcome | `yes_pct` (0–100, OLS) · `yes_frac` (0–1, fracreg) |
| Producer (binary treatment) | `abs_producer` = `cov2_total_share>0` (Milliet "any absinthe purchases"; coder reports 8 cantons) — **NOT** `absinthe_dummy` (= NE only). See CORRECTION above. |
| Language | `french_share` (continuous, Fr/(Fr+Ger), 1900) · `lang_french` (dummy: VD VS NE GE) |
| Religion control | `catholic_share` (or `protestant_share` — use the cascade's cov3) |
| Density / scale | `ln_pop` (and `cov_land` = ln area, as in col 5) |
| Wine (headline, continuous — endogenous for Lewbel) | `X3_share` (national wine **revenue** share) [also `X2_share` volume, `vineyard_per_cap`] |

## Tooling
- `which ebalance` (Hainmueller) · `which ivreg2h` (Baum–Schaffer–Lewbel) · `which teffects` (built-in).
- If missing: `ssc install ebalance` · `ssc install ivreg2h` (deps: `ssc install ivreg2`, `ssc install ranktest`).
- Log the installed versions.

---

## TASK 1 — Common-support / overlap diagnostics  *(the crux)*
Covariate set = the col-5 controls (`french_share`, `catholic_share`, `ln_pop`).
1. `tab absinthe_dummy lang_french, row col` — **count the off-diagonal "French-majority & non-producer" cell** (expected 0).
2. `tabstat french_share, by(absinthe_dummy) stats(n mean sd min max p25 p75)` — quantify the 51%-vs-2% gap and the [min,max] ranges; identify the overlap region (low-French German producers vs German non-producers).
3. Propensity overlap:
   - `logit absinthe_dummy french_share catholic_share ln_pop` — **report any "perfectly predicts / observations dropped" (separation) messages.**
   - `predict ps, pr` ; `tabstat ps, by(absinthe_dummy)` ; count `ps<.1` and `ps>.9`; list the cantons in those tails.
4. Entropy-balance feasibility precheck: is the **treated** mean `french_share` inside `[min,max]` of the **control** `french_share`? Report yes/no + the numbers. (If treated mean ≈ 0.51 > control max, `ebalance` on `french_share` is infeasible.)

**Deliver:** a small numbers table + a one-line overlap verdict.

## TASK 2 — Entropy balancing trial
- `ebalance absinthe_dummy french_share catholic_share ln_pop` (mean balance) → does it converge? Report pre/post balance and whether `french_share` balanced.
- If it cannot balance `french_share`: (a) **document the failure (this is itself a result)**; (b) retry WITHOUT language: `ebalance absinthe_dummy catholic_share ln_pop`, then the weighted producer effect `reg yes_pct absinthe_dummy [pw=_webal], vce(hc3)`. **Flag explicitly that this version does NOT address the language confound.**

**Deliver:** convergence status, balance table, weighted producer effect (if feasible), min/max weights.

## TASK 3 — IPW trial
- `teffects ipw (yes_pct) (absinthe_dummy french_share catholic_share ln_pop), atet` (and/or `ate`) → ATT/ATE + SE.
- `tebalance summarize`; `teffects overlap` (save the PNG); report min/max weights and any overlap / perfect-prediction errors.

**Deliver:** ATT/ATE + SE, weight extremes, overlap-violation flags.

## TASK 4 — Lewbel IV precheck (continuous wine, `X3_share`)
- First-stage heteroskedasticity (Lewbel **requires** it): `reg X3_share french_share catholic_share ln_pop` ; `estat hettest` ; `estat imtest, white`.
- `ivreg2h yes_pct (X3_share = ) french_share catholic_share ln_pop, robust` → report **Kleibergen–Paap rk Wald F (weak-IV)**, the `X3_share` coefficient + 95% CI, **Hansen J** (overid p), and the number of generated instruments.
- Compare the Lewbel wine coefficient to the OLS/FL col-5 estimate (≈ 0.43–0.47).

**Deliver:** het-test result, KP F, wine coef + CI, Hansen J.

---

## Constraints
- Stata-first; HC/robust SEs; existing dataset; **diagnostic only** (no changes to main analysis/paper/tables-of-record).
- Log every command + output; flag separation / weak-IV **honestly** (do not paper over).
- `set seed` if anything stochastic; use project globals, no hardcoded absolute paths.

## Deliverable
A feasibility memo → `quality_reports/coder_reports/2026-06-09_feasibility-ipw-ebal-lewbel.md` with, **per method, a GO / NO-GO / DOCUMENT-AS-LIMIT recommendation** plus the key numbers (overlap counts, treated/control French means, separation flag, KP F, Lewbel wine coef + CI). This memo decides what — if anything — gets implemented as a paper robustness section. **Do not implement paper-facing results in this pass.**

## Hypothesis (what we expect — to be confirmed or overturned)
IPW & entropy balancing hit the common-support wall (French-producer separation) → classify as *documented limits* or *religion/density-only robustness with a stated caveat*. Lewbel IV is likely weak at N=25 → exploratory. If any surprises us by being strong/feasible, that changes the plan — which is exactly why we measure first.
