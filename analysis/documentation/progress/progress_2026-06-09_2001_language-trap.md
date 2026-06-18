# Progress note: absinthe was language-trapped — the producer×French collinearity is both the political cause of its defeat and the reason the producer effect is unidentified

**Date**: 2026-06-09 20:01
**Topic**: language-trap
**Triggered by**: PI — "absinthe was a language-trapped interest while wine had cross-bloc reach … this is worthy of a checkpoint and might be paper critical." Plus the producer×French interaction test requested in the same message.
**Status**: reframing + methodological clarification (sharpens the producer-leg interpretation and unifies it with the identification failure)

---

## Headline (1 paragraph)

The same collinearity has two faces. **Politically**, the absinthe industry was a *language-trapped* minority interest: production concentrated in French-speaking Neuchâtel (and Geneva), so its defense was confined to a bloc that (a) was outvoted by the German-speaking majority and (b) was itself split, because the French *wine* cantons (Vaud, Valais) and the French *no-stake* canton (Fribourg) voted **for** the ban. The wine industry, by contrast, had a *cross-language* coalition (yes-voting wine cantons in both blocs), so it could not be isolated the way absinthe was. **Econometrically**, that same geography means `abs_producer` and `french_share` are nearly the same variable (r = 0.71; their interaction r = 0.99 with French), which is exactly why the producer coefficient cannot be separated from language. The cleavage that doomed absinthe politically is the identical collinearity that makes the producer effect statistically invisible — "lack of evidence, not evidence of lack." This unifies the producer leg's two recurring facts (real raw differential, vanishes under the French control) into one mechanism.

---

## Background and discovery

Came out of a post-RI interpretive thread (2026-06-09) reconciling three things: (1) the canton-level competing-coalition pattern, (2) the national double-majority outcome, and (3) why the producer leg is "directional but inconclusive." The PI asked whether "wine made a difference but the language cleavage was the nail in the coffin," then specifically asked for Fribourg's context and the `abs_producer × french_share` interaction. Computing those turned a loose intuition into a precise, evidence-backed mechanism.

Prior framing (decision log D8; results memo §2.5): the producer raw −11.2 pp differential collapses to +3.57 (n.s.) when French enters, with SE inflating ×1.31 — "a power / linked-covariance limitation, NOT an indemnification." This note explains *why* that happens and ties it to the political story.

---

## Substantive content

**1. The cleavage is the dominant axis (the backdrop).** Vote-weighted from actual #68 counts: the **French bloc voted 48.2% yes (net NO)**; the **German/other bloc 65.2% yes**. The ban passed (61.2% national) because the German-speaking majority overwhelmed French opposition. Consistent with the Gelbach decomposition (~99% of the wine sign-flip runs through French) and the R² jump (0.016 wine-only → 0.62 with cultural controls).

**2. But within the French bloc the vote tracks economic interest, not language.** The five French cantons split by their stake:

| French canton | vote | wine share | absinthe purchases |
|---|---|---|---|
| Valais | YES 61.8 | 19.5 | — |
| Fribourg | YES 59.5 | 0.8 | 61,906 kg, 1 firm |
| Vaud | YES 56.1 | 32.1 | 553,767 kg, 4 firms |
| Geneva | NO 40.8 | 2.8 | 1,002,297 kg, 10 firms |
| Neuchâtel | NO 35.3 | 5.4 | 3,178,714 kg, 17 firms |

The wine cantons (VD, VS) broke from their language bloc to vote yes; the absinthe-*production* cantons (NE, GE) are the only two NO votes nationally. **French ≠ no** — the French "no" is an absinthe-production phenomenon, not a language one.

**3. Fribourg is the clean control.** 69% French, but 85% Catholic, ~0 wine, and absinthe trade that's a rounding error (61,906 kg through **one** firm, vs Neuchâtel's 3,178,714 kg across 17 firms — ≈50×). With no economic stake on either side, it votes its culture (Catholic-conservative + temperance) → yes, with the majority. Fribourg shows that a French canton without an absinthe industry votes like everyone else. It also exposes the `abs_producer` dummy's coarseness: FR = NE = "1" despite a 50× difference in actual absinthe. (Note: the regression's religion control is **Protestant share** (`cov3`), not Catholic — the two are exact complements, so Fribourg's 85% Catholic = 15% Protestant; "Catholic" here describes the canton, not a regressor. The col-5 controls are French + absinthe-trade + Protestant + log-density.)

**4. The producer×French interaction is not identified — the cleanest proof of the ceiling.** `corr(abs_producer, french_share) = 0.711`; `corr(abs_producer×french_share, french_share) = 0.993`. Regression `Y1 = producer + french + producer×french` (HC3, N=25, R²=0.437):

| term | coef | SE | p |
|---|---|---|---|
| producer (at French=0) | −1.2 | 5.0 | 0.82 |
| French share | −63.1 | 54.9 | 0.26 |
| producer × French | +40.8 | 55.6 | 0.47 |

Blown-up, offsetting coefficients with SEs as large as the coefficients; nothing significant; point values are collinearity artifacts. Critically, **once French and the interaction absorb the variation, the producer "main effect" collapses to ≈0** — i.e., the raw −11 pp differential *is* the language signal. There is no separable producer coefficient because producer and French are the same column of data.

