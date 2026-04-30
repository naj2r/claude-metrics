---
description: Display UPGRADE_LOG.md entries and ask which gaps to address
---

# /review-upgrade-log

Surface logged knowledge gaps for review. Suggests where each gap should be addressed (in `stata-gotchas.md`, `guides/sources/`, a new reference file, or an UPGRADE_LOG closure).

## Action

### Step 1: Read the log

Open `.claude/UPGRADE_LOG.md` and parse all entries (each starts with `## YYYY-MM-DD —`).

### Step 2: Categorize each entry

For each entry, infer where the fix should land:

- **`stata-gotchas.md`** — the gap is a frequently-encountered pitfall worth always-loading
- **`guides/sources/stata-skill-ref/reference/<topic>.md`** — the gap is in a specific topic area; update the mined reference
- **`docs-reader` extract** — the gap was resolved by reading a PDF; the extract should be saved
- **New rule** — the gap suggests a new hook rule (hard/soft/advisory)
- **`MEMORY.md`** — the gap is a project-specific fact, not a general convention

### Step 3: Present to user

Format as a table:

| Date | Topic | Suggested location | Status |
|---|---|---|---|
| 2026-04-29 | reshape with i() string | guides/sources/stata-skill-ref/reference/data-management.md | open |
| ... | ... | ... | ... |

### Step 4: Ask the user

> Which entries should I address now? (comma-separated indices, or "all", or "none")

For each selected entry:
- If it goes in `stata-gotchas.md`, propose the addition (don't auto-write — let user approve).
- If it goes in a reference file, propose the diff.
- If it's a new rule, propose the rule script and where it'd live.
- After applying, mark the entry as `(addressed YYYY-MM-DD)` in `UPGRADE_LOG.md`.

## Cadence

Suggested: every 10 entries or every 2 weeks. The log is small enough that running this command monthly catches most drift.
