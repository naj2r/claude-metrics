#!/usr/bin/env bash
# Hard rule 07: no `ssc install`, `net install`, `net from` inside .do files
# except _install_stata_packages.do. Forces vendored installation via /add-package.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# _install_stata_packages.do is the single place these are allowed.
if is_install_packages "$FILE_PATH"; then exit 0; fi

# Look for install commands
VIOLATIONS=$(echo "$CONTENT" | grep -nE '^\s*(ssc\s+install|net\s+install|net\s+from)\b' 2>/dev/null || true)

if [ -n "$VIOLATIONS" ]; then
  block_violation "07-no-inline-package-install" "Inline package install detected (ssc install / net install / net from). Packages must be vendored into analysis/scripts/libraries/stata/ via _install_stata_packages.do or the /add-package slash command. This ensures reproducibility — any user-written package version drift would silently change results. Offending lines: $VIOLATIONS"
fi
exit 0
