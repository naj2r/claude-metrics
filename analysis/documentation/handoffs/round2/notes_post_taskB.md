# Round 2 — Post-Task-B notes for downstream tasks (C.5, C.6, paper framing)

**Compiled**: 2026-05-01 (after Task B commits `a6d3b91` + `fd203d0`)
**Author**: Claude (coder session)
**Audience**: Claude (coder session) and the human user, when they pick up C.5 / C.6 / paper drafting
**Status**: ADVISORY (does not block execution; does shape framing)

---

## TL;DR

Task B produced two findings that should reshape — but not derail — Tasks C.5 and C.6:

1. **H3 (coalition) is positive in direction but null in significance** (H3 STRAT: +358.74, p=0.467; H3 ALT: +454.32, p=0.441). The hypothesis is *consistent with the data* but cannot be *statistically supported* at N=25.
2. **H6 (Olsonian concentration) is essentially zero signal** (vine × parcel_area = +394.34, p=0.872). Direction is right, magnitude is dwarfed by the SE.

Both nulls are **lack of power, not falsification**. With N=25 and one interaction term, an OLS test needs |t| > ~2.07 for significance; H3 produced |t| ≈ 0.79 (STRAT) / 0.79 (ALT), H6 produced |t| ≈ 0.16. We are deep into "the data cannot tell us" territory, not "the data tells us no."

Implications for downstream tasks below.

---

## Implication for Task C.5 (Language Cleavage Index)

**Don't reframe C.5; do reframe its caption framing.**

The strategist's original C.5 motivation depended partly on H3 holding (the variance-decomposition story for the cleavage index assumed the moralist-coalition interaction would amplify the wine-industry effect along Protestant lines). With H3 null, the **mechanical-language story** from Gelbach (LANG channel ≈ 99% of the Simpson sign-flip; t15) becomes the load-bearing claim, and the moralist-coalition narrative shifts from "supported mechanism" to "unfalsified theoretical motivation."

### Concrete recommendations for C.5

1. **Keep the cleavage-index construction as planned** (`08_taskC5_cleavage_index.md`). The empirical content is unchanged: the index measures how much of cross-vote variation in yes-shares is explained by the canton's position on the language-religion cleavage. That's a descriptive measurement, not a hypothesis test.

