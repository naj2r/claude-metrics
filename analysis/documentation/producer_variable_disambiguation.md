# Producer-treatment variables: canonical vs. investigation-stage

**Created:** 2026-06-09 (producer-variable disambiguation cleanup).
**Why this exists:** two different "producer" variables live in two different datasets with colliding names; an earlier dispatch fused the *name* of one with the *definition* of the other. This note is the single source of truth so it never re-conflates.

## TL;DR
- **Headline producer-coalition treatment = `abs_producer`** in `cohort_1908_workshop.dta`
  (**firm-register membership**: canton has ≥1 Milliet-listed absinthe firm; **8 cantons**;
  numerically identical to `cov2_total_share > 0`, but defined by identification, not quantity).
  It is an **absinthe-trade-interest** set (handled/sold absinthe per excise records),
  **not** a strict manufacturer set. Feeds `T_producer_cascade` **[FINAL]**, `fr_x_producer`,
  and the inference battery (scripts 09/22/23). This is what the deck / EEH manuscript mean by "producer."
- **`absinthe_dummy` / `_broad` / `_any`** in `absinthe_analysis.dta` are **investigation-stage
  robustness tiers** (NE / NE+VD / NE+VD+GE), hardcoded canton lists — the
  *manufacturing-heartland ladder*. **NOT the headline.**

## The two variables

| | `abs_producer` (CANONICAL / headline) | `absinthe_dummy*` (robustness only) |
|---|---|---|
| Dataset | `cohort_1908_workshop.dta` | `absinthe_analysis.dta` |
| Definition | **firm-register membership** (≥1 Milliet-listed firm; redraft §4 builds it as the merge-match `_merge==3`) — numerically `cov2_total_share > 0`, same 8 | hardcoded canton lists |
| Construct | absinthe **trade interest** (handles/sells) | absinthe **manufacturing heartland** |
| Realized set | **8 cantons: BS, FR, GE, NE, SZ, VD, VS, ZG** (5 French + 3 German) | `absinthe_dummy`=NE (1); `_broad`=NE+VD (2); `_any`=NE+VD+GE (3) |
| Defined in | `09_canton_reg1.do:413`, `09_canton_reg1_workshop.do:411` | `02_clean.do:266–268` |
| Feeds | `T_producer_cascade` [FINAL], `fr_x_producer`, scripts 22/23 | `t12_absinthe_tier.tex` (+ t02/t03 robustness cols) |
| Role | **headline** | robustness / superseded |

**Definition reconciliation (2026-06-25, redraft §4).** `abs_producer`'s operative definition is **firm-register membership** — the canton appears in Milliet's annex (≥1 listed absinthe firm) — **not** a quantity threshold on `cov2_total_share`. The two coincide exactly (a canton has positive Milliet purchases iff it has a listed firm), so the realized set is unchanged (the same 8: NE GE BS VD SZ ZG FR VS). The shift matters because Milliet vouches for firm *identification* but flags purchase *quantities* as unreliable (BBl 1907 VI 361); defining the headline dummy by membership keeps it independent of the noisy quantity column. The redraft (`redraft_08_setup_cohort_1908.do` §4.2) builds it as the merge-match (`_merge==3`) and cross-checks that it equals `cov2_total_share > 0 & !missing(...)`. The label was updated to drop the old "Milliet any-purchase" (quantity) wording.

## Source & proxy construction (what `cov2_total_share` measures) — grounded in Milliet's text

Verified against the translated primary source (`Milliet Translations.md` = BBl 1907 VI 355–363, the Federal Alcohol Administration annex, signed E. W. Milliet, Director). Built firm→canton in `08_setup_cohort_1908.do` §7; raw file `$Absinthe1Data/original/MillietTables/AbsintheEst1908.xlsx`.

