# Librarian Dispatch — Magnan/Studer Integration + Remaining Verification

**Author:** Strategist
**Date:** 2026-05-22
**Priority:** HIGH — paper deadline today EOD; manuscript §2.2 + §2.4 prose edits pending the Section A verifications below
**Prior librarian output (reference):**
- `summaries/Studer_2024_ch004.md` — Studer ch. 4 distillation with verbatim quotes
- `notes/12_claim_2_1_health_effects_unfounded.md` — Magnan 1864 verbatim re-pulled and verified
- `notes/10_adulteration_evidence_synthesis.md` — adulteration evidence map updated to point at Studer ch. 4

---

## Purpose

The prior librarian dispatch returned Magnan 1864 verbatim + Studer 2024 ch. 4 distillation. The findings substantively restructure the absinthism-attribution chain in the paper's §2.2 (health effects unfounded) and add a primary-source adulteration anchor to §2.4 (Dragoons 1860). This dispatch:

1. **Closes remaining verification gaps** from the Magnan/Studer pull (Section A)
2. **Documents the integration plan** for the outline + manuscript edits (Section B — reference for whichever agent the PI assigns to apply edits)
3. **Lists bibliography entries** that need confirmation (Section C)

The librarian's primary work is Section A. Sections B and C are reference material so the librarian knows what the verifications support and can flag any cross-source inconsistencies they encounter.

---

## Section A — Librarian verification items (PRIMARY)

### A1. The "1873" Magnan reference (UNRESOLVED — please disambiguate)

The original strategist attribution chain referenced "Magnan (1864, 1873)." The 1873 piece is unidentified after the prior verification pass. Possibilities:

