---
description: First-clone customization — set $MyProject, fill CONTEXT.md, choose demo vs starter
argument-hint: "<project-slug> [--demo|--starter]"
---

# /init-project

One-time setup for a fresh clone of the template. Walks the user through the five `CONTEXT.md` fields and configures the project.

## Arguments

- `<project-slug>` — short kebab-case identifier (e.g., `emissions-study`, `wage-gap-2024`)
- `--demo` (default on `master` branch) — keep the Reif `auto.csv` analysis intact
- `--starter` — strip down to empty scaffold; expect on the `starter` branch

## Action

### Step 1: Verify branch

If `--starter` requested, verify we're on the `starter` branch (or offer to check it out).

### Step 2: Walk CONTEXT.md fields

Open `CONTEXT.md` and for each `[ FILL IN ]` placeholder, ask the user for the value:

1. Dataset(s)
2. Unit of observation
3. Outcome variable(s)
4. Identification strategy
5. Key globals (especially `$MyProject` path)

After all five are filled, write `CONTEXT.md` back.

### Step 3: Set `$MyProject` placeholder in run.do

Open `analysis/run.do` and surface the line:

```stata
* global MyProject "C:/Users/jdoe/MyProject"
```

Ask the user for their local path. Update the line (still commented per Reif convention — user uncomments locally; never committed uncommented).

### Step 4: Reset state files (starter branch only)

If `--starter`:
- Delete `analysis/results/_inventory.xlsx` if present
- Reset `analysis/documentation/codebook.md` to the seeded header

### Step 5: R configuration

Ask: "Will this project use R? (y/n)". If no, set `global DisableR = 1` in `run.do`.

### Step 6: Confirm to user

Print a summary: project slug, mode, R enabled/disabled, branch, next steps ("Run `/run-stata` to verify the demo, then start `/new-script 5 first_analysis`").

## Post-init checklist (for the user)

- [ ] Set `$MyProject` to your local path in `run.do`
- [ ] Place raw data in `analysis/data/`
- [ ] Run `/run-stata` to confirm the pipeline works end-to-end
- [ ] Commit the filled `CONTEXT.md` (it's the project context, not template)
