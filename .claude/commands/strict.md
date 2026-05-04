---
description: Set hook mode to strict (soft rules block on violation, recursive correction expected)
---

# /strict

Set the project-level hook mode to **strict**. In strict mode, soft rules cause hooks to exit 2 (block the tool call) and Claude is expected to self-correct. Hard rules always block. Advisory rules always warn.

## Action

Write the literal string `strict` to `.claude/.mode`:

```bash
echo "strict" > .claude/.mode
```

Confirm to the user:

> Mode set to **strict**. Soft rules will now block until corrected. Hard rules always block. Advisory rules warn-only.

## When to use

- When you (the user) are actively at your computer reviewing Claude's work in real time.
- When you want recursive correction loops to fire on style/convention violations.
- Default state for all sessions.
