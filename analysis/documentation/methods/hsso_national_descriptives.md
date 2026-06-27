# HSSO F-Series — National-Level Descriptive Context

**Authoring date**: 2026-04-30
**Maintainer**: Nicholas A Jensen
**Auto-surface keywords** (filename-derived): hsso, national, descriptives
**Status**: Active. Implemented in `analysis/scripts/06_national_descriptives.do`.

---

## Why this document exists

This is a methods-reference doc, surfaced by the `methods-doc-reminder.sh` UserPromptSubmit hook whenever a future user prompt mentions one of the keywords above. The goal is post-compaction stability: a future session can ask "what about national-level data?" or "remind me about the HSSO F-series" and this document will be auto-flagged.

The F-series files (F.7a, F.7b, F.8a, F.8b, F.13) sit in a categorically different position in the project than the canton-level HSSO files (B.01a, B.01b, B.27, B.32, I.01, I.39c, etc.). Confusing the two would silently break the analysis. This document encodes the rules that prevent that.

---

## The five files at a glance

| File   | Title (English) | Year coverage | Pre-vote rows | Action taken |
|--------|----------------|--------------|--------------|-------------|
| F.7a   | Resident population by employment status × gender | 1888-1960 | 1888, 1900 | Translate + extract |
| F.7b   | Resident population by employment status × gender | 1960-1990 | none | Translate + archive only |
| F.8a   | Agricultural population | 1888-1960 | 1888, 1900 | Translate + extract |
| F.8b   | Agricultural population | 1930-1980 | none | Translate + archive only |
| F.13   | Industrial business census (enterprises + employees by sector) | 1905, 1929, 1939, 1955 | 1905 | Translate + extract |

The 1908 absinthe ban defines pre-vote (`year <= 1908`). 1910 census rows are kept in the archive but tagged `pre_vote == 0`.

---

## The CRITICAL invariant (read first)

**These five files are NATIONAL-LEVEL ONLY.** HSSO does not have canton-by-occupation employment data anywhere from 1888-1908. The canton-level employment search is definitively closed (per strategist handoff 2026-04-30 and the prior canton-level employment audit summarized in `HANDOFF_2026-04-30.md`).

What this means in code:
- ❌ Never merge F.7a / F.7b / F.8a / F.8b / F.13 derived DTAs into `processed/absinthe_analysis.dta`
- ❌ Never use F-series variables as canton-level controls or regressors
- ❌ Never add F-series interactions to expansion specs (e.g., `vine_x_F13_*`)
- ✅ Use F-series only for paper-text descriptive sentences ("In 1905, Switzerland had X spirits enterprises [F.13]")
- ✅ Use F-series for footnotes establishing the wine industry's competitive landscape
- ✅ Reference the F-series archive when responding to a referee asking "what about employment data?"

The codebase encodes this invariant via `notes` commands embedded in each output DTA and via the placement of `06_national_descriptives.do` *after* `05_expansion.do` in `run.do` (so the canton-merge chain has fully completed before any F-series work runs — eliminating any temptation for cross-contamination).

---

## What `06_national_descriptives.do` produces

Three long-format DTAs in `processed/intermediate/`:

```
f07a_employment_long.dta       N=264    8 years × 3 gender groups × 11 employment categories
f08a_agric_pop_long.dta        N=384    8 years × 3 gender groups × 16 worker categories
f13_business_sector_long.dta   N=960    4 years × 6 metrics × (20 industry + 20 secondary/tertiary classes)
```

Each DTA has these standard columns: `year`, `gender_group` (or `metric` for F.13), industry/category column, `value`, `pre_vote` flag.

### F.7a column dictionary
| Column letter | Variable in DTA | German | English meaning |
|--|--|--|--|
| B | solo_workers | Alleinarbeitende | Sole-account workers |
| C | employers | Arbeitgeber | Employers |
| D | self_employed_total | Selbständige Total | Self-employed (total) |
| E | coop_family_members | Mitarbeitende Familienmitglieder | Cooperating family members |
| F | salaried_employees | Angestellte | Salaried employees |
| G | wage_workers | Arbeiter | Wage workers |
| H | home_workers | Heimarbeiter | Home-based workers |
| I | apprentices | Lehrlinge | Apprentices |
| J | domestic_workers | Hausangestellte | Domestic workers |
| L | total_active | Total Aktive Bevölkerung | Total active population |
| U | total_nonactive | Total Nichtaktive | Total non-active population |

Values in **thousands of persons**. Three gender blocks at rows 17-24 (Total), 28-35 (Male), 39-46 (Female). Cols B-J are the active-population breakdown; cols L and U are the active and non-active totals respectively (used together for R12 cross-data fingerprint check vs B.01a). Cols K and M-T are intermediate aggregates / family-member breakdowns and are NOT extracted.

