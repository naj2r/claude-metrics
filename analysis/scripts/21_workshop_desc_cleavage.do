/*==============================================================================
 21_workshop_desc_cleavage.do
 Purpose:  Build T_desc (descriptive cultural-cleavage table) for the workshop
           main paper.  Restricted to the 20 wine cantons; columns include
           language group, absinthe-producer flag, red/white shares, wine
           intensity, and yes-vote shares for votes #67/#68/#69.  Sorted by
           language group (FR -> IT -> DE), then Y1 descending within group.
           Footer reports group means.
 Input:    $MyProject/processed/cohort_1908_workshop.dta
 Output:   $WorkshopTables/t_desc_wine_cantons_cleavage.tex (booktabs + threeparttable)
           $MyProject/results/tables/_md/workshop/t_desc_wine_cantons_cleavage.md
 Author:   workshop-dispatch coder (2026-05-21, Phase 10b)
 Date:     2026-05-21
==============================================================================*/

version 19

if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}

global WorkshopTables "C:/Users/jensenn/Dropbox/Apps/Overleaf/Absinthe Switzerland Draft 1/Tables/Workshop_draft"


**# 1. Load + derive language group + restrict to wine cantons
*------------------------------------------------------------------------------*
{
    cap confirm file "$MyProject/processed/cohort_1908_workshop.dta"
    if _rc {
        di as error "  cohort_1908_workshop.dta missing.  Run 08_workshop + 09_workshop first."
        error 601
    }
    use "$MyProject/processed/cohort_1908_workshop.dta", clear
    assert c(N) == 25

    * Language group derivation (per dispatch §"Cultural-Cleavage Descriptive Table"):
    *   FR  if cov1 >= 50
    *   IT  if canton_iso == "TI"
    *   DE  otherwise
    cap drop lang_str
    gen str3 lang_str = "DE"
    replace lang_str = "FR" if cov1 >= 50 & !missing(cov1)
    replace lang_str = "IT" if canton_iso == "TI"

    * Numeric sort key for language ordering: FR < IT < DE per dispatch spec
    cap drop lang_sort
    gen byte lang_sort = .
    replace lang_sort = 1 if lang_str == "FR"
    replace lang_sort = 2 if lang_str == "IT"
    replace lang_sort = 3 if lang_str == "DE"

    * Wine canton indicator (X3_share > 0 — 20 cantons; alpine 5 excluded)
    cap drop wine_canton
    gen byte wine_canton = (X3_share > 0 & !missing(X3_share))
    qui count if wine_canton == 1
    di as text "  Wine cantons (X3_share > 0): " r(N) "  (expected 20)"

    * Sort: language group first, then Y1 descending within group
    gsort lang_sort -Y1
}


