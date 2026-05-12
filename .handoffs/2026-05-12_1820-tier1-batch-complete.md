# Recap: Tier 1 batch (C.6+C.7+C.8+C.9+C.10+C.12) — full session

**Type**: recap (terminal handoff for the resumable arc)
**Date**: 2026-05-12 18:20
**Builds on prior recap**: `.handoffs/2026-05-11_2310-hsso-translations-complete.md`
**Companion checkpoint**: `.handoffs/2026-05-12_1815-checkpoint-tier1-batch-complete-decisions-pending.md`
**Session: long (~9h)** — morning verification batch (Tasks 1, 3, 7, 8, hygiene block) + afternoon Tier 1 substantive batch (C.6, C.7, C.8, C.9, C.10, C.12) + smoke test.

---

## Goals (full session)

### Morning verification batch (predecessor handoff: `2026-05-11_easy_wins_c6phase0_coder_handoff.md`)
1. Task 3: `/update-codebook` regeneration
2. Task 1: f05 caption fix (mirror t19 framing)
3. Hygiene block: line 1877 `=` + 7 missing `_inventory_append` rows
4. Task 7: end-to-end smoke test
5. Task 8: number cross-check sweep (flag-only)

### Afternoon Tier 1 substantive batch (predecessor handoff: `2026-05-12_tier1_section6_mechanism_evidence_dispatch_REV2.md`)
6. C.10: H.2a substrate prices → T23 + F08
7. C.9: NE-adjacency robustness in T17 + T18
8. C.6 (Phase 0–3): Differential Mobilization full pipeline → T20 + T21 + F06
9. C.7: I.51 horticulture as multi-Bootlegger co-explanatory
10. C.8: I.33a/I.33b subsidy time-series → T22 + F07 + col K notes
11. C.12: I.01 canton-level cereal/potato extraction (REV 2 made mandatory)
12. End-to-end smoke test

All 12 goals landed. 11 commits total since the May 11 recap.

---

## Decisions (full session)

1. **MORNING — caption-discipline lesson applied (Task 1 f05)**: replaced caption claiming "wine-relevant votes cluster at high vine coef AND low cleavage share" with framing that distinguishes #65 (cleavage attenuation CONFIRMED, low rho) from #68 (NOT confirmed, high rho due to French-canton ≈ wine-canton structural overlap). Caption text now mirrors t19 footnote.

2. **MORNING — hygiene block bundled as one commit**: line 1877 `=` preventive fix + 7 missing `_inventory_append` rows + new stata-gotchas rule documenting the `local x ""` vs `local x = ""` parse-mode distinction. Per the strategist's discipline.

3. **MORNING — smoke test passed clean**: ~6 min runtime, 26 outputs regenerated, only cosmetic (line-ending + texsave format) diffs in 6 .tex/.pdf + 4 .dta files. All numbers identical.

4. **MORNING — Task 8 number cross-check**: 23 of 23 cited numbers in progress notes verified against current .tex outputs. No drift.

5. **AFTERNOON — new script `07_substrate_descriptives.do`** rather than extending `06_national_descriptives.do`. Cleaner separation: 06 is HSSO F-series national-level employment archive; 07 is substrate-economics descriptive arc (H.2a + I.33a/b + I.01 cereal/potato). Both sourced from run.do.

6. **AFTERNOON — substrate-substitution arc operationalized end-to-end** in HSSO data alone:
   - **Stage (i)** phylloxera shock + relative-price reversal: H.2a wine/potato ratio (C.10 T23/F08).
   - **Stage (iii)** wine-industry mobilization + 1908 viticulture-subsidy emergence: I.33a col C (C.8 T22/F07).
   - **Stage (iv)** post-vote substrate-subsidy continuation: I.33b cols I (potato/fruit 1931+) + J (sugar-beet 1961+) (C.8 F07).
   - Stage (ii) cheap potato-alcohol absinthe expansion: NOT in HSSO; mechanism inferred from (i).

7. **AFTERNOON — C.6 Phase 0 hard-stop verification PASSED**: per-vote turnout/eligible coverage complete for all 15 votes, no `total_votes > eligible` violations, vote #68 cross-check vs canonical extract = 0 difference.