### F.8a column dictionary
| Column letter | Variable in DTA | German | English meaning |
|--|--|--|--|
| B | indep_farmers | Selbständige | Independent farmers |
| C | coop_family_farmers | Mitarbeitende Familienmitglieder | Cooperating family farmers |
| D | nonfamily_workers | Familienfremde Arbeitskräfte | Non-family workers |
| E | total_main_occ | Total | Total main-occupation workers |
| F | adults_family | Erwachsene | Adult family members |
| G | children_family | Kinder unter 16 Jahren | Children family members <16 |
| H | total_family | Total | Total family members |
| I | total_main_pop | Total | Grand total main-occupation pop |
| J | side_with_other_main | Mit einem anderen Hauptberuf | Side ag with another main occ |
| K | without_main_occ | Ohne einen Hauptberuf | Without a main occupation |
| L | from_farmer_relatives | Davon Angehörige von Landwirten | Of which: from farmer relatives |
| M | total_side_occ | Total | Total side-occupation |
| N | employed_in_ag | In der Landwirtschaft berufstätig | Employed in agriculture |
| O | total_relatives | Angehörige | Total relatives |
| P | total_ag_pop | Total absolute | Total agricultural pop (absolute) |
| Q | index_1930_100 | 1930=100 | Index (1930=100) |

Values are **absolute counts**. Three gender blocks at rows 19-26 (Total), 30-37 (Male), 41-48 (Female). Year-asterisks (`1920*`, `1941**`) are stripped from `year` and stored separately in `year_flag`.

### F.13 column dictionary

**Section A — Industrie und Handwerk** (cols B-U, 20 classes):
foodstuffs, spirits_beverages, tobacco, textiles, clothing, leather, rubber_plastics, paper, graphic_arts, chemical, wood_cork, toys_carriages, stone_earth, metals, machinery, precision_mech, music_radio_tv, jewelry, watches, total_industry_handicraft

**Section B — Bergbau/Bau/Energie + Tertiärsektor** (cols B-U, 20 classes):
mining, construction, utilities, subtotal_bergbau_bau_energie (col E "Total" subtotal of B+C+D), total_secondary (col F "Zweiter Sektor" = col E + Section A total), wholesale, retail, banks, insurance, real_estate, brokerage, total_commerce (col M subtotal of G-L), transport, hospitality, health, education, sports_film, other_services, total_tertiary (col T "Dritter Sektor"), grand_total (col U "Gesamt-total" = col F + col T)

**Bug history**: Initial implementation mapped section B as cols B-T (19 classes) — missing col U (the actual grand_total) AND off-by-one starting at col F. Fixed 2026-04-30 after R12 fingerprint asserts (1905 secondary_tertiary grand_total = 237,989) failed against the wrong column-T value (110,617 = total_tertiary only). Lesson: always cross-check end-of-row totals against the HSSO-shipped "Total" / "Gesamt-total" column with explicit asserts; raw column counts are easy to miscount.

**Six metrics per section**: n_enterprises, n_employees_total, mean_employees_per_enterprise, n_employees_male, n_employees_female, n_women_per_1000_men.

---

## The headline pre-vote numbers (paper-text-ready)

From `f13_business_sector_long.dta`, year=1905, section=industry_handicraft:

| Industry class | n_enterprises | n_employees_total | n_male | n_female |
|--|--|--|--|--|
| **spirits_beverages** | **1,481** | **6,539** | 6,207 | 332 |
| foodstuffs | 18,660 | 57,264 | 40,588 | 16,676 |
| tobacco | 297 | 9,774 | 2,717 | 7,057 |
| textiles | 4,234 | 113,937 | 45,274 | 68,663 |
| total_industry_handicraft | 108,859 | 502,143 | 330,429 | 171,714 |

**Paper-text use case** (for the descriptive section): "In 1905, on the eve of the absinthe vote, Switzerland's spirits-and-beverages industry comprised 1,481 enterprises employing 6,539 workers nationally — a small but politically organized constituency relative to the food industry's 18,660 enterprises [HSSO F.13, 1905 census]." The point is the industry's size in absolute terms relative to other sectors; this is descriptive context, NOT identification of cantonal heterogeneity.

From `f08a_agric_pop_long.dta`, year=1900, gender_group=total:
- Total main-occupation agricultural population: 1,033,427 persons
- Independent farmers: 211,641 persons
- Cooperating family farmers: 138,382 persons

From `f07a_employment_long.dta`, year=1900, gender_group=total:
- Self-employed total: 425,460 persons (425.46 thousand)
- Salaried employees: 134,224 persons (134.224 thousand)
- Wage workers: 857,801 persons (857.801 thousand)

---

## Translation procedure

