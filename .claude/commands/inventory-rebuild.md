---
description: Delete and rebuild analysis/results/_inventory.xlsx by scanning all .do files and datasets
---

# /inventory-rebuild

Force a from-scratch rebuild of the inventory workbook. Re-creates all 6 sheets and re-populates from the current state of the repo.

## Action

### Step 1: Confirm and delete

Confirm with the user (since this discards run history):

> This will delete `analysis/results/_inventory.xlsx` and rebuild from current state. Run history will be lost. Proceed? (y/n)

If yes, delete the file.

### Step 2: Build a one-shot Stata script

```stata
do "$MyProject/scripts/programs/_config.do"

* Re-init
_inventory_init

* Scripts sheet
foreach script in 1_process_raw_data 2_clean_data 3_regressions 4_make_tables_figures {
    _inventory_append, sheet("scripts") row("`script'.do|.|<purpose from header>|.")
}

* Datasets sheet — scan processed/ and results/intermediate/ for .dta files
* (use a Stata file-listing helper or pre-compute the list outside)
foreach ds in <list> {
    _inventory_append, sheet("datasets") row("rebuilt|`ds'|.|.|.|/inventory-rebuild")
}

* Outputs sheet — scan results/figures/ and results/tables/
foreach out in <list> {
    _inventory_append, sheet("outputs") row("rebuilt|`out'|<table|figure>|/inventory-rebuild")
}

* Variables sheet — for each .dta in processed/, run describe and append rows
* (this is expensive; only do for final processed datasets)

* Pipeline sheet — left empty unless 2_clean_data.do has logged events
```

### Step 3: Run via MCP

Execute via `mcp__stata__run_do_file` (or batch fallback).

### Step 4: Confirm

Open `_inventory.xlsx` (visually if possible), confirm all 6 sheets exist with at least header rows, and report row counts to user.

## When to use

- Inventory file corrupted or accidentally edited
- After major restructure of the analysis tree
- Before publishing a snapshot — fresh inventory reflects only the published state
