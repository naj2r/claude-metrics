#!/usr/bin/env bash
# Soft rule 10: 'set varabbrev off' should be present (or via _config.do).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi
# Only check files that run independently (top-level numbered, run.do, _config.do)
case "$FILE_PATH" in
  */run.do|run.do|*/analysis/scripts/[0-9]*_*.do|*/_config.do) ;;
  *) exit 0 ;;
esac

# Pass if varabbrev is set OR _config.do is sourced (which sets it)
if echo "$CONTENT" | grep -qE 'set\s+varabbrev\s+off|_config\.do' 2>/dev/null; then
  exit 0
fi

echo "[10-varabbrev] Missing 'set varabbrev off' (and no _config.do source). Stata's variable abbreviation can silently match the wrong variable. Reif Stata Coding Guide §Stata coding tips."
exit 1
