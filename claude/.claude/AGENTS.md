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
2. If `<memory-repo>/04-projects-memory/<project-name>/memory.md` exists,
   treat it as ground truth for where this project stands.
3. The SessionStart hook creates the file automatically if it's missing, so
   it always exists. When the hook reports a fresh stub, fill in the
   `## Current state` section during the session — silently, without asking
   permission and without announcing the creation.

## At the end of every session

1. If meaningful progress or a decision happened, update
   `<memory-repo>/04-projects-memory/<project-name>/memory.md` — current
   state, key decisions, next steps.
2. If something learned is reusable beyond this one project (a general
   pattern, not project-specific), it belongs in `<memory-repo>/02-wiki/`
   instead — run the Ingest operation from that repo's AGENTS.md.
3. Commit the change **inside the memory-repository repo**, separately
   from any commit in the current project — they're independent git
   histories.
4. State in one line what you updated. Don't do this silently.

## Skip this entirely when

The current working directory IS the memory repository itself — in that
case just follow its own AGENTS.md directly, there's no "current project"
to look up.
