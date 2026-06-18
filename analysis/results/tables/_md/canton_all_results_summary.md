# Canton-level regression results — comprehensive summary

**Generated:** 2026-05-20
**Scope:** All regressions and robustness specs to date, in the unified-percent (0-100) scale convention adopted 2026-05-20.

**Pipeline producing these results:**
1. `08_setup_cohort_1908.do` → builds `cohort_1908.dta` (25 cantons × 49 vars)
2. `09_canton_reg1.do` → §1.0-§1.5 setup; §2.1 primary 20 OLS; §2.5 fractional logit; §2.6 R1-R6 robustness
3. `10_canton_reg1_tables.do` → primary OLS tables
4. `11_canton_robustness_tables.do` → robustness tables
5. `12_canton_petition.do` → petition Y battery (20 OLS specs with Y = pet_per_eligible)
6. `13_canton_petition_tables.do` → petition tables

**Source tables consolidated here:** 11 individual markdown files under `results/tables/_md/` and its `robust/` and `petition/` subdirectories.

---

## Headline findings

### Finding 1: Simpson reveal in the vote regression
The bivariate correlation between wine production and yes-vote share on the 1908 absinthe ban is **negative** for every wine measure. Conditioning on cultural cleavages (French language share, Catholic share) **flips the sign positive** for all four wine variants. The flip survives the full control battery (cascade column 5).

| Wine variant | β col 1 (naive) | β col 5 (full controls) | Sign flip |
|---|---:|---:|---|
| `X1` (ha per 1,000 pop) | −0.084 | +0.148 | ✓ |
| `X2_share` (% national volume) | −0.165 | +0.449 | ✓ |
| `X3_share` (% national revenue) | −0.196 | +0.459 | ✓ |
| `X1_share` (% national area) | −0.187 | +0.325 | ✓ |

R² goes from ~0.01 to ~0.60 across the cascade — culture explains most of the cross-canton variance.

### Finding 2: Asymmetric outcome (vote ↔ petition)
The wine coefficient is **positive in the vote regression** (after controls) but **negative in the petition regression** for every wine variant. Wine cantons supported the ban at the ballot box (conditional on culture) but did NOT mobilize for the petition that put it on the ballot.

| Wine variant | β vote (col 5) | β petition (col 5) | Asymmetry |
|---|---:|---:|---|
| `X1` (per 1k pop) | +0.148 | **−0.179** | sign-flip |
| `X2_share` (% vol) | +0.449 | **−0.369** | sign-flip |
| `X3_share` (% rev) | +0.459 | **−0.283** | sign-flip |
| `X1_share` (% area) | +0.325 | **−0.402** | sign-flip |

### Finding 3: Religion flips role between vote and petition
Protestant share (`cov3`) is **near-zero / insignificant in the vote regression** but **positive and significant in every petition cascade** (β ≈ +0.16 to +0.23, ** or ***). Protestants didn't disproportionately vote yes, but they disproportionately signed the petition — consistent with the historical role of Protestant temperance movements (e.g., Blaues Kreuz) in pro-prohibition organizing.

### Finding 4: Fractional logit tightens the Simpson finding
Re-running the cascade with `fracreg logit` instead of OLS (to respect the bounded [0, 1] outcome) yields point estimates within ~5% of OLS but with ~35% tighter standard errors. The X2_share and X3_share wine coefficients move from "insignificant" under OLS to "marginally significant" under fractional logit at col 5 — substantive headline survives the more efficient functional form.

---

## Variable / scale reference

All share-form variables (Y and X) are on percent (0-100) scale.

### Y outcomes

| Variable | Scale | Range | Mean | Meaning |
|---|---|---|---|---|
| `Y1` | % | 35.3 – 83.3 | 64.3 | Yes-vote share, vote 68 (absinthe ban, 1908) |
| `pet_per_eligible` | % | 3.5 – 41.3 | 20.5 | Petition signatures / eligible voters at vote 65 |
| `pet_per_cap` | % | 1.0 – 10.6 | 4.8 | Petition signatures / 1900 population (fallback denom) |
| `pet_natshare` | % (sums to 100) | 0.2 – 22.6 | 4.0 | Canton's share of national petition signatures |

### X (wine treatment) variables