2. **Revise the t19 caption** to lead with the Gelbach-confirmed language story rather than the coalition story. Suggested framing:
   > The language cleavage explains ~XX% of cross-canton variation in yes-share on the absinthe ban (#68), consistent with the Gelbach decomposition (t15) attributing 99% of the Simpson sign-flip to the language confound. Religion contributes negligibly to coefficient stability and does not appear to modulate the wine-industry effect (Table~\ref{tab:formal_hypotheses}, columns 2/4); the language cleavage is the dominant cultural channel.

3. **Mention H3 honestly** in either the t19 footnote OR the paper-body text immediately after t19: "We tested whether the wine-industry effect is amplified by Protestant share (Table 17 col 2) but cannot reject the null at conventional levels. The cleavage-index work documents *cleavage as a structural feature of vote dispersion*, not as a *moderator of the wine-industry effect*."

4. **Do NOT delete or downplay the coalition-mechanism theoretical exposition** in the introduction. B&B + Becker (1983) is still the right theoretical framing — we just acknowledge that with N=25, we can't distinguish coalition strength from the broader cultural confound. This is honest, defensible, and doesn't weaken the paper.

### What NOT to do for C.5

- ❌ Add new specifications hoping H3 will "show up" with different controls. We tested it; it's null at N=25; that's the answer until more data exists.
- ❌ Strip out all coalition framing. Reframing as "mechanism not testable here" is fine; pretending the framing didn't exist would be revisionist.
- ❌ Lean on H3 ALT's tighter SE as evidence for the hypothesis. Both STRAT and ALT are null; ALT just has cleaner main effects.

---

## Implication for Task C.6 (Differential Mobilization)

**Proceed with C.6 as planned. C.6 ≠ H6 substantively; it tests a different mechanism on a different outcome with a different identification strategy.**

This is the user's open question, expanded:

### What H6 tested vs what C.6 tests

| Dimension | H6 (Task B.2) | C.6 (Task C.6) |
|---|---|---|
| Outcome | `yes_pct` (intensive margin: vote-share among voters) | `turnout_dev` and `turnout_lang_gap` (extensive margin: who voted) |
| Treatment | `vineyard_per_cap × avg_parcel_area_1905` (interaction) | `vineyard_per_cap` (main effect) + `french_share` (main effect) |
| Identification | Cross-canton interaction at N=25; tests *moderation* | Mix: (a) N=25 cross-canton OLS for turnout_dev, (b) **N=375 cross-vote panel** for turnout-gap z-score |
| Theoretical mechanism | Olsonian: concentrated industries lobby more effectively → bigger wine effect on the *vote share* | Cultural-political mobilization: French cantons turned out *more than usual* on absinthe ballot day → bigger French *participation* |
| Predicted by B&B framework? | Yes (Olsonian rent-seeking efficiency) | Independent of B&B mechanism. Compatible with cultural identity, religious-political mobilization, language-bloc voting. |

### Why C.6 is independent of H6

H6 asks: "Does the wine-industry vote-share effect get *bigger* in cantons with more concentrated agricultural land?" The data: no detectable moderation (p=0.87, effectively zero signal).

C.6 asks: "Did the *cultural* (French/German) divide produce *anomalous turnout patterns* on the 1908 ballot day, distinct from the wine-industry vote-share effect?" The data (per the Python pipeline preview in the C.6 handoff): the typical French-German turnout gap of −15 to −25 pp collapsed to +1.5 pp on the absinthe ballot, a 17-point swing seen in *no other vote in the 1900-1910 panel*. This is a **descriptive panel pattern** with much higher statistical leverage than H6.

The key conceptual point: **H6 and C.6 are testing different theoretical mechanisms on different outcomes**. H6's null doesn't update us on whether C.6's pattern is real, because the underlying causal questions are non-overlapping:
- H6: does industry concentration moderate rent-seeking effectiveness on vote-share?
- C.6: did cultural-political mobilization differentially activate French cantons on absinthe ballot day?

### Power analysis for C.6 vs H6

This is the user's worry — that "no support" might just be "no power." Honest assessment:

**H6 power**: at N=25 with one interaction term, the minimum detectable effect (MDE) for a two-sided 5% test with 80% power is roughly `2.8 × SE` ≈ 2.8 × 2407 ≈ +6,800 on the interaction. We observed +394 — about 17× too small to be detectable. Even a one-SD increase in concentration (≈0.2 ha/parcel) producing a vine slope shift of +1,360 (an enormous economic effect) would be at the edge of detection. **H6 was always going to be underpowered at N=25.** The null is uninformative.

**C.6 power, broken down by sub-test**:

1. **C.6.1 cross-vote turnout-by-language table (z-score test)**: This compares the absinthe-ballot turnout-gap to the distribution of turnout-gaps across 14 other votes. Effective N for the *baseline* is 14 votes × variability = relatively tight prior. The *target effect* (gap_68 = +1.5 pp vs other-day mean ≈ −18 pp ± 5 pp SD) gives a z-score around +3.9 — well into "this did not happen by chance" territory. **This sub-test is highly powered.**

2. **C.6.2 turnout-deviation regression (`turnout_dev ~ vine + french`)**: This is N=25 cross-section, so power IS limited like H6. But: (a) it tests a *main effect* not an interaction (one fewer term to identify), (b) the Python pipeline preview gives R²=0.262 with constant ≈ −10*** (highly significant) and french_share ≈ +14 (p≈0.12, marginally significant). The constant alone confirms differential turnout exists; the regression decomposes it. **Power is moderate; the constant + french coefficient are the load-bearing inferences. The vine_per_cap coef being null is *expected* (wine industry didn't drive turnout), not a power failure.**

3. **C.6.3 same-day differential figure (descriptive)**: A bar chart of per-canton turnout differences between vote #67 (commerce) and vote #68 (absinthe) — same day, same voters. This is *purely descriptive*; no inference test. Six cantons (GL, SG, SH, BE, BS, GR) show differentials > 5 pp per the strategist preview. The chart itself is the evidence. **No power concern — descriptive.**

### Distinguishing "lack of support" from "evidence of lack" — at risk where in C.6?

| C.6 sub-test | Risk of "no power masquerading as no effect"? |
|---|---|
| C.6.1 z-score | LOW — high statistical leverage from 14-vote panel; clear z-score interpretation |
| C.6.2 turnout_dev regression | MODERATE on `vine_per_cap` (N=25, but expected null is consistent with theory); LOW on `french_share` (Python preview shows real signal) |
| C.6.3 same-day figure | NONE — descriptive only |

The honest framing for C.6's results: the **panel-based and descriptive evidence is strongly powered** and the **regression-based evidence is power-limited but consistent with the panel evidence**. Together they constitute a "complementary mechanism" finding rather than a definitive single-test claim.

### What to report in C.6 vs what to keep cautious about

**Strong claims (defensible)**:
- "On the absinthe ballot day, the typical French-German turnout gap collapsed by ~17 percentage points, a swing not seen on any other vote in the 1900-1910 panel."
- "The cantonal pattern of turnout deviation favored French-speaking cantons (NE, SO, VD, GE) by 5-20 pp above their baselines."
- "The same-day differential between vote #68 (absinthe) and vote #67 (commerce) shows several German cantons mobilized *more* on the absinthe ballot, isolating absinthe-specific drivers within otherwise-identical voting conditions."

**Cautious claims (with caveats)**:
- "vineyard_per_cap does not predict turnout deviation" (caveat: N=25, may be underpowered for moderate effects, but the effect-size we *would* expect from the wine-industry mechanism is *no* turnout differential — wine cantons should show normal turnout patterns, not anomalous ones).
- "french_share is marginally associated with positive turnout deviation" (caveat: p≈0.12 in N=25 OLS; the panel evidence in C.6.1 is the stronger version of the same claim).

**Don't claim**:
- "The Olsonian channel is rejected" — H6 was underpowered, not falsified.
- "Wine-industry interests didn't mobilize turnout" — what we have is "no detectable effect on turnout deviation in N=25 OLS"; this is consistent with both "no effect" and "small effect we can't detect." Safe phrasing: "we find no evidence of a wine-industry mobilization channel; the cultural-political channel dominates."

---

## Implication for paper framing (overall)

The paper now has FOUR mechanism families, with varying degrees of empirical support:

| Mechanism | Operationalized as | Empirical support |
|---|---|---|
| Wine-industry rent-seeking (intensive margin) | `vineyard_per_cap` coef in KEY spec | **Strong** — +484 (p<0.05), survives 28+ robustness checks |
| Language cleavage as confound | Gelbach LANG δ | **Strong** — 99% of Simpson sign-flip |
| Cultural-political mobilization (extensive margin) | C.6 turnout pattern | **Moderate-strong** (panel z-score + descriptive figure); regression weaker |
| Moralist coalition (B&B coalition mechanism) | H3 interaction | **Untestable at N=25** — direction consistent, significance absent |
| Olsonian industrial concentration | H6 interaction | **Untestable at N=25** — essentially no signal |

The paper structure should foreground the first three (well-supported) and present H3/H6 as *theoretically motivated tests that the available data cannot resolve*. This is more credible than overclaiming the nulls as falsifications.

---

## Process notes for downstream sessions

1. **Read this file before reading `08_taskC5_cleavage_index.md` or `09_taskC6_mobilization.md`.** This file modifies the framing recommendations in those handoffs based on Task B results.

2. **The handoff files themselves are not edited** to reflect this — they are the original task specs. This notes file is the addendum.

3. **When writing C.5 captions and C.6 captions**, refer to this file's "concrete recommendations" sections.

4. **If H3 is reframed in the paper text** (per recommendation #3 above), record the reframe via `/major-change` so the intellectual history is preserved.

---

## Provenance

- Origin: 2026-05-01 user dispatch following Task B commits `a6d3b91` (initial Task B) and `fd203d0` (dual-spec restructure)
- Task B handoff: `analysis/documentation/handoffs/round2/03_taskB_formal_hypotheses.md`
- Task B results: see commits above; t17_formal_hypotheses.tex (main) and t17b_formal_hypotheses_alt.tex (backmatter)
- Related progress notes: see `analysis/documentation/progress/progress_2026-05-01_*` (pending creation per user dispatch)

This notes file is intentionally NOT a `progress_*` major-change note — it is a working framing document for in-progress tasks. The major-change notes will capture the singular findings (H3/H6 nulls, design defect discovery) for permanent record.
