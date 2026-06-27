# Progress note: Engineering review of C.6 framing — three caveats and a meta-pattern (cantonal collinearity recurrence)

**Date**: 2026-05-01 20:35
**Topic**: c6_caveats (engineering pushback on the post-Task-B C.5/C.6 framing; pre-emptive paper-writeup refinements)
**Triggered by**: Strategist engineering-review feedback delivered by user 2026-05-01 evening, accepting the H6/C.6 distinction and the C.6 plan as fundamentally correct but flagging three places where the coder's framing was slightly oversold or under-specified. Noted as paper-writeup refinements, not blocking issues for Task C.1 dispatch.
**Status**: **methodological choice** — codifies three pre-emptive paper-writeup constraints and one meta-pattern (cantonal collinearity recurrence) that should be honored in all subsequent round-2 task implementations.

---

## Headline (1 paragraph)

The strategist's engineering review of the post-Task-B C.6 explanation accepted the substantive structure (intensive-vs-extensive margin distinction is correct, sub-test power decomposition is directionally right, paper-framing summary is honest) but flagged **three framing refinements** that need to land in the paper writeup: (1) C.6.1's z-score should be described as "high effect size detected with adequate panel leverage" rather than "HIGH power" (the proper inference is a one-sample t-test against 14 baseline votes, not a normal-approximation z); (2) C.6.2 has a wine-language collinearity (`vineyard_per_cap` and `french_share` share variance because in 1900 Switzerland wine cantons ≈ French cantons: Vaud, Valais, Geneva, Neuchâtel produce the wine, only Schaffhausen and Zurich/Aargau/Thurgau partially break the pattern), structurally analogous to the H3 catholic/protestant collinearity caught in Task B and meriting the same dual-spec or explicit-caveat treatment; (3) the same-day ballot nuance was under-treated — vote #67 (commerce) shows gap = +4.7 pp on the same day as #68, so the gap collapse is technically an *absinthe-ballot-day phenomenon* not strictly an *absinthe-vote phenomenon*. Plus a meta-pattern flagged: **collinearity issues will keep emerging in subsequent tasks** because the cantonal data has many near-collinear demographic dimensions in 1900 Switzerland (Catholic-Protestant, French-German, French-wine, mountain-Catholic, etc.) — each one needs the same careful treatment given to the H3 religion case.

---

## Background and discovery

**Sequence**:

1. **2026-05-01 evening (this repo).** Coder completed Task B (commits `a6d3b91`, `fd203d0`, `81e3256`) and reported H3/H6 nulls to user. The coder's report included a "STOP GATE" message with H3/H6 numbers and a recommendation framework for downstream Tasks C.5 and C.6, including the claim that C.6 is independent of H6 because it tests a different mechanism on a different outcome.
2. **2026-05-01 evening (this repo).** User asked for a deeper substantive explanation of C.6 (power vs identification distinction). Coder produced an explanation with three sub-test power decomposition (C.6.1 cross-vote panel = "HIGH" power; C.6.2 N=25 regression = moderate power; C.6.3 descriptive figure = no inference test).
3. **2026-05-01 evening (this repo).** Strategist engineering review (relayed via user) accepted the explanation as fundamentally correct and ready to greenlight for C.1 dispatch but flagged the three framing concerns above, marking them as paper-writeup refinements rather than execution blockers. Strategist also noted a meta-pattern: collinearity issues will recur because of the cantonal data structure.
4. **2026-05-01 evening — this note.** User dispatched a `/major-change` entry capturing the attenuated language and nuance, plus a `/update-codebook` to sync the latest dataset metadata. This note is the major-change record.

**Why this matters enough for a permanent note**: the three refinements would otherwise live only in chat transcripts and risk being forgotten at paper-writeup time, when the original framing might be re-stated verbatim. The meta-pattern (collinearity recurrence) is a *forward-looking constraint* on Tasks C.5 and C.6 implementation that needs to be in the project's permanent intellectual record so future Claude sessions see it without a re-discovery cycle.

