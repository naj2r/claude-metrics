#!/usr/bin/env bash
# Soft rule 11: if random functions are used, 'set seed N' must appear earlier in the file.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Random function patterns: uniform(), runiform(), rnormal(, runiform_int(...
if echo "$CONTENT" | grep -qE '\b(runiform|rnormal|rbeta|rbinomial|rchi2|rgamma|rpoisson|rt\(|uniform\(|sample\b)' 2>/dev/null; then
  if ! echo "$CONTENT" | grep -qE '^\s*set\s+seed\s+\d+' 2>/dev/null; then
    echo "[11-set-seed] Random function detected (runiform/rnormal/etc) without 'set seed N'. Results will vary across runs. Reif Stata Coding Guide §Stata coding tips. Add 'set seed <N>' before the random function."
    exit 1
  fi
fi
exit 0
