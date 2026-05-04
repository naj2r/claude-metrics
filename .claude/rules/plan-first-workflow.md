---
description: Use plan mode for non-trivial work
---

# Plan-First Workflow

For non-trivial tasks — new analysis scripts, refactors, multi-file edits, or anything affecting the run.do pipeline — enter **plan mode** before touching files. Plan mode is read-only and surfaces the approach for user approval before any edits land.

## When to plan

- Creating a new numbered script (`/new-script` is a single-file scaffold; the *content* of the script is the non-trivial part).
- Refactoring across multiple `.do` files.
- Changing the structure of `analysis/` (new subdirectories, moves, renames).
- Modifying `run.do` orchestration (new step, removed step, reordering).
- Updating `_config.do`, `_codebook_update.ado`, `_inventory_*.ado`, or any program in `programs/`.
- Modifying any hook in `.claude/hooks/`.

## When NOT to plan

- Single-line fixes to existing scripts.
- Adding a comment or a label to one variable.
- Reading files for understanding.
- Running validators, codebook updates, or other read-only commands.

## How to plan

1. Enter plan mode (Shift+Tab in the harness, or `claude --permission-mode plan`).
2. Explore: read the relevant files, understand the existing patterns.
3. Write the plan to `analysis/documentation/plans/<YYYY-MM-DD>_<slug>.md`.
4. Surface to the user via ExitPlanMode for approval.
5. Once approved, execute the plan without further interruption.

## What a good plan contains

- **Context**: why this change is needed.
- **Approach**: the recommended path; alternatives only if relevant trade-offs exist.
- **Files to modify**: explicit list with paths.
- **Verification**: how you'll confirm the change worked end-to-end.
- **Out-of-scope**: what's deliberately NOT being done now.
