# Methodology: Gini coefficient construction from binned farm-size data

**Working draft for Section 5 / Appendix of the Paper #1 manuscript (Swiss 1908 absinthe referendum, Olson × Wine interaction analysis). Ready to `\input{}` after LaTeX-formatting.**

---

## Source data

The 1905 Swiss Federal Agricultural Census reports farm counts by canton across 11 size classes, ranging from 0–0.5 hectares of cultivated area through an unbounded "over 30 hectares" class. The data are tabulated in HSSO source I.38 (Historische Statistik der Schweiz Online) and translated to English in `Data/translated/I.38_EN.xlsx`. Each canton-bin cell reports both the number of farms and the total cultivated area in that bin.

For 25 cantons × 11 bins = 275 canton-bin observations, the data structure is:

$$\underbrace{\{n_{ci}, A_{ci}\}}_{c \in \text{cantons}, \; i \in \text{bins}}$$

where $n_{ci}$ is the count of farms in canton $c$ and bin $i$, and $A_{ci}$ is the total cultivated area (hectares) in canton $c$ and bin $i$. We use these directly to construct the Gini coefficient — no within-bin imputation is required because both farm counts AND areas are observed at the bin level.

---

## The Gini coefficient

For canton $c$, define the cumulative shares:

$$F_{ci} = \frac{\sum_{s=1}^{i} n_{cs}}{\sum_{s=1}^{N} n_{cs}}, \qquad A_{ci}^* = \frac{\sum_{s=1}^{i} A_{cs}}{\sum_{s=1}^{N} A_{cs}}$$

where $F_{ci}$ is the cumulative share of farms through bin $i$ in canton $c$, and $A_{ci}^*$ is the cumulative share of cultivated area through bin $i$ in canton $c$. By construction $F_{cN} = A_{cN}^* = 1$ where $N = 11$.

The Gini coefficient is then:

$$G_c = 1 - \sum_{i=1}^{N-1}\left(F_{c,i+1} - F_{c,i}\right)\left(A_{c,i+1}^* + A_{c,i}^*\right)$$

This is the Brown trapezoidal discrete-sum approximation to the area between the 45° equality line and the empirical Lorenz curve, with the Lorenz curve modeled as a polygon through the observed bin-boundary points $(F_{ci}, A_{ci}^*)$.

**Canonical citation:** This formula appears explicitly in Galor, Moav, and Vollrath (2009), *Review of Economic Studies* 76(1), Appendix B p. 33. It is the operative standard for Gini construction from binned ag-land data in the economic history literature; the same formula underlies the Deininger-Squire (1998) cross-national landholding database used by Vollrath (2007).

---

## Treatment of the unbounded top bin

The 11th bin is "over 30 hectares" with no upper bound, which presents a known measurement challenge. We follow Galor, Moav, and Vollrath (2009, Appendix B) by capping the top-bin representative size at the bin's lower bound of 30 hectares for the primary specification.

This is the conservative choice — it assumes no farm in the top bin exceeds 30 hectares, which mechanically pulls the canton's Gini coefficient downward. The underestimation is small if the top bin contains few farms or little total area; it may be material if either share is large.

