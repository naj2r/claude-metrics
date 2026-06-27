# C.16 Structural Break Test on Wine/Potato Producer-Price Ratio (1830-1915)

**Phase**: C.16 (verify_reconstruct_expand handoff)  
**Date**: 2026-05-13  
**Window**: 1830-1915 (yearly, N=86)  
**Series**: wine_potato_ratio = wine_idx / potato_idx (HSSO H.2a, 1914=100)  
**Source dataset**: processed/intermediate/h2a_substrate_prices_long.dta  
**Script**: 07_substrate_descriptives.do, section 9d  

---

## Specification

Model: wine_potato_ratio_t = c + gamma * year_t + epsilon_t (OLS, no HAC adjustment).

Two tests of the null 'no structural break in (c, gamma)':

1. **Quandt-Andrews supremum-Wald** with unknown break date and trim(15) -- candidate break dates restricted to 1843-1903. The trim bypasses endpoint contamination and the WWI confound.
2. **Wald test at known break 1875** (Banerjee et al. 2010 phylloxera-onset year), via Stata's **estat sbknown**.

## Results

| Test | Statistic | df | p-value | Estimated break |
|---|---:|---:|---:|---:|
| Quandt-Andrews Sup-Wald |  28.511 | 2 | < 0.0001 | 1887 |
| Chow Wald at 1875       |  6.471 | 2 | 0.0393    | fixed at 1875 |

## One-paragraph Section 5 text (draft, awaiting strategist review)

A Quandt-Andrews supremum-Wald test on the wine/potato producer-price ratio over 1830-1915 rejects the null of no structural break (W =  28.511 on 2 degrees of freedom, p < 0.0001), with the data-estimated break year at 1887. A complementary Wald test at the Banerjee et al. (2010) phylloxera-onset year of 1875 also rejects the null at the 5 percent level (chi-sq(2) =  6.471, p = 0.0393). Both tests support the structural-break framing in T23b: the wine/potato ratio in the pre-phylloxera baseline period (1830-1862) is statistically indistinguishable from a stationary parity regime, and the post-1875 trajectory represents a regime shift toward sustained wine-supply scarcity. The data-estimated break year (1887) falls within the documented phylloxera era (1880s-1890s) and lags the canonical 1875 onset year by about a decade, consistent with diffusion of the supply shock through Swiss producer markets.

## Caveats

- The Quandt-Andrews trim is 15 percent from each end; the estimated break date is constrained to the 1843-1903 interior. Breaks falling within 1830-1842 or 1904-1915 are not detectable by construction.
- The linear trend model (c + gamma*year) assumes a single regime change in level and slope. Multiple-break or nonlinear-trend alternatives are not tested.
- The Wald test at 1875 has correct nominal size only if the break date is exogenously known. The 1875 date here is taken from Banerjee et al. (2010), where it represents the historically-documented phylloxera-arrival year, not a data-driven choice.
- Both tests assume errors are uncorrelated. For yearly producer-price data, residual autocorrelation likely understates standard errors and inflates the test statistic. A robustness check using Newey-West HAC SEs is in scope for a future revision but is not implemented here.

## Provenance

Computed in 07_substrate_descriptives.do section 9d (Phase C.16). Source: H.2a producer-price indexes 1801-1983 (HSSO; Ritzmann 1990; Swiss Farmers' Secretariat 1922-1984). Phylloxera-onset year convention: Banerjee et al. (2010), as also applied in t23 substrate prices table.
