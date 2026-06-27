# T_ri — randomization inference p-values [STALE -- pending R re-run on 1907-corrected data; NOT final]

| Specification (estimator) | Observed coef | RI p-value |
| --- | --- | --- |
| Wine X3 -- col 1 (OLS coef) | -0.196 | 0.524 |
| Wine X3 -- col 2 (OLS coef) | 0.568 | 0.016** |
| Wine X3 -- col 3 (OLS coef) | 0.415 | 0.084* |
| Wine X3 -- col 4 (OLS coef) | 0.547 | 0.022** |
| Wine X3 -- col 5 (OLS coef) | 0.469 | 0.054* |
| Wine X2 (volume) -- col 5 (OLS) | 0.454 | 0.101 |
| Producer -- p1 raw (OLS coef) | -11.199 | 0.023** |
| Producer -- p2 (OLS coef) | -10.768 | 0.032** |
| Producer -- p3 (OLS coef) | -12.083 | 0.021** |
| Producer -- p4 full (OLS coef) | 3.574 | 0.363 |
| Wine X3 -- col 5 (FL AME) | 0.434 | 0.087* |
| Wine X3 -- col 2 (FL AME) | 0.531 | 0.029** |
| Wine X2 (volume) -- col 5 (FL AME) | 0.428 | 0.128 |
| Producer -- p1 raw (FL AME) | -10.874 | 0.027** |
| Producer -- p4 full (FL AME) | 3.548 | 0.374 |

_Note: Randomization-inference p-values: the focal regressor is permuted across the 25 cantons 10000 times (seed 20260603) and the spec re-estimated each time; the p-value is the share of permutations with |coef| at least as large as observed. Observed coef on the 0-100 scale for OLS and in pp for FL AME. Stars: * p<0.10, ** p<0.05, *** p<0.01. Canonical battery = 10,000 permutations (methodology-integrity floor). THIS TABLE IS STALE: p-values were computed on the pre-1907-population-fix dataset and do NOT match the current point estimates; they are pending regeneration via the standalone R randomization-inference port on the corrected data._
