# Librarian Dispatch — Claim Corroboration + Studer Comprehensive Scan

**Date:** 2026-06-03
**Repo:** `c-metrics-absinthe1`
**Author of spec:** Claude (orchestrator), at PI's request
**Status:** PROPOSED — **NOT BINDING. If you cannot find or verify something, ASK THE PI — do not give up, and do not silently drop a claim.**

---

## ⛔ READ FIRST — operating rules

1. **This is a corroboration + discovery task, not a rubber stamp.** For every claim below, your job is to find the *primary* support, judge how strong it is, and **stress-test it** (look for the strongest counter-evidence too).
2. **If a source is missing, unreadable, ambiguous, or a claim can't be verified — STOP and ASK THE PI.** Do not abandon a claim or invent support. The PI (Nicholas Jensen) would rather answer a question than have a gap papered over.
3. **Don't redo existing work.** Cross-check against the existing summaries (§3) and the project's source notes (`Brainstorm-Absinthe/Supplementary/absinthe_examination/notes/`, plus the vault notes `Milliet Translations.md`, `Tabled Absinthe Work_May-2026.md`, and `lit-positioning-and-submission-strategy.md`). Flag *discrepancies* between existing notes and the primary sources.
4. **Translate every non-English quote** you rely on (verbatim original + English).
5. **Cahannes 1981 is the single most important item** — treat it as priority #1.

**Background to corroborate (the claims live here):**
`C:/Users/jensenn/Research/Obsidian/Absinthe-Obsidian/Notes/lit-positioning-and-submission-strategy.md` — §1 (sources), §2 (scapegoat + double standard). Verify everything in those sections; they were drafted from transcripts and need primary-source confirmation.

---

## 1. Claims to corroborate / stress-test (the checklist)

For each: status ∈ {**CORROBORATED** / **PARTIAL** / **UNSUPPORTED** / **CONTRADICTED**}, with source + page + verbatim quote (+ translation).

1. **Cahannes (1981) [KEY]** — that **Swiss winegrowers supported the absinthe initiative because absinthe competed with (white) wine.** Get the verbatim passage + exact page from *both* `Cahannes1981.txt` and `Cahannes1981_v2.pdf` (reconcile them). Judge how *directly* it supports the producer-coalition (Bootlegger) motive. This is the historical anchor of the whole paper — be exact.
2. **Prestwich (1979), "The Curious Case of Absinth[e]"** — (a) that absinthe was *singled out* from the broader drink question; (b) any link she draws to **wine's interest**; (c) the **"good alcohol vs bad alcohol" / natural-fermented-vs-unnatural-distilled double standard.** Supplement with Prestwich (1994) *Drinkers, Drunkards and Degenerates* and (1997) *Legrain*. Pull verbatim for whatever we cite.
3. **Heimberg (2000), p. 99** — verify the verbatim French + our translation of the three-part sentence ("no *major* economic interests" / "decided by German-speaking regions" / "scapegoat"), AND **footnote 12** ("vote… négatif dans deux cantons producteurs, Neuchâtel et Genève"). Confirm page/footnote numbers exactly.
4. **Berthoud (1969) — the "55-year" claim + the Régie.** Re-read Berthoud (and `berthoud_1969_fee_verte_summary.md`) to determine: (a) does she support a wine–temperance *coalition* thesis, or only the **fiscal Régie** angle (federal alcohol monopoly losing revenue → "fiscal bootlegger against the ban")? (b) **Does any "55-year-old observation" contribution claim survive** a careful read, or does it collapse (as prior work concluded)? (c) reconcile her loss figure (**Fr. 87,000**) against Milliet's (**Fr. 872,850/yr**). (d) Assess the insider caveat (Val-de-Travers ties). Note: her OCR corrupts `f→d` (Lanfray→"Landrey") — verify quotes against the PDF, not OCR.
5. **Scapegoat construction (the "empty panic").** Corroborate the chain **Marcé 1864 → Magnan 1864/1871 → reified "absinthism"**, the **Lanfray 1905** trigger, and the thin-science numbers (**Padosch 2006: ~1% absinthism vs ~70% chronic alcoholism**; Lachenmeier on thujone levels). Use the toxicology cluster (§2 Tier 2). **BenSlimane et al. (2025), "Scapegoating in Stigma Construction"** is directly on-point — scan it and integrate.
6. **The temperance double standard (natural fermented vs. unnatural distilled).** Corroborate beyond what we have (the Valais "wholesome drink vs distilled poison" quote in Milliet 1907; the Swiss Alcohol Law targeting *spirits* and exempting wine/beer/cider). Find supporting passages in Prestwich, Studer, Marrus, and any Swiss temperance primary text.
7. **Political-feasibility selection (Peltzman).** Corroborate that the absinthe industry was **small, geographically concentrated (NE/Val-de-Travers), and politically weak** relative to the wine sector — the precondition for it being the *feasible* target. Use Studer, Cahannes, Milliet, Sager 2009.

## 2. Comprehensive Studer scan + the full file inventory

