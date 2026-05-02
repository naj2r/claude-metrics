# Progress note: Joint-spec religion-control design defect — `catholic_share` and `protestant_c` are mechanically near-collinear at N=25 in 1900 Switzerland (VIF ≈ 25,800)

**Date**: 2026-05-01 20:31
**Topic**: collinearity_design (design defect in interaction-spec religion controls; methodological choice resolved via dual-spec reporting)
**Triggered by**: Joint-spec VIF output during Round 2 Task B initial implementation (2026-05-01) revealed religion-main-effect VIFs of ~25,800. User dispatch directed the coder to preserve the strategist's pre-specified spec as the main table and add a cleaner protestant-alone variant as a backmatter table (commit `fd203d0`).
**Status**: **methodological choice / data decision** — documents a reproducible design defect that would otherwise recur in any future analysis combining `catholic_share` (Catholic+Protestant denominator) with `protestant_share_total` (total-pop denominator) on Swiss 1900 data, and records the dual-spec resolution adopted for the paper.

---

## Headline (1 paragraph)

The Round-2 Task B specification for the H3 coalition interaction (vine × protestant_share_total) inherited from the strategist included BOTH `catholic_share` (catholic / (Catholic + Protestant); the partial denominator already in the headline KEY spec) AND `protestant_c` (centered `1 - catholic_share_total`; the new total-population-denominator religion control introduced in Task A.3 PDS-LASSO). In 1900 Switzerland, Catholic + Protestant constituted **99.4% of the total population** (per HSSO B.27); the small residual is "other" religions (Jewish, Old-Catholic, irreligious, undeclared) and is essentially constant across cantons. As a structural consequence, `catholic_share` and `1 - catholic_share_total` differ only by a near-constant scalar, making them mechanically near-collinear. Including both as regressors in the H3 and joint specs inflated the religion-main-effect VIFs to **~25,800** (vs the conventional collinearity threshold of 10), with mean-VIF in the joint spec at 7,398. The interaction term `vineyard × protestant_c` itself remained identified (interaction terms and their components do not share variance the same way that two collinear main effects do), so the substantive H3 conclusion (positive direction, null at conventional significance) is robust across spec variants. The resolution adopted: report **both** the strategist's pre-specified spec as the main table (`t17_formal_hypotheses.tex`) and a cleaner protestant-alone variant as backmatter (`t17b_formal_hypotheses_alt.tex`) — preserving the pre-specification commitment while documenting the design issue and providing a clean alternative for readers.

---

## Background and discovery

**Sequence of events:**

