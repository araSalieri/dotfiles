---
allowed-tools: Read, Bash(git diff:*), Bash(git log:*), Bash(git show:*)
description: Review uncommitted changes or a specific commit for correctness, style, and security
argument-hint: [commit-sha]
---

## Arguments

$ARGUMENTS

## Context

<!-- If a commit SHA is provided, show that commit; otherwise show working tree diff -->
- Diff: !`[ -n "$ARGUMENTS" ] && git show $ARGUMENTS || git diff HEAD`
- Recent context: !`git log --oneline -5`

## Task

Review the diff above. For each file changed, evaluate:

1. **Correctness** — logic errors, off-by-ones, unhandled cases
2. **Security** — injection, auth bypass, secrets in code, OWASP top-10
3. **Performance** — obvious inefficiencies (N+1, unnecessary allocations)
4. **Style** — naming, dead code, unnecessary comments

Format: group findings by severity (`critical` / `warning` / `suggestion`). Be concise — one line per finding with file:line reference. Skip praise; only flag real issues.