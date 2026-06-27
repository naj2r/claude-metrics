# MCP integration

The Stata MCP server is the **default execution path**. Batch mode (`stata-mp -b do`) is the fallback. `/run-stata` chooses automatically.

## Available MCP tools

(Loaded on session start; full list visible in tool inventory.)

- `mcp__stata__create_session` — open a persistent Stata session
- `mcp__stata__run_command` — run a single Stata command
- `mcp__stata__run_do_file` — execute a do-file
- `mcp__stata__run_command_background` / `run_do_file_background` — non-blocking variants
- `mcp__stata__get_task_status` / `get_task_result` — track background tasks
- `mcp__stata__describe` / `codebook` / `get_help` — metadata and help
- `mcp__stata__load_data` / `get_data` / `get_variable_list` — data inspection
- `mcp__stata__get_stored_results` — `e()`/`r()` macros after estimation
- `mcp__stata__list_graphs` / `export_graph` / `export_graphs_all` — graph handling
- `mcp__stata__read_log` / `find_in_log` — log access
- `mcp__stata__stop_session` / `break_session` / `cancel_task` — control flow

## When to use MCP vs batch

**MCP** (default):
- Interactive exploration: `summarize`, `describe`, `tab`
- Iterating on a single regression spec
- Inspecting `e()` returns
- Faster for short tasks (no interpreter startup per call)
- Persistent state across calls in the same session

**Batch mode** (fallback):
- Final pipeline runs (the entire `run.do`)
- CI/CD or scheduled tasks
- When MCP server is unavailable (offline, not running, network issue)
- When you specifically want a `.log` file in the canonical Stata format

## Batch mode invocation (Windows / Git Bash)

Stata's `-b` flag plus `do` runs a do-file in batch mode and writes a log. On Windows via Git Bash, the MSYS shell translates `/e` to `E:/`, breaking direct invocation. Workaround: write a temp `.bat`:

```bash
TMP_BAT=$(mktemp --suffix=.bat)
cat > "$TMP_BAT" <<EOF
"C:\Program Files\StataNow19\StataMP-64.exe" /e do "%MyProject%\run.do"
EOF
cmd.exe /c "$TMP_BAT"
rm "$TMP_BAT"
```

## Batch mode invocation (Unix)

```bash
stata-mp -b do "$MyProject/run.do"
```

## MCP server config

[**Paste your MCP server config here when you have it from the other repo.**]

The config typically lives in `.claude/mcp.json` or a similar file. It tells Claude Code which Stata binary to launch and how to communicate with the MCP wrapper.

Until config is present, MCP tools may be available globally (from a user-level setup) or unavailable (in which case `/run-stata` auto-falls-back to batch mode).

## Troubleshooting

- **MCP tools not visible**: confirm the MCP server is running and registered in `.claude/mcp.json` or globally. `mcp__stata__list_sessions` should return a session list (or empty array, not an error).
- **`run_do_file` hangs**: check `mcp__stata__get_task_status` — long-running tasks should be backgrounded.
- **Different log format than batch**: MCP doesn't write a Stata `.log` file by default. Use `mcp__stata__read_log` for the in-session log, or fall back to batch for canonical logs.
- **"Stata not found"**: MCP server must know where Stata is installed. Set `STATA_PATH` env var or configure in `mcp.json`.
