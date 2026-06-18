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

## Built-in function limits and quirks

### `inlist()` string-arg cap: max 10 args total (variable + 9 values)

For STRING arguments, `inlist(z, s1, s2, ...)` accepts at most 10 args total — the variable plus 9 values. For NUMERIC args, the cap is 255. The error message when over (`r(130) expression too long`) does NOT mention the type-specific cap, so it's easy to assume the script is broken when really you've just exceeded the string limit.

```stata
* BAD: 10 values + 1 variable = 11 args, fails for strings
list ... if inlist(canton_iso, "UR","SZ","OW","NW","LU","ZG","FR","VS","TI","AI")
* r(130) expression too long

* GOOD: split into two OR'd inlist calls
list ... if inlist(canton_iso, "UR","SZ","OW","NW","LU") ///
         | inlist(canton_iso, "ZG","FR","VS","TI","AI")

* ALTERNATIVE: build a categorical flag once, then filter on the flag
gen byte _grp = 0
replace _grp = 1 if inlist(canton_iso, "UR","SZ","OW","NW","LU") ///
                 | inlist(canton_iso, "ZG","FR","VS","TI","AI")
list ... if _grp == 1
```

The flag approach scales to arbitrarily many groupings and makes the grouping intent visible in the data. The OR-chained approach is leaner for one-off filters. Found during `08_setup_cohort_1908.do` religion verification, May 2026.

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

## Comment-block nesting: `/*` inside `/* ... */` is treated as a NESTED open

Stata's parser treats any `/*` substring inside an open block comment as a nested-comment opener. The first `*/` only unwinds ONE level, so everything after stays in comment-mode silently. The script appears to run cleanly (rc=0) but the body never executed — no error, no warning, just nothing happens after the comment block.

**Trigger pattern**: a long header docstring `/* ... */` that contains a glob like `analysis/scripts/*.do` (the `*.do` glob produces a literal `/*` substring inside the open comment) silently consumes the rest of the file as comment text.

**Symptom**: the do-file runs without complaint, but globals don't get set, programs don't get sourced, output files don't appear. Downstream scripts then fail with cryptic errors like `\$MyProject not set` or `_codebook_update not found`.

**Fix**: avoid `/*` substrings inside block comments. Rephrase path examples to use placeholders:
- Bad inside `/* ... */`: `analysis/scripts/*.do`
- Good inside `/* ... */`: `analysis/scripts/NN_slug.do`

Or use line comments (`*` or `//`) for the entire docstring — they don't have nesting behavior. Add a `MAINTAINER NOTE` to any docstring that's been bitten by this so future editors know not to reintroduce the glob.

Found during `stata_absinthe_init.do` session-init helper development, May 2026 (silent rc=0 failure consumed 4+ debug cycles before the `/*` glob was identified as the trigger).

## `subinstr` with literal backslash: `"\"` is parsed as escaped quote (.do-file only)

When a `.do` file is sourced (not typed at the interactive prompt), Stata's parser treats `"\"` as the START of an escaped-quote string literal, NOT as a one-character backslash string. `subinstr("path", "\", "/", .)` then silently aborts the do-file without producing an error message or even reaching the next line.

