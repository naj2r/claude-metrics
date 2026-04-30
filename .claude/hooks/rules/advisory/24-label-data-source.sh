#!/usr/bin/env bash
# Advisory 24: variable labels should mention data source for variables sourced from external data.
# Heuristic: labels for variables created in 1_process_*.do should ideally reference the source.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi
case "$FILE_PATH" in
  */1_*.do|*/[0-9]*_process_*.do|*/[0-9]*_import_*.do) ;;
  *) exit 0 ;;
esac

# Count label variable lines and how many mention a source-like word
TOTAL=$(echo "$CONTENT" | grep -cE '^\s*label\s+(variable|var)\s+' 2>/dev/null || echo 0)
WITH_SOURCE=$(echo "$CONTENT" | grep -cE '^\s*label\s+(variable|var)\s+\w+\s+"[^"]*(source|from|via|dataset|survey|admin|register|panel)[^"]*"' 2>/dev/null || echo 0)

if [ "$TOTAL" -gt 0 ] && [ "$WITH_SOURCE" -eq 0 ]; then
  echo "ADVISORY [24-label-data-source]: import script has $TOTAL label-variable calls but none mention a data source. Ouellet/Toffel §7: 'when variables come from different data sources, the label should indicate the data source.'" >&2
fi
exit 0
