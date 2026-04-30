---
description: Execute analysis/run.do via Stata MCP (default) or batch mode (fallback)
---

# /run-stata

Execute the project's master script. Default path: Stata MCP server. Fallback: Stata batch mode via Bash.

## Action

### Step 1: detect MCP availability

Try `mcp__stata__list_sessions` to confirm the Stata MCP server is reachable.

### Step 2A: MCP path (default)

If MCP is up:

```
mcp__stata__create_session  (if no active session)
mcp__stata__run_do_file with file_path="analysis/run.do"
```

Stream output via `mcp__stata__read_log` or `mcp__stata__get_task_status`. Confirm log written to `analysis/scripts/logs/`.

### Step 2B: Batch fallback

If MCP is unreachable:

```bash
# Windows (Git Bash) — uses temp .bat to bypass MSYS path translation
TMP_BAT=$(mktemp --suffix=.bat)
echo '"C:\Program Files\StataNow19\StataMP-64.exe" /e do "%MyProject%\run.do"' > "$TMP_BAT"
"$TMP_BAT"
rm "$TMP_BAT"

# Unix
stata-mp -b do "$MyProject/run.do"
```

Confirm `analysis/scripts/logs/<timestamp>.log.txt` was created.

### Step 3: Post-run check

Read `analysis/results/_inventory.xlsx` `runs` sheet — confirm the latest entry has event=`end` (success). If event=`error` or missing, surface the log tail to the user.

## Pre-flight checks

- `$MyProject` set in `run.do`?
- All vendored packages present? (`which reghdfe`, `which texsave`, `which regsave`)
- `_inventory.xlsx` initialized? (auto-created on first run via `_inventory_init`)

## When to use

- Initial test of a fresh clone
- Re-run after editing any numbered script
- Quick smoke test before committing
