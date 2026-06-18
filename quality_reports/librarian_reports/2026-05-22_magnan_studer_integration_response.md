# Librarian Response — Magnan/Studer Integration + Remaining Verification

**Responding to:** `quality_reports/librarian_dispatch/2026-05-22_magnan_studer_integration.md`
**Date:** 2026-05-22
**Librarian:** Claude (this session)
**Priority:** HIGH (workshop deadline EOD)

---

## Status summary

| Item | Status | Hard-blocker for Section B? |
|------|--------|------------------------------|
| A1 — 1873 Magnan disambiguation | **RESOLVED: NOT FOUND** — drop the 1873 reference | YES (was hard-blocker; now unblocked) |
| A2 — Studer 2024 full bib | **VERIFIED** — full citation below | YES (was hard-blocker; now unblocked) |
| A3 — Magnan 1874 full citation | **VERIFIED** — full citation below | No (confirmatory) |
| A4 — Marcé biographical + publication | **VERIFIED** — *Comptes rendus* 58 (1864) pp. 628-629 | No (enables enhanced attribution chain) |
| A5 — Baillarger/Bicêtre context | **PARTIAL** — Baillarger-vs-Marcé "service" question flagged; B4/Sweep 5 still safe to apply | No (confirmatory) |
| A6 — Heimberg/Prestwich/Cahannes carry-over | **PARTIAL** — Heimberg ✅ this session; Prestwich/Cahannes still pending separate verification | No (separate dispatch track) |
| A7 — Cross-source consistency flags | **3 flags raised** — see Section A7 below | No |

**Net effect on Section B apply order:** Both hard-blockers (A1, A2) are resolved. Sections B and C can proceed. One refinement needed in Section C (Marcé entry can be added — see A4).

---

## A1. The "1873" Magnan reference

**Status:** NOT FOUND.

**Sources consulted:**
- Google Scholar
- Comptes rendus de l'Académie des Sciences (Wikisource tables des matières for 1873 volumes)
- Internet Archive
- BnF Gallica
- Wikipedia article on Valentin Magnan
- General Magnan publication chronology

**Finding:** No 1873 Magnan publication on absinthe or alcoholism surfaces in any of the standard catalogues searched. The Magnan absinthe-publication chronology that the literature consistently documents:

