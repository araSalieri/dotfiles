---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git log:*)
description: Stage all changes and create a terse conventional commit
---

## Context

- Git status: !`git status`
- Staged and unstaged diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits (for style reference): !`git log --oneline -10`

## Task

Write the commit message, then stage all modified/new files and create the commit in a single tool response.

Rules (kept inline, duplicated across the two command files rather than shared — a `!`cat`` of a file under `~/.claude/` only resolves when cwd is the dotfiles repo, since the sandbox refuses reads outside the session's working directory):
- Terse and exact. Why over what — the diff already says what changed.
- Never: "this commit does X", "I"/"we", "as requested by", emoji, or any AI attribution trailer.
- Conventional Commits: `<type>(<scope>): <imperative summary>`. Scope optional. Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon unless project history says otherwise. No trailing period.
- Body only when *why* is non-obvious; wrap at 72; bullets use `-`. Always write one for breaking changes, security fixes, migrations and reverts.
- If changes span multiple concerns, pick dominant type.
- Stage + commit in one tool response (single `git add … && git commit` chain). Pass message via heredoc to preserve formatting.

`commands/wrap-commit.md` carries the same rules; edit both when they change.
