# T_lewbel_appendix -- Lewbel exploratory endogeneity-robustness

| Lewbel heteroskedasticity-IV (exploratory) | Value |
| --- | --- |
| Wine revenue-share coef (full sample, robust SE) | 0.571 (0.156) |
| 95-percent confidence interval | [0.266, 0.877] |
| Kleibergen-Paap rk Wald F (full sample) | 222.3 |
| Hansen J overidentification p | 0.131 |
| Generated instruments | 3 |
| Leave-one-out coef range (25 single-canton drops) | [0.495, 0.735] |
| Leave-one-out minimum KP F | 46.2 |
| drop-NE (heartland): coef / KP F | 0.518 / 174.1 |
| LOO sign flips / fits insig. at 5 percent | 0 / 0 |

_Note: Lewbel (2012) heteroskedasticity-based IV (ivreg2h) for the wine revenue share, col-5 controls (French share, Catholic share, log population), N=25 cantons. EXPLORATORY endogeneity-robustness only -- NOT a main-text result. Robustness is assessed by LEAVE-ONE-OUT STABILITY: the coefficient keeps its sign and 5-percent significance and the KP F stays at or above 46 across all 25 single-canton deletions, including dropping Neuchatel (the absinthe heartland). It is NOT certified by the KP F greater-than-20 rule of thumb, which is only heuristic for generated instruments at N=25. The Lewbel identifying restriction (controls uncorrelated with the product of the structural and first-stage errors) is untestable. The estimate corroborates the OLS / fractional-logit headline (about 0.43 to 0.47) via a route that needs no common support._
