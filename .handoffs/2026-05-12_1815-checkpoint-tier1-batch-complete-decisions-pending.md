# Checkpoint: Tier 1 batch complete — decisions pending on C.6 + C.7 + C.10

**Type**: checkpoint (mid-session)
**Date**: 2026-05-12 18:15
**Builds on prior recap**: `.handoffs/2026-05-11_2310-hsso-translations-complete.md`
**Session continues**: yes — awaiting user decisions before proceeding

---

## Goals (this batch)

Strategist's REV 2 dispatch (C.6 + C.7 + C.8 + C.9 + C.10 + C.12) for the May 22 IHS workshop draft. Operationalize the substrate-substitution policy-economy arc as descriptive evidence, plus headline-coefficient robustness columns in T17/T18, plus the differential-mobilization pipeline.

## Decisions made

1. **All 6 Tier 1 tasks executed end-to-end**, smoke test PASS, 6 commits + 1 smoke-test regen commit landed.
   - Order: C.10 → C.9 → C.6 (Phase 0–3) → C.7 → C.8 → C.12 → smoke test
2. **C.10 H.2a substrate prices** extracted as a new script `07_substrate_descriptives.do` (sourced from `run.do` after `06_national_descriptives.do`). Wine/potato substitution-incentive ratio operationalized 1875–1915.
3. **C.6 Differential Mobilization** Phase 0 (per-vote turnout/eligible plumbing in 01_import.do) + Phase 1 (canton-level mobilization measures in 02_clean.do § 4c) + Phase 2 (regressions in 05_expansion.do § 10.16) + Phase 3 (T20, T21, F06) all landed.
4. **C.6 surfaced a substantive surprise**: `mobilization_dev_v68` coefficient = **−0.436** (HC3 SE 0.165, p < 0.05). NEGATIVE — cantons that mobilized differentially on #68 voted AGAINST the ban. Becker producer-channel NOT empirically supported as currently specified.
5. **C.9 surfaced amplification on #65**: vineyard coef +1286 → +1722.9 with adj_neuchatel control. Sign + significance preserved; magnitude amplifies 34% — flagged in T18 row 8.
6. **C.7 horticulture**: null on both #68 (+6.32, n.s.) and #65 (vineyard +1308 with horticulture control, ~same as headline). Multi-Bootlegger coalition NOT empirically supported in this measure (noisy Gartenbau proxy caveat in footnote).
7. **C.8 viticulture-subsidy emergence** at 1908 (133K CHF) confirmed in T22; F07 shows the four-stage policy-economy arc all the way to 1991.
8. **C.12 substrate-availability**: data-availability discovery — canton-level cereal/potato sub-blocks of I.01 are SPARSE pre-WWI (1905 cereal: 3 cantons; 1910 potato: 1 canton). First complete canton-year is 1917. Both extracted; 1917 used as canonical under geographic-stability assumption.

## Lessons

