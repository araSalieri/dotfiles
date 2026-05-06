---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git log:*), Skill(caveman:caveman-commit)
description: Stage all changes and create a caveman-style conventional commit
---

## Context

- Git status: !`git status`
- Staged and unstaged diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits (for style reference): !`git log --oneline -10`

## Task

Invoke the `caveman:caveman-commit` skill to generate the commit message,
then stage all modified/new files and create the commit in a single tool
response.

Rules:
- Message must follow the caveman-commit skill output verbatim — no edits,
  no extra prose, no AI attribution trailers.
- Conventional Commits: `<type>(<scope>): <imperative summary>`. Scope
  optional. Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`,
  `chore`, `build`, `ci`, `style`, `revert`.
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon
  unless project history says otherwise. No trailing period.
- Body only when *why* is non-obvious; wrap at 72; bullets use `-`.
- If changes span multiple concerns, pick dominant type.
- Stage + commit in one tool response (single `git add … && git commit`
  chain). Pass message via heredoc to preserve formatting.
