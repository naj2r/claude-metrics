# Mode toggle reference

`.claude/.mode` controls how soft rules behave. Two values:

| Mode | File contents | Soft rules | Use case |
|---|---|---|---|
| **strict** (default) | `strict\n` | Block on violation; hook returns exit 2 | Active work at your computer; you want recursive correction |
| **permissive** | `permissive\n` | Warn via stderr; hook returns exit 0 | Autonomous/offline runs; review later |

## Toggling

- `/strict` — overwrites `.claude/.mode` with `strict`
- `/permissive` — overwrites `.claude/.mode` with `permissive`

## Behavior matrix

| Rule tier | Strict mode | Permissive mode |
|---|---|---|
| Hard | Block (exit 2) | Block (exit 2) |
| Soft | Block (exit 2) | Warn (exit 0 + stderr) |
| Advisory | Warn (exit 0 + stderr) | Warn (exit 0 + stderr) |

## How Claude knows the mode

The `UserPromptSubmit` hook (`inject-mode-context.sh`) prepends `[Mode: strict]` or `[Mode: permissive]` to every user turn so Claude has visibility without checking the file.

## When mode flips mid-session

Toggling via `/strict` or `/permissive` updates the file immediately. The next user prompt will reflect the change. In-flight tool calls already executing are not interrupted.

## Default state

`.claude/.mode` is initially `strict` and is gitignored — each clone starts fresh.

## Why no `auto` mode

We considered an auto-mode that flips based on whether the session is interactive. Rejected: too magical. Explicit toggling is auditable.
