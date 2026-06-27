*! _workshop_table v1.0  2026-05-22
*! Single styling wrapper for all workshop regression tables.
*!
*! Pipeline:  estimates use → optional FL ×100 rescale → regsave table() →
*!            clean_vars var → texsave (frag).
*!
*! Hardcoded "house style":
*!   - Coefficients: significant figures 3
*!   - Standard errors in parentheses, immediately below coef
*!   - Asterisks: * p<0.10, ** p<0.05, *** p<0.01
*!   - Booktabs rules with hlines(-2) (above N/R^2 stat block)
*!   - Auto-numbered column header (1)(2)(3)... plus user-specified descriptive row
*!   - frag option: .tex is \input-able fragment (no \documentclass)
*!   - nofix: don't double-escape (assume varlabels already valid LaTeX)
*!   - Footnote at \footnotesize
*!
*! INPUTS (passed via syntax options):
*!   sters(string)    : space-separated list of .ster file paths
*!   output(string)   : output .tex file path (must include .tex extension)
*!   title(string)    : table title (caption above table)
*!   tlabel(string)   : LaTeX \label{...} key (e.g. "tab:T2_X3_OLS")
*!                      NB: option name is `tlabel' not `label' to avoid collision
*!                          with Stata's built-in `label' command.
*!   mtitles(string)  : space-separated quoted column titles
*!                      e.g.  `""(1) baseline" "(2) +french" "(3) +absinthe""'
*!   footnote(string) : table footnote text (asterisk legend auto-appended)
*!   model(string)    : "ols" (default) | "fl_pp" (rescales FL AME × 100)
*!   keep(string)     : space-separated varlist to keep + order
*!                      (default: all regvars + r2 + N)
*!
*! OUTPUTS: writes `output' .tex file as a LaTeX fragment.

* Inner helper: must be eclass to call ereturn repost.
* Rescales FL AME e(b) × 100, e(V) × 10000 (delta-method scaling for SE in pp).
cap program drop _wt_fl_pp_rescale
program define _wt_fl_pp_rescale, eclass
    tempname b_pp V_pp
    matrix `b_pp' = e(b) * 100
    matrix `V_pp' = e(V) * 10000
    ereturn repost b = `b_pp' V = `V_pp'
end


