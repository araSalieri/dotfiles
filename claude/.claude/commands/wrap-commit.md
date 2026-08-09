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

!`cat ~/.claude/commit-rules.md`

## Then wrap memory

Once the commit succeeds, invoke the `wrap` skill. Do it after, not before, so the wrap sees the new commit in `git log`. It writes the project's memory file and commits that inside `/home/ara/memoria` — a separate repo, so it never touches the commit just made here.

Skip the wrap only if `git commit` failed or had nothing to commit. If the memory file already says everything this session established, the wrap records nothing and reports one line — that is the expected outcome when this runs a second time in one session, not a reason to skip it.
