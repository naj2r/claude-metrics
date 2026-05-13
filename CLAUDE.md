# claude-metrics

Stata/R/Quarto research template. AEA-compliant. Self-enforcing. Forked from `reifjulian/my-project`. **Read before any analytical reasoning.**

## What this is

Template repo. **Never work here directly.** Researchers clone → `/init-project <name>` → work in their project repo. The `master` branch keeps Reif's `auto.csv` demo as a working reference. The `starter` branch is an empty scaffold.

## Read first (every session)

1. **`CONTEXT.md`** — what this specific project is *about* (dataset, unit, outcome, ID strategy, key globals). If empty, ask the user to fill it before any analysis.
2. **`.claude/rules/methodology-integrity.md`** — never trade empirical/methodological precision to solve an engineering/runtime problem; always-loaded behavioral rule with project-specific binding parameters (RI=10k perms, HC3 SEs, etc.). Read this BEFORE relaxing any methodology dial.
3. **`.claude/rules/stata-gotchas.md`** — top critical Stata pitfalls (always loaded).
4. **`.claude/MEMORY.md`** — persistent project facts and `[LEARN]` corrections.

## Rule tiers

| Tier | Behavior | When |
|---|---|---|
| **HARD** (always block) | Hook returns exit 2; tool call denied; Claude self-corrects | data immutability; no hardcoded paths; no backslashes; `_config.do` exclusivity; numbered scripts; version statement; no inline `ssc/net install` |
| **SOFT** (mode-dependent) | `/strict`: block. `/permissive`: warn-only. | `set varabbrev off`; `set seed`; `isid` before sort; `assert` in tables script; units in labels; naming conventions |
| **ADVISORY** (always warn-only) | Stderr message; exit 0 | header format; section banners; operator spacing; suffix conventions; data source in labels; name implies coding; codebook staleness; archive-folder; stata-lint checks |

Current mode: read `.claude/.mode`. Toggle with `/strict` or `/permissive`. UserPromptSubmit hook injects `[Mode: X]` each turn.

## Knowledge lookup (escalation chain — costlier each step)

1. `mcp__stata__get_help <command>` — fast, authoritative for syntax/options
2. `.claude/rules/stata-gotchas.md` — top pitfalls (always loaded)
3. `guides/sources/stata-skill-ref/reference/<topic>.md` — mined dylantmoore content
4. `guides/sources/pdfs/u.pdf_text.md` — User's Guide extract (if exists)
5. **`docs-reader` skill** — generates extract for relevant Stata PDF (subagent isolation)
6. Other PDFs at `C:\Program Files\StataNow19\docs\`
7. Log gap to `.claude/UPGRADE_LOG.md`

**Help-first rule**: before writing code that uses any Stata command for the first time in a session, run `help <command>` via MCP. Do not guess syntax from training data.

**Structural rule**: for macros/locals/scoping/programming questions, read `guides/sources/pdfs/u.pdf` (or invoke `docs-reader`).

## Codebook + inventory protocol

Every numbered script ends with a post-credits block:

```stata
_codebook_update using "$MyProject/processed/<dataset>.dta", script("<N>_<slug>.do")
_inventory_append, sheet("datasets") row("created|processed/<dataset>.dta|`=c(N)'|`=c(k)'|.|<N>_<slug>.do")
```

`run.do` writes to the `runs` sheet at start and end. Never skip post-credits. Use `/update-codebook` and `/inventory-rebuild` to refresh from scratch.

## MCP-default-with-batch-fallback

- Default execution: `mcp__stata__run_do_file`
- Fallback: `Bash(stata-mp -b do <file.do>)` from Git Bash (Windows uses `.bat` workaround for `/e` flag)
- `/run-stata` chooses automatically

[**MCP server config to be added by user from another repo**]

## R-adjacent notes

Same hard rules apply to `.R` files (no hardcoded paths, no escape-character pathnames N/A). R packages installed via `_install_R_packages.R` (not vendored). `rscript` ado-file calls R from Stata with version checking.

## Slash commands

`/strict` `/permissive` `/new-script` `/validate` `/add-package` `/run-stata` `/init-project` `/update-codebook` `/inventory-rebuild` `/review-upgrade-log`

## Critical-paths reminder (no hardcoded paths in code)

- All paths reference `$MyProject` (set in `run.do`, propagated via `_config.do`).
- Forward slashes only in `.do` files (backslash is escape character).
- `analysis/data/**` is **immutable**. Write only to `processed/` and `results/`.
- Vendored packages live in `analysis/scripts/libraries/stata/`. Never `ssc install` inline.

## When stuck

`mcp__stata__get_help` → `stata-gotchas.md` → `guides/sources/` → `docs-reader` skill → log to `UPGRADE_LOG.md`. Don't guess.
