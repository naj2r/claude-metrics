# Project Context

> **Claude reads this file before any analytical reasoning.** If a field is empty, ask the user to fill it before proceeding. Do not invent project context.

This file is the project-level "what is this about" — distinct from `CLAUDE.md` (which is "how do we code here"). Fill all five fields when starting a new project. Run `/init-project` for an interactive walkthrough.

---

## 1. Dataset(s)

> _Name(s), source(s), sample period, N observations, refresh cadence._

- **swissvotes_dataset.csv** — Swissvotes.ch master dataset of all 708 Swiss federal popular votes (1848–present). Semicolon-delimited, UTF-8 with BOM, ~700 columns. We extract vote #68 (absinthe ban, July 5 1908): cantonal yes-vote shares. Source: swissvotes.ch. One-time historical snapshot, no refresh.
- **I.01_EN.xlsx** — HSSO Table I.01, land use by canton 1840–1996. Vineyard hectares sub-block, single-year rows {1877, 1884, 1894, 1905, 1913}. Primary measure: vineyard area in 1905. Source: Historical Statistics of Switzerland Online (HSSO).
- **B.01a_EN.xlsx** — HSSO Table B.01a, resident population by canton 1671–1990. We use the 1900 census row.
- **B.01b_EN.xlsx** — HSSO Table B.01b, population density by canton 1798–1990. We use the 1900 row.
- **B.27_EN.xlsx** — HSSO Table B.27, population by religion 1850–1990. We use 1900 Protestant and Catholic counts per canton.
- **B.32_EN.xlsx** — HSSO Table B.32, population by native language 1880–1990. We use 1900 German and French counts per canton.

All HSSO files are English translations in `$Absinthe1Data/translated/`. German originals in `$Absinthe1Data/original/` are for provenance auditing only — never imported.

---

## 2. Unit of observation

> _What does one row in the analysis dataset represent?_

Swiss canton in the 1908 federal vote. Cross-section, N = 25 cantons. BE = pre-1979 BE+JU combined (Jura was not a separate canton until 1979). The 26th modern canton (JU) is excluded.

---

## 3. Outcome variable(s)

> _Name, transformation, units. Multiple outcomes OK._

- `yes_pct` — canton-level yes-vote share for vote #68 (absinthe ban, July 5 1908), in percent (0–100). National result: 63.5% yes (passed). Two cantons rejected: Neuchâtel and Geneva.

---

## 4. Identification strategy

> _OLS / FE / DiD / IV / matching / RCT / RDD — one sentence on the source of variation._

Cross-sectional OLS with HC3 robust standard errors. Compare the bivariate vineyard–vote relationship to the relationship after conditioning on French-language share and Catholic share. The sign flip in the vineyard coefficient (negative bivariate → positive conditional) is the core finding — Simpson's paradox driven by French-speaking cantons being both wine-producing AND culturally opposed to federal temperance regulation.

**Two share-denominator definitions reported in tables**:
- `french_share`/`catholic_share` (subset): French/(German+French speakers); Catholic/(Protestant+Catholic). Focuses on the language/religion cleavage that drives federal politics.
- `french_share_total`/`catholic_share_total` (total-pop): French/total population; Catholic/total population. Matches the prior independent analysis at `~/Research/repos/Brainstorm-Absinthe/Replication/`. Both yield the headline finding (vineyard coef in [300, 600], positive); subset definition gives ~+484 (p=0.024), total-pop gives ~+437 (p=0.063).

Robustness: leave-one-out, exclude NE+GE (the two rejecting cantons), randomization inference (10,000 permutations).

---

## 5. Key globals

> _`$MyProject` and any other path globals; sample restrictions encoded as globals._

- `$MyProject` — set in `run.do` = `$Absinthe1` (pointing to `analysis/` in this repo)
- `$Absinthe1` — `~/Research/repos/c-metrics-absinthe1/analysis` (set in Stata profile)
- `$Absinthe1Data` — `~/Dropbox/research_data_raw/c-metrics-absinthe1` (raw data, separate from code)
- `$DisableR = 1` — R portion is disabled for this project
- Sample: all 25 cantons; no restrictions (but NE+GE exclusion tested as robustness)

