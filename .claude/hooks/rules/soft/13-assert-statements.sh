#!/usr/bin/env bash
# Soft rule 13: scripts that produce final reportable numbers should include 'assert' statements
# guarding key results. Specifically targets 4_make_tables_figures.do and similar.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Only flag for files that look like final-output scripts
case "$FILE_PATH" in
  */[0-9]_make_tables*.do|*/[0-9]_tables*.do|*/[0-9]_figures*.do|*/[0-9]_paper*.do|*/[0-9]_results*.do)
    if ! echo "$CONTENT" | grep -qE '^\s*assert\b' 2>/dev/null; then
      echo "[13-assert-statements] Tables/figures script appears to lack 'assert' statements. Reif Stata Coding Guide §Submission checklist: 'if the main result of your study is a regression estimate of \$1.2 million, include an assertion in your code that will fail should this number change following a new data update.' Add at least one assert guarding a key reported number."
      exit 1
    fi
    ;;
esac
exit 0
