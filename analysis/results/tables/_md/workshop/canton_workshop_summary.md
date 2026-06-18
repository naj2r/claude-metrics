# Canton workshop draft — comprehensive summary

**Generated:** 2026-05-21 (workshop draft pipeline; density-swap col 5; N=25 cantons)
**Order:** As tables/figures appear in Paper 1 draft 1.
**Scale convention:** All share-form vars on percent (0–100); log-scale vars on natural log; raw-quantity vars unchanged.

---

## ★ HEADLINE FINDINGS (workshop) ★

**SCALE CONVENTION**: All coefficients reported below are on **pp Y per pp X** scale (where Y = Yes-vote share in percent, X = regressor in percent).  OLS β values are natively on this scale.  Fractional logit AMEs are rescaled (raw AME on fractional Y × 100) for direct comparability with OLS.  See per-table footnotes for confirmation.

**1. Cross-referendum falsification holds (Table 8 FL AME, pp scale):**
Same voters, same ballot day (5 July 1908), three different questions:

- Vote #67 (commerce):     AME = −0.20 pp, p = 0.523 — *placebo passes, null*
- **Vote #68 (absinthe ban): AME = +0.43 pp, p = 0.026 ★ — headline holds at 5%**
- Vote #69 (water power):  AME ≈  0.00 pp, p = 0.983 — *placebo passes, ≈ zero*

Reading: a 1 pp ↑ in canton's national wine-revenue share predicts a 0.43 pp ↑ in Vote #68 yes-share.  Only #68 shows the effect.  Same electorate, same day, two clean nulls.

**2. Wine-type Simpson reveal (Table 9 Panel B):**
WHITE wine cascade shows a Simpson sign-flip between col 1 (bivariate β = −0.256 pp/pp, marginally significant) and col 2 (+French, β = +0.419 pp/pp).  RED wine has no Simpson — bivariate already positive (+0.43 pp/pp).  The Cahannes substitution mechanism appears as a SIGN-FLIP PATTERN under cultural-confound conditioning, not as a magnitude difference at col 5.

**3. Volume re-test of Cahannes (Table 10v + T10v_margins, pp scale):**
Phase 10b correction: replace value-share (Vaud premium prices ~55 CHF/hL skewed value) with VOLUME-share (canton white volume / national white volume).  FL AME of white-wine VOLUME share on Y at cov1=50: +0.91 pp/pp (p = 0.029 ★).  FL AME of white-wine VALUE share at same point: +1.01 pp/pp (p = 0.079 †, only marginal).  Volume measure lifts the main effect from marginal to significant.  Interaction β(white × French) stays null (p > 0.6) in BOTH measures — no cultural conditioning of the slope; the LEVEL effect is robust positive under the cleaner volume measure.

**4. Drop-Ticino robustness (Table 11):**
Removing Ticino (only Italian canton, 100% red wine, high yes-vote for cultural reasons) does NOT collapse the red-wine cascade — it doubles it (col 5 β: +0.39 → +0.83 pp/pp).  Aggregate + white cascades essentially unchanged.  The wine-industry signal is general, not Italian-driven.

**5. Cultural cleavage descriptive (T_desc):**
FR-canton mean Yes #68 = 50.7%; DE-canton mean = 67.6% (level percentages; no pp/pp conversion needed for descriptive means).  French cantons are simultaneously the wine producers AND the lowest yes-voters.  Within-FR variation (VS/VD high white, high yes) deviates UPWARD from FR baseline — the cantonal-level analog of the Simpson reveal.

---

## Table 1 — Descriptive statistics

| Descriptive statistics: 1908 cohort (N=25 cantons) |                          |           |           |           |          |           |        |           |       |     |     |     |        |           |       |     |     |     |          |           |       |     |     |     |           |           |       |     |     |     |  |
|----------------------------------------------------|--------------------------|-----------|-----------|-----------|----------|-----------|--------|-----------|-------|-----|-----|-----|--------|-----------|-------|-----|-----|-----|----------|-----------|-------|-----|-----|-----|-----------|-----------|-------|-----|-----|-----|--|
|                                                    | Overall                  |           |           |           |          |           | French |           |       |     |     |     | German |           |       |     |     |     | Producer |           |       |     |     |     | Non-prod. |           |       |     |     |     |  |
|                                                    | count                    | mean      | sd        | p50       | min      | max       | count  | mean      | sd    | p50 | min | max | count  | mean      | sd    | p50 | min | max | count    | mean      | sd    | p50 | min | max | count     | mean      | sd    | p50 | min | max |  |
| ="Yes-vote                                         | Vote #68 (absinthe ban)" | 25        | 64.34     | 11.68     | 65.13    | 35.26     | 83.28  |           | 50.68 |     |     |     |        |           | 67.76 |     |     |     |          |           | 56.73 |     |     |     |           |           | 67.93 |     |     |     |  |
| ="Yes-vote                                         | Vote #67 (commerce)"     | 25        | 72.08     | 10.88     | 72.31    | 44.67     | 91.30  |           | 68.57 |     |     |     |        |           | 72.96 |     |     |     |          |           | 72.77 |     |     |     |           |           | 71.76 |     |     |     |  |
| ="Yes-vote                                         | Vote #69 (water power)"  | 25        | 81.52     | 12.36     | 83.21    | 47.78     | 98.65  |           | 88.46 |     |     |     |        |           | 79.79 |     |     |     |          |           | 85.69 |     |     |     |           |           | 79.56 |     |     |     |  |
| Petition signatures per 100 eligible               | 25                       | 20.45     | 9.54      | 17.53     | 3.45     | 41.26     |        | 23.89     |       |     |     |     |        | 19.60     |       |     |     |     |          | 19.96     |       |     |     |     |           | 20.69     |       |     |     |     |  |
| ="Turnout                                          | Vote #68"                | 25        | 48.00     | 18.85     | 46.24    | 18.63     | 81.47  |           | 47.92 |     |     |     |        |           | 48.02 |     |     |     |          |           | 40.15 |     |     |     |           |           | 51.70 |     |     |     |  |
| ="Wine area per 1                                  | 000 pop. (ha)"           | 25        | 6.88      | 10.14     | 1.63     | 0.00      | 37.36  |           | 14.06 |     |     |     |        |           | 5.09  |     |     |     |          |           | 8.89  |     |     |     |           |           | 5.94  |     |     |     |  |
| ="Wine volume                                      | national share (%)"      | 25        | 4.00      | 6.87      | 0.97     | 0.00      | 25.63  |           | 10.90 |     |     |     |        |           | 2.28  |     |     |     |          |           | 6.84  |     |     |     |           |           | 2.66  |     |     |     |  |
| ="Wine revenue                                     | national share (%)"      | 25        | 4.00      | 7.52      | 1.21     | 0.00      | 32.11  |           | 12.13 |     |     |     |        |           | 1.97  |     |     |     |          |           | 7.62  |     |     |     |           |           | 2.30  |     |     |     |  |
| French language share (%)                          | 25                       | 17.71     | 32.66     | 0.65      | 0.05     | 90.90     |        | 80.68     |       |     |     |     |        | 1.97      |       |     |     |     |          | 50.87     |       |     |     |     |           | 2.11      |       |     |     |     |  |
| Protestant share (%)                               | 25                       | 43.06     | 34.96     | 48.16     | 1.30     | 90.19     |        | 47.46     |       |     |     |     |        | 41.96     |       |     |     |     |          | 39.21     |       |     |     |     |           | 44.87     |       |     |     |     |  |
| Absinthe industry share (%)                        | 25                       | 4.00      | 12.17     | 0.00      | 0.00     | 58.84     |        | 17.95     |       |     |     |     |        | 0.51      |       |     |     |     |          | 12.50     |       |     |     |     |           | 0.00      |       |     |     |     |  |
| Absinthe-producer indicator                        | 25                       | 0.32      | 0.48      | 0.00      | 0.00     | 1.00      |        | 1.00      |       |     |     |     |        | 0.15      |       |     |     |     |          | 1.00      |       |     |     |     |           | 0.00      |       |     |     |     |  |
| Log population density                             | 25                       | 4.62      | 1.10      | 4.63      | 2.69     | 8.02      |        | 4.71      |       |     |     |     |        | 4.60      |       |     |     |     |          | 5.07      |       |     |     |     |           | 4.41      |       |     |     |     |  |
| Population (1900)                                  | 25                       | 132617.72 | 135917.02 | 112227.00 | 13070.00 | 589433.00 |        | 156531.20 |       |     |     |     |        | 126639.35 |       |     |     |     |          | 121920.12 |       |     |     |     |           | 137651.88 |       |     |     |     |  |


