# C.15 Phase 1.1: Land Gini Construction (lower-bound-cap convention)

**Phase**: C.15 Phase 1.1 (verify_reconstruct_expand handoff)  
**Date**: 2026-05-13  
**Source dataset**: processed/i38_farm_size_long.dta (225 obs = 25 cantons x 9 bins)  
**Output**: gini_lcap added to processed/i38_canton_concentration.dta  
**Script**: 07_substrate_descriptives.do, section 9f  

---

## Formula

Brown trapezoidal discrete-sum (Galor, Moav, and Vollrath 2009 RES, Appendix B p. 33):

    G_c = 1 - sum_{i=1}^{N} (F_{c,i} - F_{c,i-1}) * (L_{c,i} + L_{c,i-1})

where F_{c,i} = cumulative share of farms through bin i in canton c; L_{c,i} = cumulative share of (imputed) cultivated area through bin i; F_{c,0} = L_{c,0} = 0; N = 9 bins. Bin areas are midpoint-imputed (no observed bin areas in I.38; see section 9e methodology deviation #2).

## Top-bin convention

**Lower-bound cap (primary, GMV 2009)**: top-bin midpoint = 30.0 ha (the bin lower bound). This is the conservative choice; it pulls the Gini downward for cantons with concentrated landholdings in the unbounded >30 ha bin -- precisely the 6 cantons flagged on the top-bin trip-wire (BS, GL, GR, NE, NW, UR; see section 9e).

**Area-calibrated (robustness, GMV 2005 Brown WP)**: NOT YET COMPUTED. Requires an independent canton-total cultivated area from HSSO I.01 (partial coverage available per C.12 workflow) or equivalent. The area-calibrated top-bin midpoint is set such that total imputed cultivated area equals the known canton total; this yields a HIGHER Gini for flagged cantons (the cap-attenuation reverses). Follow-up commit will compute and report side-by-side.

## Per-canton Gini (lower-bound cap)

| Canton | Gini (lcap) | Top-bin area share (%) | Flag (>20%) |
|---|---:|---:|---:|
| AG | 0.431 |  1.91 | no |
| AI | 0.390 |  7.66 | no |
| AR | 0.432 |  5.30 | no |
| BE | 0.515 | 18.50 | no |
| BL | 0.490 |  8.60 | no |
| BS | 0.705 | 26.98 | **YES** |
| FR | 0.505 | 18.19 | no |
| GE | 0.558 | 17.98 | no |
| GL | 0.533 | 29.33 | **YES** |
| GR | 0.544 | 32.98 | **YES** |
| LU | 0.457 | 15.07 | no |
| NE | 0.492 | 26.39 | **YES** |
| NW | 0.521 | 25.04 | **YES** |
| OW | 0.485 | 18.49 | no |
| SG | 0.466 |  8.46 | no |
| SH | 0.421 |  1.71 | no |
| SO | 0.508 | 12.12 | no |
| SZ | 0.481 | 17.03 | no |
| TG | 0.431 |  3.68 | no |
| TI | 0.436 |  8.60 | no |
| UR | 0.510 | 26.42 | **YES** |
| VD | 0.480 | 13.35 | no |
| VS | 0.480 | 16.85 | no |
| ZG | 0.451 | 10.57 | no |
| ZH | 0.417 |  2.16 | no |

**Summary**: mean 0.486, SD 0.063, min 0.390, max 0.705 (N=25 cantons).

**Trip-wire interaction**: flagged cantons (top-bin share > 20%) have mean gini_lcap = 0.551; unflagged cantons have mean gini_lcap = 0.465. The area-calibrated robustness will yield higher Gini values for the flagged group; the threshold-share family (in the same canton-level dataset) is convention-invariant and immune to this attenuation by construction.

## Caveats

- 9 bins, not 11 (methodology note v1 said 11; corrected in section 9e and pending v2 update).
- Areas imputed throughout (midpoint), not observed at bin level (methodology note v1 stated bin areas observed directly; corrected in section 9e).
- Lower-bound cap (top midpoint = 30 ha) attenuates Gini for cantons with large pastoral or alpine landholdings concentrated in the >30 ha bin. The 6 trip-wire-flagged cantons (BS, GL, GR, NE, NW, UR) are precisely the cases where attenuation matters most.
- Area-calibrated robustness alternative not yet computed (deferred follow-up; requires independent canton-total cultivated area).
- Per the methodology note v2 framing (in parallel by the strategist), the threshold-share family (share_above_X for X in {3, 5, 10, 15, 20, 30}, already in processed/i38_canton_concentration.dta) is the empirical PRIMARY concentration measure for the Olson x Wine interaction in C.15 Phase 2. The Gini family (lcap here; area-calibrated follow-up) is the ROBUSTNESS measure.

## Provenance

Computed in 07_substrate_descriptives.do section 9f (Phase C.15 Phase 1.1). Source: processed/i38_farm_size_long.dta (built in section 9e). Formula: GMV (2009) RES Appendix B. Top-bin convention: lower-bound cap = 30 ha (GMV 2009 primary). N = 9 bins, midpoint-imputed areas throughout (deviations from methodology note v1 documented in section 9e).
