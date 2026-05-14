# Task 1: I.51 + I.01 Structure Investigation (wine-specific concentration feasibility)

**Task**: May 13 batch, Task 1 (coder dispatch)
**Date**: 2026-05-13
**Source files inspected**:
- `$Absinthe1Data/translated/I.01_EN.xlsx`
- `$Absinthe1Data/translated/I.51_EN.xlsx`
- (For context) `$Absinthe1Data/translated/I.04a_EN.xlsx`, `I.38_EN.xlsx`, `I.39c_EN.xlsx`

---

## TL;DR

**Neither I.01 nor I.51 supports a direct vineyard-specific Gini or vineyard-specific size distribution at the canton level.** Both report canton-level totals or workforce counts, not per-farm or per-enterprise distributions. A vineyard Gini analogous to the I.38 farm-size Gini would require a HSSO source we do not have translated (or possibly do not have at all).

**However**, I.01 enables a related — and substantively defensible — class of "wine specialization" ratios that can serve as Olson-style concentration proxies WITHOUT requiring per-farm vineyard data. These ratios capture *industry dominance within a canton's agriculture* rather than *organizational concentration within the wine industry* — a slightly different theoretical mapping to Olson, but a tractable empirical alternative.

**Recommendation to strategist**: do NOT green-light Task 3 (vineyard-specific Gini from these two sources). Instead, consider re-scoping Task 3 to use I.01-derived wine-specialization ratios as the Olson proxy. This is a half-day of work, not a multi-day data-acquisition project.

---

## 1. Translation status

| Source | English file | Status | First-row title |
|---|---|---|---|
| I.01 | `I.01_EN.xlsx` | ✓ Translated | "I.1 to I.3 (extended). Agricultural and alpine land [...]" |
| I.51 | `I.51_EN.xlsx` | ✓ Translated | "I.51. Federal Horticulture Censuses 1905 [...]" |
| I.04a | `I.04a_EN.xlsx` | ✓ Translated | (fruit-tree stock 1951) |
| I.38 | `I.38_EN.xlsx` | ✓ Translated | (already used: farm-size distribution, 9 bins) |
| I.39c | `I.39c_EN.xlsx` | ✓ Translated | (already used: parcels per farm) |

Both Task 1 target files are translated. No translation work needed.

---

## 2. I.01 data structure (full inventory)

Sheet: `Worksheet` (the only sheet). 129 rows × 30 columns.

Canton columns in row 6 (and replicated in row 18, 43, 71, 97 for each section): B=ZH, C=BE+JU, D=BE, E=LU, F=UR, ..., Z=NE, AA=GE, AB=JU, AC=CH (28 columns; same convention as I.38).

**Five stacked sections** (header in column B at the section-start row):

| Section row | Section title | Years covered |
|---:|---|---|
| 4 | Productive agricultural and alpine land, excl. forests | 1855, 1877/90, 1912, 1923/24, 1952, 1972, 1979/85 |
| 16 | Open arable land | 1855, 1880/90, 1905, 1919, 1926, 1929, 1934, ..., 1996 |
| 41 | Cereal cultivation area | 1855, 1880/90, 1905, 1919, ..., 1996 |
| 69 | Potato cultivation area | 1855, 1880/90, 1905, 1919, ..., 1996 |
| 95 | **Vineyard area** | 1840/55, 1858, 1877, 1884, 1894, 1905, 1913, 1917, 1919, ..., 1996 |

Each cell: canton × year → area in hectares (or 1000-hectares for the broader categories).

**Vineyard area at 1905** (row 104, the pre-vote baseline year):
- ZH 4410, BE+JU 555, LU 10, UR -, SZ -, OW -, NW -, GL -, ZG 124, FR 50, SO 78, BS -, BL 90, SH 1054, AR -, AI -, SG 645, GR 410, AG 1715, TG 615, TI 6700, VD 6010, VS 3600, NE 980, GE 730 (units = hectares; some cantons "-" = none/missing).

Vineyard data exists for the years 1840/55, 1858, 1877, 1884, 1894, 1905, 1913, 1917, 1919, 1923, 1926, 1929, 1934, 1939, 1941, 1943, 1946, 1950, 1955, 1960, 1965, 1969, 1975, 1980, 1985, 1990, 1996. Rich time-series coverage.

