# Decision Log — Small-N Inference Battery + LOO (live, append-only)

**Started:** 2026-06-03. **Maintainer:** Claude (coder), at PI Nicholas Jensen's instruction.
**Dispatch:** `quality_reports/coder_dispatch/2026-06-03_inference-battery-loo-dispatch.md`
**Plan:** `analysis/documentation/plans/2026-06-03_inference-battery-loo.md`
**Purpose:** Permanent record of every decision and its rationale, updated as the build progresses, so the analysis is replicable with no later ambiguity (PI requirement).

---

## D0. Gate compliance (2026-06-03)
The dispatch is a *proposal*, not an order. Followed its gate: read dispatch + scripts + strategy note → restated intent → surfaced discrepancies → got explicit PI sign-off via four rounds of clarifying questions before writing any analysis code. No `.do` written until D-final approval below.

## D1. Pipeline = WORKSHOP (cohort_1908_workshop.dta)
- **Decision:** Run the battery on the workshop pipeline, reading `processed/cohort_1908_workshop.dta` directly (NOT sourcing `09_workshop`, which overwrites the cohort).
- **Rationale + audit (PI asked me to confirm):** workshop cohort is newest (mtime 2026-05-22 12:55 vs non-workshop 05-21); frozen `estimates_fraclogit_workshop/fl_me_3_5.ster` AME×100 = **0.4338 ≈ deployed paper 0.434**. So workshop = paper-identical AND most current. The dispatch's literal reference to the non-workshop `09_canton_reg1.do`/`cohort_1908.dta` was superseded.
- **Build consequence:** all analysis vars (`X1,X2_share,X3_share,abs_producer,fr_x_producer,X3_white_share,X3_red_share,cov1,cov2_total_share,cov3,ln_density,Y1`) are persisted in the cohort. Only `Y1_frac` is runtime-derived (`=Y1/100`). The battery reconstructs it + **asserts the headline AME reproduces 0.4338** as a self-verifying paper-anchor.

## D2. Conley spatial-HAC = DEFERRED
- **Decision:** Build LOO + RI + HC2/BM + Oster + white/red first; do Conley last, only if valid coordinates are found.
- **Rationale:** `acreg` not vendored AND no canton coordinates exist in the repo. PI: after the rest, source period-appropriate Swiss canton centroids (1908 boundaries differ from modern; jurisdictions flux) — adapt if needed, never fabricate.

## D3. Scope = WINE leg (full cascade 1–5) + PRODUCER leg
- **Decision:** Battery covers the wine leg across all five cascade columns AND the absinthe-producer dummy (`abs_producer`) leg. LOO drops each canton (flag VD, NE) on each.
- **Rationale:** PI initially chose wine+cascade, then added the producer leg (strategy note §3 calls it the *robust* leg; the gate should show which leg survives drop-Vaud).

## D4. RI = Option B (ritest/permute), both estimators
- **Decision:** RI via vendored `ritest`/`permute`, 10,000 perms, one documented seed, on **both** the FL AME and the OLS β. PLUS Oster δ-bounds (`psacalc`) and white-vs-red split.
- **Rationale:** `ritest` is vendored and proven (used in 05_expansion); structurally immune to the no-op permutation bug the dispatch warns about. PI required NO computational corner-cutting → 10k full, both estimators, every step documented. Runtime managed by engineering (targeted RI columns + incremental saves + background), never by reducing perms (methodology-integrity rule).

## D5. psacalc = ADD via /add-package (authorized)
- **Decision:** Install `psacalc` (Oster 2019) into `libraries/stata/` via the tracked `/add-package` path. Never inline `ssc install` (hard rule).

## D6. Tables destination = LOCAL + OVERLEAF (new folder)
- **Decision:** Battery tables → `analysis/results/tables/` (with markdown twins) AND deployed to a NEW Overleaf folder `Tables/Robustness_6-3-26/`. Memo → `quality_reports/coder_reports/2026-06-03_inference-battery-results.md`.

## D-final. PI APPROVED build (2026-06-03)
PI: "Approve — build it" (scripts 22/23) + "make permanent documentation of decisions now and hereafter." This log is that documentation.

---