**# 2. Write LaTeX (booktabs + threeparttable, no \caption / \label per rules/tables.md)
*------------------------------------------------------------------------------*
{
    cap mkdir "$WorkshopTables"

    cap file close ftex
    file open ftex using "$WorkshopTables/t_desc_wine_cantons_cleavage.tex", write replace

    file write ftex "\begin{threeparttable}" _n
    file write ftex "\begin{tabular}{llcrrrrrr}" _n
    file write ftex "\toprule" _n
    file write ftex "Canton & Lang & Abs.\ & Red \% & White \% & Wine \% & Yes \#67 & Yes \#68 & Yes \#69 \\\\" _n
    file write ftex " & & prod. & nat'l & nat'l & nat'l & comm. & abs.\ ban & water \\\\" _n
    file write ftex "\midrule" _n

    * Track language groups for inserting midrules between them
    local prev_lang ""
    local row_count = 0

    forvalues i = 1/`=_N' {
        if wine_canton[`i'] != 1 continue
        local row_count = `row_count' + 1

        local lang_cur = lang_str[`i']
        if "`prev_lang'" != "" & "`lang_cur'" != "`prev_lang'" {
            file write ftex "\midrule" _n
        }
        local prev_lang "`lang_cur'"

        local cn  = canton_iso[`i']
        local lg  = lang_str[`i']
        local ap  = cond(abs_producer[`i'] == 1, "Y", "N")
        local rd  : di %5.1f X3_red_share[`i']
        local wh  : di %5.1f X3_white_share[`i']
        local wi  : di %5.1f X3_share[`i']
        local y67 : di %5.1f pct_yes_67[`i']
        local y68 : di %5.1f Y1[`i']
        local y69 : di %5.1f pct_yes_69[`i']

        file write ftex "`cn' & `lg' & `ap' & `rd' & `wh' & `wi' & `y67' & `y68' & `y69' \\\\" _n
    }

    file write ftex "\midrule" _n

    * Footer: group means (FR, IT, DE)
    foreach grp in FR IT DE {
        qui count if lang_str == "`grp'" & wine_canton == 1
        local n_grp = r(N)
        if `n_grp' == 0 continue

        qui sum X3_red_share if lang_str == "`grp'" & wine_canton == 1
        local m_rd : di %5.1f r(mean)
        qui sum X3_white_share if lang_str == "`grp'" & wine_canton == 1
        local m_wh : di %5.1f r(mean)
        qui sum X3_share if lang_str == "`grp'" & wine_canton == 1
        local m_wi : di %5.1f r(mean)
        qui sum pct_yes_67 if lang_str == "`grp'" & wine_canton == 1
        local m_67 : di %5.1f r(mean)
        qui sum Y1 if lang_str == "`grp'" & wine_canton == 1
        local m_68 : di %5.1f r(mean)
        qui sum pct_yes_69 if lang_str == "`grp'" & wine_canton == 1
        local m_69 : di %5.1f r(mean)

        file write ftex "\textit{`grp' mean (N=`n_grp')} & & & `m_rd' & `m_wh' & `m_wi' & `m_67' & `m_68' & `m_69' \\\\" _n
    }

    file write ftex "\bottomrule" _n
    file write ftex "\end{tabular}" _n
    file write ftex "\begin{tablenotes}[flushleft]\footnotesize" _n
    file write ftex "\item \textbf{Sources:} Wine production and revenue from 1907 Schweizerisches Statistisches Jahrbuch (HSSO Canton1907\_wine-data.xlsx, row 22 = Switzerland totals). Vote shares from swissvotes.ch (anr 67, 68, 69; 5 July 1908)." _n
    file write ftex "\item \textbf{Sample:} 20 wine-producing cantons (cohort 1908 minus 5 alpine non-producers UR, OW, NW, ZG, AI)." _n
    file write ftex "\item \textbf{Language group:} FR if French-language share $\geq$ 50\%; IT for Ticino (only Italian canton in cohort); DE otherwise. Sort order: FR \textrightarrow{} IT \textrightarrow{} DE; within group sorted by Yes \#68 descending." _n
    file write ftex "\item \textbf{Variables:} Red/White \% = canton share of NATIONAL red/white wine value (per Switzerland row totals from XLSX, denominator 6,796,247 / 21,854,806 CHF). Wine \% = canton share of national total wine value (denominator 29,782,933 CHF). Yes \#67/\#68/\#69 = canton yes-vote share for federal referenda commerce / absinthe ban / water power, all held 5 July 1908." _n
    file write ftex "\end{tablenotes}" _n
    file write ftex "\end{threeparttable}" _n

    file close ftex
    di as text "  Wrote: $WorkshopTables/t_desc_wine_cantons_cleavage.tex"
}


**# 3. Write Markdown twin (hand-built for clean PI-readable format)
*------------------------------------------------------------------------------*
{
    cap mkdir "$MyProject/results/tables/_md/workshop"

    cap file close fmd
    file open fmd using "$MyProject/results/tables/_md/workshop/t_desc_wine_cantons_cleavage.md", write replace

    file write fmd "# Table: Wine cantons — descriptive cultural-cleavage view (1908 cohort, N=20 wine cantons)" _n _n
    file write fmd "Sort: language group (FR -> IT -> DE), then Yes #68 descending within group." _n
    file write fmd "Red/White % = canton share of national red/white wine value (Switzerland totals from 1907 HSSO Canton1907_wine-data.xlsx)." _n
    file write fmd "Wine % = canton share of national total wine value (denominator 29,782,933 CHF)." _n _n

    file write fmd "| Canton | Lang | Abs prod | Red % | White % | Wine % | Yes #67 | Yes #68 | Yes #69 |" _n
    file write fmd "|--------|------|---------:|------:|--------:|-------:|--------:|--------:|--------:|" _n

    local prev_lang ""
    forvalues i = 1/`=_N' {
        if wine_canton[`i'] != 1 continue

        local lang_cur = lang_str[`i']
        if "`prev_lang'" != "" & "`lang_cur'" != "`prev_lang'" {
            file write fmd "| --- | --- | --- | --- | --- | --- | --- | --- | --- |" _n
        }
        local prev_lang "`lang_cur'"

        local cn  = canton_iso[`i']
        local lg  = lang_str[`i']
        local ap  = cond(abs_producer[`i'] == 1, "Y", "N")
        local rd  : di %5.1f X3_red_share[`i']
        local wh  : di %5.1f X3_white_share[`i']
        local wi  : di %5.1f X3_share[`i']
        local y67 : di %5.1f pct_yes_67[`i']
        local y68 : di %5.1f Y1[`i']
        local y69 : di %5.1f pct_yes_69[`i']

        file write fmd "| `cn' | `lg' | `ap' | `rd' | `wh' | `wi' | `y67' | `y68' | `y69' |" _n
    }

    * Footer: group means
    file write fmd "| --- | --- | --- | --- | --- | --- | --- | --- | --- |" _n
    foreach grp in FR IT DE {
        qui count if lang_str == "`grp'" & wine_canton == 1
        local n_grp = r(N)
        if `n_grp' == 0 continue

        qui sum X3_red_share if lang_str == "`grp'" & wine_canton == 1
        local m_rd : di %5.1f r(mean)
        qui sum X3_white_share if lang_str == "`grp'" & wine_canton == 1
        local m_wh : di %5.1f r(mean)
        qui sum X3_share if lang_str == "`grp'" & wine_canton == 1
        local m_wi : di %5.1f r(mean)
        qui sum pct_yes_67 if lang_str == "`grp'" & wine_canton == 1
        local m_67 : di %5.1f r(mean)
        qui sum Y1 if lang_str == "`grp'" & wine_canton == 1
        local m_68 : di %5.1f r(mean)
        qui sum pct_yes_69 if lang_str == "`grp'" & wine_canton == 1
        local m_69 : di %5.1f r(mean)

        file write fmd "| **`grp' mean (N=`n_grp')** |  |  | **`m_rd'** | **`m_wh'** | **`m_wi'** | **`m_67'** | **`m_68'** | **`m_69'** |" _n
    }

    file close fmd
    di as text "  Wrote: $MyProject/results/tables/_md/workshop/t_desc_wine_cantons_cleavage.md"
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
