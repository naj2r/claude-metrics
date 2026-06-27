# Robustness status — 1908 absinthe-ban canton cross-section (N=25)

**Last updated**: 2026-06-09 (canonical 10k RI landed)
**Purpose**: the durable, single-page inventory of every robustness / inference test for the paper — done, deferred, and TBD — with conclusions. Ground truth: the inference-battery scripts (`22`/`23`) + results memo (`quality_reports/coder_reports/2026-06-03_inference-battery-results.md`), the feasibility memo (`..._2026-06-09_feasibility-ipw-ebal-lewbel.md`), the strategy note, and CONTEXT.md.
**Mirrors to**: vault `Notes/methodology/robustness_status.md` (via `notes_sync.py`).

---

## BOTTOM LINE

The robust core is a **pattern**, not one p-value: competing-coalition (wine winners ↑ yes, absinthe losers ↓ yes) **+ stage-separation** (wine→vote, Protestants→petition) **+ cross-referendum falsification** (specific to vote #68). **Wine leg = real but fragile** (robust in sign/magnitude across every deletion; modest significance at N=25 — RI p≈0.05–0.09, BM p≈0.12). **Producer leg = not separately identified** (language-entangled; carried by the qualitative record + the raw differential). Lead on the pattern + the canton magnitude ladder, not a single wine p-value.

---

## I. Gate + small-N inference (wine leg) — scripts 22/23

| Test | Status | Conclusion |
|---|---|---|
| **Leave-one-out** (wine cascade c1–c5) | ✅ PASS | FL AME 0.434 full → 0.439 drop-NE → **0.493 drop-VD** (Vaud *strengthens* it); FL range [0.318, 0.650], OLS [0.350, 0.694] — never near 0. "Not just Vaud." |
| **Randomization inference, 10k** (`ritest`, seed 20260603) | ✅ **DONE (2026-06-09)** | Headline col-5 **RI p = 0.054 (OLS) / 0.087 (FL-AME)**. Simpson-flip col-2 sharpest (0.016 / 0.029). Co-headline X2 c5 = 0.101 / 0.128. Producer p1 raw = 0.023 / 0.027; p4 +French = 0.363 / 0.374. `T_ri` FINAL + deployed. |
| **HC1/HC2/HC3 + Bell-McCaffrey dof** | ✅ DONE | BM effective dof collapses to ~2–4 (not N−k=19) ⇒ col-5 **BM p = 0.119** (vs ~0.06 textbook). The honest fragility. Mata impl validated == native HC2 (<1e-6). |
| **Oster (2019) δ-bounds** (`psacalc`) | ✅ CORROBORATES | Controls move β *away* from 0 (Simpson flip) ⇒ δ-to-zero **negative** (−1.354 at rmax=1.3R²); β@δ=1 ≈ **0.818**. Zeroing-out is ill-posed → Oster supports, not threatens. |
| **White vs red wine** (Cahannes mechanism) | ⚠️ INCONCLUSIVE | Point estimates run red ≥ white (against Cahannes), both imprecise with overlapping CIs. The canton cross-section can't resolve it. Report honestly; don't over-read. |
| **Conley (1999) spatial-HAC** | ⛔ DEFERRED | Needs period-appropriate 1908 canton centroids (never fabricate) + `acreg` vendored. Decision log D2. |

**Three small-N instruments on the headline wine coef, kept distinct (never conflated):** design-based RI p ≈ **0.05–0.09**; Bell-McCaffrey dof-adjusted p ≈ **0.12**; naïve-normal ≈ 0.06. Report the set.

---

## II. Identification-strategy feasibility (producer leg + endogeneity) — 2026-06-09

| Method | Status | Conclusion |
|---|---|---|
| **IPW** (`teffects ipw`) | ⚠️ DOCUMENT-AS-LIMIT | Runs but max weight **196×**; ATT collapses to the raw −11.5 (no overlap to adjust on). |
| **Entropy balancing** (`ebalance`) | ⛔ NO-GO | Won't converge — treated French mean 0.51 outside control range [0.00, 0.17]. Religion+density-only −11.5 doesn't address language. |
| **Lewbel het-IV** (`ivreg2h`) | ✅ GO (exploratory) | coef 0.571 [0.27, 0.88], KP F 222, Hansen J p 0.13; **LOO-ROBUST** (coef [0.50, 0.74], F never <46, drop-NE 0.518/174, 0 sign flips). Corroborates wine via an overlap-free route. Caveat: untestable cov(Z, error-product)=0 → **appendix-grade**. Built: `T_lewbel_appendix.{tex,md}` (staged Overleaf) + ProjectBook sentence. |
| **Producer verdict (3 ways agree)** | — | Raw −11.2 pp is real descriptively but **can't be de-confounded from language**: OLS collinearity (SE ×1.31, corr 0.71) + ebal non-convergence + IPW degeneracy. "Lack of evidence, not evidence of lack." |

---

## III. Falsification / mechanism / decomposition (earlier record)

| Test | Status | Conclusion |
|---|---|---|
| **Cross-referendum placebo (T14b; RI 10k × 15 votes)** | ✅ PASSES | Wine→yes pattern specific to vote #68. Robust-core member. (`05_expansion.do` §10.14b.) |
| **Gelbach (2016) decomposition (T15)** | ✅ DONE | Simpson flip attributed to French (language) as dominant mediator (~99% of the flip). |
| **Petition vs vote stage-separation (12/13)** | ✅ DONE | Wine → vote; Protestants → petition. |
| **Structural break (Quandt-Andrews + Chow + Newey-West HAC; T27/F11)** | ✅ DONE | Substrate-ratio break ~1880s; HAC-robust. Background/mechanism, not headline robustness. |

---

## IV. Spec / estimator robustness (earlier record)

| Test | Status | Conclusion |
|---|---|---|
| **R1–R6 battery (T7 appendix)** | ✅ holds | Result stable across alt specs. |
| **FL vs OLS (T7)** | ✅ consistent | FL AME ≈ rescaled OLS β. |
| **Wine-measure horse-race + value-vs-volume (T10v)** | ✅ DONE | Revenue share (X3) headline; measures consistent. |
| **Language confound: binary N=20 vs continuous N=25 (t05)** | ✅ DONE | Same direction; continuous weighting preferred. |
| **Collinearity defense: Belsley condition number + PDS-LASSO** | ✅ DONE | Defends vs the "just collinearity / EEH" critique. |
| **drop-NE+GE / drop-Vaud subsamples** | ✅ subsumed | Now covered by the full LOO. |

---

## Out of scope (deliberate — strategy note §4)

District/commune disaggregation, canton-clustered SEs, wild-cluster bootstrap — treatment varies at the **canton** level, so these manufacture artificial within-canton variation; the district result was a null anyway.

---

## TBD / open

- ⛔ **Conley spatial-HAC** — blocked on period-appropriate 1908 canton coordinates + `acreg`.
- ◻️ **LOO coefficient-stability figure** (wine cascade) — optional; data ready, not built.
- ⏸️ **Lewbel appendix row + main-text sentence** — staged + ProjectBook draft; PI integrates when editorial unfreezes.
- 🔭 **Cross-referendum RI → R/parallel** — scoped (`analysis/documentation/plans/2026-06-09_cross-referendum-ri-parallel-scoping.md`); build when the battery is expanded to FL-AME-per-vote rigor (a ~2–10 h serial job → minutes on 28 cores). Not needed for the current OLS-t T14b.

---

## Canonical RI provenance (the 2026-06-09 run)

- Wrapper: `analysis/scripts/_inference_battery_run.do` (RUN_RI=1, 10,000 perms, seed 20260603, `set processors 1`); standalone `StataMP-64.exe /e` batch, ~80 min, exit 0. All asserts passed (paper-anchor 0.4338; producer-anchor −11.199; Mata HC2==native).
- Tables refreshed via `_run_23_tables.do` → `23`; `T_ri` FINAL gate fired; 6 tables deployed to Overleaf `Tables/Robustness_6-3-26/`.
- Outputs: `results/intermediate/inference_{loo,ri,se_bm,oster,winetype}.dta`; `results/tables/T_*.{tex,md}`.
- Methodology floor honored: 10,000 perms (never reduced); `set processors 1` is a pure speed knob (core count cannot change a seeded permutation distribution — verified: 1 core ran the FL-AME cells ~20% faster than 8 at N=25).
