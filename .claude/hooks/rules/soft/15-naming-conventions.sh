#!/usr/bin/env bash
# Soft rule 15: new file/folder names lowercase + [a-z0-9_-]; no spaces, no caps.
# Triggered on Write to a new file path.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Only check the basename of the file being created/modified
BASENAME=$(basename "$FILE_PATH")

# Skip dotfiles and uppercase-by-convention files (CLAUDE.md, README.md, CONTEXT.md, etc.)
case "$BASENAME" in
  .*) exit 0 ;;
  README.md|README*|CLAUDE.md|CONTEXT.md|LICENSE|LICENSE.txt|MEMORY.md|UPGRADE_LOG.md|HOOKS.md|CODEBOOK.md|INVENTORY.md|MODE.md|MCP.md|SKILL.md) exit 0 ;;
esac

# Check for spaces, capital letters, or non-allowed chars
if echo "$BASENAME" | grep -qE '[A-Z ]|^[^a-z0-9_]' 2>/dev/null; then
  echo "[15-naming-conventions] File name '$BASENAME' has uppercase or spaces. Reif Stata Coding Guide §Stata coding tips: 'avoid using spaces and capital letters in file and folder names.' Use lowercase + underscores/hyphens."
  exit 1
fi
exit 0
