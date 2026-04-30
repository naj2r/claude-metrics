---
paths:
  - "**/*.do"
  - "**/*.R"
  - "**/*.qmd"
  - "**/run.do"
description: Verify before reporting done — run, render, or test the change
---

# Verification Protocol

When you edit a `.do`, `.R`, or `.qmd` file, **verify the change works** before reporting the task complete. "Done" means observed behavior, not intent.

## What counts as verification

| File type | Verification step |
|---|---|
| `.do` (any) | Run via `mcp__stata__run_do_file` or `stata-mp -b do`. Read the log. Confirm no errors and that any `assert` statements pass. |
| `.do` (numbered top-level) | If part of `run.do` chain: re-run `run.do` end-to-end via `/run-stata`. |
| `.R` | Run via `Rscript` or via Stata's `rscript`. Check for errors. |
| `.qmd` | Render via `quarto render`. Confirm the output PDF/HTML builds and contains expected content. |

## What is NOT verification

- Reading the file again to "look right."
- Running `which` on a command without testing it.
- Reading the diff and reasoning through it.
- "It compiled before, the change is small, should be fine."

## When verification fails

- Read the error message in full.
- Diagnose the root cause; do not patch over it.
- If the cause is a missing package, update `_install_stata_packages.do` and re-run the install.
- If the cause is a `_config.do` issue, fix `_config.do` (not the calling script).
- Log the failure and resolution to `.claude/UPGRADE_LOG.md` if the cause is non-obvious.

## Reporting completion

End-of-task summary should state:
- What you changed (1 sentence)
- How you verified (1 sentence with concrete output)
- Any caveats or follow-ups

NOT acceptable:
> "Updated `2_clean_data.do` and the change should work."

Acceptable:
> "Updated `2_clean_data.do` to drop missing values. Verified: `run.do` completes in 0.04 hours, `processed/auto.dta` has N=72, codebook updated, inventory pipeline sheet shows the exclusion."
