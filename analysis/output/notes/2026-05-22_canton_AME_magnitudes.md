# Canton-level AME magnitudes for §5.1 — M1A-5 FL vote #68

**Generated:** 2026-05-22 by `analysis/scripts/_canton_ame_magnitudes.do`
**Companion dataset:** `analysis/processed/intermediate/canton_ame_magnitudes.dta` (N=25, sorted descending on `X3_share`)
**Dispatch:** `Brainstorm-Absinthe/.../coder_dispatch/2026-05-22_pc-coder-canton-AME-magnitudes.md` (gallant-thompson worktree)

---

## Model and headline

**Spec (M1A-5 FL #68):**
```stata
fracreg logit Y1_frac X3_share cov1 cov2_total_share cov3 ln_density, vce(robust)
```
- `Y1_frac` = yes-share on vote #68 (1908 absinthe ban) on [0,1] scale
- `X3_share` = wine revenue, canton's national share (%, 1907; Cahannes data) — the headline X
- `cov1` = French language share (%)
- `cov2_total_share` = absinthe industry share (%)
- `cov3` = Protestant share (%)
- `ln_density` = log population density

**Fit:** N=25, log-likelihood = −15.857.

**Headline AME on `X3_share`:** **0.434 pp Y per pp X** (SE = 0.195) — exactly matches the dispatch's claimed value. Phase A′ convention applied (AME is multiplied by 100 to convert from fracreg's proportion-Y units to pp Y per pp X).

---

## Block A + B — Per-canton observed values + counterfactual predictions

For the four case-study cantons (VD, NE, ZH, UR):

| Canton | `X3_share` (pp) | `cov1` Fr (pp) | `cov2_tot` Abs (pp) | `cov3` Pr (pp) | `ln_density` | Observed Y (pp) | Predicted Y at obs (pp) | Counterfactual Y at X3=0 (pp) | Δ<sup>wine</sup> (pp) | AME-linear: 0.434·X3 (pp) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **VD** Vaud         | 32.11 | 90.90 | 10.25 | 86.78 | 4.603 | 56.13 | 57.32 | 41.71 | **+15.61** | 13.93 |
| **NE** Neuchâtel    |  5.43 | 85.57 | 58.84 | 85.82 | 5.173 | 35.26 | 36.03 | 33.61 |  **+2.42** |  2.36 |
| **ZH** Zurich       | 14.50 |  0.93 |  0.00 | 81.05 | 5.562 | 75.93 | 70.25 | 63.99 |  **+6.26** |  6.29 |
| **UR** Uri          |  0.00 |  0.13 |  0.00 |  3.92 | 2.927 | 70.56 | 72.12 | 72.12 |   **0.00** |  0.00 |

Notation:
- **Predicted Y at obs**: in-sample `predict` from the FL model.
- **Counterfactual Y at X3=0**: same model, same canton's other covariates, but with `X3_share` zeroed.
- **Δ<sup>wine</sup>**: predicted-yes share attributable to the wine-coalition channel (the structural counterfactual).
- **AME-linear**: linear approximation 0.434 × X3<sub>i</sub>. Comparing the two columns reveals where logistic curvature matters.

### Curvature observations

- **VD** (X3 = 32.11): linear-approx 13.93 pp **understates** the structural Δ<sup>wine</sup> of 15.61 pp. VD sits in the steep portion of the logistic curve where the AME (a sample-average linearization) loses about 11% relative to the canton's own-baseline marginal effect.
- **NE, ZH**: linear approximation matches the structural counterfactual to within ~0.05 pp. The logistic curvature is invisible at low-to-moderate X3.
- **UR**: trivial case — X3 = 0 means the counterfactual is the observed prediction; no curvature to observe.

---

## Block C — Cross-canton ranking on `X3_share`

### Top 5 by wine revenue national share

| Rank | Canton | `X3_share` (pp) | Observed Y (pp) | Predicted Y (pp) |
|---:|---|---:|---:|---:|
| 1 | VD | 32.11 | 56.13 | 57.32 |
| 2 | VS | 19.53 | 61.75 | 65.07 |
| 3 | ZH | 14.50 | 75.93 | 70.25 |
| 4 | TI |  6.16 | 68.37 | 70.51 |
| 5 | NE |  5.43 | 35.26 | 36.03 |

### Bottom 5 by wine revenue national share

All five report exactly 0.00% — alpine non-wine cantons whose `X3_share` rounds to zero. Ordered alphabetically:

| Canton | `X3_share` (pp) | Observed Y (pp) | Predicted Y (pp) |
|---|---:|---:|---:|
| AI | 0.00 | 60.59 | 69.35 |
| NW | 0.00 | 82.48 | 70.20 |
| OW | 0.00 | 65.41 | 71.20 |
| UR | 0.00 | 70.56 | 72.12 |
| ZG | 0.00 | 61.91 | 68.03 |

### Median canton (rank 13 of 25)

**BL** (Basel-Landschaft): `X3_share` = 1.21 pp, observed Y = 55.18 pp, predicted Y = 65.69 pp.

> Headline phrasing for the paper: "VD ranks #1 of 25 cantons on wine revenue national share, with X<sub>3,VD</sub> = 32.1%; the median canton (Basel-Landschaft) has X<sub>3,BL</sub> = 1.2%, and the bottom five alpine cantons (AI, NW, OW, UR, ZG) all report X<sub>3</sub> ≈ 0%."

