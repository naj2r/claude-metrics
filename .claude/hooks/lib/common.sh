#!/usr/bin/env bash
# common.sh — shared helpers for hook scripts.
# Source from each hook: source "$(dirname "$0")/lib/common.sh"

# Resolve project root (path containing .claude/)
project_root() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    echo "$CLAUDE_PROJECT_DIR"
  else
    # walk up from current dir to find .claude/
    local d="$PWD"
    while [ "$d" != "/" ]; do
      if [ -d "$d/.claude" ]; then echo "$d"; return; fi
      d=$(dirname "$d")
    done
    echo "$PWD"
  fi
}

# Read current mode (strict or permissive). Default: strict if file missing.
read_mode() {
  local mf
  mf="$(project_root)/.claude/.mode"
  if [ -f "$mf" ]; then
    tr -d ' \t\n\r' < "$mf"
  else
    echo "strict"
  fi
}

# Extract file_path from tool input JSON on stdin (cached to a variable).
extract_file_path() {
  echo "$1" | grep -oP '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/"file_path"\s*:\s*"//;s/"$//' 2>/dev/null || true
}

# Extract content (new_string for Edit, content for Write) from tool input JSON.
extract_content() {
  local input="$1"
  local content
  content=$(echo "$input" | grep -oP '"new_string"\s*:\s*"[^"]*"' | head -1 | sed 's/"new_string"\s*:\s*"//;s/"$//' 2>/dev/null || true)
  if [ -z "$content" ]; then
    content=$(echo "$input" | grep -oP '"content"\s*:\s*"[^"]*"' | head -1 | sed 's/"content"\s*:\s*"//;s/"$//' 2>/dev/null || true)
  fi
  echo "$content"
}

# File-type checks
is_do_file() { [[ "$1" =~ \.do$ ]]; }
is_r_file() { [[ "$1" =~ \.[Rr]$ ]]; }
is_stata_or_r() { is_do_file "$1" || is_r_file "$1"; }

# Path-context checks
is_data_dir() { [[ "$1" =~ /(analysis/)?data/ ]]; }
is_config_do() { [[ "$1" =~ /_config\.do$ ]]; }
is_install_packages() { [[ "$1" =~ /_install_stata_packages\.do$ ]]; }

# Emit a blocking violation as JSON to stdout (matches Claude Code hook contract)
# and exit 2 — this halts the tool call and Claude reads the message.
block_violation() {
  local rule="$1"; shift
  local msg="$*"
  cat <<EOF
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "[$rule] $msg"}}
EOF
  exit 2
}

# Emit a warning to stderr (visible to Claude). Does not block.
warn_violation() {
  local rule="$1"; shift
  echo "WARNING [$rule]: $*" >&2
}
