# Results memo — Small-N inference battery + leave-one-out (canton N=25)

**Date:** 2026-06-03 (build + verification), 2026-06-04 (tables, memo)
**Scripts:** `analysis/scripts/22_canton_inference_battery.do` (analysis), `23_canton_inference_battery_tables.do` (tables)
**Decision log:** `quality_reports/coder_reports/2026-06-03_inference-battery-decision-log.md`
**Plan / dispatch:** `analysis/documentation/plans/2026-06-03_inference-battery-loo.md` / `.../coder_dispatch/2026-06-03_inference-battery-loo-dispatch.md`
**Pipeline:** WORKSHOP (`processed/cohort_1908_workshop.dta`); the script re-derives `Y1_frac=Y1/100` and **asserts the headline FL AME reproduces the deployed 0.4338** as a paper-anchor before doing anything else (passes).

> **STATUS — one line (updated 2026-06-09):** Everything is built, verified, and **final — including the 10,000-permutation randomization inference** (canonical run completed 2026-06-09, seed 20260603, ~80 min, `set processors 1` per the N=25 single-core benchmark). `T_ri` is now FINAL and deployed to Overleaf. Headline col-5 RI p = **0.054** (OLS) / **0.087** (FL-AME); see §2.6.

---

## 1. The gate, in one paragraph

**The wine result is not "just Vaud."** At the headline col-5 spec, the fractional-logit average marginal effect is **0.434 pp** of yes-share per pp of national wine revenue share. Dropping Neuchâtel raises it to **0.439**; dropping Vaud *raises* it to **0.493**. Across all 25 single-canton deletions the FL AME stays in **[0.318, 0.650]** (minimum at drop-Zürich, maximum at drop-Fribourg) — **always positive, never near zero**. The OLS twin behaves identically (0.469 full; LOO range [0.350, 0.694]). The decision-relevant robustness check therefore **passes**: no single canton, Vaud included, is driving the wine–yes association.

The honest small-sample caveat lives one level down: at N=25 the **Bell-McCaffrey effective degrees of freedom collapse to ~2–4** (not N−k=19), so the col-5 result is **p ≈ 0.12** under the BM correction, not the ≈0.06 a naïve normal gives. The wine leg is **real but fragile** — robust in *sign and magnitude* under deletion, modest in *significance* under an honest small-N correction. (The canonical 10k RI is now in — headline col-5 p = **0.054** OLS / **0.087** FL-AME, seed 20260603 — the third leg of this read; it lands *tighter* than the BM p≈0.12, so the three small-N instruments bracket the headline at roughly p≈0.05–0.12.)

---

## 2. Results by method

### 2.1 Leave-one-out — the gate (`T_loo_gate`)

| Specification (col 5) | FL AME (pp) | OLS coef (HC3) |
|---|---|---|
| Full sample (N=25) | 0.434 (0.195) | 0.469 (0.309) |
| Drop Neuchâtel (NE) | 0.439 (0.216) | 0.478 (0.593) |
| Drop Vaud (VD) | 0.493 (0.274) | 0.528 (0.534) |
| LOO range [min, max] | [0.318, 0.650] | [0.350, 0.694] |

Dropping Vaud *strengthens* the wine effect. The full LOO envelope never crosses zero. **Gate: PASS.**

### 2.2 Small-sample SEs + Bell-McCaffrey dof (`T_se_bm`)

| Spec | OLS coef | HC2 SE | HC3 SE | BM dof | BM p |
|---|---|---|---|---|---|
| (1) wine only | −0.196 | 0.179 | 0.219 | 2.04 | 0.385 |
| (2) + French | 0.568 | 0.211 | 0.251 | 3.52 | 0.062 |
| (3) + Absinthe trade share | 0.415 | 0.201 | 0.271 | 3.31 | 0.122 |
| (4) + Protestant | 0.547 | 0.213 | 0.277 | 3.95 | 0.063 |
| (5) full | 0.469 | 0.242 | 0.309 | 4.33 | **0.119** |

The BM/Imbens-Koleśár (2016) effective dof was **hand-implemented in Mata and validated in-script** (Mata HC2 SE == native `vce(hc2)` SE, reldif < 1e-6). The collapse to ~2–4 dof is the honest reason the marginal wine result reads p≈0.12, not p≈0.06.

### 2.3 Oster (2019) δ-bounds (`T_oster`)

| Quantity | Value |
|---|---|
| Uncontrolled coef (Y on wine only) | −0.196 (R²=0.016) |
| Controlled coef (full col-5) | +0.469 (R²=0.623) |
| δ to zero the coef (rmax = 1.3·R² = 0.810) | **−1.354** |
| δ to zero the coef (rmax = 1) | −0.747 |
| coef at δ=1 (rmax = 1.3·R²) | **0.818** |
| coef at δ=1 (rmax = 1) | 1.247 |

