# Onboarding (for coauthors cloning this repo)

Five steps to get a fresh clone running on your machine.

## 1. Add your Dropbox path to `profile.do`

Stata reads `profile.do` on launch. Find yours by typing `adopath` at the Stata prompt — the directory containing `personal` is where it lives. On Windows the typical location is `C:/Users/<you>/ado/personal/profile.do`.

Add this line (replace the path with yours):

```stata
global DROPBOX "C:/Users/<you>/Dropbox"
run "$DROPBOX/stata_profile.do"
```

## 2. Add this project's global to `stata_profile.do` on Dropbox

`$DROPBOX/stata_profile.do` is the shared profile across all your machines. Add:

```stata
global MyProject "$DROPBOX/<project-folder>/analysis"
```

(Replace `<project-folder>` with the actual folder name on Dropbox where the project lives. The same line works on any machine you have linked to Dropbox.)

## 3. Run `_install_stata_packages.do` once

This vendors all required Stata packages into `analysis/scripts/libraries/stata/`. From Stata:

```stata
do "$MyProject/scripts/programs/_install_stata_packages.do"
```

(After this, the bundled libraries make the project portable; you don't need to re-install on other machines.)

## 4. Fill in `CONTEXT.md`

If `CONTEXT.md` still has `[ FILL IN ]` placeholders, run `/init-project <slug>` from Claude Code or fill the five fields manually.

## 5. Run `run.do` to verify the setup

```stata
do "$MyProject/run.do"
```

This executes the full pipeline. On success:
- `analysis/processed/` is regenerated from `analysis/data/`
- `analysis/results/` has tables and figures
- `analysis/results/_inventory.xlsx` has 6 sheets with at least one row each
- `analysis/documentation/codebook.md` has populated variable tables
- `analysis/scripts/logs/<timestamp>.log.txt` has the full execution log

If anything fails, read the log and consult `.claude/UPGRADE_LOG.md` for known gaps. If the failure is new, log it.

## Working with Claude Code

After onboarding:

- `/strict` (default) — soft rules block on violation
- `/permissive` — soft rules warn but don't block (for autonomous runs)
- `/new-script <N> <slug>` — scaffold a new numbered script
- `/run-stata` — execute `run.do` via Stata MCP or batch fallback
- `/validate` — run all hook checks across the analysis tree
- `/update-codebook` — rebuild `codebook.md` from current data
- `/inventory-rebuild` — rebuild `_inventory.xlsx` from current state
- `/review-upgrade-log` — surface logged knowledge gaps for review

See `CLAUDE.md` for the full convention reference.
