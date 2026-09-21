/**
 * Minimal editor: replaces pi's bordered input editor with a `>` prompt.
 *
 * Borderless (like a shapeless composer), but with a persistent
 * prompt glyph so the input area stays findable:
 *
 *   > █ first input line
 *     continuation lines align here
 *
 * - `>` is drawn through the editor's borderColor wiring, so it follows the
 *   existing indicators: theme thinking-level colors (retuned to accent in the
 *   dark-noborder theme) and green in bash mode.
 * - The old `─` top/bottom border rows are gone. Scroll indicators (`↑ N more`
 *   / `↓ N more`) still appear when content is scrolled out of view.
 * - Autocomplete rows align under the input; mouse hit-testing is offset-aware.
 */

import { CustomEditor } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER, visibleWidth } from "@earendil-works/pi-tui";
import type { TuiMouseEvent, TuiMouseEventResult } from "@earendil-works/pi-tui";

const GUTTER = 2;
const PROMPT = "> ";
const CONTINUATION = "  ";

type LayoutLine = { text: string; hasCursor: boolean; cursorPos?: number };
type VisualLine = { logicalLine: number; startCol: number; length: number };

/** The TS-private Editor members this override reaches into (runtime-stable). */
interface EditorInternals {
	paddingX: number;
	scrollOffset: number;
	lastWidth: number;
	renderedVisibleLineCount: number;
	renderedAutocompleteHeight: number;
	lastAction: "kill" | "yank" | "type-word" | null;
	autocompleteState: "regular" | "force" | null;
	autocompleteList?: {
		render(width: number): string[];
		handleMouse?(event: TuiMouseEvent): Record<string, unknown> | undefined;
	};
	state: { lines: string[] };
	layoutText(contentWidth: number): LayoutLine[];
	segment(text: string, mode: "word" | "grapheme"): Iterable<{ segment: string; index: number }>;
	buildVisualLineMap(width: number): VisualLine[];
	setCursorCol(col: number): void;
	exitHistoryBrowsing(): void;
	updateAutocomplete(): void;
}

function internals(editor: CustomEditor): EditorInternals {
	// SAFETY: CustomEditor and EditorInternals describe the same pi-tui editor
	// instance; the private internal fields exist at runtime but are untyped on
	// the public CustomEditor surface.
	return editor as unknown as EditorInternals;
}

class PromptEditor extends CustomEditor {
	private promptTopIndicator = false;
	private promptLinesBelow = 0;

	constructor(tui: unknown, theme: unknown, keybindings: unknown, options?: unknown) {
		super(tui as never, theme as never, keybindings as never, options as never);
	}

	override render(width: number): string[] {
		const s = internals(this);
		const maxPadding = Math.max(0, Math.floor((width - 1) / 2));
		const paddingX = Math.min(s.paddingX, maxPadding);
		const contentWidth = Math.max(1, width - paddingX * 2);

		// Reserve the 2-column prompt gutter in the wrapping width.
		const layoutWidth = Math.max(1, contentWidth - GUTTER - (paddingX ? 0 : 1));
		s.lastWidth = layoutWidth;

		const layoutLines = s.layoutText(layoutWidth);

		const terminalRows = this.tui.terminal.rows;
		const maxVisibleLines = Math.max(5, Math.floor(terminalRows * 0.3));

		let cursorLineIndex = layoutLines.findIndex((line) => line.hasCursor);
		if (cursorLineIndex === -1) cursorLineIndex = 0;

		if (cursorLineIndex < s.scrollOffset) {
			s.scrollOffset = cursorLineIndex;
		} else if (cursorLineIndex >= s.scrollOffset + maxVisibleLines) {
			s.scrollOffset = cursorLineIndex - maxVisibleLines + 1;
		}

		const maxScrollOffset = Math.max(0, layoutLines.length - maxVisibleLines);
		s.scrollOffset = Math.max(0, Math.min(s.scrollOffset, maxScrollOffset));

		const visibleLines = layoutLines.slice(s.scrollOffset, s.scrollOffset + maxVisibleLines);
		s.renderedVisibleLineCount = visibleLines.length;

		const result: string[] = [];
		const leftPadding = " ".repeat(paddingX);
		const rightPadding = leftPadding;

		// Scroll indicator replaces the old top border; nothing at all when not scrolled.
		this.promptTopIndicator = s.scrollOffset > 0;
		if (this.promptTopIndicator) {
			result.push(`${leftPadding}${this.borderColor(` ↑ ${s.scrollOffset} more `)}`);
		}

		const emitCursorMarker = this.focused;

		visibleLines.forEach((layoutLine, index) => {
			let displayText = layoutLine.text;
			let lineVisibleWidth = visibleWidth(layoutLine.text);
			let cursorInPadding = false;

			if (layoutLine.hasCursor && layoutLine.cursorPos !== undefined) {
				const before = displayText.slice(0, layoutLine.cursorPos);
				const after = displayText.slice(layoutLine.cursorPos);

				const marker = emitCursorMarker ? CURSOR_MARKER : "";

				if (after.length > 0) {
					const afterGraphemes = [...s.segment(after, "grapheme")];
					const firstGrapheme = afterGraphemes[0]?.segment || "";
					const restAfter = after.slice(firstGrapheme.length);
					displayText = before + marker + `\x1b[7m${firstGrapheme}\x1b[0m` + restAfter;
				} else {
					displayText = before + marker + "\x1b[7m \x1b[0m";
					lineVisibleWidth += 1;
					if (lineVisibleWidth > layoutWidth && paddingX > 0) cursorInPadding = true;
				}
			}

			const gutter = index === 0 ? this.borderColor(PROMPT) : CONTINUATION;
			const padding = " ".repeat(Math.max(0, contentWidth - GUTTER - lineVisibleWidth));
			const lineRightPadding = cursorInPadding ? rightPadding.slice(1) : rightPadding;
			result.push(`${leftPadding}${gutter}${displayText}${padding}${lineRightPadding}`);
		});

		const linesBelow = layoutLines.length - (s.scrollOffset + visibleLines.length);
		this.promptLinesBelow = linesBelow;
		if (linesBelow > 0) {
			result.push(`${leftPadding}${this.borderColor(` ↓ ${linesBelow} more `)}`);
		}

		s.renderedAutocompleteHeight = 0;
		if (s.autocompleteState && s.autocompleteList) {
			const autocompleteResult = s.autocompleteList.render(contentWidth - GUTTER);
			s.renderedAutocompleteHeight = autocompleteResult.length;
			for (const line of autocompleteResult) {
				const lineWidth = visibleWidth(line);
				const linePadding = " ".repeat(Math.max(0, contentWidth - GUTTER - lineWidth));
				result.push(`${leftPadding}${CONTINUATION}${line}${linePadding}${rightPadding}`);
			}
		}

		return result;
	}

