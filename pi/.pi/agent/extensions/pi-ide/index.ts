// pi-ide: two-way bridge between pi and Neovim over a loopback WebSocket MCP
// server. Neovim side: pi-ide.nvim (lock dir ~/.pi/ide).
//
// Neovim IDE integration for pi.
//
// pi auto-connects when nvim is open in the same cwd. While connected:
//   * pi sees your active selection (ambient context) — hovering/browsing
//     injects nothing; deliberate refs flow via <leader>ca/cA
//   * every pi write/edit opens as a two-pane diff — edit freely, `:w` to
//     accept, close the window to reject
//   * ghost-text suggestions served by the connected pi session
//   * pi can read your LSP diagnostics and open buffers
//   * nvim sends file:line refs into pi's editor input via <leader>ca/cA
//     (config/pi-queue.lua); refs are consumed when the message is sent
import { appendFile, readFile } from "node:fs/promises";
import { basename, relative as relativePath, resolve as resolvePath } from "node:path";
import type {
	ExtensionAPI,
	ExtensionContext,
	ExtensionUIContext,
} from "@earendil-works/pi-coding-agent";
import { IdeClient, isPidAlive, isPortListening, listLockfiles, type Lockfile, matchesCwd } from "./client.ts";
import {
	SUGGESTION_SYSTEM_PROMPT,
	buildSuggestionPrompt,
	parseSuggestionBlocks,
	prepareSuggestionCandidates,
	type SuggestionParams,
} from "./suggestion.ts";

const SUGGESTION_FLAG = "pi-ide-suggestion-model";
const SUGGESTION_DEBUG_LOG_FLAG = "pi-ide-suggestion-debug-log";

type Selection = { startLine: number; endLine: number; text: string };
type EditorState = { filePath: string | null; cursorLine: number | null; selection: Selection | null };
type Ref = { filePath: string; startLine?: number; endLine?: number };

// A line consisting solely of one or more @path refs, each with an optional
// :lines range, e.g. "@src/app.ts:10-20 @src/util.ts:5 @README.md".
const REF_LINE_RE = /^(?:@\S+(?::\d+(?:-\d+)?)?)(?:\s+@\S+(?::\d+(?:-\d+)?)?)*$/;

function formatRef(ref: Ref): string {
	const cwd = sessionCtx?.cwd;
	const p = cwd && ref.filePath.startsWith(`${cwd}/`)
		? relativePath(cwd, ref.filePath)
		: ref.filePath;
	if (ref.startLine === undefined || ref.endLine === undefined) return `@${p}`;
	const range = ref.startLine === ref.endLine ? `${ref.startLine + 1}` : `${ref.startLine + 1}-${ref.endLine + 1}`;
	return `@${p}:${range}`;
}

const MAX_SELECTION_LINES = 100;
const STATUS_KEY = "pi-ide";
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const SPINNER_INTERVAL_MS = 80;

// --- Autoconnect config & state ---
const STICKY_STATE_KEY = Symbol.for("pi-ide:sticky-state");

type StickyState = {
	lockfile?: Lockfile;
};

function isAutoconnectEnabled(): boolean {
	return process.env.PI_IDE_AUTOCONNECT !== "0";
}

// --- Sticky state helpers ---

function getStickyState(): StickyState {
	const g = globalThis as typeof globalThis & Record<symbol, StickyState | undefined>;
	g[STICKY_STATE_KEY] ??= {};
	return g[STICKY_STATE_KEY]!;
}

function setStickyLockfile(lockfile: Lockfile): void {
	getStickyState().lockfile = lockfile;
}

function clearStickyLockfile(): void {
	delete getStickyState().lockfile;
}

function getStickyLockfile(): Lockfile | undefined {
	return getStickyState().lockfile;
}

function sameLockfile(a: Lockfile, b: Lockfile): boolean {
	return a.port === b.port && a.pid === b.pid && a.authToken === b.authToken;
}

let client: IdeClient | null = null;
let state: EditorState = { filePath: null, cursorLine: null, selection: null };
let ui: ExtensionUIContext | null = null;
// ExtensionUIContext has no hasUI; carry it from the context at connect time.
let uiAvailable = false;
let sessionCtx: ExtensionContext | null = null;
let inFlightSuggestions = 0;
let spinnerTimer: ReturnType<typeof setInterval> | null = null;
let spinnerFrame = 0;

function disconnectFromIde(): void {
	if (!client) return;
	clearStickyLockfile();
	const old = client;
	client = null;
	old.close();
	resetState();
	inFlightSuggestions = 0;
	stopSpinner();
	renderStatus();
}

