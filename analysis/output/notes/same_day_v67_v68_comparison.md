# Same-Day Vote Comparison: #67 (Commerce) vs #68 (Absinthe), 5 July 1908

**Phase B.4** of `2026-05-12_coder_handoff_verify_reconstruct_expand.md`. 
**Source**: HSSO swissvotes, columns *bet* (turnout), *japroz* (yes share), per canton per ballot question. 

## Headline finding (April 2026 replicated)

Cantons where turnout on vote #68 (absinthe ban) exceeded turnout on vote #67 (commerce, same ballot day) had voters who came specifically for the absinthe question. The top-three excess cantons are German-speaking with substantial wine industries (SG, SH) or low-baseline-turnout German cantons (GL). The pattern confirms differential issue-specific mobilization rather than generic voter engagement.

## Per-canton same-day excess (sorted descending)

| Rank | Canton | Turnout v67 (%) | Turnout v68 (%) | Excess (pp) | Yes-share v68 (%) |
|---:|---|---:|---:|---:|---:|
| 1 | GL | 34.38 | 46.24 | +11.86 | 72.49 |
| 2 | SG | 60.81 | 68.42 | +7.61 | 74.44 |
| 3 | SH | 61.87 | 69.21 | +7.34 | 77.34 |
| 4 | BE | 25.31 | 32.17 | +6.86 | 55.32 |
| 5 | BS | 27.01 | 33.82 | +6.81 | 65.13 |
| 6 | GR | 43.89 | 49.57 | +5.68 | 83.28 |
| 7 | UR | 32.96 | 38.41 | +5.45 | 70.56 |
| 8 | LU | 18.68 | 22.29 | +3.61 | 74.54 |
| 9 | ZG | 20.39 | 23.94 | +3.55 | 61.91 |
| 10 | NW | 32.86 | 35.60 | +2.74 | 82.48 |
| 11 | TI | 15.99 | 18.63 | +2.64 | 68.37 |
| 12 | FR | 35.76 | 37.65 | +1.89 | 59.50 |
| 13 | TG | 81.30 | 81.47 | +0.17 | 65.51 |
| 14 | VD | 48.12 | 48.14 | +0.02 | 56.13 |
| 15 | AG | 78.97 | 78.97 |  0.00 | 63.02 |
| 16 | AI | 70.69 | 70.69 |  0.00 | 60.59 |
| 17 | AR | 63.82 | 63.82 |  0.00 | 57.64 |
| 18 | BL | 35.04 | 35.04 |  0.00 | 55.18 |
| 19 | GE | 55.07 | 55.07 |  0.00 | 40.75 |
| 20 | NE | 60.25 | 60.25 |  0.00 | 35.26 |
| 21 | OW | 36.36 | 36.36 |  0.00 | 65.41 |
| 22 | SO | 72.38 | 72.38 |  0.00 | 52.67 |
| 23 | ZH | 59.56 | 59.56 |  0.00 | 75.93 |
| 24 | SZ | 23.90 | 23.89 | -0.01 | 73.40 |
| 25 | VS | 38.50 | 38.47 | -0.03 | 61.75 |

## Interpretation

**Substantively meaningful excess** (>+5 pp): GL +11.86, SG +7.61, SH +7.34, BE +6.86, BS +6.81, GR +5.68, UR +5.45. 
These cantons show issue-specific mobilization on the absinthe question. Combined with the gap-collapse finding (French cantons mobilized differentially: see dispersion\_descriptive\_stats.md), the same-day excess pattern documents that BOTH structural language partition AND ballot-specific issue salience drove turnout patterns on #68.

## Caveat: 9 cantons with zero excess

Cantons reporting same_day_excess_v68_v67 = 0 (BL, AI, GE, ZH, OW, NE, SO, AR, AG): turnout values for v67 and v68 are literally identical in swissvotes data. This is likely an artifact of how swissvotes records ballot-day-level vs question-level turnout for some cantons (single statistic per ballot day rather than per question). Treat zero as data-availability limitation rather than evidence of zero question-specific mobilization.

## Provenance

Computed in `05_expansion.do` § 10.18 (Phase B.4 reconstruction) from `absinthe_analysis.dta` using `turnout_v67` (extracted in `01_import.do` § 2.3, B.4 patch) and `turnout` (= turnout_v68 unsuffixed).
