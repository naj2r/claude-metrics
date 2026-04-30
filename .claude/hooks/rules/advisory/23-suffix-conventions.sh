#!/usr/bin/env bash
# Advisory 23: generated transformed variables should use Ouellet/Toffel §7a suffixes:
#   _ln (log), _lnp1 (log(x+1)), _mz (missing→zero), _mm (missing→mean),
#   _miss (indicator), _cat (categorical from continuous).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

WARNINGS=""

# Check: gen <name> = log(<x>) or = ln(<x>) — name should end in _ln
LOG_NO_SUFFIX=$(echo "$CONTENT" | grep -nE '^\s*gen(erate)?\s+\w+\s*=\s*(log|ln)\(' 2>/dev/null | grep -vE '_ln\b' || true)
[ -n "$LOG_NO_SUFFIX" ] && WARNINGS="${WARNINGS}log/ln transformation without _ln suffix:$LOG_NO_SUFFIX\n"

# Check: gen <name> = log(<x>+1) — name should end in _lnp1
LNP1_NO_SUFFIX=$(echo "$CONTENT" | grep -nE 'log\(\w+\s*\+\s*1\)|ln\(\w+\s*\+\s*1\)' 2>/dev/null || true)
if [ -n "$LNP1_NO_SUFFIX" ]; then
  if ! echo "$LNP1_NO_SUFFIX" | grep -qE '_lnp1\b' 2>/dev/null; then
    WARNINGS="${WARNINGS}log(x+1) without _lnp1 suffix:$LNP1_NO_SUFFIX\n"
  fi
fi

if [ -n "$WARNINGS" ]; then
  echo "ADVISORY [23-suffix-conventions]: variable suffix conventions (Ouellet/Toffel §7a). $WARNINGS" >&2
fi
exit 0