function resetState(): void {
	state = { filePath: null, cursorLine: null, selection: null };
}

function startSpinner(): void {
	if (spinnerTimer) return;
	spinnerTimer = setInterval(() => {
		spinnerFrame = (spinnerFrame + 1) % SPINNER.length;
		renderStatus();
	}, SPINNER_INTERVAL_MS);
}

function stopSpinner(): void {
	if (spinnerTimer) {
		clearInterval(spinnerTimer);
		spinnerTimer = null;
	}
	spinnerFrame = 0;
}

function renderStatus(): void {
	if (!ui) return;
	if (!client?.isConnected()) {
		ui.setStatus(STATUS_KEY, undefined);
		return;
	}
	const ideName = client.lockfile.ideName;
	let body: string;
	if (state.selection && state.filePath) {
		body = `${ideName} · Lines ${state.selection.startLine + 1}-${state.selection.endLine + 1} selected in ${basename(state.filePath)}`;
	} else if (state.filePath) {
		body = `${ideName} · In ${basename(state.filePath)}`;
	} else {
		body = ideName;
	}
	if (inFlightSuggestions > 0) {
		body += ` · Suggesting ${SPINNER[spinnerFrame]}`;
	}
	ui.setStatus(STATUS_KEY, body);
}

function logRefDebug(entry: Record<string, unknown>): void {
	const file = process.env.PI_IDE_REF_DEBUG;
	if (!file) return;
	void appendFile(file, `${JSON.stringify({ timestamp: new Date().toISOString(), ...entry })}\n`, "utf8").catch(
		() => {},
	);
}

function onNotification(method: string, params: unknown): void {
	if (method === "ref_queued") {
		const p = params as { filePath?: unknown; startLine?: unknown; endLine?: unknown };
		logRefDebug({ event: "ref_queued", params: p, ui: !!ui, uiAvailable });
		if (typeof p.filePath !== "string") return;
		const hasRange = typeof p.startLine === "number" && typeof p.endLine === "number";
		if (!hasRange && (p.startLine !== undefined || p.endLine !== undefined)) return;
		appendRefToEditor(
			hasRange
				? { filePath: p.filePath, startLine: p.startLine as number, endLine: p.endLine as number }
				: { filePath: p.filePath },
		);
		return;
	}
	if (method !== "selection_changed" || !params || typeof params !== "object") return;
	const p = params as {
		text?: string;
		filePath?: string;
		selection?: { start: { line: number }; end: { line: number }; isEmpty: boolean };
	};
	if (!p.filePath || !p.selection) return;
	state.filePath = p.filePath;
	state.cursorLine = p.selection.start.line;
	state.selection = p.selection.isEmpty
		? null
		: { startLine: p.selection.start.line, endLine: p.selection.end.line, text: p.text ?? "" };
	renderStatus();
}

/**
 * Append an @path:lines ref to the editor input, accumulating refs
 * space-separated on a single refs-only line, like Claude Code's Neovim
 * integration. Skipped if the identical ref already exists on that line.
 * No-ops when there is no TUI (RPC/print modes).
 */
function appendRefToEditor(ref: Ref): void {
	const current = ui?.getEditorText() ?? null;
	logRefDebug({ event: "appendRefToEditor", ref, hasUi: !!ui, uiAvailable, current });
	if (!ui || !uiAvailable || current === null) return;
	const line = formatRef(ref);
	const lines = current.split("\n");
	if (lines.some((l) => l.trim().split(/\s+/).includes(line))) return;
	// Accumulate refs space-separated on a single refs-only line.
	const lastIdx = lines.length - 1;
	if (REF_LINE_RE.test(lines[lastIdx].trim())) {
		lines[lastIdx] = `${lines[lastIdx].trimEnd()} ${line}`;
		ui.setEditorText(lines.join("\n"));
		return;
	}
	const base = current.trimEnd();
	ui.setEditorText(base ? `${base}\n${line}` : line);
}

