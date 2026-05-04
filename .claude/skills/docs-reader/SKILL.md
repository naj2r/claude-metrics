---
name: docs-reader
description: Extract Stata PDF manuals into queryable markdown. Use when help-via-MCP and stata-skill-ref are insufficient — typically for structural questions, edge-case syntax, or topics not covered by SSC help files. Adapted from Cunningham's split-pdf for reference querying rather than linear reading.
---

# docs-reader skill

## When to invoke

Use this skill **after** the cheaper escalation steps fail:

1. `mcp__stata__get_help <command>` — fast path, always first
2. `.claude/rules/stata-gotchas.md` — top critical pitfalls
3. `guides/sources/stata-skill-ref/reference/<topic>.md` — mined dylantmoore content
4. `guides/sources/pdfs/<manual>_text.md` if exists — prior extract
5. **← INVOKE docs-reader HERE if no extract exists for the relevant manual**
6. Last resort: ad-hoc Read of the raw PDF

Trigger conditions:
- `help` output is ambiguous, missing, or doesn't address the question
- Structural questions about macros, locals, scoping, do-file behavior, programs (→ `u.pdf`)
- Edge-case syntax for a specific command (→ command-letter manual)
- Mata, plugins, or programming internals (→ `m.pdf`, `p.pdf`)

## What this skill does

**On first invocation for a manual**: extracts the PDF into a structured markdown file using the Stata extraction template. Writes to `guides/sources/pdfs/<manual>_text.md`. One-time cost per manual.

**On subsequent invocations**: reads the existing `_text.md` directly. Never re-extracts.

## Stata extraction template

For each command or topic encountered in the manual, extract:

```markdown
## <command name>

**Syntax:** <one-line syntax summary, monospaced>

**Options:**
- `option1` — what it does
- `option2` — what it does
...

**Stored results:**
- `e(name)` / `r(name)` — what it holds
...

**Examples:**
\`\`\`stata
<minimal working example, ideally from the manual>
\`\`\`

**Gotchas:**
- <pitfall #1>
- <pitfall #2>
...

**See also:** <related commands or sections>
```

Discard prose framing, historical asides, theoretical derivations that won't help generate code.

## Manuals reference

| Manual | File | Content | Path |
|---|---|---|---|
| User's Guide | `u.pdf` | Macros, locals, scoping, do-files, programs | `guides/sources/pdfs/u.pdf` (copied) |
| Data Management | `d.pdf` | merge, append, reshape, encode, etc. | `C:\Program Files\StataNow19\docs\d.pdf` |
| Base Reference A-H | `r1.pdf` | Commands A-H | `C:\Program Files\StataNow19\docs\r1.pdf` |
| Base Reference I-Z | `r2.pdf` | Commands I-Z | `C:\Program Files\StataNow19\docs\r2.pdf` |
| Programming | `p.pdf` | Ado-files, programs, advanced | `C:\Program Files\StataNow19\docs\p.pdf` |
| Mata Reference | `m.pdf` | Mata language | `C:\Program Files\StataNow19\docs\m.pdf` |
| Longitudinal/Panel | `xt.pdf` | xtreg, xtset, panel commands | `C:\Program Files\StataNow19\docs\xt.pdf` |
| Time Series | `ts.pdf` | tsset, arima, var, etc. | `C:\Program Files\StataNow19\docs\ts.pdf` |
| Survey Data | `svy.pdf` | svy commands | `C:\Program Files\StataNow19\docs\svy.pdf` |

If a manual is unavailable at the install path (Mac/Linux coauthor), fall back to `mcp__stata__get_help` and log the gap to `.claude/UPGRADE_LOG.md`.

## Invocation pattern

Delegate the extraction to a subagent so the parent conversation does not accumulate raw PDF content:

1. **Check existence**: does `guides/sources/pdfs/<manual>_text.md` exist?
   - Yes → read it directly, return relevant section.
   - No → continue to step 2.

2. **Spawn extraction subagent**: dispatch a `general-purpose` agent with a self-contained prompt:
   - Resolve the PDF path (prefer `guides/sources/pdfs/<manual>.pdf`, fall back to install path).
   - Read the PDF in 4-page chunks using the Read tool's `pages` parameter (e.g., `pages: "1-4"`, then `5-8`, etc.).
   - Apply the Stata extraction template to each chunk.
   - Concatenate and write to `guides/sources/pdfs/<manual>_text.md`.
   - Return the path of the new extract.

3. **Read the new extract**: open `<manual>_text.md` and find the relevant section.

4. **If gap remains**: log to `.claude/UPGRADE_LOG.md` with format:
   ```markdown
   ## YYYY-MM-DD — <topic> — <manual> — <gap description> — <suggested addition>
   ```

## Targeted extraction (preferred for large manuals)

For manuals over 200 pages (e.g., `r1.pdf`, `r2.pdf`, `m.pdf`), prefer **targeted extraction**:
- Identify the specific command or topic page range first (use the manual's table of contents or grep for a heading).
- Extract only those pages.
- Append to `<manual>_text.md` under a clear section header.
- Subsequent queries extend the same file rather than re-extracting from scratch.

## What NOT to do

- Don't read the raw PDF in the parent conversation. Always delegate to a subagent.
- Don't extract everything from a manual when you only need one command.
- Don't paraphrase or interpret — extract verbatim where syntax is shown. Compression is for prose, not signatures.
- Don't write extracts anywhere except `guides/sources/pdfs/<manual>_text.md`.
- Don't modify already-extracted files unless reconciling a documented Stata version change.

## Files maintained by this skill

- `guides/sources/pdfs/<manual>_text.md` — generated extracts (one per manual queried)
- `.claude/UPGRADE_LOG.md` — appended-to when gaps are found