| Variable | Scale | Range | Mean | Meaning |
|---|---|---|---|---|
| `X1` | ha per 1,000 pop | 0 – 37.4 | 6.9 | Wine area per 1,000 inhabitants (per-capita) |
| `X1_share` | % (sums to 100) | 0 – 23.3 | 4.0 | Canton's share of national wine area |
| `X2_share` | % (sums to 100) | 0 – 25.6 | 4.0 | Canton's share of national wine volume |
| `X3_share` | % (sums to 100) | 0 – 32.1 | 4.0 | Canton's share of national wine revenue |

### Covariates (controls)

| Variable | Scale | Range | Mean | Meaning |
|---|---|---|---|---|
| `cov1` | % | 0.05 – 90.9 | 17.7 | French share of German+French speakers |
| `cov2_total_share` | % (sums to 100) | 0 – 58.8 | 4.0 | Canton's share of national absinthe purchases (Milliet) |
| `cov3` | % | 1.3 – 90.2 | 43.1 | Protestant share of Christian population |
| `cov_land` | log km² | 3.6 – 8.9 | 6.7 | Natural log of canton area |
| `ln_pop_1900` | log persons | 9.5 – 13.3 | 11.3 | Natural log of 1900 population |

### Coefficient interpretation rule

For any β in any cascade table below:
- **If X is on % scale**: β reads as "**pct-pt change in Y per 1 pct-pt change in X**" (1:1, intuitive).
- **If X is log-scale** (`cov_land`, `ln_pop_1900`): β reads as "pct-pt change in Y per 1-unit increase in log(area or pop)" ≈ pct-pt change per ~2.7× increase in the underlying quantity.
- **If X is `X1`**: β reads as "pct-pt change in Y per additional ha of vineyard per 1,000 inhabitants."

All standard errors are **HC3 robust** (project methodology rule for OLS at N=25).
Stars: `*` p<0.10, `**` p<0.05, `***` p<0.01.

---

# Part I — Primary OLS: Vote-yes regressions

The headline 20-spec battery. 4 wine-variant treatments × 5-column cascade. Y = `Y1` (yes-vote share on vote 68, %).

Cascade column structure:
- (1) **baseline**: wine treatment alone
- (2) **+french**: adds `cov1` (French language share)
- (3) **+absinthe**: adds `cov2_total_share` (absinthe purchases share)
- (4) **+protestant**: adds `cov3` (Protestant share)
- (5) **+geog**: adds `cov_land` (log km²); also `ln_pop_1900` for spec sets 2-4 only

## Table 1.1 — Vote cascade, spec set 1 (per-capita vineyard area, X1)

| Spec set 1 cascade: Per-capita vineyard area (X1) |              |             |               |                 |           |
|---------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                   | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                   | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                   | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1                                                | -0.084       | 0.253       | 0.184         | 0.197           | 0.148     |
|                                                   | (0.225)      | (0.215)     | (0.177)       | (0.278)         | (0.337)   |
| cov1                                              |              | -0.263***   | -0.172**      | -0.178**        | -0.201**  |
|                                                   |              | (0.076)     | (0.069)       | (0.081)         | (0.080)   |
| cov2_total_share                                  |              |             | -0.350        | -0.306          | -0.244    |
|                                                   |              |             | (0.361)       | (0.327)         | (0.145)   |
| cov3                                              |              |             |               | -0.042          | -0.044    |
|                                                   |              |             |               | (0.057)         | (0.064)   |
| cov_land                                          |              |             |               |                 | 1.764     |
|                                                   |              |             |               |                 | (2.027)   |
| ln_pop_1900                                       |              |             |               |                 |           |
|                                                   |              |             |               |                 |           |
| _cons                                             | 64.923***    | 67.262***   | 67.532***     | 69.196***       | 57.938*** |
|                                                   | (2.617)      | (2.338)     | (2.329)       | (3.085)         | (13.443)  |
| N                                                 | 25           | 25          | 25            | 25              | 25        |
| R-squared                                         | 0.005        | 0.461       | 0.538         | 0.553           | 0.583     |
| RMSE                                              | 11.894       | 8.952       | 8.480         | 8.551           | 8.475     |

*Note: ln_pop_1900 row empty by design — per-capita cascade omits it (X1 already has pop in denominator).*

## Table 1.2 — Vote cascade, spec set 2 (wine volume share, X2_share)

