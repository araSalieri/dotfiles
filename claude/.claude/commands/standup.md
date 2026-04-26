---
allowed-tools: Bash(git log:*), Bash(git diff:*)
description: Generate a standup summary from today's git activity across all repos
---

## Context

- Today's commits (this repo): !`git log --oneline --since="yesterday" --author="$(git config user.name)" 2>/dev/null || echo "none"`
- Uncommitted work in progress: !`git status --short`

## Task

Write a short standup update (3–5 bullet points) in the format:

**Yesterday / Today:**
- what was completed
- what is in progress

**Blockers:**
- any blockers, or "none"

Base it strictly on the git activity above. Keep each bullet to one line.