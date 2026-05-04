#!/usr/bin/env bash
# inject-mode-context.sh — UserPromptSubmit hook
# Prepends the current mode to Claude's context so Claude knows whether
# soft rules will block or just warn. Runs every user prompt.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

MODE=$(read_mode)

# Output JSON that Claude Code injects into the conversation.
# Per Claude Code hook contract: stdout becomes additional context.
cat <<EOF
[Mode: $MODE] — Hard rules always block. Soft rules $([ "$MODE" = "strict" ] && echo "BLOCK" || echo "warn-only"). Advisory rules always warn-only.
EOF

exit 0