**KEY OBSERVATION**: I.01 reports **only canton-level totals** (one number per canton-year per category). No within-canton distribution. No per-farm or per-vineyard-holder data. The "concentration" derivable from I.01 alone is at the CROP-COMPOSITION level, not the FIRM-DISTRIBUTION level.

---

## 3. I.51 data structure (full inventory)

Sheet: `Worksheet` (the only sheet). 95 rows × 31 columns.

Same canton-column convention as I.01 and I.38.

**Six stacked sections** (header in column B at the section-start row):

| Section row | Section title | Years covered |
|---:|---|---|
| 5 | Enterprises | 1905, 1929, 1939, 1955, 1965, 1969, 1975, 1980, 1985, 1990 |
| 21 | Workforce (total) | 1905, 1929, 1939, 1955, 1965, 1969, 1975, 1980, 1985, 1990 |
| 34 | Of which: Men | same |
| 47 | Of which: Women | same |
| 63 | Permanent workforce (1929+) | 1929 onwards (NO 1905) |
| 75 | Occasional/temporary workforce (1929+) | 1929 onwards (NO 1905) |

**1905 data available for**: enterprise count, total workforce, men in workforce, women in workforce.
**1905 data NOT available for**: permanent vs occasional workforce split (starts 1929).

**1905 ZH enterprise count**: 479. **1905 ZH total workforce**: 1520. Workforce-per-enterprise ratio = 1520/479 ≈ 3.2.

**KEY OBSERVATION**: I.51 covers **horticulture (Gartenbau)**, NOT viticulture (Weinbau). In Swiss agricultural taxonomy these are distinct domains; I.51 is gardens, ornamentals, and fruit/vegetable nurseries, not wine production. Per the existing codebase (`01_import.do` section 10.5), I.51 has been treated as "horticulture as multi-Bootlegger co-explanatory" for the C.7 phase — i.e., a separate industry interest co-aligned with wine but operationally distinct.

I.51 therefore does **NOT** provide vineyard-specific concentration. It might serve as a CO-INDICATOR (cantons with strong horticulture often have strong viticulture too) but isn't the right test for the Olson wine hypothesis.

---

## 4. Feasibility assessment: wine-specific concentration

### NOT feasible from I.01 + I.51 alone

A vineyard-specific Gini analogous to the I.38 land Gini would require:
- (a) Number of vineyard-owning farms per canton, *broken into vineyard-area size bins* (small, medium, large vineyards); OR
- (b) Variance / Gini of per-farm vineyard area within each canton

Neither I.01 nor I.51 reports this. Both stop at canton-level aggregate vineyard area (I.01 §5) or canton-level horticulture enterprise count (I.51 §1).

### Other already-translated HSSO sources reviewed

- **I.04a fruit-tree stock 1951**: per-canton fruit-tree counts. Wrong era (1951) and wrong domain (fruit trees, not vines).
- **I.38 farm-size distribution**: per-canton farm counts by total cultivated area bins. Already used; gives OVERALL agricultural concentration. The Phase 2 NULL result was constructed from this.
- **I.39c parcels per farm**: per-canton average parcels per farm (one number per canton-year). Already used as a concentration proxy in section 12.5 (Olson interactions C.8 phase). Same issue: overall ag, not wine-specific.

### What WOULD give wine-specific concentration

- **I.04 (the broader fruit-and-vineyard census 1905)** if such a thing exists with size bins by canton. Need to check whether HSSO has this and whether it's available in original-language form.
- **Swissstat 1908 federal report on viticulture** — if it survives and has the per-canton-per-size-bin structure. Likely requires Swiss federal archives in Bern.
- **Cantonal viticulture yearbooks (Weinbau-Statistik)** — each wine-producing canton (NE, GE, VD, VS, TI, ZH, AG, etc.) likely published annual reports with per-vineyard size data. Distributed sources; weeks-to-months to compile.
- **Schweizerischer Weinbauverband membership rolls** — if archived, would directly map to organizational mobilization. Trade-association archives.

---

## 5. Tractable alternatives derivable from I.01 alone

Even without wine-specific concentration data, I.01 enables several Olson-style proxies at the canton level. These map to the *industry-dominance-within-canton* version of Olson rather than the *within-industry-organizational-concentration* version, but they are substantively defensible and can be constructed in ~1 hour each.