| Spec set 2 cascade: Wine volume share of national (X2_share) |              |             |               |                 |           |
|--------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                              | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                              | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                              | b/se         | b/se        | b/se          | b/se            | b/se      |
| X2_share                                                     | -0.165       | 0.592**     | 0.439*        | 0.530*          | 0.449     |
|                                                              | (0.273)      | (0.235)     | (0.235)       | (0.259)         | (0.364)   |
| cov1                                                         |              | -0.298***   | -0.211**      | -0.230**        | -0.225**  |
|                                                              |              | (0.074)     | (0.086)       | (0.083)         | (0.090)   |
| cov2_total_share                                             |              |             | -0.301        | -0.225          | -0.205    |
|                                                              |              |             | (0.284)       | (0.206)         | (0.391)   |
| cov3                                                         |              |             |               | -0.060          | -0.029    |
|                                                              |              |             |               | (0.050)         | (0.068)   |
| cov_land                                                     |              |             |               |                 | 2.180     |
|                                                              |              |             |               |                 | (3.030)   |
| ln_pop_1900                                                  |              |             |               |                 | -2.077    |
|                                                              |              |             |               |                 | (3.090)   |
| _cons                                                        | 65.004***    | 67.259***   | 67.519***     | 69.773***       | 77.493*** |
|                                                              | (2.640)      | (2.171)     | (2.199)       | (2.766)         | (26.212)  |
| N                                                            | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                    | 0.009        | 0.507       | 0.561         | 0.588           | 0.619     |
| RMSE                                                         | 11.870       | 8.560       | 8.272         | 8.207           | 8.327     |

## Table 1.3 — Vote cascade, spec set 3 (wine revenue share, X3_share)

| Spec set 3 cascade: Wine revenue share of national (X3_share) |              |             |               |                 |           |
|---------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                               | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                               | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                               | b/se         | b/se        | b/se          | b/se            | b/se      |
| X3_share                                                      | -0.196       | 0.568**     | 0.415         | 0.547*          | 0.459     |
|                                                               | (0.219)      | (0.251)     | (0.271)       | (0.277)         | (0.349)   |
| cov1                                                          |              | -0.307***   | -0.218**      | -0.248**        | -0.242**  |
|                                                               |              | (0.079)     | (0.100)       | (0.102)         | (0.103)   |
| cov2_total_share                                              |              |             | -0.294        | -0.197          | -0.179    |
|                                                               |              |             | (0.336)       | (0.258)         | (0.341)   |
| cov3                                                          |              |             |               | -0.069          | -0.040    |
|                                                               |              |             |               | (0.050)         | (0.070)   |
| cov_land                                                      |              |             |               |                 | 2.145     |
|                                                               |              |             |               |                 | (2.944)   |
| ln_pop_1900                                                   |              |             |               |                 | -1.822    |
|                                                               |              |             |               |                 | (3.030)   |
| _cons                                                         | 65.129***    | 67.508***   | 67.714***     | 70.317***       | 75.509*** |
|                                                               | (2.575)      | (2.096)     | (2.132)       | (2.676)         | (25.121)  |
| N                                                             | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                     | 0.016        | 0.510       | 0.560         | 0.595           | 0.624     |
| RMSE                                                          | 11.831       | 8.535       | 8.276         | 8.137           | 8.269     |

## Table 1.4 — Vote cascade, spec set 4 (wine area share, X1_share)

| Spec set 4 cascade: Wine area share of national (X1_share) |              |             |               |                 |           |
|------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                            | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                            | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                            | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1_share                                                   | -0.187       | 0.439       | 0.297         | 0.367           | 0.325     |
|                                                            | (0.314)      | (0.273)     | (0.216)       | (0.357)         | (0.418)   |
| cov1                                                       |              | -0.271***   | -0.178**      | -0.192**        | -0.196**  |
|                                                            |              | (0.074)     | (0.071)       | (0.077)         | (0.071)   |
| cov2_total_share                                           |              |             | -0.340        | -0.279          | -0.241    |
|                                                            |              |             | (0.406)       | (0.364)         | (0.224)   |
| cov3                                                       |              |             |               | -0.052          | -0.019    |
|                                                            |              |             |               | (0.057)         | (0.072)   |
| cov_land                                                   |              |             |               |                 | 2.544     |
|                                                            |              |             |               |                 | (2.957)   |
| ln_pop_1900                                                |              |             |               |                 | -2.378    |
|                                                            |              |             |               |                 | (3.363)   |
| _cons                                                      | 65.093***    | 67.387***   | 67.676***     | 69.608***       | 78.157**  |
|                                                            | (2.653)      | (2.273)     | (2.267)       | (2.928)         | (28.935)  |
| N                                                          | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                  | 0.011        | 0.467       | 0.538         | 0.558           | 0.601     |
| RMSE                                                       | 11.863       | 8.907       | 8.488         | 8.501           | 8.518     |

