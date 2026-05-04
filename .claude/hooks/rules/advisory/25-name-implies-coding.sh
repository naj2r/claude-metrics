#!/usr/bin/env bash
# Advisory 25: variable names should imply their coding (Ouellet/Toffel §7, §11a).
# Flag clearly ambiguous names like 'gender', 'size', 'count' (not 'count_obs') in gen statements.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Names that DON'T imply coding well
BAD=$(echo "$CONTENT" | grep -nE '^\s*gen(erate)?\s+(gender|size|race|status|category|class|type)\s*=' 2>/dev/null || true)

if [ -n "$BAD" ]; then
  echo "ADVISORY [25-name-implies-coding]: variable name doesn't clearly imply its coding. Ouellet/Toffel §7: 'female' is better than 'gender'; 'log_employment' is better than 'size'. Lines: $BAD" >&2
fi
exit 0