**Studer, *The Hour of Absinthe* (McGill-Queen's 2024)** — **run `/cheap-scan1 --safe` on the chapters** (`Books/The Hour of Absinthe/...-001.pdf` through `-013.pdf`, plus `-toc`/`-fm`). Goal is twofold: (a) corroborate claims 1–7 above; (b) **surface any content we have not captured** — anything on the Swiss case, wine–absinthe competition, the absinthe industry's structure, the ban's politics, or the natural/distilled framing. We already have summaries for **ch004 and ch011** (`Brainstorm-Absinthe/Supplementary/absinthe_examination/summaries/`) — cross-check those, don't redo them, and scan the **remaining** chapters. Flag gaps explicitly.

**Full review inventory** (dedupe — several paths repeat across folders; the PI's list contains duplicates of Prestwich-1979, Marrus, Padosch, Lachenmeier-2006/2008):

*Tier 1 — KEY (do first, `--safe`):*
- `…/Articles/Cahannes1981.txt` and `…/Articles/Cahannes1981_v2.pdf`  ← priority #1
- `…/Books/The Hour of Absinthe/…-001…-013.pdf` (Studer)
- `…/Articles/Prestwich-TemperanceFranceCurious-1979.pdf`
- `…/summaries/heimberg_2000_renouveler_summary.md` + the Heimberg primary (confirm we have the PDF; if not, ASK PI)
- `…/summaries/berthoud_1969_fee_verte_summary.md` + Berthoud primary

*Tier 2 — scapegoat / double-standard / thin-science:*
- `…/Articles/BenSlimaneEtAl-ScapegoatingInStigmaConstruction-2025.pdf`
- `…/Articles/PadoschEtAl-Absinthism-2006.pdf`; `…/Articles/LachenmeierEtAl-Absinthe-A_Review-2006.pdf`; `…/Articles/LachenmeierEtAl-ChemicalCompositionOfVintagePrebanAbsinthe-2008.pdf` (and the dup `…/Absinthe/Lachenmeier2008Chemicalcomposition.pdf`); `…/Articles/PelkonenEtAl-Thujone-2013.pdf`; `…/Articles/PatockaPlucar-PharmacologyToxicologyAbinsthe-2003.pdf`; `…/Articles/Strang-AbsintheWhatsPoison-1999.pdf`; `…/Articles/Arnold-Absinthe-1989.pdf`
- `…/Articles/Marrus-SocialDrinkingBelle-1974.pdf`; `…/Articles/Dowbiggin-BackToTheFuture-1996.pdf`
- `…/Articles/Prestwich-DrinkersDrunkardsDegenerates-1994.pdf`; `…/Articles/Prestwich-PaulMauriceLegrain-1997.pdf`
- `…/Books/Adams-HideousAbsinthe-2004.pdf`

*Tier 3 — context / mostly already summarized (cross-check only):*
- `…/Articles/Sager2009_Governance_and_Coercion.pdf`
- `…/LitDive_5-13-26/Chapuis2913_english.pdf` + `chapuis_2013…summary.md`; `…/LitDive_5-13-26/Luauté 2007_english.pdf` + `luaute_2007…summary.md`
- LitDive summaries: `lemoine_1911`, `magnan_1864`, `magnan_1871`, `motet_1859`, `pictet_1906` (`…/LitDive_5-13-26/summaries/`)
- `…/Articles/10ContempDrugProbs37.pdf`; `…/Articles/Alcohol Research Group.txt` (note: Room 1985 editorial intro, per prior finding); `…/Articles/citation.txt`
- `…/Articles/BanerjeeDuflo2011.pdf` (phylloxera-year anchor, future paper 2)
- Draft/editor notes (for what's already asserted in-text): `…/Articles/Draft 1 Outline Collab_prefix_notes.md` (+ BACKUP), `…/Articles/Editor Notes – Claude draft 1.2.md`

**Folder root** for all of the above: `C:\Users\jensenn\Dropbox\Research Sources\Regulation\Absinthe\` (Articles/ and Books/ subfolders as in the PI's list).

## 3. Cross-reference (don't redo)
Existing summaries + notes to read *before* scanning, so you extend rather than repeat:
- Repo: `Brainstorm-Absinthe/Supplementary/absinthe_examination/notes/` and `…/summaries/` (incl. Studer ch004/ch011, Magnan/Marcé chain, claim-2.1/2.4 notes).
- Vault: `Notes/Milliet Translations.md` (incl. the Valais double-standard quote + 167,814 sigs + firm table), `Notes/Tabled Absinthe Work_May-2026.md`, `Notes/lit-positioning-and-submission-strategy.md`.
- Prior librarian reports: `c-metrics-absinthe1/quality_reports/librarian_reports/`.

## 4. Deliverable
A corroboration report → `c-metrics-absinthe1/quality_reports/librarian_reports/2026-06-03_claim-corroboration.md`:
- **Claim table** (claims 1–7): status + source + page + verbatim (+ translation) + 1-line strength judgment + strongest counter-evidence found.
- **Cahannes deep-dive** (its own section): full verbatim + translation + page + how directly it supports the coalition motive.
- **Studer newly-surfaced content:** bullet list of anything not already in our notes, with chapter/page.
- **"55-year" verdict:** does Berthoud support a stronger contribution claim, or not?
- **Discrepancies** found between existing notes and primary sources (e.g., the Fr.87,000/872,850 reconciliation; any Magnan dating issues).
- **Open questions for the PI** (everything you couldn't resolve — remember: ASK, don't drop).
- cheap-scan1 `notes.md` outputs land per the skill (`scanned_AUTHOR_YEAR/`); link them.

## 5. Conventions
- Follow `/cheap-scan1` exactly (Stage 0 local extraction → triage → text → visual → consolidate); `--safe` for Tier 1, default/progressive acceptable for Tier 2–3.
- Disk-first: many PDFs are already on disk under the folder root and in `Dropbox/Research Sources/` — check before declaring anything "missing."
- This dispatch is **not binding**: if scope, priorities, or a claim's framing seem off, **flag and ask the PI** before producing the final report.
