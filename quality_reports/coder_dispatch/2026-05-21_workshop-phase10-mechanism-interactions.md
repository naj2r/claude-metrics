# Coder Dispatch: Phase 10 — White-wine mechanism interactions + drop-Ticino robustness

**Date:** 2026-05-21 (Phase 10 addendum to 2026-05-21_workshop-draft-pipeline-dispatch.md)
**Workshop deadline:** 2026-05-22 (imminent — Phase 10 work that lands in time goes to workshop; balance flows into EEH submission package)
**Strategist on standby for output review**

---

## Context — what's done, what this builds on

Phases 0-9 are complete (see prior dispatch + your completion report). The current workshop master MD has:
- Tables 1-8 + Figures 1-2 in `_md/workshop/canton_workshop_summary.md`
- Table 9 (wine-type cascade decomposition) with Panels A (aggregate), B (white wine), C (red wine)
- Diagnostic correlation matrix as Appendix A.x

The white-wine Simpson sign-flip in Panel B is the substantive headline that supports Cahannes (1981)'s substitution claim via structural pattern, not col-5 magnitude comparison.

**This dispatch adds Phase 10 — direct interaction tests of the Cahannes mechanism plus a drop-Ticino sample-restriction robustness.** Phase 10 outputs go to the MAIN PAPER as tables (not appendix), with full markdown + LaTeX twins per the existing convention.

---

## Hard rules — same as prior dispatch

Read all `.claude/rules/*.md` before executing. Flag any conflict with this dispatch. Same known frictions apply: HC3 SEs throughout, `_inventory_append` gated on `RUN_POSTCREDITS=1`, no `/*.<ext>` glob substrings in section banners, all paths via globals, no PI variable renames.

If conflicts arise, halt and report with proposed resolution.

---

## Scope summary

