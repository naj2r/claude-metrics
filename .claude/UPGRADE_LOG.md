# UPGRADE_LOG

When Claude encounters a knowledge gap during a session — a Stata command not covered by the always-in-context rules, an unexpected behavior, a missing reference — log it here. Periodic review by the user turns logs into permanent improvements (updates to `.claude/rules/stata-gotchas.md`, `guides/sources/`, or new entries in the codebook).

## Format

```
## YYYY-MM-DD — <topic> — <gap description> — <suggested addition>
```

- **YYYY-MM-DD**: today's date in ISO format
- **topic**: command name, concept, or area (e.g., `reshape`, `merge with str variable`, `coefplot options`)
- **gap description**: what was missing or unexpected (1-2 sentences)
- **suggested addition**: where to add it and what to add (file path + content)

## Examples

```
## 2025-08-15 — reshape long with i() prefix — Reshape failed with cryptic error when i() variable was string and j had non-numeric values. — Add gotcha to .claude/rules/stata-gotchas.md noting that reshape requires j() to be numeric or an explicit string() option.

## 2025-09-02 — coefplot xline option — coefplot's xline() didn't work with vertical orientation; needed yline() instead. — Add to guides/sources/stata-skill-ref/reference/graphics.md under coefplot section.
```

## Review cadence

Suggested: every ~10 entries or every 2 weeks, whichever comes first. Use `/review-upgrade-log` to surface entries.

---

## Entries

<!-- Append entries here. Newest at top. -->

## 2026-04-30 — file_read on markdown with backticks — `_codebook_update.ado` writes lines like `### \`processed/...\`` to codebook.md, then on the next invocation fails with `r(132) too few quotes` when file_read encounters those backticks (Stata interprets `` `...' `` inside the line as a macro reference, even through `macval()` + compound quotes). — Added gotcha to `.claude/rules/stata-gotchas.md` "File I/O and macro safety" section. Fixed `_codebook_update.ado` to write `### path` (no backticks) instead. Symmetric rule logged: never round-trip backticks through `file read` + `file write`.

## 2026-04-30 — import delimited hyphen handling — `import delimited` STRIPS hyphens from CSV column names entirely (preserves underscores). E.g., `zh-japroz` becomes `zhjaproz`, NOT `zh_japroz`. This contrasts with pandas/R, which convert hyphens to underscores. — Add gotcha to `.claude/rules/stata-gotchas.md`: when importing CSV with hyphenated headers, expect concatenated names. Test with `ds <pattern>` after import.

## 2026-04-30 — xpose strings-to-missing — `xpose, clear` converts ALL string variables to missing values; only numeric data survives transposition. To preserve values, `destring` BEFORE xpose. The `varname` option attaches original column names as a `_varname` variable, useful with merge against a column-letter→key crosswalk for the "tidy" import pattern. — Add to `.claude/rules/stata-gotchas.md` xpose section.

## 2026-04-30 — strL alternative for HSSO data lifecycle — Discussion: strL preservation throughout import (vs early destring) trades memory for raw-string traceability. Doesn't help with xpose's row→col limitation for multi-year data, so doesn't unify the vineyard handling with single-year HSSO files. Worth considering for edit-heavy long-running projects. — Optional addition to `guides/sources/stata-skill-ref/technique-guides/best-practices.md`: data type lifecycle trade-offs.