function renderEditorBlock(): string | null {
	// Only an active selection is worth sending to the model. Hover/browsing
	// (cursor moved, nothing selected) injects nothing — deliberate context
	// still flows via the <refs> queue (<leader>ca/cA).
	if (!state.filePath || !state.selection) return null;
	const out = ["<editor>", `  <file>${state.filePath}</file>`];
	if (state.cursorLine !== null) out.push(`  <cursor>line ${state.cursorLine + 1}</cursor>`);
	if (state.selection) {
		const lines = state.selection.text.split("\n");
		const text =
			lines.length <= MAX_SELECTION_LINES
				? state.selection.text
				: `${lines.slice(0, MAX_SELECTION_LINES).join("\n")}\n... <truncated ${lines.length - MAX_SELECTION_LINES} more lines>`;
		out.push(`  <selection lines="${state.selection.startLine + 1}-${state.selection.endLine + 1}">`);
		out.push(text);
		out.push("  </selection>");
	}
	out.push("</editor>");
	return out.join("\n");
}

function parseDiffResult(result: { content?: { text?: string }[] }): { saved: boolean; text: string } {
	const items = result?.content ?? [];
	const marker = items[0]?.text;
	if (marker === "FILE_SAVED") return { saved: true, text: items[1]?.text ?? "" };
	return { saved: false, text: "" };
}

const MAX_DIAGNOSTICS = 50;

type Diagnostic = {
	severity: string;
	message: string;
	source?: string;
	range: { start: { line: number; character: number }; end: { line: number; character: number } };
};

async function fetchDiagnosticsBlock(): Promise<string | null> {
	if (!client?.isConnected()) return null;
	let result: { content?: { text?: string }[] };
	try {
		result = await client.callTool("getDiagnostics", {});
	} catch {
		return null;
	}
	const text = result?.content?.[0]?.text;
	if (!text) return null;
	let parsed: Record<string, Diagnostic[]>;
	try {
		parsed = JSON.parse(text);
	} catch {
		return null;
	}
	const lines: string[] = [];
	for (const [uri, items] of Object.entries(parsed)) {
		for (const d of items) {
			if (d.severity !== "Error" && d.severity !== "Warning") continue;
			lines.push(
				`${uri}:${d.range.start.line + 1}:${d.range.start.character + 1} [${d.severity}] ${d.message}`,
			);
			if (lines.length >= MAX_DIAGNOSTICS) break;
		}
		if (lines.length >= MAX_DIAGNOSTICS) break;
	}
	if (lines.length === 0) return null;
	return `<lsp_diagnostics>\n${lines.join("\n")}\n</lsp_diagnostics>`;
}

async function logSuggestionDebug(
	pi: ExtensionAPI,
	entry: {
		model: string;
		params: SuggestionParams;

		userText: string;
		durationMs: number;
		stopReason: string;
		usage?: unknown;
		rawText: string;
		parsedBlocks: string[];
		returnedSuggestions: string[];
	},
): Promise<void> {
	const flagValue = pi.getFlag(SUGGESTION_DEBUG_LOG_FLAG);
	if (typeof flagValue !== "string" || !flagValue.trim()) return;
	try {
		await appendFile(
			flagValue.trim(),
			`${JSON.stringify({ timestamp: new Date().toISOString(), ...entry }, null, 2)}\n---\n`,
			"utf8",
		);
	} catch {
		// Debug logging must never break suggestions.
	}
}

/**
 * Resolve the suggestion model. Precedence: CLI flag (operator override) >
 * editor-provided preference > current session model.
 */
function resolveSuggestionModel(pi: ExtensionAPI, ctx: ExtensionContext, editorPref: string | undefined) {
	const flagValue = pi.getFlag(SUGGESTION_FLAG);
	const pick = (typeof flagValue === "string" && flagValue) ? flagValue : (editorPref || "");
	if (pick) {
		// Format "provider/id"; provider ids never contain "/", model ids may.
		const slash = pick.indexOf("/");
		if (slash <= 0) throw new Error(`invalid model format (expected provider/id): ${pick}`);
		const m = ctx.modelRegistry.find(pick.slice(0, slash), pick.slice(slash + 1));
		if (!m) throw new Error(`model not found: ${pick}`);
		return m;
	}
	if (!ctx.model) throw new Error("no current model, no editor-provided model, and --pi-ide-suggestion-model not set");
	return ctx.model;
}

