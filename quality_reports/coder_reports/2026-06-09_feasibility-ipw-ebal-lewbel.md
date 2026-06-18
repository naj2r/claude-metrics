# Feasibility memo — IPW · Entropy balancing · Lewbel IV (producer & wine legs, N=25)

**Date:** 2026-06-09
**Dispatch:** `quality_reports/coder_dispatch/2026-06-09_feasibility-ipw-ebal-lewbel.md` (corrected version)
**Script:** `analysis/scripts/_feasibility_ipw_ebal_lewbel.do` (diagnostic-only; rc=0)
**Dataset:** `processed/cohort_1908_workshop.dta` (N=25 cantons) — the tables-of-record cohort
**Treatment (producer):** `abs_producer` (= `cov2_total_share>0`, "any Milliet absinthe purchase")
**Wine (Lewbel):** `X3_share` (national wine revenue share). **Outcome:** `yes_pct` = `Y1` (#68, 0–100).
**Covariates:** `french_share`, `catholic_share`, `ln_pop_1900`.
**Status:** **DIAGNOSTIC ONLY** — no paper-facing results, no edits to the main analysis/tables-of-record. This memo decides what (if anything) gets implemented.

> **DATA-DEFINITION CORRECTION (resolved before the run).** The original dispatch named the treatment `absinthe_dummy` and called it "8 producer cantons." That **conflated two different variables in two different datasets**: `absinthe_dummy` (in `absinthe_analysis.dta`) is **NE-only** (`02_clean.do:266`; broadest sibling = NE+VD+GE = 3), while the paper's headline producer treatment is **`abs_producer`** (in `cohort_1908_workshop.dta`, `09_canton_reg1_workshop.do:411`) = 8 cantons. The coder flagged it; PI confirmed **Option 1 (workshop cohort + `abs_producer`)** because that is the dataset/treatment behind `T_producer_cascade`/`T_loo_gate` (the tables of record). The run's **first command prints the realized treated set** so the definition is permanently on the record.

## Realized treated set (`abs_producer==1`, printed by the script)
**8 cantons: BS, FR, GE, NE, SZ, VD, VS, ZG** (`n_treated = 8`, asserted). Of these, **5 are French-majority** (FR, GE, NE, VD, VS) and **3 are German-majority** (BS, SZ, ZG). **Zero French-majority cantons are non-producers** (`french_majority_nonproducer_n = 0`). This is the structural separation the whole memo is about.

---

## VERDICTS (the deliverable)

| Method | Leg | Verdict | One-line reason |
|---|---|---|---|
| **Entropy balancing** | producer | **NO-GO (document as limit)** | Cannot converge — treated French mean 0.51 lies outside the entire control French range [0.00, 0.17]; no weights can match the moment. |
| **IPW (teffects)** | producer | **DOCUMENT-AS-LIMIT** | Technically runs, but a single canton gets weight **196×**; the ATT collapses to the raw −11.5 differential — IPW cannot actually adjust for language (no overlap). |
| **Lewbel IV** | wine (`X3_share`) | **GO (exploratory / corroborating)** | Surprise: **not** weak (KP rk Wald F = 222), Hansen J passes (p=0.13), wine coef **0.571** (CI [0.27, 0.88]) corroborates the OLS/FL ~0.43–0.47 via heteroskedasticity-based identification. |

**Bottom line:** the two *reweighting* methods hit the common-support wall exactly as hypothesized (the producer⟂language separation defeats them) → they belong in the paper as a *documented limit*, not as adjustments. The *Lewbel IV* on the wine leg surprised us by being feasible and **corroborating** — a new, overlap-free robustness angle on the headline wine result, worth reporting as exploratory.

---

## TASK 1 — Common support (the crux)

| Quantity | Value |
|---|---|
| French-majority & non-producer cell | **0** (all 4–5 French-majority cantons are producers) |
| French share — treated mean / control mean | **0.509 / 0.021** |
| French share — control [min, max] | **[0.001, 0.168]** |
| French share — treated min | 0.005 (BS, a German producer) |
| Propensity (logit on the 3 covariates) — treated mean / control mean | 0.684 / 0.149 |
| Cantons with ps<0.1 / ps>0.9 | **9 / 5** |
| Entropy-balance feasibility (treated mean inside control range?) | **NO** (0.509 ≫ control max 0.168) |

**Read:** severe one-sided common-support failure. The 5 French producers sit at ps≈0.98–0.99 with **no control counterparts**; only the 3 German producers (BS, SZ, ZG) overlap the German non-producer mass. Overlap figure: `analysis/results/figures/feasibility_ps_overlap.png`.

## TASK 2 — Entropy balancing

- **Full (french_share + catholic_share + ln_pop_1900): does NOT converge** (`ebal_full_converged = 0`; ebalance: *"algorithm does not converge … no solution"*). It cannot match the treated French mean (0.51) because that value is outside the control covariate hull. **This non-convergence is itself the result.**
- **Religion + density only (drops language): converges.** Weighted producer effect **−11.46 pp (SE 4.95, p=0.030)**, weights ∈ [0.22, 0.87]. But this **does NOT address the language confound** — it just reproduces the raw cross-bloc differential (−11.2 from `T_producer_cascade` p1) with religion/density matched. Report only with that explicit caveat.

## TASK 3 — IPW (`teffects ipw`)

- Runs without a formal overlap error (`ipw_atet_rc = 0`). **ATT = −11.54 (SE 4.73); ATE = −4.74 (SE 3.01).**
- **But max IPW weight = 196.1** (treated min ps = 0.005) — one canton dominates. The ATT ≈ the unadjusted −11.2 differential: with the 5 French producers off-support, IPW cannot reweight controls to resemble them, so the "adjusted" estimate is neither genuinely language-adjusted nor stable. **Document-as-limit**, same wall as entropy balancing.

## TASK 4 — Lewbel heteroskedasticity-IV (wine leg, `X3_share`)

| Quantity | Value |
|---|---|
| First-stage heteroskedasticity (Breusch–Pagan p) | **0.0000** (Lewbel's requirement satisfied) |
| OLS reference (reduced control set) | X3 b = 0.666 (cf. published col-5 ≈ 0.469) |
| **Lewbel wine coef** | **0.571 (SE 0.156), 95% CI [0.266, 0.877]** |
| Kleibergen–Paap rk Wald F (weak-IV) | **222.3** (≫ 10) |
| Cragg–Donald Wald F | 35.7 |
| KP rk LM under-identification p | 0.146 *(soft caveat — see below)* |
| Hansen J (overid) | 4.07, **p = 0.131** (instruments not rejected) |
| Generated instruments / overid df | 3 / 2 |

**Read:** against the hypothesis, Lewbel is **not weak** here — the heteroskedasticity-based instruments are strong (KP Wald F = 222) and the wine coefficient (0.571) **corroborates** the OLS/FL headline (≈0.43–0.47) through an identification strategy that needs **no common support** (it's about the continuous wine variable, not the binary producer). Caveats to state if used: (i) Lewbel's identifying assumption cov(Z, ε²)=0 is **untestable**; (ii) the KP under-id **LM** p=0.146 is in mild tension with the large Wald F (a known generated-instrument quirk) — so treat as **exploratory corroboration**, not a primary estimate; (iii) N=25.

---

## Recommendation (what to implement)

1. **Producer leg — IPW & entropy balancing → write up as a *documented common-support limit*, not as estimates.** One short paragraph + the overlap numbers (treated French mean 0.51 vs control max 0.17; ebal non-convergence; IPW 196× weight). This *strengthens* the existing D8 framing: the producer effect cannot be separated from language not just in OLS but under any reweighting estimator, because the data have **no overlap** — "lack of evidence, not evidence of lack." The religion/density-only ebal (−11.5) can be a one-line footnote with its caveat.
2. **Wine leg — Lewbel IV → implement as an exploratory robustness row** (wine coef 0.57, CI [0.27, 0.88], KP F 222, Hansen J p=0.13), explicitly flagged as heteroskedasticity-identified and assumption-dependent. It is the one method here that *adds* corroboration rather than documenting a wall.
3. **Do NOT** pursue district/commune disaggregation or canton clustering (out of scope per the dispatch and the standing PI view).

## Parked metrics decision (non-blocking)
`abs_producer = cov2_total_share>0` is an **excise-purchase** indicator ("handles/sells absinthe per Milliet records"), not strictly **manufactures**. This is the published treatment in `T_producer_cascade`, but a later footnote/decision should state whether "producer coalition" = the excise-purchase set (8) or the manufacturing heartland (NE / NE+VD); the `absinthe_dummy*` tiers in `05_expansion.do` already provide that robustness ladder.

## Verification
- `_feasibility_ipw_ebal_lewbel.do` runs rc=0; realized treated set asserted = 8; all RESULT scalars logged. Two in-script bugs found + fixed during verification: (a) ebalance non-convergence is signalled by *no `_webal`*, not a nonzero rc (detection switched to `cap confirm variable`); (b) `reg […pw=_webal], vce(hc3)` is invalid — HC3 disallowed with pweights — switched to `vce(robust)`.
- Packages `ebalance` + `ivreg2h` vendored via `net install` into `libraries/stata` (tracked in `stata.trk`, documented in `_install_stata_packages.do`); `which` resolves both.
- MCP-Stata session healthy throughout (1 parent + 1 worker; no orphans).

---

# Lewbel LOO diagnostic (addendum, 2026-06-09)

**Dispatch:** `quality_reports/coder_dispatch/2026-06-09_lewbel-loo-diagnostic.md`
**Script:** `analysis/scripts/_lewbel_loo_diagnostic.do` (rc=0). **Output:** `analysis/results/intermediate/inference_lewbel_loo.dta` (26 rows: full + 25 LOO).
**Question:** is the surprise KP rk Wald F = 222 (vs the non-rejecting under-ID LM p = 0.146) **genuine**, or driven by one influential canton (NE = heartland = prime suspect)?

## VERDICT = **ROBUST**
Across all 25 single-canton deletions of the feasibility-Task-4 Lewbel spec (`ivreg2h yes_pct (X3_share = ) french_share catholic_share ln_pop_1900, robust`): the wine coefficient **keeps its sign, stays significant at 5% (not just 10%), and the KP F never drops below ~46** — comfortably above the >10 (and the dispatch's >20) bar. Counts: **0 sign flips, 0 fits insignificant at 5%, 0 fits with KP F ≤ 20, 0 failed fits.**

| Fit | wine coef | robust SE | p | KP rk Wald F |
|---|---:|---:|---:|---:|
| Full sample | 0.571 | 0.156 | 0.0002 | 222.3 |
| **drop-NE (heartland — the suspect)** | **0.518** | 0.170 | **0.0023** | **174.1** |
| drop-VD (most influential: min F, max p) | 0.505 | 0.243 | 0.0378 | 46.2 |
| drop-FR (max coef) | 0.735 | 0.099 | ~0 | 90.4 |
| drop-BE (min coef) | 0.495 | 0.166 | 0.0028 | 281.7 |
| **range over all 25 LOO** | **[0.495, 0.735]** | — | **[<0.001, 0.038]** | **[46.2, 502.8]** |

(drop-NE: under-ID LM p = 0.131, Hansen J p = 0.142 — essentially the full-sample values.)

## F-vs-LM tension — characterized (Task 2)
- **3 generated instruments** (`X3_share_{french_share,catholic_share,ln_pop_1900}_g`), 2 over-ID df.
- **Not one-canton-driven:** dropping NE leaves F = 174 (coef 0.52); the lowest LOO F is drop-VD at 46 — still >2× the rule-of-thumb. If the F=222 rested on a single canton, *some* LOO fit would collapse the F toward the weak-IV region; none does.
- **Interpretation: small-N / low-power-LM artifact, not genuine rank fragility.** The Kleibergen-Paap **under-ID LM** test is conservative with few instruments at N=25 (hence p=0.146), while the **weak-ID Wald F** and the LOO-stability both say the first stage is genuinely strong. The tension is a property of the LM test's small-sample power, not evidence that identification hinges on one observation.

## Implication for the PI's appendix-row-vs-drop call
Per the dispatch's decision rule, **ROBUST ⇒ Lewbel qualifies for one online-appendix row + a single main-text sentence** (endogeneity-robustness; explicitly exploratory; the untestable `cov(Z, ε²)=0` identifying assumption stated). It is **not** main-text either way. The appendix row would read: heteroskedasticity-based IV (Lewbel 2012), wine coef 0.57 (95% CI [0.27, 0.88]), KP F = 222, robust to leave-one-out incl. drop-NE — corroborating the OLS/FL headline (~0.43–0.47) via a route that needs no common support. Building that row is a one-table follow-up on the PI's go (kept out of scope here, per "appendix-grade check, not a main result").