### Canton industrial composition (sub-table)

**Canton industrial composition, 1907**

| Category                       | N  | Cantons                                                  |
|--------------------------------|---:|----------------------------------------------------------|
| Wine AND absinthe | 7 | BS FR GE NE SZ VD VS |
| Wine only | 13 | AG AR BE BL GL GR LU SG SH SO TG TI ZH |
| Absinthe only | 1 | ZG |
| Neither | 4 | AI NW OW UR |
| **Total** | **25** |  |

---

## Table 2 — Vote regression cascade

### Panel A: Wine revenue share (X3) — OLS

| Vote cascade (Panel A: Wine revenue share) — OLS |                      |             |               |                 |                     |       |
|--------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                                                  | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                                                  | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                                                  | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="Wine revenue                                   | national share (\%)" | -0.196      | 0.568**       | 0.415           | 0.547*              | 0.469 |
|                                                  | (0.219)              | (0.251)     | (0.271)       | (0.277)         | (0.309)             |       |
| French language share (\%)                       |                      | -0.307***   | -0.218**      | -0.248**        | -0.239**            |       |
|                                                  |                      | (0.079)     | (0.100)       | (0.102)         | (0.104)             |       |
| Absinthe industry share (\%)                     |                      |             | -0.294        | -0.197          | -0.185              |       |
|                                                  |                      |             | (0.336)       | (0.258)         | (0.301)             |       |
| Protestant share (\%)                            |                      |             |               | -0.069          | -0.037              |       |
|                                                  |                      |             |               | (0.050)         | (0.068)             |       |
| Log population density                           |                      |             |               |                 | -2.086              |       |
|                                                  |                      |             |               |                 | (2.709)             |       |
| Constant                                         | 65.129***            | 67.508***   | 67.714***     | 70.317***       | 78.670***           |       |
|                                                  | (2.575)              | (2.096)     | (2.132)       | (2.676)         | (11.070)            |       |
| N                                                | 25                   | 25          | 25            | 25              | 25                  |       |
| R-squared                                        | 0.016                | 0.510       | 0.560         | 0.595           | 0.623               |       |
| RMSE                                             | 11.831               | 8.535       | 8.276         | 8.137           | 8.054               |       |


### Panel A: Wine revenue share (X3) — Fractional logit AME

| Vote cascade (Panel A: Wine revenue share) — FL |                      |             |               |                 |                     |         |
|-------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|---------|
|                                                 | (1)                  | (2)         | (3)           | (4)             | (5)                 |         |
|                                                 | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |         |
|                                                 | b/se                 | b/se        | b/se          | b/se            | b/se                |         |
| ="Wine revenue                                  | national share (\%)" | -0.192      | 0.531***      | 0.391**         | 0.514***            | 0.434** |
|                                                 | (0.154)              | (0.178)     | (0.154)       | (0.164)         | (0.195)             |         |
| French language share (\%)                      |                      |             |               |                 |                     |         |
|                                                 |                      |             |               |                 |                     |         |
| Absinthe industry share (\%)                    |                      |             |               |                 |                     |         |
|                                                 |                      |             |               |                 |                     |         |
| Protestant share (\%)                           |                      |             |               |                 |                     |         |
|                                                 |                      |             |               |                 |                     |         |
| Log population density                          |                      |             |               |                 |                     |         |
|                                                 |                      |             |               |                 |                     |         |
| Constant                                        |                      |             |               |                 |                     |         |
|                                                 |                      |             |               |                 |                     |         |
| N                                               | 25                   | 25          | 25            | 25              | 25                  |         |


### Panel B: Wine volume share (X2) — OLS

| Vote cascade (Panel B: Wine volume share) — OLS |                      |             |               |                 |                     |       |
|-------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                                                 | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                                                 | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                                                 | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="Wine volume                                   | national share (\%)" | -0.165      | 0.592**       | 0.439*          | 0.530*              | 0.454 |
|                                                 | (0.273)              | (0.235)     | (0.235)       | (0.259)         | (0.297)             |       |
| French language share (\%)                      |                      | -0.298***   | -0.211**      | -0.230**        | -0.224**            |       |
|                                                 |                      | (0.074)     | (0.086)       | (0.083)         | (0.088)             |       |
| Absinthe industry share (\%)                    |                      |             | -0.301        | -0.225          | -0.207              |       |
|                                                 |                      |             | (0.284)       | (0.206)         | (0.364)             |       |
| Protestant share (\%)                           |                      |             |               | -0.060          | -0.028              |       |
|                                                 |                      |             |               | (0.050)         | (0.066)             |       |
| Log population density                          |                      |             |               |                 | -2.161              |       |
|                                                 |                      |             |               |                 | (2.760)             |       |
| Constant                                        | 65.004***            | 67.259***   | 67.519***     | 69.773***       | 78.502***           |       |
|                                                 | (2.640)              | (2.171)     | (2.199)       | (2.766)         | (11.408)            |       |
| N                                               | 25                   | 25          | 25            | 25              | 25                  |       |
| R-squared                                       | 0.009                | 0.507       | 0.561         | 0.588           | 0.618               |       |
| RMSE                                            | 11.870               | 8.560       | 8.272         | 8.207           | 8.105               |       |


