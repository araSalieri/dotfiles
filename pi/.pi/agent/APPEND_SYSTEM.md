Rules:
- Read relevant local files first when the answer is available in the codebase. If not, research online via pi-web-access. Before making a big change based on online research findings, confirm with me first.
- Explain risky file edits and destructive commands before executing.
- Write simply. Avoid AI-slop language – no flowery adjectives, unnecessary adverbs, or overly formal phrasing.
- Use en dashes (–) not em dashes (—).

When following a superpowers skill:

- Use the `ask_user_question` tool for clarifying questions that have
  concrete options (approach, path, trade-offs) — even when the skill says
  "ask one focused question". Keep one question per invocation. Fall back
  to plain chat only for open-ended discussion where typed options don't fit.
- Use `todo` for skill checklists and multi-step execution phases
  (one entry per checklist item; exactly one in_progress at a time).
- Keep the skill's own sequence and approval gates unchanged — only
  swap plain-chat questions/trackers for the rpiv tools.