program define _workshop_table
    version 19
    syntax , STERS(string) OUTput(string) ///
        [TITLE(string) TLABel(string) MTitles(string asis) ///
         Footnote(string) MODEL(string) Keep(string)]

    if "`model'" == "" local model "ols"
    if !inlist("`model'", "ols", "fl_pp") {
        di as error "  _workshop_table: model() must be 'ols' or 'fl_pp', got `model'"
        exit 198
    }

    tempfile tmpreg
    local col_no 0
    local first_pass 1

    * --- Loop estimates: load, optional rescale, append to growing table ---
    foreach sterpath of local sters {
        local col_no = `col_no' + 1
        local col_name col`col_no'

        cap estimates use "`sterpath'"
        if _rc {
            di as error "  _workshop_table: could not load .ster: `sterpath'"
            exit 601
        }

        if "`model'" == "fl_pp" {
            _wt_fl_pp_rescale
        }

        if `first_pass' {
            qui regsave using "`tmpreg'", ///
                table(`col_name', parentheses(stderr) sigfig(3) ///
                      asterisk(10 5 1) order(regvars r2 N)) ///
                replace
            local first_pass 0
        }
        else {
            qui regsave using "`tmpreg'", ///
                table(`col_name', parentheses(stderr) sigfig(3) ///
                      asterisk(10 5 1) order(regvars r2 N)) ///
                append
        }
    }

    * --- Load accumulated table dataset ---
    use "`tmpreg'", clear

    * --- Optional keep+order filter ---
    * NB: regsave's table() option names rows as `varname_coef' and
    * `varname_stderr' (see regsave help, example 6).  Match BOTH so the
    * coefficient and SE rows are kept together for each variable.
    if "`keep'" != "" {
        gen long _order_main = .
        gen byte _order_sub  = .   // 1 = coef row, 2 = stderr row
        local i 0
        foreach v of local keep {
            local i = `i' + 1
            qui replace _order_main = `i' if var == "`v'_coef"
            qui replace _order_sub  = 1  if var == "`v'_coef"
            qui replace _order_main = `i' if var == "`v'_stderr"
            qui replace _order_sub  = 2  if var == "`v'_stderr"
        }
        * Also keep r2 and N rows at the end (these are NOT _coef-suffixed).
        local stat_i = `i' + 1
        qui replace _order_main = `stat_i'     if var == "r2"
        qui replace _order_sub  = 1            if var == "r2"
        qui replace _order_main = `stat_i' + 1 if var == "N"
        qui replace _order_sub  = 1            if var == "N"
        qui keep if !missing(_order_main)
        sort _order_main _order_sub
        drop _order_main _order_sub
    }

    * --- Cosmetic cleanup of var column ---
    * Per Reif's regsave example 6: strip _coef suffix on coef rows (so the
    * var column shows the bare variable name, which clean_vars then relabels),
    * blank out _stderr rows so SE rows have no row label, and rename r2.
    qui replace var = subinstr(var, "_coef", "", 1)  if strpos(var, "_coef")   > 0
    qui replace var = ""                              if strpos(var, "_stderr") > 0
    qui replace var = "R-squared"                     if var == "r2"

    * --- Count statistic rows to compute hlines offset dynamically ---
    * Midrule should sit BEFORE the first stat row (R-squared or N).
    * texsave's hlines(-k) draws the rule BEFORE row k-from-end.
    * If both R-squared and N present → 2 stat rows → hlines(-2).
    * If only N (FL panels) → 1 stat row → hlines(-1).
    qui count if var == "R-squared" | var == "N"
    local n_stats = r(N)
    local hline_pos = -`n_stats'
    if `n_stats' == 0 local hline_pos = -1   // safety default

    * --- Apply variable-name relabeling via clean_vars ---
    cap clean_vars var

    * --- Build headerlines for descriptive column titles ---
    * texsave's autonumber writes (1)(2)(3)... as the first header row.
    * headerlines adds the descriptive mtitles row below it.
    * tokenize handles quoted strings as single tokens (each "..." → one `i').
    local hdr ""
    if `"`mtitles'"' != "" {
        tokenize `mtitles'
        local i 1
        while `"``i''"' != "" {
            local hdr `"`hdr' & ``i''"'
            local i = `i' + 1
        }
    }

    * --- Compose footnote with asterisk legend appended ---
    local fn_full ""
    if `"`footnote'"' != "" {
        local fn_full `"`footnote'"'
        local fn_full `"`fn_full' "'
    }
    local fn_full `"`fn_full'Robust standard errors in parentheses. * p\(<\)0.10, ** p\(<\)0.05, *** p\(<\)0.01."'
    * Measurement-vintage honesty note (1907 population-correctness fix, 2026-06-17):
    local fn_full `"`fn_full' Demographic-control vintages: religion (Catholic/Protestant) and language (French/German) shares are the 1900 census (nearest available, held fixed over the window); population and density are 1907; petition rates use 1906 population."'

    * --- Final texsave call (booktabs fragment) ---
    if `"`hdr'"' != "" {
        texsave using "`output'", ///
            replace frag nofix nonames autonumber ///
            headerlines(`"`hdr'"') ///
            hlines(`hline_pos') ///
            title("`title'") ///
            label("`tlabel'") ///
            footnote("`fn_full'", size(footnotesize))
    }
    else {
        texsave using "`output'", ///
            replace frag nofix nonames autonumber ///
            hlines(`hline_pos') ///
            title("`title'") ///
            label("`tlabel'") ///
            footnote("`fn_full'", size(footnotesize))
    }

    di as text "  _workshop_table: wrote `output' (model=`model', cols=`col_no')"
end

** EOF
