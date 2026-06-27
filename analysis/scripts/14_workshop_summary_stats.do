/*==============================================================================
 14_workshop_summary_stats.do  —  Phase A''.7 rewrite (2026-05-22)

 Purpose:  Build T1 descriptive statistics via Stata 17+ `dtable` command
           (purpose-built for descriptive tables with by-groups; handles
           comma-formatting and clean tex export natively).  Replaces the
           prior esttab+estpost+manual approach which produced a 31-column
           table too wide to compile cleanly even in landscape.

 Input:    $MyProject/processed/cohort_1908_workshop.dta (canonical full)
 Output:   $WorkshopTables/T1_summary_stats.tex   (dtable export)
           $WorkshopTables/T1_canton_composition.tex (hand-built fragment,
                                                      unchanged from before)

 Author:   Phase A'' refactor
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

global WorkshopTables  "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"
cap mkdir "$WorkshopTables"


**# 1. Load workshop cohort
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  cohort_1908_workshop.dta missing.  Run 08+09_workshop first."
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear
    assert c(N) == 25

    * Variable labels (dtable escapes % to \% itself; use plain % in labels
    * to avoid double-escape \\%, which LaTeX interprets as line-break + comment)
    label var Y1                "Yes-vote, Vote 68"
    label var pct_yes_67        "Yes-vote, Vote 67"
    label var pct_yes_69        "Yes-vote, Vote 69"
    label var pet_per_eligible  "Petition signatures per 100 eligible"
    label var turnout_68        "Turnout, Vote 68"
    label var X1                "Wine area per 1,000 pop. (ha)"
    label var X2_share          "Wine volume share (%)"
    label var X3_share          "Wine revenue share (%)"
    label var cov1              "French language share (%)"
    label var cov3              "Protestant share (%)"
    label var cov2_total_share  "Absinthe trade share (%)"
    label var abs_producer      "Absinthe-producer indicator"
    label var ln_density        "Log population density"
    label var pop_1900          "Population (1900)"

    * Derive language-group factor for by-group display
    cap drop lang_group
    gen byte lang_group = 1
    replace lang_group = 2 if inlist(canton_iso, "FR","VD","NE","GE","VS","JU")
    replace lang_group = 3 if canton_iso == "TI"
    cap label drop lang_lbl
    label define lang_lbl 1 "German" 2 "French" 3 "Italian"
    label values lang_group lang_lbl
    label var lang_group "Language group"
}


**# 2. T1 summary stats — hand-built via texsave (portrait, parens-as-subrow)
*------------------------------------------------------------------------------*
* Structure (parallel to regression tables): each variable spans TWO rows.
*   Row 1 (mean):  varlabel | german_mean | french_mean | italian_mean
*   Row 2 (SD):    ""       | (sd)        | (sd)        | (sd)
* Italian N=1 → SD missing → render as "" (blank) rather than "(.)".
* Pop_1900 uses %15.0fc → comma-separated thousands ("126,008").
* Others use %9.2f.
{
    di as text _newline "  --- T1 summary stats: hand-build with mean / (SD) two-row format ---"

    local vars Y1 pct_yes_67 pct_yes_69 pet_per_eligible turnout_68 ///
               X1 X2_share X3_share ///
               cov1 cov3 cov2_total_share abs_producer ///
               ln_density pop_1900

    * Cache variable labels and compute stats BEFORE preserve/clear.
    local i 0
    foreach v of local vars {
        local ++i
        local lbl_`i' : variable label `v'
        forvalues g = 1/3 {
            qui sum `v' if lang_group == `g'
            local m_`i'_`g' = r(mean)
            local s_`i'_`g' = r(sd)
        }
    }
    local n_vars = `i'

    * Build the 2N-row dataset and emit via texsave.
    preserve
        clear
        local n_rows = `n_vars' * 2
        set obs `n_rows'
        gen str60 Variable = ""
        gen str20 German   = ""
        gen str20 French   = ""
        gen str20 Italian  = ""

        local row 0
        forvalues i = 1/`n_vars' {
            local v : word `i' of `vars'
            local lbl = "`lbl_`i''"
            local fmt = cond("`v'"=="pop_1900", "%15.0fc", "%9.2f")

            * Mean row
            local ++row
            qui replace Variable = "`lbl'" in `row'
            forvalues g = 1/3 {
                local m       = `m_`i'_`g''
                local m_str   = trim(string(`m', "`fmt'"))
                local col     = cond(`g'==1, "German", cond(`g'==2, "French", "Italian"))
                qui replace `col' = "`m_str'" in `row'
            }

            * SD row (in parens; blank for Italian — N=1)
            local ++row
            qui replace Variable = "" in `row'
            forvalues g = 1/3 {
                local s = `s_`i'_`g''
                if missing(`s') {
                    local s_paren = ""
                }
                else {
                    local s_str   = trim(string(`s', "`fmt'"))
                    local s_paren = "(`s_str')"
                }
                local col = cond(`g'==1, "German", cond(`g'==2, "French", "Italian"))
                qui replace `col' = "`s_paren'" in `row'
            }
        }

        label var Variable " "
        label var German   "German (N=19)"
        label var French   "French (N=5)"
        label var Italian  "Italian (N=1)"

        * NB: NO `nofix` here.  Labels use plain "%" (Wine volume share (%));
        * texsave auto-escapes to "\%" so LaTeX renders correctly.
        texsave Variable German French Italian ///
            using "$WorkshopTables/T1_summary_stats.tex", ///
            replace frag varlabels ///
            align(lrrr) ///
            title("Descriptive statistics: 1908 cohort (mean; SD in parentheses below)") ///
            label("tab:T1_summary") ///
            footnote("Mean and standard deviation (in parentheses below) by canton language group. French cantons = NE, GE, VD, FR, VS, JU. Italian = TI. German = remaining 19. Italian SDs omitted (N=1). Population in unrounded persons (1900).", size(footnotesize))
    restore

    di as text "  Wrote T1_summary_stats.tex (texsave; portrait; mean/SD two-row)"
}


**# 3. T1 canton industrial composition (hand-built; unchanged from prior version)
*------------------------------------------------------------------------------*
{
    cap drop wine_producer
    gen byte wine_producer = (X1_share > 0 & !missing(X1_share))

    cap drop category
    gen byte category = .
    replace category = 1 if wine_producer == 1 & abs_producer == 1
    replace category = 2 if wine_producer == 1 & abs_producer == 0
    replace category = 3 if wine_producer == 0 & abs_producer == 1
    replace category = 4 if wine_producer == 0 & abs_producer == 0
    cap label drop cat_lbl
    label define cat_lbl 1 "Wine AND absinthe" 2 "Wine only" 3 "Absinthe only" 4 "Neither"
    label values category cat_lbl

    cap file close fcomp
    file open fcomp using "$WorkshopTables/T1_canton_composition.tex", write replace
    file write fcomp "\begin{tabular}{lcl}" _n
    file write fcomp "\toprule" _n
    file write fcomp "Category & N & Cantons \\" _n
    file write fcomp "\midrule" _n
    forvalues c = 1/4 {
        local lbl : label cat_lbl `c'
        qui count if category == `c'
        local n = r(N)
        qui levelsof canton_iso if category == `c', local(cl) clean
        file write fcomp "`lbl' & `n' & `cl' \\" _n
    }
    file write fcomp "\midrule" _n
    file write fcomp "Total & 25 & \\" _n
    file write fcomp "\bottomrule" _n
    file write fcomp "\end{tabular}" _n
    file close fcomp

    di as text "  Wrote T1_canton_composition.tex (hand-built)"
}


**# 4. Post-credits
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