- (a) A precursor article to *De l'alcoolisme* (1874) — possibly in *Comptes rendus* or *Bulletin de l'Académie de Médecine*
- (b) A different bibliographic dating of the 1874 book
- (c) A separate clinical case report between 1864 (*Union médicale*) and 1874 (*De l'alcoolisme*)

**Task:** search the Magnan publication record (CNRS catalogue, BNF Gallica, OPUS, WorldCat) for any 1873 Magnan publication on absinthe or alcoholism. If none found, confirm so and we drop the 1873 reference. If found, return full citation including journal/series, pages, and the substantive topic.

**Decision rule:** if no 1873 publication exists, the attribution chain becomes "Magnan (1864) + Magnan (1874)" cleanly. Default to this if verification returns negative.

### A2. Studer (2024) full bibliographic info

The prior pull verified chapter 4 content but not the full bibliographic header. Confirm:

- Author given name (Jacques? Brigitte? other?)
- Full title (presumed: *The Hour of Absinthe* — but verify subtitle if any)
- Publisher
- Series (if applicable)
- ISBN (13-digit if available)
- Original language (English original, or translated from French/German?)
- Year of publication / first edition

Source the front-matter of the PDF or the project's catalogue entry.

### A3. Magnan 1874 *De l'alcoolisme* full citation

Verify against BNF Gallica or WorldCat:

- Full title: presumed *De l'alcoolisme: des diverses formes du délire alcoolique et de leur traitement*
- Publisher: presumed Adrien Delahaye, Paris
- Year: 1874 (confirm against first-edition publication date — Magnan's *De l'alcoolisme* has multiple editions)
- Pagination of original
- Any reprint/edition variants relevant to standard scholarly citation

### A4. Marcé biographical and publication verification

The verbatim Magnan 1864 credits "M. Marcé" as experimental director. Verify:

- Full name (probable Louis-Victor Marcé, 1828-1864)
- Professional affiliation in the early 1860s (was Marcé at Bicêtre, Sainte-Anne, elsewhere?)
- Did Marcé publish independently on absinthe before or at the same time as Magnan's 1864 paper?
- If Marcé published independently, full citation needed — this is the originating experimental source and may warrant separate citation
- Note: Marcé died in 1864 (per general medical historiography); confirm and note whether his absinthe work was published posthumously

### A5. Baillarger / Bicêtre institutional context for Magnan 1864

The 1864 paper masthead reads "BULLETIN DES HOPITAUX / Bicêtre. — Service de M. BAILLARGER. / ... par M. MAGNAN, interne du service." Verify:

- Full name (presumed Jules Baillarger, 1809-1890)
- Period of Magnan's internship at Bicêtre under Baillarger (presumably 1863-1865)
- When did Magnan move from Bicêtre to Sainte-Anne (where his senior career is associated)?
- This matters for the paper's §2.2 prose, which currently mis-attributes Magnan's 1864 work to Sainte-Anne. The verbatim shows Bicêtre/Baillarger for the 1864 period.

### A6. Heimberg / Prestwich / Cahannes verification (carry-over from prior dispatch)

The earlier dispatch `2026-05-22_heimberg_prestwich_cahannes_verification.md` requested verbatim verification of:

- Heimberg (2000, p. 99) full paragraph + scope of "major economic interests" claim
- Prestwich (1979, p. 309) "silent beneficiary" passage in surrounding context
- Prestwich (1979, pp. 304-305) wine-as-sacrosanct + good-vs-bad-alcohol quotes
- Prestwich (1979, p. 302) phylloxera → cheap-absinthe quote
- Prestwich (1997, p. 1258) "powerful political influence" + "hygienic drinks" passage
- Cahannes (1981, p. 45) wine-industry quote + p. 44 qualifier

**Status check:** if this prior dispatch is still in queue, please prioritize completing it. The manuscript §2.1 paragraph anchoring depends on these verifications. The §2.1 prose cannot be locked until they return.

### A7. Cross-source consistency checks the librarian should flag

During the Section A verifications, flag any of the following inconsistencies if found:

- Discrepancy between Studer ch. 4's Marcé framing and Magnan 1864's "sous la direction... de M. Marcé" verbatim
- Discrepancy between Studer ch. 4's account of the Dragoons 1860 incident and the original Figuier (1862) / Legrand du Saulle (1860) source if the librarian can access them
- Any claim in Studer that contradicts Lachenmeier (2008) or Padosch et al. (2006) on the thujone toxicology

---

## Section B — Integration plan (REFERENCE — for whichever agent applies edits)

Two files affected:

- **Outline:** `C:\Users\jensenn\Dropbox\Research Sources\Regulation\Absinthe\Absinthe Sources\Articles\Draft 1 Outline Collab_prefix_notes.md`
- **Manuscript:** the Draft 1.2 / 5-22-26 master prose file (PI-locatable; not in repo)

### B1. Outline Edit 1 — Replace Claim 2.2 Attribution slot entirely

**Find** (within Claim 2.2 spoiler):

```markdown
### Attribution: Magnan (1864, 1873)
> "[Verbatim quote — canonical historical source for the absinthism diagnosis from experimental dog studies]" (p. X)

Magnan's experimental work on dogs administered absinthe essence is the historiographic origin of the absinthism diagnosis. Subsequent French and Swiss medical discourse — including the Bundesrat's 1907 ban justification — leaned on Magnan's framing.
```

**Replace with:**

```markdown
### Attribution: Marcé (1860s, via Magnan 1864) — animal-experimental originator
> Magnan 1864 verbatim crediting Marcé: "sous la direction et pour les recherches particulières du... maître, M. Marcé" (*Union médicale*, journal p. 261 ff., from the Bicêtre service of M. Baillarger).

Marcé directed the originating animal experiments on essence d'absinthe, performed on fasting guinea pigs at 2–4g doses. The experimental tradition the temperance discourse later cited as evidence for absinthe's distinctive toxicity used CONCENTRATED essence, not the finished beverage — a distinction Padosch et al. (2006) and Lachenmeier et al. (2008) identify as the fundamental category error.

### Attribution: Magnan (1864) — clinical case-report
> "ACCIDENTS DÉTERMINÉS PAR L'ABUS DE LA LIQUEUR D'ABSINTHE / Observation suivie de quelques réflexions, par M. MAGNAN, interne du service." (*Union médicale*, journal p. 261 ff.)

Magnan, then an *interne du service* at Bicêtre under Baillarger, published a clinical case-report on a single patient — Louis C..., a wine merchant — extending Marcé's experimental observations into asylum psychiatry. CRITICALLY, the 1864 paper uses CONDITIONAL framing ("on aurait raison de penser que... une simple coïncidence") and the ADJECTIVAL form "absinthique" / "épilepsie absinthique" — NOT the reified noun "absinthisme." The originating clinical observation explicitly acknowledged the case-evidence could be coincidence.

### Attribution: Magnan (1874) and subsequent literature — reification
The reified "absinthisme" disease entity is constructed cumulatively across Magnan's later work (*De l'alcoolisme*, 1874) and the broader French medical literature of the 1870s-1890s. By the 1890s, Prestwich (1979, p. 305) documents, "Magnan's work on absinthism was considered classic and had been incorporated into the standard clinical lessons and medical texts." The 1903 French Academy of Medicine alcoholism committee codification operates on this reified diagnosis, not on Magnan 1864's cautious original observation.

### Scope note (load-bearing)
The "absinthism scientific case" the temperance movement deployed in 1907-1908 was NOT a single founding moment that subsequent science overturned — it was a cumulatively constructed disease entity in which the originating clinical observation was substantially more cautious than the reified diagnosis that later carried the political weight. Modern toxicology (Lachenmeier et al. 2008; Höld et al. 2000; Studer 2024) returns evaluation to the cautious framing the 1864 originating author himself adopted.
```

### B2. Outline Edit 2 — Add Studer 2024 ch. 4 Corroboration to Claim 2.2

**Find** (within Claim 2.2 spoiler, after the existing Höld Corroboration):

```markdown
### Corroboration: Höld et al. (2000)
> "[Verbatim quote on thujone pharmacology — GABA-A receptor antagonism at supratoxic doses]" (p. X)

Scope: pharmacology side full. Thujone's GABA-A antagonism requires doses well above what realistic absinthe consumption could deliver.
```

**Insert immediately AFTER that block:**

```markdown
### Corroboration: Studer (2024, ch. 4, p. 28) — *The Hour of Absinthe*
> "none of its regular components seems to have been particularly dangerous or, indeed, capable of causing the hallucinations experienced by drinkers: the much-feared essential oils were essentially harmless, asphodel absinthe seems to have been a myth, and the concentration of thujone was too low. **The often-described effects of the drink were, perhaps unsurprisingly, due to the high alcohol content of the drink.**"

Scope: full. Studer is the most recent comprehensive scholarly synthesis of the toxicological reassessment. The bold-emphasized line — "due to the high alcohol content" — is the cleanest single statement of the post-Lachenmeier verdict in the literature.
```

### B3. Outline Edit 3 — Add Dragoons 1860 incident to Claim 2.3 Corroboration

**Find** (within Claim 2.3 spoiler, after the Lachenmeier Corroboration and before the Prestwich Parallel):

```markdown
### Corroboration: Lachenmeier et al. (2008) on chemistry-vs-discourse
Documents the chemistry-vs-discourse gap for absinthe danger claims generally. Used here as the comparator: the French regulatory discourse invoked adulteration-based danger; the chemistry showed otherwise in surviving samples; the Swiss regulatory discourse imported the French framing without the equivalent Swiss empirical basis.
```

**Insert immediately AFTER that block:**

```markdown
### Corroboration: 1860 Dragoons Regiment copper-sulphate incident (via Studer 2024, p. 24, citing Figuier 1862 → Legrand du Saulle 1860)
> "the doctors of the regiment undertook an investigation, which discovered the presence of copper sulphate in the absinthe in the canteens."

Scope: full as a documented primary-source instance of real adulteration. The Dragoons Regiment troops' symptoms — colic, diarrhea, vomiting — were physical gastric copper-sulphate toxicity, distinct from the neurological-hallucinatory "absinthism" syndrome the later temperance discourse attributed to thujone. This 1860 incident demonstrates that period medical authorities could identify and document specific adulteration cases when they occurred, AND that the symptom-presentation differed from what the absinthism diagnosis claimed. The Swiss-vs-French structural distinction is sharpened: documented adulteration was a real concern in mid-19th-century France; the Swiss case after the 1887 federal alcohol monopoly attenuated the structural conditions for similar industrial-base adulteration episodes.
```

### B4. Manuscript Edit 4 — §2.2 Magnan/Marcé attribution paragraph

**Find** this paragraph in §2.2:

> Louis Marce experimented on dogs and rabbits given essence of absinthe; the treated animals, in Arnold's (1989, p. 116) summary, "suffered convulsions, involuntary evacuations, abnormal respirations, and foaming at the mouth." Marce's student Valentin Magnan carried these studies into systematic clinical psychiatry at the Sainte-Anne asylum in Paris from the early 1860s onward, claiming to find that absinthe could cause hallucinations in human beings (Arnold 1989, p. 116).

**Replace with:**

> The originating experimental tradition was Louis-Victor Marcé's. In the early 1860s Marcé administered concentrated essence of absinthe — wormwood-derived essential oil, not the finished beverage — to fasting guinea pigs at 2–4 gram doses; the treated animals, in Arnold's (1989, p. 116) summary, "suffered convulsions, involuntary evacuations, abnormal respirations, and foaming at the mouth." Valentin Magnan, then an *interne du service* at Bicêtre under Jules Baillarger, extended Marcé's experimental observations into asylum psychiatry. Magnan's 1864 *Union médicale* paper presents a clinical case-report on a single patient — Louis C..., a wine merchant — and explicitly credits Marcé's experimental direction: the report describes the work as undertaken "sous la direction et pour les recherches particulières du... maître, M. Marcé." Two features of Magnan's 1864 paper warrant emphasis. First, the paper uses the ADJECTIVAL form "absinthique" and the phrase "épilepsie absinthique" — not the reified noun "absinthisme," which appears only in the later literature. Second, Magnan himself adopts CONDITIONAL framing: he acknowledges that the case-evidence could be "une simple coïncidence." The disease-entity reification — the "absinthism" syndrome with its rapid, irreversible, and (claimed) hereditary character — was constructed cumulatively across Magnan's later work, particularly *De l'alcoolisme* (1874), and the broader French medical literature of the 1870s and 1880s. By the 1890s Magnan's work was, in Prestwich's (1979, p. 305) summary, "considered classic and had been incorporated into the standard clinical lessons and medical texts." The 1903 French Academy of Medicine alcoholism committee codification operates on this cumulatively constructed diagnosis, not on the 1864 originating observation.

### B5. Manuscript Edit 5 — §2.2 modern-toxicology synthesis line

**Find** the final paragraph of the modern-toxicology discussion in §2.2 (ending with Pelkonen 2013):

> Pelkonen and colleagues (2013, p. 105) qualify this somewhat — thujone is bioactive at sufficient dose, with low doses (1.5–3.85 mg) producing little or no effect and higher doses (15 mg) producing "some subtle effects on attention and mood" — but do not rescue the absinthism diagnosis at the doses obtainable from drinking commercial absinthe.

**Insert immediately AFTER that paragraph, before the Prestwich asylum-records paragraph:**

> Studer (2024, p. 28) provides the cleanest single-line synthesis of this toxicological reassessment in the recent scholarly literature: "none of its regular components seems to have been particularly dangerous or, indeed, capable of causing the hallucinations experienced by drinkers: the much-feared essential oils were essentially harmless, asphodel absinthe seems to have been a myth, and the concentration of thujone was too low. The often-described effects of the drink were, perhaps unsurprisingly, due to the high alcohol content of the drink."

### B6. Manuscript Edit 6 — §2.4 adulteration leading example

**Find** this paragraph in §2.4:

> A third strand of the contemporary case against absinthe, distinct from both the absinthism diagnosis and the broader alcoholism concern, was adulteration, particularly in cheap variants. The historical literature documents that some absinthe contained additives including copper salts and cupric acetate (used to fake the chlorophyll-green colour after the costly natural plant-based colouring had been omitted), and that the *Lancet* in 1873 issued a medical annotation on antimony residues (Arnold 1989, pp. 115–116). The adulteration concern is independent of the thujone-toxicity concern: if pre-ban absinthe had real health effects, they may have come from adulterants rather than from thujone — which still makes the historical "absinthism = thujone" diagnosis wrong, but for a different reason than modern toxicology principally emphasises.

**Replace with:**

> A third strand of the contemporary case against absinthe, distinct from both the absinthism diagnosis and the broader alcoholism concern, was adulteration in cheap variants. The earliest well-documented incident is the 1860 Dragoons Regiment outbreak, reported by Figuier (1862) and Legrand du Saulle (1860) and summarised by Studer (2024, p. 24): when an unexplained pattern of colic, diarrhoea, and vomiting appeared among regimental troops, "the doctors of the regiment undertook an investigation, which discovered the presence of copper sulphate in the absinthe in the canteens." Two features of the 1860 incident warrant emphasis. First, the symptoms — gastrointestinal, immediate, and physically traceable to a specific contaminant — are categorically distinct from the neurological/hallucinatory absinthism syndrome that Magnan and his successors later attributed to thujone. Second, the contaminant was identified by period medical authorities using the investigative tools available to them; adulteration was therefore a documented and locatable phenomenon, not a vague conjecture. The broader historical literature documents that some absinthe contained additives including copper salts and cupric acetate (used to fake the chlorophyll-green colour after the natural plant-based colouring had been omitted), and that the *Lancet* in 1873 issued a medical annotation on antimony residues (Arnold 1989, pp. 115–116). The adulteration concern is therefore real and independent of the thujone-toxicity concern: if pre-ban absinthe had real health effects, they may have come from adulterants rather than from thujone — which still makes the historical "absinthism = thujone" diagnosis wrong, but for a different reason than modern toxicology principally emphasises.

### B7. Sweep operations (both files)

**Sweep 1 — Founding case-patient name correction**

Search both files for occurrences of "Charles" within ~10 words of "wine merchant" or "22-year-old." The librarian-verified 1864 verbatim has "C... (Louis)" — the project transcription as "Charles" was a transcription error. Replace any occurrence with "Louis C..., a wine merchant." Drop the "22-year-old ex-" qualifier (age not visible in verbatim pull; not independently verified).

**Sweep 2 — Magnan 1873 → 1874**

Search both files for "Magnan (1864, 1873)" or "1864/1873" — replace with "Magnan (1864, 1874)" (subject to Section A1 verification — if A1 returns a valid 1873 publication, retain "1864, 1873, 1874" three-citation form).

**Sweep 3 — Marce → Marcé**

Search both files for "Marce" (Louis-Victor Marcé). The proper spelling is **Marcé** with acute accent. If "Marce" appears anywhere without accent, fix.

**Sweep 4 — Manuscript only: "Marce's student" overstatement**

The manuscript phrasing "Marce's student Valentin Magnan" overstates the mentorship relationship. Magnan was an intern under Baillarger at Bicêtre; Marcé directed the absinthe experiments but was not Magnan's mentor in the formal sense. The B4 replacement above corrects this phrasing.

**Sweep 5 — Manuscript only: Sainte-Anne 1864 context fix**

The manuscript says Magnan was at Sainte-Anne when he published the 1864 paper. The verbatim shows **Bicêtre under Baillarger** in 1864. Magnan moved to Sainte-Anne later in his career. The B4 replacement above fixes this institutional reference; verify no other §2.2 sentences perpetuate the Sainte-Anne misattribution for the 1864 period.

---

## Section C — Bibliography additions (PENDING SECTION A VERIFICATIONS)

Add to `Bibliography_base.bib`:

```bibtex
@article{magnan1864,
  author = {Magnan, Valentin},
  title = {Accidents Déterminés par l'Abus de la Liqueur d'Absinthe: Observation suivie de quelques réflexions},
  journal = {Union médicale},
  year = {1864},
  note = {From the Bicêtre service of M. Baillarger; journal p. 261 ff.}
}

@book{magnan1874,
  author = {Magnan, Valentin},
  title = {De l'alcoolisme: des diverses formes du délire alcoolique et de leur traitement},
  publisher = {Adrien Delahaye},
  address = {Paris},
  year = {1874}
}

@book{studer2024,
  author = {[Verify given name — A2]},
  title = {The Hour of Absinthe},
  publisher = {[Verify — A2]},
  year = {2024}
}
```

If Section A4 returns a Marcé independent publication on absinthe, add the corresponding `@article{marce18XX}` entry.

If Section A1 returns a valid 1873 Magnan publication, add the corresponding entry.

---

## Section D — Apply order

1. **Section A verifications first** (A1-A7) — these close the open citation gaps and confirm bibliography entries
2. **Section B integration plan** handed off to PI / coder / librarian for application after Section A returns
3. **Section C bibliography updates** confirmed against Section A returns, then added to `Bibliography_base.bib`

The integration cannot be fully locked until A1 (1873 disambiguation) and A2 (Studer full bib) return. The other Section A items (A3-A7) are confirmatory rather than blocking but should be completed for citation discipline.

---

## Output format

Save librarian responses to `quality_reports/librarian_reports/2026-05-22_magnan_studer_integration_response.md`.

Structure per Section A item:
- Item ID (A1, A2, etc.)
- Source consulted
- Verbatim quote(s) with page references where applicable
- Resolution status: VERIFIED / NOT FOUND / PARTIAL / FLAGGED
- Brief annotation on what this enables in the integration plan

---

## Constraints

- Verbatim quotation in quotation marks with page references
- Paraphrase only when explicitly marked
- Don't extrapolate beyond what sources support
- If a verification target cannot be confirmed, return as explicit `[NOT FOUND: source]` — do NOT substitute or guess
- Flag any cross-source inconsistencies encountered during verification

---

**End of dispatch.**
