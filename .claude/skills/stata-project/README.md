# stata-project skill (placeholder)

This directory is reserved for a future thin **project-level** Stata skill that adapts dylantmoore/stata-skill's tiered progressive disclosure architecture (SKILL.md → reference/ → technique-guides/) for this specific replication template.

## Why a placeholder?

The user's existing user-level skill at `~/.claude/skills/stata/` already provides general Stata guidance. A project-level skill would only add value if it specialized to this repo's conventions (Reif/Ouellet/Toffel rules, codebook protocol, inventory protocol, vendored package list, etc.).

## When to populate

Populate when:
- Multiple coauthors clone the repo and lack the user-level skill
- Project-specific patterns emerge that aren't in the user-level skill
- The escalation chain consistently hits gaps that should be project-resident

## How to populate

1. Create `SKILL.md` modeled on `guides/sources/stata-skill-ref/SKILL.md` — keep it terse (~120 lines), with a routing table.
2. Add `reference/` directory with topic-specific files (100-150 lines each).
3. Add `technique-guides/` for end-to-end workflows.
4. Mine `guides/sources/stata-skill-ref/` heavily — that's exactly the source you adapted earlier.

For now: leave empty. The escalation chain in CLAUDE.md (help → stata-gotchas.md → guides/sources → docs-reader) is sufficient.
