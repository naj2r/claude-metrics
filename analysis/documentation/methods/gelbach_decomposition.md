# Gelbach (2016) Conditional Decomposition — Methods Reference

**Date compiled**: 2026-04-30
**Purpose**: Reference for implementing the Gelbach decomposition in `05_expansion.do` to quantify how much of the absinthe-vote vineyard coefficient sign-flip (bivariate −178.6 → KEY +484.4) is attributable to French-language share vs. Catholic share.

---

## TL;DR (for implementing Claude)

- **Use the official `b1x2` package** by Gelbach himself: `ssc install b1x2`. This is the canonical Stata implementation; do not hand-code from scratch unless cross-validating.
- **Install via `/add-package` slash command** — never inline `ssc install`.
- **Application here**: base spec = `reg yes_pct vineyard_per_cap`, full spec adds `french_share + catholic_share`. The decomposition tells us how much of the coefficient change on `vineyard_per_cap` is attributable to each x2 covariate.
- **Cross-validate by hand**: compute `δ_k = γ_k × β_k_full` for each x2 covariate, where γ_k = coef from `reg x2_k vineyard_per_cap` (auxiliary regression) and β_k_full = coef on x2_k in the full spec. Sum should equal `(β_full − β_base)`.
- **Robust SEs**: `b1x2` accepts `robust` and `cluster()`. **It does not accept `vce(hc3)` directly** — use `robust` (which is HC1) for the package's internal SEs, but report the substantive coefficient with our project's standard `vce(hc3)`.
- **N=25 caveat**: Gelbach's variance formulas are asymptotic. With our small sample, treat point estimates as informative and standard errors as approximate.

## OLS only — methodological necessity, not coverage gap

**The Gelbach decomposition is defined for OLS only.** Reasoning:

The identity `b1base − b1full = Σ_k δ_k` follows from the **Frisch-Waugh-Lovell theorem on linear projections**. Each `δ_k = π_k × γ_k_full` decomposes the coefficient gap into components attributable to each x2 covariate, and the additivity is a property of orthogonal linear projections.

Fractional logit (and any nonlinear link function) breaks FWL: the marginal effect of `x1` is no longer a linear projection of `y` onto the residualized `x1`, but instead a function of the link's first derivative evaluated at the observed `xβ`. The additive δ decomposition is therefore **undefined for fracreg AMEs**.

A "right" nonlinear analog of Gelbach exists — it's closer to the **Blinder-Oaxaca decomposition for nonlinear models** (Yun 2004; Bauer & Sinning 2008). That object decomposes a *gap in predicted means between two groups* rather than a *coefficient change between two specifications*, and it is not what `b1x2` implements.

**Coverage in this project**:
- `t02` (OLS) and `t03` (fracreg AMEs) — symmetric reporting of the headline KEY-spec triplet.
- `t13` (cross-referendum panel) — symmetric: OLS + fracreg AMEs side-by-side for all 15 votes 1900-1910 (added 2026-04-30 per phase-review S4).
- `t15` (Gelbach decomposition) — OLS only. Reporting a fracreg-Gelbach is not possible because the decomposition theorem doesn't extend; reporting *something else* (e.g., Blinder-Oaxaca) would be a different paper.

When a referee asks "why no fracreg Gelbach?", the answer is: **the decomposition theorem requires linearity. There is no fracreg Gelbach to compute.**

---

## What it is

Gelbach (2016, *JLE*) provides an **omitted-variable-bias-based decomposition** of the change in a focal regressor's coefficient when controls are added.

Notation:
- y = outcome
- x1 = focal regressor (vineyard_per_cap)
- x2 = vector of additional controls (french_share, catholic_share)
- "base" spec: `y = α + β_base · x1 + ε` (no x2)
- "full" spec: `y = α + β_full · x1 + γ' x2 + ε` (with x2)

**Identity (b1x2 sign convention, verified against package source)**:
```
b1base − b1full = Σ_k δ_k          (THIS is what b1x2 reports)

equivalently:

b1full − b1base = − Σ_k δ_k

where  δ_k = π_k × γ_k_full

  γ_k_full = coef on x2_k in the full regression (b2u in package code)
  π_k      = coef on x1 from the auxiliary regression of x2_k on x1
```

Each `δ_k` is the contribution of x2_k to the coefficient change.

