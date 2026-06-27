# DISPATCH: Canton Weinernte panel extraction (harvests ≈1893–1914) — ultracode batch job

> **STATUS: ON HOLD (2026-06-09, PI decision).** The PI is transcribing these tables manually — screenshots + Claude in Excel — judged faster than automating the screenshot series. **Do NOT run the batches below**; they'd duplicate the manual work. This dispatch stays as the reference spec (page map, schema, QA checks all still apply to the manual output). Expected manual deliverables: `CantonWine_Weinernte_manual.xlsx` + `CantonSpirits1889_manual.xlsx` in the yearbooks folder. Reactivate only if the PI hands it back.

**From:** coordinator (gallant-thompson) · **Date:** 2026-06-09
**Executor:** metrics coder instance OR coordinator terminal instance — written executor-agnostic. **Run with ultracode**: the job is ~22 independent per-volume batches + one merge stage, exactly the fan-out shape ultracode handles well. Checkpoint (`/checkpoint`) after each completed batch group so progress survives interruptions.
**Priority:** unblocks the cross-referendum corroboration/falsification battery (votes #43–#68 get vote-year-matched canton wine instead of the 1907 proxy). Supplemental robustness — no formal registration; just document conventions in the output README.

---

## Objective

Extract the canton-level `Weinernte` tables from the Statistical Yearbooks into one tidy panel: **canton × harvest_year (≈1893–1914) × {area_ha, yield_hl, value_fr}**, with per-cell provenance. Follow the proven single-year recipe (`analysis/scripts/python/build_canton_wine_1907_pi.py` → `analysis/processed/canton_wine_1907_pi.csv`), generalized across volumes.

## Source corpus (all verified: real page counts + OCR text layers)

`C:\Users\jensenn\Dropbox\research_data_raw\c-metrics-absinthe1\original\Statistical Yearbooks of Switzerland\SwissStats<vol>.pdf`

Audit & page map: `Brainstorm-Absinthe/.claude/worktrees/gallant-thompson/quality_reports/notes/2026-06-09_yearbook-wine-table-audit.md` (+ raw scan hits in `…_yearbook-wine-scan-raw.txt`).

**Known facts:** no 1897 volume exists (never published); vol 1898 carries BOTH harvest 1896 (p.92) and 1897 (p.94); table titles state the harvest year explicitly ("Darstellung der schweiz. Weinernte im Jahre YYYY. Nach den Angaben der Kantonsregierungen") — use the printed title, never assume volume−1; vol 1899 likely has NO full table (its §IV prose admits "grosse Lücken") — probe pp.55–85, accept absence; early tables are compiled from cantonal reports → record per-year canton coverage, do NOT assume 25/25.

## Batch table (one ultracode batch per row; PDF page numbers)

| Batch | Volume | Target PDF pp. | Expected harvest year(s) |
|---|---|---|---|
| 01 | 1894 | 108–112 | 1893 (+1877 area benchmark col) |
| 02 | 1895 | 125 (±2) | 1894 |
| 03 | 1896 | 100, 104 | 1895 (two area cols ≈1877/1895) |
| 04 | 1898 | 92–94 | **1896 AND 1897** (two tables) |
| 05 | 1899 | probe 55–85 (p.84 candidate) | 1898 — likely ABSENT; confirm & document |
| 06 | 1900 | 54, 57 | 1899 |
| 07 | 1901 | 65–69 | 1900 |
| 08 | 1902 | 68, 71 | 1901 |
| 09 | 1903 | 71 (±2) | 1902 |
| 10 | 1904 | 99–101 | 1903 |
| 11 | 1905 | 74, 77–78 | 1904 |
| 12 | 1906 | 69 (±2) | 1905 |
| 13 | 1907 | 57, 61 | 1906 |
| 14 | **1908** | **53** | **1907 — VALIDATION ANCHOR (see §Verification)** |
| 15 | 1909 | 68 (±2) | 1908 |
| 16 | 1910 | 65 (±2) | 1909 |
| 17 | 1911 | 55, 59 | 1910 |
| 18 | 1912 | 71 (±2) | 1911 |
| 19 | 1913 | 88 (±2) | 1912 |
| 20 | 1914 | 54–57 | 1913 |
| 21 | 1915 | 74–78 | 1914 |
| 22 (opt) | 1891 | 276–278 | **SPIRITS**: canton monopoly-spirits production **1889** ("Vertheilung der Produktion monopolpflichtiger gebrannter Wasser") — separate output file |

Secondary (triage-only, do NOT extract unless trivially easy): recurring "Weinbau/Handel" commerce pages (~p.215–285 family per volume) and vol 1895 p.421 price candidates — log locations to a `wine_commerce_pages.md` list for later.

## Per-batch protocol (OCR-review discipline — non-negotiable)

1. Render target pages to PNG at 200 DPI (pymupdf). **Transcribe from the rendered image, not the OCR text layer** — the text layer is mediocre ("Sch-w-eiz") and good only for locating tables.
2. Read the table title; record the printed harvest year(s) and full title verbatim.
3. Transcribe every canton row: area (ha), total yield (hl), total value (Fr) + any per-ha / per-hl unit-price columns present. Aggregate totals only — **ignore red/white/mixed wine splits entirely** (PI: discarded, not informative).
4. **Arithmetic check:** the printed "Schweiz/Suisse" total row must match the column sum of transcribed canton rows (tolerance: rounding). Mismatch → re-inspect before accepting.
5. Flag uncertain cells (`flag_uncertain=1` + note). Record cantons ABSENT from the table (early-year partial coverage is expected and is itself data).
6. Write per-volume CSV: `analysis/processed/weinernte_panel/canton_wine_vol<VOL>.csv`.

## Output schema (per-volume and merged)

```
canton_code, harvest_year, area_ha, yield_hl, value_fr, yield_per_ha_hl, price_per_hl_fr,
source_volume, source_pdf_page, table_title, flag_uncertain, notes
```

Merge stage → `analysis/processed/canton_wine_panel_1893_1914.csv` + a README documenting: per-year canton coverage matrix, the missing-1898 outcome, units (confirm hl and Fr nominal), the volume→harvest-year mapping actually observed, and any convention calls.

## Verification (built-in anchors)

- **Batch 14 is the pipeline validation:** its output must reproduce `analysis/processed/canton_wine_1907_pi.csv` cell-for-cell (that file was PI-reviewed). Diff them; any discrepancy halts the merge until explained.
- Cross-volume continuity check at merge: canton area_ha should move smoothly year-to-year (phylloxera-era declines are real but bounded); yield/value can swing with harvests (price spikes are real). Flag >50% single-year area jumps as transcription suspects.
- Spot-check 3 random non-anchor cells per batch against the PNG during merge review.

## Stata-first note

The CSV is the constructed-data artifact (same convention as `canton_wine_1907_pi.csv`); downstream analysis imports it via the numbered `.do` pipeline. Python extraction script lives with the existing one and is named as supplementary.

## NOT in scope

- No regressions, no merging into analysis cohorts (separate dispatch after PI reviews coverage).
- No red/white/mixed columns. No commune-level tables. No dossier/translation work (separate pipeline).