Add as new sections in `09_canton_reg1_workshop.do` (after the existing §2.9 wine-type battery, as §2.10) and new content in `11_canton_robustness_tables_workshop.do` or a new `19_workshop_mechanism_interactions.do` (coder's call — whichever is cleaner architecturally).

**Five new specifications (Vote #68 outcome, Y1):**

1. **D1**: White × French interaction with absinthe-producer DUMMY control
2. **D2**: White × French interaction with absinthe industry-share CONTINUOUS control
3. **E1**: White × Absinthe-producer interaction (DUMMY interaction)
4. **E2**: White × Absinthe industry-share interaction (CONTINUOUS interaction)
5. **F**: Drop-Ticino sample restriction on the full Table 9 cascade (Panels A, B, C with N=24)

For each interaction spec (D1, D2, E1, E2): also report **marginal effects at specific moderator values** to make interpretation transparent.

For F: re-run the full cascade (cols 1-5) for X3_share, X3_white_share, X3_red_share with TI excluded.

Output paths:
- LaTeX: `C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft/`
- Markdown twins: `$MyProject/results/tables/_md/workshop/`
- Master MD integration: append/insert into `canton_workshop_summary.md` after current Table 9

---

## Phase 10A — Spec D: White × French interaction

### Theoretical motivation

Cahannes (1981) predicts white-wine mobilization should be stronger in French-speaking cantons, where white wine was the dominant consumer beverage and absinthe was a direct substitute. The interaction term β(X3_white_share × cov1) directly tests this.

### D1: with absinthe-producer dummy

```stata
**# 2.10a Spec D1: White × French interaction, absinthe dummy control
{
    cap drop X3_white_x_cov1
    gen double X3_white_x_cov1 = X3_white_share * cov1
    label var X3_white_x_cov1 "Wine revenue, white national share × French language share"

    * OLS HC3
    cap estimates drop ols_white_french_dummy
    qui regress Y1 X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density, vce(hc3)
    estimates store ols_white_french_dummy
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_french_dummy.ster", replace
    di as text "  D1 OLS: β(white)=" %8.4f _b[X3_white_share] ", β(french)=" %8.4f _b[cov1] ", β(white×french)=" %8.4f _b[X3_white_x_cov1]

    * FL AME parallel
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    cap estimates drop fl_white_french_dummy
    qui fracreg logit Y1_frac X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density, vce(robust)
    estimates store fl_white_french_dummy

    * Marginal effects of X3_white_share at cov1 ∈ {0, 25, 50, 75, 100}
    margins, at(cov1=(0 25 50 75 100)) post
    estimates store fl_white_french_dummy_margins
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_dummy_margins.ster", replace
    drop Y1_frac
}
```

### D2: with absinthe industry share continuous control

```stata
**# 2.10b Spec D2: White × French interaction, absinthe continuous control
{
    * (X3_white_x_cov1 already defined in D1)

    * OLS HC3
    cap estimates drop ols_white_french_cont
    qui regress Y1 X3_white_share cov1 X3_white_x_cov1 cov2_total_share cov3 ln_density, vce(hc3)
    estimates store ols_white_french_cont
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_french_cont.ster", replace

    * FL AME parallel + marginal effects at cov1 ∈ {0, 25, 50, 75, 100}
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    cap estimates drop fl_white_french_cont
    qui fracreg logit Y1_frac X3_white_share cov1 X3_white_x_cov1 cov2_total_share cov3 ln_density, vce(robust)
    estimates store fl_white_french_cont
    margins, at(cov1=(0 25 50 75 100)) post
    estimates store fl_white_french_cont_margins
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_french_cont_margins.ster", replace
    drop Y1_frac
}
```

### Interpretation

The interaction coefficient β(X3_white × cov1):
- **Positive and significant** → Cahannes substitution mechanism confirmed: white-wine effect strengthens in French regions
- **Null** → white-wine effect is uniform across cultural contexts; no conditional substitution mechanism
- **Negative** → unexpected; would suggest white-wine mobilization is concentrated in non-French cantons

The marginal effects panel makes the substantive interpretation transparent: the predicted marginal effect of a 1pp increase in white-wine national share at canton with 0% French, 50% French, and 100% French shows how the white-wine effect varies with cultural composition.

---

## Phase 10B — Spec E: White × Absinthe interaction

### Theoretical motivation

In cantons where white wine and absinthe industries COEXIST (Neuchâtel, Geneva primarily), the wine-rent-seeking-for-ban motive competes with the local-absinthe-protect motive. The interaction quantifies this dampening.

### E1: White × Absinthe-producer dummy interaction

```stata
**# 2.10c Spec E1: White × Absinthe-producer dummy interaction
{
    cap drop X3_white_x_absprod
    gen double X3_white_x_absprod = X3_white_share * abs_producer
    label var X3_white_x_absprod "Wine revenue, white national share × Absinthe-producer indicator"

    * OLS HC3
    cap estimates drop ols_white_absprod
    qui regress Y1 X3_white_share abs_producer X3_white_x_absprod cov1 cov3 ln_density, vce(hc3)
    estimates store ols_white_absprod
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_absprod.ster", replace

    * FL AME
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    cap estimates drop fl_white_absprod
    qui fracreg logit Y1_frac X3_white_share abs_producer X3_white_x_absprod cov1 cov3 ln_density, vce(robust)
    estimates store fl_white_absprod

    * Marginal effects of X3_white_share by absinthe-producer status (0/1)
    margins, at(abs_producer=(0 1)) post
    estimates store fl_white_absprod_margins
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_absprod_margins.ster", replace
    drop Y1_frac
}
```

### E2: White × Absinthe industry-share continuous interaction

```stata
**# 2.10d Spec E2: White × Absinthe industry-share continuous interaction
{
    cap drop X3_white_x_cov2
    gen double X3_white_x_cov2 = X3_white_share * cov2_total_share
    label var X3_white_x_cov2 "Wine revenue, white national share × Absinthe industry share"

    * OLS HC3
    cap estimates drop ols_white_cov2
    qui regress Y1 X3_white_share cov2_total_share X3_white_x_cov2 cov1 cov3 ln_density, vce(hc3)
    estimates store ols_white_cov2
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_cov2.ster", replace

    * FL AME
    cap drop Y1_frac
    gen double Y1_frac = Y1 / 100
    cap estimates drop fl_white_cov2
    qui fracreg logit Y1_frac X3_white_share cov2_total_share X3_white_x_cov2 cov1 cov3 ln_density, vce(robust)
    estimates store fl_white_cov2

    * Marginal effects of X3_white_share at cov2_total_share ∈ {0, 5, 25, 50}
    margins, at(cov2_total_share=(0 5 25 50)) post
    estimates store fl_white_cov2_margins
    estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/fl_white_cov2_margins.ster", replace
    drop Y1_frac
}
```

### Interpretation

The interaction β(X3_white × abs_producer) or β(X3_white × cov2_total_share):
- **Negative and significant** → expected per substitution-vs-overlap theory: wine producers in absinthe-producing cantons mobilize less for the ban because of competing local industry interests
- **Null** → no industry-overlap dampening; wine producers in absinthe cantons behaved like wine producers elsewhere
- **Positive** → unexpected; would suggest the two industries reinforced each other politically (would require its own substantive interpretation)

---

## Phase 10C — Spec F: Drop-Ticino sample restriction

### Theoretical motivation

Ticino is the only Italian-speaking canton in the cohort and the dominant red-wine producer (100% red, 47.6% of national red-wine value). TI voted heavily yes on the absinthe ban for Catholic/Italian cultural reasons not connected to any wine-industry rent-seeking. The red-wine cascade in current Table 9 Panel C may be partially driven by TI's mobilization through this cultural channel rather than any wine-industry channel.

Re-running the full Table 9 cascade with TI excluded (N=24) tests whether:
- The red-wine null-contrast pattern (no Simpson flip) survives without TI
- The white-wine Simpson flip strengthens without the TI confound
- The aggregate cascade pattern is sensitive to a single canton

This is preferred to the Italian × Red interaction approach (which was identified off TI alone with N=1 identifying variation, effectively a Ticino fixed effect with extra steps).

### Spec F: Drop-TI cascade

```stata
**# 2.10e Spec F: Drop-Ticino cascade (Panels A, B, C re-run with N=24)
{
    * Aggregate wine cascade, no TI
    foreach j of numlist 1/5 {
        cap estimates drop ols_agg_`j'_noti
        qui regress Y1 X3_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
        estimates store ols_agg_`j'_noti
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_agg_`j'_noti.ster", replace
    }

    * White wine cascade, no TI
    foreach j of numlist 1/5 {
        cap estimates drop ols_white_`j'_noti
        qui regress Y1 X3_white_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
        estimates store ols_white_`j'_noti
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_`j'_noti.ster", replace
    }

    * Red wine cascade, no TI
    foreach j of numlist 1/5 {
        cap estimates drop ols_red_`j'_noti
        qui regress Y1 X3_red_share ${ctrl_s_c`j'} if canton_iso != "TI", vce(hc3)
        estimates store ols_red_`j'_noti
        estimates save "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_`j'_noti.ster", replace
    }

    di as text "  Spec F: Drop-Ticino cascades complete (N=24, 15 specs)"
}
```

### Interpretation

- **Red cascade collapses to null after TI removed** → confirms TI was driving the red-wine result; red-wine cantons broadly do NOT support the ban once the Italian cultural channel is excluded
- **Red cascade survives** → wine-industry mobilization extends to non-Italian red-wine cantons (ZH/SH/SG/etc.); TI is not the sole driver
- **White cascade pattern strengthens** → Cahannes mechanism is robust to the cultural-confound canton exclusion
- **White cascade weakens** → counterintuitive; would need substantive investigation

---

## Table 10 — New main-paper table

### Structure

```markdown
**Table 10 — White-wine mechanism interactions**

The Cahannes (1981) substitution mechanism predicts white-wine mobilization 
should be culturally conditional (stronger in French regions) and tempered 
where local absinthe production creates competing industry interests. We test 
both predictions explicitly.

|                                       | (D1) White×Fr, abs dummy | (D2) White×Fr, abs continuous | (E1) White×Abs producer | (E2) White×Abs continuous |
|---------------------------------------|------------------------:|------------------------------:|------------------------:|--------------------------:|
| **Panel A: OLS HC3**                  |                         |                               |                         |                           |
| White wine, national share            | [.]                     | [.]                           | [.]                     | [.]                       |
|                                       | ([.])                   | ([.])                         | ([.])                   | ([.])                     |
| French language share                 | [.]                     | [.]                           | [.]                     | [.]                       |
| Absinthe-producer dummy               | [.]                     |                               | [.]                     |                           |
| Absinthe industry share               |                         | [.]                           |                         | [.]                       |
| **White × French**                    | **[.]**                 | **[.]**                       |                         |                           |
| **White × Absinthe-producer**         |                         |                               | **[.]**                 |                           |
| **White × Absinthe industry share**   |                         |                               |                         | **[.]**                   |
| Protestant share                      | [.]                     | [.]                           | [.]                     | [.]                       |
| Log population density                | [.]                     | [.]                           | [.]                     | [.]                       |
| **Panel B: Fractional Logit AME**     |                         |                               |                         |                           |
| White wine (AME at moderator mean)    | [.]                     | [.]                           | [.]                     | [.]                       |
| **Marginal effect at moderator = low**| [.]                     | [.]                           | [.]                     | [.]                       |
| **Marginal effect at moderator = high**| [.]                    | [.]                           | [.]                     | [.]                       |
| N                                     | 25                      | 25                            | 25                      | 25                        |
| R² (OLS) / Pseudo-R² (FL)             | [.]                     | [.]                           | [.]                     | [.]                       |
```

For Panel B, "moderator = low" and "moderator = high":
- D1: cov1 = 0% (German baseline) vs cov1 = 100% (fully French)
- D2: cov1 = 0% vs cov1 = 100%
- E1: abs_producer = 0 vs abs_producer = 1
- E2: cov2_total_share = 0% vs cov2_total_share = 50% (or maximum observed)

---

## Table 11 — New main-paper table (drop-Ticino robustness)

```markdown
**Table 11 — Cascade robustness: dropping Ticino**

Ticino is the only Italian-speaking canton and the dominant red-wine producer 
(100% red, 47.6% of national red-wine value). TI voted heavily yes on the 
ban for cultural reasons unconnected to wine-industry rent-seeking. We test 
the wine-type cascade's robustness to TI exclusion.

|                                       | (1) bivariate | (2) +french | (3) +absinthe | (4) +protestant | (5) +density |
|---------------------------------------|--------------:|------------:|--------------:|----------------:|-------------:|
| **Panel A: Aggregate wine, N=24 (drop TI)** |       |             |               |                 |              |
| β (X3_share)                          | [.]           | [.]         | [.]           | [.]             | [.]          |
|                                       | ([.])         | ([.])       | ([.])         | ([.])           | ([.])        |
| **Panel B: White wine, N=24 (drop TI)** |             |             |               |                 |              |
| β (X3_white_share)                    | [.]           | [.]         | [.]           | [.]             | [.]          |
|                                       | ([.])         | ([.])       | ([.])         | ([.])           | ([.])        |
| **Panel C: Red wine, N=24 (drop TI)** |               |             |               |                 |              |
| β (X3_red_share)                      | [.]           | [.]         | [.]           | [.]             | [.]          |
|                                       | ([.])         | ([.])       | ([.])         | ([.])           | ([.])        |
| **Comparison vs. N=25 (Table 9)**     | (note row showing which cells changed materially) |
```

---

## Output paths and routing

LaTeX tables (Overleaf, main paper integration):
```
C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft/
├── T10_mechanism_interactions_OLS.tex
├── T10_mechanism_interactions_FL.tex
├── T10_mechanism_interactions_margins.tex
└── T11_drop_ti_cascade.tex
```

Markdown twins (project pipeline):
```
analysis/results/tables/_md/workshop/
├── T10_mechanism_interactions.md
└── T11_drop_ti_cascade.md
```

CSV intermediates:
```
analysis/results/tables/_csv/workshop/
├── T10_mechanism_interactions_OLS.csv
├── T10_mechanism_interactions_FL.csv
├── T10_mechanism_interactions_margins.csv
└── T11_drop_ti_cascade.csv
```

Estimate stores (`.ster`):
```
$MyProject/results/intermediate/estimates_winetype_workshop/
├── ols_white_french_dummy.ster
├── ols_white_french_cont.ster
├── ols_white_absprod.ster
├── ols_white_cov2.ster
├── fl_white_french_dummy.ster + margins.ster
├── fl_white_french_cont.ster + margins.ster
├── fl_white_absprod.ster + margins.ster
├── fl_white_cov2.ster + margins.ster
├── ols_agg_{1-5}_noti.ster
├── ols_white_{1-5}_noti.ster
└── ols_red_{1-5}_noti.ster
```

---

## Workshop master MD updates

Append two new sections to `_md/workshop/canton_workshop_summary.md`:

**After Table 9 (wine-type cascade decomposition):**

```markdown
---

## Table 10 — White-wine mechanism interactions

[Standard discussion paragraph — strategist will provide for final draft. 
Placeholder structure: Cahannes (1981) substitution mechanism is tested 
directly via two interactions: white × French (cultural conditioning) and 
white × absinthe (industry overlap dampening). Both with absinthe in two 
forms (dummy and continuous). All four specs report OLS HC3 + FL AME + 
marginal effects at moderator values.]

[Insert markdown table from T10_mechanism_interactions.md]

---

## Table 11 — Cascade robustness: drop-Ticino

Ticino is the only Italian-speaking canton and dominates national red-wine 
production. Its yes-vote on the absinthe ban reflects Catholic-Italian 
cultural factors unrelated to wine-industry rent-seeking. We test cascade 
robustness by re-running Panels A, B, C of Table 9 with TI excluded (N=24).

[Insert markdown table from T11_drop_ti_cascade.md]
```

---

## Update KEEP_LIST in 18_workshop_replication_strip.do

Add the new interaction variables to the keep list so the stripped cohort 
preserves regression-equivalence:

```stata
* --- Phase 10 mechanism interactions ---
local KEEP_LIST `KEEP_LIST' X3_white_x_cov1 X3_white_x_absprod X3_white_x_cov2
```

Then re-run §3 verification (the 4 sentinel regressions). Add at least one 
Phase 10 sentinel:

```stata
local SENTINELS `SENTINELS' "Y1 X3_white_share cov1 X3_white_x_cov1 abs_producer cov3 ln_density"
```

If this sentinel passes byte-identical between full and strip, Phase 10 
variables are correctly retained.

---

## Verification checklist (run after Phase 10 complete)

1. All 5 new specs (D1, D2, E1, E2, F) produce non-error output.
2. All sample sizes are N=25 for D/E, N=24 for F.
3. No existing tables/masters overwritten (mtime check on T1-T9 LaTeX files).
4. New tables (T10, T11) compile cleanly in Overleaf format.
5. Markdown twins (T10.md, T11.md) render correctly without label-comma issues.
6. Master MD updated with both new sections.
7. Strip sentinel passes for at least one Phase 10 spec.
8. Marginal effects from D1/D2/E1/E2 are computed and reported.

---

## Reporting requirements

In your completion message:

1. **Sentinel numbers for each new spec:**
   - D1: β(white), β(cov1), β(white×cov1) + FL AME margins at cov1=0/50/100
   - D2: same structure with continuous absinthe
   - E1: β(white), β(abs_producer), β(white×absprod) + FL AME margins at abs_producer=0/1
   - E2: β(white), β(cov2), β(white×cov2) + FL AME margins at cov2=0/25/50
   - F: Three cascades' β + p values for the drop-TI specifications

2. **Comparative interpretation:** Does β(white×cov1) > 0? Does β(white×abs_producer) < 0? Does the red cascade collapse to null after dropping TI?

3. **File paths** for T10, T11 .tex/.md/.csv outputs.

4. **Master MD section locations** where T10 and T11 were inserted.

5. **Any judgment calls made** during implementation (e.g., margins, at() values; treatment of mixed-wine in any interaction; SE specification for FL margins).

6. **Strip verification status** after Phase 10 sentinel added.

7. **Wallclock per spec.**

---

## DO NOT

- Touch existing tables T1-T9 (.tex or markdown).
- Modify the original 08-13 .do files.
- Re-run the strip without first adding the Phase 10 sentinel.
- Use raw Stata variable names in T10/T11 outputs — every coefficient row gets a human-readable label.
- Compute or report `priorban` in any spec (tabled).
- Add the Italian × Red interaction (replaced by Spec F drop-TI restriction).

---

## Workshop-vs-EEH priority

If time-constrained before the workshop:

**Priority 1 (workshop-essential):** Spec F (drop-Ticino cascade) and Specs D1+D2 (white × French interaction). These directly address the cascade-pattern interpretation that's already in the workshop master MD.

**Priority 2 (workshop-ideal):** Specs E1+E2 (white × absinthe interaction). Adds the substitution-vs-overlap test; nice to have for the workshop but can wait if time-tight.

**Priority 3 (EEH-essential):** Full table layouts T10 and T11 with all four interaction specs side-by-side and marginal-effects panels.

Coder's call on what to ship by workshop deadline; whatever doesn't make it goes to EEH submission package.

---

## End of dispatch.

Strategist on standby for partial-run review or interpretation calls. Halt and report if any spec produces unexpected results (e.g., interaction with the wrong sign, N drops below 24, marginal effects nonsensical).
