/**
 * commit-thinking — run the commit skill with low thinking.
 *
 * When you type /commit (or /skill:commit), the thinking level is switched
 * to "low" for that run and restored to your previous level when the run
 * finishes. Natural-language commit requests ("commit this for me") are not
 * intercepted — use /commit for that.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ThinkingLevel = "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max";

export default function (pi: ExtensionAPI) {
	let savedLevel: ThinkingLevel | null = null;

	pi.on("input", async (event, ctx) => {
		if (event.source === "extension") return { action: "continue" };

		const text = event.text.trim();
		if (!(text === "/commit" || text.startsWith("/commit ") || text.startsWith("/skill:commit"))) {
			return { action: "continue" };
		}

		try {
			savedLevel = pi.getThinkingLevel();
			pi.setThinkingLevel("low");
			ctx.ui.setStatus("commit-thinking", "thinking: low (commit)");
		} catch {
			// non-reasoning models are always "off"; nothing to do
		}
		return { action: "continue" };
	});

	pi.on("agent_end", async (_event, ctx) => {
		if (savedLevel === null) return;
		const level = savedLevel;
		savedLevel = null;
		try {
			pi.setThinkingLevel(level);
			ctx.ui.setStatus("commit-thinking", "");
		} catch {
			savedLevel = null;
		}
	});
}