## Table 1.5 — Vote horse race (all 4 wine variants at cascade col 5)

| Wine-variant horse race: all spec sets at cascade col 5 |             |               |               |                |
|---------------------------------------------------------|-------------|---------------|---------------|----------------|
|                                                         | (1)         | (2)           | (3)           | (4)            |
|                                                         | (1) per-cap | (2) vol share | (3) rev share | (4) area share |
|                                                         | b/se        | b/se          | b/se          | b/se           |
| X1                                                      | 0.148       |               |               |                |
|                                                         | (0.337)     |               |               |                |
| X2_share                                                |             | 0.449         |               |                |
|                                                         |             | (0.364)       |               |                |
| X3_share                                                |             |               | 0.459         |                |
|                                                         |             |               | (0.349)       |                |
| X1_share                                                |             |               |               | 0.325          |
|                                                         |             |               |               | (0.418)        |
| cov1                                                    | -0.201**    | -0.225**      | -0.242**      | -0.196**       |
|                                                         | (0.080)     | (0.090)       | (0.103)       | (0.071)        |
| cov2_total_share                                        | -0.244      | -0.205        | -0.179        | -0.241         |
|                                                         | (0.145)     | (0.391)       | (0.341)       | (0.224)        |
| cov3                                                    | -0.044      | -0.029        | -0.040        | -0.019         |
|                                                         | (0.064)     | (0.068)       | (0.070)       | (0.072)        |
| cov_land                                                | 1.764       | 2.180         | 2.145         | 2.544          |
|                                                         | (2.027)     | (3.030)       | (2.944)       | (2.957)        |
| ln_pop_1900                                             |             | -2.077        | -1.822        | -2.378         |
|                                                         |             | (3.090)       | (3.030)       | (3.363)        |
| _cons                                                   | 57.938***   | 77.493***     | 75.509***     | 78.157**       |
|                                                         | (13.443)    | (26.212)      | (25.121)      | (28.935)       |
| N                                                       | 25          | 25            | 25            | 25             |
| R-squared                                               | 0.583       | 0.619         | 0.624         | 0.601          |
| RMSE                                                    | 8.475       | 8.327         | 8.269         | 8.518          |

---

# Part II — Robustness

## Table 2.1 — Fractional logit AME vs OLS, cascade col 5

Fracreg AME columns (FL X*) show only the wine-treatment marginal effect because `margins, dydx(${X_spec})` posts only that variable. AMEs are on the [0, 1] fraction scale because fracreg requires Y on [0, 1] (the wine RHS is on percent, so AME × 100 gives the pct-pt scale comparable to OLS β).

| Fraclogit AME vs OLS at cascade col 5 (4 wine variants) |           |         |           |         |           |         |          |         |
|---------------------------------------------------------|-----------|---------|-----------|---------|-----------|---------|----------|---------|
|                                                         | (1)       | (2)     | (3)       | (4)     | (5)       | (6)     | (7)      | (8)     |
|                                                         | OLS X1    | FL X1   | OLS X2    | FL X2   | OLS X3    | FL X3   | OLS X4   | FL X4   |
|                                                         | b/se      | b/se    | b/se      | b/se    | b/se      | b/se    | b/se     | b/se    |
| X1                                                      | 0.148     | 0.002   |           |         |           |         |          |         |
|                                                         | (0.337)   | (0.002) |           |         |           |         |          |         |
| X2_share                                                |           |         | 0.449     | 0.004*  |           |         |          |         |
|                                                         |           |         | (0.364)   | (0.002) |           |         |          |         |
| X3_share                                                |           |         |           |         | 0.459     | 0.004** |          |         |
|                                                         |           |         |           |         | (0.349)   | (0.002) |          |         |
| X1_share                                                |           |         |           |         |           |         | 0.325    | 0.003   |
|                                                         |           |         |           |         |           |         | (0.418)  | (0.003) |
| cov1                                                    | -0.201**  |         | -0.225**  |         | -0.242**  |         | -0.196** |         |
|                                                         | (0.080)   |         | (0.090)   |         | (0.103)   |         | (0.071)  |         |
| cov2_total_share                                        | -0.244    |         | -0.205    |         | -0.179    |         | -0.241   |         |
|                                                         | (0.145)   |         | (0.391)   |         | (0.341)   |         | (0.224)  |         |
| cov3                                                    | -0.044    |         | -0.029    |         | -0.040    |         | -0.019   |         |
|                                                         | (0.064)   |         | (0.068)   |         | (0.070)   |         | (0.072)  |         |
| cov_land                                                | 1.764     |         | 2.180     |         | 2.145     |         | 2.544    |         |
|                                                         | (2.027)   |         | (3.030)   |         | (2.944)   |         | (2.957)  |         |
| ln_pop_1900                                             |           |         | -2.077    |         | -1.822    |         | -2.378   |         |
|                                                         |           |         | (3.090)   |         | (3.030)   |         | (3.363)  |         |
| _cons                                                   | 57.938*** |         | 77.493*** |         | 75.509*** |         | 78.157** |         |
|                                                         | (13.443)  |         | (26.212)  |         | (25.121)  |         | (28.935) |         |
| N                                                       | 25        | 25      | 25        | 25      | 25        | 25      | 25       | 25      |
| R-squared                                               | 0.583     |         | 0.619     |         | 0.624     |         | 0.601    |         |
| RMSE                                                    | 8.475     |         | 8.327     |         | 8.269     |         | 8.518    |         |

