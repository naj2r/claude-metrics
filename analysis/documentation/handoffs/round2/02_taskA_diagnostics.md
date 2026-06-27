# Round 2 — Task A: Multicollinearity & identification diagnostics

**Read first**: `00_MASTER.md`, `01_setup.md`
**Status**: PENDING
**Prereqs**: Task 01 setup complete (4 packages vendored). Pipeline at green baseline.
**Estimated time**: 3-4 hours
**Output**: `analysis/results/tables/t16_diagnostics.tex` (single table) + new entries in `regressions_expansion.dta`

---

## Purpose (1 paragraph)

Address the obstinate-EEH-reviewer concern: "with N=25 and language-vineyard collinearity, identification is off small residual variation." This is a defensive task — if VIFs are <10, condition number is <30, and PDS-LASSO selects vineyard with a coefficient consistent with our OLS headline, the multicollinearity critique is closed. If VIF/condition fail OR PDS-LASSO drops vineyard, that's a major flag and we stop and report rather than bury.

## Sub-tasks

### A.1 — VIF on the KEY spec

After the headline regression in `05_expansion.do` (or in a new section), add:

```stata
* A.1: VIF on the headline KEY spec
qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
estat vif
matrix vif_table = r(VIF)
local vif_vineyard  = vif_table[1, 1]
local vif_french    = vif_table[2, 1]
local vif_catholic  = vif_table[3, 1]
di "VIF: vineyard=" %5.2f `vif_vineyard' " french=" %5.2f `vif_french' " catholic=" %5.2f `vif_catholic'

* Save to regressions_expansion.dta as one row per VIF
* (use a fake regsave-compatible structure or write to a tempfile and append)
```

Decision point: where to store VIF values. Three options:
- **(a)** Store as 3 rows in `regressions_expansion.dta` with `spec="vif"`, `var="vineyard_per_cap"|"french_share"|"catholic_share"`, `coef=<vif>`. Pro: consistent storage. Con: VIF isn't a regression coefficient, semantic mismatch.
- **(b)** Save to separate `regressions_diagnostics.dta`. Pro: clean separation. Con: extra file to track.
- **(c)** Store as locals + display, then read back into the table builder section by hardcoding. Pro: simplest. Con: not regenerable independently.

**Recommendation**: option (a) with a clear `spec="diagnostic_vif"` label. The `regressions_expansion.dta` is already a heterogeneous catch-all.

### A.2 — BKW condition number

```stata
* A.2: BKW condition number via coldiag2
qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
coldiag2, scaled
* coldiag2 returns r(condnum) (condition number)
local condition_num = r(condnum)
di "BKW condition number (scaled): " %6.2f `condition_num'

* Save: same regsave-style row, spec="diagnostic_bkw"
```

**Verify `coldiag2` syntax** before running. The strategist's example uses `coldiag2, scaled` — confirm with `help coldiag2` after vendoring. If syntax differs, adapt.

Threshold interpretation:
- Condition number < 10: weak collinearity
- 10-30: moderate
- > 30: strong (concern)

### A.3 — Post-double-selection LASSO

```stata
* A.3: PDS-LASSO with available canton-level controls
* Per master MASTER §"Data availability fallbacks":
*   - italian_share NOT available; use lang_italian (binary) instead
*   - urban_share NOT available; omit
*   - protestant_share NOT available; construct as 1 - catholic_share_total

cap drop protestant_share_total
gen double protestant_share_total = 1 - catholic_share_total
label var protestant_share_total "Protestant share of total pop (1 - catholic_share_total)"

local pds_controls "french_share catholic_share protestant_share_total lang_italian ln_pop agland_1000ha avg_parcel_area_1905 parcels_per_farm_1905 net_migration_per_cap"

