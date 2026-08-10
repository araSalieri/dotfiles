---
allowed-tools: Bash(git -C /home/ara/memoria:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Read, Edit, Write, Glob, Grep
description: Write this session's progress into the memory repo and commit it there — runs on its own or as the tail of /wrap-commit
---

## Context

- Memory repo: `/home/ara/memoria`
- Project root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Project changes this session: !`git status --short`
- Commits this session: !`git log --oneline -10`
- Memory repo status: !`git -C /home/ara/memoria status --short`
- Vault schema: !`cat /home/ara/memoria/AGENTS.md`

## Task

Close out the session. The project name is the basename of the project root above; its memory file is `/home/ara/memoria/04-projects-memory/<project>/<project>.md`.

`/wrap-commit` calls this every time, so it may run several times in one session. Make it idempotent: re-read the memory file, and if it already reflects where the project now stands, change nothing, skip the commit, and say so in one line. Never append the same fact twice, and never re-record what an earlier run this session already wrote.

The vault schema is in Context above. From any project other than memoria that file is not auto-loaded, to keep it off unrelated sessions — which is why a wrap pulls it in here. The part that governs this command is `## Project memory` (page format and budget).

**A wrap writes inside `04-projects-memory/<project>/` and nowhere else, and opens nothing.** Not `02-wiki/`, however generalisable the lesson felt, and no `xdg-open obsidian://` for anything — the vault's open-in-Obsidian step belongs to ingests and queries, which the human asked for. Ingest is an operation the human asks for by pointing at a source; a wrap inferring one on its own writes pages nobody requested. Linking to an existing `[[wiki-page]]` from the project file is fine — creating or editing one is not.

1. Read the memory file, then rewrite the parts this session invalidated — `## Current state`, `## Key decisions`, `## Next steps`. Fold new facts into the existing prose rather than appending a dated log entry; the file is a snapshot of where the project stands, not a journal. Bump `updated:` in the frontmatter. Convert relative dates ("yesterday") to absolute. If the file does not exist, this is the project's first wrap — create it, frontmatter and headings per the schema above. Nothing stubs it anymore.
2. Record only what the repo itself does not already say. Code structure, diffs and commit messages are recoverable from git — what belongs here is the reasoning, the dead ends, the constraints, and anything that would cost the next session an hour to rediscover.
3. **Delete as much as you add.** Every session that opens this file reads it in full, so it has a ~6KB budget — check with `wc -c`, never by line count, since one paragraph is one line here. Writing an update means also cutting what it superseded: finished work, decisions overtaken, the story of how something was debugged once it is fixed. One to three sentences per decision — the outcome plus why it still binds. If a full story is worth keeping, move it to a sibling (`debugging.md`, `history.md`) and leave a sentence and a link; siblings are not auto-loaded. Over budget after the rewrite is a signal to cut, not to split reflexively.
4. A lesson that outgrows the project still goes in the project's own files — a sibling is the place for it. Mention in the closing line that it looked generalisable, and let the human decide whether it earns a wiki page.
5. Commit inside the memory repo with `git -C /home/ara/memoria …` — never `cd` there, the working directory persists across tool calls and would make the next `/commit` report the wrong repo. Separate history from the project; do not touch the project's own working tree here. When the project *is* memoria they are one repo — stage only the memory file, so the wrap commit stays separate from whatever vault edits the session made.
6. Finish with one line naming what you recorded. If the session genuinely produced nothing worth keeping, say so and write nothing.
