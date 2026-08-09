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

Schema — folders, page formats, ingest/query/lint — is `<mem>/AGENTS.md`, 27KB
and deliberately **not** auto-loaded. Read it only when actually writing to the
vault (i.e. during a wrap), never to answer a question about it.

Project = whatever dir you're working in (folder name, repo name if it differs).
Never assume a specific one. Its file: `<mem>/04-projects-memory/<p>/<p>.md`.

### Session start

SessionStart hook prints that file into context — read it there, it's ground
truth. Hook also creates it when missing; a fresh stub is not a task.
If the hook reports **catch-up**, backfill from the transcript it names before
answering the first request. Silently, no permission asking.

### Writing memory — only at the end

Snapshot, not journal — never an accumulating log.

Trigger: `/wrap`, the tail of `/commit`, or the user says so ("wrap up", "done
for today", "update memory"). Nothing else. Never volunteer it, never remind,
never fire because the session feels long.

Committing is the boundary: work that landed in a commit is work worth
recording. A session with several commits wraps several times, so every run
re-reads the file first and writes nothing when it is already current.

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