Because our data report both farm counts AND areas at the bin level (unlike GMV's 1880/1900 US Census data, which reported only counts), we do not actually need to impute a within-bin representative size to compute the Gini — the formula above operates directly on the observed cumulative area shares. The top-bin lower-bound cap therefore affects only one quantity: the implicit average farm size in the top bin, which enters the threshold-share alternatives discussed below but not the Gini itself when areas are observed.

**Robustness specification.** Following Galor, Moav, and Vollrath (2005, Brown University Working Paper, Data Appendix pp. 39–40), we also report a Gini constructed under an alternative top-bin convention: the area-calibrated mean, in which the top-bin representative size is set such that total cultivated area across all bins equals the known canton total from independent HSSO sources. Both Ginis are reported side-by-side; sensitivity is reported in Appendix Table A[X].

---

## The top-bin diagnostic

Galor, Moav, and Vollrath (2009, Appendix B p. 33) defend their lower-bound cap by stating "the results are not sensitive to alternate choices." This claim rests on the empirical fact that their top bin (>1,000 acres) contains very few farms — a structural feature of the late-19th-century US data. The same structural assumption may not hold for Swiss alpine and pastoral cantons in 1905, where large pastoral landholdings are concentrated in the few largest farms but cover substantial area.

We therefore report, as a descriptive diagnostic alongside the Gini values, the share of total canton cultivated area in the ">30 ha" bin for each canton:

$$\text{top\_bin\_area\_share}_c = \frac{A_{c,11}}{\sum_{s=1}^{11} A_{cs}}$$

If this share is small across all cantons, the GMV (2009) sensitivity defense transfers to our setting and the lower-bound cap is appropriate as the primary specification. If this share is large in any canton, the Gini under the primary specification is meaningfully attenuated for that canton, and the area-calibrated robustness Gini (or a top-share concentration ratio; see below) is preferred.

The descriptive table reports `top_bin_area_share` for all 25 cantons; cantons exceeding 20% are flagged in the methodology note for transparency.

---

## Complementary concentration measures: top-share family

In any cross-sectional analysis using the Gini, we also compute and report the top-share concentration ratio family, following the precedent in Cinnirella and Hornung (2016):

$$\text{share\_above}_X^c = \frac{\sum_{i : L_i \geq X} A_{ci}}{\sum_{i=1}^{N} A_{ci}}$$

for $X \in \{3, 5, 10, 15, 20, 30\}$ hectares. This family of measures is robust to the unbounded top-bin problem by construction — the threshold-share is unaffected by how the top bin is internally distributed, as long as one fixes which bins lie above the threshold.

Cinnirella and Hornung (2016, *Journal of Development Economics*) document a 19th-century Prussian context — county-level binned agricultural land, with the largest size class always unbounded — that is structurally analogous to Swiss 1908. Notably, those authors *chose* top-share concentration ratios over a Gini coefficient specifically because of the unbounded top bin. This precedent grounds our parallel reporting.

---

## Choice of primary measure: empirically determined post-hoc

We are agnostic ex ante about which inequality measure best captures the Olsonian collective-action mechanism in this application. We therefore run the Olson × Wine interaction specification under both measures (Gini and top-share family) and select the primary measure for the main paper based on empirical performance across four dimensions:

1. **Coefficient stability** across robustness specifications (Neuchâtel-OVB controls, drop-NE and drop-NE+GE subsamples, alternative covariate sets)
2. **Standard error tightness** under HC3 and randomization inference
3. **Sensitivity to top-bin assumption** (less sensitive measures are more defensible)
4. **Placebo battery behavior** — the measure yielding cleaner discrimination between the 1908 ban referendum and the 14 placebo referenda is empirically more credible

The measure that performs better on these dimensions appears as primary in the main paper. The other appears in robustness specifications and the appendix. This decision is documented in `analysis/output/notes/2026-05-13_c15_gini_construction.md` once both sets of values are computed.

---

## Software implementation

Gini and top-share construction is performed in Stata using the user-written `ineqdec0` package (or a custom implementation following the explicit formula above; see `scripts/02_gini_construction.do`). Within-bin areas are observed directly from the I.38 source, so we do not require the `inequal7` family of imputation routines.

---

## Conventions adopted from project rule

This methodology follows the project rule `.claude/rules/gini-from-binned-data.md`, which governs all Gini construction from binned data in this codebase. Key conventions adopted:

- Brown trapezoidal formula (GMV 2009 Appendix B) as canonical
- Within-bin midpoint imputation (where needed; not needed here since we observe bin-level areas)
- Top-bin lower-bound cap as primary, area-calibrated alternative as robustness
- Top-bin area-share diagnostic mandatory before publishing any Gini
- Top-share concentration ratio family always reported alongside Gini
- Post-hoc empirical selection of primary measure

The full five-paper literature synthesis grounding these conventions is at `quality_reports/pdf_scans/gini_methodology_synthesis.md` in the strategist worktree.

---

## References

Cinnirella, Francesco, and Erik Hornung. 2016. "Landownership Concentration and the Expansion of Education." *Journal of Development Economics* 121: 135–152.

Deininger, Klaus, and Lyn Squire. 1998. "New Ways of Looking at Old Issues: Inequality and Growth." *Journal of Development Economics* 57(2): 259–287.

Galor, Oded, Omer Moav, and Dietrich Vollrath. 2005. "Land Inequality and the Emergence of Human Capital Promoting Institutions." Brown University Department of Economics Working Paper 2005-03.

Galor, Oded, Omer Moav, and Dietrich Vollrath. 2009. "Inequality in Landownership, the Emergence of Human-Capital Promoting Institutions, and the Great Divergence." *Review of Economic Studies* 76(1): 143–179.

Vollrath, Dietrich. 2007. "Land Distribution and International Agricultural Productivity." *American Journal of Agricultural Economics* 89(1): 202–216.
