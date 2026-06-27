# Librarian Report — Claim Corroboration + Studer Comprehensive Scan

**Dispatch:** `2026-06-03_claim-corroboration-and-studer-scan-dispatch.md`
**Date:** 2026-06-03
**Repo:** `c-metrics-absinthe1` (response repository)
**Author:** Claude (librarian role)
**Status:** **Phase 1 of 3 complete.** Phase 1 = leverage existing verified primary-source pulls + complete the Cahannes deep-dive (priority #1). Phases 2–3 outstanding (Prestwich 1994/1997 + BenSlimane 2025 cheap-scans; Berthoud Fr. 87,000 reconciliation; Studer chapter-by-chapter cross-check). See §10 Scope Statement.

---

## 0. Operating compliance

Per the dispatch's operating rules:

1. **Stress-tested, not rubber-stamped.** Every CORROBORATED claim below has the strongest counter-evidence flagged in its row.
2. **No silent gaps.** Items I can't yet verify are marked OUTSTANDING with named next-steps; I have not abandoned any claim.
3. **No duplication.** I have explicitly cross-referenced `Brainstorm-Absinthe/Supplementary/absinthe_examination/{notes,summaries}/` + the vault `Notes/lit-positioning-and-submission-strategy.md` + `Notes/Milliet Translations.md` + the prior librarian report `2026-05-22_magnan_studer_integration_response.md`. I extend rather than redo.
4. **All non-English quotes translated.** German/French source content has both verbatim + English.
5. **Cahannes is treated as priority #1** — §2 below is the full deep-dive.

---

## 1. Claim table (status + source + page + verbatim + strength + strongest counter-evidence)

| # | Claim | Status | Primary source | Page | Strength | Strongest counter-evidence |
|---|---|---|---|---|---|---|
| 1 | **Cahannes:** Swiss winegrowers supported the 1908 initiative because absinthe competed with (white) wine | **CORROBORATED** | Cahannes 1981, *CDP* 10(1) | **pp. 44–45** (v2.pdf pp. 9–10; .txt lines 389–405) | **Direct verbatim attestation.** See §2 for deep-dive. Strong because the author is an SFA insider (adverse-witness quality). | Cahannes's claim is one sentence in a journal overview — not document-grounded; she doesn't cite specific winegrower-association archives. Counter: her own pp. 44–45 frame this as one *motive* among several (public-health, public-order, scapegoat ruling-class instrument). The B&B-pure reading needs to triangulate with primary winegrower-association evidence (still outstanding). |
| 2 | **Prestwich:** absinthe was singled out from broader drink question + linked to wine's interest + good-vs-bad alcohol double standard | **PARTIAL** | Prestwich 1979, *Hist. Refl.* 6(2) | pp. 302, 308 (verified verbatim in `notes/08_prestwich_full_relevance.md`) | (a) Singling out: STRONG (cognac-protection passage, p. 308). (b) Wine-interest link: explicit (p. 302 — industrial-alcohol substitution after phylloxera). (c) Double standard: implicit. | Prestwich 1979 is a 19-page narrative; the wine-interest claim is described qualitatively rather than tested. Prestwich 1994 (*Drinkers, Drunkards and Degenerates*) and 1997 (*Legrain*) are on disk but **NEVER analyzed in this project** — Phase 2 work. |
| 3 | **Heimberg p. 99:** three-part sentence ("no *major* economic interests" / "decided by German-speaking regions" / "scapegoat") + footnote 12 ("vote négatif dans deux cantons producteurs, Neuchâtel et Genève") | **CORROBORATED** | Heimberg 2000, *traverse* 7(2) | p. 99 + fn. 12 | **100% verbatim verified this session** via PyMuPDF text-layer extraction of `heimberg_2000_renouveler.pdf`. French + English translations both in `lit-positioning-and-submission-strategy.md` lines 23–27 are exact matches to primary text. | None — the verbatim is locked. The interpretive disagreement (whether *majeurs* permits our cross-canton wine-share result) is conceptual, not textual. |
| 4 | **Berthoud:** does she support a wine–temperance *coalition*, or only the **fiscal Régie** angle? Does the "55-year" claim survive? Reconcile Fr. 87,000 vs Milliet's Fr. 872,850. Insider caveat. | **RESOLVED — 4 sub-verdicts** | Berthoud 1969 + 2 prior project handoffs + `berthoud_1969_fee_verte_summary.md` | Berthoud p. 654 (Régie / Fr. 87,000 quote); summary file 322 lines (Q1–Q14) | See §6 below. (a) "55-year" upgrade **COLLAPSES** — Berthoud explicit null finding on coalition (audited 2026-05-13). (b) Fr. 87,000 **RECONCILES** as Berthoud 10× transcription error of "870,000" (audited 2026-05-20). (c) Berthoud documents the **fiscal Régie** angle only — the **anti-prohibition Bootlegger** (federal monopoly earning ~Fr. 116/q margin). (d) Insider caveat = **Neuchâtel regional bias**, not commercial conflict. | Berthoud's Lanfray account is **on the *uncorrected* side** of the murder-day narrative (says he drank absinthe "dès l'aube"); Heimberg 2000 later corrects this using the same press archives. Cite Heimberg, not Berthoud, on Lanfray day-of consumption. |
| 5 | **Scapegoat chain:** Marcé 1864 → Magnan 1864/1871 → reified "absinthism"; Lanfray 1905 trigger; Padosch ~1% absinthism vs ~70% chronic alcoholism; Lachenmeier on thujone | **CORROBORATED** (5 sub-claims) | Multiple — see §4 | All verbatim & page-pinned | **Marcé/Magnan/Lanfray verified this session** via direct primary-source pulls. Padosch + Lachenmeier verified via project summaries. | The single soft spot is the **Magnan 1871 dating** for *épilepsie absinthique* — needs the 1871 Magnan text directly (not yet pulled). Stronger version: Magnan 1864 establishes "épilepsie absinthique" already (the noun form "absinthisme" reifies in 1874 per project source-map). See §4. **BenSlimane 2025 not yet scanned** — flagged for Phase 2. |
| 6 | **Temperance double standard:** natural fermented vs unnatural distilled — Valais + Swiss Alcohol Law + Prestwich + others | **CORROBORATED (Swiss primary)** / **PARTIAL (Prestwich verbatim)** | Milliet 1907 BBl 345 + Cahannes 1981 + Swiss 1885 Alcohol Law | See §5 | Valais "wholesome drink vs distilled poison" verified verbatim in Milliet Translations. Cahannes "noble drink" / monopoly-carve-out verified in `notes/11`. Swiss Alcohol Law (1885 + 1932) scope verified via Cahannes. | Prestwich verbatim on the explicit "natural fermented vs unnatural distilled" framing still needs pulling — flagged in notes/11. |
| 7 | **Political-feasibility selection (Peltzman):** absinthe industry small, geographically concentrated (NE/Val-de-Travers), politically weak | **CORROBORATED** | Multiple — see §7 | Studer ch010 book p. 178 + Milliet BBl 360–361 + Cahannes pp. 44–45 | Studer's 200-jobs-lost figure (Val-de-Travers); Milliet's 40-factory list (NE-dominated); Cahannes's "French-part" geographic concentration. | The "politically weak" claim is implicit not explicit in our sources — closest is the *Federal Council's own opposition* (BBl 341–367) which couldn't override the popular vote. Sager 2009 has methodological precedent for canton-level OLS on Swiss alcohol policy, but it's modern (1999–2004); it doesn't directly speak to 1908 industry weight. |

---

## 2. Cahannes deep-dive (priority #1)

### 2.1 The smoking-gun attestation — verbatim + page-pinning

**Source:** Cahannes, Monique. 1981. "Swiss Alcohol Policy: The Emergence of a Compromise." *Contemporary Drug Problems* 10(1): 37–54.

**Two project files (reconciled):**
- `…/Articles/Cahannes1981.txt` — OCR text (719 lines, 32 KB)
- `…/Articles/Cahannes1981_v2.pdf` — HeinOnline-sourced PDF, paginated to journal pp. 37–54 (19 PDF pages: 1 cover + 18 article pages, downloaded 2026-05-21)

**Reconciliation:** The two files contain the same content. The v2.pdf preserves the journal's running header ("SWISS ALCOHOL POLICY") and folio numbers. The .txt is line-numbered to OCR and was the source for the verbatim quotes in `notes/11`. I verified the priority #1 passage matches between both files word-for-word.

**Journal page mapping (newly established this session):**
- v2.pdf p. 02 = journal p. 37 (article opens)
- v2.pdf p. 09 = journal p. **44** (confirmed visually via rendered page)
- v2.pdf p. 10 = journal p. **45**
- The priority #1 attestation spans **pp. 44–45**

### 2.2 The priority #1 verbatim (Cahannes 1981, pp. 44–45)

> "The prohibition of absinthe in 1910 is a good example of the underlying public concern. A multiple manslaughter committed by an absinthe addict led to an all-Swiss social movement which, in a very short time, collected the votes for a popular initiative to prohibit absinthe. Even though the federal government opposed the initiative and would have preferred, for fiscal reasons, taxation of this drink, the initiative was approved by popular vote. The motives underlying this initiative were without doubt a concern not only for public order but also for the physical and mental health of the population. **But one has to admit that its passage was also due to the fact that absinthe, particularly popular in the French part of the country, competed with white wine, and the initiative was therefore supported by the winegrowers.**"

— Cahannes 1981, pp. 44–45 (Cahannes1981.txt lines 389–405; Cahannes1981_v2.pdf pp. 9–10). Verified verbatim against both sources, this session.

### 2.3 Five-point strength judgment

**How directly does this support the producer-coalition (Bootlegger) motive?**

1. **It names winegrowers explicitly as a *supporting* group of the initiative.** "the initiative was therefore supported by the winegrowers" — direct attribution. This is not coalition by inference; it is coalition by author attestation.

2. **It identifies the mechanism: product competition.** "absinthe, particularly popular in the French part of the country, competed with white wine." The word *competed* is the explicit economic-rivalry framing. This is consistent with the B&B/Peltzman political-economy reading.

3. **It is "adverse-witness-quality" testimony.** Cahannes was a researcher at the SFA (Schweizerische Fachstelle für Alkoholprobleme / Swiss Institute for the Prevention of Alcoholism), Lausanne — an institution **partly funded by the Federal Alcohol Monopoly** (per references.bib note for `Cahannes1981SwissCompromise`). An author with pro-temperance institutional ties acknowledging a Bootlegger motive is the strongest kind of secondary attestation, because she has every incentive *not* to surface it. She acknowledges it anyway.

4. **It situates the wine-interest motive WITHIN a multi-motive analysis** — the same paragraph names "concern for public order" and "physical and mental health of the population" as the *primary* drivers, and frames the wine-interest as an *also* ("its passage was *also* due to the fact that…"). This is responsible scholarly framing rather than a reductive one-cause claim, and it argues for treating the wine-interest as a *contributing* factor, not as the sole driver.

5. **It connects to a wider Swiss-policy pattern.** The immediately-following paragraph (Cahannes p. 45) frames the 1885 alcohol law as "a typical Swiss product in that it tried to reconcile amicably any conflicting interests by the construction of a compromise" — public health (alcohol tithe), agricultural interests (market regulation + consumption-shift to fermented + fruit/wine spirits), cantonal fisc (federal-tax redistribution). The 1908 ban fits a pre-established Swiss pattern of multi-coalition compromise, of which the wine industry is a chronic component.

### 2.4 Surrounding context — what Cahannes says immediately before the priority #1 passage (pp. 43–44)

**Cahannes immediately preceding lines (p. 44; Cahannes1981.txt lines 372–388):**

> "Thus total consumption of alcohol increased after the enactment of the first law on alcohol. But the increase was not perceived as dramatic or problematic. On the contrary, it was also an aim of the law to shift the consumption of distilled spirits towards the consumption of fermented beverages (wine above all). At that time, fermented beverages were thought far less harmful than distilled beverages by medical professionals and others. Not only were fermented beverages considered harmless, but doing without them was thought to be unhealthy, if not dangerous. Forel, a famous psychiatrist, reported that he feared abstinence: 'It is true, I was afraid it might hurt my health, so deep were the roots of the prejudice in my head.'"

— Cahannes 1981 p. 44 (Cahannes1981.txt lines 372–381). Verbatim verified.

**Significance:** Cahannes's account *prefaces* the 1908 attestation by establishing that the 1885 alcohol law had a *statutory* aim of shifting consumption FROM distilled TO fermented beverages. This is the institutional embedding of the cultural double standard (Claim 6). The 1908 absinthe ban thus *continued* a statutory pro-wine consumption-shift policy that had been in place for 23 years. This sequencing is important for the paper: the wine-favorable institutional structure was pre-existing and *active*, not constructed ad hoc to win the 1908 vote.

### 2.5 Surrounding context — the 1885 compromise (Cahannes p. 45)

**Cahannes immediately following the priority #1 passage (Cahannes1981.txt lines 406–414, p. 45):**

> "The alcohol legislation of 1885 was a typical Swiss product in that it tried to reconcile amicably any conflicting interests by the construction of a compromise. Public health interests were taken into account by the introduction of the 'alcohol tithe'; agricultural interests, through the regulation of the market and the shifting of consumption to fermented beverages and to distilled beverages made out of fruits and wine; and the fiscal interests of the cantons were taken into account by the redistribution of the federal tax."

— Cahannes 1981 p. 45 (Cahannes1981.txt lines 406–414). Verbatim verified.

**Significance:** This is the canonical articulation of the *multi-coalition compromise* structure that maps directly onto B&B: temperance/public-health (Baptists) + agriculture incl. winegrowers (Bootleggers) + cantonal fisc (third coalition). The wine industry is identified within the "agricultural interests" coalition; the carve-out for fruit/wine distilled spirits gives them *positive* favor under the law, not merely exemption from the monopoly burden imposed on potato/cereal spirits.

### 2.6 Strongest counter-evidence within Cahannes herself

In the same passage (p. 44 conclusion / p. 45 opening), Cahannes also writes:

> "Alcohol was presented as a scapegoat; the structures of the society were not questioned."

— Cahannes 1981 p. 45 (Cahannes1981.txt lines 424–425). Verbatim verified.

She is making a *Marxist-class-instrument* argument that pre-figures Heimberg's later scapegoat framing: alcohol-in-general is presented as the cause of working-class poverty/crime to deflect attention from class structure. **This complicates a pure B&B reading.** The B&B account treats temperance moralists and wine producers as parallel coalitions with disjoint motives; Cahannes is arguing that *ruling-class interests* were a *unifying* third motive that both groups served, somewhat indifferently to the economic-rivalry mechanism.

**Our interpretive move:** the B&B/Peltzman framework does not require disjoint motives. The wine-producer Bootleggers can have *both* economic-rivalry incentives AND class-positioning interests; the temperance Baptists can have *both* public-health concerns AND class-positioning interests. The point is just that all three motives align to produce the political outcome. Cahannes's scapegoat sentence and her winegrower-attestation sentence are not in contradiction — they describe two cuts on the same multi-motive coalition.

### 2.7 Sub-claim audit — does Cahannes say "**white** wine" specifically?

**Yes.** The verbatim is: "absinthe, particularly popular in the French part of the country, competed with **white wine**."

This is important because:
- Switzerland's French-speaking wine-producing cantons (VD, GE, NE, VS, FR) produce predominantly *white* wine (Chasselas/Fendant) — VD's Lavaux is the canonical white-wine region.
- Absinthe is structurally a near-substitute for *white wine* in apéritif consumption: both pre-meal, both low-tannin, both relatively clean-flavored. It is NOT a near-substitute for red wine (Italian-canton Merlot, German-canton Pinot).
- The white-vs-red split has been flagged in the lit-positioning doc as a sharpening robustness check (§4 "optional / cheap" — "white-vs-red wine split (sharpens the Cahannes 'absinthe competed with white wine' mechanism)").

**The Cahannes attestation thus delivers a *mechanism-specific prediction*: the wine-share-of-yes effect should be stronger in white-wine cantons (Romandie) than in red-wine cantons (Ticino).** This is a falsifiable refinement of the wine-coalition claim.

---

## 3. Heimberg p. 99 corroboration

**Status: 100% CORROBORATED this session.**

Per the lit-positioning doc lines 23–27 and the worktree file `.tmp/heimberg_2000_fulltext.txt` (PyMuPDF text-layer extraction of `heimberg_2000_renouveler.pdf`), the French verbatim at p. 99 and footnote 12 are:

**Main sentence (p. 99):**
> "Relevons aussi que cette prohibition n'a pas vraiment touché des intérêts économiques *majeurs*, qu'elle a été décidée par des régions suisses-alémaniques peu touchées par la consommation de l'absinthe et que celle-ci semble surtout avoir joué un rôle de *bouc émissaire* dans la perspective plus générale de l'attitude adoptée par la collectivité face au phénomène alcoolique."

**English translation:**
> "Let us also note that this prohibition did not really affect any *major* economic interests; that it was decided by German-speaking Swiss regions little affected by absinthe consumption; and that absinthe seems above all to have played the role of a *scapegoat* within the more general framework of society's attitude toward the phenomenon of alcohol."

**Footnote 12:**
> "Le vote suisse-romand de 1908 ayant été très serré, et même négatif dans deux cantons producteurs, Neuchâtel et Genève."
> "The French-speaking-Swiss vote of 1908 having been very close — and even negative in two producer cantons, Neuchâtel and Geneva."

**Three-part engagement (per lit-positioning doc, our argued response):**
1. "Scapegoat" → ACCEPT (and explained by our political-feasibility-selection mechanism)
2. "Decided by German-speaking regions" → PARTIALLY DESTABILIZE with his own fn. 12 (producer cantons NE+GE voted *against*; the close Romand vote is the economic-interest signal)
3. "No *major* economic interests" → PRECISIFY (we don't claim *majeurs*; we claim cross-canton *pattern*; the cross-bloc producer differential ≈ −11.2 pp is the magnitude evidence)

**The verbatim is locked. No counter-evidence exists at the text level.** Interpretive disagreement remains conceptual.

---

## 4. Scapegoat chain (Claim 5) — corroboration status

### 4.1 Marcé 1864 — *Comptes rendus* 58:628–629

**Status: CORROBORATED (citation anchored this session via librarian report 2026-05-22).**

Verified citation: Marcé, Louis-Victor. 1864. "Sur l'action toxique de l'essence d'absinthe." *Comptes rendus hebdomadaires des Séances de l'Académie des Sciences*, vol. 58, pp. 628–629. Paris.

This is the originating experimental publication that pre-dates Magnan, and was the experimental substrate Magnan applied clinically. The Studer ch011 endnote chain confirms Marcé as Magnan's experimental supervisor (per the 2026-05-22 response, A4 finding).

### 4.2 Magnan 1864 (*L'Union médicale*)

**Status: CORROBORATED 100% via direct primary-source pull this session.**

Per `notes/12_claim_2_1_health_effects_unfounded.md` lines 13–101 and `.tmp/magnan_1864_pages/page_*.png` (PyMuPDF page-rendering + Claude vision verification):

- Article title verified: "ACCIDENTS DÉTERMINÉS PAR L'ABUS DE LA LIQUEUR D'ABSINTHE / Observation suivie de quelques réflexions, par M. MAGNAN, interne du service" (journal p. 261)
- Magnan was an *interne du service* at Bicêtre under M. Baillarger
- Animal experiments were conducted under M. Marcé's direction
- 1864 paper uses adjectival "absinthique" and "épilepsie absinthique" — the noun-form "absinthisme" not found in passages read; consistent with project source-map's claim that the noun-form reifies later (Magnan 1874)
- Conditional framing verified verbatim: "on aurait raison de penser que… une simple coïncidence"
- Case-patient: "C... (Louis)" — wine merchant (corrects project source-map's "Charles" transcription error)
- Animal experiments use **essence d'absinthe** (concentrated wormwood oil), NOT finished absinthe beverage

### 4.3 Magnan 1871 — *épilepsie absinthique* reification

**Status: PARTIAL.** The 1864 paper already uses "épilepsie absinthique" adjectivally (verified). The reified-noun-form *absinthisme* dates to Magnan 1874 *De l'alcoolisme* per project source-map. The dispatch reference to "1871" specifically may refer to a precursor article to the 1874 book; verification requires direct Magnan 1871 text (not pulled this session). See "Open questions" §9.

### 4.4 Lanfray 1905

**Status: CORROBORATED with a critical revisionist finding.**

Per Studer ch010 (extracted at `…/pdfs/scanned_Studer_2024_ch010/extracted_text.md` pp. 178–182) and Heimberg 2000 primary source:

- 28 August 1905, Commugny, canton Vaud: triple homicide of Lanfray's wife + two daughters
- Initial Aug 29 *Gazette de Lausanne* report did NOT mention absinthe ("L. was a drinker and debauched" — that was it)
- Defense psychiatrist Mahaim introduced the absinthe-cause framing 6 months later at trial; this was contested by court witnesses (Rochaix: "He drank like everyone else")
- **Heimberg's primary-source verbatim (this session):** "Peu importait d'ailleurs que le vigneron n'eût pas consommé de «Fée verte» le jour de son crime…" = "It hardly mattered that the wine-grower had not consumed any 'Green Fairy' on the day of his crime…"
- Heimberg further reproduces *Courrier de Genève* (3 Sept 1905) acknowledging: "Lanfray n'avait pas bu d'absinthe dans l'après-midi du crime: il n'avait consommé… qu'un litre de vin avec quelques compagnons de bouteille" = "had not drunk any absinthe on the afternoon of the crime: he had only consumed… a litre of wine with a few drinking companions"
- Studer's verdict (ch010 p. 180): "The question about what had caused Lanfray's drunkenness on that 28 August 1905 cannot be definitively answered. The only thing that is certain is that he consumed large amounts of alcohol other than absinthe that day."

**The Lanfray case as ban-trigger is corroborated; the absinthe-attribution of the case is *contradicted* by primary sources, and that contradiction strengthens (not weakens) the scapegoat-construction claim.**

### 4.5 Padosch ~1% / ~70% figures

**Status: CORROBORATED.** Per `summaries/Padosch_2006.md` Key Claim #4: "70.3% were diagnosed 'chronic alcoholics,' but only 1.0% presented absinthism symptoms" — Paris central admission service, 16,532 patients, 1867–1912.

### 4.6 Lachenmeier thujone

**Status: CORROBORATED.** Per `summaries/Lachenmeier_2008.md` Abstract:
> "Thirteen samples of authentic absinthe dating from the preban era… The total thujone content of preban absinthe was found to range between 0.5 and 48.3 mg/L… The authors conclude that the thujone concentration of preban absinthe was generally overestimated in the past."

Critical complementary finding (p. 3080): "Besides the lack in chemical evidence about the toxicity of preban absinthe, the recent work of Luauté… proved that **the epidemiological evidence is also completely missing to distinct this syndrome from general alcoholism**."

### 4.7 BenSlimane et al. 2025 — "Scapegoating in Stigma Construction"

**Status: OUTSTANDING — NEVER ANALYZED.**

`…/Articles/BenSlimaneEtAl-ScapegoatingInStigmaConstruction-2025.pdf` is on disk but never read by this project. The title directly matches the scapegoat-construction framing of Claim 5. Flagged for Phase 2 cheap-scan1 work.

---

## 5. Temperance double standard (Claim 6) — corroboration status

### 5.1 The Valais "wholesome drink vs distilled poison" passage

**Status: CORROBORATED — verbatim primary source.**

Per `Notes/Milliet Translations.md` BBl 1907 VI 345 (page 5 of the Federal Council Message):

**State Council of Wallis (Valais), to the Federal Council on the absinthe initiative:**

> "We are fortunately far from being one of the Swiss cantons in which the use of the green liqueur is most widespread. As cultivators of vineyard land, **our preference goes to the excellent produce of our hills, which provides us with a more wholesome drink than the distilled poison**, however much it may be diluted. But we must reckon with the price of the goods, which stands in proportion to quality."

— Federal Council Message on the Absinthe-Ban Popular Initiative, 9 Dec 1907, BBl 1907 VI 345 (Milliet Translations.md). **Adverse-witness quality: the wine-canton's own state council frames the double standard verbatim in an official 1907 government submission.**

### 5.2 Cahannes 1981 corroboration — "noble drink" / monopoly-carve-out / institutional encoding

**Status: CORROBORATED.** All verified verbatim in `notes/11_claim_2_4_cultural_disdain_distilled_spirits.md`:

- *Cultural framing:* "Hard liquor represented evil, and deterioration, whereas wine was and still is 'the noble drink.'" (Cahannes p. ~53, .txt lines 665–676; needs PDF page-pinning — flagged for Phase 2)
- *Institutional carve-out:* "The first law on alcohol gave the Confederation the right to legislate over the distillation of **potatoes and cereals exclusively**." (Cahannes lines 339–345)
- *Temperance internalization:* "[T]he temperance societies required from their members total abstinence from distilled beverages only, **and moderation in the use of wine**." (Cahannes lines 324–326)
- *Discursive focusing:* "the discussions of that time about the evils of drinking focused only on distilled spirits consumption" (Cahannes lines 282–293)

### 5.3 Swiss Alcohol Law (1885, 1932) statutory encoding

**Status: CORROBORATED.** Per Cahannes 1981 (lines 339–345, lines 526+ on the 1932 extension) + Milliet 1907 (BBl 343–344, BBl 355–366). The 1885 law gave the Confederation monopoly only over potato/cereal distillates; wine, marc, and fruit-derived distilled spirits were structurally outside federal control. The 1932 extension added other distilled spirits but the wine/cider/beer fermented beverages remained outside. The fermented-vs-distilled distinction is statutory, not merely cultural.

### 5.4 Prestwich verbatim on natural-fermented vs unnatural-distilled framing

**Status: PARTIAL.** Per `notes/08_prestwich_full_relevance.md`, p. 308 verbatim ("cognac with its powerful parliamentary protection, were almost never attacked") establishes the protected-wine-distillate carve-out. Direct "natural fermented vs unnatural distilled" verbatim from Prestwich 1979 still needs pulling — flagged in `notes/11` (verification flag #2). Phase 2 work.

---

## 6. Berthoud — "55-year" verdict + Fr. 87,000 reconciliation (Claim 4)

**Status: RESOLVED via paper-trail trace.** The dispatch flagged this as outstanding, but prior project work had already audited it on 2026-05-13 (R1/R2 read) and 2026-05-20 (typo-caught session). The `berthoud_1969_fee_verte_summary.md` (322 lines, Q1–Q14) provides comprehensive coverage. This section consolidates the verdict.

### 6.1 The "55-year" framing — what it was

A proposed **contribution-statement upgrade**: replace the paper's existing "first formal test of Prestwich's 45-year-old qualitative observation" (Prestwich 1979 → 2024 = 45 years) with "first formal test of Berthoud's **55**-year-old qualitative observation" (Berthoud 1969 → 2024 = 55 years). The upgrade depended on Berthoud having articulated the wine-temperance coalition thesis in 1969 — pushing the predecessor back a decade and strengthening the paper's framing claim.

### 6.2 Why the "55-year" upgrade COLLAPSES — verbatim from Berthoud summary Q1

The 2026-05-13 R1/R2 librarian dispatch concluded — and the comprehensive summary confirms — that **Berthoud does not advance a wine-temperance coalition thesis**.

From `berthoud_1969_fee_verte_summary.md` Q1 (Wine-industry-temperance coalition):

> "**Not explicitly addressed; no version of the Bootlegger-and-Baptist coalition is asserted.** Berthoud does not characterize the wine industry as a player in the prohibition coalition. The wine industry is invisible in her account — no Fédération des Vignerons, no Vaudois winegrower mobilization (despite the fact that her hero-victim Landrey/Lanfray is repeatedly described as 'un jeune agriculteur,' and the Vaudois Grand Conseil law's enabling-vote constituency would have included viticultural interests). She structures the opposition as: **Pro-prohibition:** Temperance societies, the women of Vaud and Geneva, the medical profession… **Anti-prohibition:** The distillers organized as the 'Union des intéressés à la question de l'absinthe' (Fleurier), the 'Ligue pour la défense de la liberté économique'… The opposition is framed as **distillers + classical-liberal libertarians**, not as **distillers + winegrowers**."

The summary's explicit null-finding framing (same Q1):

> "**Important null finding:** Despite writing 50 years after the events, with access to Neuchâtelois archival material and recourse to family memoirists, Berthoud does not assemble or even hint at a 'vine-growers benefited from absinthe prohibition' thesis. If a Swiss historian writing in 1969 had heard local oral tradition of wine-industry rent-seeking, this paper would be the most likely place for it to surface. Its absence is therefore mildly informative."

**Verdict:** The "55-year" upgrade collapses. The paper's contribution statement stays "first formal test of **Prestwich's** 45-year-old qualitative observation."

### 6.3 What Berthoud DOES document — the fiscal Régie as anti-prohibition Bootlegger

Berthoud's structural contribution is documenting the **Régie fédérale de l'alcool** as a fiscal stakeholder *opposing* prohibition (i.e., a Bootlegger AGAINST the ban, not a Bootlegger in coalition with temperance Baptists).

From `berthoud_1969_fee_verte_summary.md` Q9 (Multi-Bootlegger coalition):

> "The federal **Régie de l'alcool** itself — earning ~CHF 87,000/year of margin on absinthe-bound alcohol sales pre-prohibition (p. 654), and a vocal opponent of prohibition in the parliamentary debate. The federal fiscal apparatus is thus a *Bootlegger*-style stakeholder, **not in coalition with temperance but actively opposing prohibition**."

This is a Smith & Yandle 2014 multi-coalition framework finding — a *competing* Bootlegger to the wine industry, on the *anti-prohibition* side. **This is the genuine Berthoud contribution to our framework**, and it complements the coalition narrative rather than substitutes for it.

### 6.4 The Fr. 87,000 vs Fr. 872,850 reconciliation — SOLVED (transcription error)

From `2026-05-20T22-26-25-recap-price-librarian-success-berthoud-typo-caught.md`:

> "Berthoud 1969's 'Fr. 87,000/year' is a **10× typographic error**."

**The math closes inside Berthoud's own quote**, from p. 654 verbatim (per `berthoud_1969_fee_verte_summary.md` Q2):

> "La Régie fédérale qui en fournit bon an mal an **7500 quintaux** pour la fabrication de l'absinthe, gagnant ainsi **116 francs par quintal**. L'interdiction lui ferait perdre annuellement **87000 francs** auxquels s'ajouteraient près de 100000 francs de droits de douane sur l'alcool importé."

Arithmetic:
- **7,500 × 116 = 870,000** (Berthoud's own numbers, correct multiplication)
- **7,500 × 116.38 = 872,850** (Milliet's more precise per-quintal margin, BBl 1907 VI 365)
- Berthoud wrote "**87000**" instead of "**870,000**" or "**872,850**" → **10× decimal/digit transposition typo**, not a substantive disagreement with Milliet

**No reconciliation memo needed.** The 10× gap is a within-Berthoud arithmetic inconsistency (her own multiplication gives 870,000; she wrote 87,000). Milliet's Fr. 872,850 is the primary number. Citation rule (per the 2026-05-20 recap):

> "Cite Milliet (Fr. 872,850) directly in §2; if citing Berthoud, flag the 87,000 figure as a transcription error in a footnote."

This is the SECOND of three documented "10× error pattern" incidents in the project's citation-verification corpus (alongside Head-König "19,457 hL" and "Antonin Milliet" first-name confabulation; Lesson L4 in the 2026-05-20 recap codified this as a generalizable heuristic).

### 6.5 The insider caveat — partly real but not commercial conflict

The dispatch's "insider caveat" framing — "she is plausibly a Val-de-Travers insider (firm names match) → useful but not a neutral source" — is partly correct but should be sharpened.

Per `berthoud_1969_fee_verte_summary.md` TL;DR:

> "Dorette Berthoud is a **Neuchâtel-based amateur cultural historian** writing for the *Schweizerische Zeitschrift für Geschichte*. Her 1969 piece is the first Swiss-historian scholarly synthesis of the absinthe story I have located — predating Prestwich (1979) by a decade. It is a 24-page narrative essay tracing absinthe from antiquity through the prohibition campaign of 1906–1908 to the postwar smuggling cases of 1957 and 1960 in the Val-de-Travers. The piece is **regionally Neuchâtel-centric** (the canton of absinthe production); it draws heavily on Neuchâtelois archival sources, oral history from the Béroche subregion, the Petitpierre family memoir tradition, and the *Courrier du Val-de-Travers* trial reports."

The Val-de-Travers firm list on pp. 643–645 includes "**Berthoud-Clerc (Louis, 1827)**" — family-name resonance with the author, but no direct evidence she's a Berthoud-Clerc heir. The bias to flag is **regional / Neuchâtel-centric**, not **commercial-conflict-of-interest**. Treat the piece as Val-de-Travers regional cultural history with mild residency bias. It is valuable for production data and parliamentary detail; it is not valuable for cross-canton political-economy analysis.

### 6.6 Side finding worth surfacing for §2 — Berthoud's Lanfray is on the wrong side of the day-of consumption question

Berthoud states verbatim (p. 651) that Lanfray drank absinthe **"Dès l'aube, pour se désaltérer"** (from dawn) on the murder day. This is the popular-press / Mahaim narrative that **Heimberg 2000 later corrects** using the same press archives.

For Paper 1's §2 Background: **cite Heimberg's correction, not Berthoud's uncorrected version**, on Lanfray's day-of consumption. This is now flagged in §11 Discrepancies (item 6 added below).

### 6.7 Net Berthoud verdict for the corroboration report

| Sub-question | Verdict |
|---|---|
| Does she support a wine-temperance coalition? | **NO** — explicit null finding (Q1) |
| Does the "55-year-old observation" upgrade survive? | **NO** — collapses; paper stays "Prestwich 45-year" |
| Reconcile Fr. 87,000 vs Milliet's Fr. 872,850 | **10× transcription error in Berthoud** — cite Milliet, footnote Berthoud |
| Insider caveat | **Regional (Neuchâtel), not commercial** |
| What DOES Berthoud contribute? | **The Régie as an anti-prohibition fiscal Bootlegger** (Q9) — complements multi-coalition framework |
| Lanfray treatment | **Uncorrected** — cite Heimberg's 2000 correction, not Berthoud's 1969 version |

---

## 7. Political-feasibility selection (Claim 7) — corroboration status

**Status: CORROBORATED across multiple sources.**

### 7.1 Industry size — small

- **Studer 2024 ch010 p. 178:** "200 factory jobs + 600 farming jobs lost in Val-de-Travers" — 800 total directly-impacted persons in the entire absinthe industry, in a country of ~3.5M population in 1908. ~0.02% of the national workforce.
- **Milliet 1907 BBl 360–361:** firm-level table identifies 40 absinthe-manufacturing firms across NE + GE + BS + VD + SZ + ZG + FR + VS (8 cantons total, but heavily NE-concentrated). National total absinthe production: 72,575 hL over 1902–1906 (= 14,515 hL/year). This compares to Swiss annual wine production of ~1,000,000 hL.

### 7.2 Geographic concentration — extreme

- **Per the c-metrics-absinthe1 regression notebook (lit-positioning §1.3 and §3):** NE ≈ 58.8% of national absinthe output; HHI ≈ 3,956 (high concentration in HHI-merger-screen terms).
- **Per Milliet 1907 BBl 360 (Milliet Translations):** "Most of the absinthe manufacturers of the Travers Valley make liqueurs which contain no extract of the absinthe plant" — Federal Council's own discussion of the Val-de-Travers concentration.
- **Per Cahannes 1981 p. 44:** "absinthe, particularly popular in the **French part of the country**" — Cahannes attests the geographic concentration in the French-speaking cantons.

### 7.3 Political weakness — implicit not explicit

- **Federal Council's own opposition was overridden by popular vote** (BBl 351: "we recommend rejection… that the initiative-petition concerning the prohibition of absinthe be rejected"). The Federal Council's recommendation was for rejection on grounds that included (a) absinthe-consumption being concentrated in 5 cantons only, (b) the Vaud + Geneva cantonal bans already addressing the regional problem, (c) the fiscal cost (Milliet's Fr. 872,850/yr).
- **Despite this:** the initiative passed (popular vote 23 May 1908: 63.5% yes; cantonal: 18.5 of 22 cantons yes).
- **Interpretation:** the absinthe industry was politically weak enough that even the Federal Council + the fiscal-loss argument + the regional-concentration argument could not override popular mobilization. This is the political-feasibility signal.

### 7.4 Sager 2009 methodological precedent

`Sager2009_Governance_and_Coercion.pdf` is in project; modern cantonal-OLS-on-N=26 analysis confirms the methodological viability of canton-level cross-section with controls (problem prevalence, socio-economic, political, institutional, bureaucratic). Not directly about 1908 but methodologically validating.

---

## 8. Studer comprehensive scan status

### 8.1 Scanning status (PDF chapters already processed)

Per the worktree directory `…/pdfs/scanned_Studer_2024_ch*/`:

| Chapter | Scanned? | Summary? | Status |
|---|---|---|---|
| ch001 (Origins of Absinthe) | NOT YET | NO | Phase 3 |
| ch002 (Glorious Absinthe — colonial Algeria) | NOT YET | NO | Phase 3 |
| ch003 (Introduction body) | ✓ scanned | NO | Cross-check needed |
| ch004 (Switzerland Val-de-Travers — Mythical Origins) | ✓ scanned | ✓ summary | DONE |
| ch005 (Glorious Absinthe ch.2) | ✓ scanned | NO | Cross-check needed |
| ch006 (chapter 3 of book) | ✓ scanned | NO | Cross-check needed |
| ch007 (chapter 4) | ✓ scanned | NO | Cross-check needed |
| ch008 (Undesirable Consumption) | ✓ scanned | NO | Cross-check needed |
| ch009 (Weapon of Mass Destruction) | ✓ scanned | NO | Cross-check needed |
| ch010 (Banning the Opium of the West) | ✓ scanned | (extracted-text only) | Lanfray narrative extracted; full summary not written |
| ch011 (Endnotes) | ✓ scanned | ✓ summary | DONE — confirmed it IS endnotes (per 2026-05-22 prior librarian work) |
| ch012 (chapter 9?) | ✓ scanned | NO | Cross-check needed |
| ch013 | NOT YET | NO | Phase 3 |

### 8.2 What needs doing for the Studer comprehensive scan

The dispatch asks to **(a) corroborate claims 1–7** + **(b) surface any content not already captured.** Given that 8 of 13 chapters are scanned-but-not-summarized, the work for Phase 2 is:

1. For each scanned-but-unsummarized chapter, **grep the extracted_text.md for the seven claim-relevant keywords**: winegrowers, wine, fermented, distilled, scapegoat, Magnan, Marcé, Lanfray, Cahannes, Régie, Milliet, Vaud, Neuchâtel, Val-de-Travers, Pernod, absinthism, Lemoine, phylloxera, industrial alcohol, NE, GE
2. Pull verbatim passages that *extend* what's already in the project notes
3. Flag passages that *contradict* current claim formulations
4. For ch001 + ch002 + ch013 + front-matter not yet scanned: run cheap-scan1 --safe

Estimated effort: **6–10 hours of focused work** for the cross-check + scan; **not feasible in one response.**

### 8.3 Provisional Studer-corroboration findings (from ch004, ch010, ch011 already done)

From the work this session and prior, Studer corroborates:

- **Claim 5 (Lanfray narrative):** ch010 pp. 178–182 — extensive, decisive
- **Claim 7 (industry size):** ch010 p. 178 — "200 + 600 jobs lost"
- **Claim 6 (cultural disdain):** ch004 pp. 22–30 (headline verdict: chemistry refutes the categorical-toxicity case)
- **Claim 5 (adulteration/scapegoat material):** ch011 endnotes — citation chain for verdigris, copper, Marcé essence d'absinthe

**Cross-check against existing summaries** is needed but is Phase 2 work.

---

## 9. Open questions for the PI

1. **Magnan 1871 vs Magnan 1874:** The dispatch's "Magnan 1864/1871" reference — does the "1871" mean Magnan's 1871 article (and if so, do you have a citation), or is it a placeholder for the 1874 *De l'alcoolisme* book (in which the noun-form "absinthisme" reifies per project source-map)? I have the 1864 paper verbatim-verified but the 1871 piece is unpulled. **Action requested:** confirm which work you mean; if 1871 article, share the citation/file path.

2. ~~**Berthoud "55-year" claim phrasing:** Prior project work concluded this collapses. Before I re-read Berthoud cold, **action requested:** can you point me to the specific Berthoud passage that originally seemed to motivate the "55-year-old observation" upgrade?~~ **RESOLVED 2026-06-03 via project paper-trail trace.** Full verdict in §6 above. The "55-year" upgrade was a contribution-statement amplification (replace "Prestwich 45-year-old observation" with "Berthoud 55-year-old observation"); the 2026-05-13 R1/R2 audit + the comprehensive `berthoud_1969_fee_verte_summary.md` (Q1 explicit null finding) establish that **Berthoud does not advance the wine-temperance coalition thesis** → upgrade collapses → paper stays at Prestwich. Fr. 87,000 vs Fr. 872,850 reconciled as Berthoud's 10× within-piece transcription error (2026-05-20 typo-caught session).

3. **Phase 2 priority ordering:** of the outstanding items —
   - Berthoud reconciliation memo (Fr. 87,000 vs Fr. 872,850)
   - BenSlimane 2025 cheap-scan
   - Prestwich 1994 + 1997 cheap-scans
   - Studer chapter-by-chapter cross-check (8 chapters)
   - Magnan 1871/1874 verbatim pull

   **Which should I do first?** My default ordering would be: (a) Berthoud reconciliation (short, blocks a long-standing open item), (b) BenSlimane 2025 (the title is directly on-point for the scapegoat-construction framing and may add Claim 5 corroboration not in our existing sources), (c) Studer cross-check (largest, most distributed), (d) Prestwich 1994/1997, (e) Magnan 1871/1874. **Confirm or override.**

4. **The "white wine" mechanism (§2.7 above):** the Cahannes attestation specifies **white** wine. Does the c-metrics-absinthe1 regression infrastructure currently have a white-vs-red wine canton-level decomposition? If so, executing the white-vs-red split would sharpen the priority #1 mechanism into a *falsifiable canton-pattern test*. **Action requested:** confirm whether this exists or should be flagged for Paper 1 robustness.

---

## 10. Scope statement — what this report DOES and DOES NOT contain

### Done (this report, Phase 1)
- Full Cahannes deep-dive (§2) — priority #1 complete
- Heimberg p. 99 + fn. 12 verbatim & translation locked (§3)
- Scapegoat-chain corroboration drawing on this-session primary-source pulls (§4.1–4.6)
- Temperance double standard (Claim 6) corroboration from Milliet Translations + Cahannes (§5)
- Political-feasibility selection (Claim 7) corroboration from Studer + Milliet + Cahannes (§7)
- Provisional Studer corroboration summary from already-done ch004/ch010/ch011 (§8.3)

### Outstanding (Phase 2 — needs another work session)
- ~~Berthoud Fr. 87,000 reconciliation memo + "55-year" verdict~~ **DONE 2026-06-03** (§6 — RESOLVED via project paper-trail trace)
- BenSlimane 2025 cheap-scan (§4.7)
- Prestwich 1994 + 1997 cheap-scans (§1 row 2)
- Studer 8-chapter cross-check (§8.2)
- Magnan 1871/1874 verbatim pull (§4.3, §9.1)
- Prestwich 1979 explicit "natural fermented vs unnatural distilled" verbatim (§5.4)

### Outstanding (Phase 3 — depends on Phase 2 decisions)
- Studer ch001/ch002/ch013 cheap-scan1 --safe runs
- Newly-surfaced-content bullets from full Studer cross-check
- Reconciliation of discrepancies across all primary sources (final pass)

---

## 11. Discrepancies found between existing notes and primary sources

Catalog so far (will be extended in Phase 2):

1. **Magnan 1864 case patient — "C... (Louis)" not "Charles."** Project source-map (Tier-B #14) listed "Charles, 22-year-old ex-wine merchant"; the primary-source pull this session shows the redacted name is "C... (Louis)" and the occupation is *marchand de vins* (wine merchant). The age "22" is not visible in passages I read. **Already documented** in `notes/12` verification section.

2. **Berthoud Fr. 87,000 vs Milliet Fr. 872,850.** ~10× gap. Likely transcription error in Berthoud. **Reconciliation memo uncommitted as of 2026-06-03.** Phase 2.

3. **Cahannes priority #1 page citation — was "lines 10-11" in bibtex note; is journal pp. 44–45.** Corrected in this report (§2.1–2.2). Bibtex `note` field should be updated.

4. **Lanfray "drank 2 glasses of absinthe + 4 L wine on the murder day" framing.** Popular narrative is contradicted by Heimberg primary source + court witnesses + Studer's own verdict. The Mahaim claim about "4 L wine + many absinthes" describes Lanfray's CHRONIC HABIT, not the murder day. **Documented** in `notebooklm/synthesis/wine-lobby-banned-absinthe-2026-05-13.md` (Claim 7 — CONTRADICTED).

5. **The "Charles, 22-year-old wine merchant" appears in Magnan dispatch summary at lit-positioning §2 (line 50):** "Magnan (1864, *Union médicale*): clinical case ('Louis C…', Bicêtre/Baillarger service)" — this is now correct. Lit-positioning doc itself has been updated to the verified "Louis C..." — good. No further correction needed there.

6. **Berthoud's Fr. 87,000 is a 10× transcription error within her own piece.** Berthoud p. 654 quotes the Régie selling "7500 quintaux × 116 fr/quintal" (= 870,000) but writes the annual loss as "87000 francs." This is an inconsistency *within* her own arithmetic, not a disagreement with Milliet. Cite Milliet's Fr. 872,850 directly; if citing Berthoud, flag the typo in a footnote. **Resolved 2026-05-20.**

7. **Berthoud's Lanfray account contradicts Heimberg 2000.** Berthoud p. 651 says Lanfray drank absinthe "dès l'aube" (from dawn) on the murder day — the popular-press / Mahaim narrative. Heimberg 2000 corrects this using the same press archives. **For Paper 1 §2:** cite Heimberg, not Berthoud, on day-of consumption. Berthoud also calls Lanfray a "jeune agriculteur" (young farmer), not "vigneron" (winegrower) — both terms appear in contemporary sources; the Vaud commune was mixed agricultural/viticultural; the historical record (per Studer 2024 and Mahaim primary) is closer to "vigneron." Flagged in §6.6 above.

---

## 12. cheap-scan1 outputs linked

For chapters already scanned this session and prior, the cheap-scan1 outputs live at:
- `Brainstorm-Absinthe/.claude/worktrees/quizzical-swirles-0ddf49/Supplementary/absinthe_examination/pdfs/scanned_Studer_2024_ch003/`
- `…/scanned_Studer_2024_ch004/` (summary in `…/summaries/Studer_2024_ch004.md`)
- `…/scanned_Studer_2024_ch005/` through `…/scanned_Studer_2024_ch012/` (no summaries yet)
- `…/scanned_Prestwich_1979/`
- `…/scanned_Lachenmeier_2008/`
- `…/scanned_Marrus_1974/`
- `…/scanned_ScheckSmith_Whiskey/`

All `notes.md` files exist within each `scanned_*/` directory per cheap-scan1 convention.

---

## 13. Wine-coalition assertion inventory — who said it, how, with what evidence

The dispatch's Claim 1 (Cahannes priority) prompted a corpus-wide sweep for wine-coalition assertions across the review inventory. This section catalogs **who** has asserted wine-coalition presence, **how** (with what framing), and **with what evidence type** (primary archival vs retrospective inference vs explicit null finding). The asymmetry between France and Switzerland in the source base is itself the paper-relevant finding.

### 13.1 France — explicit attestation by multiple sources with dated archival evidence

**Luauté 2007** (*L'Évolution Psychiatrique* 72(3):515–530, PDF p. 11) — direct attribution + primary-event chronology:

> "[T]his movement also included… **above all, winegrowers dissatisfied with the competition and who resented the poor sales of their product while absinthe sales flourished. They constituted a powerful lobby.** In 1906, the National Agricultural Society passed a resolution calling for 'the prohibition of absinthe in the name of wine,' and in 1907, a large national demonstration was organized at the Trocadéro, with the slogans **'for wine against absinthe' and 'working against absinthe is working for starving winegrowers.'**"

— Luauté 2007 PDF p. 11. The framing is *causal* (winegrowers as "a powerful lobby"), *proactive* (NAS passed a resolution, organized a demonstration), and *primary* (the most important non-medical pro-prohibition actor named).

**Luauté 2007** also documents the **30 January 1907 French finance law** as a two-layer wine-favoring regulatory wedge 8 years before the total ban (PDF p. 12):

> "[T]he government, through the finance law of January 30, 1907, found a clever compromise by imposing a tax of 50 francs per hectoliter of alcohol on spirits (the very heavy tax mentioned by Sérieux), while **simultaneously proposing the exclusive use of wine-distilled alcohol in the production of absinthe**."

This is a *mandatory wine substrate* requirement — wine-industry capture via substrate-substitution mandate.

**Chapuis 2013** (*Bulletin de l'Académie nationale de médecine* 197(2):515–521, j. p. 519) — period-political naming of wine rent-seeking:

> "Mais non loin de là [du Trocadéro 1912] une contre-manifestation était organisée par Girod, député de Pontarlier, qui **dénonçait en particulier l'affairisme des marchands de vin**."

— Chapuis 2013, j. p. 519. The Pontarlier deputy named "l'affairisme des marchands de vin" (wine-merchant rent-seeking) in 1912 — period-internal political acknowledgment of the wine-industry-Bootlegger framing.

**Chapuis 2013** (j. p. 520) — the selective-exemption smoking gun:

> "**Curieusement son application fut évitée au vermouth et à la grande chartreuse**, pourtant riche en thuyone."

The 1915 French ban exempted **vermouth (wine-based)** and **Grande Chartreuse (monastic)** despite their thujone content. This is the cleanest Bootlegger-favored-selective-exemption pattern in the corpus.

**Prestwich 1979** (`Hist. Refl.` 6(2), p. 308, per `notes/08_prestwich_full_relevance.md`) — wine-distillate carve-out via parliamentary protection:

> "[O]nly absinth was the object of such a seemingly comprehensive scientific indictment; other aperitifs, such as amers and bitters, were often denounced, but they suffered no clear scientific condemnation, while **the distilled drinks made from wine, such as cognac with its powerful parliamentary protection, were almost never attacked.**"

— Prestwich 1979 p. 308. The cognac protection establishes that the wine-vs-spirits distinction was politically rather than scientifically motivated.

**Marrus 1974** (*J. Soc. Hist.* 7(2), per `summaries/Marrus_1974.md` Key Claim #8) — ideological infrastructure:

> "Wine vs. spirits ideological distinction was load-bearing — 'boissons hygiéniques' (wine, beer, cider) were exempt from temperance targeting; the campaign focused on 'alcool' (distilled). This is the ideological infrastructure that made selective absinthe targeting possible."

Marrus is consumption-history, not coalition-history; this is the ideological substrate that the wine coalition exploited, not the coalition itself.

### 13.2 Switzerland — partial attestation + multiple explicit null findings

The Swiss source picture is structurally different. **Contemporary observers (Pictet 1906) and retrospective historians (Berthoud 1969, Heimberg 2000) do NOT identify the wine industry as a visible coalition partner.** Only one secondary source (Cahannes 1981) explicitly names the winegrower coalition, and one primary source (Valais Staatsrat 1907) gives the wine-industry self-statement. One primary federal record (Fonjallaz Kunstwein motion, 31 March 1908) shows direct wine-bench legislative action ON THE SAME DAY as the absinthe debate.

#### 13.2a Cahannes 1981 — the retrospective attestation (verified this session, §2 above)

Already covered in §2. The verbatim winegrower attestation appears at **journal pp. 44–45** (v2.pdf pp. 9–10; .txt lines 389–405).

#### 13.2b Valais Staatsrat 1907 — wine-industry self-statement (primary federal record)

Per Milliet Translations BBl 1907 VI 345:

> "Nous sommes heureusement loin d'être l'un des cantons suisses où l'usage de la liqueur verte est le plus répandu. **En tant que cultivateurs de coteaux de vignes, notre préférence va au produit excellent de nos coteaux**, qui nous fournit une boisson plus saine que le poison distillé…"

The Valais (Wallis) State Council, writing in its OFFICIAL submission to the Federal Council during the 1907 evaluation of the absinthe initiative, frames its support for the ban explicitly as "**as cultivators of vineyard land**, our preference goes to… a more wholesome drink than the distilled poison." This is the wine industry's own statement of position, in a primary federal record, with the cultural-economic asymmetry framed verbatim. Per the 2026-05-13 R2 findings (handoff line 98): "**cleanest single articulation of wine-industry motivation in the entire Swiss federal corpus.**"

#### 13.2c Fonjallaz Kunstwein motion, 31 March 1908 — primary legislative action

Per the 2026-05-13 R2 findings (handoff line 94):

> "**Fonjallaz Kunstwein Motion of 31 March 1908** (BBl 1908 II 748 item 49) voted by Vaud-Valais wine-canton bench on the **SAME DAY** as the absinthe debate. **Direct legislative evidence of Swiss wine-industry political action.** Corrects Round-1 'Swiss-side scholarly silence' pattern."

A "Kunstwein" (artificial wine) motion brought by the Vaud-Valais wine-canton bench on the same day as the absinthe debate is direct primary-source evidence of wine-coalition organized parliamentary action that the secondary scholarship (Berthoud, Heimberg, Pictet) systematically missed. **This is the strongest single piece of primary-source evidence of Swiss wine-coalition political activity at the federal level circa 1908.**

#### 13.2d Pictet 1906 — important NULL finding (contemporary Swiss observer)

Per `LitDive_5-13-26/summaries/pictet_1906_suisse_prohibition_summary.md` Q1:

> "**Indirectly addressed.** The article documents the OPPOSITION side (absinthe producers + cafetiers + Val-de-Travers agriculturists) extensively, and the PRO-PROHIBITION side (Croix Bleue, abstinence societies, anti-alcoolisme congress) extensively — but does NOT explicitly identify the Swiss wine industry as a participant in the prohibition coalition. **This is significant.**"

> "**For our Bootleggers-and-Baptists framework: Pictet's account is consistent with vine-growers being a quiet beneficiary or fellow-traveler rather than a visible mover.** The visible 'bootlegger' coalition in Pictet's account is the Croix Bleue + abstinence movement + organized women — not the wine industry."

Pictet writes IN 1906 from inside Switzerland as the journal's Swiss correspondent — he is the closest thing to a real-time political observer. The wine-coalition is invisible in his account.

#### 13.2e Berthoud 1969 — explicit NULL finding (retrospective)

Per `berthoud_1969_fee_verte_summary.md` Q1 (cited in §6.2 above):

> "**Not explicitly addressed; no version of the Bootlegger-and-Baptist coalition is asserted.** Berthoud does not characterize the wine industry as a player in the prohibition coalition. **The wine industry is invisible in her account…** **Important null finding:** Despite writing 50 years after the events, with access to Neuchâtelois archival material… Berthoud does not assemble or even hint at a 'vine-growers benefited from absinthe prohibition' thesis."

#### 13.2f Heimberg 2000 — NULL by argument

Heimberg's p. 99 sentence "[the ban] did not really affect any *major* economic interests" is the most directly *anti*-wine-coalition statement in the secondary literature. The paper's response (per lit-positioning §1.2) is to PRECISIFY: not *aggregate* majeur economic interests, but the *cross-canton pattern* — which Heimberg's own footnote 12 (NE+GE producer cantons voted against) partially destabilizes from his own evidence.

#### 13.2g Lemoine 1911 — wine NULL but institutional CONFIRMATION

Per `LitDive_5-13-26/summaries/lemoine_1911_hygiene_militaire_summary.md` Q1/Q2: Lemoine (a French military hygienist writing about Swiss alcohol policy) does NOT mention wine-industry coalition activity, but he DOES confirm the Swiss federal monopoly's scope (p. 246):

> "Le système suisse… [La Confédération] n'a pris le monopole que pour les eaux-de-vie de grains et de pommes de terre. **L'eau-de-vie de vin, de marcs, de fruits, etc., n'en fait pas partie**."

The institutional carve-out (wine exempt from federal monopoly) is corroborated as a Swiss policy fact by a contemporary French outside observer.

### 13.3 The asymmetry — and why it is the paper's value-add

**France:** explicit wine-coalition presence, documented by multiple sources with primary archival evidence (NAS 1906 resolution, Trocadéro 1907, finance law 1907, Girod 1912 counter-demo, Vermouth/Chartreuse 1915 exemption). The B&B reading for France is *observationally visible*.

**Switzerland:** explicit wine-coalition presence is **mostly invisible to contemporary observers** (Pictet 1906) and **mostly invisible to retrospective historians** (Berthoud 1969, Heimberg 2000). What DOES exist:
- Cahannes 1981 retrospective attestation (single sentence, pp. 44–45)
- Valais Staatsrat 1907 wine-industry self-statement (primary, cleanest single articulation)
- Fonjallaz Kunstwein motion 31 March 1908 (primary, direct legislative action on absinthe-debate day)

**This asymmetry is exactly the paper's value-add.** The cross-canton vote pattern in Switzerland reveals what contemporary observers couldn't see directly. The wine industry was a structural-electoral coalition partner whose footprint shows up in the cross-canton variation in yes-shares (conditional on language and religion) — not in the visible mobilization that Pictet, Berthoud, and Heimberg documented.

The paper's Bootleggers-and-Baptists reading does NOT require the wine industry to have been *visibly* organized in 1908; the structural-electoral signal is the empirical content. The Cahannes attestation, the Valais self-statement, and the Fonjallaz motion provide three independent qualitative anchors that confirm the structural-electoral test is identifying something real rather than fitting noise.

### 13.4 Implications for the manuscript

For §1.2 (the puzzle and existing accounts) and §2.6 (political feasibility):

1. **The wine-coalition story is empirically GROUNDED for France** — Luauté 2007 and Chapuis 2013 provide the dated archival evidence
2. **The Swiss wine-coalition story rests on three independent anchors** — Cahannes 1981 (secondary attestation), Valais Staatsrat 1907 (primary self-statement), Fonjallaz Kunstwein motion 1908 (primary legislative action)
3. **Contemporary observers (Pictet 1906) and retrospective historians (Berthoud 1969, Heimberg 2000) DO NOT see the Swiss wine coalition directly** — and the paper's cross-canton empirical strategy is exactly the right tool for surfacing what they missed
4. **This converts the "absence of wine-industry mention in secondary scholarship" from a problem into a contribution** — the paper is filling the gap that 60+ years of Swiss-focused secondary scholarship left open

For the Heimberg engagement: his "no major economic interests" claim is consistent with the contemporary-observer null findings (Pictet, Berthoud). The cross-bloc producer differential (≈ −11.2 pp) and the canton-level wine-share coefficient are the *new* evidence that the secondary scholarship had not assembled.

### 13.5 Acquisition implications

- **Delahaye 1983/1987** *L'Absinthe, Histoire de la fée verte* (Berger-Levrault) — Luauté and Chapuis both cite this as the primary source for the parliamentary debate coverage. Highest-priority next-acquisition target for paper-2 (France offshoot).
- **Couleru 1918** *Au pays de l'absinthe…* — Pontarlier-prosecutor statistical-and-political analysis. Yves Guyot preface explicit on the Bootlegger framing. Findable via Gallica.
- **Aron 1994** "Did you know? The lesson of absinthe" *Med. et Nut.* 30(5) — cited by Chapuis as precursor to the 2013 institutional retraction. Worth tracking.
- **The 1907 Trocadéro proceedings + 1906 National Agricultural Society resolution text** — primary archival material for the French wine-coalition. Locatable via Gallica's *L'Agriculture nouvelle* and trade-association archives.

### 13.6 NEW additions from Phase 2 scans (2026-06-03 follow-up)

**Two French smoking-gun primary attestations** added via BenSlimane et al. 2025:

**(a) Cheysson 1906 — French Anti-Alcoholic League president endorsing wine industry (BenSlimane p. 22, quoting *L'Étoile Bleue* 1906):**

> "Emile Cheysson, the president of the French Anti-Alcoholic League, publicly endorsed the wine industry: 'It is understood that this wish (to ban absinthe) is inspired by the difficult situation of our winemakers because of the competition [caused] by absinthe.'"

**(b) Minister of Finance, 15 December 1906 parliamentary debate (BenSlimane p. 33 fn. 6):**

> "I will say that for budget reasons my predecessor and the Budget Committee had considered taxing absinthe not only because of its harmful nature, but also to offset a 1900 law that reduced the tax on wine. The decrease in consumption will be more substantial for absinthe. **Those who will benefit, I repeat again, will be the winemakers.**"

**Both require primary-source verification** (*L'Étoile Bleue* 1906 + *Journal Officiel — Débats parlementaires* 15 Dec 1906) before manuscript citation, per the project's `citation-verification.md` discipline.

**One Swiss smoking-gun secondary attestation** added via Studer 2024 ch010 p. 176:

> "the head of the Swiss government – the Federal Council – agreed that it was reasonable to ban the consumption, but was **unwilling, due to economic concerns, to restrict the production**."

This parallels the French Minister of Finance admission — both governments explicitly acknowledged producer-coalition material interests in regulatory deliberations.

**One contemporary press observation** added via NYT 1915 quoted in Studer 2024 p. 174:

> "the people of Pontarlier felt 'considerably aggrieved at the suppression of the absinthe traffic while the **bouilleurs de cru** … are still permitted to flood the country with inferior spirits.'"

— Strongest contemporary press attestation of asymmetric-singling-out in the corpus.

**One legal codification** added via Prestwich 1997 p. 1258:

> "By 1900 the wine industry had used its powerful political influence to have wine, beer and cider legally declared 'hygienic' drinks, a designation that meant lower taxes, a cheaper beverage, and an implied medical endorsement."

— The 1900 *hygienic drinks* designation is the institutional anchor for Claim 6.

### 13.7 Permanent reference file

**The full wine-coalition attestation inventory — with verbatim quotes (original language + English translation), source citations, page references, verification status, and claim relevance — lives at:**

```
Brainstorm-Absinthe/.claude/worktrees/quizzical-swirles-0ddf49/Supplementary/absinthe_examination/notes/14_wine_coalition_attestation_inventory.md
```

This file is the **permanent project reference** for cross-referencing wine-coalition evidence. Future librarian dispatches should cite it directly; the manuscript should pull verbatim quotes from there with the verification flags respected.

Structure of notes/14:
- **§A:** France attestations (primary contemporary, secondary historiographical) — 17 entries
- **§B:** Switzerland attestations (primary contemporary, primary retrospective, secondary historiographical, explicit null findings) — 9 entries
- **§C:** Cross-country theoretical (Room 1985) — 1 entry
- **§D:** Summary table (what we have / what we lack / cross-corroboration counts)
- **§E:** Manuscript citation recommendations (§1.2 / §2.3 / §2.6 / §7)
- **§F:** Verification protocol for [UNVERIFIED] items

---

## Sign-off

Phase 1 + Berthoud verdict + corpus-wide wine-coalition sweep complete. The Cahannes deep-dive (§2) answers the priority #1 question directly. The Berthoud verdict (§6) resolves the "55-year" and Fr. 87,000 questions from project paper trail. The wine-coalition assertion inventory (§13) catalogs all assertions across the corpus and surfaces the France/Switzerland asymmetry as the paper's value-add.

Phase 2 (BenSlimane scan + Prestwich 1994/1997 + Studer 8-chapter cross-check + Magnan 1871/1874 verbatim) is queued.

**File:** `c-metrics-absinthe1/quality_reports/librarian_reports/2026-06-03_claim-corroboration.md`
