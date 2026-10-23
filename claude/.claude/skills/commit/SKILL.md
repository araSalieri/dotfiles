---
name: commit
description: Commit working-tree changes with a terse Conventional Commits message. Use whenever creating a git commit.
---

Commit the current working-tree changes.

1. Run `git status --short && git diff --stat && git log --oneline -5` to see what changed and match the project's tone.
2. Stage the files that belong to the change by path (`git add <paths>`).
3. Write the message, check it against the rules below (subject length included), and commit with `git commit -F -` and a heredoc. If a hook rejects it, fix the message and commit again.

Message rules:
- Conventional Commits: `<type>(<scope>): <summary>`. Scope optional. Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Terse and exact. Why over what — the diff already says what changed.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon unless project history says otherwise. No trailing period.
- Body only when the why is non-obvious; write it as `-` bullets, one reason per bullet; wrap at 72. Always write a body for breaking changes, security fixes, migrations and reverts.
- The message ends with the subject or the last body bullet. Never: "this commit does X", "I"/"we", "as requested by", emoji, or any AI attribution trailer (Co-Authored-By, Generated-with, etc.).
- If changes span multiple concerns, pick the dominant type.
- Follow project history when it clearly deviates (check `git log` first).
