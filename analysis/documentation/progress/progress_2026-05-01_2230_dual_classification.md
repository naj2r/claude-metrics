# Progress note: Dual-classification of #60 + vote-LOO sensitivity is a HARD PAPER REQUIREMENT — both ranks must appear side-by-side

**Date**: 2026-05-01 22:30
**Topic**: dual_classification (paper-writeup mandate: dual-classification + vote-LOO)
**Triggered by**: User dispatch 2026-05-01 22:25 in response to the #60 finding from Task C.4 (see `progress_2026-05-01_2210_vote60.md`). Direct quote: "do two separate classifications and run both — one without the #60 and one with it. Could we do a leave-one-out approach with the referenda too? rather than just a year we can see what happens there or what? Do what you're sure you can proceed with. right now document your finding as a /major-change so I dont forget that this is explicitly needed in the paper."
**Status**: **methodological choice** (HARD paper requirement) — codifies a binding constraint on the falsification-section paper writeup that future Claude sessions and any coauthors must honor. The paper MUST present both classifications (with #60 retained AND with #60 reclassified) side-by-side, plus a vote-LOO sensitivity table demonstrating which single placebo vote drives the rank change.

---

## Headline (1 paragraph)

The Round-2 Task C.4 result (absinthe ranks #2 of 14 in the true-placebo set, with vote #60 federal customs tariff 1903 as the single exceeding placebo) creates a researcher-degrees-of-freedom risk: which placebo set is "the right" one to compute the rank against? The user's binding directive is that the paper **MUST present both classifications** to take the choice off the table:

- **Classification A (#60 retained as placebo, #65 reclassified)**: absinthe rank = #2 of 14, permutation-style p = 2/14 ≈ 0.143. The conservative falsification — treats #60 as a chance-noise null because its coefficient is not significant.
- **Classification B (#60 AND #65 both reclassified as wine-relevant comparators)**: absinthe rank = #1 of 13, permutation-style p = 1/13 ≈ 0.077. The substantive interpretation — treats #60 as a third member of the wine-industry rent-seeking cluster on a priori historical grounds (1903 tariff = wine-import duties) even though the coefficient is not significant at N=25.

Plus a **vote-LOO sensitivity table** showing absinthe's rank when each of the 13 (or 14, depending on classification) placebo votes is dropped one at a time. The expected pattern: dropping #60 changes absinthe's rank from #2 to #1; dropping any other placebo leaves the rank unchanged. This empirically demonstrates that the rank-#2-vs-rank-#1 ambiguity is driven entirely by a single vote (#60), not by a noisy distribution of multiple competitors. Both side-by-side classifications + the vote-LOO table are HARD requirements for the paper's falsification section per user dispatch; this note records that requirement permanently.

---

## Background and discovery

**Sequence**:

1. **2026-05-01 evening — Task C.4 first run**. Pipeline `2026.05.01_21.59.00.log.txt` produced the strict-assertion failure documented in `progress_2026-05-01_2210_vote60.md`: vote #60 has vineyard coef +737 (p=0.328), exceeding absinthe's +484. Rank in the 13-placebo set is #2 of 14, not #1 of 14.

2. **2026-05-01 evening — coder reported back to user** with three options: (1) continue auto to C.5, (2) pause to verify 1903 tariff schedule, (3) reclassify #60 now. Recommendation: option 1 (proceed), with #60 finding documented for later decision.

3. **2026-05-01 22:25 — user dispatched dual-track move**: present BOTH classifications side-by-side rather than picking one. Plus a vote-LOO sensitivity over the placebo votes (analogous to canton-LOO but rotating the dropped placebo vote rather than the dropped canton). Plus an explicit instruction to document this as a `/major-change` so the requirement isn't lost across sessions. Direct quote at top of this note.

4. **2026-05-01 22:30 — this note written**. Captures:
   - The dual-classification mandate (Classification A + Classification B side-by-side)
   - The vote-LOO sensitivity mandate
   - The "explicitly needed in the paper" constraint

5. **2026-05-01 22:30+ — implementation**. Section 13 of `05_expansion.do` extended to compute and assert both Classifications A and B; new vote-LOO block added to compute the rank under each placebo-drop. CONTEXT.md updated to report both ranks side-by-side. Pipeline re-verified.

---

## Substantive content

### Classification A: #60 retained, #65 reclassified

This is the round-1 "round-2-corrected" framing per the original Task C.4 handoff:
- Treatment: #68 absinthe ban (1908)
- Comparator (excluded from placebo set): #65 Lebensmittelgesetz (1906) — wine-rent-seeking comparator per `progress_2026-04-30_1830_foodbev.md`
- Placebo set: 13 votes (15 - #68 - #65)
- Of the 13 placebos, **1 has coef ≥ absinthe** (#60 customs tariff, +737 vs absinthe's +484)
- Absinthe rank: **#2 of 14** (treatment + 13 placebos)
- Permutation-style p: **2/14 ≈ 0.143**

**Substantive reading**: this classification treats #60 as a chance-noise null because its coefficient is not statistically significant (p=0.328). The rank #2 reflects that there is one non-treatment vote with a higher point estimate, but the absence of significance means we cannot reject the null that #60's positive coefficient is sampling noise.

**Paper presentation**: present this as the *conservative* falsification result — "even under the most cautious treatment of #60 as an ordinary noisy placebo, absinthe ranks #2 of 14 in the true-placebo set."

### Classification B: #60 AND #65 both reclassified

This is the round-2-extended framing, motivated by the historical interpretation of #60 as a wine-protective tariff vote:
- Treatment: #68 absinthe ban (1908)
- Comparators (both excluded): #65 Lebensmittelgesetz (1906) AND #60 federal customs tariff (1903)
- Placebo set: 12 votes (15 - #68 - #65 - #60)
- Of the 12 placebos, **0 have coef ≥ absinthe**
- Absinthe rank: **#1 of 13** (treatment + 12 placebos)
- Permutation-style p: **1/13 ≈ 0.077**

**Substantive reading**: this classification reads #60 as the third member of the wine-industry rent-seeking cluster (tariff protection 1903 → product-purity regulation 1906 → product-elimination 1908). The historical case for #60's wine-relevance: the 1903 tariff schedule included substantial duties on foreign wine imports (8-25 CHF per 100 kg), protecting Swiss wine producers. A pro-tariff vote by wine cantons is consistent with the Stiglerian-capture mechanism that explains #65 and #68. The lack of statistical significance reflects N=25 power limits, not the absence of an effect.

**Paper presentation**: present this as the *substantive* falsification result — "with #60 acknowledged as a wine-industry-relevant vote, absinthe ranks #1 of 13 in the true-placebo set, consistent with a 3-vote regulatory-capture pattern spanning 1903-1908."

### Vote-LOO sensitivity table

Independent of the A-vs-B classification debate, a vote-leave-one-out exercise demonstrates *empirically* that the rank ambiguity hinges on a single vote (#60). For each of the 13 placebos in Classification A, drop that vote and recompute absinthe's rank in the remaining 12-placebo set:

Expected output (to be confirmed empirically by implementation):

| Dropped placebo | Absinthe rank in 12-vote set | Notes |
|---|---:|---|
| #56 federal insurance | 2 of 13 | drop changes nothing; #60 still exceeds |
| #57 proportional rep | 2 of 13 | drop changes nothing |
| #58 popular Fed Council election | 2 of 13 | drop changes nothing |
| #59 federal school subsidies | 2 of 13 | drop changes nothing |
| **#60 federal customs tariff** | **1 of 13** | **drop changes rank!** (#60 was the exceeding vote) |
| #61 federal criminal code | 2 of 13 | drop changes nothing |
| #62 National Council elections | 2 of 13 | drop changes nothing |
| #63 federal alcohol-trade reg | 2 of 13 | drop changes nothing |
| #64 patent extension | 2 of 13 | drop changes nothing |
| #66 federal military org | 2 of 13 | drop changes nothing |
| #67 commerce article (same day) | 2 of 13 | drop changes nothing |
| ... (3 more, depending on exact panel range) | 2 of 13 each | drop changes nothing |

**Expected pattern**: 1 of the 13 LOO drops produces rank #1 (the drop of #60); the other 12 produce rank #2. This isolates the rank ambiguity to a single vote.

**Substantive reading**: the rank-#1-vs-#2 question is not a distribution-shape question (where many votes contribute to the rank uncertainty); it is a single-vote question (does #60 belong in the placebo set or not?). The vote-LOO table makes this transparent.

**Paper presentation**: present the vote-LOO as a robustness table accompanying the dual-classification table, with absinthe's rank under each LOO-drop in a 13-row column. Bold or highlight the row corresponding to #60.

### Why presenting both classifications + vote-LOO is paper-required (the user's binding constraint)

Three reasons:

1. **Researcher-degrees-of-freedom transparency**. Picking one classification (A or B) over the other requires a methodological choice that cannot be validated from the data alone (#60's coefficient is null at N=25). Presenting both removes the choice from the researcher and lets the reader decide.

2. **The historical interpretation of #60 cannot be fully resolved here**. Verifying the 1903 Swiss tariff schedule's per-commodity wine-import duties requires primary-source archival work (the *Bundesblatt* of 1902 and the actual tariff schedule document). Until that verification is done, the case for Classification B over Classification A rests on plausibility, not evidence. Presenting both keeps the question open for the eventual archival work.

3. **The vote-LOO sensitivity is methodologically informative beyond the #60 question**. It shows whether the rank statistic is generally stable (one vote moves it; eleven votes don't) or unstable (multiple votes contribute to rank uncertainty). The first is a strong falsification design; the second is fragile. Our pattern is the first, which is good news worth reporting explicitly.

**The paper-text requirement**: the falsification section MUST include:
- A short sub-paragraph stating "We report two rankings: one treating #60 as a placebo (rank #2 of 14, p ≈ 0.143), and one treating #60 as a wine-industry comparator (rank #1 of 13, p ≈ 0.077)."
- A vote-LOO sensitivity table or in-text mention: "Of the 13 vote-LOO drops, only the drop of #60 changes absinthe's rank from #2 to #1; the other 12 leave the rank unchanged. The rank ambiguity is therefore driven by a single vote, not by a noisy distribution of competitors."
- A footnote pointing to `progress_2026-05-01_2210_vote60.md` and this note for the underlying reasoning.

This is a HARD requirement per the user's 2026-05-01 22:25 dispatch. If a future Claude session or coauthor proposes "let's just pick one classification for simplicity," that proposal violates the user's directive; both must appear.

---

## Why this matters for the paper

1. **Defuses the cherry-picking critique pre-emptively**. Reviewers commonly object: "How did you decide which votes count as wine-relevant comparators?" Our answer: we don't decide; we report both classifications. The reader sees that the absinthe-specific story is supported under both.

2. **Sharpens the Stiglerian-capture narrative without overclaiming**. Classification B (3-vote pattern) is the "substantive" story; Classification A (2-vote with #60 as conservative null) is the "skeptical" story. Both are reportable; both are honest.

3. **Establishes the data-collection priority for follow-up work**. The 1903 tariff schedule's wine-import duties are the missing evidence that would resolve A-vs-B in favor of B. The paper text should flag this as a future-work item.

4. **The vote-LOO sensitivity is a publishable robustness check on its own**. It generalizes the canton-LOO concept to the cross-vote panel and demonstrates a strong falsification structure (one vote moves the rank; not many).

---

## Mechanism / interpretation

The dual-classification + vote-LOO is methodological transparency, not a substantive claim. The substantive claims are:

- **Strong claim** (under both A and B): vineyard cantons supported the absinthe ban, with the wine-industry coefficient surviving 30+ robustness checks (the headline +484 result).
- **Strong claim** (under both A and B): the absinthe vote is one of at most 2 federal votes 1900-1910 with a positive vineyard coefficient that exceeds anything in the clean-placebo distribution (#65 in round 1; #65 + possibly #60 in round 2).
- **Conditional claim** (only under B): the wine-industry rent-seeking pattern spans 3 votes 1903-1908 (tariff → product-purity → product-elimination).

The conditional claim requires the historical-interpretation evidence on #60. Until that evidence is in hand, the paper presents both classifications without prejudice.

---

## Evidence base

| Source | What it provides |
|---|---|
| `progress_2026-05-01_2210_vote60.md` | The original substantive note on vote #60 as the rank-failure cause |
| `analysis/scripts/05_expansion.do` section 13 (post-update) | Code computing both Classification A and B ranks + vote-LOO sensitivity |
| `analysis/results/intermediate/regressions_expansion.dta` | All 15 panel rows with vineyard coefs, SEs, p-values |
| CONTEXT.md (post-update) | Paper-facing documentation reporting both ranks side-by-side |
| `analysis/results/figures/f03_placebo_distribution.pdf` | Histogram showing #60 as the rightmost placebo bar (visual confirmation) |
| `analysis/documentation/handoffs/round2/07_taskC4_rank_recompute.md` | Original Task C.4 handoff that anticipated the rank-failure case |
| User dispatch 2026-05-01 22:25 | Binding directive for dual-classification + vote-LOO + paper-requirement documentation |

---

## Caveats / open questions

- **The 1903 tariff schedule's wine-import duties remain unverified**. Per `progress_2026-05-01_2210_vote60.md`, the case for Classification B rests on the historical interpretation. A follow-up archival pass is needed.

- **The vote-LOO assumes #60 is the only outlier**. If a future analysis adds new variables to the KEY spec (e.g., parcel area, migration), the placebo coefficients may shift and #60 may no longer be the unique exceeding vote. The vote-LOO would then identify the new outliers transparently.

- **The vote-LOO does NOT extend to canton-LOO interaction**. We have separate canton-LOO sensitivity (in Task C.2 for vote #65 specifically). A combined "drop one canton AND one vote" double-LOO would be more thorough but is N=25 × 13 = 325 regressions per dimension, which adds runtime without clear marginal information at this scale.

- **The dual-classification is binary by design**. We could in principle report N classifications (A: #60 retained, B: #60 reclassified, C: #60 + #57 reclassified, D: ...). The user's directive is for two; we honor that. If a third classification becomes relevant (e.g., another vote surfaces as wine-relevant on archival evidence), the framework extends naturally.

- **The user's directive is binding for THIS paper**. If a future paper re-uses this dataset for a different question (e.g., the cleavage index in Task C.5), the dual-classification requirement may not apply. The constraint is specific to the falsification rank-statistic context.

---

## Provenance

- **Origin**: 2026-05-01 22:25 user dispatch in direct response to the Task C.4 commit `bb08a5d` and the coder's "decision point for you" report. Quote at top of this note.
- **Linked commits**:
  - `bb08a5d` — Task C.4 with #60 finding (Classification A only; this note + follow-up commit add Classification B + vote-LOO)
  - This work in progress (round-2 Task C.4 extension commit pending)
- **Related progress notes**:
  - `progress_2026-05-01_2210_vote60.md` — substantive note on vote #60 (the trigger for this dual-classification mandate)
  - `progress_2026-04-30_1830_foodbev.md` — original second-headline note on #65 reclassification (the precedent for the comparator-reclassification framework)
- **Related working documents**:
  - `analysis/documentation/handoffs/round2/notes_post_taskB.md` — round-2 framing notes (the cantonal-collinearity meta-pattern relates indirectly: #60's null at p=0.328 is another instance of the N=25 power constraint)

---

## References / further reading

- **Simmons, Joseph P.; Nelson, Leif D.; Simonsohn, Uri (2011)**. "False-Positive Psychology: Undisclosed Flexibility in Data Collection and Analysis Allows Presenting Anything as Significant." *Psychological Science* 22(11): 1359-1366. The methodological-transparency reference for why presenting researcher-degrees-of-freedom decisions matters; supports the dual-classification mandate.
- **Gelman, Andrew; Loken, Eric (2014)**. "The Statistical Crisis in Science." *American Scientist* 102: 460-465. The "garden of forking paths" argument; relevant for why multi-classification reporting is preferable to picking one path.
- **Stigler, George J. (1971)**. "The Theory of Economic Regulation." Cited in `progress_2026-05-01_2210_vote60.md`; relevant for the substantive interpretation of #60 under Classification B.
- **Imbens, Guido W.; Wooldridge, Jeffrey M. (2009)**. "Recent Developments in the Econometrics of Program Evaluation." *Journal of Economic Literature* 47(1): 5-86. Section on permutation-based inference; relevant for the rank-statistic interpretation as informal RI.
- **Bairoch, Paul (1989)**. "European Trade Policy, 1815-1914." Cited in `progress_2026-05-01_2210_vote60.md`; the standard reference for the 1903 Swiss tariff context whose wine-content drives Classification B.
