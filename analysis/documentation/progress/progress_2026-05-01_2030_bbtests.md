# Progress note: B&B coalition (H3) and Olsonian (H6) interaction tests are null at N=25 — lack of evidence, not evidence of lack

**Date**: 2026-05-01 20:30
**Topic**: bbtests (Bootleggers-and-Baptists hypothesis tests, Round 2 Task B)
**Triggered by**: Completion of Round 2 Task B (formal H3 and H6 hypothesis tests). User dispatch on 2026-05-01 to "do major-change entries" for the H3/H6 results so the paper's evidentiary status is preserved permanently.
**Status**: **methodological choice / robustness** — establishes that two pre-specified bootleggers-and-baptists hypotheses cannot be tested at the available N=25 sample, with both producing positive-direction null results that should be reported honestly as "underpowered" rather than "rejected" or "supported."

---

## Headline (1 paragraph)

The Round-2 strategist handoff specified two formal tests of the bootleggers-and-baptists framework derived from Becker (1983) and Olson (1965): H3 — wine-industry effect amplified by moralist-coalition strength, operationalized as `vineyard_per_cap × protestant_share_total` (Blue Cross / Croix-Bleue / IOGT canton-level membership unavailable, hence Protestant share as the available proxy); and H6 — wine-industry effect amplified by Olsonian industrial concentration, operationalized as `vineyard_per_cap × avg_parcel_area_1905`. Both tests came back **directionally consistent with the hypotheses but null at conventional significance levels**: H3 STRAT (main, with both religion vars) +358.74 (SE 484.96, p=0.467); H3 ALT (backmatter, protestant alone) +454.32 (SE 577.79, p=0.441); H6 (same in both spec families) +394.34 (SE 2406.58, p=0.872). The KEY-spec headline result (vineyard coef positive) survives interaction inclusion in all five Task-B specs (vineyard main effect ranges +464 to +1096 across H3/H6/joint variants). With N=25 cantons and one interaction term, the minimum detectable effect for H6 at conventional power was approximately 17× the observed magnitude — these tests were **structurally underpowered**, and the resulting null results should be reported as "lack of evidence" rather than "evidence of lack."

---

## Background and discovery

**Sequence of events:**

1. **2026-04-30 evening (this repo).** Strategist's Round-2 handoff (`Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_paper1_coder_handoff_round2.md`) specifies Task B as one of three round-2 priorities, with the goal of moving the paper from "consistent with B&B" to "tests B&B against rival explanations." Two interactions called out: H3 (coalition) and H6 (Olsonian). Predicted signs: both positive.
2. **2026-04-30 evening (this repo).** Partitioned handoff `analysis/documentation/handoffs/round2/03_taskB_formal_hypotheses.md` written by coder session, marking Task B as a STOP-AFTER-THIS gate before Tasks C.5 and C.6 because the framing of those downstream tasks depends on whether H3 and H6 hold.
3. **2026-05-01 morning (this repo).** Task A completed (commit `9daa9f5`): VIF, BKW condition number, and PDS-LASSO diagnostics established the KEY-spec collinearity story is benign (VIFs 1.07-1.42, BKW 2.39, PDS-LASSO sign-positive). This Task A diagnostic infrastructure is what later catches the Task B design defect (see `progress_2026-05-01_2031_collinearity_design.md`).
4. **2026-05-01 evening (this repo).** Task B initial implementation (commit `a6d3b91`) ran H3 and H6 with the strategist's pre-specified spec including BOTH `catholic_share` AND `protestant_c` as religion controls. This produced joint-spec religion-main-effect VIFs of ~25,800 because in 1900 Switzerland Catholic + Protestant constituted 99.4% of total population (the two religion variables share essentially all their Catholic-population variance). User dispatch directed the coder to keep the strategist's pre-specified spec as the main table and add a cleaner protestant-alone variant as a backmatter table — both variants reported, both share the same H3/H6 substantive nulls.
5. **2026-05-01 evening (this repo).** Task B refactor (commit `fd203d0`) implemented dual-spec t17 main + t17b backmatter. All 5 specs (H3 STRAT, H3 ALT, H6, joint STRAT, joint ALT) pass the vineyard-main-effect-positive sanity assertion. Pipeline at 36 assertions, runtime ~150 seconds.