**Oster corroborates, it does not threaten.** Adding observables moves the coefficient *away* from zero (the Simpson flip −0.196 → +0.469), so the δ that would drive it to zero is **negative** — unobservable selection would have to run *opposite* to the observable selection. Under equal selection (δ=1) the bias-adjusted coefficient is *larger* (0.82), not smaller. The standard "is δ>1?" cutoff does not bind because zeroing-out is ill-posed here.

> **Note (transparency):** the first build had a `psacalc` bug — `mcontrol()` was passed all the col-5 controls, which forces the short model to equal the long model and returns missing δ/β. Fixed (no `mcontrol`, so the short model is the bivariate). The numbers above are post-fix and reproduce the decision-log "β@δ=1 ≈ 0.81."

### 2.4 White vs red wine (`T_winetype`)

| Wine type (col 5) | OLS coef (HC3) | FL AME (pp) |
|---|---|---|
| White | 0.285 (0.249) | 0.257 (0.150) |
| Red | 0.393 (0.458) | 0.418 (0.247) |

Cahannes (1981) predicts absinthe competed with **white** wine ⇒ coef(white) > coef(red). At this canton-level spec the point estimates run the **other way** (red ≥ white), but both are imprecise with heavily overlapping CIs — **the canton cross-section cannot resolve the white-vs-red split.** Flag for the mechanism discussion; do not over-read.

### 2.5 Producer-coalition cascade (`T_producer_cascade`)

| Step (focal: absinthe-producer dummy, 8 cantons) | OLS coef (HC3) | FL AME (pp) |
|---|---|---|
| p1: raw bivariate | **−11.20 (5.35)** | −10.87 (4.56) |
| p2: + Protestant + density | −10.77 (5.23) | −10.48 (4.08) |
| p3: + wine + Prot. + density | −12.08 (7.35) | −11.80 (5.42) |
| p4: + French (full) | **+3.57 (6.99)** | +3.55 (5.22) |

LOO (OLS): the raw differential p1 ranges **[−13.58, −8.13]** across single-canton deletions (always clearly negative); the full-spec p4 ranges [0.91, 8.36].

**FRAMING (binding, per decision log D8 — use this register in the paper):** the collapse at the +French step is a **power / linked-covariance limitation, NOT an indemnification** of the producer-coalition hypothesis. corr(producer, French) = **0.71**; the producer SE inflates **×1.31** (5.35 → 6.99) when French enters, with a sign flip — the signature of an under-identified coefficient, not a true null. At N=25 with r=0.71 the cross-section **cannot separate the producer-economic channel from the language-cultural channel** (producer cantons average 51% French vs 2% for non-producers). Report as **"lack of evidence, not evidence of lack,"** matching the register CONTEXT.md already uses for the underpowered H3/H6 interaction tests. Do **not** read +3.57 n.s. as "no producer effect."

### 2.6 Randomization inference (`T_ri`) — **FINAL (canonical 10k, 2026-06-09)**

`ritest` permutes the focal regressor across the 25 cantons 10,000×, seed 20260603 (`set processors 1` — at N=25 MP threading is net-negative; RI results are core-count-invariant). Canonical p-values:

| Spec | OLS β | RI p | FL AME | RI p |
|---|---|---|---|---|
| Wine X3 c1 (raw) | −0.196 | 0.524 | — | — |
| Wine X3 c2 (Simpson flip) | 0.568 | **0.016** | 0.531 | **0.029** |
| Wine X3 c3 | 0.415 | 0.084 | — | — |
| Wine X3 c4 | 0.547 | **0.022** | — | — |
| **Wine X3 c5 (headline)** | **0.469** | **0.054** | **0.434** | **0.087** |
| Wine X2 c5 (volume co-headline) | 0.454 | 0.101 | 0.428 | 0.128 |
| Producer p1 (raw) | −11.20 | **0.023** | −10.87 | **0.027** |
| Producer p2 / p3 | −10.77 / −12.08 | 0.032 / 0.021 | — | — |
| Producer p4 (+French) | +3.57 | 0.363 | +3.55 | 0.374 |

**Read:** the headline wine col-5 is RI-significant at p≈0.05–0.09 (estimator-dependent); the Simpson-flip col-2 is the sharpest (p≈0.02–0.03); the raw producer differential (p1) is significant (p≈0.02–0.03) and collapses to n.s. only at the +French step (p4 — the language-entanglement limit, per §2.5). **This RI p is distinct from — and tighter than — the BM dof-adjusted p (§2.2, col-5 = 0.119);** report the two as separate small-N instruments, never conflated into one "≈0.12."

---

## 3. The emerging shape of the paper (analyst read)

