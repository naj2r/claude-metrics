#!/usr/bin/env bash
# Hard rule 04: only _config.do may set $MyProject, $DROPBOX, $ProjectDir.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if ! is_do_file "$FILE_PATH"; then exit 0; fi

# run.do is allowed to define $MyProject (it's the user-set entry point)
if [[ "$FILE_PATH" =~ /run\.do$ ]] || [[ "$FILE_PATH" =~ ^run\.do$ ]]; then
  exit 0
fi
# _config.do is exempt (it's the canonical setter)
if is_config_do "$FILE_PATH"; then exit 0; fi

# Look for `global X` or `global X =` for path globals
VIOLATIONS=$(echo "$CONTENT" | grep -nE '^\s*global\s+(MyProject|DROPBOX|ProjectDir)\b' 2>/dev/null || true)

if [ -n "$VIOLATIONS" ]; then
  block_violation "04-config-exclusivity" "Only _config.do (and run.do for the initial \$MyProject) may set project-path globals. Detected setting of \$MyProject/\$DROPBOX/\$ProjectDir in another file. Reason: paths must come from a single source of truth so coauthors only edit ONE place. Offending lines: $VIOLATIONS"
fi
exit 0
