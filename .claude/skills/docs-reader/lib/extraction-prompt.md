# Extraction Subagent Prompt Template

This is the prompt template the parent passes to a subagent when invoking docs-reader for the first time on a given Stata manual. Customize the placeholders before dispatching.

---

You are extracting a Stata manual into a Stata-specific reference markdown. Do not summarize or paraphrase syntax — extract verbatim. Compression is for prose only.

## Inputs

- **Manual name**: `<MANUAL_NAME>` (e.g., `u`, `d`, `r1`, `xt`)
- **PDF path**: `<PDF_PATH>` (e.g., `guides/sources/pdfs/u.pdf` or `C:/Program Files/StataNow19/docs/d.pdf`)
- **Output path**: `guides/sources/pdfs/<MANUAL_NAME>_text.md`
- **Page range**: `<PAGE_RANGE>` (e.g., `1-50` for full small manual, or `120-145` for targeted extraction of one command)

## Procedure

1. Read the PDF in 4-page chunks using the Read tool's `pages` parameter:
   - `Read(file_path="<PDF_PATH>", pages="1-4")`
   - `Read(file_path="<PDF_PATH>", pages="5-8")`
   - …continue until the requested range is covered.
2. For each chunk, identify command or topic boundaries (look for section headers, command names in monospace, "Syntax" labels).
3. Apply the Stata extraction template to each command/topic:

```markdown
## <command name or topic>

**Syntax:** <one-line syntax summary, monospaced>

**Options:**
- `option1` — what it does
- `option2` — what it does

**Stored results:**
- `e(name)` / `r(name)` — what it holds

**Examples:**
\`\`\`stata
<minimal working example, ideally from the manual>
\`\`\`

**Gotchas:**
- <pitfall #1>
- <pitfall #2>

**See also:** <related commands or sections>
```

4. Discard:
   - Prose framing not specific to syntax or behavior
   - Historical context, citations, theoretical derivations
   - Long tables of asymptotic results
   - Marketing-style introductions

5. Concatenate all extracted sections into a single markdown file at the output path. Sort by command name alphabetically. Add a top-of-file metadata block:

```markdown
# <Manual Title> — Stata Extract

_Extracted: <YYYY-MM-DD>_
_Source: <PDF_PATH>_
_Pages: <PAGE_RANGE>_
_Manual: <MANUAL_NAME>.pdf_

---

[content here]
```

6. **Return** the output path and a 2-line summary: how many commands/topics were extracted and any pages that were skipped or unreadable.

## Constraints

- Maximum 4 pages per Read call. Do not exceed.
- Maximum 3 chunks (12 pages) read in one batch. If more is needed, finish writing the current batch's content to disk before reading more.
- Stata syntax often uses overstrike or special PostScript characters — if the Read output looks garbled for a passage, note it in a `<!-- garbled -->` comment rather than guessing.
- If a section's syntax block spans a page break, include the full block from both pages.

## What success looks like

The output file is a complete reference for the requested page range, formatted consistently, with code blocks that can be pasted into a `.do` file with no modification beyond filling in user-specific variable names. A reader who has never opened the PDF should be able to use the extract to write correct Stata code.

## What failure looks like

- The output is paraphrased instead of verbatim.
- Code blocks are incomplete or have placeholder ellipses where the manual showed full syntax.
- Multiple commands are conflated under one heading.
- The metadata block at the top is missing or incomplete.