async function generateSuggestions(pi: ExtensionAPI, params: SuggestionParams, signal: AbortSignal): Promise<string[]> {
	try {
		if (!sessionCtx) throw new Error("session not yet started");
		const ctx = sessionCtx;
		const model = resolveSuggestionModel(pi, ctx, params.model);

		const userText = buildSuggestionPrompt(params);
		const startedAt = Date.now();
		// streamSimple resolves provider auth internally (unlike raw pi-ai calls).
		const response = await ctx.modelRegistry
			.streamSimple(
				model,
				{
					systemPrompt: SUGGESTION_SYSTEM_PROMPT,
					messages: [
						{
							role: "user",
							content: [{ type: "text", text: userText }],
							timestamp: Date.now(),
						},
					],
				},
				{
				maxTokens: 2048,
				// Ghost text needs fast raw output; keep reasoning minimal so
				// thinking models don't burn the token budget before emitting text.
				reasoning: "minimal",
				signal,
				cacheRetention: "short",
				},
			)
			.result();
		if (response.stopReason === "error" || response.stopReason === "aborted") {
			throw new Error(response.errorMessage ?? `suggestion model stopped with ${response.stopReason}`);
		}
		const text = response.content
			.filter((c): c is { type: "text"; text: string } => c.type === "text")
			.map((c) => c.text)
			.join("");
		const blocks = parseSuggestionBlocks(text);
		const returnedSuggestions = prepareSuggestionCandidates(blocks, params);
		await logSuggestionDebug(pi, {
			model: `${model.provider}/${model.id}`,
			params,
			userText,
			durationMs: Date.now() - startedAt,
			stopReason: response.stopReason,
			usage: response.usage,
			rawText: text,
			parsedBlocks: blocks,
			returnedSuggestions,
		});
		return returnedSuggestions;
	} catch (err) {
		console.error(`pi-ide suggestions failed: ${err instanceof Error ? err.message : String(err)}`);
		return [];
	}
}

type PickResult =
	| { kind: "selected"; lockfile: Lockfile }
	| { kind: "none" }
	| { kind: "cancelled" };

async function pickLockfile(
	cwd: string,
	ui: { select: (t: string, o: string[]) => Promise<string | undefined> },
	current?: Lockfile,
): Promise<PickResult> {
	const candidates = await findCandidateLockfiles(cwd);
	if (candidates.length === 0) return { kind: "none" };
	const labels = candidates.map((c) => {
		const folder = c.workspaceFolders[0] ?? "?";
		const marker = current && c.port === current.port && c.pid === current.pid ? " · (connected)" : "";
		return `${c.ideName} · ${folder} · pid=${c.pid} port=${c.port}${marker}`;
	});
	const title = current ? "Select IDE (toggle to disconnect)" : "Connect to IDE";
	const choice = await ui.select(title, labels);
	if (!choice) return { kind: "cancelled" };
	const lockfile = candidates[labels.indexOf(choice)];
	return lockfile ? { kind: "selected", lockfile } : { kind: "cancelled" };
}

/**
 * Find lockfiles that match the given cwd, have a live PID, and are listening.
 */
async function findCandidateLockfiles(cwd: string): Promise<Lockfile[]> {
	const all = await listLockfiles();
	const candidates: Lockfile[] = [];
	for (const lf of all) {
		if (!matchesCwd(lf, cwd)) continue;
		if (!isPidAlive(lf.pid)) continue;
		if (!(await isPortListening(lf.port))) continue;
		candidates.push(lf);
	}
	return candidates;
}

/**
 * Create an IdeClient, wire up handlers, and connect.
 */
async function connectToLockfile(lockfile: Lockfile, ctx: ExtensionContext, pi: ExtensionAPI): Promise<IdeClient | null> {
	const next = new IdeClient(lockfile);
	ui = ctx.ui;
	uiAvailable = ctx.hasUI;
	next.onNotification = onNotification;
	next.onRequest("getSuggestions", async (params, signal) => {
		inFlightSuggestions++;
		if (inFlightSuggestions === 1) startSpinner();
		renderStatus();
		try {
			const suggestions = await generateSuggestions(pi, (params ?? {}) as SuggestionParams, signal);
			return { suggestions };
		} finally {
			inFlightSuggestions--;
			if (inFlightSuggestions === 0) stopSpinner();
			renderStatus();
		}
	});
	next.onRequest("listSuggestionModels", async () => {
		if (!sessionCtx) throw new Error("session not yet started");
		const flagValue = pi.getFlag(SUGGESTION_FLAG);
		const cliOverride = (typeof flagValue === "string" && flagValue) ? flagValue : undefined;
		return {
			cliOverride,
			currentModel: sessionCtx.model ? `${sessionCtx.model.provider}/${sessionCtx.model.id}` : undefined,
			models: sessionCtx.modelRegistry.getAvailable().map((model) => ({
				provider: model.provider,
				id: model.id,
				name: model.name,
				model: `${model.provider}/${model.id}`,
			})),
		};
	});
	next.onClose = () => {
		if (client === next) {
			client = null;
			resetState();
			inFlightSuggestions = 0;
			stopSpinner();
			renderStatus();
			ui?.notify("IDE disconnected", "warning");
		}
	};
	try {
		await next.connect();
	} catch (err) {
		ctx.ui.notify(`Failed to connect: ${err instanceof Error ? err.message : String(err)}`, "error");
		return null;
	}
	client = next;
	setStickyLockfile(lockfile);
	renderStatus();
	return next;
}