**Sign in our application**: vineyard coef goes from b1base = −178.6 (bivariate) to b1full = +484.4 (KEY spec). So `b1base − b1full = −178.6 − 484.4 = −663.0`, which is what b1x2 will report as the total decomposition (and the sign of each δ_k will reflect the proportional contribution to that −663). Adding controls flips the coefficient UP by 663 — a Simpson sign-flip — so the δ_k's are NEGATIVE in our case (consistent with controls "absorbing" downward bias from the bivariate).

**Key property — order independence**: unlike sequential addition (`reg y x1` → `reg y x1 cath` → `reg y x1 cath fr`), Gelbach's decomposition does NOT depend on the order in which controls are added. Each δ_k is conditional on all other x2 controls being in the full spec.

**Why this is useful for our paper**: the Simpson sign-flip from −178.6 (bivariate) to +484.4 (KEY) is a coefficient change of +662.9. A reviewer will ask: "How much of this flip is driven by language vs. religion?" Gelbach gives the answer mechanically. Without it, we'd be telling a qualitative story; with it, we have numbers.

---

## Stata implementation: `b1x2`

### Install
```stata
ssc install b1x2
```

We will install via the project's `/add-package` slash command, which vendors the `.ado` and `.sthlp` into `analysis/scripts/libraries/stata/` and registers in `stata.trk`. Reproducibility-archive standard.

### Syntax
```stata
b1x2 depvar [if] [in] [aweight fweight iweight] ,
    x1all(varlist)        // base regressors (focal x1)
    x2all(varlist)        // additional controls
    [ x1only(varname)     // restrict decomposition reporting to one x1
      x1endog(varlist)    // endogenous x1 vars (for IV)
      iv(varlist)         // instruments (for IV)
      Robust              // robust SEs (HC1)
      Cluster(varname)    // cluster SEs
      x2delta(string)     // group x2 vars (e.g. "LANG=french_share : RELIG=catholic_share")
      noBase noFull       // suppress base/full spec output
      gamma0 cov0         // suppress gamma/cov terms in output
    ]
```

### Our planned application

```stata
* Bare decomposition (one row per x2 covariate)
b1x2 yes_pct, x1all(vineyard_per_cap) ///
    x2all(french_share catholic_share) robust

* With grouping for cleaner reporting
b1x2 yes_pct, x1all(vineyard_per_cap) ///
    x2all(french_share catholic_share) ///
    x2delta("LANG=french_share : RELIG=catholic_share") robust
```

### Interpreting the output

The package outputs a table like:

```
                     |   delta    se     z    P>|z|  [95% CI]
---------------------+----------------------------------------
vineyard_per_cap     |
            LANG     |  -660.2   201.3 -3.28  0.001  [-1054.8 -265.6]
            RELIG    |    -2.7    49.1 -0.05  0.957  [  -98.9   93.5]
            __TC     |  -662.9                       (= b1base - b1full)
---------------------+----------------------------------------
```