**5. Discipline check — wine was not nationally pivotal.** Removing the wine contribution entirely (even at the upper 90% CI slope, 0.76) leaves the ban passing 57.9% popular and 18/22 cantonal votes (thresholds 50% and >11). Wine plausibly flipped exactly one canton (Vaud: 56.1 → 41.7, but its 90% CI [31, 52] straddles 50). So the cultural majority was decisive for the outcome; wine is a real, identified, cross-cutting, but *second-order* tilt.

---

## Why this matters for the paper

- **It converts a weakness into a mechanism.** "The producer effect disappears under the French control" reads as a limitation. Reframed, it is a *finding*: absinthe's economic interest was geographically trapped inside the French minority, so it had no cross-bloc coalition — and that same trapping is why it can't be econometrically separated from language. The political economy and the identification problem are the *same fact*.
- **It explains the winner/loser asymmetry** in the competing-coalition story: the *winner* (wine) leg is identified precisely because wine spans both language blocs (German wine cantons ZH/AG/TG/SH give within-language variation); the *loser* (absinthe) leg is not, because it doesn't. This is the honest, referee-proof account of why the paper leads on wine and treats producer as corroborating-qualitative.
- **Fribourg is a usable illustration** (a French Catholic no-stake canton voting yes) for the mechanism section, and a concrete example of the `abs_producer` dummy's measurement limits.

---

## Mechanism / interpretation

Cross-cutting cleavage vs. trapped interest. Wine production sits in *both* language groups → the wine coalition recruits allies across the German/French divide → identified and cross-cutting (though marginal). Absinthe production sits only in French Neuchâtel/Geneva → its coalition is a minority-within-a-minority, can't escape the language boundary, and is even abandoned by its own bloc's wine cantons → outvoted *and* statistically inseparable from "French." The cleavage was fatal to absinthe not because language *per se* doomed it, but because absinthe's interest was language-bounded while the ban's support (German majority + cross-bloc wine cantons) was not.

What the data shows vs. is consistent with: the data **shows** producer≈French collinearity, the within-French economic split, and Fribourg's profile. It is **consistent with** (but cannot prove) a causal "trapped interest" story — the producer effect is directional but not separately identified, so the political mechanism is an interpretation of a pattern, not an estimated causal effect.

---

## Evidence base

| Source | What it provides |
|---|---|
| `processed/cohort_1908_workshop.dta` (vote-weighted #68 counts) | French bloc 48.2% vs German 65.2%; within-French split; Fribourg profile; absinthe purchase volumes/firm counts |
| Interaction regression (this note, §4) | corr 0.993; non-identified producer×French; producer main effect ≈0 once French absorbs it |
| `T_producer_cascade` / results memo §2.5 | raw −11.2 pp → +3.57 under French; SE ×1.31; corr(producer,French)=0.71 |
| Gelbach decomposition (T15) | ~99% of the wine sign-flip mediated by French |
| National counterfactual (this thread) | wine not nationally pivotal; cultural majority decisive |

---

## Caveats / open questions

- **"Language" is shorthand** for the German-vs-French cultural/confessional/temperance bundle; the data cannot isolate pure language from religion and the temperance movement (all load on the German bloc). Use "cultural cleavage," with language as its dominant measurable proxy.
- **The producer leg remains directional-but-not-identified.** This note does NOT claim a causal producer effect; it claims the *non-identification* is structural (collinearity) and meaningful, not a true null.
- **`abs_producer` is a coarse dummy** (FR=NE despite 50× difference). A continuous absinthe-intensity measure (purchase kg) might give marginally more variation, but the French confound remains — unlikely to rescue identification at N=25.
- **Don't let "language was decisive" bury the contribution.** The cleavage driving the vote is the *known background*; the paper's news is the economic coalition detectable *net of* it.

---

## Provenance

- Origin: chat thread 2026-06-09 (post-canonical-RI interpretation), PI prompts on Fribourg + producer×French interaction.
- Computations: ad-hoc MCP-Stata runs on `cohort_1908_workshop.dta` (bloc yes-rates, Fribourg profile, interaction regression, national counterfactual). Reproduce by re-running the snippets in the chat log / this note's §1–§5.
- Related: `quality_reports/coder_reports/2026-06-03_inference-battery-results.md` (§2.5 producer cascade); `quality_reports/coder_reports/2026-06-03_inference-battery-decision-log.md` (D8); `analysis/documentation/producer_variable_disambiguation.md`; `analysis/documentation/robustness_status.md`; `.handoffs/2026-06-09T20-01-24-checkpoint-language-trap-mechanism.md`.
- Related tables: T_producer_cascade, T15 (Gelbach), T19/T20 (cleavage index).

---

## References / further reading

- Gelbach (2016), "When do covariates matter?" — the decomposition attributing the sign-flip to French.
- Cahannes (1981) — absinthe vs white wine competition (the winner-coalition mechanism).
- Project decision log D8 — producer cascade framing ("power/linked-covariance limitation, not indemnification").
