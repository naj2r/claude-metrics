---
description: Document a substantive paper-level change as a permanent progress note in analysis/documentation/progress/
argument-hint: "<topic-slug-1-or-2-words>"
---

# /major-change

Invoke the `major-change` skill (`.claude/skills/major-change/SKILL.md`) to write a permanent in-depth markdown note documenting a substantive change to the paper's findings, design, or interpretation.

## Usage

```
/major-change <topic-slug>
```

Examples:
- `/major-change foodbev` — for the vote-#65-as-regulatory-prequel finding
- `/major-change simpson` — for documenting the Simpson's-paradox sign-flip
- `/major-change oster` — for the Oster (2019) coefficient stability discussion

If no topic is given, ask the user for one (1-2 words, lowercase).

## What this command does

1. Reads the most recent conversation context to identify the substantive finding/decision.
2. Determines current date and time.
3. Writes `analysis/documentation/progress/progress_YYYY-MM-DD_HHMM_<topic>.md` using the structured template in the major-change skill.
4. Updates CONTEXT.md / HANDOFF if the finding warrants headline elevation.
5. Updates the inventory.
6. Surfaces the path to the user and offers to commit + push.

## Auto-trigger phrases (without explicit slash invocation)

The skill is also configured to auto-invoke when the user says:
- "this is a major change [of the paper]"
- "this should be a [second] headline"
- "document this for posterity"
- "save this finding"
- "make a giant note on this"

So `/major-change` is the explicit form; the skill also fires on those natural-language cues.
