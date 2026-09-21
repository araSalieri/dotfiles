---
name: commit
description: Creates a git commit — writes the commit message, stages all modified/new files, and commits in a single tool response. Use when the user asks to commit, commit changes, save/checkpoint work, or any git commit request.
---

# Commit

## Workflow

1. Run `git status --short && git diff --stat && git log --oneline -5` to see
   what changed and match the project's tone.
2. Write the commit message.
3. Stage all modified/new files and create the commit in a single tool response
   (one `git add … && git commit` chain). Pass the message via heredoc to
   preserve formatting:

```bash
git add -A && git commit -m "$(cat <<'EOF'
fix(auth): refresh token before expiry

Sessions expired mid-use because the refresh timer only ran on
page load.
EOF
)"
```

Never split staging and committing into separate tool responses. Never use
interactive editors or `git commit -am` as a substitute for explicit staging.

## Message rules

- Terse and exact. Why over what — the diff already says what changed.
- Never: "this commit does X", "I"/"we", "as requested by", emoji, or any AI
  attribution trailer (Co-Authored-By, Generated-with, etc.).
- Conventional Commits: `<type>(<scope>): <imperative summary>`. Scope
  optional. Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`,
  `build`, `ci`, `style`, `revert`.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon unless
  project history says otherwise. No trailing period.
- Body only when the *why* is non-obvious; wrap at 72; bullets use `-`.
  Always write a body for breaking changes, security fixes, migrations and
  reverts.
- If changes span multiple concerns, pick the dominant type.
- Follow project history when it clearly deviates (check `git log` first).