## Progress log (append per milestone)
- 2026-06-03 — Decisions D0–D6 locked; plan + this log written.
- 2026-06-03 — `psacalc` 2.1 installed via `/add-package` into `libraries/stata/p/` (tracked in `stata.trk`); documented in `_install_stata_packages.do` (Group 5 + verification list); reachability confirmed (`which psacalc` resolves to vendored path after `adopath ++`). `ritest` confirmed already vendored.
- 2026-06-03 — Help-first done for `ritest` + `psacalc` (read vendored `.sthlp`). D7 (HC2+BM) raised.
- 2026-06-03 — D7 RESOLVED: PI chose Mata IK-BM, validated. Implemented in `22_canton_inference_battery.do §3` with an in-script assert (Mata HC2 SE == native `vce(hc2)` SE < 1e-6) — PASSED.
- 2026-06-03 — `22_canton_inference_battery.do` written + FAST PASS verified (rc=0). Bugs fixed during verification: (i) `vce(hc1)` invalid → `vce(robust)` (Stata: robust==HC1); (ii) `putmata` takes a space-separated varlist in parens (my `subinstr` comma-insertion was wrong AND missing its 4th arg). RI code path smoke-tested at 50 reps (rc=0; sensible p-values; `ritest`+FL-AME mechanism works).
- **2026-06-03 — KEY FINDINGS (fast pass + 50-rep RI):**
  - **GATE: wine leg SURVIVES drop-Vaud.** FL AME col-5: full 0.434 (SE .195) → drop-NE 0.439 → **drop-VD 0.493 (SE .274)**. Not "just Vaud."
  - **BM dof confirms fragility (validated):** effective dof ~2–4 (not N−k=19); col-5 OLS p_bm = **0.119** (vs analytic ~0.06) — matches the strategy note's "RI-fragile."
  - **Oster ill-posed:** δ-to-zero undefined (controls AMPLIFY the wine coef — the Simpson flip c1=−0.196 → c5=+0.469), β at δ=1 = 0.81. Oster assumes attenuation; report honestly, do not force a δ.
  - **White/red (col-5):** red ≥ white (white FL AME 0.257 vs red 0.418) — AGAINST the Cahannes white>red prediction at this spec. Flag.
- **2026-06-03 — 10k RI launched in BACKGROUND** (RUN_RI=1, seed 20260603, ~80 min est).

## D8. Producer-leg spec — OPEN (needs PI), 2026-06-03
- **Issue:** my producer-leg spec `Y ~ X3_share + abs_producer + cov1 + cov3 + ln_density` gives `abs_producer` b = **+3.57pp, n.s. (RI p≈.36)** — contradicting the strategy note's "robust **−11.2pp** cross-bloc producer differential."
- **Cause:** §3 degeneracy — all 5 producer cantons are French, so conditioning on `cov1` (French share) absorbs the producer differential (near-collinear). The −11.2pp is a *cross-bloc* contrast (French-producer vs German-non-producer), not a coefficient from a French-conditioned regression.
- **Need PI:** which producer-leg spec? (a) cross-bloc raw/contrast reproducing −11.2pp; (b) abs_producer WITHOUT cov1; (c) the joint French-conditioned model as I coded (answers a different question); (d) drop producer leg. The 10k RI producer rows currently use (c), documented + flagged.

### D8 RESOLVED (2026-06-03) — producer leg = CASCADE + power-limitation framing
- **PI decision:** feature the producer leg as a **cascade** (mirror the wine cascade), LOO + RI on the key columns.
- **Correction to an earlier wrong assumption:** `abs_producer` (= `cov2_total_share`>0) flags **8 cantons** (incl. German BS, SZ, ZG), NOT just the 5 French cantons. It is *not* mechanically collinear with French.
- **The −11.2pp is the RAW bivariate differential** (`reg Y1 abs_producer`), reproduced exactly. Producer cascade (OLS, HC3, coef on `abs_producer`):

  | Step | b (pp) | SE | p |
  |---|---:|---:|---:|
  | C raw bivariate | **−11.20** | 5.36 | 0.048 |
  | B2 +Protestant+density | −10.77 | 5.23 | 0.052 |
  | B +wine+Prot+density | −12.08 | 7.35 | 0.116 |
  | A +French (full) | +3.57 | 6.99 | 0.615 |