**Why the null results matter enough to record permanently**: the paper's planned framing depended on H3 and H6 returning *some* signal — even marginal — to anchor the bootleggers-and-baptists theoretical motivation as more than narrative. With both tests null, the reframing decision (proceed with B&B as theoretical motivation but acknowledge tests are uninformative at N=25) is itself a paper-affecting choice that needs to outlive this conversation.

---

## Substantive content

### H3 — coalition interaction (Becker 1983)

**Theoretical prediction**: The wine-industry effect on the absinthe vote is amplified in cantons where the moralist-temperance coalition is organizationally stronger. Becker's (1983) coalition theory of pressure-group politics predicts that complementary interests (here, wine producers seeking competitor elimination + temperance reformers seeking moral reform) produce larger policy effects when the coalition has higher organizational density.

**First-best operationalization** (per strategist handoff): canton-level membership in the Blue Cross (Croix-Bleue, German: Blaues Kreuz) — the dominant Swiss Protestant temperance organization 1880-1920, founded by Louis-Lucien Rochat (Vaud, 1877) and centrally organized in Bern. Membership data exists in Blue Cross archival annual reports but is NOT available in any digital HSSO or swissvotes source.

**Available proxy**: Protestant share of the canton's total population in 1900 (`protestant_share_total = 1 - catholic_share_total`). Justification: the Swiss temperance movement 1880-1908 was empirically dominated by Reformed/Protestant religious networks (Blue Cross, IOGT, Methodist temperance societies). Canton-level Protestant share is a noisy but defensible proxy for the density of these networks in absence of direct membership data.

**Results (HC3 robust SEs, N=25)**:

| Spec | Vineyard main effect | H3 interaction (vine × prot) | SE | p |
|------|---:|---:|---:|---:|
| H3 STRAT (main t17, both religion vars) | +472.21 | +358.74 | 484.96 | 0.467 |
| H3 ALT (backmatter t17b, protestant alone) | +463.64 | +454.32 | 577.79 | 0.441 |
| Joint STRAT (main t17 col 4) | +872.87 | +324.93 | 887.77 | 0.719 |
| Joint ALT (backmatter t17b col 4) | +759.22 | +385.91 | 985.87 | 0.700 |

**Interpretation**: Direction is consistent with Becker's coalition prediction (positive interaction in all four spec variants). Magnitude is moderate (300-450 across variants). Statistical significance is absent (smallest p-value 0.441; none below 0.40). The hypothesis cannot be rejected and cannot be statistically supported at this sample size.

### H6 — Olsonian industrial-concentration interaction (Olson 1965)

**Theoretical prediction**: The wine-industry effect is amplified in cantons where wine-producing land is more concentrated. Olson's (1965) collective-action theory predicts that smaller, more-concentrated groups overcome the free-rider problem more effectively and achieve disproportionate policy gains.

**Operationalization**: `avg_parcel_area_1905` (constructed in `02_clean.do` as `agland_1000ha × 1000 / (farms_1905 × parcels_per_farm_1905)`). Larger average parcel area → fewer, larger producers → more concentrated industry → easier collective action per Olson.

**Results (HC3 robust SEs, N=25)**:

| Spec | Vineyard main effect | H6 interaction (vine × parcel) | SE | p |
|------|---:|---:|---:|---:|
| H6 alone (col 3 of both tables) | +1095.57 | +394.34 | 2406.58 | 0.872 |
| Joint STRAT (main t17 col 4) | +872.87 | +282.12 | 2974.31 | 0.926 |
| Joint ALT (backmatter t17b col 4) | +759.22 | +189.57 | 3023.55 | 0.951 |

**Interpretation**: Direction is technically consistent with Olson (positive sign), but the magnitude is dwarfed by the standard error in every spec. The H6 interaction is essentially zero signal. With p-values of 0.87-0.95, this is well into "the data cannot tell us anything" territory.