	override handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
		const s = internals(this);
		const topIndicator = this.promptTopIndicator ? 1 : 0;

		if (s.autocompleteState && s.autocompleteList) {
			const bottomIndicator = this.promptLinesBelow > 0 ? 1 : 0;
			const autocompleteStartRow = topIndicator + s.renderedVisibleLineCount + bottomIndicator;
			if (event.y >= autocompleteStartRow && event.y < autocompleteStartRow + s.renderedAutocompleteHeight) {
				const maxPadding = Math.max(0, Math.floor((event.width - 1) / 2));
				const paddingX = Math.min(s.paddingX, maxPadding);
				const contentWidth = Math.max(1, event.width - paddingX * 2 - GUTTER);
				const result = s.autocompleteList.handleMouse?.({
					...event,
					x: event.x - paddingX - GUTTER,
					y: event.y - autocompleteStartRow,
					width: contentWidth,
					height: s.renderedAutocompleteHeight,
				});
				return result ? { ...result, focus: true } : undefined;
			}
		}

		// Leave press/drag/release unhandled so screen-level text selection still
		// works over editor rows (same contract as upstream).
		if (event.type !== "click" || event.button !== "left") return undefined;

		const row = event.y - topIndicator;
		if (row <= 0 || row > s.renderedVisibleLineCount) return { handled: true, focus: true };

		const visualLines = s.buildVisualLineMap(s.lastWidth);
		const visualLineIndex = s.scrollOffset + row - 1;
		const visualLine = visualLines[visualLineIndex];
		if (!visualLine) return { handled: true, focus: true };

		const logicalLine = s.state.lines[visualLine.logicalLine] ?? "";
		const chunkEnd = visualLine.startCol + visualLine.length;
		const chunk = logicalLine.slice(visualLine.startCol, chunkEnd);
		const maxPadding = Math.max(0, Math.floor((event.width - 1) / 2));
		const paddingX = Math.min(s.paddingX, maxPadding);
		const targetColumn = Math.max(0, event.x - paddingX - GUTTER);
		let visibleColumn = 0;
		let targetIndex = chunk.length;
		let lastGraphemeIndex = 0;
		for (const grapheme of s.segment(chunk, "grapheme")) {
			const nextColumn = visibleColumn + visibleWidth(grapheme.segment);
			lastGraphemeIndex = grapheme.index;
			if (targetColumn < nextColumn) {
				targetIndex = grapheme.index;
				break;
			}
			visibleColumn = nextColumn;
		}
		const isLastSegment =
			visualLineIndex === visualLines.length - 1 ||
			visualLines[visualLineIndex + 1]?.logicalLine !== visualLine.logicalLine;
		if (!isLastSegment && targetIndex === chunk.length && chunk.length > 0) targetIndex = lastGraphemeIndex;

		s.state.cursorLine = visualLine.logicalLine;
		s.setCursorCol(visualLine.startCol + targetIndex);
		s.lastAction = null;
		s.exitHistoryBrowsing();
		if (s.autocompleteState) s.updateAutocomplete();
		return { handled: true, focus: true };
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui: never, theme: never, keybindings: never) => {
			return new PromptEditor(tui, theme, keybindings);
		});
	});
}
