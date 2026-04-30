*! version 1.0.0 _codebook_update — refresh codebook.md entry for a dataset
*! Author: claude-metrics template
*! Purpose: append/replace a per-dataset section in analysis/documentation/codebook.md
*!
*! Usage:
*!   _codebook_update using "$MyProject/processed/auto.dta", script("2_clean_data.do")
*!
*! The using/ dataset is opened in a preserve/restore block. The codebook section
*! for that dataset is wiped (matched by HTML-comment markers) and replaced with
*! current variable metadata (name, type, format, label).

program define _codebook_update
    version 15
    syntax using/, script(string) [project_dir(string) section(string)]

    * Resolve project root
    if "`project_dir'" == "" local project_dir "$MyProject"
    if "`project_dir'" == "" {
        di as error "{bf:_codebook_update}: must set global \$MyProject or pass project_dir()"
        exit 198
    }

    local cb_path "`project_dir'/documentation/codebook.md"
    local cb_dir "`project_dir'/documentation"

    * Ensure documentation directory exists
    cap mkdir "`cb_dir'"

    * Resolve relative path used as section key
    local rel_using = subinstr("`using'", "`project_dir'/", "", .)
    local rel_using = subinstr("`rel_using'", "\", "/", .)

    local marker_start "<!-- codebook:`rel_using':start -->"
    local marker_end "<!-- codebook:`rel_using':end -->"

    * If codebook doesn't exist, seed it with header
    cap confirm file "`cb_path'"
    if _rc {
        tempname seedh
        file open `seedh' using "`cb_path'", write replace
        file write `seedh' "# Project Codebook" _n _n
        file write `seedh' "_Auto-updated by _codebook_update.ado_" _n _n
        file write `seedh' "## Suffix conventions" _n _n
        file write `seedh' "- _cat — categorical" _n
        file write `seedh' "- _mz — missing-recoded-to-zero" _n
        file write `seedh' "- _mm — missing-recoded-to-mean" _n
        file write `seedh' "- _miss — imputation indicator" _n
        file write `seedh' "- _ln — natural log" _n
        file write `seedh' "- _lnp1 — natural log of (x+1)" _n _n
        file write `seedh' "## Datasets" _n _n
        file close `seedh'
    }

    * Read existing codebook, write tempfile excluding the section for this dataset
    tempfile newcb
    tempname rh wh
    file open `rh' using "`cb_path'", read
    file open `wh' using "`newcb'", write

    local skip 0
    file read `rh' line
    while r(eof) == 0 {
        if strpos(`"`macval(line)'"', "`marker_start'") > 0 {
            local skip 1
        }
        if `skip' == 0 {
            file write `wh' `"`macval(line)'"' _n
        }
        if strpos(`"`macval(line)'"', "`marker_end'") > 0 {
            local skip 0
            file read `rh' line
            continue
        }
        file read `rh' line
    }
    file close `rh'

    * Append the new section. Use **bold** instead of backticks for the path
    * because file_read on subsequent invocations chokes on lines containing
    * backticks (Stata interprets them as macro references even inside macval).
    file write `wh' "`marker_start'" _n
    file write `wh' "### `rel_using'" _n _n
    file write `wh' "_Updated: `c(current_date)' `c(current_time)' by `script'_" _n _n

    * Open the dataset (preserve current data)
    preserve
    quietly use "`using'", clear

    local nobs = c(N)
    local nvars = c(k)
    file write `wh' "**N = `nobs', vars = `nvars'**" _n _n

    if "`section'" != "" {
        file write `wh' "_`section'_" _n _n
    }

    file write `wh' "| Variable | Type | Format | Label |" _n
    file write `wh' "|---|---|---|---|" _n

    quietly ds
    local vlist `r(varlist)'
    foreach v of local vlist {
        local lbl : variable label `v'
        local typ : type `v'
        local fmt : format `v'
        * Escape pipe characters in labels (markdown table cell separator)
        local lbl_safe = subinstr(`"`lbl'"', "|", "\|", .)
        file write `wh' `"| `v' | `typ' | `fmt' | `lbl_safe' |"' _n
    }

    restore

    file write `wh' _n "`marker_end'" _n _n
    file close `wh'

    * Replace the codebook with the new version
    copy "`newcb'" "`cb_path'", replace

    di as text "{bf:_codebook_update}: refreshed entry for `rel_using' (vars=`nvars', N=`nobs') in `cb_path'"
end
