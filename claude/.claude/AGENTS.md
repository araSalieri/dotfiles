# AGENTS.md — Global

This file applies to every project on this machine, regardless of which repo you're currently in.

## Token efficiency

Respond like smart caveman. Cut all filler, keep technical substance.
- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- No hard wrap. One line per paragraph.
- Pattern: [thing] [action] [reason]. [next step].

## External knowledge vault

`/home/ara/memoria` (`<mem>`) is a personal wiki kept outside every project. It holds no per-project memory — that layer was removed 2026-08-11, and nothing replaced it. Sessions start cold; don't hunt for a memory file, don't offer to write one.

The vault is written **on request only** — the human points at a source and asks for an ingest, or asks a question the pages answer. Never write to it on inference.

Schema — folders, page formats, ingest/query/lint — is `<mem>/AGENTS.md`, ~10KB. Auto-loaded only when cwd is memoria (its `CLAUDE.md` imports it). From any other project, read it only when actually writing to the vault, never to answer a question about it. Detail sits in `<mem>/.agents/pages.md` and `<mem>/.agents/ops.md`, read on demand — never preemptively.

### Never `cd` into the memory repo

Use `git -C <mem> …`; if you did `cd`, `cd` back before ending the turn. Working dir persists across tool calls, so the statusline and `/commit` would read memoria's git state instead of the project's. Every trip.

### When cwd IS memoria

Its own AGENTS.md is authority on the vault schema.
