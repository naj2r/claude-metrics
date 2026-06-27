# Hooks reference (3-tier rule system)

All hooks live in `.claude/hooks/`. Registered in `.claude/settings.json`.

## Rule tiers

### Hard rules — `.claude/hooks/rules/hard/`

Always block on violation, regardless of mode.

| Script | Rule |
|---|---|
| `01-data-immutable.sh` | `analysis/data/**` immutable |
| `02-no-hardcoded-paths.sh` | No absolute paths in .do/.R |
| `03-no-backslashes.sh` | No backslashes in path strings in .do |
| `04-config-exclusivity.sh` | `_config.do` is sole setter of `$MyProject` etc. |
| `05-numbered-scripts.sh` | Top-level scripts match `^[0-9]+_[a-z0-9_]+\.do$` |
| `06-version-statement.sh` | `version N` required in run.do, top-level scripts, _config.do |
| `07-no-ssc-install.sh` | No `ssc install`/`net install` outside `_install_stata_packages.do` |

### Soft rules — `.claude/hooks/rules/soft/`

Block in strict mode, warn in permissive mode.

| Script | Rule |
|---|---|
| `10-varabbrev.sh` | `set varabbrev off` should be set |
| `11-set-seed.sh` | `set seed N` if random functions used |
| `12-isid-before-sort.sh` | `isid` or `, stable` before sort |
| `13-assert-statements.sh` | `assert` in tables/figures script |
| `14-units-in-labels.sh` | Variable labels include units (heuristic) |
| `15-naming-conventions.sh` | New file/folder names lowercase + `[a-z0-9_-]` |

### Advisory rules — `.claude/hooks/rules/advisory/`

Always warn-only, never block.

| Script | Rule |
|---|---|
| `20-script-header.sh` | Header with Author/Date/Purpose |
| `21-section-banners.sh` | Banner separators in long scripts |
| `22-operator-spacing.sh` | Spaces around operators |
| `23-suffix-conventions.sh` | `_ln`, `_mz`, `_mm`, `_cat`, `_lnp1`, `_miss` suffixes |
| `24-label-data-source.sh` | Labels mention data source for external vars |
| `25-name-implies-coding.sh` | `female` not `gender`, `log_X` not `size` |
| `26-codebook-staleness.sh` | New vars without _codebook_update call |
| `27-archive-folder.sh` | Heavy edit → suggest archive copy |
| `28-stata-lint-checks.sh` | Wrapper for stata-lint.sh |

## Hook events

| Event | Hook | Purpose |
|---|---|---|
| `UserPromptSubmit` | `inject-mode-context.sh` | Prepend `[Mode: X]` to context |
| `PreToolUse` (Edit/Write/MultiEdit) | `pre-edit-validator.sh` | Run all rule tiers in order |
| `PostToolUse` (Edit/Write/MultiEdit) | `post-edit-codebook-advisory.sh` | Remind about codebook refresh |
| `PostToolUse` (Edit/Write/MultiEdit) | `stata-lint.sh` | 5 stata-skill checks |
| `PostToolUse` (Edit/Write/MultiEdit) | `post-edit-log.sh` | Append JSONL audit log |

## Adding a new rule

1. Decide tier (hard/soft/advisory).
2. Create `.claude/hooks/rules/<tier>/<NN>-<slug>.sh`. Number it sequentially after the highest in that tier.
3. Use `lib/common.sh` helpers (`block_violation`, `warn_violation`).
4. `chmod +x` the new script.
5. Test on a trivial violating case before committing.

## Disabling a rule

For one session: rename the file to `*.sh.disabled`. The validator's glob skips disabled scripts.

For permanent removal: delete the file and update `setup_resources/HOOKS.md`.

## Common.sh helpers

- `read_mode()` — returns `strict` or `permissive`
- `extract_file_path()` / `extract_content()` — parse tool input JSON
- `is_do_file()`, `is_r_file()`, `is_stata_or_r()` — file-type checks
- `is_data_dir()`, `is_config_do()`, `is_install_packages()` — path-context checks
- `block_violation <rule> <msg>` — emit blocking JSON, exit 2
- `warn_violation <rule> <msg>` — emit stderr warning, no exit