- **Firm set (who is in it):** the firms the Alcohol Administration could identify as the absinthe industry — (i) those entitled to a **monopoly-tax refund on *exported* absinthe**, plus (ii) a few **Commercial-Register-listed absinthe manufacturers** not in the export trade. **40 firms across the 8 cantons** NE, GE, BS, VD, SZ, ZG, FR, VS. So `abs_producer` (the 8 cantons) is **absinthe-specific**, NOT "all spirits."
- **Quantity (`cov2_total_share`):** each firm's **purchases of high-proof spirit (Sprit à 95° / trois-six) procured directly from the federal monopoly**, 1902–1906 → canton sum → share of the producer national total (`= share_of_total_purchases × 100`). Companions: `cov2_exp` = portion **exported as absinthe**; `cov2_dom` = purchases − exports. The 95° is the monopoly's spirit-feedstock unit (finished absinthe ≈ 65°) — **not an ABV row-filter**; the selector is the monopoly-refund / Commercial-Register status above.
- **Milliet's own caveats (BBl 1907 VI 361 — load-bearing; quote if pressed):**
  - *"do not provide a reliable indication of the scale of absinthe production"* — the firms also make **other products** from the same monopoly spirit, and can buy spirit/absinthe **through middlemen** (uncaptured).
  - the list **omits cold-process (essence) absinthe makers entirely** → distilled-absinthe inputs only.
  - **exports are "considerably more reliable"** than purchases.
- **Window:** 5-year totals 1902–1906 (`_yr` variants = ÷5); shares scale-invariant.
- **Coverage / missing:** only the 8 annex cantons appear; the other 17 are **missing** in base `08` (Milliet specs drop to the 8-producer subsample), but the workshop layer enforces them to **0** for full-N specs — a missing-vs-zero difference to know.

**So, precisely:** a canton-share proxy for **absinthe-industry scale via monopoly-sourced distilling spirit** — absinthe-firm-identified, distilled-only, input-side, and *by Milliet's own admission noisy for "production."* Not a clean production count, not general spirits, not clean trade.

**On "who produced":** Milliet lists absinthe manufacturers across **8 cantons** (NE dominant; the Federal Council's report separately notes **Basel-Stadt has 3 absinthe-manufacturing firms**, export-oriented; VD/GE statutes targeted absinthe production too). So **NE is the heartland, not the sole producer.** The `absinthe_dummy*` NE/VD/GE tiers are a narrower hand-set heartland ladder, not the full producer set.

**Context-rot note:** the terse codebook label ("spirit purchases, Milliet 1902-06") is source-level wording; the absinthe-proxy meaning + caveats live here and in `08` §7. (Earlier in-chat I mis-summarized this as "assumes all spirit→absinthe" and "NE the only producer" — both corrected against the translation above.)

## Why the names mislead
`absinthe_dummy` *sounds* like "produces absinthe (0/1)" but is literally `(canton_code=="NE")` —
it encodes "is Neuchâtel," the manufacturing heartland. The genuine "handled absinthe at all"
indicator is `abs_producer`, a different name in a different file. The **name** matches one
variable while the **definition** matches the other → easy to fuse (which is exactly what an
earlier feasibility dispatch did; caught + corrected 2026-06-09).

## Rules
1. Producer-coalition specs use **`abs_producer`** on `cohort_1908_workshop.dta` unless the run is
   *explicitly* the NE-tier manufacturing robustness.
2. **Every producer spec prints `tab canton_iso if abs_producer==1`** so the realized treated set
   is in the log — the construct is shown, never inferred from a name. (Practiced in
   `_feasibility_ipw_ebal_lewbel.do`, `_lewbel_loo_diagnostic.do`, and `22_canton_inference_battery.do`.)
3. `absinthe_dummy*` stays robustness-only; **no promotion to headline without strategist sign-off.**

## Secondary metrics decision (possible paper footnote)
`abs_producer` is a **handles/sells-per-excise** definition (Milliet purchases), not strictly
"manufactures." That is a defensible and already-published-in-`T_producer_cascade` choice, but if
a referee presses on "producer," the `absinthe_dummy*` NE-tiers (`02_clean.do`) are the
manufacturing-heartland robustness ladder to cite. State the construct honestly as
*absinthe-trade-interest* in prose, not "manufacturers."

## Provenance
- Root-cause flag + correction: `quality_reports/coder_dispatch/2026-06-09_producer-variable-disambiguation-update.md`,
  `..._feasibility-ipw-ebal-lewbel.md` (CORRECTION block).
- Realized 8-canton set printed + asserted in the feasibility + Lewbel-LOO runs (2026-06-09).
