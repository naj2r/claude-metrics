#!/usr/bin/env bash
# Advisory 22: operators should have spaces around them (Ouellet/Toffel §1e).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Find lines with operators jammed against operands. Heuristic: gen/replace/if statements.
SUSPICIOUS=$(echo "$CONTENT" | grep -nE '^\s*(gen|replace)\s+\w+=\w' 2>/dev/null | head -5 || true)
SUSPICIOUS2=$(echo "$CONTENT" | grep -nE 'if\s+\w+==\w|if\s+\w+>\w|if\s+\w+<\w' 2>/dev/null | head -5 || true)

if [ -n "$SUSPICIOUS" ] || [ -n "$SUSPICIOUS2" ]; then
  echo "ADVISORY [22-operator-spacing]: operators without surrounding spaces detected. Ouellet/Toffel §1e: 'gen bmi = weight_kg / (height_m ^ 2)' is preferred over 'gen bmi=weight_kg/(height_m^2)'. Sample lines: $SUSPICIOUS $SUSPICIOUS2" >&2
fi
exit 0
