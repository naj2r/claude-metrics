#!/usr/bin/env bash
# Advisory 20: scripts should have header with Author, Date, Purpose, Version (Ouellet/Toffel §1b).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi
case "$FILE_PATH" in
  */[0-9]_*.do|*/run.do|run.do) ;;
  *) exit 0 ;;
esac

MISSING=""
echo "$CONTENT" | head -20 | grep -qiE 'author' 2>/dev/null || MISSING="$MISSING Author"
echo "$CONTENT" | head -20 | grep -qiE 'purpose' 2>/dev/null || MISSING="$MISSING Purpose"
echo "$CONTENT" | head -20 | grep -qiE 'date|^\*.*[0-9]{4}-[0-9]{2}' 2>/dev/null || MISSING="$MISSING Date"

if [ -n "$MISSING" ]; then
  echo "ADVISORY [20-script-header]: header missing fields:$MISSING. Ouellet/Toffel §1b suggests Author, Date, Purpose, Version/Last Update at top of file. See _template_script.do." >&2
fi
exit 0