---

## One-line interpretive gloss per case-study canton

- **VD (Vaud) — wine-coalition mechanism in isolation:** of the canton's predicted yes-share of 57.3 pp, Δ<sup>wine</sup><sub>VD</sub> = **+15.6 pp is attributable to the wine-coalition channel**, leaving 41.7 pp explained by VD's high French share, near-zero absinthe production, Protestantism, and density. The wine channel takes a non-producer French canton from below-majority (41.7 pp) to majority support.
- **NE (Neuchâtel) — producer-resistance dominates:** despite a non-trivial wine revenue share (5.4 pp), NE voted strongly NO (Y<sub>obs</sub> = 35.3 pp), and the model fits closely (Y<sub>pred</sub> = 36.0 pp). The wine channel adds only **+2.4 pp** to NE's predicted yes-share, far outweighed by the negative pull from NE's dominant absinthe industry share (58.8 pp, the highest in the sample). The counterfactual yes-share at X3=0 (33.6 pp) is still well below majority — NE's no-vote is driven by producer resistance, not the absence of a wine constituency.
- **ZH (Zurich) — strongest yes-vote despite low French share:** with X<sub>3</sub> = 14.5 pp (the German-speaking wine producer), zero absinthe industry, and a large urban Protestant population, ZH delivered the highest observed yes-share (75.9 pp) — though the model slightly under-predicts (70.3 pp). The wine channel contributes **+6.3 pp** of the predicted yes; the residual 63.9 pp is the temperance-mechanism baseline (Protestant + urban density). The ~5.7 pp under-prediction may reflect a Zurich-specific factor (urban temperance organization, perhaps) not captured in the model.
- **UR (Uri) — structural baseline:** zero wine, zero absinthe, alpine Catholic. The wine-coalition channel contributes **0.0 pp** to UR's predicted yes-share. UR voted yes at 70.6 pp despite having essentially none of the model's covariate drivers — the model picks up 72.1 pp from the intercept plus ln_density, suggesting that the structural baseline yes-share (without any wine or anti-producer pull) is around 70 pp for a low-population Catholic canton.

---

## Cross-canton structural takeaway

The four cantons span the 2×2 cross-tabulation that motivates the M1A-5 specification:

| | Non-producer (Abs = 0) | Producer (Abs > 0) |
|---|---|---|
| **High wine (X3 ≥ median)** | **VD, ZH**: wine channel contributes +6 to +16 pp to predicted yes (VD biggest because highest X3). Both vote yes. | **NE**: wine channel contributes only +2.4 pp; producer pull dominates. Votes no. |
| **Zero wine (X3 = 0)** | **UR + the four other alpine cantons (AI, NW, OW, ZG)**: wine channel contributes 0 pp. Yes-share entirely from non-wine drivers. All vote yes. | — (empty cell: no canton produces absinthe without producing wine) |

The wine channel is the single largest mechanism for **non-producing wine cantons (VD, ZH)** — it pushes them above majority. It is **not sufficient to override producer resistance** in NE (the single producer in the sample), nor is it **necessary** for yes-vote majorities in the alpine non-wine, non-French cantons (UR + 4 others) whose yes-share is driven entirely by language/religion/density covariates.

---

## Provenance and reproducibility

- **Script:** [`analysis/scripts/_canton_ame_magnitudes.do`](../../scripts/_canton_ame_magnitudes.do) (~150 lines, standalone — not part of `run.do`).
- **Source cohort:** `processed/cohort_1908_workshop.dta` (built by `08_setup_cohort_1908_workshop.do` + `09_canton_reg1_workshop.do`).
- **Model identity:** the FL re-estimation in `_canton_ame_magnitudes.do` reproduces the headline AME = 0.434 from the existing `estimates_fraclogit_workshop/fl_3_5.ster` exactly. No modifications were made to the M1A-5 estimation pipeline (per dispatch acceptance criterion 6).
- **Backing dataset:** `processed/intermediate/canton_ame_magnitudes.dta` contains all N=25 cantons with `yhat_obs`, `yhat_obs_pct`, `yhat_x3_zero_pct`, `delta_wine`, `ame_linear` (sorted descending on `X3_share`) for downstream extension to an appendix table if requested.

## Caveats

1. **Counterfactuals at observed canton covariates**, not at sample means — per dispatch instruction. Each canton's Δ<sup>wine</sup> is conditional on that canton's own Fr, Abs, Pr, ln_density.
2. **No SE on the counterfactuals** — point estimates only, per dispatch ("HC3/sandwich SE not required for this dispatch").
3. **Logistic-curvature note**: the AME-linear approximation understates the structural Δ<sup>wine</sup> at high X3 (VD: 13.9 vs 15.6, ~11% gap). For cantons in the bulk of the X3 distribution (≤ ~15 pp), the two coincide.
4. **The headline AME (0.434) is the sample-average marginal effect**, not the canton-specific marginal effect. The structural Δ<sup>wine</sup> values reported above are the canton-specific own-baseline marginal contributions and are the more substantively appropriate quantity for the §5.1 case study.
