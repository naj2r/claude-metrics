# Codebook protocol

`analysis/documentation/codebook.md` is an auto-updated markdown dictionary of every variable in every processed dataset.

## Update mechanism

### Stata-runtime (authoritative)

`analysis/scripts/programs/_codebook_update.ado` runs at the end of each numbered script:

```stata
_codebook_update using "$MyProject/processed/<dataset>.dta", script("<N>_<slug>.do")
```

It opens the dataset (via `preserve` / `restore`), iterates over all variables, and updates the section in `codebook.md` for that dataset. Sections are bracketed by HTML-comment markers (`<!-- codebook:<path>:start --> ... <!-- codebook:<path>:end -->`) so re-running the same script replaces only that dataset's entry.

### Claude-time advisory (informational)

A `PostToolUse` hook (`post-edit-codebook-advisory.sh`) greps `.do` file edits for `gen|egen|replace|label variable` patterns and reminds Claude that the codebook will refresh on the next run. Never blocks.

## Structure

```markdown
# Project Codebook

_Auto-updated by _codebook_update.ado_

## Suffix conventions  ← edited manually; preserved across refreshes
- _cat — categorical
- _mz — missing-recoded-to-zero
- ...

## Datasets

<!-- codebook:processed/auto.dta:start -->
### `processed/auto.dta`
_Updated: 29 Apr 2026 14:32 by 2_clean_data.do_

**N = 74, vars = 14**

| Variable | Type | Format | Label |
|---|---|---|---|
| make | str18 | %-18s | Make and Model |
| price | int | %12.0fc | Price (1978 dollars) |
| ... | ... | ... | ... |

<!-- codebook:processed/auto.dta:end -->
```

## Suffix conventions (Ouellet/Toffel §7a)

- `_cat` — categorical (binned from continuous)
- `_mz` — missing-recoded-to-zero
- `_mm` — missing-recoded-to-mean
- `_miss` — binary indicator (1 = imputation/recode applied)
- `_ln` — natural log
- `_lnp1` — natural log of (x+1)

Variable names should imply their coding (`female` not `gender`, `log_employment` not `size`). Variable labels should include units (`pounds`, `dollars`, `%`) where applicable.

## Manual edits

Anything **outside** the marked sections persists across refreshes. Use this for:

- The "Suffix conventions" section header and table
- Project-level notes about variable provenance
- Cross-references between datasets

Anything **inside** marked sections (`<!-- codebook:...:start --> ... <!-- ...:end -->`) is overwritten on next run.

## `/update-codebook`

Force a from-scratch rebuild by scanning all final processed datasets. Useful after merging a branch with conflicting codebook sections, or when the auto-update has drifted.

## Why markdown (not CSV or PDF)

Markdown is git-diffable, human-readable, renders nicely in any IDE, and supports the marker pattern that lets us update one section at a time. CSV would lose the suffix-convention prose; PDF would prevent diffing.
