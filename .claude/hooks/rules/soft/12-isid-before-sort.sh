#!/usr/bin/env bash
# Soft rule 12: sort/bysort should be preceded by 'isid <key>' or use ', stable' option.
# Heuristic: flag any sort/bysort that doesn't have nearby isid or stable.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# If file contains sort or bysort but no isid and no ", stable":
if echo "$CONTENT" | grep -qE '^\s*(sort|bysort)\s+\w' 2>/dev/null; then
  if ! echo "$CONTENT" | grep -qE 'isid\s+|,\s*stable\b' 2>/dev/null; then
    echo "[12-isid-before-sort] sort/bysort detected without isid check or ', stable' option. Non-unique sorts produce nondeterministic results. Either add 'isid <keys>' before the sort, or use ', stable' option. Reif Stata Coding Guide §Stata coding tips (gotcha: float-based uniform() with N=100k may not be unique)."
    exit 1
  fi
fi
exit 0
