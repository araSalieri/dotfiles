/**
 * commit — /commit command + validating commit tool.
 *
 * /commit sends a prompt to the agent; the agent gathers context, writes the
 * message, and calls the `commit` tool. The tool validates the message against
 * the project's commit rules, then stages everything and commits in one step.
 */
import { spawnSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const TYPES = [
	"feat",
	"fix",
	"refactor",
	"perf",
	"docs",
	"test",
	"chore",
	"build",
	"ci",
	"style",
	"revert",
];

const SUBJECT_RE = new RegExp(`^(?:(${TYPES.join("|")}))((?:\\([^)]*\\)))?!?: (.+)$`);

interface CommitDetails {
	subject: string;
	hasBody: boolean;
	commit?: string;
}

function git(cwd: string, args: string[]): { ok: boolean; output: string } {
	const res = spawnSync("git", args, { cwd, encoding: "utf-8" });
	return {
		ok: res.status === 0,
		output: `${res.stdout ?? ""}${res.stderr ?? ""}`.trim(),
	};
}

/** Hard rules enforced by the tool. Returns a list of problems (empty = valid). */
function validateMessage(message: string): string[] {
	const problems: string[] = [];
	const lines = message.split("\n");
	const subject = lines[0].trimEnd();
	const body = lines.slice(1).join("\n");

	const match = SUBJECT_RE.exec(subject);
	if (!match) {
		problems.push(
			`Subject must match "<type>(<scope>): <summary>" with type one of: ${TYPES.join(", ")}`,
		);
	} else {
		if (subject.length > 72) {
			problems.push(`Subject is ${subject.length} chars; hard cap is 72`);
		}
		if (match[3].endsWith(".")) {
			problems.push("Subject must not end with a period");
		}
	}
	if (/^co-authored-by:/im.test(body)) {
		problems.push("Remove Co-Authored-By trailer");
	}
	if (/^generated-with:/im.test(body)) {
		problems.push("Remove Generated-with trailer");
	}
	return problems;
}

const COMMIT_PROMPT = `Commit the current working-tree changes.

1. Run \`git status --short && git diff --stat && git log --oneline -5\` to see what changed and match the project's tone.
2. Write the commit message and call the \`commit\` tool with it. If the tool reports validation problems, fix the message and call it again.

Message rules:
- Conventional Commits: \`<type>(<scope>): <summary>\`. Scope optional. Types: ${TYPES.join(", ")}.
- Terse and exact. Why over what — the diff already says what changed.
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding".
- Subject ≤50 chars when possible, hard cap 72. Lowercase after colon unless project history says otherwise. No trailing period.
- Body only when the why is non-obvious; wrap at 72; bullets use \`-\`. Always write a body for breaking changes, security fixes, migrations and reverts.
- Never: "this commit does X", "I"/"we", "as requested by", emoji, or any AI attribution trailer (Co-Authored-By, Generated-with, etc.).
- If changes span multiple concerns, pick the dominant type.
- Follow project history when it clearly deviates (check \`git log\` first).`;

const CommitParams = Type.Object({
	message: Type.String({
		description:
			'Full commit message: "<type>(<scope>): <summary>" subject line, optional body after a blank line.',
	}),
});

export default function (pi: ExtensionAPI) {
	pi.registerCommand("commit", {
		description:
			"Commit current changes — agent writes the message, the commit tool validates and commits",
		handler: async (_args, ctx) => {
			if (!ctx.isIdle()) {
				ctx.ui.notify("Agent is busy — run /commit again when idle.", "warning");
				return;
			}
			pi.sendUserMessage(COMMIT_PROMPT);
			ctx.ui.notify("Asked the agent to commit.", "info");
		},
	});

	pi.registerTool({
		name: "commit",
		label: "Commit",
		description: `Stage all changes (git add -A) and create a git commit in one step. Validates the message first and returns an error listing problems if it violates the rules: subject must be "<type>(<scope>): <summary>" with type one of ${TYPES.join(", ")}, subject ≤72 chars, no trailing period, no Co-Authored-By or Generated-with trailers. Fails early if the working tree is clean. Subject ≤50 chars when possible; body wraps at 72 and explains the why.`,
		parameters: CommitParams,
		exposure: "model-only",
		annotations: { destructiveHint: true },

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const problems = validateMessage(params.message);
			if (problems.length > 0) {
				throw new Error(
					`Invalid commit message:\n${problems.map((p) => `- ${p}`).join("\n")}\nFix the message and call the commit tool again.`,
				);
			}

			const repo = git(ctx.cwd, ["rev-parse", "--is-inside-work-tree"]);
			if (!repo.ok) {
				throw new Error("Not a git repository.");
			}

			const status = git(ctx.cwd, ["status", "--porcelain"]);
			if (!status.ok) {
				throw new Error(`git status failed: ${status.output}`);
			}
			if (!status.output) {
				return {
					content: [{ type: "text", text: "Nothing to commit: working tree is clean." }],
					details: { subject: "", hasBody: false } as CommitDetails,
				};
			}

			// spawnSync blocks, so the add+commit pair is atomic within this call.
			const add = git(ctx.cwd, ["add", "-A"]);
			if (!add.ok) {
				throw new Error(`git add failed: ${add.output}`);
			}

			const commit = git(ctx.cwd, ["commit", "-m", params.message]);
			if (!commit.ok) {
				throw new Error(`git commit failed: ${commit.output}`);
			}

			const hashMatch = /\[([^\s]+)\s+([0-9a-f]+)\]/.exec(commit.output);
			const details: CommitDetails = {
				subject: params.message.split("\n")[0],
				hasBody: params.message.includes("\n"),
				commit: hashMatch ? hashMatch[2] : undefined,
			};

			return {
				content: [{ type: "text", text: commit.output }],
				details,
			};
		},
	});
}