### Power analysis — why both tests were always going to be inconclusive

For a two-sided test at α=0.05 with 80% power, the minimum detectable effect (MDE) on a regression coefficient is approximately `2.8 × SE` — i.e., observed |t| must exceed ~2.8 for the test to be powered to detect a true effect. Empirically observed |t|-statistics in Task B:

- H3 STRAT: |t| = 358.74 / 484.96 ≈ **0.74** (need 2.07 for sig; need 2.8 for 80% power)
- H3 ALT: |t| = 454.32 / 577.79 ≈ **0.79**
- H6 alone: |t| = 394.34 / 2406.58 ≈ **0.16** (essentially zero signal)
- Joint H3 STRAT: |t| ≈ 0.37
- Joint H6 STRAT: |t| ≈ 0.09

For H6 specifically, the MDE at observed SE was approximately 2.8 × 2406 ≈ +6,740 on the interaction. We observed +394. **The true effect would have to be ~17× the observed magnitude for these data to detect it with 80% power.** Even an enormous economic effect — say, a one-SD increase in `avg_parcel_area_1905` (≈0.2 ha/parcel) producing a vineyard-slope shift of +1,348 — would still fall short of detection in this sample.

H3 is closer to detectable but still well outside the power envelope. To detect an H3 effect of the observed magnitude (~+450) at conventional levels, we would need either (a) ~5-7× more cantons (which doesn't exist for this single referendum) or (b) a sharper proxy than Protestant share for moralist-coalition strength (Blue Cross membership data, which isn't digitized).

---

## Why this matters for the paper

The paper's pre-Task-B framing positioned H3 and H6 as the formal hypothesis tests that would elevate the analysis from "consistent with bootleggers-and-baptists" to "tests bootleggers-and-baptists." With both nulls, that framing must adjust:

1. **The B&B theoretical motivation remains valid.** The KEY-spec result (vineyard coefficient +484, p<0.05, surviving 28+ robustness checks including LOO, exclude-NE+GE, randomization inference, fractional logit, weighted regressions, and post-double-selection LASSO) is directly consistent with B&B coalition rent-seeking. The paper can and should present B&B as the most plausible interpretation of the headline finding.

