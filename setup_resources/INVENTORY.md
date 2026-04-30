# Inventory protocol

`analysis/results/_inventory.xlsx` is a living workbook accumulating run history, scripts, datasets, variables, outputs, and pipeline events. Gitignored. Regenerable.

## Sheets

| Sheet | Columns | Updated by |
|---|---|---|
| `runs` | timestamp, event, script, duration_sec, stata_version, os, host | `run.do` start + end |
| `scripts` | timestamp, filename, lines, purpose, last_modified | post-credits in each numbered script |
| `datasets` | timestamp, event, path, n_obs, n_vars, size_bytes, created_by | post-credits when a script saves a `.dta` |
| `variables` | timestamp, dataset, variable, type, format, label, created_by | (currently routed via codebook; sheet reserved for future use) |
| `outputs` | timestamp, event, path, type, generated_by | `4_make_tables_figures.do` per table/figure |
| `pipeline` | timestamp, step, description, n_remaining, n_excluded, pct_original, script | `2_clean_data.do` per exclusion step (Ouellet/Toffel §13b) |

## Update mechanism

`analysis/scripts/programs/_inventory_append.ado` is a single ado-file that handles both first-time initialization (creates workbook with all 6 sheets and column headers) and subsequent appends. Uses Stata's `putexcel`.

Each numbered script ends with a post-credits block that calls `_inventory_append` for the relevant sheets. `run.do` writes to the `runs` sheet at start and end.

## Schema for `row()` argument

`_inventory_append, sheet("X") row("col2|col3|col4|...")` — the `timestamp` column is auto-filled, then each pipe-separated value goes in subsequent columns.

## Rebuilding

`/inventory-rebuild` deletes `_inventory.xlsx` and rebuilds by scanning all `.do` files and datasets. Run history is lost (deliberately — fresh inventory reflects only current state).

## Why xlsx (not CSV or JSONL)

Multiple sheets in one file, human-browsable in Excel/LibreOffice, naturally handles mixed types per sheet. CSV/JSONL would require either six files or a single denormalized log, both worse.

## Performance

For projects with >10,000 rows in a sheet, the read-modify-write pattern (used because Stata's `putexcel` doesn't expose "next empty row") starts to slow down. Mitigation: archive old `_inventory.xlsx` periodically and start fresh.

## Pipeline table convention

Exclusion steps in `2_clean_data.do` should each call:

```stata
_inventory_append, sheet("pipeline") row("<step>|<description>|<n_remaining>|<n_excluded>|<pct_original>|2_clean_data.do"
```

The pct_original is always relative to the initial sample size, not the prior step.
