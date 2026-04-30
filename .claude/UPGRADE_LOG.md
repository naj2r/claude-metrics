# UPGRADE_LOG

When Claude encounters a knowledge gap during a session — a Stata command not covered by the always-in-context rules, an unexpected behavior, a missing reference — log it here. Periodic review by the user turns logs into permanent improvements (updates to `.claude/rules/stata-gotchas.md`, `guides/sources/`, or new entries in the codebook).

## Format

```
## YYYY-MM-DD — <topic> — <gap description> — <suggested addition>
```

- **YYYY-MM-DD**: today's date in ISO format
- **topic**: command name, concept, or area (e.g., `reshape`, `merge with str variable`, `coefplot options`)
- **gap description**: what was missing or unexpected (1-2 sentences)
- **suggested addition**: where to add it and what to add (file path + content)

## Examples

```
## 2025-08-15 — reshape long with i() prefix — Reshape failed with cryptic error when i() variable was string and j had non-numeric values. — Add gotcha to .claude/rules/stata-gotchas.md noting that reshape requires j() to be numeric or an explicit string() option.

## 2025-09-02 — coefplot xline option — coefplot's xline() didn't work with vertical orientation; needed yline() instead. — Add to guides/sources/stata-skill-ref/reference/graphics.md under coefplot section.
```

## Review cadence

Suggested: every ~10 entries or every 2 weeks, whichever comes first. Use `/review-upgrade-log` to surface entries.

---

## Entries

<!-- Append entries here. Newest at top. -->