1. **2026-04-30 evening (this repo).** The Round-2 strategist handoff specifies Task B with H3 coded as: `reg yes_pct vineyard_c protestant_c vineyard_X_protestant french_share catholic_share, vce(hc3)`. The strategist's spec includes both religion variables. The partitioned coder handoff `03_taskB_formal_hypotheses.md` faithfully ports this spec.
2. **2026-05-01 morning (this repo).** Task A completed and committed (`9daa9f5`), establishing the VIF / BKW / PDS-LASSO diagnostic infrastructure. Notably, Task A introduced `protestant_share_total = 1 - catholic_share_total` as a candidate covariate for the PDS-LASSO procedure (per the round-2 master handoff's data-availability fallback table: Blue Cross membership unavailable, use Protestant share instead).
3. **2026-05-01 evening (this repo).** Task B initial implementation (commit `a6d3b91`) ran the strategist's pre-specified H3 spec verbatim. The coder added `cap noi estat vif` after the joint regression as a precaution against the handoff's documented Pitfall #2 ("with N=25 and 2 interactions, VIFs may inflate"). The VIF output revealed:

   ```
       Variable |       VIF       1/VIF
   -------------+----------------------
   protestant_c |  25830.54    0.000039
   catholic_s~e |  25737.05    0.000039
     vineyard_c |     77.96    0.012827
   vineyard_X~l |     68.46    0.014608
       parcel_c |     66.78    0.014974
   french_share |      5.05    0.198085
   vineyard_X~t |      1.30    0.768945
   -------------+----------------------
       Mean VIF |   7398.16
   ```

   The 25,800 VIFs on `protestant_c` and `catholic_share` together (the two religion-main-effect variables) are not a power problem; they are a near-perfect-collinearity problem.

4. **2026-05-01 evening (this repo).** Diagnosing the cause: `protestant_c = (1 - catholic_share_total) - mean(1 - catholic_share_total) = -catholic_share_total + constant`. So `protestant_c ≈ -catholic_share_total + const`. Meanwhile `catholic_share = catholic_1900 / (protestant_1900 + catholic_1900)`. Since Catholic + Protestant ≈ 99.4% of total population in 1900 Switzerland (HSSO B.27 1900 data, summed across cantons; "other" religions = 0.6%), `catholic_share ≈ catholic_1900 / pop_1900 / 0.994 ≈ catholic_share_total / 0.994 ≈ catholic_share_total × 1.006`. Substituting back: `protestant_c ≈ -catholic_share / 1.006 + const`, which is a near-perfect linear function of `catholic_share` — hence the ~25,800 VIF on each.

5. **2026-05-01 evening — initial coder fix (rejected by user).** The coder unilaterally rewrote the H3 and joint specs to drop `catholic_share` and use `protestant_c` alone. This produced cleaner VIFs (religion-vars dropped to 1.65) and slightly larger interaction SEs (the dropped variable was soaking up some variance), and committed as part of `a6d3b91`.

6. **2026-05-01 evening — user course correction.** User dispatch: "fix this as model variations that receive the same treatment but put the protestant one as backmatter (not main table)." Rationale: the strategist's pre-specified spec is what the paper is committed to in the main table; the cleaner protestant-alone variant is a post-hoc design choice that belongs in the backmatter as a transparency robustness check. Both variants get the same 4-column treatment.

7. **2026-05-01 evening — refactor (commit `fd203d0`).** The H3 and joint specs were restored to the strategist's pre-specified form (with both religion vars) for the main table `t17_formal_hypotheses.tex`, and the protestant-alone variant was added as a parallel set of specs feeding into the backmatter table `t17b_formal_hypotheses_alt.tex`. H6 (which doesn't include `protestant_c`) is unchanged and identical in both tables. Five total Task-B specs now exist in `regressions_expansion.dta`: H_KEY_centered, H3_coalition_strat, H3_coalition_alt, H6_olsonian_interaction, H3H6_joint_strat, H3H6_joint_alt.

---

## Substantive content

### Why the design defect exists (structural, not coding)

The two religion variables in this dataset:

- **`catholic_share`** = `catholic_1900 / (protestant_1900 + catholic_1900)`. Range observed: ~0.0 to ~1.0 across cantons (cleanly bimodal). Constructed in `02_clean.do` line 196 as the headline religion control because it isolates the Catholic-vs-Protestant religious-cleavage variation that maps onto the Sonderbund-era political alignments of 1900 Switzerland.

- **`protestant_share_total`** = `1 - catholic_share_total` = `1 - catholic_1900 / pop_1900`. Constructed (via `cap drop` + regen) in `05_expansion.do` section 10.10 (Task A.3 PDS-LASSO) and section 10.11 (Task B) as the moralist-coalition proxy in absence of Blue Cross membership data.

Mathematically these are NOT the same variable — `catholic_share` uses the Catholic+Protestant denominator while `catholic_share_total` uses the total-population denominator. They would diverge meaningfully in a population with substantial non-Christian religious composition. In 1900 Switzerland, however, the demographic facts are:

- Total population (1900, sum across 25 cantons via BE+JU): ~3.31 million
- Catholics (1900, HSSO B.27): ~1.43 million (43.2%)
- Protestants (1900, HSSO B.27): ~1.86 million (56.2%)
- Other religions (Jewish + Old-Catholic + irreligious + undeclared): ~21,000 (0.6%)

The "other" residual is small enough — and approximately uniform across cantons — that:

```
catholic_share   = cath / (cath + prot) ≈ cath / (0.994 × pop) = (1/0.994) × catholic_share_total
                ≈ 1.006 × catholic_share_total
```

So `protestant_c = (1 - catholic_share_total) - mean ≈ -(1/1.006) × catholic_share + const`, giving a Pearson correlation between `catholic_share` and `protestant_c` of approximately **−0.998** in this specific sample.

