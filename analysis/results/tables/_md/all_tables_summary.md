# Canton-level regression battery — summary of all tables

Generated from 20 OLS estimates produced by `09_canton_reg1.do §2`,
formatted by `10_canton_reg1_tables.do`, post-processed to markdown by
`scripts/python/esttab_csv_to_markdown.py`.

**Design**: 4 wine-variant treatments × 5-column cascade = 20 specifications.
HC3 robust standard errors throughout (project methodology rule for OLS at N=25).
Priorban tabled per coder dispatch; RI 10,000-perm permutation inference deferred
to a later inference layer.

**Outcome variable Y1**: yes-vote share on Swiss federal vote #68 (1908 absinthe ban),
canton-level, 0–100 scale.

**Wine variants (treatments)**:

| k | Variable | Construction | Units |
|---|---|---|---|
| 1 | `X1` | wine_ha / pop_1900 | ha per person |
| 2 | `X2_share` | wine_volume_canton_hl / national total | [0,1] share |
| 3 | `X3_share` | wine_revenue_canton_fr / national total | [0,1] share |
| 4 | `X1_share` | wine_area_canton_ha / national total | [0,1] share |

**Cascade columns** (M1A-style, baseline → full):

| Col | Adds | Family |
|---|---|---|
| (1) | treatment only | — |
| (2) | + `cov1` (French language share) | both |
| (3) | + `cov2_total_share` (Milliet absinthe purchases share) | both |
| (4) | + `cov3` (Protestant share) | both |
| (5) | + `cov_land` (ln canton area); + `ln_pop_1900` for share specs only | per-cap vs share |

**Headline finding (the Simpson reveal)**: In every cascade, the wine coefficient
starts negative or near-zero in column (1) — the naive bivariate correlation —
and flips substantively positive once French-language share enters at column (2).
The flip survives the full control battery (column 5) in all four wine variants.

| Spec set | Wine var | β col (1) | β col (5) | Sign flip |
|---|---|---:|---:|---|
| 1 (per-cap)    | X1       | −84.10  | +148.47 | ✓ |
| 2 (vol share)  | X2_share | −16.49  | +44.90  | ✓ |
| 3 (rev share)  | X3_share | −19.63  | +45.87  | ✓ |
| 4 (area share) | X1_share | −18.73  | +32.45  | ✓ |

The cov1 (French language) coefficient is the dominant control in every cascade,
consistently large-negative and statistically significant (** or ***).

---

## Table 1 — Spec set 1 cascade: Per-capita vineyard area (X1)

| Spec set 1 cascade: Per-capita vineyard area (X1) |              |             |               |                 |           |
|---------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                   | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                   | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                   | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1                                                | -84.100      | 253.020     | 183.756       | 196.787         | 148.470   |
|                                                   | (224.733)    | (214.582)   | (177.131)     | (278.379)       | (336.878) |
| cov1                                              |              | -26.304***  | -17.230**     | -17.816**       | -20.086** |
|                                                   |              | (7.550)     | (6.852)       | (8.082)         | (8.037)   |
| cov2_total_share                                  |              |             | -35.005       | -30.632         | -24.437   |
|                                                   |              |             | (36.110)      | (32.654)        | (14.485)  |
| cov3                                              |              |             |               | -4.238          | -4.435    |
|                                                   |              |             |               | (5.741)         | (6.385)   |
| cov_land                                          |              |             |               |                 | 1.764     |
|                                                   |              |             |               |                 | (2.027)   |
| ln_pop_1900                                       |              |             |               |                 |           |
|                                                   |              |             |               |                 |           |
| _cons                                             | 64.923***    | 67.262***   | 67.532***     | 69.196***       | 57.938*** |
|                                                   | (2.617)      | (2.338)     | (2.329)       | (3.085)         | (13.443)  |
| N                                                 | 25           | 25          | 25            | 25              | 25        |
| R-squared                                         | 0.005        | 0.461       | 0.538         | 0.553           | 0.583     |
| RMSE                                              | 11.894       | 8.952       | 8.480         | 8.551           | 8.475     |

