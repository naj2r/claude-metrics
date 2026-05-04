---
description: Rebuild analysis/documentation/codebook.md from scratch by scanning all final processed datasets
---

# /update-codebook

Force a from-scratch rebuild of the codebook. Useful when the auto-update has drifted, or after merging a branch with conflicting codebook sections.

## Action

### Step 1: Inventory the datasets to scan

Identify all `.dta` files in:
- `analysis/processed/` (top-level)
- `analysis/processed/intermediate/`
- `analysis/results/intermediate/`

### Step 2: Reset the codebook

Move the existing `analysis/documentation/codebook.md` to `analysis/documentation/codebook.md.bak` (so changes outside marked sections are preserved if the user wants to recover them).

Re-create `codebook.md` with just the seeded header (suffix conventions etc).

### Step 3: Generate a one-shot Stata script

Build a temp `.do` file that:

```stata
do "$MyProject/scripts/programs/_config.do"

foreach ds in <list of dataset paths> {
    _codebook_update using "$MyProject/`ds'", script("/update-codebook")
}
```

### Step 4: Run via MCP (or batch fallback)

Execute the temp script via `mcp__stata__run_do_file`. This re-populates each dataset's section in `codebook.md` using `_codebook_update.ado`.

### Step 5: Confirm to user

Show the final `codebook.md` line count and the list of dataset sections refreshed.

## When to use

- After merging a branch where another contributor edited the codebook
- After a `/permissive`-mode session that may have skipped post-credits calls
- Before sharing the repo with a coauthor (clean baseline)
- When the codebook visibly disagrees with the data (likely from a manual edit going wrong)