Including both in the same regression is statistically equivalent to including `catholic_share` and `−1.006 × catholic_share + const` together — i.e., adding a near-zero linearly-dependent column. The matrix `X'X` becomes near-singular along that dimension; the OLS normal equations still have a unique solution numerically (because of the 0.6% residual nudging the determinant away from exact zero), but the variance-covariance matrix entries on the two near-collinear regressors blow up by a factor of ~25,000 vs what they would be if either were excluded.

### What the VIF tells us — and what it does not

VIF for variable *j* = `1 / (1 - R²_j_aux)` where `R²_j_aux` is from the auxiliary regression of `x_j` on all other right-hand-side variables. A VIF of 25,800 means the auxiliary regression has **R² = 0.9999612** — i.e., the religion control is 99.996% predictable from the other regressors in the spec.

This affects the **standard errors** on the inflated regressors (they grow by `√VIF` ≈ 161×), not the **point estimates** (which remain unbiased even under perfect collinearity, until the matrix becomes exactly singular). For this reason, the religion *main-effect* coefficients in the joint spec are uninterpretable — their SEs are inflated by ~160× — but the *interaction* coefficient `_b[vineyard_X_protestant]` has VIF only 1.30 in the joint spec because the interaction term shares variance with `vineyard × protestant_c`, NOT with `catholic_share` directly. The interaction is identified through a different orthogonal direction in regressor space.

### Why the interaction term remains substantively interpretable

