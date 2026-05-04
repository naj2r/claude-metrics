---
name: major-change
description: Document a substantive change to the paper's findings, design, or interpretation as a permanent in-depth markdown note in `analysis/documentation/progress/`. Make sure to use this skill whenever the user says "this is a major change", "major change of the paper", "this is headline", "second headline", "document this finding", "save this for the paper", or describes a finding/decision they want preserved as part of the project's intellectual history. Also use it proactively when you make a discovery the user reacts strongly to (e.g., "Jesus", "wow", "this is huge"). The skill writes a structured historical-style summary including context, mechanism, evidence, caveats, and provenance — designed to be readable years later by the user, a coauthor, or a referee. Filename convention: `progress_YYYY-MM-DD_HHMM_<topic>.md` where topic is a 1-2 word lowercase slug.
---

# major-change

Capture moments where the paper's intellectual content shifts: a new headline, a reframed mechanism, a robustness check that changes interpretation, a finding ported from prior work, or a methodological choice that needs to outlive any particular conversation. Each invocation writes ONE permanent markdown note.

## When to invoke

Always invoke when the user says any variant of:
- "this is a major change [of the paper]"
- "this should be a [second] headline"
- "document this [as a major change | for the paper | for posterity]"
- "save this finding"
- "make a giant note on this"

Also invoke proactively (without explicit user request) when:
- A finding lands that the user reacts strongly to ("Jesus", "wow", "this is huge", "that's the paper", etc.)
- A reframing changes the substantive interpretation (e.g., "X is not Y, X is the prequel to Y")
- A robustness/falsification result corroborates the headline in a way worth preserving

When in doubt, invoke. The marginal cost of an extra progress note is small (one file). The cost of losing a finding because it was buried in a chat transcript is large.

## Filename convention

```
analysis/documentation/progress/progress_YYYY-MM-DD_HHMM_<topic>.md
```

- `YYYY-MM-DD`: date in ISO-8601, e.g. `2026-04-30`
- `HHMM`: 24-hour time of write, e.g. `1820`
- `<topic>`: 1-2 word lowercase slug capturing the substantive content, e.g. `foodbev`, `simpson`, `oster`, `placebo`, `naturalization`. Use the user's suggested topic if given; otherwise pick the shortest descriptive slug.

Example: `progress_2026-04-30_1820_foodbev.md` for the vote-#65-as-regulatory-prequel finding.

## Action sequence

1. **Determine topic slug.** If the user named it (e.g., "for this one it would be foodbev"), use that. Otherwise propose 2-3 candidates and pick the most specific.
2. **Determine current date and time.** Use the date/time available in the session context. For time, use the current local time at moment of write (4-digit 24h). If unsure, use the timestamp of the most recent run or git commit as a proxy.
3. **Write the note** to the path above using the template below.
4. **Update related documentation:**
   - `CONTEXT.md` — if the finding warrants elevation to headline/secondary-headline, add or amend the relevant Notes section.
   - `analysis/documentation/HANDOFF_*.md` (if any) — add a TL;DR bullet pointing to the new progress note.
   - `analysis/results/_inventory.xlsx` — append a `progress_*` entry under the `outputs` sheet via `_inventory_append`. (If running outside Stata, defer this to the next pipeline run.)
5. **Surface to user**: confirm with the path and a one-line summary. Offer to commit + push if user is in active session.

## Note template

```markdown
# Progress note: [Headline of the finding in 5-10 words]

**Date**: YYYY-MM-DD HH:MM
**Topic**: <topic-slug>
**Triggered by**: [user message excerpt or autonomous discovery context]
**Status**: [headline | second headline | reframing | robustness | methodological choice | data decision]

---

## Headline (1 paragraph)

[State the finding precisely in 2-4 sentences. Include the key number(s) if applicable. Write as if for the paper's abstract.]

---

## Background and discovery

[How did this come up? What was the prior framing, and what changed? If ported from prior work, name the source.]

---

## Substantive content

[The detail. Translate any non-English material. Walk through the historical/institutional context. If the finding is a regression result, give the coefficient, SE, p, sample size, and specification. If it's a reframing, contrast the old and new interpretations explicitly.]

---

## Why this matters for the paper

[How does this slot into the existing narrative? Does it strengthen, weaken, or reframe an existing claim? Does it open a new section or close a referee-objection avenue?]

---

## Mechanism / interpretation

[The story that explains the result. Be careful to distinguish what the data shows from what the data is consistent with.]

---

## Evidence base

| Source | What it provides |
|---|---|
| `<file path or table>` | <what's there> |
| ... | ... |

---

## Caveats / open questions

- [What this does NOT establish]
- [Specifications that would tighten or test this]
- [Data that would be needed to resolve remaining ambiguity]

---

## Provenance

- Origin: [date and source — chat conversation, prior repo entry, archival source, etc.]
- Linked commits: [git SHAs if known]
- Related progress notes: [other progress_*.md files this connects to]
- Related tables/figures: [t01-t13 etc.]

---

## References / further reading

- [Citation 1]
- [Citation 2]
```

## Style guidance

- **Write for the user three years from now**, not for the user right now. They will have forgotten the chat. The note should stand alone.
- **Translate everything non-English** in line — no "see the German title". Give the English.
- **Cite specific lines/tables** — never "see the analysis"; instead "see `04_tables.do` line 246, or `t13_placebo_panel.tex` row #65".
- **Include numbers** — coefficients, p-values, sample sizes. A note that says "the result is positive and significant" is useless three years from now.
- **Keep history visible** — if a finding evolved, show the evolution. "Initially we thought X. After Y, we now think Z."
- **One note per major change**. Don't bundle. The point is searchability and provenance.

## What this skill is NOT for

- Routine code edits (use git commits)
- Bug fixes (use UPGRADE_LOG.md)
- Stata gotchas (use `.claude/rules/stata-gotchas.md`)
- Validation reports (use `/validate`)
- Phase reviews (use `/phase-review`)

## Reminder to self (Claude)

This skill creates a SINGLE PERMANENT FILE per invocation. Do not append to an existing progress note even if the topic seems related — start a new one. Each note is a snapshot of a moment of intellectual progress; the chronology is the value.
