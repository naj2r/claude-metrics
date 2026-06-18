/*==============================================================================
 _section_2_1_anchor_stats.do  —  Descriptive statistics for §2.1 paragraph
                                  anchoring (2026-05-22 dispatch).

 Output: analysis/results/descriptive/2026-05-22_section_2_1_anchor_stats.md

 Strictly descriptive; no new regressions.  Uses existing cohort_1908_workshop.dta.

 Author: §2.1 dispatch executor (2026-05-22)
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}

local OUT "$MyProject/results/descriptive/2026-05-22_section_2_1_anchor_stats.md"

use "$MyProject/processed/cohort_1908_workshop.dta", clear
assert c(N) == 25


**# 0. Derive grouping variables needed across sections
*------------------------------------------------------------------------------*

* Wine canton: X3_share > 0 (= 20 cantons; 5 alpine non-producers UR/OW/NW/ZG/AI excluded)
cap drop wine_canton
gen byte wine_canton = (X3_share > 0 & !missing(X3_share))

* Language groups: FR if cov1 >= 50; IT for Ticino; DE otherwise
cap drop lang_str
gen str3 lang_str = "DE"
replace lang_str = "FR" if cov1 >= 50 & !missing(cov1)
replace lang_str = "IT" if canton_iso == "TI"

cap drop french_majority
gen byte french_majority = (lang_str == "FR")

cap drop german_majority
gen byte german_majority = (lang_str == "DE")

* Religion: Protestant-majority = cov3 >= 50; Catholic-majority = otherwise
cap drop prot_majority
gen byte prot_majority = (cov3 >= 50 & !missing(cov3))

cap drop cath_majority
gen byte cath_majority = (cov3 < 50 & !missing(cov3))

* Prior cantonal absinthe ban: VD (1907) and GE (1907)
cap drop prior_ban
gen byte prior_ban = inlist(canton_iso, "VD", "GE")

* Use Y1 as our pct_yes_68 alias for clarity in this script
cap drop pct_yes_68
gen pct_yes_68 = Y1


**# 1. Open output markdown file
*------------------------------------------------------------------------------*

cap file close f1
file open f1 using "`OUT'", write replace

file write f1 "# Section 2.1 Anchor Statistics — Descriptive Evidence for Closing Paragraph" _n _n
file write f1 "**Source:** processed/cohort_1908_workshop.dta (N=25 cantons, vote #68 = 5 July 1908)" _n
file write f1 "**Generated:** 2026-05-22 by `_section_2_1_anchor_stats.do`" _n
file write f1 "**Scope:** Strictly descriptive (no regressions). All percentages 1 decimal place; correlations 3 decimal places." _n _n
file write f1 "---" _n _n


**# 2. SECTION 1 — Canton-level vote #68 yes-shares for rhetorical-question cantons
*------------------------------------------------------------------------------*
file write f1 "## 1. Vote #68 yes-shares for §2.1 named cantons" _n _n

* National benchmark (mean weighted by pop? Or just simple canton-level mean? Use both.)
qui sum pct_yes_68
local nat_mean : di %5.1f r(mean)
qui sum pct_yes_68 [aw=pop_1900]
local nat_mean_wt : di %5.1f r(mean)

file write f1 "| Canton | Yes #68 (%) |" _n
file write f1 "|--------|------------:|" _n

foreach c in VD GE NE VS FR TI {
    qui sum pct_yes_68 if canton_iso == "`c'"
    local val : di %5.1f r(mean)
    file write f1 "| `c' | `val' |" _n
}

file write f1 "| **National (simple mean of cantons)** | **`nat_mean'** |" _n
file write f1 "| **National (population-weighted)**    | **`nat_mean_wt'** |" _n _n

file write f1 "*Note: 'National' here is the cohort-aggregate over 25 cantons. The 63.5% benchmark from federal totals is the actual referendum result; the simple-mean and pop-weighted values above differ because they treat cantons as units rather than voters.*" _n _n


**# 3. SECTION 2 — Group-mean comparisons (vote #68 yes-share)
*------------------------------------------------------------------------------*
file write f1 "## 2. Group-mean comparisons — yes #68 by group" _n _n
file write f1 "Format: each grouping splits the 25 cantons into two groups; reports mean(SD), N, and simple difference (group1 minus group0)." _n _n

file write f1 "| Grouping | Group 1 (mean / SD / N) | Group 0 (mean / SD / N) | Diff (G1 - G0) pp |" _n
file write f1 "|----------|--------------------------|--------------------------|------------------:|" _n

* Helper: ad-hoc inline computation for each grouping
* Wine cantons vs non-wine
foreach grouping in "Wine cantons (X3_share>0) vs non-wine" {
    qui sum pct_yes_68 if wine_canton == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pct_yes_68 if wine_canton == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

* Absinthe producer vs non-producer
foreach grouping in "Absinthe-producer (abs_producer==1) vs non-producer" {
    qui sum pct_yes_68 if abs_producer == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pct_yes_68 if abs_producer == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

* French majority vs German majority (excluding TI)
foreach grouping in "French-majority (cov1>=50) vs German-majority (cov1<50, excl TI)" {
    qui sum pct_yes_68 if french_majority == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pct_yes_68 if german_majority == 1
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

* Protestant majority vs Catholic majority
foreach grouping in "Protestant-majority (cov3>=50) vs Catholic-majority (cov3<50)" {
    qui sum pct_yes_68 if prot_majority == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pct_yes_68 if cath_majority == 1
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

* Prior-ban cantons (VD, GE) vs no-prior-ban
foreach grouping in "Prior-cantonal-ban (VD, GE) vs no-prior-ban" {
    qui sum pct_yes_68 if prior_ban == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pct_yes_68 if prior_ban == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

file write f1 _n


**# 4. SECTION 3 — Petition rate descriptive stats (stage-separation)
*------------------------------------------------------------------------------*
file write f1 "## 3. Petition rate by group (stage-separation evidence)" _n _n
file write f1 "Mean petition signatures per 100 eligible voters (pet_per_eligible) by the same groupings as §2 above. Side-by-side with the vote-stage means lets the reader see whether the petition stage loads differently on Protestant share / wine production than the vote stage does." _n _n

qui sum pet_per_eligible
local nat_pet : di %5.1f r(mean)

file write f1 "**National mean petition rate (simple mean over 25 cantons):** `nat_pet' per 100 eligible." _n _n

file write f1 "| Grouping | Group 1 (mean / SD / N) | Group 0 (mean / SD / N) | Diff (G1 - G0) |" _n
file write f1 "|----------|--------------------------|--------------------------|---------------:|" _n

foreach grouping in "Wine cantons vs non-wine" {
    qui sum pet_per_eligible if wine_canton == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pet_per_eligible if wine_canton == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

foreach grouping in "Absinthe-producer vs non-producer" {
    qui sum pet_per_eligible if abs_producer == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pet_per_eligible if abs_producer == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

foreach grouping in "French-majority vs German-majority (excl TI)" {
    qui sum pet_per_eligible if french_majority == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pet_per_eligible if german_majority == 1
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

foreach grouping in "Protestant-majority vs Catholic-majority" {
    qui sum pet_per_eligible if prot_majority == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pet_per_eligible if cath_majority == 1
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

foreach grouping in "Prior-cantonal-ban vs no-prior-ban" {
    qui sum pet_per_eligible if prior_ban == 1
    local m1 : di %5.1f r(mean)
    local s1 : di %5.1f r(sd)
    local n1 = r(N)
    qui sum pet_per_eligible if prior_ban == 0
    local m0 : di %5.1f r(mean)
    local s0 : di %5.1f r(sd)
    local n0 = r(N)
    local d : di %5.1f `m1' - `m0'
    file write f1 "| `grouping' | `m1' (`s1') / N=`n1' | `m0' (`s0') / N=`n0' | `d' |" _n
}

file write f1 _n
file write f1 "*Substantive read: compare the row-by-row differences in §3 (petition stage) vs §2 (vote stage).  Where the gap shrinks/flips between the two stages, the cleavage shifted between petition organization and voter participation.*" _n _n


**# 5. SECTION 4 — Bivariate vs partial correlations (Simpson's paradox anchor)
*------------------------------------------------------------------------------*
file write f1 "## 4. Bivariate vs partial correlations (Simpson's-paradox anchor)" _n _n

* corr(X1, pct_yes_68) raw bivariate
qui corr X1 pct_yes_68
local c1 : di %6.3f r(rho)

* Partial corr X1 with pct_yes_68 controlling for cov1
qui pcorr pct_yes_68 X1 cov1
local p1 : di %6.3f r(p_corr)[1,1]

* corr(pet_per_eligible, X1)
qui corr pet_per_eligible X1
local c2 : di %6.3f r(rho)

* corr(pet_per_eligible, cov3)
qui corr pet_per_eligible cov3
local c3 : di %6.3f r(rho)

file write f1 "| Correlation | Value |" _n
file write f1 "|-------------|------:|" _n
file write f1 "| corr(vineyard_per_cap X1, pct_yes_68) — raw bivariate | `c1' |" _n
file write f1 "| partial corr(X1, pct_yes_68 \| cov1) — controlling French share | `p1' |" _n
file write f1 "| corr(pet_per_eligible, X1) — petition vs vineyard area | `c2' |" _n
file write f1 "| corr(pet_per_eligible, cov3) — petition vs Protestant share | `c3' |" _n _n

file write f1 "*Substantive read: the first two rows are the Simpson's-paradox kernel — raw correlation between vineyard area and yes-#68 vs the partial correlation after netting out French language share.  Sign and magnitude shift is the §2.1 quantitative anchor.*" _n _n


**# 6. SECTION 5 — Within-Romandie 5-canton comparison table
*------------------------------------------------------------------------------*
file write f1 "## 5. Within-Romandie comparison (5 French-majority cantons)" _n _n
file write f1 "Within the same language bloc, the vote pattern is heterogeneous in ways that track producer-side configuration rather than language." _n _n

file write f1 "| Canton | Yes #68 (%) | Petition rate | X1 (wine per 1k pop) | Abs producer | Abs industry share (%) | Prior ban | Protestant share (%) |" _n
file write f1 "|--------|------------:|--------------:|---------------------:|:------------:|-----------------------:|:---------:|---------------------:|" _n

* Loop in canonical Romandie order (VD GE NE VS FR), then JU if it exists in cohort
foreach c in VD GE NE VS FR JU {
    qui count if canton_iso == "`c'"
    if r(N) == 0 continue

    qui sum pct_yes_68 if canton_iso == "`c'"
    local y68 : di %5.1f r(mean)
    qui sum pet_per_eligible if canton_iso == "`c'"
    local pet : di %5.1f r(mean)
    qui sum X1 if canton_iso == "`c'"
    local x1 : di %5.1f r(mean)
    qui sum abs_producer if canton_iso == "`c'"
    local ap = cond(r(mean) == 1, "Y", "N")
    qui sum cov2_total_share if canton_iso == "`c'"
    local apshare : di %5.1f r(mean)
    qui sum prior_ban if canton_iso == "`c'"
    local pb = cond(r(mean) == 1, "Y", "N")
    qui sum cov3 if canton_iso == "`c'"
    local cov3v : di %5.1f r(mean)

    file write f1 "| `c' | `y68' | `pet' | `x1' | `ap' | `apshare' | `pb' | `cov3v' |" _n
}

file write f1 _n


**# 7. SECTION 6 — Heimberg empirical test (within-French-bloc comparisons)
*------------------------------------------------------------------------------*
file write f1 "## 6. Heimberg empirical test (within-French bloc)" _n _n
file write f1 "Heimberg ('no major economic interests at stake') reads imply that, within a single language bloc, wine cantons and absinthe-producer cantons should NOT differ from non-wine and non-producer cantons.  Within the 5-6 French-majority cantons, check both differences." _n _n

* Within French bloc: wine vs non-wine (all French cantons are wine cantons in this cohort — 5 of 5)
file write f1 "**(a) Within French bloc — wine cantons vs non-wine cantons:**" _n _n
qui sum pct_yes_68 if french_majority == 1 & wine_canton == 1
local m1 : di %5.1f r(mean)
local n1 = r(N)
qui sum pct_yes_68 if french_majority == 1 & wine_canton == 0
local m0 : di %5.1f r(mean)
local n0 = r(N)
file write f1 "- Wine cantons within French bloc: mean yes-#68 = `m1' (N=`n1')" _n
file write f1 "- Non-wine cantons within French bloc: mean yes-#68 = `m0' (N=`n0')" _n
if `n0' == 0 {
    file write f1 "- *Note: all French-bloc cantons in cohort are wine-producing; this within-French wine/non-wine split is degenerate.  Falsification reads on the language/wine confound rather than within-French wine variation.*" _n
}
else {
    local d : di %5.1f `m1' - `m0'
    file write f1 "- Difference: `d' pp" _n
}
file write f1 _n

* Within French bloc: absinthe producer vs non-producer
file write f1 "**(b) Within French bloc — absinthe producer vs non-producer:**" _n _n
qui sum pct_yes_68 if french_majority == 1 & abs_producer == 1
local m1 : di %5.1f r(mean)
local n1 = r(N)
qui sum pct_yes_68 if french_majority == 1 & abs_producer == 0
local m0 : di %5.1f r(mean)
local n0 = r(N)
local d : di %5.1f `m1' - `m0'
file write f1 "- Absinthe-producer cantons within French bloc: mean yes-#68 = `m1' (N=`n1')" _n
file write f1 "- Non-producer cantons within French bloc: mean yes-#68 = `m0' (N=`n0')" _n
file write f1 "- Difference: `d' pp" _n _n

file write f1 "*Substantive read: if |difference| > 5 pp, Heimberg's 'no major economic interests at stake' claim is empirically contradicted within the very language bloc he discusses.*" _n _n


**# 8. SECTION 7 — T25 turnout-gap reference (already computed)
*------------------------------------------------------------------------------*
file write f1 "## 7. T25 French-German turnout-gap collapse (reference; from T6_turnout_gap_collapse.tex)" _n _n
file write f1 "From the existing T25/T6 table (Phase C.6c output):" _n _n
file write f1 "| Stat | French (N=5) | German (N=20) | Gap (Fr - Ge) |" _n
file write f1 "|------|-------------:|--------------:|--------------:|" _n
file write f1 "| Baseline turnout (median across 14 placebo votes 1907-1910) | 44.40 | 56.62 | -12.22 |" _n
file write f1 "| Vote #68 turnout (5 July 1908, absinthe ban) | 47.92 | 48.02 | -0.11 |" _n
file write f1 "| Change (gap collapse) | +3.52 | -8.60 | +12.12 |" _n _n
file write f1 "*Substantive read: the French-German turnout gap, normally -12 pp, collapses to ~0 on vote #68.  +12.12 pp swing in the gap is the empirical signature of the language cleavage activating on this specific vote.*" _n _n


**# 9. Close + verify
*------------------------------------------------------------------------------*
file write f1 "---" _n _n
file write f1 "**Generated:** `c(current_date)' `c(current_time)' by `_section_2_1_anchor_stats.do`" _n
file close f1

di as text _newline "  Wrote: `OUT'"

** EOF