The battery is turning into a **symmetry result**: *both* legs are "real but fragile at N=25." The wine leg survives every single-canton deletion and Oster, is p≈0.12 under BM and p≈0.05–0.09 under the design-based 10k RI; the producer leg has a clean raw −11 pp differential (RI p≈0.02) that the language channel absorbs but cannot be shown to be spurious. The implication: **the paper should lead on the competing-coalition *pattern* + stage-separation + cross-referendum falsification, not on either single p-value.** Neither leg is a knockout in isolation; together, plus the historical mechanism, they are the argument.

---

## 4. Finalization — ✓ DONE (2026-06-09)

1. ✓ **Canonical battery run** via `analysis/scripts/_inference_battery_run.do` (RUN_RI=1, 10,000 perms, seed 20260603, RUN_POSTCREDITS=1, `set processors 1`). Ran as a standalone `StataMP-64.exe /e` batch (~80 min, exit 0) — *not* via the MCP server (the wrapper sources the Dropbox init, which the MCP path-sandbox blocks; the standalone process is also crash-safe for a long unattended run). Regenerated all `inference_*.dta` and stamped `char _dta[ri_reps]=10000`. All asserts passed (paper-anchor FL AME 0.4338; producer-anchor −11.199; Mata HC2 == native).
2. ✓ **Table builder re-run** via `_run_23_tables.do` → `23`: detected `ri_reps=10000`, dropped the PROVISIONAL stamp, deployed `T_ri.tex` to Overleaf (`Tables/Robustness_6-3-26/`) alongside the other five — **six FINAL tables** now deployed.
3. ✓ **§2.6 updated** with the final RI p-values (above).

Everything else (LOO, SE/BM, Oster, white/red, producer cascade) was deterministic and already final — the canonical run reproduced them bit-for-bit (verified in the run log).

---

## 5. Verification performed

- `22` re-run end-to-end (RUN_RI=0 fast pass): rc=0; **all asserts pass** — paper-anchor (FL AME=0.4338), producer-anchor (raw bivariate −11.199), Mata HC2 == native HC2 (<1e-6).
- §2 RI **canonical 10k run** (2026-06-09, standalone `StataMP-64.exe /e` batch, exit 0): 15 rows, `reps=10000` stamped, seed 20260603; headline col-5 p = 0.054 (OLS) / 0.087 (FL-AME).
- `23` re-run (canonical, via `_run_23_tables.do`): rc=0; 6 tables + 6 markdown twins written; **FINAL gate fired** (log: "RI is CANONICAL … T_ri will deploy") — all 6 finals deployed to Overleaf, `T_ri` included.
- **LaTeX compile test:** all 6 fragments `\input` into a minimal article and compile under `pdflatex` with **exit 0, zero errors**.

### Bugs caught and fixed during verification (transparency)
1. **Oster `mcontrol()`** over-specified ⇒ short==long ⇒ missing δ/β. Fixed (no `mcontrol`); δ/β now real.
2. **`23` header `/*`-glob** (`tables/*.tex` inside a `/* */` block) silently commented out the whole script (rc=0, no files). Fixed per `stata-gotchas.md`.
3. **`texsave footnote()` r(198)**: two footnotes interpolate LOO ranges via `+ string()` and needed `local x = "..."` (with `=`), not `local x "..."`. Fixed per `stata-gotchas.md`.
4. Bare `#68` in three footnotes would break LaTeX (`#` is the macro-parameter char under `nofix`). Fixed with `\#68` — the `\#` escape renders as `#` in **both** LaTeX and the markdown twin (`#` is escapable punctuation in CommonMark too), so the paper's vote-`#68` notation is preserved. (An interim "vote 68" workaround was used first, then superseded once the dual-renderer `\#` escape was confirmed.)
5. Markdown twin titles carried literal quotes (`# "Title"`) because `_md_dump` used `TITLE(string asis)`; switched to `TITLE(string)` (and `NOTE(string)`) so the `#` heading is clean.

---

## 6. Files produced

**Analysis / wrappers (new):**
- `analysis/scripts/22_canton_inference_battery.do` (producer cascade + Oster fix)
- `analysis/scripts/23_canton_inference_battery_tables.do`
- `analysis/scripts/_inference_battery_run.do` (canonical overnight 10k)
- `analysis/scripts/_inference_battery_smoke.do` (30-perm verification)

**Intermediates (`analysis/results/intermediate/`):** `inference_loo.dta` (234 rows: wine c1–c5 + producer p1–p4 × {full, 25 LOO}), `inference_se_bm.dta` (5), `inference_oster.dta` (8), `inference_winetype.dta` (4) — **canonical**; `inference_ri.dta` (15) — **canonical 10,000-perm (seed 20260603, run 2026-06-09)**.

**Tables (`analysis/results/tables/` + `_md/` twins):** `T_loo_gate`, `T_producer_cascade`, `T_se_bm`, `T_oster`, `T_winetype`, `T_ri`.

**Overleaf (`Tables/Robustness_6-3-26/`):** all **six** FINAL `.tex` (`T_ri` deployed 2026-06-09 after the canonical 10k run).
