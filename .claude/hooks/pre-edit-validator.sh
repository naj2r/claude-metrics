#!/usr/bin/env bash
# pre-edit-validator.sh — main PreToolUse validator
# Fires on Edit|Write|MultiEdit. Runs hard rules (always block on violation),
# then soft rules (block in strict mode, warn in permissive), then advisory
# rules (always warn-only).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Read tool input from stdin (cache for re-use)
INPUT=$(cat)
FILE_PATH=$(extract_file_path "$INPUT")
CONTENT=$(extract_content "$INPUT")

# Skip if no file path (defensive)
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-stata-relevant files unless rule cares about other paths (e.g., data dir)
# Hard rules check their own scope; we always run them.

# Export for rule scripts
export FILE_PATH CONTENT INPUT
export PROJECT_ROOT
PROJECT_ROOT="$(project_root)"
export PROJECT_ROOT

# --- Hard rules (always block on violation) ---
for rule in "$SCRIPT_DIR/rules/hard/"*.sh; do
  [ -e "$rule" ] || continue
  output=$(bash "$rule" 2>&1)
  rc=$?
  if [ $rc -ne 0 ]; then
    # Hard rule violation. Output already in JSON format from block_violation.
    echo "$output"
    exit 2
  fi
done

# --- Soft rules (mode-dependent) ---
MODE=$(read_mode)
SOFT_VIOLATIONS=""
for rule in "$SCRIPT_DIR/rules/soft/"*.sh; do
  [ -e "$rule" ] || continue
  output=$(bash "$rule" 2>&1)
  rc=$?
  if [ $rc -ne 0 ]; then
    SOFT_VIOLATIONS="${SOFT_VIOLATIONS}${output}\n"
  fi
done

if [ -n "$SOFT_VIOLATIONS" ]; then
  if [ "$MODE" = "strict" ]; then
    cat <<EOF
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "[soft-rules in strict mode] $(echo -e "$SOFT_VIOLATIONS")"}}
EOF
    exit 2
  else
    echo -e "$SOFT_VIOLATIONS" >&2
  fi
fi

# --- Advisory rules (always warn-only via stderr) ---
# Suppress stdout (so it doesn't pollute hook JSON output) but pass stderr through.
for rule in "$SCRIPT_DIR/rules/advisory/"*.sh; do
  [ -e "$rule" ] || continue
  bash "$rule" >/dev/null || true
done

exit 0