---

## Substantive content

### Caveat #1 — C.6.1 inference framing: high effect size, not "high power"

**Coder's original framing** (in the C.6 explanation message to user, 2026-05-01 ~20:00):
> *C.6.1 — Cross-vote turnout-by-language table (z-score test). [...] z-score ≈ +3.9 — well into "this did not happen by chance" territory. **This sub-test is highly powered.***

**Strategist's correction**:
> The z ≈ 3.9 is a large *effect size* detected in a small sample (14 baseline votes). That's convincing because the effect is huge, not because the test has high power in the abstract. With only 14 baseline observations, the SD of the gap distribution is estimated with noise; the proper inference is a one-sample t-test against the 14-observation baseline distribution, not a normal-approximation z-score.

**The technical issue**: a "z-score" computed as `(gap_68 - mean_other) / sd_other` is only normally distributed when `mean_other` and `sd_other` are population parameters. With 14 observations, `sd_other` is itself a random variable (estimated with `√(2/13) ≈ 0.39` relative SE on the SD itself), and the test statistic follows a distribution closer to t(13) under the null (and only approximately, because the variance ratio is non-trivial). The conclusion still holds — t(13) at 3.9 is p ≈ 0.0017, still strongly significant — but the language must distinguish:

- ✗ "High statistical power" implies the test would detect a smaller effect if one existed. With N_baseline = 14, MDE at 80% power is roughly t-crit × SE(gap) ≈ 2.16 × ~5pp ≈ 11pp. The observed gap collapse of 17pp is well above MDE; it would have been *detected even if smaller*. So "adequate power for the effect we observed" is honest.
- ✓ "High effect size detected with adequate panel leverage" emphasizes that what makes the conclusion strong is the *magnitude of the observed swing* (17pp out of typical 15-25pp gaps), not a high a priori detection probability.

