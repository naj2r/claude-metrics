# Stata Critical Rules (Always-In-Context)

When writing or editing `.do` files, ALWAYS follow these rules. They are loaded into every Claude Code session via CLAUDE.md include.

## Top 10 hard-won pitfalls

1. **NEVER** compare with `>`, `<`, `>=`, `<=` without also `& !missing(varname)` — missing values are +infinity in Stata.
2. **NEVER** use `merge` without immediately checking `tab _merge` (or `assert _merge==3` etc.) and handling unmatched observations.
3. **NEVER** use `=` for comparison — use `==` (single `=` is assignment).
4. **NEVER** use `by varname:` without prior `sort` — use `bysort varname:` instead.
5. **ALWAYS** use backtick-quote for local macros: `` `localname' `` — not `$localname` (that's globals).
6. **ALWAYS** pair `preserve` with `restore` (or `restore, not` to keep changes).
7. **ALWAYS** use `tempvar` / `tempfile` for temporary objects — never leave them behind.
8. **ALWAYS** check `_rc` after `capture` — it swallows errors silently.
9. **PREFER** `reghdfe` for fixed-effects regression over `areg` or manual dummies.
10. **PREFER** `graph export` over `graph save` for publication figures (export produces PDF/PNG).

## Estimation safety

- Store estimates with `estimates store <name>` **before** running the next model — `e()` gets overwritten.
- Estimate-store names must be ≤32 characters (Stata hard limit).
- Use `i.` prefix for categorical variables in regressions — bare numeric vars are treated as continuous.
- Use `///` for line continuation, not `\`.

## File I/O and macro safety

- **NEVER write literal backticks (`` ` ``) into files that another Stata script will later `file read`.** Stata's macro substitution treats any `` `...' `` pattern as a macro reference, even inside `macval()` and compound quotes (`` `"..."' ``). When you read back a line containing backticks (e.g., markdown code-quoted text from a previously generated `codebook.md`), Stata fails with `r(132) too few quotes`.
  - **Symptom**: `_codebook_update` (or any program that round-trips a markdown file) crashes on the second invocation, succeeding only the first time.
  - **Fix**: in markdown output, use bold (`**path**`) or HTML `<code>path</code>` instead of backtick code-quotes. Reserve backticks for human-only docs that no Stata program will read back.
  - **Symmetric rule for input**: when reading user-provided text via `file read`, sanitize backticks before passing through `macval()` or compound quotes.

## Project-specific

- All paths reference `$MyProject` (defined in `run.do`). Never hardcode.
- Forward slashes only in pathnames — backslashes are escape characters in Stata.
- The `data/` folder is **immutable**. Only `processed/` and `results/` are writable.
- All add-on packages live in `analysis/scripts/libraries/stata/`. Never `ssc install` inline — use `/add-package`.
- Numbered scripts use the `N_description.do` pattern. New scripts go through `/new-script`.
- Each script ends with a post-credits block that calls `_codebook_update` and `_inventory_append`. See template at `analysis/scripts/programs/_template_script.do`.

## Independent (background / batch) vs manual (interactive) Stata runs

When invoking Stata **independently** — i.e. via `/e do` batch mode, a background `run_in_background: true` Bash call, a cmd.exe `.bat` wrapper, or any path where the Claude/automation layer does not have a human at the keyboard — the wrapper `.do` file MUST set the following BEFORE sourcing the project pipeline:

```stata
* Suppress graph windows. Stata /e batch mode on Windows still pops graph
* windows for `twoway`, `marginsplot`, `histogram`, etc. The graph window
* stealing focus interrupts the batch and produces "test_full_pipeline.do
* has been interrupted. Continue?" modal dialogs that pile up across runs.
* `set graphics off` suppresses all graph window display; `graph export`
* still writes the PDF/PNG to disk normally.
set graphics off

* Pre-erase regenerable intermediate .dta files to prevent the
* "Replace existing file?" modal dialog when a prior run was interrupted
* and left files partially written. Source data in $MyProjectData is NOT touched.
foreach f in <list of regenerable intermediates> {
    cap erase "$MyProject/results/intermediate/`f'"
}
```

When invoking Stata **manually** in an interactive session (the human is at the keyboard, the GUI is open, graphs and dialogs are wanted), do NOT add `set graphics off` — graphs should display in the GUI as expected, and the user can answer "Replace existing file?" prompts directly.

The distinction is operational: graph windows are useful when a human can see them; they are batch-poisonous when a human cannot. Each Stata invocation must explicitly choose one mode. The default for the Claude automation layer is **independent / batch mode**, so the wrapper `.do` files used by Claude (e.g. `test_full_pipeline.do`) MUST include both lines above.

## Section navigation (do-file editor bookmarks)

Use Stata's **`**#` bookmark syntax** for section headings. Lines starting with `**#` become navigable bookmarks in the do-file editor (View > Bookmarks).

Number sections **chapter-style**: `0.`, `1.`, `1.1`, `1.2`, `2.`, etc. — like a book outline.

Wrap long code chunks in `{ ... }` braces so they're foldable in the editor:

```stata
**# 1. Load data
*------------------------------------------------------------------------------*
{
    use "$MyProject/processed/auto.dta", clear
    * ...long block...
}

**# 1.1 Clean values
*------------------------------------------------------------------------------*
{
    * ...
}
```

The header rule (`*-----*`) is decorative; the `**#` line is what Stata indexes as a bookmark.

## Variable suffix conventions (Ouellet/Toffel §7a)

- `_cat` — categorical (binned from continuous)
- `_mz` — missing-recoded-to-zero
- `_mm` — missing-recoded-to-mean
- `_miss` — binary indicator (1 = imputation/recode applied)
- `_ln` — natural log
- `_lnp1` — natural log of (x+1)

Variable names should imply their coding (`female` not `gender`, `log_employment` not `size`).