* PDS-LASSO: vineyard_per_cap is the focal regressor; pds_controls are
* the candidate covariates. partial() declares which to consider for both
* y- and x-equation selection.
pdslasso yes_pct vineyard_per_cap (`pds_controls'), partial(`pds_controls')

* Extract post-selection coef on vineyard_per_cap
local pds_coef = _b[vineyard_per_cap]
local pds_se   = _se[vineyard_per_cap]
local pds_t    = `pds_coef' / `pds_se'
local pds_p    = 2 * (1 - normal(abs(`pds_t')))

* Selected covariates (count + list)
local selected_count = e(p)         // verify e(p) is the right scalar; consult `help pdslasso`
local selected_list  = e(selected)  // ditto

di "PDS-LASSO: vineyard coef=" %7.2f `pds_coef' " (SE=" %6.2f `pds_se' ", p=" %5.3f `pds_p' ")"
di "PDS-LASSO selected " `selected_count' " of `: word count `pds_controls'' candidate controls"
di "Selected: `selected_list'"

* Save: regsave-style row, spec="diagnostic_pdslasso", model="pds_lasso"
```

**Acceptance criterion (CRITICAL)**: PDS-LASSO selected coefficient on `vineyard_per_cap` should be POSITIVE and significantly different from zero (consistent with the OLS headline +484). If LASSO drops vineyard altogether OR selects a negative coefficient, **STOP and flag to user** — that's a major finding against the headline, not a routine result.

If PDS-LASSO succeeds with positive coefficient: continue.

### A.4 — Build t16_diagnostics.tex

```stata
* A.4: Build t16_diagnostics.tex
* Single table with three blocks (panels):
*   Panel A: VIFs (3 rows, one per KEY-spec covariate)
*   Panel B: BKW condition number (1 row)
*   Panel C: PDS-LASSO results (3 rows: coef + SE + p; selected-count; selected-list)

* Read diagnostic rows from regressions_expansion.dta
use "$MyProject/results/intermediate/regressions_expansion.dta", clear
keep if strpos(spec, "diagnostic_")
* ... format and write via texsave ...
```

Caption template (from strategist):
> Multicollinearity diagnostics and post-selection inference. Variance inflation factors (VIFs) and the Belsley-Kuh-Welsch condition number assess potential multicollinearity in the headline specification. Post-double-selection LASSO (Belloni, Chernozhukov, Hansen 2014) provides data-driven covariate selection from a candidate set of `<list candidates>`. Notes on covariate construction: protestant_share_total is constructed as 1 - catholic_share_total because the HSSO Catholic+Protestant religion data does not separately report Protestant counts. Italian share is represented by a binary indicator (lang_italian) because continuous Italian population shares are not available for our HSSO subset. Urban share is omitted because canton-level urbanization data are not in our HSSO extracts; ln_pop partially captures urban-rural variation.

### A.5 — Add assertions

In the existing assertion block of `05_expansion.do`:

```stata
* Task A diagnostic assertions (round 2)
use "$MyProject/results/intermediate/regressions_expansion.dta", clear

* VIFs should all be < 10
foreach v in vineyard_per_cap french_share catholic_share {
    summ coef if spec == "diagnostic_vif" & var == "`v'", meanonly
    di "VIF `v' = " %5.2f r(mean)
    assert r(mean) < 10
}

* BKW condition number should be < 30
summ coef if spec == "diagnostic_bkw", meanonly
di "BKW condition = " %5.2f r(mean)
assert r(mean) < 30

* PDS-LASSO coef on vineyard should be POSITIVE
summ coef if spec == "diagnostic_pdslasso" & var == "vineyard_per_cap", meanonly
di "PDS-LASSO vineyard coef = " %7.2f r(mean)
assert r(mean) > 0
```

If the VIF or condition number assertion fails, **STOP**. That's the diagnostic itself failing — it means the multicollinearity critique is real and we need to either:
- (a) report it honestly with implications discussion, or
- (b) try alternative specifications (e.g., orthogonalize covariates)

Don't paper over by relaxing the assertion.

## Where this lives in `05_expansion.do`

Add as a NEW section between sections 10.9 (Gelbach) and 11 (assertion block):

```
**# 10.10 Round-2 Task A: Multicollinearity diagnostics
*------------------------------------------------------------------------------*
{
    * (the code above)
}
```

And the t16 builder goes between sections 12.11 (existing Gelbach builder) and 12.12 (existing marginsplot builder), as section **12.11.5** OR renumber as **12.12** and shift the marginsplot down to 12.13. Pick whichever produces less churn in the diff.

## Acceptance criteria

- [ ] `t16_diagnostics.tex` exists in `analysis/results/tables/`
- [ ] All 3 VIFs reported and < 10
- [ ] BKW condition number reported and < 30
- [ ] PDS-LASSO selected vineyard with positive coefficient and reasonable magnitude (within 50% of OLS +484)
- [ ] PDS-LASSO selected covariates list reported in caption
- [ ] All new asserts pass at end of pipeline
- [ ] Pipeline runtime not materially increased (< 5 min total)

## Pitfalls

1. **`coldiag2` may have specific data requirements** — it computes condition indexes on the X'X matrix. Confirm it works on the KEY spec data (3 covariates, N=25). If it errors with "matrix not positive definite" or similar, that itself is a multicollinearity signal worth noting.

2. **PDS-LASSO penalization on N=25** — small sample, the LASSO penalty may shrink everything to zero. If `pdslasso` reports "no covariates selected", that doesn't mean vineyard was dropped — it means after partialing out the candidate controls, the residualized vineyard is still significantly related to residualized yes_pct. Check the post-selection coefficient on vineyard, not just the selected list.

3. **`pdslasso` syntax** — confirm via `help pdslasso` after vendoring. Strategist's example is illustrative but the SSC version's exact arg names may differ. Especially the difference between `pdslasso y x (controls)` and `pdslasso y x, controls(...)` syntax variants.

4. **`protestant_share_total = 1 - catholic_share_total`** approximation — this assumes Catholic + Protestant ≈ 100% of pop. Per orchestration follow-up, in 1900 Switzerland the two together = 99.4% (Jewish 0.4%, other/none 0.2%). Document the approximation in t16 caption.

5. **VIF interpretation with HC3 SEs** — `estat vif` after `reg ..., vce(hc3)` should report standard VIFs (not HC3-adjusted, which isn't a thing). The VIF is a feature of the X matrix only, independent of the SE estimator. No correction needed.

## Commit message template

```
round2 Task A: VIF + BKW + PDS-LASSO diagnostics

Defends the headline KEY-spec result against the obstinate-collinearity
critique. Implementation in 05_expansion.do new section 10.10.

Results (verify in test run):
- VIFs: vineyard=<X.XX>, french=<X.XX>, catholic=<X.XX>; all < 10
- BKW condition number: <X.XX>; < 30
- PDS-LASSO: vineyard coef = <YYY> (SE <ZZ>, p=<...>), selected <N>
  of <M> candidate covariates: <list>

protestant_share_total constructed as 1 - catholic_share_total because
HSSO does not separately publish Protestant counts; documented in
t16 caption.

italian_share unavailable; lang_italian (binary) used in PDS-LASSO
candidate set as fallback.

urban_share unavailable; omitted from candidate set; ln_pop partially
proxies urban-rural variation. Documented in t16 caption.

3 new asserts in expansion assertion block. Full pipeline 28+3=31
assertions pass.
```

## Done when

- t16_diagnostics.tex regenerates cleanly via full-pipeline run
- 3 new asserts pass
- Commit pushed
- Move to `03_taskB_formal_hypotheses.md`