**Trigger pattern**: any normalization of a Windows path that needs to convert `\` → `/`:

```stata
* This works at the Stata prompt but SILENTLY ABORTS inside a .do file:
global HOME = subinstr("`raw_home'", "\", "/", .)
```

**Symptom**: the `.do` file exits with no error message, no log entry past that line, and no globals set. Downstream code crashes with `\$MyProject not set` or similar. The killer detail: it WORKS perfectly when typed line-by-line at the Stata prompt, so manual debug-stepping doesn't reproduce the failure.

**Fix**: use `char(92)` for the backslash literal:

```stata
local bs = char(92)
global HOME = subinstr("`raw_home'", "`bs'", "/", .)
```

`char(92)` returns the literal backslash character without triggering the parser's escape-quote handling. Same trick works in any string-literal context where you need a backslash inside a `.do` file (regex patterns, file-path manipulation, etc.).

Found during `stata_absinthe_init.do` session-init helper development, May 2026. Distinct from the MCP-Stata-transport backslash mangling documented below (that one corrupts `\` → `/` in inline MCP code; this one is a Stata-native parser quirk affecting any `.do` file regardless of how it's invoked).

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
- **`_codebook_update` is upsert-safe**; **`_inventory_append` is append-only.** `_codebook_update` refreshes the existing entry in `codebook.md` in place (the program looks for a matching dataset path and replaces that section), so it's safe to call on every iteration. `_inventory_append` always appends a new row to `_inventory.xlsx` with no dedupe — calling it on every iteration during dev accumulates duplicate rows that pollute the shared pipeline-state tracker. For scripts that may be iterated repeatedly, gate `_inventory_append` behind `if "${RUN_POSTCREDITS}" == "1"` so canonical inventory rows are added only on release runs (set `global RUN_POSTCREDITS = 1` before `do "<script>"` when you want the canonical row to land).
- **Terminology**: reserve "bootstrap" for econometric resampling (bootstrap SEs, wild-cluster bootstrap, pairs/wild bootstrap, etc.). For script-init mechanisms that load globals or rebuild from a disk checkpoint, prefer "session-init helper", "standalone-run preamble", or "standalone setup" (per `_template_script.do`). Calling a session-init script a "bootstrap" causes confusion in code review and methodology discussion.

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

## Standalone-preamble pattern for chunked iteration (Ctrl+D workflows)

When a script is structured for section-by-section Ctrl+D execution in the do-file editor (the PI development pattern), each `**# N.` section that consumes upstream output should begin with a **standalone-run preamble** that detects partial / empty in-memory state and auto-loads the upstream checkpoint from disk:

```stata
**# 5.0 Standalone-run preamble: load §1-§4 output if memory is empty / re-runnable
{
    cap confirm variable pop_1910         // sentinel = predecessor §4's last-added var
    if _rc {
        cap confirm file "$MyProject/processed/cohort_1908.dta"
        if _rc {
            di as error "  §5 needs §1-§4 output (pop_1910) but cohort_1908.dta not found."
            di as error "  Run §1-§4 first, OR run the whole script end-to-end."
            error 601
        }
        use "$MyProject/processed/cohort_1908.dta", clear
        di as text "  (standalone-run preamble: loaded cohort_1908.dta from disk)"
    }
    foreach v in <vars_this_section_adds> {    // idempotency: drop colliding vars
        cap drop `v'
    }
}
```

### Critical: sentinel choice

The variable in `cap confirm variable <X>` MUST be the **last var added by the immediately-preceding section**, NOT a base-state var like `canton_iso`. The two choices have very different semantics:

| Sentinel | Catches | Misses |
|---|---|---|
| `canton_iso` (base ID) | Empty memory | Partial state from older script version or skipped section |
| Predecessor's last var | Empty memory AND partial state | Nothing (transitively implies full upstream chain) |

**Why predecessor's-last-var works**: in a linearly-built dataset where `§N (save)` writes the union of all sections, the on-disk file always represents the canonical complete state. If the predecessor's last var is missing from memory, the in-memory state is partial — reload from disk to restore the complete chain. If the predecessor's last var IS present, all earlier vars must also be present (linear-build invariant), and no reload is needed.

**Bug 2026-05-18** during `08_setup_cohort_1908.do` chunked review: §5.0 used `canton_iso` as the sentinel, which was present in the PI's session (from an older script version that ran §1+§2+§3 only). §5 proceeded but §6.1 crashed on `assert pop_1900 > 0 & !missing(pop_1900)` because pop_1900 was never loaded. Switching the sentinel to `pop_1910` (§4's last var) made §5.0 auto-load from disk, restoring pop_1900/1910 alongside everything else. Retrofitted to §2.0/§3.0/§4.0/§6.0 for consistency.

### Recommended safeguards for standalone-preamble changes

When you add or modify a standalone-preamble, run BOTH of these regression tests before reporting done:

1. **End-to-end**: `clear all; do "<script>"` — simulates a fresh session with empty memory. The preamble's auto-load branch fires (memory is empty, so the sentinel var is absent). All downstream sections see the freshly-loaded state.
2. **Partial-state**: load the complete output dataset, drop a downstream var family (e.g., `drop pop_1900 pop_1910`), then run the chunk in question. The preamble should detect the missing sentinel and auto-load from disk to restore the dropped vars. If the preamble's sentinel is too weak (e.g., `canton_iso` instead of `pop_1910`), it will NOT trigger the auto-load and the chunk will crash downstream — exactly the bug the partial-state test is designed to catch.

A single end-to-end pass is NOT sufficient: end-to-end always builds from scratch, so all upstream vars are guaranteed present regardless of sentinel weakness. Only the partial-state test surfaces sentinel choice errors. Skip the partial-state test → ship the bug (this is the 2026-05-18 lesson).

### Idempotency: drop section-output vars before re-building

The `foreach v in <vars_this_section_adds> { cap drop `v' }` block at the end of the preamble lets the section be re-run cleanly even if a prior partial run left some of its output vars in memory. Without it, the section's `gen` and `merge` commands will error with "variable already exists" on the second Ctrl+D pass. `cap drop` is no-op if the var doesn't exist, so it costs nothing on fresh runs.

## Variable suffix conventions (Ouellet/Toffel §7a)

- `_cat` — categorical (binned from continuous)
- `_mz` — missing-recoded-to-zero
- `_mm` — missing-recoded-to-mean
- `_miss` — binary indicator (1 = imputation/recode applied)
- `_ln` — natural log
- `_lnp1` — natural log of (x+1)

Variable names should imply their coding (`female` not `gender`, `log_employment` not `size`).
