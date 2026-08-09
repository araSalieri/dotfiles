#!/usr/bin/env bash
# SessionStart hook: print the current project's memory file, creating a
# stub silently on first ever session for that project.
#
# Also runs the end-of-session catch-up: memory is meant to be written once,
# when a session wraps (`/wrap`), not nagged for mid-session. Nothing can make
# the model act after the session is gone, so instead this checks on the way
# in whether the *previous* session ended without touching memory, and asks
# for a backfill from that session's transcript.
set -u

MEM=/home/ara/memoria
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT=$(basename "$ROOT")

# Minimum transcript size, in bytes, for a previous session to be worth
# backfilling. Below this it was an aborted or trivial session with nothing
# to record. Raise it if catch-up fires on sessions that did nothing.
MIN_TRANSCRIPT_BYTES=20000

# The memory repo is a project like any other — basename resolves it to
# "memoria" and its file sits at the same path as everyone else's. It was
# skipped here until 2026-08-04, back when the vault tracked itself in
# 02-wiki/log.md instead.
[ -d "$MEM" ] || exit 0

FILE="$MEM/04-projects-memory/$PROJECT/$PROJECT.md"

# Hook payload: {"session_id":…,"transcript_path":…,"cwd":…,"source":…}
INPUT=$(cat 2>/dev/null || true)
SOURCE=$(printf '%s' "$INPUT" | jq -r '.source // empty' 2>/dev/null)
TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

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
  echo "Stub created at $FILE — leave it alone until the session wraps, then fill in Current state as part of /wrap."
  exit 0
fi

echo "## Project memory ($PROJECT)"
cat "$FILE"

# --- end-of-session catch-up -------------------------------------------------
# Only on a genuinely new session. On resume/clear/compact the newest transcript
# is this same conversation, so there is nothing to catch up on.
[ "$SOURCE" = "startup" ] || exit 0
[ -n "$TRANSCRIPT" ] || exit 0

PREV=$(find "$(dirname "$TRANSCRIPT")" -maxdepth 1 -name '*.jsonl' \
         ! -path "$TRANSCRIPT" -size +"$((MIN_TRANSCRIPT_BYTES / 1024))"k \
         -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

[ -n "$PREV" ] || exit 0
[ "$PREV" -nt "$FILE" ] || exit 0

cat <<EOF

## Catch-up: previous session ended without updating memory

Last session's transcript ($PREV) is newer than $FILE, so it wrapped without a
/wrap. Before answering the user's first request, skim that transcript and
backfill anything worth carrying forward into the memory file, then commit it
with \`git -C $MEM\`. Do this silently — one line at the end saying what you
recorded, no permission asking.

If the transcript turns out to hold nothing worth recording, say nothing at all
and just \`touch $FILE\` so this does not fire again.
EOF