- **1864** — "Accidents déterminés par l'abus de la liqueur d'absinthe" (*Union médicale*) — VERIFIED, in hand
- **1864** — (collaborative experimental work with Marcé that appears in *Comptes rendus* 58: pp. 628-629 — under MARCÉ's name, see A4)
- **1871** — *Étude expérimentale et clinique sur l'alcoolisme, alcool et absinthe, épilepsie absinthique* (per BnF "data.bnf.fr/temp-work" listing) — this is the most plausible source of "1873" confusion in the strategist's chain
- **1874** — *De l'alcoolisme, des diverses formes du délire alcoolique et de leur traitement* (Adrien Delahaye, Paris) — VERIFIED, see A3

**Resolution:** Per the dispatch's decision rule, the attribution chain should default to **"Magnan (1864) + Magnan (1874)"** cleanly.

**Possibility worth flagging to the strategist:** The "1873" reference may be a misdating of Magnan's 1871 *Étude expérimentale et clinique sur l'alcoolisme, alcool et absinthe, épilepsie absinthique*. If the strategist's source for the 1873 date was a secondary work that conflated the 1871 *Étude* with a later printing or with the 1874 book, the cleanest correction is to either (a) drop the 1873 reference per the dispatch's default, OR (b) substitute "Magnan (1871, 1874)" if the strategist wants to anchor on the *Étude* explicitly.

**Annotation for integration plan:** Sweep 2 (Magnan 1873 → 1874) can proceed as the dispatch's default. The two-citation form "Magnan (1864, 1874)" is the safest workshop-acceptable attribution chain.

---

## A2. Studer (2024) full bibliographic info

**Status:** VERIFIED. (Pre-existing in project `Bibliography_base.bib` and `Supplementary/absinthe_examination/bibtex/references.bib` §6.)

**Full citation:**

```bibtex
@book{Studer2024Hour,
  author    = {Studer, Nina S.},
  title     = {The Hour of Absinthe: A Cultural History of {France}'s Most Notorious Drink},
  series    = {Intoxicating Histories},
  volume    = {11},
  publisher = {McGill-Queen's University Press},
  address   = {Montr{\'e}al},
  year      = {2024},
  isbn      = {9780228022206},
  doi       = {10.1515/9780228022213}
}
```

**Components:**
- **Author given name:** Nina S. Studer
- **Full title:** *The Hour of Absinthe: A Cultural History of France's Most Notorious Drink*
- **Publisher:** McGill-Queen's University Press
- **Address:** Montréal
- **Series:** Intoxicating Histories, volume 11
- **ISBN:** 9780228022206
- **DOI:** 10.1515/9780228022213
- **Year:** 2024
- **Original language:** English (Studer is a Swiss historian working in English on French-Swiss absinthe history)

**Project provenance note:** This citation was previously verified during the Brainstorm-Absinthe project's 2026-05-14 source-map consolidation. An earlier project draft had misattributed the book to Dubus / University of Toronto Press; the corrected attribution to Studer / MQUP was confirmed against the AHR 2024 review and against the publisher's catalogue page.

**Annotation for integration plan:** The Section C placeholder `@book{studer2024}` can be filled with the full entry above. The §2.2 and §2.4 citations in the manuscript can use "Studer (2024)" without further qualification.

---

## A3. Magnan 1874 *De l'alcoolisme* full citation

**Status:** VERIFIED.

**Sources consulted:**
- Internet Archive (`archive.org/details/delalcoolismedes01magn`)
- BnF Gallica (`bpt6k768889`)
- AbeBooks listings for the 1874 first edition
- WorldCat-equivalent records via the Internet Archive metadata

**Full citation:**

```bibtex
@book{magnan1874,
  author    = {Magnan, Valentin},
  title     = {De l'alcoolisme: des diverses formes du d{\'e}lire alcoolique et de leur traitement},
  publisher = {Adrien Delahaye},
  address   = {Paris},
  year      = {1874},
  pages     = {344}
}
```

**Components verified:**
- **Full title:** *De l'alcoolisme: des diverses formes du délire alcoolique et de leur traitement* (the dispatch's presumed title is exact)
- **Publisher:** Adrien Delahaye, Paris (sometimes listed as "A. Delahaye" in shorter forms)
- **Year:** 1874 (first edition)
- **Pagination:** 344 pages per Internet Archive scan; one AbeBooks listing shows 282 pages — the 282-page version is likely a different printing or condensed edition; the 344-page version is the canonical first edition
- **English translation:** *On Alcoholism: The Various Forms of Alcoholic Delirium and Their Treatment*, translated by W.S. Greenfield, 1876 — useful for English-medium citation needs

**Annotation for integration plan:** Section C placeholder can be filled with the above. Page references for any specific passage citations from *De l'alcoolisme* should be pinned against the Internet Archive scan (paginated edition).

---

## A4. Marcé biographical and publication verification

**Status:** VERIFIED — substantial new finding.

**Sources consulted:**
- Cairn.info biographical piece on Marcé (perinatal psychiatry context)
- Wikipedia (English) article on Louis-Victor Marcé
- BnF data.bnf.fr authority record (`fr/12567414/louis-victor_marce/`)
- Springer Nature absinthe-history chapter
- *La vie et l'œuvre pionnière de Louis-Victor Marcé* (Cambridge University Press, European Psychiatry)
- Comptes rendus de l'Académie des Sciences (Wikisource table of contents for 1864 vols. 58-59)