8. **AFTERNOON — three substantive findings flagged for paper-text use**:
   - **C.6 negative mobilization coefficient** (−0.436, p<0.05): Becker producer-channel NOT empirically supported as currently specified. Differential mobilization ran the OTHER direction (producer-defense in NE/GE rather than producer-offense in wine cantons).
   - **C.9 amplification on #65** (vineyard +1286 → +1722.9 with adj_neuchatel control): NE-adjacent cantons (notably VD) were depressing the partial vineyard slope; removing that variance reveals stronger pure wine signal.
   - **C.7 horticulture null** (+6.32, n.s. on #68; +1308, ~unchanged on #65): multi-Bootlegger coalition NOT empirically supported. Caveat: noisy Gartenbau proxy.

9. **AFTERNOON — C.12 data-availability discovery**: HSSO I.01 cereal/potato sub-blocks have SPARSE pre-WWI canton coverage (1905 cereal: 3 cantons; 1910 potato: 1 canton). First complete canton-year is 1917. Decision: extract both (sparse pre-vote for transparency + complete 1917 for paper use under geographic-stability assumption).

10. **AFTERNOON — REV 2 dispatch acknowledged** mid-batch: C.12 moved from optional to mandatory; commit grouping updated; report-back format updated. Re-executed accordingly.

---

## Lessons (full session)

1. **Smoke-test regen produces line-ending diffs even when numbers are identical** — texsave format under the vendored library writes LF + omits trailing `\tabularnewline` on data rows; pre-existing repo state had CRLF + suffix. Cosmetic only; documented in commit messages.

2. **MCP-Stata `$Absinthe1Data` profile-inheritance gap**: the user's stata_profile.do globals are not all inherited by MCP-Stata sessions. Defensive `if "$Absinthe1Data" == ""` setter required in any wrapper that runs run.do via MCP. Worth adding to `.claude/rules/stata-gotchas.md` as a documented gotcha (not yet done).

3. **MCP-Stata task tracker can mark "timeout" while the do-file actually completed**. Verify by reading the log tail and the output files directly. (Hit on the C.12 final test.)

4. **Vendored texsave version drift can produce silent format diffs across smoke tests**. The bulk-vendor commit `c0151b9` from yesterday shifted the canonical format; first smoke test after that commit generated 6 cosmetic diffs. Worth a bake-out check at the start of each session.

5. **HSSO sub-block coverage assumptions warrant pre-flight verification**. The strategist's C.12 spec assumed canton-level coverage at 4 pre-vote years; reality is sparse 1905/1910 + complete 1917. Future canton-level extracts should run a quick openpyxl `count_nonblank` check before writing the Stata extraction code.

6. **Negative mobilization coefficient is informative for the workshop draft, not a negative result to suppress**. The strategist's spec explicitly framed a null mobilization coefficient as supportive of the preference-driven story. Honest reporting of the negative coefficient strengthens the mechanism narrative by ruling out one channel.

7. **regsave_tbl + texsave column-extension pattern is the canonical recipe** for adding columns to existing regression tables: append spec to `inlist`, add `regsave_tbl using "`fh'" if spec=="...", name(colN) ... append`, extend `texsave var col1 col2 ... colN using ...`. Used in T17 (added cols 5+6) and T18 (added rows 8+9).

8. **Mean-centering both interaction inputs** is necessary for interpretable main effects in interaction specs (T17 col 6 vine_c × parcel_c; T21 vine_c_c6 × mobil_c). Without centering, main effects are slopes at zero, not at the moderator mean.

9. **The "policy-economy arc" framing helped organize the dispatch's substantive content**. Four named stages → each task maps to a stage → captions and commit messages reuse the same vocabulary → the workshop draft has a coherent narrative spine without me having to invent it.

10. **The morning batch's conservative scope choice paid off**: deliberately deferring C.6/C.7/C.10/C.8 from yesterday's "easy wins" dispatch meant today's Tier 1 batch had a clean baseline (smoke-tested headline coefficients, locked numbers in the cross-check) to build on.

---

## Blockers (open at end of session)

1. **C.6 follow-up direction (USER DECISION POINT)**: T21 LitA5 framing (vineyard × mobilization) was the wrong test per user feedback. Proposed replacement specs need user selection:
   - (1) `mobilization_dev_v68 ~ french_share` — does language predict differential mobilization?
   - (2) `mobilization_dev_v68 ~ catholic_share` — does religion predict?
   - (3) (1)+(2) joint
   - (4) `yes_pct ~ vineyard × french_share + mobilization × french_share + KEY` — yes-share with mobilization × language interaction
   User indicated they will respond with the next decision.

2. **C.7 reframe pending (USER DECISION POINT)**: user direction is "interpret as inconclusive and relegate to future backmatter". Caption changes pending: T17 col 6 footnote update + T18 row 9 cell note. Low-risk framing only — awaiting confirmation before executing.

3. **C.10 backward extension (USER DECISION POINT)**: H.2a yearly coverage extends to 1801 for wine + potato + wheat + rye + oats (apple from 1861). Current T23 window is 1875–1915 (41 yrs). Pre-phylloxera baseline 1830s–1860s could be added (T23b table or extended T23). User to choose window: 1801, 1830, or other.

4. **MCP-Stata profile-inheritance gotcha not yet added to `.claude/rules/stata-gotchas.md`**. Discovered on the morning's smoke test ($Absinthe1Data not set in MCP session). 5-min documentation task; flagged for next housekeeping pass.

5. **Brugger 1968 archival lookup** (carry-forward from May 11): required to disambiguate the 1908 viticulture-subsidy emergence between (a) genuinely new program vs (b) categorical reclassification. Out of scope for coder; flagged for coauthor or archival sub-task.

---

## Files touched (full session)

### Committed today (11 commits since May 11 recap)

**Morning batch**:
- `e4f61aa` round2 docs: /update-codebook rebuild — 24 datasets refreshed
- `675ad35` round2 Task 1: f05 caption fix to match observed cleavage pattern
- `3d59475` round2 hygiene: t15 local fn =-fix + 7 missing _inventory_append rows
- `642a480` round2 Task 7: full-pipeline smoke-test regeneration

**Afternoon batch**:
- `2faf2b7` round2 Task C.10: substrate-economics descriptives (T23 + F08, H.2a)
- `eff4e7b` round2 Task C.9: NE-adjacency spatial-spillover robustness in T17 + T18
- `d17f44e` round2 Task C.6: Differential Mobilization full pipeline (Phase 0-3)
- `e907608` round2 Task C.7: I.51 horticulture as multi-Bootlegger co-explanatory
- `f11bb33` round2 Task C.8: federal subsidy time-series (I.33a/I.33b)
- `8439a82` round2 smoke test (post C.6-C.10): full-pipeline regeneration
- `d66f5ad` round2 Task C.12: I.01 canton-level substrate-availability descriptive

### New scripts
- `analysis/scripts/07_substrate_descriptives.do` — NEW, 430+ lines, sourced from run.do after 06.

### Modified scripts
- `analysis/run.do` (sources 07_substrate_descriptives.do)
- `analysis/scripts/01_import.do` (Phase 0 turnout/eligible; I.51 horticulture; I.01 cereal/potato)
- `analysis/scripts/02_clean.do` (adj_neuchatel; horticulture_per_cap; Phase 1 mobilization)
- `analysis/scripts/05_expansion.do` (KEY+adj_NE, KEY+horticulture, food65_*, C.6 specs, T20/T21/F06 builders, T17/T18 column+row extensions)
- `analysis/documentation/codebook.md` (regenerated)
- `.claude/rules/stata-gotchas.md` (new "local x" parse-mode section, hygiene block)

### New tables (4)
- `t20_mobilization.tex`, `t21_vineyard_X_mobil.tex`, `t22_viticulture_subsidy.tex`, `t23_substrate_prices.tex`

### Modified tables
- `t17_formal_hypotheses.tex` (now 6 cols)
- `t18_food65_robustness.tex` (now 9 rows)
- All other regenerated tables (cosmetic format diffs only)

### New figures (3)
- `f06_mobilization_scatter.pdf`, `f07_subsidy_timeseries.pdf`, `f08_substrate_prices.pdf`

### New intermediate datasets (5; gitignored .dta files exist locally)
- `h2a_substrate_prices_long.dta` (183 yearly rows 1801-1983)
- `i33_subsidies_long.dta` (125 yearly rows 1866-1991)
- `horticulture_uncleaned.dta` (25 cantons)
- `cereal_potato_area_uncleaned.dta` (25 cantons)
- `cereal_potato_area_long.dta` (25 cantons, with per_cap)

### New notes files
- `analysis/output/notes/ag_association_subsidies_descriptive.md` (C.8 secondary)
- `analysis/output/notes/canton_substrate_availability_descriptive.md` (C.12 descriptive)

### Inventory
- `analysis/results/_inventory.xlsx` — verified all 7 outputs + 5 datasets + 1 script tracked. Total: 25 tables + 8 figures.

### Working tree status at session end
Clean except for `.handoffs/2026-05-11T23-14-10-auto-precompact.md` (yesterday's auto-snapshot, intentional skip).

---

## Next action

**Immediate (on resume)**: process user's three decisions on:
1. C.6 follow-up — which mobilization-by-language/religion specs (1, 2, 3, and/or 4)?
2. C.7 reframe — confirm inconclusive/backmatter caption updates?
3. C.10 backward extension — which window (1801, 1830, other)?

Then execute the chosen specs in priority order. Each is a small marginal commit.

**Then optionally**:
- Add MCP-Stata profile-inheritance gotcha to `.claude/rules/stata-gotchas.md`
- Reframe T20 caption to acknowledge the negative mobilization coefficient as evidence against the Becker channel rather than a puzzle
- Move on to C.11 (Multi-Bootlegger Kirsch + brewery) if the strategist dispatches it; per the strategist's prior note, "C.11 will be dispatched separately IF this batch lands clean and ≥4h capacity remains" — we landed clean, so the dispatch is on the strategist's table

**Open archival subtask** (no rush, coauthor-handleable): Brugger 1968 lookup for viti1908 disambiguation. Carried forward from May 11.

**Workshop draft is ready for prose drafting** in the substrate-substitution-arc, mobilization-channel, and headline-robustness territory once the three pending decisions land.
