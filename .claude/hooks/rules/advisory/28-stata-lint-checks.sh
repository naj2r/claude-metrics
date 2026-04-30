#!/usr/bin/env bash
# Advisory 28: wrapper that delegates to stata-lint.sh for the 5 stata-skill checks.
# Lets the lint fire on pre-edit (in addition to post-edit registration in settings.json).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LINT="$SCRIPT_DIR/stata-lint.sh"

if [ -x "$LINT" ]; then
  # Reconstruct minimal stdin JSON for stata-lint.sh (it expects file_path + content)
  printf '{"file_path":"%s","content":"%s","new_string":""}' "$FILE_PATH" "$CONTENT" | bash "$LINT"
fi
exit 0
