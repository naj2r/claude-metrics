#!/usr/bin/env bash
# post-edit-log.sh — PostToolUse audit log
# Appends a JSONL record of every Edit/Write/MultiEdit to .claude/edit-log.jsonl.
# This is gitignored; useful for review and replay.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

INPUT=$(cat)
FILE_PATH=$(extract_file_path "$INPUT")

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

LOG="$PROJECT_ROOT/.claude/edit-log.jsonl"
[ -z "${PROJECT_ROOT:-}" ] && PROJECT_ROOT="$(project_root)"
LOG="$PROJECT_ROOT/.claude/edit-log.jsonl"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MODE=$(read_mode)

printf '{"ts":"%s","mode":"%s","file":"%s"}\n' "$TIMESTAMP" "$MODE" "$FILE_PATH" >> "$LOG"

exit 0