### Panel B: Wine volume share (X2) — Fractional logit AME

| Vote cascade (Panel B: Wine volume share) — FL |                      |             |               |                 |                     |         |
|------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|---------|
|                                                | (1)                  | (2)         | (3)           | (4)             | (5)                 |         |
|                                                | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |         |
|                                                | b/se                 | b/se        | b/se          | b/se            | b/se                |         |
| ="Wine volume                                  | national share (\%)" | -0.163      | 0.567***      | 0.422***        | 0.511***            | 0.428** |
|                                                | (0.212)              | (0.184)     | (0.159)       | (0.175)         | (0.205)             |         |
| French language share (\%)                     |                      |             |               |                 |                     |         |
|                                                |                      |             |               |                 |                     |         |
| Absinthe industry share (\%)                   |                      |             |               |                 |                     |         |
|                                                |                      |             |               |                 |                     |         |
| Protestant share (\%)                          |                      |             |               |                 |                     |         |
|                                                |                      |             |               |                 |                     |         |
| Log population density                         |                      |             |               |                 |                     |         |
|                                                |                      |             |               |                 |                     |         |
| Constant                                       |                      |             |               |                 |                     |         |
|                                                |                      |             |               |                 |                     |         |
| N                                              | 25                   | 25          | 25            | 25              | 25                  |         |

---

## Table 3 — Vote horse race at col 5 (X1, X2_share, X3_share)

### OLS HC3

| Vote horse race at col 5 — OLS |                      |                  |                   |       |
|--------------------------------|----------------------|------------------|-------------------|-------|
|                                | (1)                  | (2)              | (3)               |       |
|                                | (1) Per-cap          | (2) Volume share | (3) Revenue share |       |
|                                | b/se                 | b/se             | b/se              |       |
| ="Wine area per 1              | 000 pop. (ha)"       | 0.168            |                   |       |
|                                | (0.261)              |                  |                   |       |
| ="Wine volume                  | national share (\%)" |                  | 0.454             |       |
|                                |                      | (0.297)          |                   |       |
| ="Wine revenue                 | national share (\%)" |                  |                   | 0.469 |
|                                |                      |                  | (0.309)           |       |
| French language share (\%)     | -0.181**             | -0.224**         | -0.239**          |       |
|                                | (0.070)              | (0.088)          | (0.104)           |       |
| Absinthe industry share (\%)   | -0.272               | -0.207           | -0.185            |       |
|                                | (0.227)              | (0.364)          | (0.301)           |       |
| Protestant share (\%)          | -0.009               | -0.028           | -0.037            |       |
|                                | (0.068)              | (0.066)          | (0.068)           |       |
| Log population density         | -2.480               | -2.161           | -2.086            |       |
|                                | (2.731)              | (2.760)          | (2.709)           |       |
| Constant                       | 79.297***            | 78.502***        | 78.670***         |       |
|                                | (11.229)             | (11.408)         | (11.070)          |       |
| N                              | 25                   | 25               | 25                |       |
| R-squared                      | 0.594                | 0.618            | 0.623             |       |
| RMSE                           | 8.362                | 8.105            | 8.054             |       |


### Fractional logit AME

| Vote horse race at col 5 — FL |                      |                  |                   |         |
|-------------------------------|----------------------|------------------|-------------------|---------|
|                               | (1)                  | (2)              | (3)               |         |
|                               | (1) Per-cap          | (2) Volume share | (3) Revenue share |         |
|                               | b/se                 | b/se             | b/se              |         |
| ="Wine area per 1             | 000 pop. (ha)"       | 0.170            |                   |         |
|                               | (0.145)              |                  |                   |         |
| ="Wine volume                 | national share (\%)" |                  | 0.428**           |         |
|                               |                      | (0.205)          |                   |         |
| ="Wine revenue                | national share (\%)" |                  |                   | 0.434** |
|                               |                      |                  | (0.195)           |         |
| French language share (\%)    |                      |                  |                   |         |
|                               |                      |                  |                   |         |
| Absinthe industry share (\%)  |                      |                  |                   |         |
|                               |                      |                  |                   |         |
| Protestant share (\%)         |                      |                  |                   |         |
|                               |                      |                  |                   |         |
| Log population density        |                      |                  |                   |         |
|                               |                      |                  |                   |         |
| Constant                      |                      |                  |                   |         |
|                               |                      |                  |                   |         |
| N                             | 25                   | 25               | 25                |         |

---

## Table 4 — Petition regression cascade (Y = pet_per_eligible)

### Panel A: Wine revenue share (X3) — OLS

| Petition cascade (Panel A: Wine revenue share) — Y=pet_per_eligible |                      |             |               |                 |                     |        |
|---------------------------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|--------|
|                                                                     | (1)                  | (2)         | (3)           | (4)             | (5)                 |        |
|                                                                     | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |        |
|                                                                     | b/se                 | b/se        | b/se          | b/se            | b/se                |        |
| ="Wine revenue                                                      | national share (\%)" | 0.110       | -0.051        | 0.023           | -0.311              | -0.366 |
|                                                                     | (0.436)              | (0.451)     | (0.509)       | (0.471)         | (0.456)             |        |
| French language share (\%)                                          |                      | 0.065       | 0.021         | 0.098           | 0.104               |        |
|                                                                     |                      | (0.075)     | (0.139)       | (0.161)         | (0.148)             |        |
| Absinthe industry share (\%)                                        |                      |             | 0.142         | -0.102          | -0.092              |        |
|                                                                     |                      |             | (0.416)       | (0.722)         | (0.649)             |        |
| Protestant share (\%)                                               |                      |             |               | 0.175**         | 0.198**             |        |
|                                                                     |                      |             |               | (0.064)         | (0.079)             |        |
| Log population density                                              |                      |             |               |                 | -1.494              |        |
|                                                                     |                      |             |               |                 | (2.496)             |        |
| Constant                                                            | 20.016***            | 19.515***   | 19.415***     | 12.821***       | 18.802*             |        |
|                                                                     | (2.272)              | (2.393)     | (2.447)       | (2.607)         | (10.600)            |        |
| N                                                                   | 25                   | 25          | 25            | 25              | 25                  |        |
| R-squared                                                           | 0.007                | 0.040       | 0.058         | 0.394           | 0.416               |        |
| RMSE                                                                | 9.705                | 9.758       | 9.896         | 8.132           | 8.194               |        |