*Note: ln_pop_1900 row is empty by design — per-cap cascade (`ctrl_1_*`) intentionally
omits ln_pop_1900 because pop_1900 is already in X1's LHS denominator (adding it RHS
would create a definitional dependency).*

---

## Table 2 — Spec set 2 cascade: Wine volume share of national (X2_share)

| Spec set 2 cascade: Wine volume share of national (X2_share) |              |             |               |                 |           |
|--------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                              | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                              | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                              | b/se         | b/se        | b/se          | b/se            | b/se      |
| X2_share                                                     | -16.493      | 59.239**    | 43.914*       | 52.992*         | 44.899    |
|                                                              | (27.337)     | (23.523)    | (23.507)      | (25.922)        | (36.408)  |
| cov1                                                         |              | -29.834***  | -21.051**     | -22.999**       | -22.491** |
|                                                              |              | (7.402)     | (8.556)       | (8.284)         | (8.984)   |
| cov2_total_share                                             |              |             | -30.075       | -22.510         | -20.546   |
|                                                              |              |             | (28.405)      | (20.608)        | (39.107)  |
| cov3                                                         |              |             |               | -5.980          | -2.890    |
|                                                              |              |             |               | (4.951)         | (6.823)   |
| cov_land                                                     |              |             |               |                 | 2.180     |
|                                                              |              |             |               |                 | (3.030)   |
| ln_pop_1900                                                  |              |             |               |                 | -2.077    |
|                                                              |              |             |               |                 | (3.090)   |
| _cons                                                        | 65.004***    | 67.259***   | 67.519***     | 69.773***       | 77.493*** |
|                                                              | (2.640)      | (2.171)     | (2.199)       | (2.766)         | (26.212)  |
| N                                                            | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                    | 0.009        | 0.507       | 0.561         | 0.588           | 0.619     |
| RMSE                                                         | 11.870       | 8.560       | 8.272         | 8.207           | 8.327     |

---

## Table 3 — Spec set 3 cascade: Wine revenue share of national (X3_share)

| Spec set 3 cascade: Wine revenue share of national (X3_share) |              |             |               |                 |           |
|---------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                               | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                               | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                               | b/se         | b/se        | b/se          | b/se            | b/se      |
| X3_share                                                      | -19.629      | 56.753**    | 41.534        | 54.697*         | 45.869    |
|                                                               | (21.854)     | (25.064)    | (27.082)      | (27.734)        | (34.902)  |
| cov1                                                          |              | -30.677***  | -21.769**     | -24.787**       | -24.224** |
|                                                               |              | (7.942)     | (10.017)      | (10.227)        | (10.314)  |
| cov2_total_share                                              |              |             | -29.381       | -19.748         | -17.860   |
|                                                               |              |             | (33.626)      | (25.798)        | (34.097)  |
| cov3                                                          |              |             |               | -6.923          | -4.039    |
|                                                               |              |             |               | (4.950)         | (6.971)   |
| cov_land                                                      |              |             |               |                 | 2.145     |
|                                                               |              |             |               |                 | (2.944)   |
| ln_pop_1900                                                   |              |             |               |                 | -1.822    |
|                                                               |              |             |               |                 | (3.030)   |
| _cons                                                         | 65.129***    | 67.508***   | 67.714***     | 70.317***       | 75.509*** |
|                                                               | (2.575)      | (2.096)     | (2.132)       | (2.676)         | (25.121)  |
| N                                                             | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                     | 0.016        | 0.510       | 0.560         | 0.595           | 0.624     |
| RMSE                                                          | 11.831       | 8.535       | 8.276         | 8.137           | 8.269     |

---

## Table 4 — Spec set 4 cascade: Wine area share of national (X1_share)