---

## Variable definitions (algebra)

Every derived variable in `02_clean.do` is a deterministic function of the raw HSSO/swissvotes counts. Explicit formulas:

```
* --- Outcome ---
yes_pct        = swissvotes <ct>-japroz, vote #68             [units: %, 0-100]
yes_frac       = yes_pct / 100                                [units: 0-1]

* --- Vineyard ---
vineyard_ha       = vineyard_1905                             [units: hectares]
vineyard_per_cap  = vineyard_ha / pop_1900                    [units: ha/person]
vine_per_1000     = (vineyard_ha / pop_1900) * 1000           [units: ha per 1000 pop]
vine_share_agland = (vineyard_1905 / (agland_1000ha*1000))*100 [units: %]
vineyard_per_cap_1894 = vineyard_1894 / pop_1900              [pre-determined: pre-vote]
vine_change_pct   = ((vineyard_1905-vineyard_1877)/vineyard_1877)*100  [if y_1877>0]

* --- Religion / Language shares: TWO denominator definitions ---
* SUBSET denominator (mine; focuses on the dominant binary cleavage):
catholic_share        = catholic_1900 / (protestant_1900 + catholic_1900)
french_share          = french_1900   / (german_1900    + french_1900)

* TOTAL-POP denominator (matches prior Brainstorm-Absinthe analysis):
catholic_share_total  = catholic_1900 / pop_1900
french_share_total    = french_1900   / pop_1900

* The two definitions diverge most where Italian/Romansh are large
* (TI: french_share=11.2% subset vs 0.3% total-pop). Both are reported in
* the OLS table (cols. 4 vs 5). Both yield the headline sign-flip.
```

**Naming rule for denominators**: bare name = subset denominator (binary contrast); `_total` suffix = total-population denominator. Future shares should follow this convention.

---

## Notes