### Option 5A. Wine specialization ratio: vineyard / open arable land

For each canton at 1905:

```
wine_specialization_c = vineyard_area_c / open_arable_land_c
```

Both quantities come from I.01 at row 22 (arable, 1905) and row 104 (vineyard, 1905). Vine-specialized cantons (VD, VS, NE, GE, TI) score high; cereal/dairy cantons (BE, LU, SG, AG) score low.

**Olson mapping**: if wine is the dominant crop, wine farmers are the agricultural-political majority → stronger collective-action capacity on wine-protection votes. Cantons where wine is one of many crops have politically diluted wine voice. Interaction `vineyard_per_cap × wine_specialization` tests whether the wine-protection effect is amplified in wine-dominant cantons.

**Caveat**: somewhat collinear with `vineyard_per_cap` (both are increasing in vineyard area). Need to test the OLS conditional on the main effect.

### Option 5B. Wine vs substrate ratios

```
wine_vs_cereal_c    = vineyard_area_c / cereal_cultivation_area_c
wine_vs_potato_c    = vineyard_area_c / potato_cultivation_area_c
```

Substantively maps to the paper's substrate-substitution framework: cantons where wine area dominates over substrate (cereal, potato) crops have the most acute economic stake in protecting wine from absinthe substitution. The Olson reading is: cantonal wine farmers face a clearer collective-action problem (vs. fragmented substrate growers) when wine dominates the local crop mix.

Both ratios derivable from I.01 sections §3 (cereal), §4 (potato), §5 (vineyard) at 1905.

### Option 5C. Wine workforce concentration via I.51 horticulture as a proxy

Less compelling. Workforce-per-enterprise in horticulture (I.51 §1 + §2: 1520/479 ≈ 3.2 for ZH at 1905) is a horticultural concentration proxy. Cantons with high horticulture-workforce-concentration tend to have similarly organized viticulture, but the correlation is loose. I would not recommend leading with this; could be used as a robustness check.

### Option 5D. Vineyard area / total productive agricultural land

```
wine_share_of_ag_c = vineyard_area_c / productive_agricultural_land_c
```

Vineyard area from I.01 §5 (1905), productive ag land from I.01 §1 (closest year: 1912). Year-mismatch caveat. Same Olson reading as 5A but with a broader denominator (includes alpine pasture, which most wine cantons have little of).

---

## 6. Recommendation

**For the strategist's call** (Task 3 conditional green-light):

- **Do NOT direct Task 3 to construct a vineyard-specific Gini.** The data don't support it from I.01 or I.51 alone, and acquiring the right source is a multi-week project (Bern archives or distributed cantonal yearbooks).

- **DO consider re-scoping Task 3 to construct wine-specialization ratios (Options 5A, 5B)** and re-run the Olson × Wine interaction with these as the concentration measures, alongside the existing I.38-derived ones. This is a ~1-hour data construction + ~30-minute re-run.

- **Substantive caveat to flag in the paper**: these ratios test *industry dominance within a canton's crop mix*, not *organizational concentration within the wine industry*. Both are Olson-relevant but slightly different theoretical channels. If the within-industry organizational channel matters specifically, only archival evidence (Options E, F, G in the recap notes) can test it directly.

- **Phase 2 NULL interpretation revision**: even if Options 5A, 5B also yield NULL interactions, the substantive claim becomes much stronger: "wine cantons supported the ban regardless of whether wine was the dominant local industry OR an organizationally concentrated agricultural sector — vineyard presence is the channel, not industry organization."

---

## 7. Open questions for strategist

1. Is the wine-specialization ratio (Option 5A or 5B) an acceptable Olson proxy, or does the paper specifically need within-industry organizational concentration evidence?

2. If within-industry concentration is required, is there appetite for the Bern-archive sprint (Options E-G in the prior recap), or do we accept the methodological caveat and proceed?

3. If we proceed with wine-specialization ratios, should they be reported alongside the I.38 measures as a 4-vs-4 comparison (overall ag vs wine-specific), or substituted as the new primary?

---

## 8. Provenance

Investigated 2026-05-13 by openpyxl-based file inspection. No code commits triggered by this investigation (Task 1 is read-only). Findings summarized in this notes file.