### Panel B: Wine volume share (X2) — OLS

| Petition cascade (Panel B: Wine volume share) — Y=pet_per_eligible |                      |             |               |                 |                     |        |
|--------------------------------------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|--------|
|                                                                    | (1)                  | (2)         | (3)           | (4)             | (5)                 |        |
|                                                                    | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |        |
|                                                                    | b/se                 | b/se        | b/se          | b/se            | b/se                |        |
| ="Wine volume                                                      | national share (\%)" | -0.002      | -0.209        | -0.154          | -0.419              | -0.474 |
|                                                                    | (0.440)              | (0.431)     | (0.463)       | (0.406)         | (0.379)             |        |
| French language share (\%)                                         |                      | 0.081       | 0.050         | 0.107           | 0.111               |        |
|                                                                    |                      | (0.077)     | (0.124)       | (0.150)         | (0.138)             |        |
| Absinthe industry share (\%)                                       |                      |             | 0.108         | -0.113          | -0.100              |        |
|                                                                    |                      |             | (0.467)       | (0.811)         | (0.756)             |        |
| Protestant share (\%)                                              |                      |             |               | 0.175***        | 0.198**             |        |
|                                                                    |                      |             |               | (0.061)         | (0.075)             |        |
| Log population density                                             |                      |             |               |                 | -1.567              |        |
|                                                                    |                      |             |               |                 | (2.594)             |        |
| Constant                                                           | 20.463***            | 19.849***   | 19.756***     | 13.164***       | 19.497*             |        |
|                                                                    | (2.243)              | (2.378)     | (2.420)       | (2.438)         | (10.983)            |        |
| N                                                                  | 25                   | 25          | 25            | 25              | 25                  |        |
| R-squared                                                          | 0.000                | 0.055       | 0.066         | 0.417           | 0.441               |        |
| RMSE                                                               | 9.742                | 9.681       | 9.855         | 7.975           | 8.013               |        |

---

## Table 5 — R4 mechanism interaction (French × Absinthe-producer)

### Panel A: Wine volume share (X2)

| R4 mechanism (Panel A: Wine volume share) |                      |                   |       |
|-------------------------------------------|----------------------|-------------------|-------|
|                                           | (1)                  | (2)               |       |
|                                           | (1) col 5            | (2) + interaction |       |
|                                           | b/se                 | b/se              |       |
| ="Wine volume                             | national share (\%)" | 0.454             | 0.466 |
|                                           | (0.297)              | (0.279)           |       |
| French language share (\%)                | -0.224**             | -0.788***         |       |
|                                           | (0.088)              | (0.253)           |       |
| Absinthe-producer indicator               |                      | 3.359             |       |
|                                           |                      | (7.046)           |       |
| French $\times$ Absinthe-producer         |                      | 0.529*            |       |
|                                           |                      | (0.261)           |       |
| Absinthe industry share (\%)              | -0.207               | -0.239            |       |
|                                           | (0.364)              | (0.255)           |       |
| Protestant share (\%)                     | -0.028               | 0.001             |       |
|                                           | (0.066)              | (0.071)           |       |
| Log population density                    | -2.161               | -3.022            |       |
|                                           | (2.760)              | (2.620)           |       |
| Constant                                  | 78.502***            | 81.612***         |       |
|                                           | (11.408)             | (10.637)          |       |
| N                                         | 25                   | 25                |       |
| R-squared                                 | 0.618                | 0.660             |       |
| RMSE                                      | 8.105                | 8.084             |       |


### Panel B: Wine revenue share (X3)

| R4 mechanism (Panel B: Wine revenue share) |                      |                   |       |
|--------------------------------------------|----------------------|-------------------|-------|
|                                            | (1)                  | (2)               |       |
|                                            | (1) col 5            | (2) + interaction |       |
|                                            | b/se                 | b/se              |       |
| ="Wine revenue                             | national share (\%)" | 0.469             | 0.421 |
|                                            | (0.309)              | (0.310)           |       |
| French language share (\%)                 | -0.239**             | -0.707*           |       |
|                                            | (0.104)              | (0.394)           |       |
| Absinthe-producer indicator                |                      | 3.007             |       |
|                                            |                      | (7.160)           |       |
| French $\times$ Absinthe-producer          |                      | 0.447             |       |
|                                            |                      | (0.404)           |       |
| Absinthe industry share (\%)               | -0.185               | -0.227            |       |
|                                            | (0.301)              | (0.210)           |       |
| Protestant share (\%)                      | -0.037               | -0.007            |       |
|                                            | (0.068)              | (0.079)           |       |
| Log population density                     | -2.086               | -2.912            |       |
|                                            | (2.709)              | (2.694)           |       |
| Constant                                   | 78.670***            | 81.616***         |       |
|                                            | (11.070)             | (10.697)          |       |
| N                                          | 25                   | 25                |       |
| R-squared                                  | 0.623                | 0.654             |       |
| RMSE                                       | 8.054                | 8.165             |       |


### Conditional means (vs. German non-producer baseline)

**Table 5 conditional means (vs.\ German non-producer baseline; pp Δ in Yes-vote)**

| Subgroup                                          | Panel A (X2_share) | Panel B (X3_share) |
|---------------------------------------------------|-------------------:|-------------------:|
| French non-producer (cov1 alone)                  |  -0.788 |  -0.707 |
| German producer (abs_producer alone)              |   3.359 |   3.007 |
| French producer (cov1 + abs_producer + interaction) |   3.100 |   2.747 |

---

## Table 6 — French-German turnout gap collapse

**Table 6 — French-German turnout gap collapse on vote #68 (5 July 1908)**

|                                                              | French (N=5) | German (N=20) | Gap (Fr-Ge)  |
|--------------------------------------------------------------|-------------:|--------------:|-------------:|
| Baseline turnout (median across 14 placebo votes 1907-1910)  | 44.40        | 56.62         | **-12.22**   |
| Vote #68 turnout (5 July 1908, absinthe ban)                 | 47.92        | 48.02         | **-0.11**    |
| Change (gap collapse, row 2 minus row 1)                     | **+3.52**    | **-8.60**     | **+12.12**   |

---

## Figure 1 — Petition rate vs Protestant share

![F1](C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Figures/F1_petition_protestant.png)

Monochrome scatter of canton-level petition signatures per 100 eligible voters
against Protestant share of the Christian population.  Markers by language group
(German = open circle; French = filled square; Italian = filled triangle).  Solid
line = OLS fit.  Source: cohort_1908_workshop.dta.

