# AGENTS.md — Global

This file applies to every project on this machine, regardless of which repo you're currently in.

## Token efficiency

Respond like smart caveman. Cut all filler, keep technical substance.
- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- No hard wrap. One line per paragraph.
- Pattern: [thing] [action] [reason]. [next step].

## External memory repository

Memory for ALL projects lives outside them, in `/home/ara/memoria` (`<mem>`).

Schema — folders, page formats, ingest/query/lint — is `<mem>/AGENTS.md`, ~10KB. Auto-loaded only when cwd is memoria (its `CLAUDE.md` imports it). From any other project, read it only when actually writing to the vault (i.e. during a wrap), never to answer a question about it. Detail sits in `<mem>/.agents/pages.md` and `<mem>/.agents/ops.md`, read on demand — never preemptively.

Project = whatever dir you're working in (folder name, repo name if it differs). Never assume a specific one. Its file: `<mem>/04-projects-memory/<p>/<p>.md`.

### Session start

A SessionStart hook prints one line naming that file and its size. It prints the pointer only — the content is not loaded, so **Read it yourself**, once, before the first substantive action on the project. Until 2026-08-09 the hook printed the whole file; every session paid ~6KB for it whether or not the work touched what it described.

Default is to read. Skip only when the exchange will not touch the project's work at all — a shell one-liner, a question about an unrelated tool. Do not reason "this task looks self-contained, so history is irrelevant": that judgment is made without the history, and what the file holds is exactly the constraints you would not otherwise know to ask about.

"None yet" means the project has no memory — not an error, not a task. Don't create it; `/wrap` does that when there is finally something to record.

### Writing memory — only at the end

Snapshot, not journal — never an accumulating log.

Trigger: `/wrap`, the tail of `/wrap-commit`, or the user says so ("wrap up", "done for today", "update memory"). **Nothing else — `/commit` does not write memory.** Never volunteer it, never remind, never fire because the session feels long.

That split is deliberate: committing is cheap and frequent, recording is not, and a wrap on every commit meant memory got rewritten several times a session whether or not anything had changed. `/wrap-commit` is there for when the two genuinely go together. Either way every run re-reads the file first and writes nothing when it is already current.

Procedure lives in `claude/.claude/commands/wrap.md`. Short version: rewrite `Current state` / `Key decisions` / `Next steps`, folding into the prose (no dated entries); anything generalisable goes to `<mem>/02-wiki/` via Ingest; commit inside the memory repo, separate from any project commit; report in one line.

A killed terminal loses that session's memory outright. Nothing backfills it — catch-up was removed on 2026-08-09 because it was the last thing that wrote without being asked. Still not a reason to write early: the fix is to wrap before closing, not to hedge mid-session.

### Never `cd` into the memory repo

Use `git -C <mem> …`; if you did `cd`, `cd` back before ending the turn. Working dir persists across tool calls, so hooks, statusline and `/commit` would read memoria's git state instead of the project's. Every trip, not just the wrap.

### When cwd IS memoria

Its own AGENTS.md is authority on the vault schema.

memoria is still a project: memory at `04-projects-memory/memoria/memoria.md`, same read-at-start / write-at-wrap rules. Holds the vault's own state — tooling, generated assets, why the schema is shaped that way. Replaced an append-only `02-wiki/log.md` on 2026-08-04; any instruction to append a log entry after an ingest is stale.
