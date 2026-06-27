# I.38 Farm-Size Extraction + Top-Bin Trip-Wire Diagnostic (Phase C.15 prep)

**Phase**: C.15 prep / Phase 1.0 (verify_reconstruct_expand handoff)  
**Date**: 2026-05-13  
**Source**: HSSO I.38 (1905 Swiss Federal Agricultural Census, canton x farm-size)  
**Translated file**: research_data_raw/c-metrics-absinthe1/translated/I.38_EN.xlsx  
**Script**: 07_substrate_descriptives.do, section 9e  

---

## TL;DR

Two methodological deviations from analysis/documentation/methods/gini_methodology.md were identified during extraction. **The strategist should review and update that note before C.15 Phase 1.1.**

1. **NINE bins, not 11.** The 1905 Swiss census reports 9 cultivated-area size classes: 0.0-0.5, 0.5-1, 1.01-3, 3.01-5, 5.01-10, 10.01-15, 15.01-20, 20.01-30, >30 hectares. The methodology note's claim of 11 bins is incorrect. The Gini formula handles N=9 identically -- this is a numerology correction only.

2. **No observed bin areas.** I.38 reports ONLY farm counts per canton-bin, NOT bin-level cultivated areas. The methodology note's statement that 'each canton-bin cell reports both the number of farms and the total cultivated area' is INCORRECT. Bin-level areas must be IMPUTED via bin midpoints throughout (not just the top bin, which the note already noted needs handling). The Gini construction must therefore operate on cumulative shares of IMPUTED areas, not observed areas.

Trip-wire diagnostic table (deliverable): 6 of 25 cantons exceed the 20-percent top-bin area-share threshold mandated by the project rule.

## Source-data layout (I.38)

- Single worksheet ('Worksheet'); 146 rows x 29 columns.
- Canton codes in row 4 (cols B-AC: ZH, BE+JU combined, BE, LU, UR, ..., GE, JU, CH). The combined BE+JU column (C) is used as 1908-historical BE per the project canton_crosswalk.
- Section titles in column B at rows 6, 19, 32, 44, 56, 68, 80, 92, 104, 116, 128 (11 sections).
- Section row 6 = 'Total number of farms' (overall total, validation only).
- Section row 32 = 'Farms with cultivated area over 0.5 hectares' (cumulative subtotal of bins 2-9; **NOT** a standalone bin; skipped in extraction).
- The 9 standalone bin sections are at rows 19, 44, 56, 68, 80, 92, 104, 116, 128.
- 1905 data row in each section = section_row + 2. Years covered: 1905, 1929, 1939, 1955, 1965, 1969, 1975, 1980, 1985, 1990. Only 1905 (the pre-vote year) is extracted.

## Bin definitions and midpoint convention

| Bin | I.38 section row | 1905 data row | Range (ha) | Midpoint (ha) | Note |
|---:|---:|---:|---|---:|---|
| 1 |  19 |  21 | 0.00 - 0.50    |  0.25 |  |
| 2 |  44 |  46 | 0.50 - 1.00    |  0.75 |  |
| 3 |  56 |  58 | 1.01 - 3.00    |  2.00 |  |
| 4 |  68 |  70 | 3.01 - 5.00    |  4.00 |  |
| 5 |  80 |  82 | 5.01 - 10.00   |  7.50 |  |
| 6 |  92 |  94 | 10.01 - 15.00  | 12.50 |  |
| 7 | 104 | 106 | 15.01 - 20.00  | 17.50 |  |
| 8 | 116 | 118 | 20.01 - 30.00  | 25.00 |  |
| 9 | 128 | 130 | > 30.00 (open) | 30.00 | Lower-bound cap; GMV 2009 primary. Area-calibrated robustness alternative not yet computed (requires independent canton-total cultivated area from HSSO I.01 or similar). |

## Top-bin area-share trip-wire (deliverable)

Per-canton imputed area share of the unbounded top bin: top_bin_area_share_c = imputed_area_c_9 / sum_i imputed_area_c_i.

Project rule .claude/rules/gini-from-binned-data.md sec. 4: flag any canton with top_bin_area_share > 20% for additional scrutiny in C.15 robustness work.

| Canton | top_bin_area_share (%) | Flag (>20%) |
|---|---:|---:|
| AG |  1.91 | no |
| AI |  7.66 | no |
| AR |  5.30 | no |
| BE | 18.50 | no |
| BL |  8.60 | no |
| BS | 26.98 | **YES** |
| FR | 18.19 | no |
| GE | 17.98 | no |
| GL | 29.33 | **YES** |
| GR | 32.98 | **YES** |
| LU | 15.07 | no |
| NE | 26.39 | **YES** |
| NW | 25.04 | **YES** |
| OW | 18.49 | no |
| SG |  8.46 | no |
| SH |  1.71 | no |
| SO | 12.12 | no |
| SZ | 17.03 | no |
| TG |  3.68 | no |
| TI |  8.60 | no |
| UR | 26.42 | **YES** |
| VD | 13.35 | no |
| VS | 16.85 | no |
| ZG | 10.57 | no |
| ZH |  2.16 | no |

**Cantons flagged: 6 of 25.**

## Threshold-share family (deliverable; area-based, midpoint-imputed)

share_above_X = (sum of imputed cultivated area in bins with lower bound >= X ha) / total imputed canton cultivated area.

Note: share_above_30 is identical to top_bin_area_share by construction (only bin 9 has lower bound >= 30).

Available in processed/i38_canton_concentration.dta for X in {3, 5, 10, 15, 20, 30}. Stata variable names: share_above_3, share_above_5, share_above_10, share_above_15, share_above_20, share_above_30 (each in percent units, 0-100).

## Pending decisions for the strategist (before C.15 Phase 1.1)

1. **Methodology-note correction.** Update analysis/documentation/methods/gini_methodology.md to reflect (a) 9 not 11 bins, (b) midpoint imputation required throughout (not only at the top bin), and (c) the Gini formula now operates on cumulative shares of imputed areas, not observed areas. The literature references in the note (GMV 2009, Cinnirella-Hornung 2016) remain applicable; the GMV 2005 Brown WP Appendix B treatment of counts-only data is the closer-fit precedent than the GMV 2009 RES paper.

2. **Area-calibrated robustness top-bin convention.** GMV 2005 proposes calibrating the top-bin representative size such that total imputed cultivated area equals a known canton total from an independent source. We need to identify that independent source. HSSO I.01 includes agricultural-land area per canton; the C.12 canton_substrate_availability workflow already extracted partial coverage. The area-calibrated robustness Gini and threshold shares can be added in a follow-up commit.

3. **Trip-wire interpretation.** With 6 cantons exceeding 20% top-bin share, the GMV (2009) 'top-bin sensitivity is negligible' defense may NOT transfer to the Swiss case. Implications for C.15:
   - Area-calibrated robustness must be computed and reported alongside the primary Gini.
   - The empirical primary-measure selection (Gini vs. top-share family) should weight robustness of the threshold-share family more heavily, since those are immune to the unbounded-top-bin problem by construction.
   - Consider reporting threshold-share family as PRIMARY in the main paper, with Gini as appendix/robustness.

## Provenance

Computed in 07_substrate_descriptives.do section 9e (Phase C.15 prep / Phase 1.0). Source: HSSO I.38 (1905 Federal Agricultural Census; Schweizerisches Bauernsekretariat statistical surveys). BE/JU combined-column convention. Midpoint imputation throughout; top bin (>30 ha) capped at 30.0 (GMV 2009 primary convention).