- **FRAMING (PI directive, binding for memo + any table footnote):** the collapse at the +French step is a **power / linked-covariance limitation, NOT an indemnification** of the producer-coalition hypothesis. Quantitative anchors: corr(`abs_producer`,`cov1`)=**0.711**; VIF≈2.9; producer SE inflates **×1.31** (5.36→6.99) when French enters, with a sign flip — the signature of an under-identified coefficient, not a true null. At N=25 with r=0.71 the cross-section **cannot separate the producer-economic channel from the language-cultural channel** (the §3 cross-bloc degeneracy: producers average 51% French vs 2% non-producers). Report as **"lack of evidence, not evidence of lack,"** matching the register CONTEXT.md already uses for the underpowered H3/H6 interaction tests. Do NOT read +3.57 n.s. as "no producer effect."

## Progress log (cont.)
- 2026-06-03 — Producer comparison run (4 specs + linkage diagnostics). D8 resolved (cascade + power framing above).
- 2026-06-03 — **OPERATIONAL LESSON:** stopping the MCP-Stata background RI task mid-run orphaned the worker and wedged the single Stata license (`session=error`, init timeouts); recovered after a stop + retry probe. **Don't stop MCP-Stata background tasks mid-run** — let them finish, or accept a license-recovery cycle. (gotchas.md candidate.) The 10k RI must be relaunched.
- **NEXT:** (1) edit `22 §1/§2` so the producer leg is a 4-step cascade (raw→+ctrls→+wine→+French) for LOO+RI; (2) relaunch 10k RI (background) with the producer cascade baked in; (3) build `23` tables (+md twins) → local + Overleaf `Tables/Robustness_6-3-26/`; (4) results memo carrying the power-limitation framing; (5) Conley (deferred, needs coords).