| Spec set 4 cascade: Wine area share of national (X1_share) |              |             |               |                 |           |
|------------------------------------------------------------|--------------|-------------|---------------|-----------------|-----------|
|                                                            | (1)          | (2)         | (3)           | (4)             | (5)       |
|                                                            | (1) baseline | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog |
|                                                            | b/se         | b/se        | b/se          | b/se            | b/se      |
| X1_share                                                   | -18.727      | 43.873      | 29.705        | 36.745          | 32.453    |
|                                                            | (31.385)     | (27.305)    | (21.569)      | (35.736)        | (41.758)  |
| cov1                                                       |              | -27.089***  | -17.844**     | -19.170**       | -19.613** |
|                                                            |              | (7.397)     | (7.085)       | (7.666)         | (7.107)   |
| cov2_total_share                                           |              |             | -34.000       | -27.907         | -24.119   |
|                                                            |              |             | (40.631)      | (36.375)        | (22.424)  |
| cov3                                                       |              |             |               | -5.161          | -1.853    |
|                                                            |              |             |               | (5.709)         | (7.190)   |
| cov_land                                                   |              |             |               |                 | 2.544     |
|                                                            |              |             |               |                 | (2.957)   |
| ln_pop_1900                                                |              |             |               |                 | -2.378    |
|                                                            |              |             |               |                 | (3.363)   |
| _cons                                                      | 65.093***    | 67.387***   | 67.676***     | 69.608***       | 78.157**  |
|                                                            | (2.653)      | (2.273)     | (2.267)       | (2.928)         | (28.935)  |
| N                                                          | 25           | 25          | 25            | 25              | 25        |
| R-squared                                                  | 0.011        | 0.467       | 0.538         | 0.558           | 0.601     |
| RMSE                                                       | 11.863       | 8.907       | 8.488         | 8.501           | 8.518     |

---

## Table 5 — Wine-variant horse race (all 4 spec sets at cascade col 5)

| Wine-variant horse race: all spec sets at cascade col 5 |             |               |               |                |
|---------------------------------------------------------|-------------|---------------|---------------|----------------|
|                                                         | (1)         | (2)           | (3)           | (4)            |
|                                                         | (1) per-cap | (2) vol share | (3) rev share | (4) area share |
|                                                         | b/se        | b/se          | b/se          | b/se           |
| X1                                                      | 148.470     |               |               |                |
|                                                         | (336.878)   |               |               |                |
| X2_share                                                |             | 44.899        |               |                |
|                                                         |             | (36.408)      |               |                |
| X3_share                                                |             |               | 45.869        |                |
|                                                         |             |               | (34.902)      |                |
| X1_share                                                |             |               |               | 32.453         |
|                                                         |             |               |               | (41.758)       |
| cov1                                                    | -20.086**   | -22.491**     | -24.224**     | -19.613**      |
|                                                         | (8.037)     | (8.984)       | (10.314)      | (7.107)        |
| cov2_total_share                                        | -24.437     | -20.546       | -17.860       | -24.119        |
|                                                         | (14.485)    | (39.107)      | (34.097)      | (22.424)       |
| cov3                                                    | -4.435      | -2.890        | -4.039        | -1.853         |
|                                                         | (6.385)     | (6.823)       | (6.971)       | (7.190)        |
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

## Reading guide

- **Cell format**: coefficient (top) over robust standard error in parentheses (bottom). Stars: `*` p<0.10, `**` p<0.05, `***` p<0.01.
- **Wine coefficients sign-flip across cols (1) → (2)** in every cascade — that's the headline finding (Simpson's paradox: conditional vs marginal association reverse direction).
- **Wine coefficients in col (5)** (full controls) are positive in magnitude but mostly insignificant due to wide SEs at N=25 with collinear controls. The substantive sign and magnitude are robust; statistical significance is fragile at this sample size.
- **cov1 (French language)** is the single dominant control — it absorbs most of the variation that was hiding the wine relationship in the bivariate.
- **R²** more than triples between cols (1) and (5) in every cascade (~0.01 → ~0.60).

**Source artifacts**: 20 `.ster` files in `results/intermediate/estimates/`. LaTeX twins in `results/tables/*.tex`. CSV intermediates in `results/tables/_csv/*.csv`.
