#!/usr/bin/env bash
# Hard rule 05: top-level scripts in analysis/scripts/ must match N_description.do
# (programs/ and libraries/ are exempt; _-prefixed files are exempt; _install_*.do is exempt)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# Only check top-level scripts/ files (not subdirectories like programs/, libraries/)
case "$FILE_PATH" in
  */analysis/scripts/programs/*) exit 0 ;;
  */analysis/scripts/libraries/*) exit 0 ;;
  */analysis/scripts/logs/*) exit 0 ;;
  */analysis/scripts/[0-9]*_*.do) exit 0 ;;
  */analysis/scripts/_*.do) exit 0 ;;
  */analysis/scripts/*.do)
    block_violation "05-numbered-scripts" "Top-level scripts in analysis/scripts/ must match the pattern N_description.do (e.g., 5_robustness.do). _-prefixed scripts (like _install_stata_packages.do) are also allowed. Use /new-script <N> <slug> to scaffold one correctly. File: $FILE_PATH"
    ;;
esac
exit 0
