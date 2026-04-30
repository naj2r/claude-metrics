#!/usr/bin/env bash
# Hard rule 03: no backslashes in pathnames inside .do files (Stata escape character).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Look for backslashes inside double-quoted path-like strings.
# Pattern: "<...>\<...>.<extension>" where extension is do|dta|csv|tex|pdf|ado|R|txt|log
VIOLATIONS=$(echo "$CONTENT" | grep -nE '"[^"]*\\[^"]*\.(do|dta|csv|tex|pdf|ado|R|txt|log|xlsx)"' 2>/dev/null || true)

if [ -n "$VIOLATIONS" ]; then
  block_violation "03-no-backslashes" "Backslash found in pathname inside .do file. Backslashes are escape characters in Stata. Use forward slashes (/) for cross-platform compatibility. Reif Stata Coding Guide §Stata coding tips. Offending lines: $VIOLATIONS"
fi
exit 0
