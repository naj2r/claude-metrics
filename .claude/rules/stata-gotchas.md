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

## `local x "..."` vs `local x = "..."` — expression-evaluation gotcha

Stata's `local` command has two different parse modes:

- `local x "...stuff..."` — Stata stores the literal text. **Backtick macros** (`` `name' ``) inside the string DO expand at parse time (macro substitution happens during scanning). But **expression operators** (`+`, function calls like `string()`, `substr()`, `subinstr()`, `format()`, `cond()`, `e()`, `r()`, `trim()`) are NOT evaluated — they get stored as literal text.
- `local x = "...stuff..."` — Stata evaluates the RHS as a string expression. Operators and function calls execute.

**The trap**: a footnote-style local that mixes literal text with embedded `+ string(...)` calls looks plausible without the `=`, but stores the literal text including the `+` and `string(...)` characters. When that local is later interpolated into a context like `texsave footnote("`fn'")`, the literal `"` characters inside `string(..., "%5.3f")` close the `footnote()` option early and texsave throws `r(198) Invalid syntax for footnote() option` — with a confusing 4000-character message that hides the one missing `=`.

**Known instances in this repo**:
- `analysis/scripts/05_expansion.do` line 2216 (`t19_cleavage_index` footnote with per-vote rho values) — **fixed** at commit `b885f8a`.
- `analysis/scripts/05_expansion.do` line 1877 (`t15_gelbach` footnote with `` `b_base_str' `` etc.) — **preventively converted** to use `=` even though it would work without (the current RHS uses only bare backtick macros that expand at parse time; the `=` is defensive against future edits that might add `+ string(...)`).

**Rule**: when a footnote local contains ANY of: `string(`, `substr(`, `subinstr(`, `cond(`, `e(`, `r(`, `format(`, `trim(`, `+ ` (string concat), use `local x = "..."`. When the RHS is pure literal text plus bare backtick macros, either form works — but the `=` form is defensive and recommended.

## File I/O and macro safety

- **NEVER write literal backticks (`` ` ``) into files that another Stata script will later `file read`.** Stata's macro substitution treats any `` `...' `` pattern as a macro reference, even inside `macval()` and compound quotes (`` `"..."' ``). When you read back a line containing backticks (e.g., markdown code-quoted text from a previously generated `codebook.md`), Stata fails with `r(132) too few quotes`.
  - **Symptom**: `_codebook_update` (or any program that round-trips a markdown file) crashes on the second invocation, succeeding only the first time.
  - **Fix**: in markdown output, use bold (`**path**`) or HTML `<code>path</code>` instead of backtick code-quotes. Reserve backticks for human-only docs that no Stata program will read back.
  - **Symmetric rule for input**: when reading user-provided text via `file read`, sanitize backticks before passing through `macval()` or compound quotes.

## File-write formatting gotchas

Three traps that recur when generating LaTeX tables or text files via `file write` (or via locals pre-formatted for later string interpolation):

### 1. `%+N.Mf` is NOT a valid Stata format

Stata's `format` and `display` specifiers do **not** support the `+` flag for forced sign prefix on positive numbers (unlike C/Python printf). The format `%+6.2f` returns `r(120) invalid %format` at runtime.

**Workaround**: format normally, then manually prepend `"+"` for positive values:

```stata
local v_str = trim(string(`val', "%5.2f"))
if `val' >= 0 local v_str = "+" + "`v_str'"
```

Use this pattern when visual contrast between signed values matters (e.g., a "delta" or "change" row where positives should read `+3.52` rather than `3.52`).

### 2. Defensive `cap file close <handle>` before every `file open`

If a prior Stata run aborted (error, interrupt, OS crash) while a file handle was open, the handle remains attached to its file. The next `file open <handle>` fails with `r(610)` or `r(603)`. Subsequent re-runs of the script then can't recover without manual `file close`.

**Pattern**: always pair `file open` with a preceding `cap file close`:

```stata
cap file close myfh
file open myfh using "$MyProject/output/path.md", write replace
file write myfh "..." _n
file close myfh
```

The `cap` form suppresses the "file handle not open" error on fresh runs where the handle was never opened. Purely defensive — costs nothing on healthy runs, recovers automatically on aborted-prior-run scenarios.

### 3. `file write` does NOT accept inline format specs

Unlike `display`, the `file write` command does not parse `%N.Mf` specifiers in its argument list. The following silently writes the literal text `%5.2f` rather than the formatted number:

```stata
file write myfh "value = " %5.2f `val' _n   // BUG: writes literal '%5.2f'
```

**Workaround**: pre-format the value into a local via `: di` or `string()`, then write the local:

```stata
local v_str : di %5.2f `val'
file write myfh "value = `v_str'" _n         // writes "value = 44.40"
```

Equivalent with the `=` assignment form (preferred when concatenating with `+`):

```stata
local v_str = string(`val', "%5.2f")
file write myfh "value = `v_str'" _n
```

Found during C.16 (07_substrate_descriptives.do § 9d) and C.6c (05_expansion.do § 12.15) work, May 2026.

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
* and left files partially written. Source data in $Absinthe1Data is NOT touched.
foreach f in <list of regenerable intermediates> {
    cap erase "$Absinthe1/results/intermediate/`f'"
}
```

When invoking Stata **manually** in an interactive session (the human is at the keyboard, the GUI is open, graphs and dialogs are wanted), do NOT add `set graphics off` — graphs should display in the GUI as expected, and the user can answer "Replace existing file?" prompts directly.

The distinction is operational: graph windows are useful when a human can see them; they are batch-poisonous when a human cannot. Each Stata invocation must explicitly choose one mode. The default for the Claude automation layer is **independent / batch mode**, so the wrapper `.do` files used by Claude (e.g. `test_full_pipeline.do`) MUST include both lines above.

## MCP-Stata process leak (Windows-specific)

`python -m mcp_stata` embeds Stata in-process via `pystata` and uses `multiprocessing.spawn` for worker isolation. On Windows, when the parent dies (Claude Code restart, OS crash, `taskkill`), its multiprocessing children are **NOT auto-cleaned** — Windows has no equivalent of Linux's `PR_SET_PDEATHSIG`. Each orphaned child holds:

- ~140 MB of resident memory (pystata + Stata loaded in-process)
- A claim on the single-user Stata license

After a few interrupted sessions, orphans accumulate. The next `mcp_stata` invocation appears to wedge — `di "hello"` over MCP hangs for minutes because pystata is blocked waiting for a license slot. Symptoms:

- MCP `run_command` hangs on trivial commands
- Batch `/e do <pipeline>` triggers cascading "Replace existing file?" or "...has been interrupted. Continue?" dialogs (multiple Stata instances competing for the same files)
- Stata GUI refuses to launch with "license in use" or similar

**Detection** (PowerShell):

```powershell
Get-CimInstance Win32_Process -Filter 'Name="python.exe"' |
  Where-Object {
    $_.CommandLine -like '*mcp_stata*' -or
    ($_.CommandLine -like '*multiprocessing-fork*' -and $_.WorkingSetSize -gt 100MB)
  } | Select-Object ProcessId, WorkingSetSize, CommandLine
```

A healthy session shows 1 `mcp_stata` parent + 1 multiprocessing child. More than that means orphans.

**Fix (one-time setup)**: register the safe-launch wrapper instead of calling `python -m mcp_stata` directly. The wrapper lives at `$DROPBOX/Scripts/start_mcp_stata.ps1` and sweeps stale processes before launching. In `~/.claude.json`:

```json
"stata": {
  "type": "stdio",
  "command": "powershell.exe",
  "args": [
    "-NoProfile", "-ExecutionPolicy", "Bypass",
    "-File", "C:\\Users\\jensenn\\Dropbox\\Scripts\\start_mcp_stata.ps1"
  ]
}
```

Equivalent `claude mcp` CLI:

```
claude mcp remove stata --scope user
claude mcp add stata --scope user -- powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\jensenn\Dropbox\Scripts\start_mcp_stata.ps1"
```

After re-registering, restart Claude Code. The wrapper logs cleanup activity to **stderr** (stdout is reserved for MCP JSON-RPC). Look in Claude Code's MCP server logs to see lines like `[start_mcp_stata] killing pid=...` confirming the safeguard fired.

## MCP-Stata transport: backslash mangling in inline code

When running Stata code via `mcp__stata__stata_run` with `code=<inline-string>` (NOT `is_file=True`), **backslash characters in the code are silently converted to forward slashes**. This corrupts:

- LaTeX escape sequences: `\#`, `\_`, `\$`, `\Delta`, `\texttt{...}`, `\ref{...}` all become `/#`, `/_`, `/Delta`, `/texttt{...}`, etc.
- Any other content where `\` is structurally meaningful (regex patterns, etc.)

The conversion appears to be a Windows path-normalization side effect in the MCP transport layer (it pre-processes the code string as if it were a path, converting `\` → `/` for portability). Reading code from a `.do` file on disk bypasses the transform — Stata reads the file directly from disk via `do "path/to/file"`.

**Symptom**: LaTeX tables built via inline `stata_run` contain things like `/Delta`, `/texttt`, `/#68` — all invalid LaTeX commands. Visible only in the resulting `.tex` file; the Stata log shows the corrupted code as it was received (so the log "looks like" it executed `/_` rather than `\_`).

**Workaround**: for any code that contains backslashes (LaTeX content, certain regex patterns, etc.), write the code to a `.do` file first and run via `mcp__stata__stata_run` with `is_file=True`:

```
# Bad: backslashes get mangled
stata_run(code='replace x = "Vote \#68" in 1', is_file=False)

# Good: write to file first, then run
Write(".../_tmp.do", 'replace x = "Vote \#68" in 1\n...')
stata_run(code=".../_tmp.do", is_file=True)
```

For short ad-hoc commands without backslashes, inline mode is fine. For any LaTeX-generating code or anything that contains explicit `\` characters, always go through a file.

Found during C.6c T25 table generation, May 2026.

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
