# C.15 Phase 2: Olson x Wine Interaction Primary Specs

**Phase**: C.15 Phase 2 (verify_reconstruct_expand handoff)  
**Date**: 2026-05-13  
**Source**: processed/absinthe_analysis.dta + processed/i38_canton_concentration.dta (on-the-fly merge)  
**Output**: results/intermediate/c15_olson_wine_specs.dta  
**Script**: 05_expansion.do, section 10.19  

---

## Specification

For each of 4 concentration measures C in {share_above_3, share_above_10, share_above_30, gini_lcap}:

    yes_pct = beta0 + beta1 * vineyard_per_cap + beta2 * (C - mean(C))
            + beta3 * vineyard_per_cap * (C - mean(C))
            + beta4 * french_share + beta5 * catholic_share + epsilon

Estimator: OLS with HC3 robust SEs. N = 25 cantons. Concentration mean-centered so beta1 is the vineyard effect at the sample-mean concentration.

**Olson prediction**: beta3 > 0 (vineyard's pro-ban-vote effect amplified by agricultural concentration).

## Results: 4-spec comparison

| Concentration measure | beta1 (vineyard) | SE | beta3 (interaction) | SE | p (interaction) | R^2 |
|---|---:|---:|---:|---:|---:|---:|
| share_above_3 |   752.99 |  383.09 | -20.2759 | 47.7324 | 0.676 | 0.608 |
| share_above_10 |   907.95 | 1097.92 |  -0.4839 | 33.2118 | 0.989 | 0.596 |
| share_above_30 |   477.21 |  637.38 | -47.1377 | 64.9216 | 0.477 | 0.674 |
| gini_lcap |   346.05 |  602.85 | -6.1e+03 |  1.1e+04 | 0.575 | 0.578 |

## Substantive interpretation (proposed)

- **beta1 (vineyard at mean conc)** captures the headline wine-protection effect at typical agricultural concentration. Should be positive and significant at the headline magnitude (~480 in raw KEY-spec, comparable here).
- **beta3 (interaction)** is the Olson test. If positive across all 4 measures, the wine-protection effect is amplified by agricultural concentration -- supporting Olson at the canton level. If near zero or sign-inconsistent across measures, the wine effect operates independently of concentration.
- **Cross-measure stability** of beta3 (consistent sign, similar magnitudes) is itself an empirical signal: it suggests the Olson signal is in the data, not in the choice of measure.
- **R^2** comparison: the measure with the highest R^2 has the most explanatory power, but should be weighted alongside coefficient stability per the methodology note v2 selection criteria.

## Pending follow-up (Phases 3-5)

1. **Phase 3 Robustness**: re-run all 4 specs with NE-OVB controls, drop-NE and drop-NE+GE subsamples, alternative covariate sets.
2. **Phase 4 NE-OVB**: explicitly test whether the Olson signal is driven by NE alone (the absinthe-producing canton, also flagged on the trip-wire at top_bin_area_share = 26.4%). If the interaction collapses without NE, the canton-level Olson story doesn't replicate.
3. **Phase 5 Placebo battery for the interaction**: extend Tier 1.1 (T14b) to the interaction spec -- run the interaction on each of the 14 placebo votes and check whether the interaction concentrates on #68 alone.
4. **Phase 6 Paragraph**: draft the Section 5 prose conditional on Phase 3-5 outcomes.

5. **Methodology**: area-calibrated robustness Gini still pending (deferred from C.15 Phase 1.1; requires independent canton-total cultivated area).

## Provenance

Computed in 05_expansion.do section 10.19 (Phase C.15 Phase 2). Source: processed/absinthe_analysis.dta + processed/i38_canton_concentration.dta. KEY-spec covariates: vineyard_per_cap + french_share + catholic_share. Concentration measures from I.38 (1905 Federal Agricultural Census).