**Forward-looking constraint for C.6 implementation**: when reporting C.6.1 in t20 caption and the paper text, use one-sample t-test framing against the 14-baseline-vote distribution, not normal-approximation z. If a z-score is also reported (for back-compatibility with the strategist's preview), pair it with the t-test p-value.

### Caveat #2 — C.6.2 wine-language collinearity is structurally analogous to H3 religion collinearity

**The structural fact**: in 1900 Switzerland, the four French-language cantons Vaud, Valais, Geneva, and Neuchâtel together account for the overwhelming majority of national vineyard area. Approximate vineyard-share data from `processed/intermediate/vineyard_uncleaned.dta` (1905 row):

- VD (Vaud): ~6,000 ha vineyard, French
- VS (Valais): ~3,500 ha, French (and Italian)
- GE (Geneva): ~1,500 ha, French
- NE (Neuchâtel): ~700 ha, French
- TI (Ticino): ~7,000 ha, Italian (some bilingual)
- SH (Schaffhausen): ~700 ha, German (the main German-speaking break)
- ZH/AG/TG: ~500-1,500 ha each, German (modest German breaks)

So wine cantons are not perfectly French (TI is Italian; SH/ZH/AG/TG break the pattern), but the correlation between `vineyard_per_cap` and `french_share` is high (Pearson roughly +0.55-0.65 in this dataset, depending on sample restrictions).

**Implication for C.6.2 regression** `reg turnout_dev vineyard_per_cap french_share, vce(hc3)` (and the `+ catholic_share` and `+ catholic_share + net_migration + ln_pop` variants):

- The Python pipeline preview gave: vine ≈ +153 (n.s., t≈0.59), french_share ≈ +14 (p≈0.12, marginal).
- The coder's original framing implied: "wine industry did not mobilize differential turnout." A more accurate statement: "we cannot separately identify wine-industry mobilization from French-cultural mobilization in N=25 cross-section because the two regressors share variance."
- Just as in H3 STRAT vs H3 ALT (Task B), the joint inclusion of two highly-correlated regressors inflates SEs on the affected variables, making it harder to attribute the effect to either separately. The vine null at p=0.557 is *conditional on french_share absorbing the overlapping variance*; if `french_share` were dropped from the spec, the vine coefficient would likely be non-null (because then it would soak up all the cultural-mobilization variance).

**Forward-looking constraint for C.6 implementation**: when reporting C.6.2 in t21 / paper text, the wine-null framing must include the explicit caveat. Suggested phrasing:

> "Conditional on French-language share, vineyard density does not predict turnout deviation (β = +153, p = 0.557). This null is conditional: in 1900 Switzerland, French-language cantons (VD, VS, GE, NE) produced the bulk of the country's vineyard area, so vineyard density and French share are highly correlated (r ≈ 0.6 in our N=25 sample). The N=25 cross-section cannot separately identify wine-industry mobilization from French-cultural mobilization on turnout. The cross-vote panel evidence (Table 20, z-score = +3.9 against 14 baseline votes) provides higher-leverage evidence on the cultural-mobilization channel."

**Optional**: A dual-spec presentation of C.6.2 (analogous to t17 main + t17b backmatter) could report (a) the joint spec with both vine and french as in the strategist preview, and (b) a spec dropping french_share to see whether vine then absorbs the variance. This would make the identification limit fully transparent. **Recommendation: implement the dual-spec variant in C.6.2 if time allows; at minimum, the caption caveat above is required.**

### Caveat #3 — Same-day ballot nuance: vote #67 also shows gap collapse

**The structural fact**: the strategist's preview (`09_taskC6_mobilization.md` line 17) explicitly notes that vote #67 (commerce article, July 5 1908, same day as absinthe ban #68) shows gap = +4.7 pp — also an anomalous collapse of the typical −15 to −25 pp French-German turnout gap, though smaller than #68's +1.5 pp gap. The two votes were on the same ballot, voted by the same electorate.

**Coder's original framing** (in the C.6 explanation message to user, 2026-05-01 ~20:00):
> *Did French cantons turn out more than usual on absinthe ballot day?*

This phrasing implies absinthe-specific drivers. But mechanically, the gap-collapse is a *ballot-day* phenomenon: voters who showed up on July 5 1908 voted on both items. We cannot from #68 alone distinguish "absinthe drove the mobilization" from "commerce drove the mobilization" from "some unrelated ballot-day cultural moment drove both."

**Strategist's correction**:
> Vote #67 (commerce) shows gap = +4.7 on the same day as #68. So the gap collapse is technically an *absinthe-ballot-day phenomenon*, not strictly an *absinthe-vote phenomenon*. [...] The coder's framing implies absinthe-specific mobilization without addressing whether commerce could have driven it (almost certainly not — commerce was a bland article — but it should be argued, not assumed).

**Forward-looking constraint for C.6 implementation**: t20 / t21 / f06 captions must distinguish the two interpretive questions:

1. **Was July 5 1908 a high-mobilization day for French cantons?** (Yes — both #67 and #68 show gap collapse.)
2. **Was that mobilization driven by absinthe specifically?** (Indirectly — the magnitude difference is meaningful: +1.5 pp on absinthe vs +4.7 pp on commerce, so absinthe attracted *additional* voters above the commerce-only baseline; but the same-day-ballot-day phenomenon means we can't fully separate the two items as drivers.)

The argument that commerce did NOT drive the mobilization should be made explicitly in the paper:
- Commerce article #67 was a "bland" constitutional clarification of federal trade legislation authority — not the type of mobilizing issue that would draw out cultural-political turnout.
- The differential between #68 and #67 (per-canton turnout gap of `turnout_68 − turnout_67`) shows several cantons had absinthe-specific *additional* turnout (per the strategist preview: GL +11.9, SG +7.6, SH +7.3, BE +6.9, BS +6.8, GR +5.7).
- The cross-vote panel (#56-#74) singles out *both* #67 and #68 as anomalous July 5 1908 ballot-day votes; no other day in 1900-1910 produced a cluster of two co-occurring anomalies.

**Suggested t20 caption addition** (to the strategist's draft caption already in `09_taskC6_mobilization.md` line 156):
> "The collapse is a same-day phenomenon — voters who showed up to vote on absinthe also voted on the same-day commerce item — but isolates the specific ballot day on which French-Swiss mobilization was anomalously high. The differential turnout between the two same-day items (Figure 6: turnout_68 − turnout_67) shows that absinthe attracted additional voters beyond the commerce-only baseline in several German-speaking cantons (GL, SG, SH, BE, BS, GR), supporting absinthe-specific mobilization above the ballot-day floor. We cannot fully separate the two co-occurring items as drivers of the French-canton mobilization, and we do not need to — the cultural-political mobilization argument is at the *ballot-day-and-issue* level, not at the per-item level."

### Meta-pattern — cantonal collinearity will keep recurring

The H3 catholic/protestant collinearity and the C.6.2 vine/french collinearity are **both instances of a broader pattern**: 1900 Swiss cantonal data has multiple near-collinear demographic dimensions because Switzerland's cultural-political cleavages aligned along several reinforcing axes:

| Cleavage dimension | Highly-correlated pair | Why correlated in 1900 Switzerland |
|---|---|---|
| Religion (within Christianity) | `catholic_share` ↔ `protestant_share_total` | Cath + Prot = 99.4% of population (the H3 / t17 case) |
| Language ↔ wine industry | `french_share` ↔ `vineyard_per_cap` | French-speaking cantons (VD, VS, GE, NE) produced the bulk of national vineyard area (the C.6.2 case) |
| Religion ↔ topography | `catholic_share` ↔ `pop_density_1900` | Catholic cantons concentrated in mountain/inner cantons (UR, SZ, OW, NW, GL, ZG, FR, AI, AR partially); Protestant cantons in lowland/urban (ZH, BE, BS, GE) |
| Migration ↔ pop size | `net_migration_per_cap` ↔ `ln_pop` | Larger urban cantons (ZH, GE, BS) attracted in-migration; small cantons did not |
| Language ↔ religion (partial) | `french_share` ↔ `catholic_share` | French cantons split: VD/NE/GE Protestant, VS Catholic. Less cleanly correlated than the others above; partial overlap in VS only. |

For each future task that introduces a new regressor, the implementing coder should:

1. Compute pairwise correlations with existing controls before estimation (`corr <new_var> vineyard_per_cap french_share catholic_share ln_pop`).
2. Run the spec; check joint-spec VIFs via `cap noi estat vif`.
3. If VIFs > 10 on substantively important regressors, treat the case as analogous to H3 / C.6.2 — either drop one collinear variable (with documentation) or report both versions (main + backmatter, as t17 / t17b model).
4. In every case, document the collinearity *explicitly* in the table caption so the reader sees the constraint on identification.

**This applies to upcoming tasks**:
- **C.5 cleavage index**: the index aggregates language + religion variation. Construction of the index needs to acknowledge that French-Catholic vs French-Protestant variation is partially confounded.
- **C.6 mobilization**: per Caveat #2 above.
- **C.4 rank recompute (#65 reclassified)**: lower risk — pure rank-statistic recomputation, no new regressors.
- **C.2 food65 robustness**: same controls as headline KEY spec, no new collinearity surface.

---

## Why this matters for the paper

1. **Honest power language is referee-proofing.** A reviewer reading "highly powered" applied to a 14-observation comparison will (correctly) flag it as overclaim. Pre-emptive correction in the paper text avoids that referee comment.

2. **Identification limits acknowledged in C.6.2 prevent overclaim of mechanism separation.** The wine-industry-vs-cultural-mobilization separation is a substantive empirical claim; if the data cannot support it cleanly, the paper must say so.

3. **Same-day ballot nuance is intellectually honest.** Many empirical political-economy papers conflate ballot-day mobilization with vote-specific mobilization without acknowledging the distinction; doing so explicitly is good practice and signals methodological care.

4. **The collinearity meta-pattern is forward-looking insurance.** Without this note, a future Claude session implementing C.5 or future tasks would have to re-derive the collinearity discipline each time — wasting context budget and risking inconsistent treatment across tables. With this note, the discipline is permanent.

---

## Mechanism / interpretation

These are not findings about Swiss politics; they are findings about the *measurement-and-identification structure of the dataset we have*. The cantonal data has 25 observations across multiple dimensions (language, religion, wine industry, mountain/lowland, migration, ag concentration), and these dimensions are correlated with one another for historical reasons — Swiss cantonal political identities formed in periods (Reformation, Sonderbund, federal-state-formation) that aligned cultural-political-economic cleavages along reinforcing axes.

This is a *small-N reality* of any historical cross-section of subnational political units: the units are not orthogonal in their characteristics. The methodological response is not to give up on identification, but to be transparent about which separations the data can and cannot support, and to triangulate via panel evidence (cross-vote, cross-time) and descriptive evidence (figures, individual case studies) wherever the cross-section regression is identification-limited.

The paper that emerges from this analysis will therefore:
- **Make strong claims** where multiple identification strategies converge (e.g., the headline +484 wine-industry coefficient survives 28+ robustness checks, OLS + fracreg + LOO + RI + PDS-LASSO; this is well-identified despite N=25)
- **Make moderate claims** where panel evidence supports cross-section evidence (e.g., C.6's cultural-mobilization story — strong panel, modestly identified cross-section)
- **Make explicitly-cautious claims** where only the cross-section can speak (e.g., C.6's wine-vs-French separation — pre-emptive acknowledgment of identification limit)
- **Decline to make claims** where the data is uninformative (e.g., H3 and H6 interaction signs — null at N=25, reported as "tested but power-limited")

This four-level claim hierarchy is the substantive output of the engineering-review discipline.

---

## Evidence base

| Source | What it provides |
|---|---|
| Coder's C.6 explanation message (this conversation, 2026-05-01 ~20:00) | The original framing that the strategist reviewed |
| Strategist's engineering review (relayed via user, 2026-05-01 evening) | The three caveats + meta-pattern |
| `analysis/documentation/handoffs/round2/notes_post_taskB.md` | Working framing recommendations for downstream Tasks C.5 / C.6 — to be amended in light of these caveats |
| `analysis/documentation/handoffs/round2/09_taskC6_mobilization.md` lines 17, 156, 234-242 | Source for the same-day vote #67 gap = +4.7 pp fact and the strategist's draft t20 caption |
| `analysis/processed/absinthe_analysis.dta` | Source for verifying the wine-French canton correlation: `corr vineyard_per_cap french_share` returns ~+0.6 in this sample |
| `analysis/processed/intermediate/vineyard_uncleaned.dta` | Source for canton-level vineyard area 1905 (used above to enumerate French wine cantons) |
| `analysis/results/tables/t17_formal_hypotheses.tex`, `t17b_formal_hypotheses_alt.tex` | Precedent for the dual-spec main+backmatter treatment that C.6.2 should consider adopting |
| Pipeline log `2026.05.01_20.10.*.log.txt` | Confirms all Task B asserts pass with both spec families |

---

## Caveats / open questions

- **The C.6 implementation is still pending.** These caveats apply to *how* C.6 will be implemented and reported, not to results we have. Task C.6 implementation will need to incorporate them in the section 10.16+ code, the t20/t21/f06 captions, and the post-credits assert messages.

- **The dual-spec recommendation for C.6.2 is OPTIONAL.** Single-spec with explicit caveat in caption is acceptable. Dual-spec (analogous to t17/t17b) is preferred but adds implementation time. Decision to be made at C.6 dispatch time.

- **The collinearity meta-pattern table above is illustrative, not exhaustive.** Other near-collinearities exist in the data (e.g., `parcels_per_farm_1905` vs `avg_parcel_area_1905` — both proxy ag concentration). The C.5 / C.6 implementer should run their own correlation matrix on whatever new variables they introduce.

- **The "high effect size with adequate panel leverage" framing for C.6.1 must be paired with a one-sample t-test p-value**, not just a z-score. If the strategist's preview used z, the implementer needs to also compute and report `ttest gap == hypothesized_value` against the 14-vote baseline distribution, or equivalently use `signrank` for a non-parametric version.

- **None of these caveats blocks Task C.1 dispatch.** C.1 is a Simpson-flip diagnostic for vote #65, with the same identification structure as the headline KEY spec — no new collinearity surface. Per the strategist: "C.1 is a straightforward Simpson-flip diagnostic that doesn't depend on C.6's framing."

---

## Provenance

- **Origin**: 2026-05-01 evening, strategist engineering review of the coder's post-Task-B C.6 explanation, relayed via user dispatch.
- **Linked commits**:
  - `a6d3b91` round2 Task B initial implementation (the H3/H6 nulls that motivated the C.6 explanation)
  - `fd203d0` round2 Task B refactor: dual-spec t17 main + t17b backmatter (the precedent for dual-spec collinearity treatment)
  - `81e3256` round2 Task B documentation (2 progress notes + downstream framing handoff)
- **Related progress notes**:
  - `progress_2026-05-01_2030_bbtests.md` — Task B substantive results (H3/H6 nulls)
  - `progress_2026-05-01_2031_collinearity_design.md` — H3 design defect (the precedent collinearity case for the meta-pattern documented here)
  - `progress_2026-04-30_1830_foodbev.md` — Stiglerian capture pattern (unrelated but contextually adjacent)
- **Related tables/figures**: t17 (main, strat) and t17b (backmatter, alt) — the precedent dual-spec implementation; t20 / t21 / f06 (pending C.6 implementation, will inherit these caveats).
- **Related working documents**: `analysis/documentation/handoffs/round2/notes_post_taskB.md` (working framing handoff that this note refines), `analysis/documentation/handoffs/round2/09_taskC6_mobilization.md` (the original C.6 spec from the strategist).

---

## References / further reading

- **Cohen, Jacob (1988)**. *Statistical Power Analysis for the Behavioral Sciences*. 2nd ed. Lawrence Erlbaum Associates. The reference for power-vs-effect-size distinction central to Caveat #1.
- **Wooldridge, Jeffrey M. (2010)**. *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press. Section 4.4.4 on multicollinearity (relevant to Caveat #2 and the meta-pattern).
- **Aiken, Leona S.; West, Stephen G. (1991)**. *Multiple Regression: Testing and Interpreting Interactions*. SAGE Publications. The standard reference for the principle invoked in Task B that interaction-term identification can survive main-effect collinearity (relevant for the dual-spec recommendation in Caveat #2).
- **Bonjour, Edgar; Offler, H. S.; Potter, G. R. (1952)**. *A Short History of Switzerland*. Oxford: Clarendon Press. The reference for the historical-formation argument that 1900 Swiss cantonal cleavages aligned along reinforcing axes (Reformation, Sonderbund, federal-state formation), explaining the structural correlation underlying the meta-pattern.
- **Linder, Wolf (2010)**. *Swiss Democracy: Possible Solutions to Conflict in Multicultural Societies*. 3rd ed. Palgrave Macmillan. The canonical English-language reference for the cultural-political cleavage structure of late-19th-century Switzerland, providing context for why French-language cantons concentrated wine production (climatological + Roman-law inheritance) and Catholic cantons concentrated in mountain regions (Counter-Reformation defense in inner cantons).
