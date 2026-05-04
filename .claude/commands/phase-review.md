---
description: Auto-trigger an adversarial read-only review at the end of each implementation phase
argument-hint: "<phase-name-or-number> [paths-or-globs-to-focus-on]"
---

# /phase-review

Run a lightweight adversarial review of the most recent phase's work. The reviewer runs as a subagent with **read-only tools only** — Read, Grep, Glob. It cannot edit. It does not negotiate. It reports PASS / FAIL per requirement.

## When to invoke

Automatically at the end of each implementation phase, before presenting the verification checklist. Manually any time you want a separate set of eyes on what just landed.

## Action

Dispatch a `general-purpose` agent (or `Explore` agent if available) with this prompt:

```
You are a read-only compliance reviewer for the claude-metrics template repo.
You have Read, Grep, and Glob tools only — you cannot edit anything.

Review the files listed below against the requirements for Phase <N>:
<list the requirements verbatim from the phase spec>

For every requirement, output a row in this table:

## Phase <N> Review
| Requirement | Status | Finding |
|-------------|--------|---------|
| <requirement> | ✓ PASS / ✗ FAIL | <specific finding or "meets spec"> |

Always also run these cross-cutting checks:
1. CLAUDE.md line count — must be ≤150. Report exact count.
2. .gitignore — must include .claude/.mode, CLAUDE.local.md,
   analysis/data/ (or analysis/data/raw/ if restructured),
   analysis/results/_inventory.xlsx, analysis/scripts/logs/.
3. No hardcoded absolute paths (C:\, /Users/, /home/) in any new file.
4. No `ssc install` or `net install` outside _install_stata_packages.do.
5. Every new shell script: has `#!/usr/bin/env bash` shebang, is executable
   (use `ls -l`), sources lib/common.sh if it uses block/warn helpers.

Do not summarize. Do not be diplomatic. If something is wrong, say exactly
what is wrong and where (file path + line if applicable).

Flag anything that looks like:
- Placeholder content passed off as implementation
- Spec drift (does adjacent thing rather than specified thing)
- Missing edge cases (e.g., hook blocks happy path but exits 0 on malformed input)
- Cross-file inconsistency (behavior specified in one file depends on a value
  in another that doesn't agree)
- Silent failures (code runs but produces no specified output)
```

## Escalation rule

If the reviewer finds the same failure twice in a row (claimed fixed but fails again on re-review), **stop and ask the user** before attempting a third fix. Do not loop silently.

## What to do with findings

For each ✗ FAIL:
1. Read the specific file/lines flagged.
2. Determine root cause (don't patch over it).
3. Apply the fix.
4. Re-run `/phase-review` until all rows show ✓ PASS.
5. Then proceed to the verification checklist.
