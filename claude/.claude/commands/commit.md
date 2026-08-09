---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git log:*), Skill(wrap)
description: Stage all changes, create a terse conventional commit, then wrap memory
---

## Context

- Git status: !`git status`
- Staged and unstaged diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits (for style reference): !`git log --oneline -10`

## Task

Write the commit message, then stage all modified/new files and create the
commit in a single tool response.

Rules:
- Terse and exact. Why over what — the diff already says what changed.
- Never: "this commit does X", "I"/"we", "as requested by", emoji, or any AI
  attribution trailer.
- Conventional Commits: `<type>(<scope>): <imperative summary>`. Scope
  optional. Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`,
  `chore`, `build`, `ci`, `style`, `revert`.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon
  unless project history says otherwise. No trailing period.
- Body only when *why* is non-obvious; wrap at 72; bullets use `-`. Always
  write one for breaking changes, security fixes, migrations and reverts.
- If changes span multiple concerns, pick dominant type.
- Stage + commit in one tool response (single `git add … && git commit`
  chain). Pass message via heredoc to preserve formatting.

## Then wrap memory

Once the commit succeeds, invoke the `wrap` skill. Do it after, not before, so
the wrap sees the new commit in `git log`. It writes the project's memory file
and commits that inside `/home/ara/memoria` — a separate repo, so it never
touches the commit just made here.

Skip the wrap only if `git commit` failed or had nothing to commit. If the
memory file already says everything this session established, the wrap records
nothing and reports one line — that is the expected outcome for the second and
later commits of a session, not a reason to skip it.