**Biographical details:**
- **Full name:** Louis-Victor Marcé
- **Dates:** 3 June 1828, Paris – August 1864 (died at age 36)
- **Professional affiliation (early 1860s):** Physician at Hôpital de Bicêtre (Paris)
- **Approach:** Followed Claude Bernard's experimental medicine method; established a physiological experimentation laboratory on animals at Bicêtre
- **Legacy:** The Marcé Society (founded 1980) is named in his honor for his pioneering work on perinatal psychiatry (*La folie des femmes enceintes*); his absinthe work was a separate strand

**Absinthe publication (VERIFIED VERBATIM CITATION):**

```bibtex
@article{marce1864,
  author    = {Marc{\'e}, Louis-Victor},
  title     = {Sur l'action toxique de l'essence d'absinthe},
  journal   = {Comptes rendus hebdomadaires des S{\'e}ances de l'Acad{\'e}mie des Sciences},
  volume    = {58},
  pages     = {628--629},
  year      = {1864},
  address   = {Paris}
}
```

**Significance:** Marcé is credited as the **discoverer of the convulsive power of absinthe essence** in animal experiments. His 1864 *Comptes rendus* paper is the ORIGINATING experimental publication on absinthe toxicity — pre-dating Magnan's clinical case-report in *Union médicale* the same year.