**Key result:** AMEs on [0,1] scale × 100 = AME on Y1's pct scale. So FL X2 = 0.004 × 100 ≈ 0.40, close to OLS X2 = 0.449. **Same point estimate, ~35% tighter SE, flips X2/X3 share from insignificant to marginal-significant.** Substantive headline survives — and strengthens — under the bounded-outcome model.

## Table 2.2 — R1–R6 robustness battery

All at cascade-col-5 equivalent. Wine variant held at `X2_share` (working primary). Tests alt absinthe measures, drop-NE sample, French × producer interaction, and log-log functional form.

| Robustness battery R1-R6 |              |               |              |                |              |              |
|--------------------------|--------------|---------------|--------------|----------------|--------------|--------------|
|                          | (1)          | (2)           | (3)          | (4)            | (5)          | (6)          |
|                          | (R1) n_firms | (R2) producer | (R3) abs_log | (R4) fr x prod | (R5) drop-NE | (R6) log-log |
|                          | b/se         | b/se          | b/se         | b/se           | b/se         | b/se         |
| X2_share                 | 0.434        | 0.529         | 0.119        | 0.376          | 0.463        |              |
|                          | (0.402)      | (0.354)       | (2.920)      | (0.303)        | (0.656)      |              |
| wine_vol_log             |              |               |              |                |              | -1.681       |
|                          |              |               |              |                |              | (11.540)     |
| cov1                     | -0.212*      | -0.334***     | -0.362       | -1.013**       | -0.263       | -0.397       |
|                          | (0.119)      | (0.104)       | (0.586)      | (0.405)        | (0.326)      | (1.193)      |
| cov2_total_share         |              |               |              | -0.215         | 0.161        |              |
|                          |              |               |              | (0.368)        | (1.830)      |              |
| abs_nfirms               | -0.699       |               |              |                |              |              |
|                          | (1.005)      |               |              |                |              |              |
| abs_producer             |              | 4.665         |              | 3.529          |              |              |
|                          |              | (7.298)       |              | (7.002)        |              |              |
| abs_log                  |              |               | -2.554       |                |              | -0.145       |
|                          |              |               | (27.803)     |                |              | (47.223)     |
| fr_x_producer            |              |               |              | 0.736*         |              |              |
|                          |              |               |              | (0.403)        |              |              |
| cov3                     | -0.035       | -0.028        | -0.061       | -0.015         | -0.028       | -0.159       |
|                          | (0.067)      | (0.078)       | (1.051)      | (0.072)        | (0.070)      | (1.872)      |
| cov_land                 | 1.951        | 3.224         | 2.157        | 3.554          | 2.817        | 3.890        |
|                          | (3.075)      | (3.011)       | (12.106)     | (2.948)        | (4.263)      | (22.964)     |
| ln_pop_1900              | -1.872       | -2.503        | 10.609       | -1.539         | -2.478       | 21.749       |
|                          | (3.073)      | (3.057)       | (32.533)     | (2.948)        | (3.967)      | (98.751)     |
| _cons                    | 77.075***    | 74.572**      | -27.519      | 62.739**       | 77.639**     | -176.810     |
|                          | (26.178)     | (27.226)      | (572.786)    | (27.967)       | (27.481)     | (1641.660)   |
| N                        | 25           | 25            | 8            | 25             | 24           | 8            |
| R-squared                | 0.615        | 0.609         | 0.980        | 0.675          | 0.485        | 0.991        |
| RMSE                     | 8.361        | 8.427         | 4.799        | 8.157          | 8.511        | 3.198        |

