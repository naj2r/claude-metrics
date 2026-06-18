# Scoping: cross-referendum RI battery → R / parallel execution

**Date**: 2026-06-09
**Author**: metrics agent (c-metrics-absinthe1)
**Type**: scoping / feasibility memo (NOT an implementation plan — no code lands from this doc)
**Trigger**: PI — "skip the R port [of the canton battery] for now, but scope the cross-referendum battery's RI with the R/parallel option in mind, since that's where it'd actually pay off."
**Companion**: the canton small-N RI (script 22 §2) stays in Stata; see `_inference_battery_run.do`. This memo is only about the **placebo / cross-referendum** RI family in `05_expansion.do`.

---

## 1. TL;DR / recommendation

- **Do NOT port the *current* T14b for its own sake.** As written it is 15 votes × **one OLS-t cell** × 10k ≈ **3–5 min** in Stata (its own header's estimate; OLS RI gets no benefit from MP anyway). R/parallel would cut that to tens of seconds — not worth a second engine.
- **DO build a parallel R harness the moment the cross-referendum battery is asked to match the headline's FL-AME RI rigor.** A referee will reasonably ask why the headline vote (#68) gets fractional-logit-AME RI while the placebo battery gets only OLS-t. Answering that = **FL-AME RI × 15 votes**, which is a **~2-hour serial** job in Stata (and **~10 hours** if extended to the 5-spec cascade). On 28 cores in R that is **single-digit-to-tens of minutes**. *That* is the payoff the PI is pointing at.
- **Engine boundary (important):** keep the **in-text** headline vote-#68 RI (T13, `05_expansion.do` §10.14 / earlier cells) in Stata as the canonical engine. Move only the **appendix** placebo battery (T14b) to R. No in-text number ever changes engines; the two only need to agree to Monte-Carlo error.
- **Integration keeps the pipeline intact:** the R harness reads `processed/placebo_panel.dta`, writes the **identical** `results/intermediate/t14b_ri_battery.dta` schema, and is invoked from Stata via the project's existing `rscript` ado. The downstream table builder (`05_expansion.do` §12.8b) is unchanged.

---

## 2. The target, exactly as it stands

**Primary target — T14b systematic battery** (`05_expansion.do` §10.14b, lines ~1381–1427):

```stata
foreach v of numlist 56/70 {                      // 15 federal votes (anr 56–70)
    use "$MyProject/processed/placebo_panel.dta", clear
    keep if anr == `v'                            // N = 25 cantons per vote
    ritest vineyard_per_cap _b[vineyard_per_cap]/_se[vineyard_per_cap], ///
        reps(10000) seed(20260430) nodots: ///
        reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
    // p = el(r(p),1,1);  SE = sqrt(p(1-p)/10000)
}
// -> results/intermediate/t14b_ri_battery.dta  (anr, ri_p_10k, ri_p_se)
// -> consumed by §12.8b for the T14b table
```

- **Statistic**: HC3 **t-stat** of `vineyard_per_cap` (`_b/_se`) — note this is the t-stat, not the raw β (so the SE definition matters for fidelity).
- **KEY spec**: `yes_pct ~ vineyard_per_cap + french_share + catholic_share` (the Simpson's-flip spec; **no** `ln_pop` here — distinct from the canton battery's col-5 control set).
- **Permutation scheme**: `ritest` permutes the focal regressor (`vineyard_per_cap`) across the 25 cantons, controls held fixed, 10,000 draws, one seed (`20260430`).
- **I/O**: reads the long panel `placebo_panel.dta` (15 votes × 25 cantons); writes a 15-row `.dta` (`anr`, `ri_p_10k`, `ri_p_se`).

**Sibling cells (same family, smaller):** §10.14 runs the same RI on the 3 wine-relevant votes {63, 65, 68} (subsumed by T14b at the same seed). The **headline** vote-#68 RI (the cells around lines 349/372/395 and §10.x) feeds **T13** and is **in-text** — keep it in Stata (see engine boundary above).

---

## 3. Why this battery, not the canton battery

| | Canton small-N RI (script 22 §2) | Cross-ref battery (T14b, §10.14b) |
|---|---|---|
| Shape | 15 cells on **one** 25-canton sample | **15 votes** × cell(s), each its own 25-canton fit |
| Parallel axis | perms only | **votes × perms** (two independent axes) |
| Current cost | ~65–75 min (FL-AME-dominated), validated one-off | ~3–5 min now; **but the rigor-matching expansion is hours** |
| Re-run frequency | rarely (frozen result) | **often** (add votes, add FL-AME, referee asks) |
| Verdict | keep in Stata (validated, small, done) | **the right parallel target** (recurring, large, embarrassingly parallel) |

The canton battery is a validated, run-once-and-freeze job — porting it buys nothing. The cross-referendum battery is where work *recurs and grows*, and its work is embarrassingly parallel along two axes (vote, perm). That is exactly the profile where 28 cores pays off.

---

## 4. Cost projections (why the expansion is the case)

Per-permutation costs measured on this machine, N=25, 2026-06-09 (StataMP, 1 core; ritest overhead included):

- OLS-t cell: ~0.002 s/perm *effective* (T14b's documented 3–5 min for 15×10k implies this; a direct micro-bench read ~0.015 s/perm but that timer absorbed ritest's one-time ado-load — treat OLS as cheap).
- **FL-AME cell: ~0.047 s/perm** (clean measurement; `fracreg logit` + `margins, dydx() post` per perm). MP gives **no** speedup at N=25 (measured: 1 core ran ~20% *faster* than 8).

| Scenario | Fits | Stata serial (1 core) | R / 28 cores (~22 eff.) |
|---|---:|---:|---:|
| **Current T14b**: 15 votes × OLS-t × 10k | 150k OLS | **~3–5 min** | ~10–40 s |
| **+ FL-AME RI per vote**: 15 × FL × 10k | 150k FL | **~2 hours** | **~1–5 min** |
| **+ 5-spec cascade × FL-AME**: 15 × 5 × FL × 10k | 750k FL | **~10 hours** | **~5–20 min** |

R wall-clock assumes ~80% parallel efficiency on 28 cores and that R's `glm` + a hand-coded fractional-logit AME is at least as fast per fit as Stata's `fracreg`+`margins` (it generally is, since it sheds `margins`' delta-method and `ritest`'s ado overhead). The headline: **the rigor-matching expansion is a multi-hour serial job that becomes minutes in parallel.**

---

## 5. R / parallel architecture (sketch)

**Parallelize across votes first, perms second.** 15 votes ≤ 28 cores, so the simplest correct mapping is one worker per vote, each running its own 10k-perm RI serially; if a single vote's perm loop is the bottleneck (FL case), nest a perm-chunk split. Either way the slowest single chain is one vote's 10k RI.

```r
# cross_ref_ri.R  (sketch — not final)
library(haven); library(sandwich); library(future); library(furrr)
panel <- read_dta(file.path(Sys.getenv("MyProject"), "processed/placebo_panel.dta"))
votes <- 56:70
plan(multisession, workers = 28)

