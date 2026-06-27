# Round 2 — Task 01: Setup (vendor packages)

**Read first**: `00_MASTER.md`
**Status**: PENDING
**Prereqs**: Read MASTER. Verify on commit `cfc2493` or later, branch `starter`.
**Estimated time**: 30 min
**Output**: Updated `analysis/scripts/programs/_install_stata_packages.do` + 3 new vendored package directories under `analysis/scripts/libraries/stata/`

---

## Purpose

Vendor the three SSC packages required across Tasks A, C.3, and C.6 BEFORE starting any analytical work. Project HARD rule: no inline `ssc install` / `net install`. The `/add-package` slash command is the project's wrapper that performs `ssc install` into a temporary location, copies the `.ado` and `.sthlp` into `analysis/scripts/libraries/stata/<letter>/`, and registers the install in `_install_stata_packages.do` so it propagates to coauthor machines via `do "$MyProject/scripts/programs/_install_stata_packages.do"`.

## Packages to vendor

| Package | Source | Used by | Purpose |
|---|---|---|---|
| `coldiag2` | SSC | Task A | BKW (Belsley-Kuh-Welsch) condition number for multicollinearity diagnostic |
| `pdslasso` | SSC | Task A | Post-double-selection LASSO (Belloni-Chernozhukov-Hansen 2014) |
| `lassopack` | SSC | Task A (transitive dep of `pdslasso`) | LASSO machinery used by `pdslasso` |
| `ritest` | SSC | Tasks C.3, C.6 | Permutation inference (10k reps) |

Note on `ritest`: there is also a richer GitHub version (`net install ritest, from(https://...)`). Use the SSC version unless `/add-package ritest` reports it doesn't exist or is missing required functionality. The SSC version supports the `_b[varname]` syntax used in the strategist's example code.

## Implementation steps

### Step 1 — Read existing package install script

Read `analysis/scripts/programs/_install_stata_packages.do` to understand the existing structure. It's organized in groups (Group 1, Group 2, ..., Group 7 was added for `b1x2` in the F-series session). Round 2 will add **Group 8: round-2 diagnostics packages**.

### Step 2 — Vendor the packages (one at a time)

Use the `/add-package` slash command per project rule. Sequence:

```
/add-package coldiag2
/add-package lassopack          # vendor before pdslasso since pdslasso depends on it
/add-package pdslasso
/add-package ritest
```

`/add-package` is documented in `.claude/commands/add-package.md`. It takes one positional arg (package name) and:
1. Runs `ssc install <name>` into a tempdir
2. Locates the `.ado`, `.sthlp`, and any subordinate files
3. Copies them to `analysis/scripts/libraries/stata/<first-letter>/`
4. Adds an `_install_ssc <name>` line to `_install_stata_packages.do` in the right group section
5. Updates the `.trk` tracking file if present

If `/add-package` doesn't exist as a slash command in `.claude/commands/`, check for `add-package.sh` or similar. As a last resort, manually:
1. `ssc install <pkg>` in a clean Stata session
2. `which <pkg>` to find install location
3. Copy `.ado` + `.sthlp` (and any sub-files) into `analysis/scripts/libraries/stata/<first-letter>/`
4. Add `_install_ssc <pkg>` to `_install_stata_packages.do` Group 8

### Step 3 — Verify all 4 packages can be loaded by Stata

Use the batch-mode wrapper (per MASTER §"Re-running the pipeline"):