## D7. HC2 + Bell-McCaffrey dof — implementation fork (OPEN, 2026-06-03)
- **Situation:** HC1/HC2/HC3 SEs are native (`vce(hc1|hc2|hc3)`). The Bell-McCaffrey / Imbens-Koleśár (2016) *effective degrees-of-freedom* adjustment — which is the part that actually matters at N=25 (it can shrink dof well below N−k, widening the t-critical value for the marginal wine result) — has NO native Stata command and is NOT on SSC (reference impl is Koleśár's R `dfadjust`).
- **Options:** (a) hand-implement IK-BM effective dof in Mata, self-contained in the do-file (most replicable — no dependency — but I author it, so it must be validated against a published value); (b) report HC1/HC2/HC3 SEs natively and defer the BM dof refinement; (c) drop HC2/BM from scope.
- **Recommendation:** (a) Mata IK-BM, with an in-script validation check, since it ships in the replication archive and matches the dispatch's intent. **Awaiting PI confirmation before coding the battery's SE section.**

---

## Progress log — 2026-06-04 (producer cascade coded + Oster fixed + tables built + compile-tested)

PI directive this session: "do all those but the 10k randomization inference right now as I'll need to do that overnight." Executed steps 1, 3, 4 + de-risked step 2 (RI code path), per below.

### What was done
- **D8 producer cascade CODED into `22` §1 (LOO) + §2 (RI).** §1: producer leg is now a 4-step cascade p1 (raw `abs_producer`) → p2 (`cov3 ln_density`) → p3 (`X3_share cov3 ln_density`) → p4 (`X3_share cov1 cov3 ln_density`), LOO over all 25 cantons each. §2: OLS-β RI on p1–p4, FL-AME RI on the endpoints p1 + p4. Added a **producer-anchor assert** (raw bivariate reproduces −11.199) — passes. The full-sample cascade reproduces the D8 table exactly (−11.20 / −10.77 / −12.08 / +3.57).
- **RI made overnight-safe + provisional-aware.** §2 RI postfile now stamps a `reps` column and `char _dta[ri_reps]`; a sub-10k run prints a PROVISIONAL warning. Two wrappers: `_inference_battery_run.do` (canonical 10k, batch-safe preamble, RUN_POSTCREDITS=1) and `_inference_battery_smoke.do` (30-perm verification). The 10k RI itself is **deferred to the PI's overnight run** (per directive); not launched.
- **Oster bug FOUND + FIXED (methodology).** §4 `psacalc` was passing `mcontrol(<all controls>)`, forcing short==long ⇒ missing δ/β. Removed `mcontrol()` (standard Oster: short = bivariate). Now δ=−1.354 (rmax=1.3R²) / −0.747 (rmax=1), β@δ=1=0.818 / 1.247 — **reproduces the decision-log "0.81" and confirms the ill-posed-for-attenuation reading** (controls amplify; δ<0; Oster corroborates). §4 also stores short/long β + R² for the table.
- **`23_canton_inference_battery_tables.do` BUILT** — 6 hand-built `texsave` tables + markdown twins: `T_loo_gate`, `T_producer_cascade`, `T_se_bm`, `T_oster`, `T_winetype`, `T_ri`. **Provisional gate works:** reads `ri_reps`; if <10000 it stamps `T_ri` PROVISIONAL and **withholds it from Overleaf**. The 5 deterministic tables deployed to `Tables/Robustness_6-3-26/`; `T_ri` held back (currently 30-perm smoke).
- **Results memo written:** `quality_reports/coder_reports/2026-06-03_inference-battery-results.md`.

### Verification (observed, not asserted-intent)
- `22` RUN_RI=0 fast pass: rc=0; paper-anchor + producer-anchor + Mata-HC2-validation asserts all PASS.
- `22` RUN_RI=1 smoke (30 perms): rc=0; RI 15 rows incl. producer cascade; reps-stamp written.
- `23`: rc=0; 6 tables + 6 md twins; final "all present" assert passes; 5 deployed + T_ri withheld.
- **LaTeX compile test:** all 6 fragments `\input` + `pdflatex` ⇒ exit 0, zero errors, 54 KB PDF.

### Bugs caught during verification (all fixed)
1. **Oster `mcontrol()`** over-specified (above) — would have shipped blank δ/β.
2. **`23` `/*`-glob in header** (`tables/*.tex` inside `/* */`) silently commented out the whole script (rc=0, no files) — the documented `stata-gotchas.md` comment-nesting trap. Fixed (placeholder path).
3. **`texsave footnote()` r(198)** — two footnotes use `+ string()` and needed `local x = "..."` (with `=`). Fixed per gotchas.
4. **Bare `#68`** in three footnotes (LaTeX macro-parameter char under `nofix`) → **`\#68`** (the `\#` escape renders as `#` in both LaTeX and the markdown twin; preserves the paper's `#68` notation — an interim "vote 68" was superseded).

### Outstanding
- **10k RI (the only remaining deliverable):** PI to run `_inference_battery_run.do` overnight (~100 min; do NOT stop mid-run — single-license orphan risk). Then re-run `23` → `T_ri` finalizes + deploys to Overleaf. Then update §2.6 of the results memo.
- Conley spatial-HAC: still DEFERRED (D2; needs period-appropriate canton centroids).

### Analyst note
Battery is converging on a **symmetry result** — both legs "real but fragile at N=25." Wine survives every LOO deletion + Oster but is p≈0.12 under Bell-McCaffrey; producer has a clean raw −11 pp differential the language channel absorbs (power-limited, not refuted). Paper should lead on the competing-coalition *pattern* + stage-separation + cross-referendum falsification, not either single p-value.

### Markdown polish (2026-06-04, post-PI feedback)
PI: "fix the markdown things; remember `\#` works in markdown too." Done in `23`: (i) `_md_dump` switched `TITLE`/`NOTE` from `string asis` to `string` so md `#` headings no longer carry literal quotes; (ii) restored the paper's `#68` notation in the three footnotes via `\#68` — the `\#` escape renders as `#` in **both** LaTeX (`texsave nofix`) and CommonMark (`#` is escapable punctuation), so the interim "vote 68" workaround was removed. **Re-verified:** `23` rc=0; 6 tables + twins regenerated; 5 finals re-deployed to Overleaf (T_ri still withheld — provisional 30-perm); `pdflatex` compile of all 6 fragments ⇒ exit 0, zero errors.