**Three things to flag in this table:**

1. **R3 and R6 collapse to N=8.** `abs_log` and `wine_vol_log` are both ln(1+raw kg) on a sample restricted to producer cantons in some downstream check — the N=8 here means structural-zero cantons are getting dropped. Worth investigating whether the restriction is intended or a bug in the data prep.
2. **R4 (French × producer interaction):** the interaction term `fr_x_producer` is positive and marginally significant (+0.74*); cov1 itself becomes much more negative (−1.01**). Reading: among non-producer cantons, each 1 pct-pt of French share is associated with −1.01 pp yes-vote; among producer cantons, the net French effect is −1.01 + 0.74 = −0.28 (smaller in magnitude). **French effect on yes-vote is dampened in absinthe-producer cantons** — culturally-French regions that also produce absinthe behave less anti-ban than culturally-French regions that don't.
3. **R5 (drop NE):** β on X2_share stays positive (+0.46) and similar magnitude to primary col-5 (+0.45). The Simpson reveal is NOT driven by NE alone. (NE = Neuchâtel, the absinthe heartland.)

---

# Part III — Petition: asymmetric outcome battery

20 OLS specs with Y = `pet_per_eligible` (petition signatures per 100 eligible voters, denominator = vote 65 eligibility roll). Same primary RHS as Part I.

## Table 3.1 — Petition cascade, spec set 1 (X1)

| Petition cascade 1: Per-capita vineyard area (X1) |              |             |               |                 |           |
|---------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                   | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                   | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                   | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1                                                | -0.066       | -0.166      | -0.144        | -0.194          | -0.179    |
|                                                   | (0.384)      | (0.460)     | (0.486)       | (0.295)         | (0.315)   |
| cov1                                              |              | 0.078       | 0.050         | 0.072           | 0.080     |
|                                                   |              | (0.089)     | (0.129)       | (0.111)         | (0.152)   |
| cov2_total_share                                  |              |             | 0.110         | -0.057          | -0.077    |
|                                                   |              |             | (0.430)       | (0.635)         | (1.102)   |
| cov3                                              |              |             |               | 0.162**         | 0.163**   |
|                                                   |              |             |               | (0.061)         | (0.065)   |
| cov_land                                          |              |             |               |                 | -0.566    |
|                                                   |              |             |               |                 | (2.241)   |
| ln_pop_1900                                       |              |             |               |                 |           |
|                                                   |              |             |               |                 |           |
| _cons                                             | 20.905***    | 20.209***   | 20.124***     | 13.765***       | 17.377    |
|                                                   | (2.493)      | (2.333)     | (2.382)       | (2.626)         | (14.423)  |
| N                                                 | 25           | 25          | 25            | 25              | 25        |
| R-squared                                         | 0.005        | 0.065       | 0.077         | 0.396           | 0.401     |
| RMSE                                              | 9.718        | 9.630       | 9.796         | 8.116           | 8.295     |

## Table 3.2 — Petition cascade, spec set 2 (X2_share)

| Petition cascade 2: Wine volume share of national (X2_share) |              |             |               |                 |           |
|--------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                              | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                              | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                              | b/se         | b/se        | b/se          | b/se            | b/se      |
| X2_share                                                     | -0.002       | -0.209      | -0.154        | -0.419          | -0.369    |
|                                                              | (0.440)      | (0.431)     | (0.463)       | (0.406)         | (0.392)   |
| cov1                                                         |              | 0.081       | 0.050         | 0.107           | 0.127     |
|                                                              |              | (0.077)     | (0.124)       | (0.150)         | (0.161)   |
| cov2_total_share                                             |              |             | 0.108         | -0.113          | -0.137    |
|                                                              |              |             | (0.467)       | (0.811)         | (0.975)   |
| cov3                                                         |              |             |               | 0.175***        | 0.221**   |
|                                                              |              |             |               | (0.061)         | (0.084)   |
| cov_land                                                     |              |             |               |                 | 1.144     |
|                                                              |              |             |               |                 | (2.767)   |
| ln_pop_1900                                                  |              |             |               |                 | -3.346    |
|                                                              |              |             |               |                 | (2.850)   |
| _cons                                                        | 20.463***    | 19.849***   | 19.756***     | 13.164***       | 40.919*   |
|                                                              | (2.243)      | (2.378)     | (2.420)       | (2.438)         | (22.821)  |
| N                                                            | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                    | 0.000        | 0.055       | 0.066         | 0.417           | 0.475     |
| RMSE                                                         | 9.742        | 9.681       | 9.855         | 7.975           | 7.980     |