/**
 * Auto-connect to an IDE.
 *
 * When `preferSticky` is true (session replacement flow), tries the sticky
 * IDE from the previous session first, bypassing the single-candidate rule.
 * Falls back to the cold-start rule when sticky is absent or stale.
 *
 * When `preferSticky` is false (cold startup), connects only when exactly one
 * valid IDE candidate exists for the cwd.
 */
async function autoConnect(ctx: ExtensionContext, pi: ExtensionAPI, options: { preferSticky: boolean }): Promise<void> {
	if (client?.isConnected()) return;
	if (!isAutoconnectEnabled()) return;

	let candidates = await findCandidateLockfiles(ctx.cwd);

	if (options.preferSticky) {
		const sticky = getStickyLockfile();
		if (sticky) {
			const candidate = candidates.find((c) => sameLockfile(c, sticky));
			if (candidate) {
				const connected = await connectToLockfile(candidate, ctx, pi);
				if (connected) {
					ctx.ui.notify(`Reconnected to ${candidate.ideName}`, "info");
					return;
				}
				// Treat a failed sticky reconnect as stale. Do not retry the
				// same lockfile in the cold-start fallback below.
				clearStickyLockfile();
				candidates = candidates.filter((c) => !sameLockfile(c, candidate));
			} else {
				// Sticky IDE is gone; clear it and fall through to cold start logic.
				clearStickyLockfile();
			}
		}
	}

	if (candidates.length !== 1) return;
	const lockfile = candidates[0];
	const connected = await connectToLockfile(lockfile, ctx, pi);
	if (connected) {
		ctx.ui.notify(`Auto-connected to ${lockfile.ideName}`, "info");
	}
}

// --- Diff routing (write + edit tools) ---

/**
 * Route a write tool call through the IDE diff view. Mutates `event.input`
 * in place with the accepted content, or returns a block result on reject.
 */
async function routeWrite(
	event: { toolCallId: string; input: { path?: unknown; content?: unknown } },
	ctx: ExtensionContext,
): Promise<{ block?: boolean; reason?: string } | undefined> {
	const input = event.input as { path?: unknown; content?: unknown };
	const rawPath = typeof input.path === "string" ? input.path : "";
	// Internal URLs (xd://, archive:, db:, local:, etc.) and other scheme
	// targets must NOT be routed through the editor.
	if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(rawPath)) return;

	const path = resolvePath(ctx.cwd, rawPath);
	const proposedContent = typeof input.content === "string" ? input.content : "";

	const tabName = `pi-write:${event.toolCallId}`;
	let result: { content?: { text?: string }[] };
	try {
		result = await client!.callTool("openDiff", {
			old_file_path: path,
			new_file_path: path,
			new_file_contents: proposedContent,
			tab_name: tabName,
		});
	} catch (err) {
		ctx.ui.notify(`IDE diff failed: ${err instanceof Error ? err.message : String(err)}`, "warning");
		return;
	}
	void client!.callTool("close_tab", { tab_name: tabName }).catch(() => {});
	const parsed = parseDiffResult(result);
	if (!parsed.saved) return { block: true, reason: `user rejected the write in IDE` };
	// Replace the content with what the user accepted in the editor.
	input.content = parsed.text;
	return undefined;
}

/**
 * Route an edit tool call through the IDE diff view. Computes the proposed
 * content from the current file plus the requested replacements, shows the
 * diff, and on accept rewrites the input as a single whole-file replacement
 * (oldText = current content, newText = accepted content) so the edit tool
 * reproduces exactly what the user approved — including any hand-edits made
 * in the diff buffer.
 */
