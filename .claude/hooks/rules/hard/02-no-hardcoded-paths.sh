#!/usr/bin/env bash
# Hard rule 02: no hardcoded absolute paths in .do or .R files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_stata_or_r "$FILE_PATH"; then exit 0; fi

# Patterns that indicate hardcoded absolute paths in code:
# - Windows: C:/, D:/, C:\, etc.
# - Unix: /Users/<name>/, /home/<name>/
# Allowed: env-var refs ($MyProject, $DROPBOX, Sys.getenv(...))
# Heuristic: search for these patterns INSIDE quoted strings (Stata uses ", R uses " or ')

VIOLATIONS=$(echo "$CONTENT" | grep -nE '"([A-Za-z]:[/\\]|/Users/|/home/[^/]+/)' 2>/dev/null | grep -v '\$MyProject\|\$DROPBOX\|Sys.getenv\|file.path' || true)

if [ -n "$VIOLATIONS" ]; then
  block_violation "02-no-hardcoded-paths" "Hardcoded absolute path detected. Use \$MyProject (Stata) or Sys.getenv('MyProject')/file.path() (R) instead. Reif Stata Coding Guide: 'Anyone should be able to run your entire analysis from their computer without having to edit any scripts, with the exception of defining a single global variable in run.do.' Offending lines: $VIOLATIONS"
fi
exit 0
