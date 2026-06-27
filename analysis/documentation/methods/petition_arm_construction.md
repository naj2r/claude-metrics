# Petition arm construction (§7–§8 of the 1908 cohort redraft)

**Created:** 2026-06-26.
**Scope:** documents how the 1908 *petition* outcome and its inputs are built in
`analysis/scripts/redrafts/redraft_08_setup_cohort_1908.do` §7–§8, the reasoning behind
each vintage/denominator choice, the one deliberate deviation from production, and how
each piece is coded. Written so it stands alone years later.

---

## TL;DR

- The 1908 cohort carries **two outcomes on one shared right-hand side**: the **#68 federal
  vote** and the **petition**. They ride the same cohort because they share the same
  covariate *values* (1900-census `cov1`/`cov3`, Milliet producer `cov2*`/`abs_producer`,
  wine shares). The petition is **not** a separate script — it lives in the main cohort.
- The petition arm is **1906-vintage throughout** (the petition's peak-signature year), the
  deliberate single-case exception to the rest of the cohort (1900-census covariates; 1907
  for #68's scale control).
- **Eligibility denominator** `eligible_1906` is a **proxy**: the eligibility roll of
  **Vote 65 (the federal Foodstuffs Act / *Lebensmittelgesetz*, 10 June 1906)** — a
  *same-year* federal vote, since no standalone petition-eligibility count exists. National
  ≈ **784,769**.
- **Signatures** `pet_total`/`pet_valid`/`pet_invalid` come from `AbsinthePetition.xlsx`
  (national 169,377 / 167,814 / 1,563; *Bundesblatt* 1907 p.984).
- **`pop_1906`** is the yearbook's 1906 annual estimate (national 3,491,163) — itself an
  **inter-census interpolation** between the 1900 and 1910 censuses (the "rough midpoint
  proxy" on the population side).
- **One approved deviation from production:** production reuses #68's **1907** `ln_density`
  as the petition's density control; the redraft instead builds a **1906-vintage
  `ln_density_1906`** (PI-approved 2026-06-26). This is **out of the equivalence gate** (no
  production counterpart) and **changes the petition col-5 coefficients** relative to
  production. Everything else in the arm is byte-equal to production and gated.

---

## Why the petition rides the main cohort (scope rule)

An outcome belongs in this cohort **iff it shares these covariate values**. The petition
and vote #68 are both 1908-cohort events evaluated against the *same* 1900-census language
(`cov1`) / religion (`cov3`), Milliet producer (`cov2*`, `abs_producer`), and wine-share
covariates — so they share one right-hand side and one cohort. Cross-year referenda (same
variables, *different values* for a different year) do **not** belong here; they go to
separate per-year scripts in a secondary phase.

Consequence: the petition's numerator (signatures), its eligibility denominator, and its
1906 population/density inputs are all pulled into `redraft_08…` §7–§8 rather than a
standalone petition script.

---

## The 1906 vintage (and why it's the exception)

The rest of the cohort uses **1900-census** covariates (the nearest census to 1908) and
**1907** for #68's population/scale control (the pre-vote annual, matching the 1907 wine
vintage). The petition breaks this: it is dated to **1906**, the **peak-signature year**,
so its scale inputs are 1906-vintage. This is the deliberate single-case exception to the
opening-date vintage rule. Three 1906-vintage pieces, two kinds of proxy:

| piece | what it is | proxy type |
|---|---|---|
| `eligible_1906` | Vote 65's eligibility roll (10 Jun 1906) | a **real same-year vote's** roll (exact, borrowed) |
| `pop_1906` | yearbook 1906 annual estimate | an **inter-census interpolation** (1900↔1910) |
| `ln_density_1906` | `ln(pop_1906 / fixed 1900-census area)` | derived; the approved spec change |

---

## Piece by piece — reasoning + how it's coded

### §7 — `pop_1906` and the 1906 density

**Source.** `pop_1906` is read from the **same** yearbook as `pop_1907`
(`$Absinthe1Data/original/Statistical Yearbooks of Switzerland/SwissStats1908_population_1908-1867.xlsx`,
sheet "English"), just the **1906 column (col D)** instead of 1907's col C. Header layout:
row 4 = years (A=Canton, **B=1908, C=1907, D=1906**, … J=1900); cantons on rows 5–29;
Switzerland on row 30.

**How coded (§7.1).** Identical to §3.1 (the `pop_1907` read) with col D:
`import excel … allstring`; `assert A[4]=="Canton"` and **`assert real(D[4])==1906`** (guards
against column drift); `keep A D`; `keep in 5/30`; strip a trailing parenthetical from canton
names (`Grisons (Graubünden)` → `Grisons`); comma-strip + `real()`→`double`; map the 25
English names + `Switzerland` to ISO via the explicit ladder. **Self-validating:** the 25
cantons must sum to the file's own Switzerland row (`reldif < 1e-6`); the value `3,491,163`
is an *optional* documented source-version pin (delete the one line for a purely
self-validating check). Drop the CH row; `assert _N==25`; save tempfile; merge 1:1.

**The density (§7.2) — the SPEC CHANGE.** Production builds `pop_1906` as a **raw denominator
only** and explicitly derives **no density on 1906** (`08_setup_cohort_1908.do:1159`); its
petition regression reuses **#68's 1907 `ln_density`** (the col-5 "density-swap" control
`ln_density`, built from `pop_1907`). The redraft instead builds a **1906-vintage** density,
using the **same fixed land area** as §3 (`canton_area_km2 = 1900-census pop / 1900-census
density`, which is time-invariant):

```
gen double pop_density_1906 = pop_1906 / canton_area_km2
gen double ln_density_1906  = ln(pop_density_1906)
```

Rationale: vintage-matching the density to the 1906 petition is cleaner than borrowing the
1907 figure. **Consequences, made explicit:** (1) `ln_density_1906` has **no production
counterpart**, so it is **out of the equivalence gate** — validated instead by the derived-
identity assert `reldif(ln_density_1906, ln(pop_1906/canton_area_km2)) < 1e-12`; (2) using it
as the petition's col-5 density control **changes the petition coefficients** versus
production (which used 1907). This is a real, PI-approved spec change (2026-06-26), not a
silent port. **`pop_1906` itself is in production and is gated (§7.4): 0-diff confirmed.**

Sanity: `ln_density_1906` mean = **4.6607** vs 1907 `ln_density` mean = **4.6683** — slightly
lower, as 1906 population is slightly below 1907. As expected.

### §8.1 — eligibility proxy `eligible_1906` (Vote 65)

**Reasoning.** The primary petition outcome is signatures *per eligible voter*, but there is
no standalone "petition eligibility" count. The nearest federal vote to the petition is
**Vote 65, the Foodstuffs Act (*Lebensmittelgesetz*), 10 June 1906** — same year as the
petition — so its eligibility roll is used as the petition's eligibility denominator. It is
therefore a **1906-vintage** proxy (a real same-year vote's roll), national ≈ **784,769**.

**How coded.** A **separate** swissvotes read (§1's import is preserved verbatim and filters
to votes 67/68/69): `import delimited … swissvotes_dataset.csv` → `keep if anr == 65` →
`assert c(N)==1` → keep the 25 `<ct>berecht` columns → rename to the `berecht_<ct>` stub →
`reshape long berecht_, i(anr) j(canton_iso) string` → `rename berecht_ eligible_1906` →
`destring … ignore(",")` → `assert c(N)==25` → merge 1:1. Mirrors prod
`08_setup_cohort_1908_workshop.do §3`. National total asserted in [780k, 790k].

### §8.2 — signatures `pet_total` / `pet_valid` / `pet_invalid`

**Source.** `$Absinthe1Data/translated/AbsinthePetition.xlsx` (a PI-curated translation of
the petition tally from PDF). Layout: row 1 header, rows 2–26 = 25 cantons, **row 27 =
"Total"**. National totals 169,377 / 167,814 / 1,563 (*Bundesblatt* 1907 p.984).

**How coded.** `import excel … cellrange(A1:E27) firstrow` (header → variable names
`Canton`, `RegionCode`, `TotalSignaturesReceived`, `ValidSignatures`, `InvalidSignatures`).
**Provenance check before trimming:** the printed **Total row** is cross-validated against
the published nationals (`assert inrange(…)` for each) — stronger than a self-sum, which
would match by construction — *then* the Total row is dropped. Rename `RegionCode →
canton_iso`, `TotalSignaturesReceived → pet_total`, etc.; `assert _N==25`; merge 1:1.
**Integrity assert:** `pet_valid + pet_invalid == pet_total` (exact). Mirrors prod
`08_workshop §4` (lifted there verbatim from `12 §1.2`).

### §8.3 — the three petition outcomes

```
gen double pet_per_eligible = pet_total / eligible_1906 * 100   // PRIMARY
gen double pet_per_cap      = pet_total / pop_1906      * 100   // fallback (per capita, 1906)
gen double pet_natshare     = pet_total / 169377        * 100   // alt (canton share of national)
```

- **`pet_per_eligible` (PRIMARY)** — signatures per 100 *eligible voters*; denominator is the
  vintage-matched Vote-65 1906 roll. On the same 0–100 scale as the vote outcome `Y1`.
- **`pet_per_cap` (fallback)** — signatures per 100 *residents*; denominator `pop_1906`. (Note:
  prod's `09_workshop:534` *comment* says the denominator is `pop_1900`, but the *code*
  (`:559`) uses `pop_1906` — the code is authoritative; the comment is stale.)
- **`pet_natshare` (alt scale)** — canton's share of the 169,377 national total; sums to 100
  across cantons (`assert reldif(sum, 100) < 1e-6`).

---

## Equivalence-gate coverage

Gated against the frozen pre-consolidation snapshot
(`analysis/processed/cohort_1908_workshop_preconsolidation.dta`), merged on `canton_iso`
(`recast str8` to match prod's `str2` key on value, not datasignature):

| column | gated? | result |
|---|---|---|
| `pop_1906` | ✅ §7.4 | 0-diff |
| `eligible_1906` | ✅ §8.5 | 0-diff |
| `pet_total` / `pet_valid` / `pet_invalid` | ✅ §8.5 | 0-diff |
| `pet_per_eligible` / `pet_per_cap` / `pet_natshare` | ✅ §8.5 | 0-diff |
| `pop_density_1906` / **`ln_density_1906`** | ❌ (no prod counterpart) | spec change; validated by derived-identity assert |

Full file end-to-end (2026-06-26): **rc=0, 25 obs × 58 vars**, all five gates (§4.5, §5.4,
§6.4, §7.4, §8.5) PASS, `abs_producer` = 8.

---

## Deferred: `prior_canton_ban`

Built in prod `08 §6` (`= inlist(canton_iso,"VD","GE")`, the VD-1906 + GE-1907 cantonal
retail bans) but consumed by **no live workshop spec** (the only apparent user,
`_section_2_1_anchor_stats.do`, rebuilds its own `prior_ban` from `canton_iso`). **Deferred,
default drop** — and it's a genuine *judgement call*: the VD/GE cantonal bans are so close in
time to the 1908 federal vote that whether they're a clean pre-treatment control or
contaminated by the federal campaign is not obvious. The PI decides during streamlining;
not default-carried.

---

## Provenance (production sources mirrored)

- Eligibility: `08_setup_cohort_1908_workshop.do` §3 (lines ~104–148).
- Signatures: `08_setup_cohort_1908_workshop.do` §4 (lines ~161–221); source
  `$Absinthe1Data/translated/AbsinthePetition.xlsx`.
- Outcomes: `09_canton_reg1_workshop.do` §1.6 (lines ~536–564); petition battery
  `12_canton_petition_workshop.do` (runs `pet_per_eligible` on the col-5 controls).
- Density precedent (1900-census area backout): `redraft_08…` §3; prod `08` §8.2.
- The "prod reuses 1907 for the petition" finding: `08_setup_cohort_1908.do:1159`
  ("no density derived on 1906") + the col-5 control set `ctrl_s_c5 = … ln_density`.
- Related note: `analysis/documentation/producer_variable_disambiguation.md` (the `cov2*`
  family); the redraft header BUILD-PHASE MAP.
