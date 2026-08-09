---
allowed-tools: Bash(git -C /home/ara/memoria:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Read, Edit, Write, Glob, Grep
description: End-of-session wrap — write this session's progress into the memory repo and commit it there
---

## Context

- Memory repo: `/home/ara/memoria`
- Project root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Project changes this session: !`git status --short`
- Commits this session: !`git log --oneline -10`
- Memory repo status: !`git -C /home/ara/memoria status --short`

## Task

Close out the session. The project name is the basename of the project root
above; its memory file is
`/home/ara/memoria/04-projects-memory/<project>/<project>.md`.

1. Read that file, then rewrite the parts this session invalidated —
   `## Current state`, `## Key decisions`, `## Next steps`. Fold new facts into
   the existing prose rather than appending a dated log entry; the file is a
   snapshot of where the project stands, not a journal. Bump `updated:` in the
   frontmatter. Convert relative dates ("yesterday") to absolute.
2. Record only what the repo itself does not already say. Code structure,
   diffs and commit messages are recoverable from git — what belongs here is
   the reasoning, the dead ends, the constraints, and anything that would cost
   the next session an hour to rediscover.
3. If something learned generalises past this one project, it goes in
   `/home/ara/memoria/02-wiki/` instead — run the Ingest operation from that
   repo's `AGENTS.md`.
4. Commit inside the memory repo with `git -C /home/ara/memoria …` — never
   `cd` there, the working directory persists across tool calls and would make
   the next `/commit` report the wrong repo. Separate history from the project;
   do not touch the project's own working tree here.
5. Finish with one line naming what you recorded. If the session genuinely
   produced nothing worth keeping, say so and still `touch` the memory file so
   the next session's catch-up hook stays quiet.