---

## Figure 2 — Vote and petition rates by canton (grouped bars)

![F2](C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Figures/F2_canton_bars.png)

Side-by-side bars per canton: gray = Vote #68 yes-share (%); black = petition
signatures per 100 eligible voters (%).  Cantons grouped by language cluster
(German | French | Italian).  Source: cohort_1908_workshop.dta.

---

## Table 7 (Appendix) — Consolidated robustness

Two appendix files in `Workshop_draft/`:
- **`T7_appendix_canton_robustness_r1_r6.tex`** — direct copy of non-workshop R1-R6 (OLS only; scale-uniform, no rescale needed).  Uses non-workshop col-5 controls (cov_land + ln_pop_1900).
- **`T7_appendix_fraclogit_vs_ols.tex scale-consistency.  Uses workshop col-5 controls (ln_density) AND FL AMEs rescaled to pp Y per pp X for direct comparability with OLS HC3 columns.

The non-workshop summary `_md/robust/canton_robustness_summary.md` (existing baseline) uses cov_land + ln_pop_1900 controls AND has mixed-scale FL AMEs (fractional Y) — DO NOT cite from there for workshop or EEH purposes.  Use the rebuilt T7_appendix_fraclogit_vs_ols.tex instead.

---

## Table 8 — Cross-referendum #67 / #68 / #69 (falsification)

**Headline result — read FL AME panel below.**  OLS panel is for reference (small-sample HC3 SEs at N=25 are conservative; FL is the appropriate model for the bounded outcome and tightens the absinthe-ban result to p=0.026 at the 5% threshold).

### Fractional logit AME (HEADLINE)

| ="Cross-referendum: votes #67 | #68                     | #69 — Fractional logit AME" |                            |       |
|-------------------------------|-------------------------|-----------------------------|----------------------------|-------|
|                               | (1)                     | (2)                         | (3)                        |       |
|                               | (1) Vote #67 (commerce) | (2) Vote #68 (absinthe ban) | (3) Vote #69 (water power) |       |
|                               | b/se                    | b/se                        | b/se                       |       |
| ="Wine revenue                | national share (\%)"    | -0.196                      | 0.434**                    | 0.005 |
|                               | (0.308)                 | (0.195)                     | (0.210)                    |       |
| French language share (\%)    |                         |                             |                            |       |
|                               |                         |                             |                            |       |
| Absinthe industry share (\%)  |                         |                             |                            |       |
|                               |                         |                             |                            |       |
| Protestant share (\%)         |                         |                             |                            |       |
|                               |                         |                             |                            |       |
| Log population density        |                         |                             |                            |       |
|                               |                         |                             |                            |       |
| Constant                      |                         |                             |                            |       |
|                               |                         |                             |                            |       |
| N                             | 25                      | 25                          | 25                         |       |


### OLS HC3 (for reference)

| ="Cross-referendum: votes #67 | #68                     | #69 — OLS HC3"              |                            |        |
|-------------------------------|-------------------------|-----------------------------|----------------------------|--------|
|                               | (1)                     | (2)                         | (3)                        |        |
|                               | (1) Vote #67 (commerce) | (2) Vote #68 (absinthe ban) | (3) Vote #69 (water power) |        |
|                               | b/se                    | b/se                        | b/se                       |        |
| ="Wine revenue                | national share (\%)"    | -0.218                      | 0.469                      | -0.009 |
|                               | (0.547)                 | (0.309)                     | (0.291)                    |        |
| French language share (\%)    | -0.022                  | -0.239**                    | 0.127**                    |        |
|                               | (0.241)                 | (0.104)                     | (0.060)                    |        |
| Absinthe industry share (\%)  | -0.009                  | -0.185                      | -0.157                     |        |
|                               | (1.448)                 | (0.301)                     | (0.255)                    |        |
| Protestant share (\%)         | -0.012                  | -0.037                      | 0.118                      |        |
|                               | (0.082)                 | (0.068)                     | (0.076)                    |        |
| Log population density        | 4.135                   | -2.086                      | 4.964***                   |        |
|                               | (3.193)                 | (2.709)                     | (1.355)                    |        |
| Constant                      | 54.774***               | 78.670***                   | 51.939***                  |        |
|                               | (13.296)                | (11.070)                    | (6.011)                    |        |
| N                             | 25                      | 25                          | 25                         |        |
| R-squared                     | 0.204                   | 0.623                       | 0.501                      |        |
| RMSE                          | 10.915                  | 8.054                       | 9.811                      |        |

---

## Cultural-cleavage descriptive table (T_desc) — wine cantons only (N=20)

Sort: language group (FR → IT → DE), then Yes #68 descending within group.
Carries the substantive cultural-cleavage story without leaning on interactions at N=25.

# Table: Wine cantons — descriptive cultural-cleavage view (1908 cohort, N=20 wine cantons)

Sort: language group (FR -> IT -> DE), then Yes #68 descending within group.
Red/White % = canton share of national red/white wine value (Switzerland totals from 1907 HSSO Canton1907_wine-data.xlsx).
Wine % = canton share of national total wine value (denominator 29,782,933 CHF).

| Canton | Lang | Abs prod | Red % | White % | Wine % | Yes #67 | Yes #68 | Yes #69 |
|--------|------|---------:|------:|--------:|-------:|--------:|--------:|--------:|
| VS | FR | Y |   2.7 |  25.8 |  19.5 |  62.7 |  61.8 |  79.9 |
| FR | FR | Y |   0.2 |   1.0 |   0.8 |  61.6 |  59.5 |  83.8 |
| VD | FR | Y |   6.0 |  41.9 |  32.1 |  59.4 |  56.1 |  90.1 |
| GE | FR | Y |   1.6 |   3.3 |   2.8 |  91.3 |  40.8 |  98.7 |
| NE | FR | Y |   3.2 |   6.4 |   5.4 |  67.9 |  35.3 |  89.9 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TI | IT | N |  27.0 |   0.0 |   6.2 |  74.0 |  68.4 |  73.6 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GR | DE | N |   5.3 |   0.0 |   1.2 |  72.3 |  83.3 |  72.5 |
| SH | DE | N |  12.8 |   3.1 |   5.3 |  88.1 |  77.3 |  92.4 |
| ZH | DE | N |  24.3 |   9.8 |  14.5 |  78.9 |  75.9 |  93.6 |
| LU | DE | N |   0.1 |   0.0 |   0.0 |  88.0 |  74.5 |  92.8 |
| SG | DE | N |   8.8 |   0.5 |   2.4 |  72.4 |  74.4 |  75.4 |
| SZ | DE | Y |   0.2 |   0.1 |   0.1 |  71.4 |  73.4 |  59.6 |
| GL | DE | N |   0.0 |   0.0 |   0.0 |  80.3 |  72.5 |  89.2 |
| TG | DE | N |   4.0 |   1.7 |   2.3 |  66.6 |  65.5 |  81.7 |
| BS | DE | Y |   0.0 |   0.2 |   0.2 |  88.6 |  65.1 |  97.7 |
| AG | DE | N |   2.9 |   1.8 |   3.7 |  59.9 |  63.0 |  78.8 |
| AR | DE | N |   0.0 |   0.0 |   0.0 |  67.4 |  57.6 |  82.9 |
| BE | DE | N |   0.1 |   2.9 |   2.2 |  71.4 |  55.3 |  83.2 |
| BL | DE | N |   0.7 |   1.4 |   1.2 |  64.4 |  55.2 |  85.4 |
| SO | DE | N |   0.0 |   0.1 |   0.1 |  79.4 |  52.7 |  90.7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **FR mean (N=5)** |  |  | **  2.8** | ** 15.7** | ** 12.1** | ** 68.6** | ** 50.7** | ** 88.5** |
| **IT mean (N=1)** |  |  | ** 27.0** | **  0.0** | **  6.2** | ** 74.0** | ** 68.4** | ** 73.6** |
| **DE mean (N=14)** |  |  | **  4.2** | **  1.5** | **  2.4** | ** 74.9** | ** 67.6** | ** 84.0** |

---

## Table 9 — Wine-type cascade decomposition (3 panels: Aggregate / White / Red)

All three panels: OLS HC3, N=25, Y = Yes-vote share Vote #68 (absinthe ban).
**Key pattern**: WHITE shows Simpson sign-flip col 1 → col 2 (−0.256* → +0.419*); RED does not (already positive bivariate).

### Panel A: Aggregate wine cascade

| T9 Panel A: Aggregate wine cascade |                      |             |               |                 |                     |       |
|------------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                                    | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                                    | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                                    | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="Wine revenue                     | national share (\%)" | -0.196      | 0.568**       | 0.415           | 0.547*              | 0.469 |
|                                    | (0.219)              | (0.251)     | (0.271)       | (0.277)         | (0.309)             |       |
| French language share (\%)         |                      | -0.307***   | -0.218**      | -0.248**        | -0.239**            |       |
|                                    |                      | (0.079)     | (0.100)       | (0.102)         | (0.104)             |       |
| Absinthe industry share (\%)       |                      |             | -0.294        | -0.197          | -0.185              |       |
|                                    |                      |             | (0.336)       | (0.258)         | (0.301)             |       |
| Protestant share (\%)              |                      |             |               | -0.069          | -0.037              |       |
|                                    |                      |             |               | (0.050)         | (0.068)             |       |
| Log population density             |                      |             |               |                 | -2.086              |       |
|                                    |                      |             |               |                 | (2.709)             |       |
| Constant                           | 65.129***            | 67.508***   | 67.714***     | 70.317***       | 78.670***           |       |
|                                    | (2.575)              | (2.096)     | (2.132)       | (2.676)         | (11.070)            |       |
| N                                  | 25                   | 25          | 25            | 25              | 25                  |       |
| R-squared                          | 0.016                | 0.510       | 0.560         | 0.595           | 0.623               |       |
| RMSE                               | 11.831               | 8.535       | 8.276         | 8.137           | 8.054               |       |


### Panel B: WHITE wine cascade  (Simpson sign-flip)

| T9 Panel B: WHITE wine cascade |                      |             |               |                 |                     |       |
|--------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                                | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                                | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                                | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="WHITE wine                   | national share (\%)" | -0.256*     | 0.419*        | 0.272           | 0.363               | 0.285 |
|                                | (0.125)              | (0.223)     | (0.227)       | (0.233)         | (0.249)             |       |
| French language share (\%)     |                      | -0.310***   | -0.211*       | -0.239**        | -0.225**            |       |
|                                |                      | (0.088)     | (0.111)       | (0.113)         | (0.107)             |       |
| Absinthe industry share (\%)   |                      |             | -0.306        | -0.220          | -0.212              |       |
|                                |                      |             | (0.366)       | (0.303)         | (0.255)             |       |
| Protestant share (\%)          |                      |             |               | -0.061          | -0.027              |       |
|                                |                      |             |               | (0.052)         | (0.071)             |       |
| Log population density         |                      |             |               |                 | -2.189              |       |
|                                |                      |             |               |                 | (2.714)             |       |
| Constant                       | 65.369***            | 68.158***   | 68.212***     | 70.622***       | 79.296***           |       |
|                                | (2.455)              | (2.044)     | (2.059)       | (2.726)         | (10.886)            |       |
| N                              | 25                   | 25          | 25            | 25              | 25                  |       |
| R-squared                      | 0.044                | 0.490       | 0.543         | 0.570           | 0.601               |       |
| RMSE                           | 11.661               | 8.706       | 8.438         | 8.384           | 8.292               |       |


### Panel C: RED wine cascade  (no Simpson; stable positive)

| T9 Panel C: RED wine cascade |                      |             |               |                 |                     |       |
|------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                              | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                              | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                              | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="RED wine                   | national share (\%)" | 0.433       | 0.388         | 0.372           | 0.406               | 0.393 |
|                              | (0.254)              | (0.244)     | (0.260)       | (0.454)         | (0.458)             |       |
| French language share (\%)   |                      | -0.228***   | -0.140**      | -0.144**        | -0.152**            |       |
|                              |                      | (0.070)     | (0.057)       | (0.061)         | (0.055)             |       |
| Absinthe industry share (\%) |                      |             | -0.376        | -0.325          | -0.284              |       |
|                              |                      |             | (0.325)       | (0.275)         | (0.313)             |       |
| Protestant share (\%)        |                      |             |               | -0.051          | -0.017              |       |
|                              |                      |             |               | (0.066)         | (0.074)             |       |
| Log population density       |                      |             |               |                 | -2.541              |       |
|                              |                      |             |               |                 | (3.013)             |       |
| Constant                     | 62.612***            | 66.831***   | 66.838***     | 68.768***       | 79.046***           |       |
|                              | (2.635)              | (2.308)     | (2.332)       | (3.120)         | (12.053)            |       |
| N                            | 25                   | 25          | 25            | 25              | 25                  |       |
| R-squared                    | 0.073                | 0.479       | 0.571         | 0.592           | 0.635               |       |
| RMSE                         | 11.484               | 8.805       | 8.173         | 8.170           | 7.923               |       |

---

## Table 10v — Cahannes substitution channel: VOLUME-share re-test (Phase 10b)

**Motivation.**  X3_white_share uses CHF revenue.  Price/yield heterogeneity (premium Vaud whites at ~55 CHF/hL vs. bulk Ticino reds at ~23 CHF/hL) loads onto value-share.
If Cahannes's substitution channel runs through VOLUME (what consumers drink, what growers plant)—not revenue—then value-share is mis-specified.
Volume-share = canton's white VOLUME / national white VOLUME (parallel to value-share form).

### Side-by-side: D1/D2 (value) vs D1v/D2v (volume)

| T10v: White x French value vs volume re-test |                               |                      |                   |                     |       |
|----------------------------------------------|-------------------------------|----------------------|-------------------|---------------------|-------|
|                                              | (1)                           | (2)                  | (3)               | (4)                 |       |
|                                              | D1 value abs dummy            | D1v volume abs dummy | D2 value abs cont | D2v volume abs cont |       |
|                                              | b/se                          | b/se                 | b/se              | b/se                |       |
| ="White wine                                 | national share (\%) — VALUE"  | 0.969                |                   | 0.772               |       |
|                                              | (1.280)                       |                      | (1.297)           |                     |       |
| ="White wine                                 | national share (\%) — VOLUME" |                      | 0.850             |                     | 0.701 |
|                                              |                               | (0.886)              |                   | (0.931)             |       |
| French language share (\%)                   | -0.309**                      | -0.305**             | -0.218*           | -0.211*             |       |
|                                              | (0.114)                       | (0.116)              | (0.117)           | (0.117)             |       |
| White (val) $\times$ French                  | -0.007                        |                      | -0.006            |                     |       |
|                                              | (0.021)                       |                      | (0.018)           |                     |       |
| White (vol) $\times$ French                  |                               | -0.006               |                   | -0.005              |       |
|                                              |                               | (0.016)              |                   | (0.014)             |       |
| Absinthe-producer indicator                  | 3.272                         | 3.486                |                   |                     |       |
|                                              | (7.554)                       | (7.631)              |                   |                     |       |
| Absinthe industry share (\%)                 |                               |                      | -0.197            | -0.205              |       |
|                                              |                               |                      | (0.458)           | (0.499)             |       |
| Protestant share (\%)                        | -0.034                        | -0.034               | -0.033            | -0.033              |       |
|                                              | (0.087)                       | (0.087)              | (0.079)           | (0.079)             |       |
| Log population density                       | -2.921                        | -3.025               | -2.246            | -2.287              |       |
|                                              | (3.260)                       | (3.366)              | (3.100)           | (3.299)             |       |
| Constant                                     | 81.796***                     | 82.077***            | 79.263***         | 79.327***           |       |
|                                              | (12.628)                      | (13.049)             | (12.520)          | (13.260)            |       |
| N                                            | 25                            | 25                   | 25                | 25                  |       |
| R-squared                                    | 0.597                         | 0.601                | 0.610             | 0.616               |       |
| RMSE                                         | 8.560                         | 8.513                | 8.421             | 8.359               |       |


### FL AME marginal effects (the headline panel)

## T10v Marginal Effects: white wine on Yes-vote, by cov1 value

FL AME of white wine share at cov1 = {0, 25, 50, 75, 100} %.
**All AMEs rescaled to pp Y per pp X scale (raw FL AME × 100), comparable to OLS β.**  Robust SEs in parentheses.  Sig: † p<0.10, * p<0.05, ** p<0.01.

| cov1 | D1 value (abs dummy) | D1v volume (abs dummy) | D2 value (abs cont) | D2v volume (abs cont) |
|-----:|---------------------:|------------------------:|--------------------:|----------------------:|
| 0\\% | 0.8658† (0.4975) | 0.7826* (0.3661) | 0.7167 (0.5205) | 0.6696† (0.3795) |
| 25\\% | 0.9580† (0.5471) | 0.8647* (0.3999) | 0.7689 (0.5572) | 0.7166† (0.4028) |
| 50\\% | 1.0102† (0.5746) | 0.9117* (0.4188) | 0.8053 (0.5825) | 0.7499† (0.4193) |
| 75\\% | 1.0128† (0.5749) | 0.9153* (0.4195) | 0.8227 (0.5937) | 0.7666† (0.4276) |
| 100\\% | 0.9656† (0.5502) | 0.8748* (0.4042) | 0.8192 (0.5899) | 0.7652† (0.4271) |


**Result.**  Volume measure lifts white-wine main effect from p≈0.08 (value, marginal) to **p≈0.03 (volume, significant at 5%)** at all moderator values.
Interaction β(white × French) stays NULL (p>0.6) — no cultural conditioning of the slope.  The Cahannes substitution mechanism is supported by the MAIN EFFECT under the correct (volume) measure, not by cultural conditioning.

---

## Table 11 — Drop-Ticino cascade robustness (Phase 10 Spec F)

Ticino is the only Italian-speaking canton in the cohort and the dominant red-wine producer (100% red, 27% of national red value).
TI voted YES at 68.4% for Catholic-Italian cultural reasons unconnected to wine-industry rent-seeking.
Re-running the wine-type cascade with TI excluded tests the substantive interpretation of the red-wine result.

**Result.**  Aggregate and WHITE cascades essentially unchanged.  RED cascade STRENGTHENS (col 5 β: +0.39 → +0.83).  The wine-industry signal is general and is NOT Ticino-driven; if anything TI was suppressing the red-wine effect via its cultural-channel confound.

### Panel A: Aggregate wine, drop TI (N=24)

| ="T11 Panel A: Aggregate wine | drop Ticino"         |             |               |                 |                     |       |
|-------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                               | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                               | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                               | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="Wine revenue                | national share (\%)" | -0.204      | 0.565**       | 0.414           | 0.565*              | 0.486 |
|                               | (0.209)              | (0.250)     | (0.271)       | (0.283)         | (0.316)             |       |
| French language share (\%)    |                      | -0.306***   | -0.217**      | -0.252**        | -0.243**            |       |
|                               |                      | (0.080)     | (0.100)       | (0.103)         | (0.105)             |       |
| Absinthe industry share (\%)  |                      |             | -0.294        | -0.192          | -0.179              |       |
|                               |                      |             | (0.335)       | (0.263)         | (0.294)             |       |
| Protestant share (\%)         |                      |             |               | -0.074          | -0.042              |       |
|                               |                      |             |               | (0.053)         | (0.071)             |       |
| Log population density        |                      |             |               |                 | -2.077              |       |
|                               |                      |             |               |                 | (2.705)             |       |
| Constant                      | 64.973***            | 67.474***   | 67.691***     | 70.614***       | 78.906***           |       |
|                               | (2.644)              | (2.159)     | (2.200)       | (2.986)         | (11.097)            |       |
| N                             | 24                   | 24          | 24            | 24              | 24                  |       |
| R-squared                     | 0.017                | 0.508       | 0.558         | 0.595           | 0.623               |       |
| RMSE                          | 12.057               | 8.734       | 8.480         | 8.327           | 8.255               |       |


### Panel B: WHITE wine, drop TI (N=24)

| ="T11 Panel B: WHITE wine    | drop Ticino"         |             |               |                 |                     |       |
|------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                              | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                              | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                              | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="WHITE wine                 | national share (\%)" | -0.250*     | 0.427*        | 0.280           | 0.364               | 0.285 |
|                              | (0.123)              | (0.230)     | (0.243)       | (0.239)         | (0.254)             |       |
| French language share (\%)   |                      | -0.311***   | -0.213*       | -0.239*         | -0.225*             |       |
|                              |                      | (0.089)     | (0.116)       | (0.115)         | (0.109)             |       |
| Absinthe industry share (\%) |                      |             | -0.300        | -0.220          | -0.212              |       |
|                              |                      |             | (0.359)       | (0.304)         | (0.259)             |       |
| Protestant share (\%)        |                      |             |               | -0.060          | -0.026              |       |
|                              |                      |             |               | (0.055)         | (0.072)             |       |
| Log population density       |                      |             |               |                 | -2.188              |       |
|                              |                      |             |               |                 | (2.721)             |       |
| Constant                     | 65.220***            | 67.980***   | 68.088***     | 70.563***       | 79.262***           |       |
|                              | (2.579)              | (2.131)     | (2.155)       | (3.014)         | (11.045)            |       |
| N                            | 24                   | 24          | 24            | 24              | 24                  |       |
| R-squared                    | 0.042                | 0.492       | 0.543         | 0.568           | 0.599               |       |
| RMSE                         | 11.905               | 8.873       | 8.627         | 8.601           | 8.519               |       |


### Panel C: RED wine, drop TI (N=24)

| ="T11 Panel C: RED wine      | drop Ticino"         |             |               |                 |                     |       |
|------------------------------|----------------------|-------------|---------------|-----------------|---------------------|-------|
|                              | (1)                  | (2)         | (3)           | (4)             | (5)                 |       |
|                              | (1) baseline         | (2) +french | (3) +absinthe | (4) +protestant | (5) +geog (density) |       |
|                              | b/se                 | b/se        | b/se          | b/se            | b/se                |       |
| ="RED wine                   | national share (\%)" | 0.631**     | 0.600         | 0.603           | 0.842               | 0.825 |
|                              | (0.259)              | (0.480)     | (0.488)       | (0.659)         | (0.565)             |       |
| French language share (\%)   |                      | -0.229***   | -0.139**      | -0.146**        | -0.153**            |       |
|                              |                      | (0.070)     | (0.056)       | (0.061)         | (0.058)             |       |
| Absinthe industry share (\%) |                      |             | -0.385        | -0.296          | -0.255              |       |
|                              |                      |             | (0.343)       | (0.246)         | (0.345)             |       |
| Protestant share (\%)        |                      |             |               | -0.097*         | -0.063              |       |
|                              |                      |             |               | (0.051)         | (0.061)             |       |
| Log population density       |                      |             |               |                 | -2.507              |       |
|                              |                      |             |               |                 | (3.517)             |       |
| Constant                     | 62.257***            | 66.466***   | 66.441***     | 69.810***       | 79.942***           |       |
|                              | (2.637)              | (2.371)     | (2.391)       | (2.953)         | (14.089)            |       |
| N                            | 24                   | 24          | 24            | 24              | 24                  |       |
| R-squared                    | 0.088                | 0.499       | 0.596         | 0.656           | 0.699               |       |
| RMSE                         | 11.616               | 8.813       | 8.106         | 7.672           | 7.379               |       |

---

## Cahannes (1981) — historiographic anchor for the white-wine substitution test

**Citation.**  Cahannes, Monique. 1981. "Swiss alcohol policy: the emergence of a compromise." *Contemporary Drug Problems* 8(2): 167-186.

**Direct substitution claim** (p. ~5 in PDF; pp. 394-405 of source):
> *"absinthe, particularly popular in the French part of the country, competed with white wine, and the initiative was therefore supported by the winegrowers."*

**Empirical test status (this paper):**
- White-wine main effect on Vote #68: positive and significant at p≈0.03 under volume measure (Table 10v) ✓ consistent with Cahannes substitution channel
- White × French cultural conditioning: null (p > 0.6 in both D1v and D2v) ✗ no slope conditioning detected
- Simpson sign-flip for WHITE in cascade (Table 9 Panel B) ✓ consistent with Cahannes story masked by cultural confound
- Red wine effect: comparable magnitude to white at col 5 (Table 9 Panel C); strengthens without Ticino (Table 11 Panel C)

**Other Cahannes (1981) anchors for workshop narrative:**
- *Federal government OPPOSED the initiative* (preferred taxation for fiscal reasons) — citizen-coalition victory against federal-elite preference; supports Peltzman / B&B framing.
- *Temperance societies originated in viticultural regions* — Protestant Awakening Movement ("Mouvement du Réveil") required abstinence from spirits but allowed moderate wine.  Wine industry and temperance had ALIGNED interests by design — the B&B coalition was institutionalized at the membership level.
- *Class-coded beverage consumption*: spirits = working class, wine = upper/middle class.  Banning the former while protecting the latter reflects social-class interests.
- *Geographic concentration*: 4/5 of viticultural land is in French- and Italian-speaking parts; 3/4 in French-speaking alone.  This is WHY X3_white_share is highly correlated with cov1 (r = 0.638) and the cascade decomposition matters.
- *Constitutional context*: 8 of 187 federal amendments 1874-1978 concerned alcohol production/sale — recurring federal issue.  Auguste Forel (1848-1931) is the recognized Swiss anti-alcohol psychiatrist anchoring the Protestant-temperance movement.

---

## Notes on this assembly

- All workshop regressions use the **density-swap col 5** (`ln_density = ln_pop_1900 - cov_land`)
  replacing the original 09's two-var formulation (`cov_land + ln_pop_1900`).
- All N = 25 cantons throughout the workshop tables.
- HC3 robust SEs for OLS; vce(robust) for fracreg AMEs.
- Workshop estimates live in `estimates_workshop/`, `estimates_fraclogit_workshop/`,
  `estimates_robust_workshop/`, `estimates_petition_workshop/`, `estimates_crossref/`.
- Workshop cohort source of truth: `processed/cohort_1908_workshop.dta`.
- Workshop replication subset: `processed/cohort_1908_workshop_replication.dta`
  (built by `18_workshop_replication_strip.do` via editable KEEP_LIST).

