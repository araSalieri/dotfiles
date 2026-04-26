---
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(git push:*), Bash(git status:*), Bash(gh pr:*), Bash(gh repo:*)
description: Push the current branch and open a GitHub pull request
argument-hint: [base-branch]
---

## Arguments

$ARGUMENTS

## Context

- Current branch: !`git branch --show-current`
- Commits vs base: !`git log --oneline $(git merge-base HEAD ${ARGUMENTS:-main})..HEAD`
- Full diff vs base: !`git diff $(git merge-base HEAD ${ARGUMENTS:-main})..HEAD`
- Remote tracking status: !`git status -sb`

## Task

1. Push the current branch to origin (with `-u` if no upstream yet).
2. Create a GitHub PR targeting `$ARGUMENTS` (default: `main`) using `gh pr create`.

PR format:
```
Title: <type>: <short description> (≤ 70 chars)

## Summary
- bullet points of what changed and why

## Test plan
- [ ] steps to verify the change
```

Do not add emoji. Keep the summary factual and concise.