(Hypothetical numbers. The point: each row is the contribution of one x2 group to the coefficient change. The `__TC` (total change) row is the sum of all group δ's and equals `b1base − b1full` exactly.)

**KNOWN PACKAGE LIMITATION (verified in b1x2.ado source line 1231-1233)**: the package's reported covariance between the `__TC` coefficient and the individual group coefficients is set to zero, which is NOT correct. The package author flags this in the output: "This is NOT correct!!". Practical implication: do not test the `__TC` coefficient against group coefficients using `test`/`lincom`. Each group δ has correct SE; the `__TC` SE is also computed correctly; the covariance is the part that's wrong. For our paper, we report individual group δ's and their SEs, not joint tests.

**Substantive interpretation for our paper**: If the decomposition shows ~99% of the sign flip is driven by language and ~1% by religion, the Simpson story is overwhelmingly a *language* story. That sharpens the framing: it isn't "language and religion both confound the bivariate"; it's "language is the entire confound."

---

## Cross-validation by hand

Per project convention "no guesses on brand-new methods", we will hand-compute the decomposition and `assert` agreement with `b1x2` output.

```stata
* Auxiliary regressions: x2_k on x1
qui reg french_share vineyard_per_cap
local pi_french = _b[vineyard_per_cap]

qui reg catholic_share vineyard_per_cap
local pi_catholic = _b[vineyard_per_cap]

* Full spec: get γ on each x2_k
qui reg yes_pct vineyard_per_cap french_share catholic_share, vce(hc3)
local g_french   = _b[french_share]
local g_catholic = _b[catholic_share]
local b_full     = _b[vineyard_per_cap]

* Base spec
qui reg yes_pct vineyard_per_cap, vce(hc3)
local b_base = _b[vineyard_per_cap]

* Decomposition contributions (b1x2 sign convention: b1base - b1full)
local d_french   = `pi_french'   * `g_french'
local d_catholic = `pi_catholic' * `g_catholic'
local d_total    = `d_french' + `d_catholic'

* Identity check (should equal b_base - b_full, up to numerical precision)
local check_diff = (`b_base' - `b_full') - `d_total'
assert abs(`check_diff') < 1e-6  // hand calc matches identity
```

If `b1x2` is unavailable for any reason, the hand calc gives identical point estimates. Variance/SE requires more work (Gelbach Appendix A); for our small N, point estimates are the substantive output.

---

## Caveats

### 1. Linearity
The decomposition is exact for linear regressions. Our specs are OLS, so this is fine. If we later switch to fractional logit headline, Gelbach does not directly apply — would need to use AMEs and a different decomposition framework.

### 2. Small-sample inference
Gelbach's published asymptotic SEs may underperform at N=25. The package's `robust` SE is HC1 by default. For inference, we will pair the Gelbach point estimates with our existing `randomization inference (10k perms)` for the underlying coefficient stability check.

### 3. Interpretation of negative δ
A negative δ_k means: "adding x2_k to the spec moves β_x1 *upward*." In our case, both french_share and catholic_share should produce negative δ (because both correlate negatively with vineyard_per_cap and positively with yes_pct in some way that contributes to the Simpson confound). The signs and relative magnitudes are the substantive content.

### 4. Order independence is a feature
Reviewers sometimes object to "the result depends on which control you add first." Gelbach explicitly designed this method to break that dependence. Each δ_k is computed conditional on ALL other x2 controls being in the model.

### 5. Difference from Oster (2019)
Oster's δ asks: "How important would unobservables need to be (relative to observables) to drive β to zero?" That is a coefficient *stability* / *bounded sensitivity* question.

Gelbach asks: "Among the observables we DO have, how much does each one contribute to the coefficient change?" That is a coefficient *attribution* / *decomposition* question.

These are complementary, not substitutable. Our paper now has both: Oster t10 (already built) and Gelbach (new).

### 6. Simpson-paradox interaction
Our base→full coefficient change is a *sign flip*, not a magnitude change. The Gelbach formula handles this fine (signs in the decomposition just flip accordingly), but the qualitative story is unusual. In the paper, present it carefully: "The sign flip is driven entirely by the contribution of language."

---

## Comparison to the strategist's plan

The strategist's handoff (`Brainstorm-Absinthe/.../2026-04-30_paper1_data_v2_handoff.md`) mentions Gelbach decomposition as already-implemented in `08_expansion_master.do` of the old repo. Per user instruction ("their code is sloppy vibe code, treat as rewrite from scratch"), we are NOT porting that implementation. We are building from the canonical `b1x2` package + hand-validating identity, per this reference document.

If/when the strategist wants to compare numbers across the two pipelines, the Gelbach point estimates from `b1x2` should match exactly between repos (the underlying data is the same). Differences in SEs may arise from `vce()` choices.

---

## References

- **Gelbach, Jonah B. (2016)**. "When Do Covariates Matter? And Which Ones, and How Much?" *Journal of Labor Economics* 34(2): 509-543. [Journals.uchicago.edu](https://www.journals.uchicago.edu/doi/abs/10.1086/683668) | [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1425737) | [Author preprint (UBC)](http://papers.economics.ubc.ca/legacypapers/gelbach.pdf)
- **`b1x2` Stata package** (Gelbach 2014). RePEc/Boston College Statistical Software Components: [s457814](https://ideas.repec.org/c/boc/bocode/s457814.html). Help file: [b1x2.sthlp](http://fmwww.bc.edu/repec/bocode/b/b1x2.sthlp).
- **MatthieuStigler/Misconometrics** GitHub — R reimplementation and Stata `.ado` mirror: [Gelbach_decompo](https://github.com/MatthieuStigler/Misconometrics/tree/master/Gelbach_decompo). Useful for cross-checking.
- **Oster (2019)** for contrast: "Unobservable Selection and Coefficient Stability." *JBES* 37(2). The other coefficient-sensitivity tool we use.

---

## Audit history

- 2026-04-30: First compiled. Sources: WebSearch + canonical b1x2 help file + Misconometrics GitHub. No Stata-PDF documentation exists for `b1x2` (it's a community package); hence this dedicated reference. Per project rule "If Stata doesn't document explicitly, deep search and save markdowns and links."