**Posthumous-publication question:** Marcé died August 1864. *Comptes rendus* volume 58 covered January-June 1864 (volume 59 covered July-December 1864). The Marcé paper at vol. 58: pp. 628-629 was therefore published **before** his death. The absinthe research program continued under Magnan (Marcé's interne) at Bicêtre.

**Confirms project source-map Tier-B finding:** Studer ch011 endnote 41 cites "Marcé, 'Sur l'action toxique de l'essence d'absinthe.' See also Marcé, *Traité pratique*, 606." The citation now has full bibliographic anchor.

**Annotation for integration plan:**
- Section C should be augmented with the `marce1864` entry above
- B4 (the §2.2 attribution paragraph replacement) correctly credits Marcé as the experimental originator
- B1 (Outline Edit 1) correctly positions Marcé as "animal-experimental originator" with Magnan extending the work into clinical psychiatry
- The dispatch's working hypothesis ("Marcé directed the originating animal experiments... extended Marcé's experimental observations into asylum psychiatry") is **CONFIRMED**

---

## A5. Baillarger / Bicêtre institutional context

**Status:** PARTIAL. The institutional reference in B4 is safe, but a flag is needed on the Baillarger-vs-Marcé "service" question.

**Sources consulted:**
- Whonamedit.com (Jules-Gabriel-François Baillarger biography)
- Wikipedia (English) Jules Baillarger article
- BionetX/Bionity.com Baillarger entry
- Geneastar genealogy database
- Cross-references from the Marcé biographical literature

**Biographical details on Baillarger:**
- **Full name:** Jules-Gabriel-François Baillarger
- **Dates:** 1809-1890
- **Training:** Studied medicine at the University of Paris under Jean-Étienne Dominique Esquirol (1772-1840)
- **Early career:** Intern at Charenton mental institution (under Esquirol)
- **1840:** Position at the Salpêtrière
- **Later:** Director of a maison de santé in Ivry-sur-Seine
- **Magnan relationship:** Baillarger "nursed Magnan back to health during cholera epidemics"; Magnan was Baillarger's eulogist — a close lifelong professional relationship

**Period of Magnan's internship under Baillarger at Bicêtre:** The Wikipedia and bionity biographical sources do not explicitly document Baillarger as chief of service at Bicêtre in the early-mid 1860s; his named affiliations are Charenton, Salpêtrière, and Ivry-sur-Seine. **However**, the Magnan 1864 *Union médicale* paper masthead unambiguously reads:

> "BULLETIN DES HOPITAUX / Bicêtre. — Service de M. BAILLARGER. / ACCIDENTS DÉTERMINÉS PAR L'ABUS DE LA LIQUEUR D'ABSINTHE / Observation suivie de quelques réflexions, par M. MAGNAN, interne du service."

This is verbatim from the primary source. **The masthead is itself authoritative.** Baillarger likely held a Bicêtre appointment (visiting consultant or part-time service chief) that the cursory biographical summaries omit; this is consistent with the multi-institutional career patterns common among 19th-century French alienists.

**The Baillarger-vs-Marcé "service" question (cross-source consistency issue):** A biographical secondary source (Cairn.info Marcé piece) characterizes Magnan as having held "his first internship position **in the service of Louis-Victor Marcé** at the Bicêtre Hospital." The Magnan 1864 masthead says Baillarger's service. Reconciliation:

- **Most likely:** Magnan was administratively attached to Baillarger's clinical service at Bicêtre but performed the absinthe experiments in Marcé's research laboratory at the same institution. The two are not mutually exclusive — "service" in the masthead refers to the formal clinical service assignment; "service" in the biographical secondary refers colloquially to Marcé's research program direction.
- **Alternative reading:** The biographical secondary literature has condensed "Magnan was an intern at Bicêtre, where he worked with Marcé on the absinthe experiments" to "Magnan was an intern in Marcé's service." This simplification is common in encyclopedia-style biographies.

**Annotation for integration plan:** B4 (the §2.2 paragraph) correctly says "an *interne du service* at Bicêtre under Jules Baillarger" and credits "Marcé's experimental direction" separately. This dual-institutional framing is exactly right and resolves the ambiguity faithfully to the primary source. **Sweep 5 (Sainte-Anne 1864 misattribution fix) is correct and should be applied** — Magnan was at Bicêtre in 1864; the Sainte-Anne phase came later in his career.

---

## A6. Heimberg / Prestwich / Cahannes verification (carry-over from prior dispatch)

**Status:** PARTIAL.

### Heimberg (2000, p. 99) — **COMPLETED THIS SESSION**

Per the immediately preceding session's deliverable (sent to the strategist 2026-05-22 within the workshop-deadline window). Full verbatim French + English translation + paragraph-level surrounding context + footnote 12 (the "alémanique decision" qualifier) + footnote 11 (Fahrenkrug "prohibition réussie" reference) delivered.

Key items resolved:
- Exact phrase: "Relevons aussi que cette prohibition n'a pas vraiment touché des intérêts économiques **majeurs**" (Heimberg 2000 p. 99). The qualifier "majeurs" / "major" is load-bearing — Heimberg's claim is about magnitude, not absolute touching of economic interests.
- Heimberg's own footnote 12 partly undermines his "alémanique decision" qualifier: "Le vote suisse-romand de 1908 ayant été très serré, et même négatif dans deux cantons producteurs, Neuchâtel et Genève." Producer cantons voted against — exactly what the project's wine-coalition / producer-canton framing predicts.
- The scapegoat claim is hedged: "semble surtout avoir joué un rôle de bouc émissaire dans la **perspective plus générale**" — a perspective claim, not a factual claim.

### Prestwich 1979 verbatim verification — PARTIAL

The project's notes/08 (`Supplementary/absinthe_examination/notes/08_prestwich_full_relevance.md`) documents verbatim Prestwich quotes already extracted in prior sessions:
- p. 302 phylloxera → cheap absinthe chain — ✅ already verbatim in notes/08
- p. 308 selective targeting, cognac protection — ✅ already verbatim in notes/08
- p. 309 "long jealous" wine industry framing — ✅ already verbatim in notes/08
- p. 315 1909 alcohol-content law / *Revue vinicole* "expropriation" — ✅ already verbatim in notes/08

The dispatch lists Prestwich (1979) **pp. 304-305** "wine-as-sacrosanct + good-vs-bad-alcohol" passages as a verification target. These specific page references are NOT in my context this session — they require an additional Prestwich PDF dive. **Flag: pp. 304-305 not yet verbatim-pinned.**

### Prestwich 1997 — **NOT YET VERIFIED**

The dispatch lists "Prestwich (1997, p. 1258) 'powerful political influence' + 'hygienic drinks' passage" — this references a SEPARATE Prestwich publication from 1997 (the 1979 *Historical Reflections* article is in hand; the 1997 piece is not). Possible identification: P.E. Prestwich, "Drinkers, Drunkards and Degenerates: The Alcoholic Population of a Parisian Asylum, 1867-1914," *Journal of Social History* 31 (1997) — but this needs explicit verification by acquiring the 1997 piece. **Flag: separate acquisition needed.**

### Cahannes 1981 verbatim verification — PARTIAL

The earlier Brainstorm-Absinthe session (2026-05-22) verified Cahannes 1981 verbatim against the project's TXT extraction (`Cahannes1981.txt`). The verbatim quotes used in `notes/11_claim_2_4_cultural_disdain_distilled_spirits.md` cite line numbers in the TXT extraction (e.g., lines 135-144, lines 282-300, lines 665-676) — NOT the original journal pagination of *Contemporary Drug Problems* vol. 10 (pp. 37-53).

The dispatch lists "Cahannes (1981, p. 45) wine-industry quote + p. 44 qualifier" as a verification target. The project's TXT extraction does not have original-pagination markers; mapping line numbers to original pp. 37-53 requires the original journal PDF or hardcopy. **Flag: original CDP vol. 10 pagination not yet pinned to the verbatim Cahannes quotes.**

**Annotation for integration plan:** The Heimberg portion of A6 is closed. The Prestwich pp. 304-305 / Prestwich 1997 / Cahannes pagination items are not blockers for B1-B7 application but should be flagged in the manuscript's verification log as "pending pagination pinning" for final-paper citation discipline.

---

## A7. Cross-source consistency flags

Three flags raised during the Section A verifications:

### A7-Flag 1: Baillarger-vs-Marcé institutional "service" question (raised in A5)

Biographical secondary literature (Cairn.info, EM-consulte) characterizes Magnan as an intern in Marcé's "service" at Bicêtre. The Magnan 1864 *Union médicale* primary-source masthead identifies Magnan as an intern in Baillarger's clinical service at Bicêtre. **Reconciliation:** dual institutional context — Bicêtre institution, Baillarger clinical service chief, Marcé experimental research direction. The B4 paragraph handles this correctly by crediting Baillarger administratively and Marcé experimentally.

### A7-Flag 2: Marcé death timing and posthumous attribution

Marcé died August 1864. His *Comptes rendus* paper on essence d'absinthe was published in vol. 58 (January-June 1864) — **before** his death. The continued absinthe-research program post-August 1864 was carried by Magnan independently, citing Marcé as the originating experimental director. **This timing is important for the attribution chain** — Marcé's primacy is established for the experimental discovery (essence-toxicity), but the clinical extension to humans (and the subsequent reification as "absinthism") was Magnan's solo work after Marcé's death.

### A7-Flag 3: Studer ch. 4 vs. Lachenmeier (2008) — no inconsistency found

Per the dispatch's A7 request, I cross-checked Studer ch. 4 against Lachenmeier 2008 for any contradictions on thujone toxicology. **No inconsistencies found.** Studer's p. 28 verdict ("the concentration of thujone was too low... The often-described effects of the drink were, perhaps unsurprisingly, due to the high alcohol content of the drink") is consistent with Lachenmeier 2008's chemistry (mean thujone 25.4 mg/L, within EU 35 mg/L limit; no exotic adulterants in premium-survival samples; "nothing besides ethanol... was able to explain the syndrome 'absinthism'").

Both Studer and Lachenmeier acknowledge that cheap-cask absinthe was not in the empirical sample and adulteration in that segment cannot be empirically ruled out — but neither uses that gap to rescue the absinthism diagnosis as applied to absinthe-as-a-category. The two sources are mutually consistent.

### A7-Flag 4 (additional, not in dispatch A7): "C... (Louis)" age qualifier

The project's source-map Tier-B #14 originally characterized the Magnan 1864 case patient as "Charles, 22-year-old ex-WINE MERCHANT." The verbatim re-pull this morning showed the name is **"C... (Louis)"** — wine merchant, but the "22-year-old" age qualifier is NOT visible in the passages read. **Sweep 1 (founding case-patient name correction) is correct and should be applied; the age qualifier should be dropped, not just the name corrected.** B4 paragraph already handles this.

---

## Recommended Section C bibliography augmentation

Add the `@article{marce1864}` entry per A4 finding:

```bibtex
@article{marce1864,
  author    = {Marc{\'e}, Louis-Victor},
  title     = {Sur l'action toxique de l'essence d'absinthe},
  journal   = {Comptes rendus hebdomadaires des S{\'e}ances de l'Acad{\'e}mie des Sciences},
  volume    = {58},
  pages     = {628--629},
  year      = {1864},
  address   = {Paris}
}
```

This converts Section C from 3 entries (Magnan 1864, Magnan 1874, Studer 2024) to 4 entries (+ Marcé 1864). The added entry supports B1's "Marcé (1860s, via Magnan 1864) — animal-experimental originator" attribution slot, which previously had no formal bibliography entry.

The Section A1 negative finding means **no `@article{magnan1873}` entry is needed.**

---

## Apply-flow status (for the strategist)

✅ Hard-blockers cleared: A1 (NOT FOUND, drop the 1873) + A2 (Studer fully verified)
✅ B1-B6 manuscript / outline edits can proceed as written
✅ B7 sweeps 1-5 can proceed as written
✅ Section C can be applied with the addition of `@article{marce1864}`
⚠️ A6 partial: Heimberg done; Prestwich pp. 304-305 + Prestwich 1997 + Cahannes original-CDP pagination still pending — these are NOT workshop-deadline blockers but should be tracked in the verification log

---

## Constraint adherence

- All verbatim quotation in quotation marks with page references where available ✅
- No paraphrase used without explicit marking ✅
- No extrapolation beyond what sources support ✅
- Where sources could not confirm (A1, parts of A5, parts of A6), explicit [NOT FOUND] or [PARTIAL] markers applied ✅
- Cross-source inconsistencies flagged in A7 ✅

---

## Sources consulted (cumulative for this response)

| Source | Used for | Access mode |
|--------|---------|-------------|
| Magnan 1864 *Union médicale* PDF | Verbatim primary, A5 institutional masthead, A7 case-patient name correction | PyMuPDF + image rendering this session (prior task) |
| Heimberg 2000 *traverse* PDF | A6 (Heimberg portion) | PyMuPDF text-layer extraction this session (prior task) |
| Studer 2024 ch. 4 PDF | A7 consistency cross-check against Lachenmeier | Already distilled in `summaries/Studer_2024_ch004.md` |
| Studer 2024 bibliography (Brainstorm-Absinthe) | A2 full citation | Existing `Bibliography_base.bib` entry |
| Internet Archive | A3 Magnan 1874 verification | Web |
| BnF Gallica | A3 Magnan 1874 + A1 1873 search | Web |
| Wikisource Comptes rendus vol. 58/59 tables | A1 1873 search + A4 Marcé citation | Web |
| Cairn.info Marcé biographical piece | A4 + A5 + A7-Flag-1 | Web |
| Wikipedia (English) Marcé + Baillarger | A4 + A5 | Web |
| EM-consulte / Cambridge UP Marcé biography | A4 + A5 + A7-Flag-1 | Web (abstract/preview level only) |
| Whonamedit.com Baillarger | A5 | Web |
| Project notes 08 (Prestwich) | A6 status report on Prestwich pp. 302/308/309/315 | Project-internal |
| Project notes 11 (Cahannes) | A6 status report on Cahannes pagination gap | Project-internal |

---

**End of response.**
