#!/usr/bin/env bash
# Advisory 21: long scripts should use banner separators for sections (Ouellet/Toffel §1b).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

LINE_COUNT=$(echo "$CONTENT" | wc -l)
if [ "$LINE_COUNT" -lt 80 ]; then exit 0; fi

# Look for banner-style separators (asterisk lines, hash lines)
if ! echo "$CONTENT" | grep -qE '^\*-{5,}|^\*={5,}|^#-{5,}|^//-{5,}' 2>/dev/null; then
  echo "ADVISORY [21-section-banners]: long script ($LINE_COUNT lines) without banner separators. Consider adding section banners (e.g., '*--------------------*\n* Section name\n*--------------------*'). Ouellet/Toffel §1b." >&2
fi
exit 0
