#!/usr/bin/env bash
# Advisory 26: if .do file generates new variables, codebook should be refreshed.
# Heuristic: this hook runs PRE-edit, so it just reminds Claude that codebook needs refresh.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

NEW_VARS=$(echo "$CONTENT" | grep -cE '^\s*(gen|egen|generate)\s+\w+' 2>/dev/null || echo 0)
if [ "$NEW_VARS" -gt 0 ]; then
  if ! echo "$CONTENT" | grep -qE '_codebook_update' 2>/dev/null; then
    echo "ADVISORY [26-codebook-staleness]: $NEW_VARS new variable(s) created in this file but no _codebook_update call detected. Add _codebook_update to the post-credits block. Or run /update-codebook after this run." >&2
  fi
fi
exit 0
