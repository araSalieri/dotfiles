Rules:
- Ask me first for destructive commands before executing.
- Write simply. Avoid AI-slop language, no flowery adjectives, unnecessary adverbs, or overly formal phrasing.
- Use en dashes (–) not em dashes (—).
- Don't over-document. Write only what the reader needs.
- When documenting, don't wrap lines at a fixed width. Keep each paragraph or list item on one line.
- When running the grilling skill, ask each round with the AskUserQuestion tool (recommended answer as the first option) instead of the markdown format.
- When running implement-spec, create each implementer's worktree myself from the integration branch (`git worktree add -b ticket/N .claude/worktrees/ticket-N <integration-branch>`) and pass the path in the prompt. Don't use the Agent tool's `isolation: "worktree"`: it always bases on the default branch.
