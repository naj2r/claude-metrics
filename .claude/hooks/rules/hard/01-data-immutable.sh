#!/usr/bin/env bash
# Hard rule 01: analysis/data/** is immutable. Block any Edit/Write to raw data.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

if [[ "$FILE_PATH" =~ /analysis/data/ ]] || [[ "$FILE_PATH" =~ ^analysis/data/ ]]; then
  block_violation "01-data-immutable" "Cannot modify files under analysis/data/. Raw data is immutable in this replication template. Write to analysis/processed/ or analysis/results/ instead. If you genuinely need to update raw data, do it manually outside Claude and document the change."
fi
exit 0