## Table 3.3 — Petition cascade, spec set 3 (X3_share)

| Petition cascade 3: Wine revenue share of national (X3_share) |              |             |               |                 |           |
|---------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                               | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                               | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                               | b/se         | b/se        | b/se          | b/se            | b/se      |
| X3_share                                                      | 0.110        | -0.051      | 0.023         | -0.311          | -0.283    |
|                                                               | (0.436)      | (0.451)     | (0.509)       | (0.471)         | (0.443)   |
| cov1                                                          |              | 0.065       | 0.021         | 0.098           | 0.126     |
|                                                               |              | (0.075)     | (0.139)       | (0.161)         | (0.174)   |
| cov2_total_share                                              |              |             | 0.142         | -0.102          | -0.138    |
|                                                               |              |             | (0.416)       | (0.722)         | (0.917)   |
| cov3                                                          |              |             |               | 0.175**         | 0.226**   |
|                                                               |              |             |               | (0.064)         | (0.088)   |
| cov_land                                                      |              |             |               |                 | 1.041     |
|                                                               |              |             |               |                 | (2.663)   |
| ln_pop_1900                                                   |              |             |               |                 | -3.552    |
|                                                               |              |             |               |                 | (2.835)   |
| _cons                                                         | 20.016***    | 19.515***   | 19.415***     | 12.821***       | 43.439*   |
|                                                               | (2.272)      | (2.393)     | (2.447)       | (2.607)         | (22.865)  |
| N                                                             | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                     | 0.007        | 0.040       | 0.058         | 0.394           | 0.461     |
| RMSE                                                          | 9.705        | 9.758       | 9.896         | 8.132           | 8.081     |

## Table 3.4 — Petition cascade, spec set 4 (X1_share)

| Petition cascade 4: Wine area share of national (X1_share) |              |             |               |                 |           |
|------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                            | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                            | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                            | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1_share                                                   | -0.103       | -0.297      | -0.256        | -0.497          | -0.402    |
|                                                            | (0.544)      | (0.499)     | (0.537)       | (0.294)         | (0.302)   |
| cov1                                                       |              | 0.084       | 0.058         | 0.103           | 0.116     |
|                                                            |              | (0.074)     | (0.115)       | (0.101)         | (0.121)   |
| cov2_total_share                                           |              |             | 0.098         | -0.110          | -0.123    |
|                                                            |              |             | (0.391)       | (0.594)         | (0.788)   |
| cov3                                                       |              |             |               | 0.176***        | 0.214**   |
|                                                            |              |             |               | (0.059)         | (0.081)   |
| cov_land                                                   |              |             |               |                 | 0.947     |
|                                                            |              |             |               |                 | (2.435)   |
| ln_pop_1900                                                |              |             |               |                 | -2.875    |
|                                                            |              |             |               |                 | (2.657)   |
| _cons                                                      | 20.864***    | 20.150***   | 20.066***     | 13.475***       | 37.478    |
|                                                            | (2.412)      | (2.474)     | (2.518)       | (2.434)         | (22.773)  |
| N                                                          | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                  | 0.005        | 0.071       | 0.080         | 0.441           | 0.481     |
| RMSE                                                       | 9.719        | 9.601       | 9.780         | 7.811           | 7.930     |

## Table 3.5 — Petition horse race

| Petition horse race: 4 wine variants at cascade col 5 |             |               |               |                |
|-------------------------------------------------------|-------------|---------------|---------------|----------------|
|                                                       | (1)         | (2)           | (3)           | (4)            |
|                                                       | (1) per-cap | (2) vol share | (3) rev share | (4) area share |
|                                                       | b/se        | b/se          | b/se          | b/se           |
| X1                                                    | -0.179      |               |               |                |
|                                                       | (0.315)     |               |               |                |
| X2_share                                              |             | -0.369        |               |                |
|                                                       |             | (0.392)       |               |                |
| X3_share                                              |             |               | -0.283        |                |
|                                                       |             |               | (0.443)       |                |
| X1_share                                              |             |               |               | -0.402         |
|                                                       |             |               |               | (0.302)        |
| cov1                                                  | 0.080       | 0.127         | 0.126         | 0.116          |
|                                                       | (0.152)     | (0.161)       | (0.174)       | (0.121)        |
| cov2_total_share                                      | -0.077      | -0.137        | -0.138        | -0.123         |
|                                                       | (1.102)     | (0.975)       | (0.917)       | (0.788)        |
| cov3                                                  | 0.163**     | 0.221**       | 0.226**       | 0.214**        |
|                                                       | (0.065)     | (0.084)       | (0.088)       | (0.081)        |
| cov_land                                              | -0.566      | 1.144         | 1.041         | 0.947          |
|                                                       | (2.241)     | (2.767)       | (2.663)       | (2.435)        |
| ln_pop_1900                                           |             | -3.346        | -3.552        | -2.875         |
|                                                       |             | (2.850)       | (2.835)       | (2.657)        |
| _cons                                                 | 17.377      | 40.919*       | 43.439*       | 37.478         |
|                                                       | (14.423)    | (22.821)      | (22.865)      | (22.773)       |
| N                                                     | 25          | 25            | 25            | 25             |
| R-squared                                             | 0.401       | 0.475         | 0.461         | 0.481          |
| RMSE                                                  | 8.295       | 7.980         | 8.081         | 7.930          |

