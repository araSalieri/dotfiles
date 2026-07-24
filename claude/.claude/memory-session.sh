#!/usr/bin/env bash
# SessionStart hook: print the current project's memory file, creating a
# stub silently on first ever session for that project.
set -u

MEM=/home/ara/memoria
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT=$(basename "$ROOT")

# Inside the memory repo itself there is no "current project" to look up.
[ "$(pwd)" = "$MEM" ] && exit 0
[ -d "$MEM" ] || exit 0

FILE="$MEM/04-projects-memory/$PROJECT/$PROJECT.md"

if [ ! -f "$FILE" ]; then
  mkdir -p "$(dirname "$FILE")"
  cat >"$FILE" <<EOF
---
type: project-memory
title: $PROJECT
path: $ROOT
created: $(date +%F)
updated: $(date +%F)
status: active
---

## Current state

(stub — created automatically on first session, not yet filled in)

## Key decisions

## Next steps
EOF
  echo "## Project memory ($PROJECT)"
  echo "Stub created at $FILE — fill in Current state during this session, do not ask permission."
  exit 0
fi

echo "## Project memory ($PROJECT)"
cat "$FILE"
