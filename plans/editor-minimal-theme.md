# Minimalist editor: `>` prompt instead of borders (pi)

## Context

The `dark-noborder` theme made pi's editor border invisible (black on black), which removed the
loud pink frame but left the input area hard to locate. The user wants the omp borderless-composer
look (`omp/.omp/agent/config.yml` → `composer.shape: borderless`, the current reference) for **pi
only**: no `─` border lines, just a `>` prompt glyph marking the input. Plus `editorPaddingX: 1`
for breathing room.

pi proper has no structural border option (the `─` lines are always drawn by `Editor.render()`),
but it has an extension API to replace the editor component entirely
(`ctx.ui.setEditorComponent(...)`). So the `>` prompt ships as a small extension.

## Approach

**1. Extension `~/.pi/agent/extensions/minimal-editor.ts`** – replaces the editor:

- `class PromptEditor extends CustomEditor` (`CustomEditor` is exported from
  `@earendil-works/pi-coding-agent`). Subclassing keeps all app behavior: keybindings,
  action handlers, working-status row, autocomplete, history, padding, scroll.
- Override `render(width): string[]` with an adapted copy of `Editor.render()`
  (original source recoverable from
  `node_modules/@earendil-works/pi-tui/dist/components/editor.js.map` → `sourcesContent`,
  or GitHub `packages/tui/src/components/editor.ts`). Changes vs. original:
  - Drop the unconditional top/bottom border pushes. Instead emit scroll indicators only when
    needed: top row ` ↑ N more ` when `scrollOffset > 0`, bottom row ` ↓ N more ` when lines
    below exist (reuse the `createScrollBorder` pattern, styled via `this.borderColor`).
  - First visible row gets a gutter prefix `this.borderColor("> ")`; continuation rows get
    plain `"  "` → uniform 2-column gutter on every row.
  - Reserve the gutter in layout: `layoutWidth = contentWidth - 2 - (paddingX ? 0 : 1)`;
    line padding becomes `contentWidth - 2 - lineVisibleWidth`.
  - Autocomplete block: prefix its rows with the same 2-col gutter so it aligns under the input.
  - Keep bookkeeping fields intact: `renderedVisibleLineCount`, `renderedAutocompleteHeight`,
    `lastWidth` (TUI + autocomplete rely on them).
- Colors route through `this.borderColor(...)` (never `theme.fg` directly) – interactive-mode
  keeps it updated (thinking level / bash mode), so the glyph follows existing wiring with zero
  extra code.
- Register on `session_start`:
  ```ts
  export default function (pi: ExtensionAPI) {
    pi.on("session_start", (_e, ctx) => {
      ctx.ui.setEditorComponent((tui, theme, keybindings) => new PromptEditor(tui, theme, keybindings));
    });
  }
  ```
  (`setCustomEditorComponent` copies text, onSubmit/onChange, borderColor, paddingX,
  autocomplete provider, and – via duck-typing `actionHandlers` – app handlers; verified in
  `interactive-mode.js` ~line 2126.)

**2. Theme `~/.pi/agent/themes/dark-noborder.json`** (name kept; hot-reloads):

- `thinkingOff/Minimal/Low/Medium/High/Xhigh/Max` → `"accent"` (uniform, quiet `>` at every
  level; kills the per-level neon incl. the old pink `#ff5fff`).
- `borderMuted` → `"darkGray"` (restores built-in value; mermaid renders use it).
- `bashMode` stays green → bash mode (Ctrl+T) turns the `>` green.
- `invisible` var: remove (no longer used).

**3. `~/.pi/agent/settings.json`** – add `"editorPaddingX": 1`.

**4. Dotfiles persistence** – copy the theme and extension into the repo and stow:

- `pi/.pi/agent/themes/dark-noborder.json`
- `pi/.pi/agent/extensions/minimal-editor.ts`
- `stow pi`

Out of scope: omp itself (user chose pi only). omp's composer already does borderless; if wanted
later, `omp gallery --surface composer` previews alternative shapes.

## Reuse

- `CustomEditor` + `CustomEditorOptions` from `@earendil-works/pi-coding-agent` (public exports).
- `ctx.ui.setEditorComponent` extension API (docs/extensions.md ~line 2679).
- `Editor.render()` original source: pi-tui sourcemap `sourcesContent` (verified extraction works).
- Existing theme file `~/.pi/agent/themes/dark-noborder.json` (edit in place).
- Extension file format per `examples/extensions/todo.ts` (default-export function, `pi.on`).

## Steps

- [x] Extract `Editor.render()` reference from pi-tui sourcemap
- [x] Write `minimal-editor.ts` (PromptEditor + session_start registration)
- [x] Retune theme tokens (thinking* → accent, borderMuted → darkGray, drop `invisible`)
- [x] Set `"editorPaddingX": 1` in settings.json
- [x] Restart pi; iterate on visuals if needed (theme hot-reloads; extension via `/reload`)
- [x] Copy theme + extension into `dotfiles/pi/.pi/agent/...`, `stow pi`

## Verification

- Empty editor shows `> ` + cursor block, no `─` lines above/below.
- Multi-line input: continuation rows align under the input (hanging indent), cursor intact.
- Long paste: `↑ N more` / `↓ N more` indicators appear when scrolled; no pink ever.
- Bash mode (Ctrl+T): `>` turns green; leaving restores accent.
- Working spinner row, autocomplete menu (type `/`), image paste all still behave.
- `editorPaddingX` 1 shows one column of breathing room either side.
- After `stow pi`, fresh shell → same look (theme + extension picked up from stowed paths).
