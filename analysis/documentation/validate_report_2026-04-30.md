# /validate report — 2026-04-30 (post-commit, post-phase-review)

**Mode**: strict
**Files scanned**: 11 (.do + .R under analysis/)
**Tool**: ad-hoc runner mirroring `.claude/hooks/pre-edit-validator.sh` against every rule script in `.claude/hooks/rules/{hard,soft,advisory}/`.

---

## Summary counts

| Tier | Findings | Files affected | Real issues |
|---|---|---|---|
| HARD | 0 | 0 | 0 |
| SOFT | 8 | 6 | 2 (rest are template / false-positive) |
| ADVISORY | 9 | 7 | 2 (rest are template / hook bugs) |
| CONTEXT.md | PASS | — | — |

**Net assessment**: clean. No blocking violations. Two real soft items + two real advisories worth addressing later (none urgent enough to block commit).

---

## [HARD] 0 violations

All 7 hard rules pass on all 11 files:
- 01-data-immutable, 02-no-hardcoded-paths, 03-no-backslashes, 04-config-exclusivity, 05-numbered-scripts, 06-version-statement, 07-no-ssc-install — all green.

---

## [SOFT] 8 violations across 6 files

### Real issues (2)

| Rule | File | Finding | Action |
|---|---|---|---|
| 14-units-in-labels | `02_clean.do:60-64` | `vineyard_1877..1913` labels DO contain units ("hectares") — false positive on the regex, but `vineyard_per_cap` label (line 142) and `wine_canton` (line 223) are correctly unitised. | None — false positive; rule's regex doesn't recognize parenthetical units after the label string. |
| 14-units-in-labels | `02_clean.do:205-218` | `absinthe_dummy*` and `lang_*` labels lack `// no-unit-needed` inline marker (they're dummies, no unit applies). | Optional: add `// no-unit-needed` comments per rule guidance. Cosmetic. |

### False positives (4)

| Rule | File | Why false positive |
|---|---|---|
| 11-set-seed | `04_tables.do` | Regex matches "sample" in comments at lines 273-276 (`sample size` in display strings). No actual `sample`/`runiform`/`rnormal` call. |
| 11-set-seed | `05_expansion.do` | Regex matches "sample" in footnote text at line 433 (`uses the full sample`). No actual random-function call. |
| 14-units-in-labels | `01_import.do` (~17 labels) | Most flagged labels contain parenthetical units (e.g., `"Vineyard area (hectares)"`, `"Resident population (persons, 1900 census)"`). Rule regex doesn't parse `(...)` as units. |
| 14-units-in-labels | `04_tables.do` (~6 labels) | Flagged labels are display labels for table-building tempvars (`Variable`, `Min`, `Max`, `N`) — units don't apply. |
| 14-units-in-labels | `05_expansion.do` (~9 labels) | Same as above — `var` and `Variable` display labels for tempvars. |

### Template-shipped (2)

| Rule | File | Note |
|---|---|---|
| 15-naming-conventions | `_install_R_packages.R` | Capital R/P — template ships this name. Out of scope to rename. |
| 15-naming-conventions | `regressions.R` | Capital R from the `.R` extension — same template-ship. |

---

## [ADVISORY] 9 warnings across 7 files

### Real issues (2)

| Rule | File | Finding | Action |
|---|---|---|---|
| 23-suffix-conventions | `02_clean.do:242-243` | `ln_vineyard` and `ln_vineyard_1894` are `log(x+1)` transforms but use `ln_` prefix (per CLAUDE.md convention) instead of the `_lnp1` suffix from gotchas. | Defensible: `ln_` is more readable and the project uses prefix-naming. The `_lnp1` suffix is Ouellet/Toffel guidance, not a hard project rule. Leave as-is, or rename if you want strict suffix-convention compliance. |
| 26-codebook-staleness | `04_tables.do` | Reports "11 new variable(s) created but no `_codebook_update`". | Defensible carve-out: tables script doesn't produce a `.dta` for codebook to document. Same finding as Phase Review R8. |

### Hook bugs (4)

| Rule | File | Bug |
|---|---|---|
| 26-codebook-staleness | `run.do`, `_config.do`, `_install_stata_packages.do`, `_template_script.do` | Bash error: `[: 0\n0: integer expression expected` at line 10 of the hook. The hook tries to integer-compare an output that has trailing newline. Template bug — not a project finding. |

### Template / shipped (2)

| Rule | File | Note |
|---|---|---|
| 20-script-header | `run.do` | Missing Author/Purpose/Date — template ships `run.do` without those fields. Project shouldn't add them; `run.do` is orchestration not analysis. |
| 21-section-banners | `_install_stata_packages.do` | 153 lines without banners — template-shipped. |

### Pattern-matching false positive (1)

| Rule | File | Why false positive |
|---|---|---|
| 23-suffix-conventions | `05_expansion.do:523` | Matches `log(ha+1)` inside footnote text describing column 4 of the alt-vineyard table. Not a variable definition. |

---

## CONTEXT.md completeness

PASS. All 5 required fields populated; no `[ FILL IN ]` placeholders detected.

---

## Hook-file pattern bug (cross-cutting)

Three rule scripts use file-globs that match **single-digit** prefixes only and miss our 2-digit-prefixed scripts:

| Rule | Glob | Matches `01_*.do`? |
|---|---|---|
| `advisory/20-script-header.sh` | `*/[0-9]_*.do` | ✗ no |
| `advisory/24-label-data-source.sh` | `*/1_*.do\|*/[0-9]*_process_*.do\|*/[0-9]*_import_*.do` | ✗ partial — only matches `_process_` / `_import_` |
| `soft/13-assert-statements.sh` | `*/[0-9]_make_tables*.do\|*/[0-9]_tables*.do\|*/[0-9]_figures*.do\|*/[0-9]_paper*.do\|*/[0-9]_results*.do` | ✗ no — won't catch `04_tables.do` |

These hooks **silently skip** our scripts because the glob requires a single-digit prefix. The scripts that DO use `[0-9]*_*.do` (with the `*`) work correctly: `hard/05-numbered-scripts.sh`, `hard/06-version-statement.sh`, `soft/10-varabbrev.sh`.

**Impact**: The `04_tables.do` advisory check for missing `assert` statements (rule 13) was silently skipped. Inspection: 04_tables.do has 8 assertions (sec 6, lines 226-281), so the rule would have passed anyway — but future tables scripts won't be checked.

**Recommendation**: Open a template upstream issue to widen these globs to `[0-9]*_*.do` to support 2-digit zero-padded prefixes (which the project naming rule in CONTEXT.md mandates).

---

## Comparison to earlier validate report (15:21 today)

| Metric | Earlier today (pre-fixes) | Now (post-commit) |
|---|---|---|
| HARD | 0 | 0 |
| SOFT | (similar) | 8 |
| ADVISORY | (similar) | 9 |

No new violations introduced by the post-commit edits (04_tables.do comment fix, clean_vars.ado addition, HANDOFF references).
