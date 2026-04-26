---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git log:*)
description: Stage all changes and create a conventional commit
---

## Context

- Git status: !`git status`
- Staged and unstaged diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits (for style reference): !`git log --oneline -10`

## Task

Stage all modified/new files and create a single git commit following conventional commit format (`type: message`).

Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `style`.

Rules:
- Subject line max 72 chars, lowercase, no trailing period
- If changes span multiple concerns, use the dominant type
- Do not include a body unless the why is non-obvious from the diff
- Use a single tool response to stage and commit together