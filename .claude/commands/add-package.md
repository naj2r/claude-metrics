---
description: Install a Stata package into analysis/scripts/libraries/stata with .trk tracking
argument-hint: "<package-name> <source: ssc | reifjulian | <github-user>>"
---

# /add-package

Install a Stata package into the project's vendored library. Updates `analysis/scripts/libraries/stata/stata.trk` automatically (Stata's built-in tracking).

## Arguments

- `<package-name>` — the package's command name (e.g., `reghdfe`, `coefplot`)
- `<source>` — one of:
  - `ssc` — install from Boston College SSC archive
  - `reifjulian` — install from Reif's GitHub
  - `<github-user>` — install from arbitrary GitHub user's repo (must follow Stata's `net install` URL format)

## Action

1. Verify the package isn't already installed: read `analysis/scripts/libraries/stata/stata.trk` for existing entries.
2. Construct the install command:
   - `ssc`: `qui net from "http://fmwww.bc.edu/repec/bocode/<first-letter>"; net install <pkg>, replace`
   - `<user>`: `net install <pkg>, from("https://raw.githubusercontent.com/<user>/<pkg>/master") replace`
3. Run the command via `mcp__stata__run_command` (preferred) or generate a one-shot do-file Claude tells the user to run.
4. Verify with `which <pkg>` — confirm the path is inside `libraries/stata/`.
5. Append a note to `_install_stata_packages.do` documenting the addition (so the install is reproducible from scratch).
6. Confirm to user with package path and version (if Stata exposes it).

## Why not inline `ssc install`?

Hard rule 07 blocks inline package installs. This command is the only safe path. It centralizes install metadata, prevents drift, and ensures the package is bundled in the replication archive.

## When the package fails to install

Log to `UPGRADE_LOG.md` and ask the user whether to try an alternate source (e.g., direct GitHub instead of SSC).
