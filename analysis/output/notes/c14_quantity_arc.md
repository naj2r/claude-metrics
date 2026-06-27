# Phase C.14 — National Crop Production: Quantity-Side Corroboration of Substrate-Substitution

**Source**: HSSO I.21a (Annual yields of vegetable products, 1837-1991, yearly). National-level only.
**Phase C.14** of `2026-05-12_coder_handoff_verify_reconstruct_expand.md`. Pillar 2 quantity-side corroboration.

## Why this matters

The substrate-substitution framework predicts AMBIGUOUS price movements (demand for substitutes up; substitute supply up via land reallocation) but UNAMBIGUOUS QUANTITY increases for substitute crops during the phylloxera era. C.10 H.2a price evidence is consistent with the framework but cannot directly identify the mechanism (demand-quantity data unavailable). C.14 directly tests the quantity-side prediction.

## Period means (T26 headline numbers)

| Period | Years (N) | Wine (1000 hl) | Potato (1000 q) | Cereal (1000 q) |
|---|---:|---:|---:|---:|
| Pre-phylloxera 1837-1862 | 26 |   1418 |   5849 |   4301 |
| Phylloxera era 1875-1895 | 21 |   1360 |   8060 |   3448 |
| Recovery + ban 1895-1915 | 21 |   1014 |   6849 |   2673 |

## Key year values

| Year | Event | Wine (1000 hl) | Potato (1000 q) | Cereal (1000 q) |
|---|---|---:|---:|---:|
| 1837 | first data row |   1370 |   8434 |   4199 |
| 1862 | pre-phylloxera last |   1804 |   8169 |   5062 |
| 1875 | wine production peak era |   2350 |   7634 |   4108 |
| 1880 |  |   1469 |   6704 |   3811 |
| 1885 | potato peak era |   1795 |  11521 |   3817 |
| 1890 |  |   1047 |   6653 |   3173 |
| 1892 | ratio peak (H.2a) |   1391 |  10691 |   3534 |
| 1894 |  |   1429 |   9996 |   3365 |
| 1900 |  |   2194 |   9029 |   2850 |
| 1908 | **absinthe ban** |   1033 |   7672 |   2424 |
| 1910 | wine-index peak (H.2a) |    222 |   3622 |   2424 |
| 1915 |  |    626 |   8350 |   2412 |

## Substantive interpretation

**Wine production**: pre-phylloxera baseline (mean   1418) to phylloxera-era trough (mean   1360). Sustained decline through ban era (mean   1014). Framework prediction: WINE DOWN — supported.

**Potato production**: pre-phylloxera baseline (mean   5849) to phylloxera-era mean   8060 — substantial increase during phylloxera. Framework prediction: POTATO UP — supported.

**Cereal production**:   4301 (pre) to   3448 (phyl) to   2673 (ban). Pattern is dominated by secular trends rather than substitution; framework not strongly identified on cereal.

## Convergent evidence base for Pillar 2

- **C.10 H.2a prices** (1830-1915): wine/potato ratio rises 1.00 (pre) to 1.29 (phyl) to 1.34 (recovery)
- **C.10b structural-break period means** (T23b): pre-phylloxera ratio at parity establishes baseline
- **C.14 I.21a quantities** (THIS FILE): wine production sustained decline; potato production phylloxera-era surge
- **Marrus 1974** consumption volumes: 35x increase in cheap-spirits consumption 1873-1900
- **C.12 I.01 canton substrate areas** (1917 complete coverage): regional substrate availability documented

Together these pieces converge on the substrate-substitution narrative without any individually claiming to identify the mechanism.

## Caveats

- I.21a starts 1837 (no earlier data). The pre-phylloxera baseline window is 1837-1862, slightly shorter than the H.2a 1830-1862 window.
- Quantity is national; cannot identify within-canton heterogeneity.
- Framework prediction is qualitative (direction); magnitude inference would require demand elasticity estimates we do not have.
- Cereal pattern is dominated by secular trends; not a clean substitute-supply surge story.

## Provenance

Computed in `07_substrate_descriptives.do` § 9c-9c.4. Source dataset: `processed/intermediate/i21a_quantities_long.dta`. T26: `results/tables/t26_quantity_periods.tex`. F10: `results/figures/f10_quantity_arc.pdf`.
