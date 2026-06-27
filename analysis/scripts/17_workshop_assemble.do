/*==============================================================================
 17_workshop_assemble.do
 Purpose:  Assemble all per-table markdowns into one comprehensive master
           summary for the workshop draft.
 Input:    $MyProject/results/tables/_md/workshop/{per-table .md files}
 Output:   $MyProject/results/tables/_md/workshop/canton_workshop_summary.md
 Author:   workshop-dispatch coder (2026-05-21)
 Date:     2026-05-21
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

global WorkshopFigures "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Figures"


* ----- Helper: include one per-table MD file -----
* Reads `infile' line by line and writes contents to fout.
* Defined at TOP LEVEL (outside any brace block) so it's registered before
* the assembly block runs.  Stata can define programs inside `{ ... }`, but
* the buffer-and-execute-at-close behavior of brace blocks combined with the
* program definition has caused silent failures in this layout (file just
* not appearing without an error rc).  Pulling the program out fixes it.
cap program drop _include_md
program define _include_md
    args fhout infile
    cap confirm file "`infile'"
    if _rc {
        file write `fhout' "*(missing: `infile' — re-run the producing script)*" _n _n
        exit
    }
    tempname fin
    file open `fin' using "`infile'", read
    file read `fin' line
    while r(eof) == 0 {
        file write `fhout' `"`macval(line)'"' _n
        file read `fin' line
    }
    file close `fin'
    file write `fhout' _n
end


**# 1. Assemble master MD
*------------------------------------------------------------------------------*
{
    local outpath "$MyProject/results/tables/_md/workshop/canton_workshop_summary.md"
    local indir   "$MyProject/results/tables/_md/workshop"

    cap mkdir "$MyProject/results/tables/_md/workshop"

    cap file close fout
    file open fout using "`outpath'", write replace

    file write fout "# Canton workshop draft — comprehensive summary" _n _n
    file write fout "**Generated:** 2026-05-21 (workshop draft pipeline; density-swap col 5; N=25 cantons)" _n
    file write fout "**Order:** As tables/figures appear in Paper 1 draft 1." _n
    file write fout "**Scale convention:** All share-form vars on percent (0–100); log-scale vars on natural log; raw-quantity vars unchanged." _n _n
    file write fout "---" _n _n

    * ----- HEADLINE CALLOUT BOX (workshop substantive summary) -----
    file write fout "## ★ HEADLINE FINDINGS (workshop) ★" _n _n
    file write fout "**SCALE CONVENTION**: All coefficients reported below are on **pp Y per pp X** scale (where Y = Yes-vote share in percent, X = regressor in percent).  OLS β values are natively on this scale.  Fractional logit AMEs are rescaled (raw AME on fractional Y × 100) for direct comparability with OLS.  See per-table footnotes for confirmation." _n _n
    file write fout "**1. Cross-referendum falsification holds (Table 8 FL AME, pp scale):**" _n
    file write fout "Same voters, same ballot day (5 July 1908), three different questions:" _n _n
    file write fout "- Vote #67 (commerce):     AME = −0.20 pp, p = 0.523 — *placebo passes, null*" _n
    file write fout "- **Vote #68 (absinthe ban): AME = +0.43 pp, p = 0.026 ★ — headline holds at 5%**" _n
    file write fout "- Vote #69 (water power):  AME ≈  0.00 pp, p = 0.983 — *placebo passes, ≈ zero*" _n _n
    file write fout "Reading: a 1 pp ↑ in canton's national wine-revenue share predicts a 0.43 pp ↑ in Vote #68 yes-share.  Only #68 shows the effect.  Same electorate, same day, two clean nulls." _n _n
    file write fout "**2. Wine-type Simpson reveal (Table 9 Panel B):**" _n
    file write fout "WHITE wine cascade shows a Simpson sign-flip between col 1 (bivariate β = −0.256 pp/pp, marginally significant) and col 2 (+French, β = +0.419 pp/pp).  RED wine has no Simpson — bivariate already positive (+0.43 pp/pp).  The Cahannes substitution mechanism appears as a SIGN-FLIP PATTERN under cultural-confound conditioning, not as a magnitude difference at col 5." _n _n
    file write fout "**3. Volume re-test of Cahannes (Table 10v + T10v_margins, pp scale):**" _n
    file write fout "Phase 10b correction: replace value-share (Vaud premium prices ~55 CHF/hL skewed value) with VOLUME-share (canton white volume / national white volume).  FL AME of white-wine VOLUME share on Y at cov1=50: +0.91 pp/pp (p = 0.029 ★).  FL AME of white-wine VALUE share at same point: +1.01 pp/pp (p = 0.079 †, only marginal).  Volume measure lifts the main effect from marginal to significant.  Interaction β(white × French) stays null (p > 0.6) in BOTH measures — no cultural conditioning of the slope; the LEVEL effect is robust positive under the cleaner volume measure." _n _n
    file write fout "**4. Drop-Ticino robustness (Table 11):**" _n
    file write fout "Removing Ticino (only Italian canton, 100% red wine, high yes-vote for cultural reasons) does NOT collapse the red-wine cascade — it doubles it (col 5 β: +0.39 → +0.83 pp/pp).  Aggregate + white cascades essentially unchanged.  The wine-industry signal is general, not Italian-driven." _n _n
    file write fout "**5. Cultural cleavage descriptive (T_desc):**" _n
    file write fout "FR-canton mean Yes #68 = 50.7%; DE-canton mean = 67.6% (level percentages; no pp/pp conversion needed for descriptive means).  French cantons are simultaneously the wine producers AND the lowest yes-voters.  Within-FR variation (VS/VD high white, high yes) deviates UPWARD from FR baseline — the cantonal-level analog of the Simpson reveal." _n _n
    file write fout "---" _n _n

    * ----- Table 1 — Summary statistics -----
    file write fout "## Table 1 — Descriptive statistics" _n _n
    _include_md fout "`indir'/T1_summary_stats.md"
    file write fout _n "### Canton industrial composition (sub-table)" _n _n
    _include_md fout "`indir'/T1_canton_composition.md"
    file write fout "---" _n _n

    * ----- Table 2 — Vote cascade -----
    file write fout "## Table 2 — Vote regression cascade" _n _n
    file write fout "### Panel A: Wine revenue share (X3) — OLS" _n _n
    _include_md fout "`indir'/T2_vote_cascade_X3_OLS.md"
    file write fout _n "### Panel A: Wine revenue share (X3) — Fractional logit AME" _n _n
    _include_md fout "`indir'/T2_vote_cascade_X3_FL.md"
    file write fout _n "### Panel B: Wine volume share (X2) — OLS" _n _n
    _include_md fout "`indir'/T2_vote_cascade_X2_OLS.md"
    file write fout _n "### Panel B: Wine volume share (X2) — Fractional logit AME" _n _n
    _include_md fout "`indir'/T2_vote_cascade_X2_FL.md"
    file write fout "---" _n _n

    * ----- Table 3 — Vote horse race at col 5 -----
    file write fout "## Table 3 — Vote horse race at col 5 (X1, X2_share, X3_share)" _n _n
    file write fout "### OLS HC3" _n _n
    _include_md fout "`indir'/T3_vote_horserace_OLS.md"
    file write fout _n "### Fractional logit AME" _n _n
    _include_md fout "`indir'/T3_vote_horserace_FL.md"
    file write fout "---" _n _n

    * ----- Table 4 — Petition cascade -----
    file write fout "## Table 4 — Petition regression cascade (Y = pet_per_eligible)" _n _n
    file write fout "### Panel A: Wine revenue share (X3) — OLS" _n _n
    _include_md fout "`indir'/T4_petition_cascade_X3_OLS.md"
    file write fout _n "### Panel B: Wine volume share (X2) — OLS" _n _n
    _include_md fout "`indir'/T4_petition_cascade_X2_OLS.md"
    file write fout "---" _n _n

    * ----- Table 5 — R4 mechanism -----
    file write fout "## Table 5 — R4 mechanism interaction (French × Absinthe-producer)" _n _n
    file write fout "### Panel A: Wine volume share (X2)" _n _n
    _include_md fout "`indir'/T5_R4_mechanism_X2.md"
    file write fout _n "### Panel B: Wine revenue share (X3)" _n _n
    _include_md fout "`indir'/T5_R4_mechanism_X3.md"
    file write fout _n "### Conditional means (vs. German non-producer baseline)" _n _n
    _include_md fout "`indir'/T5_R4_conditional_means.md"
    file write fout "---" _n _n

    * ----- Table 6 — Turnout gap collapse -----
    file write fout "## Table 6 — French-German turnout gap collapse" _n _n
    _include_md fout "`indir'/T6_turnout_gap_collapse.md"
    file write fout "---" _n _n

    * ----- Figure 1 -----
    file write fout "## Figure 1 — Petition rate vs Protestant share" _n _n
    file write fout "![F1](" "$WorkshopFigures" "/F1_petition_protestant.png)" _n _n
    file write fout "Monochrome scatter of canton-level petition signatures per 100 eligible voters" _n
    file write fout "against Protestant share of the Christian population.  Markers by language group" _n
    file write fout "(German = open circle; French = filled square; Italian = filled triangle).  Solid" _n
    file write fout "line = OLS fit.  Source: cohort_1908_workshop.dta." _n _n
    file write fout "---" _n _n

    * ----- Figure 2 -----
    file write fout "## Figure 2 — Vote and petition rates by canton (grouped bars)" _n _n
    file write fout "![F2](" "$WorkshopFigures" "/F2_canton_bars.png)" _n _n
    file write fout "Side-by-side bars per canton: gray = Vote #68 yes-share (%); black = petition" _n
    file write fout "signatures per 100 eligible voters (%).  Cantons grouped by language cluster" _n
    file write fout "(German | French | Italian).  Source: cohort_1908_workshop.dta." _n _n
    file write fout "---" _n _n

    * ----- Table 7 (appendix) -----
    file write fout "## Table 7 (Appendix) — Consolidated robustness" _n _n
    file write fout "Two appendix files in `Workshop_draft/`:" _n
    file write fout "- **`T7_appendix_canton_robustness_r1_r6.tex`** — direct copy of non-workshop R1-R6 (OLS only; scale-uniform, no rescale needed).  Uses non-workshop col-5 controls (cov_land + ln_pop_1900)." _n
    file write fout "- **`T7_appendix_fraclogit_vs_ols.tex`** — **REBUILT** for Phase A' scale-consistency.  Uses workshop col-5 controls (ln_density) AND FL AMEs rescaled to pp Y per pp X for direct comparability with OLS HC3 columns." _n _n
    file write fout "The non-workshop summary `_md/robust/canton_robustness_summary.md` (existing baseline) uses cov_land + ln_pop_1900 controls AND has mixed-scale FL AMEs (fractional Y) — DO NOT cite from there for workshop or EEH purposes.  Use the rebuilt T7_appendix_fraclogit_vs_ols.tex instead." _n _n
    file write fout "---" _n _n

    * ----- Table 8 — Cross-referendum -----
    file write fout "## Table 8 — Cross-referendum #67 / #68 / #69 (falsification)" _n _n
    file write fout "**Headline result — read FL AME panel below.**  OLS panel is for reference (small-sample HC3 SEs at N=25 are conservative; FL is the appropriate model for the bounded outcome and tightens the absinthe-ban result to p=0.026 at the 5% threshold)." _n _n
    file write fout "### Fractional logit AME (HEADLINE)" _n _n
    _include_md fout "`indir'/T8_cross_referendum_FL.md"
    file write fout _n "### OLS HC3 (for reference)" _n _n
    _include_md fout "`indir'/T8_cross_referendum_OLS.md"
    file write fout "---" _n _n

    * ----- T_desc — Cultural-cleavage descriptive (sets up wine-type discussion) -----
    file write fout "## Cultural-cleavage descriptive table (T_desc) — wine cantons only (N=20)" _n _n
    file write fout "Sort: language group (FR → IT → DE), then Yes #68 descending within group." _n
    file write fout "Carries the substantive cultural-cleavage story without leaning on interactions at N=25." _n _n
    _include_md fout "`indir'/t_desc_wine_cantons_cleavage.md"
    file write fout "---" _n _n

    * ----- Table 9 — Wine-type cascade (3 panels) -----
    file write fout "## Table 9 — Wine-type cascade decomposition (3 panels: Aggregate / White / Red)" _n _n
    file write fout "All three panels: OLS HC3, N=25, Y = Yes-vote share Vote #68 (absinthe ban)." _n
    file write fout "**Key pattern**: WHITE shows Simpson sign-flip col 1 → col 2 (−0.256* → +0.419*); RED does not (already positive bivariate)." _n _n
    file write fout "### Panel A: Aggregate wine cascade" _n _n
    _include_md fout "`indir'/T9_winetype_cascade_A_agg.md"
    file write fout _n "### Panel B: WHITE wine cascade  (Simpson sign-flip)" _n _n
    _include_md fout "`indir'/T9_winetype_cascade_B_white.md"
    file write fout _n "### Panel C: RED wine cascade  (no Simpson; stable positive)" _n _n
    _include_md fout "`indir'/T9_winetype_cascade_C_red.md"
    file write fout "---" _n _n

    * ----- Table 10v — Volume re-test of Cahannes -----
    file write fout "## Table 10v — Cahannes substitution channel: VOLUME-share re-test (Phase 10b)" _n _n
    file write fout "**Motivation.**  X3_white_share uses CHF revenue.  Price/yield heterogeneity (premium Vaud whites at ~55 CHF/hL vs. bulk Ticino reds at ~23 CHF/hL) loads onto value-share." _n
    file write fout "If Cahannes's substitution channel runs through VOLUME (what consumers drink, what growers plant)—not revenue—then value-share is mis-specified." _n
    file write fout "Volume-share = canton's white VOLUME / national white VOLUME (parallel to value-share form)." _n _n
    file write fout "### Side-by-side: D1/D2 (value) vs D1v/D2v (volume)" _n _n
    _include_md fout "`indir'/T10v_white_french_value_vs_volume.md"
    file write fout _n "### FL AME marginal effects (the headline panel)" _n _n
    _include_md fout "`indir'/T10v_margins.md"
    file write fout _n "**Result.**  Volume measure lifts white-wine main effect from p≈0.08 (value, marginal) to **p≈0.03 (volume, significant at 5%)** at all moderator values." _n
    file write fout "Interaction β(white × French) stays NULL (p>0.6) — no cultural conditioning of the slope.  The Cahannes substitution mechanism is supported by the MAIN EFFECT under the correct (volume) measure, not by cultural conditioning." _n _n
    file write fout "---" _n _n

    * ----- Table 11 — Drop-Ticino robustness -----
    file write fout "## Table 11 — Drop-Ticino cascade robustness (Phase 10 Spec F)" _n _n
    file write fout "Ticino is the only Italian-speaking canton in the cohort and the dominant red-wine producer (100% red, 27% of national red value)." _n
    file write fout "TI voted YES at 68.4% for Catholic-Italian cultural reasons unconnected to wine-industry rent-seeking." _n
    file write fout "Re-running the wine-type cascade with TI excluded tests the substantive interpretation of the red-wine result." _n _n
    file write fout "**Result.**  Aggregate and WHITE cascades essentially unchanged.  RED cascade STRENGTHENS (col 5 β: +0.39 → +0.83).  The wine-industry signal is general and is NOT Ticino-driven; if anything TI was suppressing the red-wine effect via its cultural-channel confound." _n _n
    file write fout "### Panel A: Aggregate wine, drop TI (N=24)" _n _n
    _include_md fout "`indir'/T11_drop_ti_A_agg.md"
    file write fout _n "### Panel B: WHITE wine, drop TI (N=24)" _n _n
    _include_md fout "`indir'/T11_drop_ti_B_white.md"
    file write fout _n "### Panel C: RED wine, drop TI (N=24)" _n _n
    _include_md fout "`indir'/T11_drop_ti_C_red.md"
    file write fout "---" _n _n

    * ----- Cahannes (1981) methodology + citation -----
    * NOTE: lines with embedded double-quotes use Stata compound quotes `"..."'
    * to allow literal " inside the string (Stata can't escape " with \").
    file write fout "## Cahannes (1981) — historiographic anchor for the white-wine substitution test" _n _n
    file write fout `"**Citation.**  Cahannes, Monique. 1981. "Swiss alcohol policy: the emergence of a compromise." *Contemporary Drug Problems* 8(2): 167-186."' _n _n
    file write fout "**Direct substitution claim** (p. ~5 in PDF; pp. 394-405 of source):" _n
    file write fout `"> *"absinthe, particularly popular in the French part of the country, competed with white wine, and the initiative was therefore supported by the winegrowers."*"' _n _n
    file write fout "**Empirical test status (this paper):**" _n
    file write fout "- White-wine main effect on Vote #68: positive and significant at p≈0.03 under volume measure (Table 10v) ✓ consistent with Cahannes substitution channel" _n
    file write fout "- White × French cultural conditioning: null (p > 0.6 in both D1v and D2v) ✗ no slope conditioning detected" _n
    file write fout "- Simpson sign-flip for WHITE in cascade (Table 9 Panel B) ✓ consistent with Cahannes story masked by cultural confound" _n
    file write fout "- Red wine effect: comparable magnitude to white at col 5 (Table 9 Panel C); strengthens without Ticino (Table 11 Panel C)" _n _n
    file write fout "**Other Cahannes (1981) anchors for workshop narrative:**" _n
    file write fout "- *Federal government OPPOSED the initiative* (preferred taxation for fiscal reasons) — citizen-coalition victory against federal-elite preference; supports Peltzman / B&B framing." _n
    file write fout `"- *Temperance societies originated in viticultural regions* — Protestant Awakening Movement ("Mouvement du Réveil") required abstinence from spirits but allowed moderate wine.  Wine industry and temperance had ALIGNED interests by design — the B&B coalition was institutionalized at the membership level."' _n
    file write fout "- *Class-coded beverage consumption*: spirits = working class, wine = upper/middle class.  Banning the former while protecting the latter reflects social-class interests." _n
    file write fout "- *Geographic concentration*: 4/5 of viticultural land is in French- and Italian-speaking parts; 3/4 in French-speaking alone.  This is WHY X3_white_share is highly correlated with cov1 (r = 0.638) and the cascade decomposition matters." _n
    file write fout "- *Constitutional context*: 8 of 187 federal amendments 1874-1978 concerned alcohol production/sale — recurring federal issue.  Auguste Forel (1848-1931) is the recognized Swiss anti-alcohol psychiatrist anchoring the Protestant-temperance movement." _n _n
    file write fout "---" _n _n

    * ----- Footer -----
    file write fout "## Notes on this assembly" _n _n
    file write fout "- All workshop regressions use the **density-swap col 5** (`ln_density = ln_pop_1900 - cov_land`)" _n
    file write fout "  replacing the original 09's two-var formulation (`cov_land + ln_pop_1900`)." _n
    file write fout "- All N = 25 cantons throughout the workshop tables." _n
    file write fout "- HC3 robust SEs for OLS; vce(robust) for fracreg AMEs." _n
    file write fout "- Workshop estimates live in `estimates_workshop/`, `estimates_fraclogit_workshop/`," _n
    file write fout "  `estimates_robust_workshop/`, `estimates_petition_workshop/`, `estimates_crossref/`." _n
    file write fout "- Workshop cohort source of truth: `processed/cohort_1908_workshop.dta`." _n
    file write fout "- Workshop replication subset: `processed/cohort_1908_workshop_replication.dta`" _n
    file write fout "  (built by `18_workshop_replication_strip.do` via editable KEEP_LIST)." _n _n

    file close fout
    di as text "  Wrote master MD: `outpath'"
}


**# 2. Post-credits
*------------------------------------------------------------------------------*
{
    if "${RUN_POSTCREDITS}" == "1" {
        di as text "  (inventory append: post-credits structure ready)"
    }
    else {
        di as text "  (inventory append skipped: \$RUN_POSTCREDITS != 1)"
    }
}

** EOF
