# AGENTS.md — Global

This file applies to every project on this machine, regardless of which
repo you're currently in.

## Token efficiency

Respond like smart caveman. Cut all filler, keep technical substance.
- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: [thing] [action] [reason]. [next step].

## External memory repository

Memory for ALL projects lives outside them, in `/home/ara/memoria` (`<mem>`).
Schema — folders, page formats, ingest/query/lint — is that repo's `AGENTS.md`.

Project = whatever dir you're working in (folder name, repo name if it differs).
Never assume a specific one. Its file: `<mem>/04-projects-memory/<p>/<p>.md`.

### Session start

SessionStart hook prints that file into context — read it there, it's ground
truth. Hook also creates it when missing; a fresh stub is not a task.
If the hook reports **catch-up**, backfill from the transcript it names before
answering the first request. Silently, no permission asking.

### Writing memory — only at the end

Snapshot, not journal. Written once, at wrap. Never mid-session: facts written
at turn 10 are wrong by turn 40.

Trigger: `/wrap`, or the user says so ("wrap up", "done for today", "update
memory"). Never volunteer it, never remind, never fire because session feels
long.

Procedure lives in `claude/.claude/commands/wrap.md`. Short version: rewrite
`Current state` / `Key decisions` / `Next steps`, folding into the prose (no
dated entries); anything generalisable goes to `<mem>/02-wiki/` via Ingest;
commit inside the memory repo, separate from any project commit; report in one
line.

Killed terminal skips the wrap — SessionStart catch-up covers that. Not a
reason to write early.

### Never `cd` into the memory repo

Use `git -C <mem> …`; if you did `cd`, `cd` back before ending the turn. Working
dir persists across tool calls, so hooks, statusline and `/commit` would read
memoria's git state instead of the project's. Every trip, not just the wrap.

### When cwd IS memoria

Its own AGENTS.md is authority on the vault schema.

memoria is still a project: memory at `04-projects-memory/memoria/memoria.md`,
same read-at-start / write-at-wrap rules. Holds the vault's own state — tooling,
generated assets, why the schema is shaped that way. Replaced an append-only
`02-wiki/log.md` on 2026-08-04; any instruction to append a log entry after an
ingest is stale.