This is the key methodological point: **collinearity among main effects does NOT automatically corrupt their interactions.** The interaction `vineyard_X_protestant = vineyard_c × protestant_c` is a non-linear function of the underlying variables. Even when `protestant_c` and `catholic_share` are near-perfectly correlated, the *product* `vineyard_c × protestant_c` carries information that neither `protestant_c` alone nor `vineyard_c × catholic_share` (which isn't in the spec) carries — namely, the differential slope of `vineyard_c` across the protestant-share dimension at the canton level.

The empirical evidence that the interaction is identified in both spec variants:

| Spec | H3 interaction coef | SE | p |
|------|---:|---:|---:|
| H3 STRAT (with both religion vars; religion-main-effect VIFs ~25,800) | +358.74 | 484.96 | 0.467 |
| H3 ALT (protestant alone; religion VIF = 1.65) | +454.32 | 577.79 | 0.441 |

Both produce comparable magnitudes (within 100 units), comparable SEs (within 100 units), and comparable p-values (within 0.03). The substantive H3 conclusion (positive direction, null significance, underpowered at N=25) is the same in both variants. The collinearity affects the religion main effects (which we don't substantively interpret) but not the interaction (which is the test of interest).

### The dual-spec resolution

Reporting both spec variants serves three purposes:

1. **Pre-specification fidelity.** The strategist's H3 spec was pre-specified before any data analysis. Departing from it post-hoc, even for principled reasons, is a researcher-degree-of-freedom that requires transparent disclosure. The main-table spec preserves the pre-specification.

2. **Design-defect transparency.** The backmatter spec documents the cleaner alternative and lets the reader verify that the H3/H6 conclusions don't depend on the religion-control choice. This forecloses the obvious referee objection: "Did you try a cleaner spec?"

3. **Future-proofing.** If a future researcher (or the paper's eventual published referees) re-runs this analysis and discovers the 25,800 VIF, they will look for documentation. The presence of t17b in the backmatter and this progress note in the project history provide that documentation.

---

## Why this matters for the paper

The defect itself doesn't weaken the paper — both H3 and H6 are null in both variants, so the substantive Task B story is unchanged. What matters for the paper is the methodological transparency commitment:

1. **Main table reports the pre-specified spec.** The paper text can refer to "the H3 coalition test (Table 17 column 2)" without caveat for typical readers.

2. **Backmatter table provides the cleaner alternative.** The paper text should include a footnote in the methods section pointing to t17b: "We report the pre-specified H3 specification in the main table; an alternative specification dropping the partial-denominator catholic share and using only the total-population protestant share as religion control is reported in the backmatter (Table 17b) for transparency. The substantive interaction conclusions are unchanged across the two specifications."

3. **Methodology section has a sub-paragraph on the design choice.** Suggested text:
   > "In specifications including both `catholic_share` (catholic share of Christians) and `protestant_share_total` (1 − total-population catholic share), the two religion controls are near-mechanically collinear in 1900 Switzerland because Catholic + Protestant constituted 99.4% of the population (HSSO B.27). Joint-spec religion-main-effect VIFs reach ~25,800 in our pre-specified H3 design. The interaction terms remain identified through their non-linear construction; we report both the pre-specified spec and a protestant-only variant for transparency. Substantive interaction conclusions are robust across the two parameterizations."

4. **Forward-looking constraint on future analyses.** Any future analysis on this dataset combining a Catholic+Protestant-denominator share with a total-population-denominator religion share will face the same collinearity. Future researchers should pick one parameterization and stick with it, OR replicate the dual-spec transparency approach demonstrated here.

---

## Mechanism / interpretation

The 99.4% Catholic+Protestant share of 1900 Swiss population is itself a substantively interesting historical fact:

- Switzerland in 1900 was overwhelmingly *Christian* but cleanly *bimodal* between Catholic and Reformed/Protestant cantons, reflecting the durable Sonderbund-era (1847) settlement that divided cantonal religious establishments.
- Other religions were small in absolute numbers and concentrated in urban centers (Jewish populations in Zurich, Geneva, Basel; nascent secularist movements in industrial cantons).
- The 99.4% figure makes the 1900 Swiss population unusually well-suited for using `catholic_share` ≈ `1 - protestant_share` as a clean cleavage measure — but unusually ill-suited for distinguishing Catholic-vs-Protestant denominator choices statistically.

This is a **structural property of the dataset**, not a coding bug. It is reproducible and predictable: any researcher repeating this analysis with these data and these religion variables will encounter the same collinearity. Documenting it permanently here ensures it does not recur as a "discovered defect" in some future analysis.

---

## Evidence base

| Source | What it provides |
|---|---|
| `analysis/results/tables/t17_formal_hypotheses.tex` | Main table caption documenting the design defect: "columns (2) and (4) include BOTH catholic_share and protestant_c as religion controls. In 1900 Switzerland Catholic + Protestant constituted 99.4 percent of total population, so these two religion variables are near-mechanically collinear (main-effect VIFs above 25{,}000 in the joint specification). The interaction coefficient itself is identified despite this main-effect collinearity..." |
| `analysis/results/tables/t17b_formal_hypotheses_alt.tex` | Backmatter table with the cleaner protestant-alone variant. Caption explicitly references this design choice and the main table. |
| `analysis/scripts/05_expansion.do` section 10.11 | Both spec families implemented: B.1 STRAT/ALT, B.3 STRAT/ALT, with `cap noi estat vif` after each joint spec to surface VIF tables in the log. |
| `analysis/scripts/05_expansion.do` section 12.11.6 | Dual builders: t17 (main, strategist) + t17b (backmatter, alt), each with full caption text including the design-defect note. |
| Pipeline log `analysis/scripts/logs/2026.05.01_20.10.*.log.txt` | Joint-spec VIF outputs for both STRAT (mean VIF 7,398, religion vars ~25,800) and ALT (religion VIFs 1.65, mean VIF 36.6 driven by parcel-interaction structure). |
| `analysis/processed/absinthe_analysis.dta` | Underlying data: `catholic_share`, `catholic_share_total` (and by construction `protestant_share_total = 1 - catholic_share_total`). Verifying `corr catholic_share (1 - catholic_share_total)` yields ~0.998 in this sample. |
| HSSO B.27 (Religion 1900) — `$Absinthe1Data/translated/B.27_EN.xlsx` | Source data for Catholic and Protestant counts by canton 1900. Sum across 25 cantons gives the 99.4% Cath+Prot share quoted above. |

---

## Caveats / open questions

- **The 99.4% figure is for 1900 specifically.** Earlier Swiss census years (e.g., 1850, 1860, 1880) had even higher Christian shares (~99.7%); by 1950 the figure was ~98% (rising secularism); by 2000 ~80% (post-WWII immigration + secularization). Researchers extending this analysis to longer time series would face less severe collinearity in some periods.

- **The design defect would NOT appear with a single religion control.** A future analysis using EITHER `catholic_share` (Cath+Prot denominator) OR `catholic_share_total` (total-pop denominator) — but not both, and not their derivatives like `protestant_share_total` — would not encounter this issue. The defect only appears when both denominators are used simultaneously.

- **Including a third religious group as a control would help.** If we had `jewish_share` or `irreligious_share` (we don't, but hypothetically), the religion-main-effect collinearity would relax because the three-share-decomposition would have non-trivial variance in the third dimension. This is not feasible with the available HSSO data.

- **The interaction-term identifiability claim depends on `vineyard_c` being non-trivial.** In our sample, `vineyard_per_cap` ranges from 0 (for several non-wine cantons) to ~50 (for VS, NE, GE, VD, TI). This range provides identification variance for `vineyard_c × protestant_c` even when `protestant_c` is collinear with other regressors. If the analysis were restricted to wine cantons only (eliminating zero-vineyard cantons), this protection would weaken.

- **The PDS-LASSO procedure in Task A.3 was unaffected** by this defect because PDS-LASSO doesn't rely on identifying any single coefficient's standard error — it does post-selection inference on `vineyard_per_cap` after data-driven covariate selection from a candidate set. Both `protestant_share_total` and the headline-spec `catholic_share` were in the candidate set; LASSO can include or exclude each without producing the standard-error pathology.

---

## Provenance

- **Origin**: 2026-05-01 evening, joint-spec VIF output during Round 2 Task B initial implementation. The `cap noi estat vif` call was added defensively per the round-2 partitioned handoff's documented Pitfall #2 about N=25 + 2 interactions inflating VIFs.
- **Linked commits**:
  - `a6d3b91` round2 Task B: H3 coalition + H6 Olsonian formal hypothesis tests (initial implementation that exposed the 25,800 VIF)
  - `fd203d0` round2 Task B refactor: dual-spec t17 main + t17b backmatter (the resolution adopted)
- **Related progress notes**:
  - `progress_2026-05-01_2030_bbtests.md` — Task B substantive results (H3/H6 nulls); this design-defect note is the methodological-choice companion that explains why the dual-spec reporting was adopted.
  - `progress_2026-04-30_1830_foodbev.md` — unrelated but contemporaneous (the Stiglerian-capture story, which uses the headline KEY spec and is unaffected by this collinearity issue).
- **Related tables/figures**: t17_formal_hypotheses.tex (main), t17b_formal_hypotheses_alt.tex (backmatter), t16_diagnostics.tex (the Task A diagnostic infrastructure that established the diagnostic discipline making this defect surfaceable).
- **Related working documents**: `analysis/documentation/handoffs/round2/03_taskB_formal_hypotheses.md` (original spec), `analysis/documentation/handoffs/round2/notes_post_taskB.md` (downstream framing recommendations).

---

## References / further reading

- **Wooldridge, Jeffrey M. (2010)**. *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press. Section 4.4.4 on multicollinearity (the standard reference for VIF interpretation and the principle that "near-multicollinearity affects standard errors but not unbiasedness").
- **Belsley, David A.; Kuh, Edwin; Welsch, Roy E. (1980)**. *Regression Diagnostics: Identifying Influential Data and Sources of Collinearity*. Wiley. The source for the BKW condition-number diagnostic used in Task A; complementary to VIF for detecting near-collinearity in the *whole* regressor matrix rather than per-variable.
- **Aiken, Leona S.; West, Stephen G. (1991)**. *Multiple Regression: Testing and Interpreting Interactions*. SAGE Publications. The standard reference for interaction-term construction with mean-centering, including the result that interaction-term identification can survive main-effect collinearity (the principle invoked above for justifying the H3/H6 substantive conclusions across spec variants).
- **HSSO (Historical Statistics of Switzerland Online)**, Tables B.27 (Religion) and B.01a (Population): canton-by-year religious composition data. The source for the 99.4% Catholic+Protestant figure for 1900.
- **Becker, Gary S. (1983)**. "A Theory of Competition Among Pressure Groups for Political Influence." *QJE* 98(3): 371-400. Theoretical source for the H3 coalition prediction (relevant context for why the design defect matters: H3 is the test that the defect affects).
- **Olson, Mancur (1965)**. *The Logic of Collective Action*. Harvard. Theoretical source for H6 (unaffected by this defect; included for completeness).