ri_one_vote <- function(v, reps = 10000L) {
  d <- subset(panel, anr == v)                       # N = 25
  stat_obs <- t_hc3(lm(yes_pct ~ vineyard_per_cap + french_share + catholic_share, d))
  # permute focal regressor across the 25 cantons, controls fixed:
  perm <- replicate(reps, {
    dp <- d; dp$vineyard_per_cap <- sample(dp$vineyard_per_cap)
    t_hc3(lm(yes_pct ~ vineyard_per_cap + french_share + catholic_share, dp))
  })
  p <- mean(abs(perm) >= abs(stat_obs))              # two-sided, matches ritest default
  data.frame(anr = v, ri_p_10k = p, ri_p_se = sqrt(p*(1-p)/reps))
}
# t_hc3(fit) = coef/SE on vineyard_per_cap with sandwich::vcovHC(fit, "HC3")
res <- future_map_dfr(votes, ri_one_vote,
                      .options = furrr_options(seed = TRUE))   # L'Ecuyer streams
write_dta(res, file.path(Sys.getenv("MyProject"),
          "results/intermediate/t14b_ri_battery.dta"))
```

Key engineering points:
- **Estimator port.** OLS-t: `lm()` + `sandwich::vcovHC(fit, type = "HC3")` → t = β/SE, matching Stata `vce(hc3)`. FL extension: `glm(family = quasibinomial("logit"))` (reproduces `fracreg logit` point estimates) + a **hand-coded AME** for the focal regressor (avoids `marginaleffects` per-call overhead; for the logit link the AME = mean over i of β·Λ(xβ)(1−Λ(xβ))).
- **Seeding / reproducibility (load-bearing).** Parallel RNG **must** use independent streams or results aren't reproducible: `furrr_options(seed = TRUE)` (or `parallel::clusterSetRNGStream`) gives per-worker L'Ecuyer-CMRG streams from one master seed. This **replaces** Stata's single `seed(20260430)` — document the master seed + stream scheme in the script header and the memo so the battery is re-runnable bit-for-bit.
- **I/O contract = unchanged pipeline.** Read `placebo_panel.dta` (`haven::read_dta`), write the **identical** `t14b_ri_battery.dta` schema. The Stata table builder (§12.8b) and the `.tex`/`.md` output are untouched — only the *compute engine* moves.
- **Pipeline integration.** Invoke from Stata via the project's existing `rscript` ado (`rscript using "$MyProject/scripts/cross_ref_ri.R"`), so `run.do` orchestration and the replication archive stay single-entry. Add `future`, `furrr`, `sandwich`, `haven` to `_install_R_packages.R` (the compliant install path — never inline `install.packages` in analysis code).

---

## 6. Fidelity & validation plan

A second RI engine is only acceptable if proven faithful. Before any R output feeds a table:

1. **Pin the observed statistic.** For ≥2 votes (the signal vote #68 and one null, e.g. #67), confirm R's HC3 t-stat on the *observed* fit equals Stata's `_b/_se` to numerical precision. (If these don't match, nothing downstream can.)
2. **Reproduce the RI p-value within MCSE.** Run the R battery and compare each vote's `ri_p_10k` to the committed Stata `t14b_ri_battery.dta`. Expected agreement: **±~0.006** at p≈0.1, 10k perms (MCSE = √(p(1−p)/10000)). Agreement at this level = faithful (it's the same as re-running Stata with a different seed). Disagreement beyond ~3×MCSE = a port bug (statistic, permutation scheme, or one-/two-sided mismatch).
3. **Match the tail convention.** `ritest`'s default p is two-sided on |stat| — mirror it (`mean(abs(perm) >= abs(stat_obs))`), or set both engines to the same convention explicitly.

---

## 7. Provenance / comparability caveat

- **Not a methodology-floor issue.** The 10k-perm floor is preserved, the statistic (HC3 t) is unchanged, and the permutation scheme is identical. R vs Stata agree up to Monte-Carlo error — exactly like re-seeding Stata. This does **not** violate the methodology-integrity rule (no precision is traded; reps stay at 10k).
- **It is a provenance surface.** Introducing R for one table means a referee/coauthor re-running the *Stata* pipeline won't bit-reproduce the R numbers, and you maintain two implementations. Mitigations: (i) validate per §6 and commit the validation log; (ii) document the seed-stream scheme; (iii) keep the **engine boundary** — Stata canonical for in-text T13, R for the appendix T14b battery — so no headline number depends on R; (iv) optionally run both for the first release and assert agreement.

---

## 8. Decision points for the PI

1. **Trigger**: build the R harness now (proactive), or only when the FL-AME-per-vote expansion is actually requested? (Recommend: build when the expansion is on the table — that's when it pays for itself.)
2. **Scope of port**: T14b OLS-t only (validation target), or T14b + FL-AME-per-vote + cascade (the expensive expansion)? (The expansion is the reason to do it at all.)
3. **Canonical engine**: Stata-canonical with R as a validated accelerator (run both, assert agreement) vs R-as-canonical for the appendix battery (one engine for that table). (Recommend the former for the first release, then collapse to R-canonical for the appendix once trust is established.)
4. **Seed scheme**: approve a documented master seed + L'Ecuyer-stream convention to replace Stata's single `seed(20260430)`.

---

## 9. Out of scope / non-goals

- **Not** porting the canton small-N RI (script 22 §2) — it stays in Stata (validated one-off; FL-dominated; ~65 min; no recurring need).
- **Not** changing the 10k-perm floor, the KEY spec, the vote set, or the HC3 statistic — this is an *execution-engine* scope only.
- **Not** moving the in-text headline RI (T13) off Stata.
- `rscript` integration and `_install_R_packages.R` additions are the only pipeline touches; no `run.do` re-ordering beyond adding the (optional) `rscript` call.

---

## 10. Provenance

- Current battery: `analysis/scripts/05_expansion.do` §10.14 (3 votes) + §10.14b (T14b, 15 votes, lines ~1381–1427) → `results/intermediate/t14b_ri_battery.dta` → §12.8b table.
- Input panel: `analysis/processed/placebo_panel.dta` (long; 15 votes × 25 cantons).
- Per-perm benchmark + license facts: this session, 2026-06-09 (StataMP "Single-user 8-core"; FL-AME ~0.047 s/perm 1-core, ~0.059 s/perm 8-core; OLS-t cheap).
- Canton battery (the *non*-target, for contrast): `analysis/scripts/22_canton_inference_battery.do`, `_inference_battery_run.do`.
- Related: `quality_reports/coder_reports/2026-06-09_feasibility-ipw-ebal-lewbel.md`; commit `e082b49` (Tier 1.1 T14b battery).
