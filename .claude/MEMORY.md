# Project Memory

Persistent across sessions. Read at start of every conversation.

## Format

```
[LEARN:category] one-line description of discovered behavior or correction
```

When the user types `[LEARN] <correction>` or you discover a non-obvious project behavior, persist it here.

## Key Facts

- **Stata version**: 19 (StataNow)
- **Stata install**: `C:\Program Files\StataNow19\`
- **Stata docs**: `C:\Program Files\StataNow19\docs\` (u.pdf copied to `guides/sources/pdfs/u.pdf`)
- **Libraries vendored in**: `analysis/scripts/libraries/stata/`
- **All globals set in**: `analysis/scripts/programs/_config.do` (single source of truth)
- **Mode file**: `.claude/.mode` (`strict` or `permissive`; default `strict`)
- **Codebook**: `analysis/documentation/codebook.md` (auto-updated by `_codebook_update.ado` on each script run)
- **Inventory**: `analysis/results/_inventory.xlsx` (gitignored; 6 sheets; appended on every script run)
- **Demo branch**: `master` keeps Reif's `auto.csv` analysis intact as a working reference
- **Starter branch**: `starter` is empty scaffold — clone target for new projects
- **Plans directory**: `analysis/documentation/plans/` (set in settings.json)

## Project layout (read-only — do not modify these conventions)

- `analysis/data/` — immutable raw data. Hard rule blocks all writes.
- `analysis/processed/` — cleaned/derived data. Regenerable by re-running scripts.
- `analysis/results/` — tables, figures, intermediate regression output.
- `analysis/scripts/` — top-level numbered .do files (`N_description.do` pattern).
- `analysis/scripts/programs/` — ado-files and helper programs (no name-pattern rule).
- `analysis/scripts/libraries/stata/` — vendored add-on packages.
- `paper/` — LaTeX/Quarto manuscript.
- `setup_resources/` — convention docs (Reif guide, Ouellet/Toffel notes, MODE/HOOKS/etc).
- `guides/sources/` — read-only external reference material (Reif/COMET/Stata PDFs).
- `.claude/` — Claude Code infrastructure (hooks, rules, commands, skills, memory).

## Corrections Log

<!-- Append [LEARN:...] entries here. Newest at top. -->