Source: HSSO German originals at `https://hsso.ch/de/2012/f/<id>` (or downloaded copies in the strategist's `Brainstorm-Absinthe/Replication/Manual Replication/Mass_import_hsso/` folder, mirrored to `$Absinthe1Data/original/` for archival redundancy).

Pipeline: `download_and_translate.py` from the strategist's repo. The `translate_excel(src, dst, mapping)` function performs:
1. Dictionary substitution from `DE_TO_EN` (143 entries; covers most HSSO standard headers)
2. LLM fallback for sentences not matched (only fires if API key is configured; without one, partial translation results — typically only 8-15 substitutions per file)

Partial translation is acceptable for our use because the **numeric data is unchanged** — only headers/titles are translated. The Stata extraction script hardcodes column meanings from the German originals (verified via `inspect_f_series.py` and `inspect_f_translated.py` scratch scripts), so it doesn't depend on the translation being complete.

To re-run translation:
```python
import importlib.util
spec = importlib.util.spec_from_file_location(
    "downtrans",
    r"C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/Replication/Python/download_and_translate.py")
dt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dt)

import os
SRC = r"C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/Replication/Manual Replication/Mass_import_hsso"
DST = r"C:/Users/jensenn/Dropbox/research_data_raw/c-metrics-absinthe1/translated"

for fname in ["F.7a", "F.7b", "F.8a", "F.8b", "F.13"]:
    src = f"{SRC}/{fname}.xlsx"
    dst = f"{DST}/{fname}_EN.xlsx"
    n = dt.translate_excel(src, dst, dt.DE_TO_EN)
    print(f"{fname}: {n} substitutions -> {dst}")
```

**Output destinations** (immutable raw-data tier under `$Absinthe1Data`):
- `$Absinthe1Data/original/F.{7a,7b,8a,8b,13}.xlsx` — German originals (archive)
- `$Absinthe1Data/translated/F.{7a,7b,8a,8b,13}_EN.xlsx` — partially-translated (workflow input)

---

## Sanity-check assertions (pre-vote numbers)

Hardcoded in `06_national_descriptives.do` Section 4. If any assertion fails, the extraction has drifted (e.g., HSSO updated the file, row layouts shifted). All currently pass:

1. F.7a 1900 self_employed_total = 425.46 thousand
2. F.7a 1900 salaried_employees = 134.224 thousand
3. **R12 fingerprint**: F.7a 1900 total_active + total_nonactive = 3315.443 thousand (matches B.01a 1900 canton-pop sum to 6 sig figs — the two HSSO sources cross-validate)
4. F.8a 1900 total_main_pop = 1,033,427
5. F.8a 1900 indep_farmers = 211,641
6. F.13 1905 spirits_beverages n_enterprises = 1,481
7. F.13 1905 spirits_beverages n_employees_total = 6,539
8. F.13 1905 foodstuffs n_enterprises = 18,660
9. **R12 fingerprint**: F.13 1905 industry_handicraft total = 108,859 enterprises (col U, end-of-row total)
10. **R12 fingerprint**: F.13 1905 secondary_tertiary grand_total = 237,989 enterprises (col U, end-of-row total)

---

## Common pitfalls (lessons from the build)

1. **`str10` truncation trap** — initial implementation used `gen str10 section = "industry_handicraft"`, silently truncating to "industry_h". Downstream `if section=="industry_handicraft"` then matched zero rows. Fixed to `str50` (project norm for category/metric/label string vars where future name growth is likely; `compress` downsizes at save-time). Lesson: when assigning string literals to fixed-width vars, default to `str50` unless the value is provably bounded (e.g., `str2` for 2-letter canton codes).

2. **Stata batch mode does not auto-load Dropbox-based `stata_profile.do`** — the user's profile lives at `$DROPBOX/stata_profile.do` and is sourced by per-machine `profile.do` files. Direct batch invocation from `/tmp` skips the per-machine bootstrap. Workaround for ad-hoc test scripts: explicitly `do "$DROPBOX/stata_profile.do"` after first setting `$HOME` and `$DROPBOX`. The production `run.do` does NOT have this issue because it's invoked from a normal Stata session that already loaded the profile.

3. **Partial translation is fine** — only ~8-15 dictionary substitutions per F-series file (LLM fallback inactive without API key). Numeric data unchanged. Hardcoded column meanings in extraction script absorb the residual German.

4. **Year-asterisk footnotes (`1920*`, `1941**`)** — F.8a uses asterisks to flag definition changes. The extraction script strips them via `subinstr(A, "*", "", .)` and stores them separately in `year_flag` so the `year` column stays numeric.

---

## Provenance

- Strategist's setup-prompt: `C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_F_series_translation_prompt.md`
- Strategist's deeper-context handoff: `C:/Users/jensenn/Research/repos/Brainstorm-Absinthe/quality_reports/handoffs/2026-04-30_F7_F8_F13_translation_handoff.md`
- This project's HANDOFF (canton-employment closure history): `analysis/documentation/HANDOFF_2026-04-30.md`
- Implementation: `analysis/scripts/06_national_descriptives.do`
- Outputs: `analysis/processed/intermediate/f07a_employment_long.dta`, `f08a_agric_pop_long.dta`, `f13_business_sector_long.dta`

---

## What's NOT done (deferred)

- **F.7b and F.8b extraction**: post-vote only (1960-1990 and 1930-1980). Reserved for Paper #2 industry-dynamics work. German originals + partial translations are mirrored to `$Absinthe1Data/{original,translated}/` for future use; no Stata extraction code exists yet.
- **HSSO F.10 / F.0 / F.31**: prior national-level files inspected during the canton-employment search; F.31 has canton dimension but only post-1960. Not in scope here.
- **Historical employment time-series figures** (e.g., national agricultural-employment trend 1888-1960 from F.8a): could be a paper appendix figure if a referee asks for sectoral context. Currently unimplemented; the long-format DTA has the data ready if a figure is wanted.
