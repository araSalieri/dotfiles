#!/usr/bin/env bash
# Print named sections of the memoria vault schema.
#
# memoria's AGENTS.md is not auto-loaded outside memoria itself. A wrap needs
# two small parts of it, so pull those by heading rather than reading the whole
# file or copying the format into the command (which would silently go stale
# when the schema changes).
#
# Usage: memoria-section.sh '## Project memory' '## Operations'
set -u

SCHEMA=${MEMORIA_SCHEMA:-/home/ara/memoria/AGENTS.md}
[ -f "$SCHEMA" ] || { echo "schema not found: $SCHEMA" >&2; exit 1; }

for heading in "$@"; do
  grep -qF -- "$heading" "$SCHEMA" || {
    echo "WARNING: heading '$heading' no longer in $SCHEMA — it was renamed or"
    echo "removed. Read the whole schema file instead, and fix this call."
    continue
  }
  awk -v want="$heading" '
    # Track fenced code blocks: sample frontmatter inside a section contains
    # "## " lines that must not be mistaken for the next heading.
    /^```/ { fence = !fence }

    # A heading at the same depth or shallower ends the section.
    !fence && found && /^#+ / {
      depth = index($0, " ") - 1
      if (depth <= want_depth) exit
    }

    !fence && !found && index($0, want) == 1 {
      found = 1
      want_depth = index($0, " ") - 1
    }

    found
  ' "$SCHEMA" || exit 1
done