2. **The formal hypothesis claims must be honest about power.** The paper text and t17 caption should report H3 and H6 as "directionally consistent but uninformative due to N=25 sample size" — NOT as "rejected" (which would be wrong; underpowered tests don't reject), and NOT as "supported" (which would be wrong; null is null). The honest framing is "theoretically motivated tests that the available data cannot resolve."

3. **The paper's contribution shifts modestly.** From "we test H1-H6" (originally planned) to "we test H1, H2, H4, H5 (the well-powered tests on the headline + robustness) and report H3, H6 as theoretically motivated but underpowered." The H3/H6 nulls are not failures of the paper; they are honest reporting of what N=25 can and cannot establish.

4. **Forward-looking implication for downstream tasks.** Task C.5 (Language Cleavage Index) and Task C.6 (Differential Mobilization) were partly motivated by H3-coalition and H6-Olsonian framings. With H3 null, C.5 should lean on the Gelbach-confirmed language-channel story (99% LANG δ in t15) rather than the coalition story. With H6 null, C.6 stands on its own as an extensive-margin (turnout) channel independent of the intensive-margin (vote-share) wine-industry effect; its identification does not depend on H6 holding. See `analysis/documentation/handoffs/round2/notes_post_taskB.md` for full reframing recommendations.

---

## Mechanism / interpretation

The substantive question — whether the wine-industry effect on the absinthe vote was *amplified* by moralist-coalition strength or by Olsonian concentration — remains theoretically interesting but empirically unresolved at N=25.

**What the data is consistent with** (cannot reject):
- A real positive H3 interaction (wine effect larger where Protestants more numerous → moralist coalition stronger → joint rent-seeking more effective)
- A real positive H6 interaction (wine effect larger where parcels more concentrated → fewer larger producers → easier coordination)
- Either or both interactions being zero or even slightly negative

**What the data shows** (rejects):
- Nothing. The tests are too noisy to reject anything.

**What we can say with confidence**: the KEY-spec wine-industry coefficient (+484) is robust across all interaction inclusions — vineyard main effect remains positive (range +464 to +1096 across the 5 Task-B specs). The Simpson sign-flip story (bivariate negative → conditional positive once language and religion are added) and the Stiglerian capture story (vineyard cantons supported food-law #65 as well as absinthe-ban #68; see `progress_2026-04-30_1830_foodbev.md`) are unaffected by the H3/H6 nulls, because they rest on main-effect identification, not interaction identification.

**The paper's empirical story** survives Task B intact. What changes is the *framing precision* of the bootleggers-and-baptists section: from "we test the coalition and Olsonian channels" to "we motivate the analysis with B&B and document that the coalition and Olsonian channels are theoretically defensible but underpowered to test directly at the available sample size."

---

## Evidence base

| Source | What it provides |
|---|---|
| `analysis/results/tables/t17_formal_hypotheses.tex` | MAIN table: 4 columns (KEY centered / H3 STRAT / H6 / joint STRAT). All H3/H6 interaction coefs and SEs. Caption documents the design issue (catholic_share + protestant_c near-collinearity) and points to t17b. |
| `analysis/results/tables/t17b_formal_hypotheses_alt.tex` | BACKMATTER table: same 4-column structure with H3 ALT and joint ALT (protestant_c alone, cleaner religion-main-effect identification). |
| `analysis/results/intermediate/regressions_expansion.dta` | All 5 Task-B specs saved as rows tagged `spec ∈ {H_KEY_centered, H3_coalition_strat, H3_coalition_alt, H6_olsonian_interaction, H3H6_joint_strat, H3H6_joint_alt}`, model = "ols". 30+ rows total covering coefs, SEs, t-stats, p-values, N, and r2 for each spec. |
| `analysis/scripts/05_expansion.do` section 10.11 | Estimation block: B.1 STRAT/ALT, B.2 H6, B.3 STRAT/ALT joint. Centered regressors constructed; interaction terms built; results saved with regsave; di output for log inspection. |
| `analysis/scripts/05_expansion.do` section 12.11.6 | Builder code for both t17 and t17b, with full caption text including the design-defect documentation. |
| `analysis/scripts/05_expansion.do` section 13 | Sanity asserts: vineyard main effect > 0 in all 5 Task-B specs. Hypothesis signs (positive H3, positive H6) NOT asserted because they are the substantive claims being reported. |
| `analysis/documentation/handoffs/round2/03_taskB_formal_hypotheses.md` | Original Task B partitioned handoff with strategist's spec and acceptance criteria. |
| `analysis/documentation/handoffs/round2/notes_post_taskB.md` | Working framing document for downstream Tasks C.5 and C.6 in light of Task B null results. |
| Commits `a6d3b91` and `fd203d0` | Initial Task B implementation and dual-spec restructure. |
| Pipeline log `analysis/scripts/logs/2026.05.01_20.10.*.log.txt` | All 5 Task-B regression outputs, joint-spec VIF tables, and assert-block results. |

---

## Caveats / open questions

- **N=25 is the binding constraint.** No specification trick or modeling choice will recover power at this sample size. Future work that extends to commune-level data (~3,000 communes in 1908 Switzerland) would dramatically improve power for these interaction tests, but commune-level archival extraction is out of scope for this paper.

- **The Blue Cross membership data does exist in archives.** Annual reports of the Schweizer Blau-Kreuz-Verein (Swiss Blue Cross Federation) and the Croix-Bleue Romande list canton-level membership figures from 1880 onward. These are NOT digitized but could be hand-collected. If so collected for 1900 or 1905, the H3 test could be re-run with Blue Cross density rather than Protestant share as the moderator, which would be a meaningfully sharper proxy. Even then, N=25 remains binding.

- **A natural future H6 sharpening**: instead of `avg_parcel_area_1905` (which mixes vineyard and non-vineyard agricultural land), a vineyard-specific concentration measure (mean vineyard-parcel size or Herfindahl index of vineyard ownership) would be theoretically tighter. Such data is available in cantonal viticultural inventories from the 1880s but requires hand-collection from cantonal archives.

- **The two religion proxies (catholic_share with Catholic+Protestant denominator vs catholic_share_total with total-pop denominator) are essentially redundant in 1900 Switzerland** because Catholic + Protestant = 99.4% of the population. This is a structural property of late-19th-century Swiss demographics, not a coding bug. Future work using earlier (pre-1830) or non-Swiss data would face a different religious composition and the two measures would diverge meaningfully.

- **The H3/H6 nulls do NOT update us against the bootleggers-and-baptists framework as such.** They update us against the *testability of B&B-derived interactions in this specific N=25 dataset*. The theoretical framework remains the most parsimonious explanation for the headline +484 wine-industry coefficient and the cross-vote regulatory-capture pattern documented in `progress_2026-04-30_1830_foodbev.md`.

---

## Provenance

- **Origin**: 2026-04-30 strategist Round-2 handoff (Task B) → 2026-04-30 partitioned coder handoff `03_taskB_formal_hypotheses.md` → 2026-05-01 Task A diagnostics (commit `9daa9f5`) → 2026-05-01 Task B initial (commit `a6d3b91`) → user dispatch to dual-spec → 2026-05-01 Task B refactor (commit `fd203d0`).
- **Linked commits**:
  - `9daa9f5` round2 Task A: VIF + BKW + PDS-LASSO diagnostics
  - `a6d3b91` round2 Task B: H3 coalition + H6 Olsonian formal hypothesis tests
  - `fd203d0` round2 Task B refactor: dual-spec t17 main + t17b backmatter
- **Related progress notes**:
  - `progress_2026-04-30_1830_foodbev.md` — Stiglerian capture pattern across votes #65 and #68 (the headline-strengthening companion finding to Task B's interaction nulls)
  - `progress_2026-05-01_2031_collinearity_design.md` — design defect discovered via Task B joint-spec VIF (the methodological-choice companion note to this one)
- **Related tables/figures**:
  - `t17_formal_hypotheses.tex` (main, strat) — primary evidence for this note
  - `t17b_formal_hypotheses_alt.tex` (backmatter, alt) — supporting evidence
  - `t15_gelbach.tex` — the Gelbach decomposition that makes the language story load-bearing for C.5 (per the post-Task-B reframing)
  - `t13_placebo_panel.tex` — the cross-referendum placebo panel that anchors the Stiglerian capture story
  - `t02_main.tex`, `t03_fracreg.tex` — KEY-spec headline tables (the +484 coefficient that survives Task B's interaction inclusions)

---

## References / further reading

- **Becker, Gary S. (1983)**. "A Theory of Competition Among Pressure Groups for Political Influence." *Quarterly Journal of Economics* 98(3): 371-400. The theoretical source for the H3 coalition prediction (complementary pressure groups produce larger policy effects).
- **Olson, Mancur (1965)**. *The Logic of Collective Action: Public Goods and the Theory of Groups*. Harvard University Press. The theoretical source for the H6 Olsonian-concentration prediction (smaller, more concentrated groups overcome the free-rider problem more effectively).
- **Stigler, George J. (1971)**. "The Theory of Economic Regulation." *Bell Journal of Economics and Management Science* 2(1): 3-21. The framework for the Stiglerian capture interpretation of the cross-vote pattern (relevant for downstream framing per `progress_2026-04-30_1830_foodbev.md`).
- **Yandle, Bruce (1983)**. "Bootleggers and Baptists: The Education of a Regulatory Economist." *Regulation* 7(3): 12-16. The popularization of the bootleggers-and-baptists framework that motivates the Task B tests.
- **Cohen, Jacob (1988)**. *Statistical Power Analysis for the Behavioral Sciences*. 2nd ed. Lawrence Erlbaum Associates. The standard reference for the power-vs-detectable-effect calculations applied above.
- **Wooldridge, Jeffrey M. (2010)**. *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press. Section 4.4 on multicollinearity and Section 18.7 on interaction-term identification (directly relevant to the H3/H6 design and the design-defect resolution documented in the companion progress note).
