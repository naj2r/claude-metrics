# Section 2.1 Anchor Statistics — Descriptive Evidence for Closing Paragraph

**Source:** processed/cohort_1908_workshop.dta (N=25 cantons, vote #68 = 5 July 1908)
**Generated:** 2026-05-22 by `_section_2_1_anchor_stats.do`
**Scope:** Strictly descriptive (no regressions). All percentages 1 decimal place; correlations 3 decimal places.

---

## 1. Vote #68 yes-shares for §2.1 named cantons

| Canton | Yes #68 (%) |
|--------|------------:|
| VD |  56.1 |
| GE |  40.8 |
| NE |  35.3 |
| VS |  61.8 |
| FR |  59.5 |
| TI |  68.4 |
| **National (simple mean of cantons)** | ** 64.3** |
| **National (population-weighted)**    | ** 63.0** |

*Note: 'National' here is the cohort-aggregate over 25 cantons. The 63.5% benchmark from federal totals is the actual referendum result; the simple-mean and pop-weighted values above differ because they treat cantons as units rather than voters.*

## 2. Group-mean comparisons — yes #68 by group

Format: each grouping splits the 25 cantons into two groups; reports mean(SD), N, and simple difference (group1 minus group0).

| Grouping | Group 1 (mean / SD / N) | Group 0 (mean / SD / N) | Diff (G1 - G0) pp |
|----------|--------------------------|--------------------------|------------------:|
| Wine cantons (X3_share>0) vs non-wine |  63.4 ( 12.3) / N=20 |  68.2 (  8.9) / N=5 |  -4.8 |
| Absinthe-producer (abs_producer==1) vs non-producer |  56.7 ( 12.7) / N=8 |  67.9 (  9.6) / N=17 | -11.2 |
| French-majority (cov1>=50) vs German-majority (cov1<50, excl TI) |  50.7 ( 11.9) / N=5 |  67.7 (  9.2) / N=19 | -17.0 |
| Protestant-majority (cov3>=50) vs Catholic-majority (cov3<50) |  63.5 ( 13.0) / N=12 |  65.1 ( 10.8) / N=13 |  -1.6 |
| Prior-cantonal-ban (VD, GE) vs no-prior-ban |  48.4 ( 10.9) / N=2 |  65.7 ( 10.9) / N=23 | -17.3 |

## 3. Petition rate by group (stage-separation evidence)

Mean petition signatures per 100 eligible voters (pet_per_eligible) by the same groupings as §2 above. Side-by-side with the vote-stage means lets the reader see whether the petition stage loads differently on Protestant share / wine production than the vote stage does.

**National mean petition rate (simple mean over 25 cantons):**  20.5 per 100 eligible.

| Grouping | Group 1 (mean / SD / N) | Group 0 (mean / SD / N) | Diff (G1 - G0) |
|----------|--------------------------|--------------------------|---------------:|
| Wine cantons vs non-wine |  21.8 (  9.6) / N=20 |  15.0 (  7.8) / N=5 |   6.8 |
| Absinthe-producer vs non-producer |  20.0 ( 10.2) / N=8 |  20.7 (  9.5) / N=17 |  -0.7 |
| French-majority vs German-majority (excl TI) |  23.9 (  9.4) / N=5 |  20.4 (  9.1) / N=19 |   3.5 |
| Protestant-majority vs Catholic-majority |  25.5 (  9.0) / N=12 |  15.8 (  7.6) / N=13 |   9.7 |
| Prior-cantonal-ban vs no-prior-ban |  24.1 (  9.2) / N=2 |  20.1 (  9.7) / N=23 |   4.0 |

*Substantive read: compare the row-by-row differences in §3 (petition stage) vs §2 (vote stage).  Where the gap shrinks/flips between the two stages, the cleavage shifted between petition organization and voter participation.*

## 4. Bivariate vs partial correlations (Simpson's-paradox anchor)

| Correlation | Value |
|-------------|------:|
| corr(vineyard_per_cap X1, pct_yes_68) — raw bivariate | -0.073 |
| partial corr(X1, pct_yes_68 \| cov1) — controlling French share |  0.265 |
| corr(pet_per_eligible, X1) — petition vs vineyard area | -0.070 |
| corr(pet_per_eligible, cov3) — petition vs Protestant share |  0.589 |

*Substantive read: the first two rows are the Simpson's-paradox kernel — raw correlation between vineyard area and yes-#68 vs the partial correlation after netting out French language share.  Sign and magnitude shift is the §2.1 quantitative anchor.*

## 5. Within-Romandie comparison (5 French-majority cantons)

Within the same language bloc, the vote pattern is heterogeneous in ways that track producer-side configuration rather than language.

| Canton | Yes #68 (%) | Petition rate | X1 (wine per 1k pop) | Abs producer | Abs industry share (%) | Prior ban | Protestant share (%) |
|--------|------------:|--------------:|---------------------:|:------------:|-----------------------:|:---------:|---------------------:|
| VD |  56.1 |  30.6 |  22.6 | Y |  10.3 | Y |  86.8 |
| GE |  40.8 |  17.5 |  12.7 | Y |  18.6 | Y |  48.2 |
| NE |  35.3 |  31.2 |   8.9 | Y |  58.8 | N |  85.8 |
| VS |  61.8 |  10.5 |  24.5 | Y |   1.0 | N |   1.4 |
| FR |  59.5 |  29.7 |   1.6 | Y |   1.1 | N |  15.1 |

## 6. Heimberg empirical test (within-French bloc)

Heimberg ('no major economic interests at stake') reads imply that, within a single language bloc, wine cantons and absinthe-producer cantons should NOT differ from non-wine and non-producer cantons.  Within the 5-6 French-majority cantons, check both differences.

**(a) Within French bloc — wine cantons vs non-wine cantons:**

- Wine cantons within French bloc: mean yes-#68 =  50.7 (N=5)
- Non-wine cantons within French bloc: mean yes-#68 =     . (N=0)
- *Note: all French-bloc cantons in cohort are wine-producing; this within-French wine/non-wine split is degenerate.  Falsification reads on the language/wine confound rather than within-French wine variation.*

**(b) Within French bloc — absinthe producer vs non-producer:**

- Absinthe-producer cantons within French bloc: mean yes-#68 =  50.7 (N=5)
- Non-producer cantons within French bloc: mean yes-#68 =     . (N=0)
- Difference:     . pp

*Substantive read: if |difference| > 5 pp, Heimberg's 'no major economic interests at stake' claim is empirically contradicted within the very language bloc he discusses.*

## 7. T25 French-German turnout-gap collapse (reference; from T6_turnout_gap_collapse.tex)

From the existing T25/T6 table (Phase C.6c output):

| Stat | French (N=5) | German (N=20) | Gap (Fr - Ge) |
|------|-------------:|--------------:|--------------:|
| Baseline turnout (median across 14 placebo votes 1907-1910) | 44.40 | 56.62 | -12.22 |
| Vote #68 turnout (5 July 1908, absinthe ban) | 47.92 | 48.02 | -0.11 |
| Change (gap collapse) | +3.52 | -8.60 | +12.12 |

*Substantive read: the French-German turnout gap, normally -12 pp, collapses to ~0 on vote #68.  +12.12 pp swing in the gap is the empirical signature of the language cleavage activating on this specific vote.*

---

**Generated:** 22 May 2026 15:21:30 by `_section_2_1_anchor_stats.do`
