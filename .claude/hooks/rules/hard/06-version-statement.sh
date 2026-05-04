#!/usr/bin/env bash
# Hard rule 06: run.do and top-level numbered .do scripts must include `version X`
# (or call _config.do which sets it). _config.do itself must have `version X`.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Files that need a version statement:
NEEDS_VERSION=0
case "$FILE_PATH" in
  */run.do|run.do) NEEDS_VERSION=1 ;;
  */analysis/scripts/[0-9]*_*.do) NEEDS_VERSION=1 ;;
  */analysis/scripts/programs/_config.do) NEEDS_VERSION=1 ;;
esac

if [ $NEEDS_VERSION -eq 0 ]; then exit 0; fi

# Allow _config.do sourcing (run "...programs/_config.do") as a proxy for version-set
if echo "$CONTENT" | grep -qE '_config\.do' 2>/dev/null; then
  exit 0
fi

# Check for `version X` directive
if ! echo "$CONTENT" | grep -qE '^\s*version\s+[0-9]+' 2>/dev/null; then
  block_violation "06-version-statement" "Missing 'version N' directive. run.do, top-level numbered scripts, and _config.do must declare a Stata version (e.g., 'version 15') for reproducibility. Reif Stata Coding Guide: 'Stata takes version control seriously. You should always include a version statement in your master script.' File: $FILE_PATH"
fi
exit 0