async function routeEdit(
	event: { toolCallId: string; input: { path?: unknown; edits?: unknown } },
	ctx: ExtensionContext,
): Promise<{ block?: boolean; reason?: string } | undefined> {
	const input = event.input as { path?: string; edits?: { oldText: string; newText: string }[] };
	const rawPath = typeof input.path === "string" ? input.path : "";
	if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(rawPath)) return;
	if (!Array.isArray(input.edits) || input.edits.length === 0) return;

	const path = resolvePath(ctx.cwd, rawPath);
	let original: string;
	try {
		original = await readFile(path, "utf8");
	} catch {
		// Missing/unreadable file: let the tool run and fail on its own terms.
		return;
	}

	// Replicate the edit tool's sequential application to preview the result.
	let proposed = original;
	for (const e of input.edits) {
		if (typeof e?.oldText !== "string" || typeof e?.newText !== "string") return;
		if (!proposed.includes(e.oldText)) return; // let the tool produce its own error
		proposed = proposed.replace(e.oldText, e.newText);
	}

	const tabName = `pi-edit:${event.toolCallId}`;
	let result: { content?: { text?: string }[] };
	try {
		result = await client!.callTool("openDiff", {
			old_file_path: path,
			new_file_path: path,
			new_file_contents: proposed,
			tab_name: tabName,
		});
	} catch (err) {
		ctx.ui.notify(`IDE diff failed: ${err instanceof Error ? err.message : String(err)}`, "warning");
		return;
	}
	void client!.callTool("close_tab", { tab_name: tabName }).catch(() => {});
	const parsed = parseDiffResult(result);
	if (!parsed.saved) return { block: true, reason: `user rejected the edit in IDE` };
	// Collapse the multi-edit input into one exact whole-file replacement of
	// what the user accepted. The edit tool matches oldText against the file
	// at execution time; if the file changed since our read, the edit tool
	// reports its own error and the model can retry.
	input.edits = [{ oldText: original, newText: parsed.text }];
	return undefined;
}

export default function (pi: ExtensionAPI) {
	pi.registerFlag(SUGGESTION_FLAG, {
		type: "string",
		description: "Model to use for inline suggestions (format: provider/id). Falls back to current session model.",
	});
	pi.registerFlag(SUGGESTION_DEBUG_LOG_FLAG, {
		type: "string",
		description: "Path to append raw inline suggestion debug logs.",
	});

	pi.on("session_start", async (event, ctx) => {
		sessionCtx = ctx;
		// startup = cold start; reload/new/resume/fork can reuse the sticky IDE.
		await autoConnect(ctx, pi, { preferSticky: event.reason !== "startup" });
	});

	pi.registerCommand("ide", {
		description: "Connect to a running IDE for ambient context and IDE-routed diffs. Select the current IDE to disconnect.",
		async handler(_args, ctx) {
			const wasConnected = client?.isConnected() ?? false;
			const currentLockfile = wasConnected ? client!.lockfile : undefined;
			const pick = await pickLockfile(ctx.cwd, ctx.ui, currentLockfile);
			if (pick.kind === "cancelled") return;

			if (wasConnected) {
				if (pick.kind === "none") {
					disconnectFromIde();
					ctx.ui.notify(`Disconnected from ${currentLockfile!.ideName}`, "warning");
					return;
				}
				const same =
					pick.lockfile.port === currentLockfile!.port &&
					pick.lockfile.pid === currentLockfile!.pid;
				if (same) {
					disconnectFromIde();
					ctx.ui.notify(`Disconnected from ${currentLockfile!.ideName}`, "warning");
					return;
				}
				// Switch to a different IDE
				disconnectFromIde();
			}

			if (pick.kind === "none") {
				ctx.ui.notify("No running IDE found for this project", "warning");
				return;
			}

			await connectToLockfile(pick.lockfile, ctx, pi);
		},
	});

	pi.on("context", async (event) => {
		const blocks: string[] = [];
		const editor = renderEditorBlock();
		if (editor) blocks.push(editor);
		const diagnostics = await fetchDiagnosticsBlock();
		if (diagnostics) blocks.push(diagnostics);
		if (blocks.length === 0) return;
		return {
			messages: [
				...event.messages,
				{
					role: "custom",
					customType: "pi-ide.editor-context",
					content: blocks.join("\n\n"),
					display: false,
					timestamp: Date.now(),
				},
			],
		};
	});

	pi.on("tool_call", async (event, ctx) => {
		if (!client?.isConnected()) return;
		if (event.toolName === "write") {
			return routeWrite(event as never, ctx);
		}
		if (event.toolName === "edit") {
			return routeEdit(event as never, ctx);
		}
		return undefined;
	});

	pi.on("session_shutdown", () => {
		client?.close();
		inFlightSuggestions = 0;
		stopSpinner();
		renderStatus();
		client = null;
		resetState();
	});
}
