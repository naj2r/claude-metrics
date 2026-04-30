*! version 1.1.0 _inventory_append — init and append rows to _inventory.xlsx
*! Author: claude-metrics template
*!
*! Single ado-file that handles both first-time initialization (creates the
*! workbook with all 6 sheets and column headers) and subsequent appends.
*!
*! Schemas:
*!   runs:      timestamp | event | script | duration_sec | stata_version | os | host
*!   scripts:   timestamp | filename | lines | purpose | last_modified
*!   datasets:  timestamp | event | path | n_obs | n_vars | size_bytes | created_by
*!   variables: timestamp | dataset | variable | type | format | label | created_by
*!   outputs:   timestamp | event | path | type | generated_by
*!   pipeline:  timestamp | step | description | n_remaining | n_excluded | pct_original | script
*!
*! Usage:
*!   _inventory_append, sheet("runs") row("start|run.do|.|`c(stata_version)'|`c(os)'|`c(hostname)'")
*!   _inventory_append, sheet("datasets") row("created|processed/auto.dta|74|14|3520|2_clean_data.do")

program define _inventory_append
    version 15
    syntax , sheet(string) row(string) [project_dir(string)]

    if "`project_dir'" == "" local project_dir "$MyProject"
    if "`project_dir'" == "" {
        di as error "{bf:_inventory_append}: must set global \$MyProject or pass project_dir()"
        exit 198
    }

    local file "`project_dir'/results/_inventory.xlsx"

    * Initialize workbook if missing
    cap confirm file "`file'"
    if _rc {
        _inventory_init_internal, project_dir("`project_dir'")
    }

    * Compose timestamp
    local timestamp "`c(current_date)' `c(current_time)'"

    * Determine next row by reading the sheet header
    preserve
    quietly capture import excel "`file'", sheet("`sheet'") clear allstring firstrow
    if _rc {
        di as error "{bf:_inventory_append}: sheet `sheet' not found in `file'."
        restore
        exit 459
    }
    local nextrow = c(N) + 2
    restore

    * Open workbook for writing
    putexcel set "`file'", sheet("`sheet'") modify

    * Write timestamp in column A
    putexcel A`nextrow' = "`timestamp'"

    * Parse row by pipe and write cells B, C, D, ...
    local remaining "`row'"
    local col_idx = 2
    while strpos("`remaining'", "|") > 0 {
        local cell = substr("`remaining'", 1, strpos("`remaining'", "|") - 1)
        local col = char(64 + `col_idx')
        putexcel `col'`nextrow' = "`cell'"
        local remaining = substr("`remaining'", strpos("`remaining'", "|") + 1, .)
        local col_idx = `col_idx' + 1
    }
    * Last cell after final pipe
    local col = char(64 + `col_idx')
    putexcel `col'`nextrow' = "`remaining'"

    di as text "{bf:_inventory_append}: row `nextrow' added to [`sheet']"
end


*! Internal initializer — creates the workbook with all 6 sheets and headers.
*! Not intended to be called directly; called by _inventory_append on missing file.
program define _inventory_init_internal
    version 15
    syntax , [project_dir(string)]

    if "`project_dir'" == "" local project_dir "$MyProject"
    local results_dir "`project_dir'/results"
    local file "`results_dir'/_inventory.xlsx"

    cap mkdir "`results_dir'"

    * Sheet 1: runs
    putexcel set "`file'", sheet("runs") replace
    putexcel A1 = "timestamp"
    putexcel B1 = "event"
    putexcel C1 = "script"
    putexcel D1 = "duration_sec"
    putexcel E1 = "stata_version"
    putexcel F1 = "os"
    putexcel G1 = "host"

    * Sheet 2: scripts
    putexcel set "`file'", sheet("scripts") modify
    putexcel A1 = "timestamp"
    putexcel B1 = "filename"
    putexcel C1 = "lines"
    putexcel D1 = "purpose"
    putexcel E1 = "last_modified"

    * Sheet 3: datasets
    putexcel set "`file'", sheet("datasets") modify
    putexcel A1 = "timestamp"
    putexcel B1 = "event"
    putexcel C1 = "path"
    putexcel D1 = "n_obs"
    putexcel E1 = "n_vars"
    putexcel F1 = "size_bytes"
    putexcel G1 = "created_by"

    * Sheet 4: variables
    putexcel set "`file'", sheet("variables") modify
    putexcel A1 = "timestamp"
    putexcel B1 = "dataset"
    putexcel C1 = "variable"
    putexcel D1 = "type"
    putexcel E1 = "format"
    putexcel F1 = "label"
    putexcel G1 = "created_by"

    * Sheet 5: outputs
    putexcel set "`file'", sheet("outputs") modify
    putexcel A1 = "timestamp"
    putexcel B1 = "event"
    putexcel C1 = "path"
    putexcel D1 = "type"
    putexcel E1 = "generated_by"

    * Sheet 6: pipeline (Ouellet/Toffel §13b)
    putexcel set "`file'", sheet("pipeline") modify
    putexcel A1 = "timestamp"
    putexcel B1 = "step"
    putexcel C1 = "description"
    putexcel D1 = "n_remaining"
    putexcel E1 = "n_excluded"
    putexcel F1 = "pct_original"
    putexcel G1 = "script"

    di as text "{bf:_inventory_init_internal}: initialized `file' with 6 sheets"
end
