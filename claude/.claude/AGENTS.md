# AGENTS.md — Global

This file applies to every project on this machine, regardless of which
repo you're currently in.

## External memory repository

Project memory for ALL repos lives in one place, outside any individual
project:

**Memory repo:** `/home/ara/memoria`
**Schema:** see that repo's `AGENTS.md` for full conventions (folder
structure, page formats, ingest/query/lint workflows).

This file never names a specific project — the current project is
whatever directory you're working in (its folder name, or its repo name if
it differs). Never assume it's a particular project.

## At the start of every session

1. Determine the current project name (the SessionStart hook already does
   this and prints the matching memory file into context — check there
   first).
2. If `<memory-repo>/04-projects-memory/<project-name>/<project-name>.md` exists,
   treat it as ground truth for where this project stands.
3. The SessionStart hook creates the file automatically if it's missing, so
   it always exists. When the hook reports a fresh stub, fill in the
   `## Current state` section during the session — silently, without asking
   permission and without announcing the creation.

## At the end of every session

1. If meaningful progress or a decision happened, update
   `<memory-repo>/04-projects-memory/<project-name>/<project-name>.md` — current
   state, key decisions, next steps.
2. If something learned is reusable beyond this one project (a general
   pattern, not project-specific), it belongs in `<memory-repo>/02-wiki/`
   instead — run the Ingest operation from that repo's AGENTS.md.
3. Commit the change **inside the memory-repository repo**, separately
   from any commit in the current project — they're independent git
   histories.
4. State in one line what you updated. Don't do this silently.
5. **Return to the project directory afterwards.** Prefer `git -C
   <memory-repo> …` so the working directory never moves in the first
   place; if you did `cd` there, `cd` back before ending the turn.

Why: the shell's working directory persists across tool calls, and hooks,
slash commands and status lines read git state from wherever it happens to
be. Leave it in the memory repo and the next `/commit` reports that repo's
branch and a clean tree, hiding the project's real pending changes. This
applies to *any* trip into the memory repo — not just the end-of-session
one.

## When the current directory IS the memory repository

Follow its own AGENTS.md for everything about the vault's schema — that
file governs folder structure, page formats and the ingest/query/lint
workflows, and it is the authority there.

The project lookup above still applies, though: memoria is a project like
any other and its memory lives at the same path as everyone else's,
`04-projects-memory/memoria/memoria.md`. Read it at the start of the
session and update it at the end, exactly as you would for any repo. It
holds the state of the vault itself — its tooling, its generated assets,
and why the schema is shaped the way it is.

This replaced an append-only `02-wiki/log.md` on 2026-08-04. If you find
instructions anywhere telling you to append a log entry after an ingest
or an edit, they are stale; the file above is where that now goes, and
only when something is worth carrying to the next session.
