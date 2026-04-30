---
description: Set hook mode to permissive (soft rules warn but don't block; useful for autonomous/offline runs)
---

# /permissive

Set the project-level hook mode to **permissive**. In permissive mode, soft rules emit warnings to stderr but do NOT block the tool call. Hard rules still block. Advisory rules still warn.

## Action

Write the literal string `permissive` to `.claude/.mode`:

```bash
echo "permissive" > .claude/.mode
```

Confirm to the user:

> Mode set to **permissive**. Soft rules will warn-only. Hard rules still block. Advisory rules warn-only. Review `.claude/edit-log.jsonl` and the inventory pipeline sheet after the session to catch any drift.

## When to use

- When Claude is running autonomously (e.g., overnight, scheduled tasks).
- When you want to review violations later instead of fixing in-session.
- When the strict-mode correction loop is interfering with progress on a known soft-rule edge case.
