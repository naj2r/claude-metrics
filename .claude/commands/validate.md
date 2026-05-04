---
description: Run all hard, soft, and advisory checks across analysis/ and report violations
---

# /validate

Comprehensive compliance scan across the entire `analysis/` tree. Reports violations of hard, soft, and advisory rules. Does not modify any files.

## Action

1. Read the current mode from `.claude/.mode` (informational — `/validate` runs ALL checks regardless of mode).
2. Glob all `.do` and `.R` files under `analysis/`.
3. For each file, simulate a PreToolUse Edit (read content + path) and run each rule script in `.claude/hooks/rules/{hard,soft,advisory}/`.
4. Aggregate results into a structured report:

```
=== /validate report ===
Mode: <strict|permissive>
Files scanned: <N>

[HARD] N violations across M files:
  hard/01-data-immutable.sh — <file>:<reason>
  ...

[SOFT] N violations across M files (would block in strict, warn in permissive):
  soft/11-set-seed.sh — <file>:<reason>
  ...

[ADVISORY] N warnings across M files:
  advisory/20-script-header.sh — <file>:<reason>
  ...

CONTEXT.md completeness: <PASS|missing fields: ...>
```

5. Also check `CONTEXT.md` for empty `[ FILL IN ]` placeholders in the 5 required fields.

## Output destination

Write the full report to `analysis/documentation/validate_report_<YYYY-MM-DD>.md` and echo a summary to stdout.

## Use cases

- Before commits, run `/validate` to catch drift.
- Before sharing the repo with a coauthor, ensure clean baseline.
- After a `/permissive` session, check accumulated violations.