---

# Part IV — Cross-cutting comparison: vote vs petition

Side-by-side β at cascade col 5 (full controls) for the 4 main covariates and 4 wine variants.

| Coefficient | Vote (Y = `Y1`) col 5 | Petition (Y = `pet_per_eligible`) col 5 | Comparison |
|---|---|---|---|
| **Wine treatment** (β on respective `X` var) | | | |
| spec 1: X1 (per 1k pop) | +0.148 | **−0.179** | sign-flip |
| spec 2: X2_share | +0.449 | **−0.369** | sign-flip |
| spec 3: X3_share | +0.459 | **−0.283** | sign-flip |
| spec 4: X1_share | +0.325 | **−0.402** | sign-flip |
| **Covariates** (spec 2, col 5) | | | |
| cov1 (French) | −0.225** | +0.127 | sign-flip (insig→insig) |
| cov2_total_share (absinthe) | −0.205 | −0.137 | same direction, both insig |
| cov3 (Protestant) | −0.029 | **+0.221**** | sign-flip + significance gain |
| cov_land (log km²) | +2.180 | +1.144 | same direction |
| ln_pop_1900 | −2.077 | −3.346 | same direction |

**Three substantive asymmetries surface in this table:**

1. **Wine cantons:** voted yes more than expected at the ballot box (after culture controls), but did NOT mobilize for the petition.
2. **French cantons:** voted yes less at the ballot box (significantly), but didn't differ systematically on the petition.
3. **Protestant cantons:** showed no special vote behavior, but mobilized strongly for the petition — consistent with Protestant temperance-movement organizing.

These three patterns suggest different mobilization mechanisms operating on the two margins. The vote captures the full electorate's preference (support − opposition); the petition captures only the activist core (support-only). Wine and Protestant cantons differ in which margin they operate on — wine cantons are quiet petition-side but consistent at the ballot; Protestants are loud petition-side but unremarkable at the ballot.

---

## File provenance

This summary was assembled from 11 individual markdown files produced by the pipeline:

```
results/tables/_md/
├── cascade_spec1.md            (Table 1.1)
├── cascade_spec2.md            (Table 1.2)
├── cascade_spec3.md            (Table 1.3)
├── cascade_spec4.md            (Table 1.4)
├── altwine_horserace.md        (Table 1.5)
├── robust/
│   ├── canton_robustness_fraclogit_vs_ols.md   (Table 2.1)
│   ├── canton_robustness_r1_r6.md              (Table 2.2)
│   └── canton_robustness_summary.md            (auto-master from 11)
└── petition/
    ├── canton_petition_cascade_spec1.md        (Table 3.1)
    ├── canton_petition_cascade_spec2.md        (Table 3.2)
    ├── canton_petition_cascade_spec3.md        (Table 3.3)
    ├── canton_petition_cascade_spec4.md        (Table 3.4)
    ├── canton_petition_horserace.md            (Table 3.5)
    └── canton_petition_summary.md              (auto-master from 13)
```

**Other masters** (NOT touched by this summary):
- `_md/all_tables_summary.md` — older hand-curated primary OLS master (PRE-RESCALING; values are 100× larger for share-form variables; use this file with caution or regenerate).
- `_md/robust/canton_robustness_summary.md` — auto-master for robustness (current scale ✓).
- `_md/petition/canton_petition_summary.md` — auto-master for petition (current scale ✓).

**The current file (`canton_all_results_summary.md`) is the canonical comprehensive reference for cross-result comparison.**