```stata
* Save to C:/Users/jensenn/AppData/Local/Temp/test_packages.do
version 19
global HOME    "C:/Users/jensenn"
global DROPBOX "C:/Users/jensenn/Dropbox"
do "$DROPBOX/stata_profile.do"
global MyProject "$Absinthe1"

* Source the install script to get adopath set
do "$MyProject/scripts/programs/_install_stata_packages.do"

* Verify each package loads
foreach pkg in coldiag2 pdslasso lassopack ritest {
    cap which `pkg'
    if _rc {
        di as error "FAIL: `pkg' not found on adopath"
    }
    else {
        di as text "OK: `pkg' found"
    }
}
```

Expected: 4 OK lines.

### Step 4 — Run the full pipeline once

Per "verify after every change" rule. Should still run in ~110-120s with all 28 assertions passing (we haven't added any analysis yet, just vendored packages).

```bash
# See MASTER §"Re-running the pipeline"
```

### Step 5 — Commit

Stage:
- `analysis/scripts/programs/_install_stata_packages.do`
- `analysis/scripts/libraries/stata/c/coldiag2.*` (or wherever it lands)
- `analysis/scripts/libraries/stata/p/pdslasso.*`
- `analysis/scripts/libraries/stata/l/lassopack.*` (and any sub-files)
- `analysis/scripts/libraries/stata/r/ritest.*`
- `analysis/scripts/libraries/stata/<letter>/<pkg>.trk` files if present

```bash
git add analysis/scripts/programs/_install_stata_packages.do
git add analysis/scripts/libraries/stata/c/coldiag2*
git add analysis/scripts/libraries/stata/l/lassopack*
git add analysis/scripts/libraries/stata/p/pdslasso*
git add analysis/scripts/libraries/stata/r/ritest*

git commit -m "Vendor coldiag2, pdslasso, lassopack, ritest for round-2 diagnostics

Round-2 (Task A diagnostics + Tasks C.3/C.6 RI inference) requires four
SSC packages vendored under analysis/scripts/libraries/stata/. Per project
HARD rule, ssc install is forbidden inline; vendored copies propagate to
coauthors via _install_stata_packages.do.

- coldiag2: BKW condition number for Task A multicollinearity diagnostic
- pdslasso + lassopack (dep): post-double-selection LASSO for Task A
- ritest: 10k permutation inference for Tasks C.3 and C.6

Group 8 added to _install_stata_packages.do.

No analysis changes; pipeline still runs end-to-end with 28 assertions
passing (~115s)."

git push origin starter
```

## Acceptance criteria

- [ ] `/add-package coldiag2` (or manual equivalent) succeeded; `coldiag2.ado` exists under `libraries/stata/c/`
- [ ] `/add-package lassopack` succeeded; `lassopack.ado` (and any sub-files) exist under `libraries/stata/l/`
- [ ] `/add-package pdslasso` succeeded; `pdslasso.ado` exists under `libraries/stata/p/`
- [ ] `/add-package ritest` succeeded; `ritest.ado` exists under `libraries/stata/r/`
- [ ] `_install_stata_packages.do` has Group 8 with the 4 new `_install_ssc` lines
- [ ] Stata `which <pkg>` returns a path under `libraries/stata/` for all 4 packages (NOT under user's PERSONAL ado dir)
- [ ] Full pipeline runs end-to-end, 28 assertions pass
- [ ] Commit pushed to `origin/starter`

## Pitfalls

1. **`/add-package` may not handle `lassopack` cleanly** if it has multiple sub-files. Check after vendoring that all required `.ado` files are present (e.g., `lassopack.ado`, `lasso2.ado`, `lassoutils.ado`, etc.). If any are missing, copy manually.

2. **`pdslasso` has hidden dependencies on `lassopack`** — must vendor `lassopack` FIRST. If you vendor `pdslasso` before `lassopack`, the install may succeed but later runtime calls to `pdslasso` will fail with "lassoutils not found" or similar.

3. **`ritest` syntax variants** — there are multiple versions in the wild. The strategist's example code uses `_b[varname]` syntax: `ritest treatvar _b[treatvar], reps(...): ...`. Verify the vendored version supports this. If not, use the syntax that works and document in the task handoff that uses it.

4. **Adopath order matters**. `_config.do` should already prepend `libraries/stata/` to the adopath; verify before running tests. If a vendored package is "newer" than a system version, this matters. Should be fine for these 4 packages (none are also installed system-wide).

## Done when

- All 4 `which <pkg>` checks return paths under `libraries/stata/`
- Full pipeline passes 28 assertions
- Commit `<hash>` pushed
- Move to `02_taskA_diagnostics.md`
