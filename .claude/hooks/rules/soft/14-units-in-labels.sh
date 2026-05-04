#!/usr/bin/env bash
# Soft rule 14: variable labels should include units when the variable is numeric and external.
# Heuristic: any 'label variable X "..."' where the label has fewer than 4 words and no unit indicator.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Find label variable lines without unit-indicating words.
# Unit indicators: $, %, dollars, pounds, kg, years, count, rate, ratio, log, percent, share, mean, sd, std
SUSPICIOUS=$(echo "$CONTENT" | grep -nE '^\s*label\s+(variable|var)\s+\w+\s+"[^"]*"' 2>/dev/null | grep -ivE '\$|%|dollar|pound|kilogram|kg|year|count|rate|ratio|log|percent|share|mean|stdev|std|score|index|number|num\b|hours|seconds|minutes|days|weeks|months|miles|km|grams|liters|index|level|rank|prob|probability|odds|fraction' || true)

# Allow opt-out via inline `// no-unit-needed`
SUSPICIOUS=$(echo "$SUSPICIOUS" | grep -v 'no-unit-needed' || true)

if [ -n "$SUSPICIOUS" ]; then
  echo "[14-units-in-labels] Variable label may lack unit indicator. Ouellet/Toffel §7: 'Always include units in the label.' If unit doesn't apply, add inline comment '// no-unit-needed'. Lines: $SUSPICIOUS"
  exit 1
fi
exit 0