1. **MCP-Stata task tracker can mark "timeout" while the do-file actually completed** (last C.12 test). Verify by reading output files directly when this happens; the commits + outputs were valid.
2. **HSSO sub-block coverage assumptions warrant verification before scope commitments**. The strategist's C.12 spec assumed canton-level coverage at 1855/1877-90/1905/1912; reality is sparse 1905/1910 + complete 1917 only. Future canton-level extracts should confirm canton-cell density before committing to a year.
3. **Negative mobilization coefficient on a B&B test is informative, not embarrassing**. Becker producer-mobilization channel ruled out at this specification. The substantive conclusion narrows the mechanism to preference + religion + language channels (already documented in #65/#68 robustness), not mobilization.
4. **regsave_tbl + texsave column extension pattern works** (used to add T17 col 5/6 and T18 row 8/9). The `inlist` filter + `name(colN)` arg + texsave var-list addition is the canonical recipe; documented implicitly in the t17/t18 builders.
5. **Mean-centering both interaction inputs is necessary** for interpretable main effects in T21 (vine_c_c6 × mobil_c). Without centering, the main effects would be slopes evaluated at zero rather than at the moderator mean.

## Blockers / decision points (USER MUST CHOOSE BEFORE NEXT WORK)

1. **C.6 follow-up direction**: T21 LitA5 framing (vineyard × mobilization) is inadequate per user. Proposed replacement specs:
   - (1) `reg mobilization_dev_v68 french_share, vce(hc3)` — does language predict differential mobilization?
   - (2) `reg mobilization_dev_v68 catholic_share, vce(hc3)` — does religion predict differential mobilization?
   - (3) (1)+(2) joint
   - (4) `yes_pct ~ vineyard × french_share + mobilization × french_share + KEY` — yes-share with mobilization × language interaction
   USER TO PICK which combination to execute.

2. **C.7 reframe**: user direction is "interpret as inconclusive and relegate to future backmatter". Two changes pending: T17 col 6 footnote update + T18 row 9 cell note update. Low-risk, framing only — awaiting confirmation.

3. **C.10 backward extension**: H.2a yearly coverage extends to 1801 for wine/potato/wheat/rye/oats (apple from 1861). Current T23 window is 1875–1915 (41 yrs). Pre-phylloxera baseline 1830s–1860s could be added (T23b table or extended T23). USER TO CHOOSE window.

## Files touched (this batch — committed)

### New scripts
- `analysis/scripts/07_substrate_descriptives.do` — NEW (430+ lines, 10 sections: H.2a + I.33a/b + I.01 cereal/potato + notes-file generators)

### Modified scripts
- `analysis/run.do` — sources 07_substrate_descriptives.do after 06
- `analysis/scripts/01_import.do` — Phase 0 turnout/eligible extraction (sec 2.2-ish), I.51 horticulture (sec 10.5), I.01 cereal/potato (sec 4.05)
- `analysis/scripts/02_clean.do` — adj_neuchatel + horticulture_per_cap + Phase 1 mobilization measures (sec 1.x, 1.11, 4c, 4d)
- `analysis/scripts/05_expansion.do` — KEY+adj_NE + KEY+horticulture specs (sec 10 Task B); food65_adj_NE + food65_horticulture (sec 10.12); C.6 mobilization regressions (sec 10.16); T20+T21+F06 builders (sec 12.13); T17 + T18 builders extended

### New tables
- `analysis/results/tables/t20_mobilization.tex`
- `analysis/results/tables/t21_vineyard_X_mobil.tex`
- `analysis/results/tables/t22_viticulture_subsidy.tex`
- `analysis/results/tables/t23_substrate_prices.tex`

### Modified tables (column/row added)
- `analysis/results/tables/t17_formal_hypotheses.tex` (now 6 cols)
- `analysis/results/tables/t18_food65_robustness.tex` (now 9 rows)

### New figures
- `analysis/results/figures/f06_mobilization_scatter.pdf`
- `analysis/results/figures/f07_subsidy_timeseries.pdf`
- `analysis/results/figures/f08_substrate_prices.pdf`

### New intermediate datasets (gitignored .dta files exist locally)
- `processed/intermediate/h2a_substrate_prices_long.dta` (183 yearly rows 1801-1983, 10 vars)
- `processed/intermediate/i33_subsidies_long.dta` (125 yearly rows 1866-1991, 6 vars)
- `processed/intermediate/horticulture_uncleaned.dta` (25 cantons, 2 vars)
- `processed/intermediate/cereal_potato_area_uncleaned.dta` (25 cantons, 4 vars)
- `processed/intermediate/cereal_potato_area_long.dta` (25 cantons, 9 vars including per_cap-scaled)

### New notes files
- `analysis/output/notes/ag_association_subsidies_descriptive.md` (C.8 secondary)
- `analysis/output/notes/canton_substrate_availability_descriptive.md` (C.12 descriptive)

### Inventory
- `analysis/results/_inventory.xlsx` — verified all 7 outputs + 5 datasets + 1 script tracked. 25 tables + 8 figures total in repo now.

## Commits made (this batch)

```
d66f5ad round2 Task C.12: I.01 canton-level substrate-availability descriptive
8439a82 round2 smoke test (post C.6-C.10): full-pipeline regeneration
f11bb33 round2 Task C.8: federal subsidy time-series (I.33a/I.33b)
e907608 round2 Task C.7: I.51 horticulture as multi-Bootlegger co-explanatory
d17f44e round2 Task C.6: Differential Mobilization full pipeline (Phase 0-3)
eff4e7b round2 Task C.9: NE-adjacency spatial-spillover robustness in T17 + T18
2faf2b7 round2 Task C.10: substrate-economics descriptives (T23 + F08, H.2a)
```

Plus from earlier today (2026-05-12 morning batch):
```
642a480 round2 Task 7: full-pipeline smoke-test regeneration
3d59475 round2 hygiene: t15 local fn =-fix + 7 missing _inventory_append rows
675ad35 round2 Task 1: f05 caption fix to match observed cleavage pattern
e4f61aa round2 docs: /update-codebook rebuild — 24 datasets refreshed
```

11 commits total since the May 11 recap.

## Next action

**WAIT FOR USER DECISIONS on the three pending direction items above**:
1. C.6 follow-up: which mobilization-by-language/religion specs to run?
2. C.7 reframe: confirm inconclusive/backmatter caption updates?
3. C.10 backward extension: what pre-phylloxera window? (1801, 1830, or other)

User indicated they will respond with the next decisions. Do NOT proceed autonomously on any of these three — they are explicit decision points.

In the meantime, the working tree is clean (only the 2026-05-11 auto-precompact handoff remains untracked). All Tier 1 batch outputs are committed, smoke-tested, and inventoried.
