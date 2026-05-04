#!/usr/bin/env bash
# methods-doc-reminder.sh — UserPromptSubmit hook
#
# Survives compaction. Fires on every user prompt. Scans the prompt for
# keywords derived from filenames in analysis/documentation/methods/*.md.
# For each match, emits a one-line reminder so Claude reads the methods doc
# before working on that method (per project rule "no guesses on brand-new
# methods" + user instruction "needs to read that even post-compact as you
# would for any other common methods").
#
# Convention: methods doc filenames are <topic>_<method>.md or <topic>.md.
# Keywords are derived by:
#   1. Strip directory prefix and `.md` suffix
#   2. Split on underscores
#   3. Each token (length >= 4 to avoid noise) becomes a case-insensitive
#      whole-word trigger.
#
# To add a new method: just drop a new <name>.md file under
# analysis/documentation/methods/. No hook code change needed.

set -uo pipefail

# Determine project root (for portability)
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
METHODS_DIR="$ROOT/analysis/documentation/methods"

# Read the user prompt JSON from stdin (PreToolUse contract supplies via env;
# UserPromptSubmit supplies via stdin per Claude Code docs).
INPUT=""
if ! [ -t 0 ]; then
  INPUT=$(cat 2>/dev/null || true)
fi

# Extract the user's prompt text. Be tolerant of multiple JSON shapes.
PROMPT=$(echo "$INPUT" | grep -oP '"prompt"\s*:\s*"[^"]*"' | head -1 | sed 's/"prompt"\s*:\s*"//;s/"$//' 2>/dev/null || true)
[ -z "$PROMPT" ] && PROMPT="$INPUT"  # fallback: scan whole input

# If no methods dir, exit silently
if [ ! -d "$METHODS_DIR" ]; then
  exit 0
fi

# For each methods doc, derive keywords and check if any appear in the prompt
matches=""
shopt -s nullglob
for doc in "$METHODS_DIR"/*.md; do
  base=$(basename "$doc" .md)
  # Skip if filename starts with underscore (private docs)
  case "$base" in _*) continue ;; esac

  # Tokenize on underscore + dash, keep tokens of length >= 4
  IFS='_- ' read -ra tokens <<< "$base"
  matched_token=""
  for tok in "${tokens[@]}"; do
    if [ ${#tok} -lt 4 ]; then continue; fi
    # Case-insensitive whole-word match in the prompt
    if echo "$PROMPT" | grep -qiE "\\b${tok}\\b"; then
      matched_token="$tok"
      break
    fi
  done

  if [ -n "$matched_token" ]; then
    rel_path="analysis/documentation/methods/$(basename "$doc")"
    matches="${matches}- ${rel_path} (matched on: ${matched_token})\n"
  fi
done

# If we have matches, emit a reminder block to stdout (injected into context)
if [ -n "$matches" ]; then
  printf "📚 Relevant methods reference(s) detected — read before implementing:\n%b\n" "$matches"
fi

exit 0
