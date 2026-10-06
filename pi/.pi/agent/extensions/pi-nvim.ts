/**
 * pi-nvim — one-way bridge from Neovim into a running pi session.
 *
 * Nvim pushes three things over a unix socket, nothing flows back to the
 * editor (no ambient context, no diff routing, no suggestions):
 *
 *   { "type": "ref", "filePath": "...", "startLine"?: n, "endLine"?: n }
 *       Appends an `@path[:a-b]` token to the editor input, where it
 *       accumulates until the message is sent (queue mode, <leader>ca/cf).
 *   { "type": "prompt", "message": "..." }
 *       Immediately sends the message as a follow-up (immediate sends).
 *   { "type": "ping" }  ->  { "ok": true, "type": "pong" }
 *
 * Socket conventions match the carderne/pi-nvim plugin so the nvim-side
 * discovery logic is shared: /tmp/pi-nvim-sockets/<md5(cwd)12>-<pid>.sock
 * with a .info manifest next to it, plus a /tmp/pi-nvim-latest.sock symlink.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import * as net from "node:net";
import * as fs from "node:fs";
import * as path from "node:path";

const SOCKETS_DIR = "/tmp/pi-nvim-sockets";
const LATEST_LINK = "/tmp/pi-nvim-latest.sock";

type Ref = { filePath: string; startLine?: number; endLine?: number };

function cwdHash(cwd: string): string {
	// NOTE: must stay in sync with any other client of the same dir.
	return Buffer.from(cwd).toString("base64url").slice(0, 16);
}

function socketPath(cwd: string): string {
	return path.join(SOCKETS_DIR, `${cwdHash(cwd)}-${process.pid}.sock`);
}

function relativeTo(cwd: string, p: string): string {
	if (p === cwd) return ".";
	if (p.startsWith(cwd + "/")) return p.slice(cwd.length + 1);
	return p;
}

function formatRef(ref: Ref, cwd: string): string {
	const p = relativeTo(cwd, ref.filePath);
	if (ref.startLine === undefined || ref.endLine === undefined) return `@${p}`;
	const range =
		ref.startLine === ref.endLine ? `${ref.startLine + 1}` : `${ref.startLine + 1}-${ref.endLine + 1}`;
	return `@${p}:${range}`;
}

export default function (pi: ExtensionAPI) {
	let server: net.Server | null = null;
	let sockPath: string | null = null;
	let sessionCtx: ExtensionContext | null = null;

	pi.on("session_start", async (_event, ctx) => {
		sessionCtx = ctx;
		try {
			fs.mkdirSync(SOCKETS_DIR, { recursive: true });
		} catch (e) {
			// Best effort; a missing dir fails later at listen(), which reports.
			void e;
		}
		sockPath = socketPath(ctx.cwd);
		try {
			fs.unlinkSync(sockPath);
		} catch {}

		server = net.createServer((conn) => {
			let buffer = "";
			conn.on("data", (data) => {
				buffer += data.toString();
				let nl: number;
				while ((nl = buffer.indexOf("\n")) !== -1) {
					const line = buffer.slice(0, nl).trim();
					buffer = buffer.slice(nl + 1);
					if (line) handleMessage(line, conn, ctx.cwd);
				}
			});
			conn.on("error", () => {});
		});

		server.listen(sockPath, () => {
			// LATEST_LINK ownership races between concurrent sessions; ignore.
			try {
				fs.unlinkSync(LATEST_LINK);
			} catch (e) {
				void e;
			}
			try {
				fs.symlinkSync(sockPath!, LATEST_LINK);
			} catch (e) {
				void e;
			}
			try {
				fs.writeFileSync(
					sockPath! + ".info",
					JSON.stringify({
						socket: sockPath,
						cwd: ctx.cwd,
						pid: process.pid,
						startedAt: new Date().toISOString(),
					}),
				);
			} catch {}
		});

		server.on("error", (err) => {
			ctx.ui.notify(`pi-nvim error: ${err.message}`, "error");
		});
	});

	function respond(conn: net.Socket, obj: Record<string, unknown>) {
		// Broken client pipe: nothing to do, the connection is dying anyway.
		try {
			conn.write(JSON.stringify(obj) + "\n");
		} catch (e) {
			void e;
		}
	}

	function handleMessage(raw: string, conn: net.Socket, cwd: string) {
		let msg: any;
		try {
			msg = JSON.parse(raw);
		} catch (e: any) {
			respond(conn, { ok: false, error: `Parse error: ${e.message}` });
			return;
		}

		if (msg.type === "ping") {
			respond(conn, { ok: true, type: "pong" });
			return;
		}

		if (msg.type === "prompt" && typeof msg.message === "string") {
			// Snap the TUI back to the input line (kitty scrollback safe).
			process.stdout.write("\x1b[?1049h\x1b[?1049l");
			pi.sendUserMessage(msg.message, { deliverAs: "followUp" });
			respond(conn, { ok: true });
			return;
		}

		if (msg.type === "ref") {
			const p = msg as Ref;
			if (typeof p.filePath !== "string" || p.filePath === "") {
				respond(conn, { ok: false, error: "ref requires filePath" });
				return;
			}
			const hasRange = typeof p.startLine === "number" && typeof p.endLine === "number";
			if (!hasRange && (p.startLine !== undefined || p.endLine !== undefined)) {
				respond(conn, { ok: false, error: "ref range incomplete" });
				return;
			}
			const err = appendRefToEditor(hasRange ? p : { filePath: p.filePath }, cwd);
			respond(conn, err ? { ok: false, error: err } : { ok: true });
			return;
		}

		respond(conn, { ok: false, error: `Unknown command type: ${msg.type}` });
	}

	/**
	 * Append an @path[:a-b] token at the end of the editor input. Skips an
	 * identical token already present. No-ops outside the TUI (RPC/print).
	 */
	function appendRefToEditor(ref: Ref, cwd: string): string | null {
		const ui = sessionCtx?.ui;
		if (!ui || sessionCtx?.mode !== "tui") return "no TUI running";
		let current: string;
		try {
			current = ui.getEditorText();
		} catch {
			return "editor unavailable";
		}
		const token = formatRef(ref, cwd);
		if (current.split(/\s+/).includes(token)) return null;
		const base = current.trimEnd();
		try {
			ui.setEditorText(base ? `${base} ${token}` : token);
		} catch (e: any) {
			return `setEditorText failed: ${e?.message ?? e}`;
		}
		// setEditorText doesn't schedule a repaint; the (cleared) status set
		// nudges the TUI to redraw without leaving the ref in the footer.
		try {
			ui.setStatus("pi-nvim", undefined);
		} catch (e) {
			void e;
		}
		return null;
	}

	function cleanup() {
		if (server) {
			server.close();
			server = null;
		}
		if (!sockPath) return;
		try {
			fs.unlinkSync(sockPath);
		} catch {}
		try {
			fs.unlinkSync(sockPath + ".info");
		} catch {}
		try {
			if (fs.readlinkSync(LATEST_LINK) === sockPath) fs.unlinkSync(LATEST_LINK);
		} catch {}
	}

	pi.on("session_shutdown", async () => {
		cleanup();
	});
	process.on("exit", cleanup);
}
