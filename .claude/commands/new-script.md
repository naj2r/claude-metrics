---
description: Scaffold a new numbered .do script from the template
argument-hint: "<number> <slug-with-underscores>"
---

# /new-script

Create a new top-level numbered `.do` file at `analysis/scripts/<N>_<slug>.do` from `analysis/scripts/programs/_template_script.do`.

## Arguments

- `<number>` — integer (next available, or specified)
- `<slug>` — short snake_case description (e.g., `robustness`, `summary_stats`, `figure_main`)

## Action

1. Verify the slug is lowercase with `[a-z0-9_]` only (hard rule 05 will block otherwise).
2. Verify no script with that number already exists.
3. Read `analysis/scripts/programs/_template_script.do`.
4. Substitute placeholders:
   - `[NN]_[description].do` → `<N>_<slug>.do`
   - `[Author name]` → ask user if not in CONTEXT.md
   - `[YYYY-MM-DD]` → today's date
   - `[Your code here]` → empty placeholder section
5. Write to `analysis/scripts/<N>_<slug>.do`.
6. Confirm to user with the path and a one-line preview of the header.

## Hooks that will fire

- Hard rule 05 (numbered-scripts naming) — should pass
- Hard rule 06 (version statement) — passes because template includes `version 19`
- Soft rule 10 (varabbrev) — passes if template sources `_config.do`
- Advisory 20 (script-header) — passes because template has Author/Date/Purpose

## Reminder

After scaffolding, you (Claude) should NOT auto-fill the analysis logic. Wait for the user to describe what the script should do.
