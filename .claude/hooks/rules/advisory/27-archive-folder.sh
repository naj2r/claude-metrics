#!/usr/bin/env bash
# Advisory 27: heavy edits to a script should suggest archiving prior version with date suffix.
# Heuristic: if Edit replaces >50% of file's content, suggest archive (Ouellet/Toffel §2b).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Detect 'old_string' from input; if its length is >50% of total content length, flag.
OLD_STRING=$(echo "$INPUT" | grep -oP '"old_string"\s*:\s*"[^"]*"' | head -1 | sed 's/"old_string"\s*:\s*"//;s/"$//' 2>/dev/null || true)
if [ -z "$OLD_STRING" ]; then exit 0; fi

OLD_LEN=${#OLD_STRING}
NEW_LEN=${#CONTENT}

if [ "$OLD_LEN" -gt 1000 ] && [ "$OLD_LEN" -gt $((NEW_LEN / 2)) ]; then
  ARCHIVE_SUGGESTION="archive/$(basename "${FILE_PATH%.do}")_$(date +%Y-%m-%d).do"
  echo "ADVISORY [27-archive-folder]: large edit detected (>1KB old_string, ~50%+ of file). Ouellet/Toffel §2b suggests archiving prior versions in archive/ subfolder with date suffix. Consider: cp '$FILE_PATH' '$(dirname "$FILE_PATH")/$ARCHIVE_SUGGESTION' before this edit." >&2
fi
exit 0
