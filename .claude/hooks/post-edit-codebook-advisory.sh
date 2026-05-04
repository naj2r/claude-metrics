#!/usr/bin/env bash
# post-edit-codebook-advisory.sh — PostToolUse advisory after Edit/Write on .do
# Greps the diff for new variable creation patterns and reminds Claude that
# the codebook will refresh on next run. Never blocks.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

INPUT=$(cat)
FILE_PATH=$(extract_file_path "$INPUT")
CONTENT=$(extract_content "$INPUT")

if ! is_do_file "$FILE_PATH"; then
  exit 0
fi

# Look for new variable patterns
NEW_VARS=""
if echo "$CONTENT" | grep -qP '^\s*(gen|egen|generate)\s+\w+' 2>/dev/null; then
  NEW_VARS="$NEW_VARS gen/egen"
fi
if echo "$CONTENT" | grep -qP '^\s*label\s+variable\s+' 2>/dev/null; then
  NEW_VARS="$NEW_VARS label-variable"
fi
if echo "$CONTENT" | grep -qP '^\s*replace\s+\w+\s*=' 2>/dev/null; then
  NEW_VARS="$NEW_VARS replace"
fi

if [ -n "$NEW_VARS" ]; then
  echo "ADVISORY [codebook]: detected variable changes ($NEW_VARS) in $FILE_PATH. Codebook will refresh on next run via _codebook_update post-credits. To rebuild now, use /update-codebook." >&2
fi

exit 0