- **Simpson's paradox**: French-speaking cantons are both heavily wine-producing AND culturally opposed to federal temperance regulation. Failing to condition on language share produces a misleading negative bivariate vineyard–vote correlation.
- **BE/JU handling**: Jura (JU) separated from Bern (BE) in 1979. For the 1908 cross-section, use the combined BE+JU value from HSSO (column C, labeled "BE,JU") and drop the BE-only column (D) and JU-only column (AB). N = 25, not 26.
- **Vineyard unit choice (frontmatter convention)**: `vineyard_per_cap` is in **hectares per person**, not per 1000 pop. The raw coefficient (~+484 in KEY spec) is mathematically correct but reads as absurd to a non-specialist (no canton has 1 ha/person). The substantive translation is in `t11_magnitudes.tex`: a one-SD increase in `vineyard_per_cap` ≈ 4 pp higher yes-vote; comparing wine-richest Vaud (0.023 ha/person) to no-vineyard Uri predicts ~11 pp higher yes-vote, holding language and religion constant. **Whenever the headline coefficient appears in prose, ALWAYS pair it with a substantive-magnitude sentence drawn from t11.**
- **Absinthe-canton tiering**: three definitions are computed for robustness. `absinthe_dummy` = NE only (heartland; Pernod 1797–; matches prior analysis). `absinthe_dummy_broad` = NE + VD (incl. Yverdon Kübler & Wyss). `absinthe_dummy_any` = NE + VD + GE (any documented production). Used as robustness in `t12_absinthe_tier.tex`.
- **Language confound — two approaches**: (a) binary subsample (`if french_share < 0.5`, N=20 German-only cantons; in `t05` cols 1-3) — arbitrary 0.5 cutoff; (b) **continuous weighting** (`[aweight = (1-french_share_total)]`, N=25; in `t05` cols 4-5) — preferred because no observations dropped. Both yield the same direction; the continuous version is more defensible.
- **Naturalization data not yet imported**: HSSO Table B.15 (canton × gender × nationality, 1900) exists in the original Brainstorm-Absinthe data folder but is not in `$Absinthe1Data`. If naturalization shares matter for an interpretation (e.g., immigrant attitudes toward federal temperance), B.15 would need to be added to `01_import.do`.
- **Verification target**: After conditioning on French/Catholic shares (either denominator), the coefficient on `vineyard_per_cap` should be in [300, 600] positive. With subset denominators p~0.02; with total-pop denominators p~0.06. The bivariate coefficient is negative. Both targets are guarded by `assert` in `04_tables.do`.
- **Naming conventions**: scripts use 2-digit zero-padded prefixes (`01_*.do`, `02_*.do`, ...). Output tables use `t01_*.tex`, `t02_*.tex` etc.; figures use `f01_*.pdf`, `f02_*.pdf`. Subsetted long code chains (if any) use decimal sub-prefixes (e.g., `01.1_*.do`, `01.2_*.do`).
- **Expansion analyses (`05_expansion.do`)** — ported from prior Brainstorm-Absinthe analysis after data extraction was verified to match. Includes: (1) same-day placebo (vote #67 commerce, July 5 1908 — same voters, different issue); (2) German-only subsample (eliminates Simpson confound entirely); (3) pre-determined vineyard 1894 (addresses reverse causality); (4) vineyard-change 1877-1905 ("desperation hypothesis"); (5) population/votes/eligible/French-pop/German-pop weighted regressions; (6) 6 alternative vineyard operationalizations (pre-1894 per cap, per 1000 pop, raw ha, binary >1000 ha, per km², share of agricultural land); (7) heterogeneity interactions (vine × french/catholic/lnpop); (8) alternative outcomes (margin, yes/eligible, turnout); (9) NE prediction-gap (estimates net absinthe-industry employment effect); (10) Oster (2019) coefficient stability (with Simpson-paradox caveat); (11) **cross-referendum falsification panel** — KEY-spec regression run on each of the 15 federal popular votes 1900-1910; absinthe vote (#68) coefficient should be in the right tail. Outputs: `t04_placebo.tex` through `t10_stability.tex`, plus `t13_placebo_panel.tex` and `f03_placebo_distribution.pdf`. **`log(vineyard+1)` is intentionally NOT used as an alt operationalization — with ~32% zero-vineyard cantons the +1 is arbitrary and the coefficient has no scale-invariant interpretation (Chen & Roth 2023, QJE). Extensive margin captured via `wine_canton` binary; intensity via per-km² and ag-share.**

**Cross-referendum falsification design (`05_expansion.do` sections 10.5, 12.8-12.9)** — built on top of `processed/placebo_panel.dta` (375 rows = 25 cantons × 15 votes 1900-1910). For each placebo vote, regress canton yes-vote share on `vineyard_per_cap + french_share + catholic_share`, HC3. The treatment vote (#68 absinthe) ought to be in the right tail. Substantively interesting watchpoints:

- **Vote #63 (25.10.1903) "Artikel über die Regulierung des Alkoholhandels"** (Federal alcohol-trade regulation article) — should be NULL. If vineyard cantons opposed federal alcohol regulation generically, the wine-protection-via-substitution story collapses. **Observed: -52, p=0.886 ✓**.
- **Vote #65 (10.06.1906) "Lebensmittelgesetz"** (Federal Act on the Trade in Foodstuffs and Articles of Daily Use, 8 Dec 1905) — **NOT a clean placebo**. This law established federal authority over beverage purity, additives, and essences (the regulatory framework later invoked against absinthe). Wine producers were a key "yes" constituency because the law cracked down on wine adulteration and substitute beverages. The pro-wine-purity coalition (wine industry + temperance + public health) reassembled for the absinthe vote 23 months later. Reading vote #65 as the *prequel* to #68 makes a single rent-seeking story; reading them as independent makes a paradox. **Observed: +1286**, p=0.045**. Prior analysis (Brainstorm-Absinthe 2026-04-09) flagged this and we replicate.

Of 14 non-treatment placebo coefficients, only #65 reaches significance and only #65 has substantive content related to alcohol/wine regulation. Absinthe (#68) ranks #2 of 15 in coefficient magnitude. Window matches prior Brainstorm-Absinthe analysis (entry `2026-04-09_expansion-analysis.qmd` Section 2).
