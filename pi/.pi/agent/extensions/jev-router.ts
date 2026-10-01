/**
 * Jev router — a virtual model that picks the physical model for each user turn.
 *
 * Registers `openrouter/jev-auto`, listed next to the physical OpenRouter
 * models. On every new user message, the Jev classifier
 * (TypeSafe System One, via OpenRouter's Decisions API) rates the prompt's
 * complexity on three tiers — standard, complex, extreme — and routes to the
 * highest tier whose probability meets `complexityThreshold`. Continuations,
 * tool follow-ups, and retries stay on the model that answered last, so prompt
 * caches and thinking signatures stay valid within a turn. Direct requests
 * (compaction summaries, extension calls) go to the standard model.
 *
 * All models are configured in settings.json under `jevRouter`:
 *
 *   "jevRouter": {
 *     "routerModel": "openrouter/~typesafe/jev-latest",
 *     "standardModel": "openrouter/z-ai/glm-5.3-flash",
 *     "complexModel": "openrouter/z-ai/glm-5.3",
 *     "extremeModel": "openrouter/anthropic/claude-opus-5.5",
 *     "complexityThreshold": 0.5
 *   }
 *
 * Model values are `provider/id` strings resolved against the model catalog.
 * If Jev is unavailable or the classify call fails, the turn falls back to the
 * standard model. The chosen model is router state on the session branch, so
 * it survives compaction and /tree navigation.
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	ModelRoute,
	ModelRouteRequest,
} from "@earendil-works/pi-coding-agent";

interface JevRouterConfig {
	routerModel: string;
	standardModel: string;
	complexModel: string;
	extremeModel: string;
	complexityThreshold: number;
}

const DEFAULTS: JevRouterConfig = {
	routerModel: "openrouter/~typesafe/jev-latest",
	standardModel: "openrouter/z-ai/glm-5.3-flash",
	complexModel: "openrouter/z-ai/glm-5.3",
	extremeModel: "openrouter/anthropic/claude-opus-5.5",
	complexityThreshold: 0.5,
};

/** Router state persisted on the session branch. */
interface JevState {
	/** Model id routed to for the current turn. */
	model: string;
}

type JevRequest = ModelRouteRequest<JevState>;

/** Split a `provider/id` reference; ids may contain further slashes. */
function parseModelRef(ref: string): { provider: string; id: string } {
	const slash = ref.indexOf("/");
	if (slash <= 0 || slash === ref.length - 1) {
		throw new Error(`Invalid model reference "${ref}" — expected "provider/id"`);
	}
	return { provider: ref.slice(0, slash), id: ref.slice(slash + 1) };
}

function readConfig(pi: ExtensionAPI): JevRouterConfig {
	const raw = (pi.getSettings() as Record<string, unknown>).jevRouter;
	if (typeof raw !== "object" || raw === null) return DEFAULTS;
	const obj = raw as Record<string, unknown>;
	const num = (value: unknown, fallback: number) =>
		typeof value === "number" && value >= 0 && value <= 1 ? value : fallback;
	const str = (value: unknown, fallback: string) =>
		typeof value === "string" && value.includes("/") ? value : fallback;
	return {
		routerModel: str(obj.routerModel, DEFAULTS.routerModel),
		standardModel: str(obj.standardModel, DEFAULTS.standardModel),
		complexModel: str(obj.complexModel, DEFAULTS.complexModel),
		extremeModel: str(obj.extremeModel, DEFAULTS.extremeModel),
		complexityThreshold: num(obj.complexityThreshold, DEFAULTS.complexityThreshold),
	};
}

function routeTo(
	request: JevRequest,
	ctx: ExtensionContext,
	ref: string,
	state?: JevState,
): ModelRoute<JevState> {
	const { provider, id } = parseModelRef(ref);
	const model = ctx.modelRegistry.find(provider, id);
	if (!model) throw new Error(`Model ${ref} is not in the catalog`);
	return { model, thinkingLevel: request.thinkingLevel, state };
}

/** Minimal structural view of the transcript messages the router reads. */
interface TextBlock {
	type: string;
	text?: string;
}

interface MessageLike {
	role: string;
	content: string | readonly TextBlock[];
}

function lastUserText(messages: readonly MessageLike[]): string {
	const content = messages.filter((message) => message.role === "user").at(-1)?.content ?? "";
	if (typeof content === "string") return content;
	return content
		.flatMap((block) => (block.type === "text" && typeof block.text === "string" ? [block.text] : []))
		.join("\n");
}

/**
 * Rate the prompt's complexity with Jev. Returns the reference of the highest
 * tier whose probability meets the threshold — extreme, then complex, then
 * standard. Falls back to the standard model on any failure.
 */
async function chooseModelForTurn(
	request: JevRequest,
	ctx: ExtensionContext,
	config: JevRouterConfig,
): Promise<string> {
	const { provider, id } = parseModelRef(config.routerModel);
	const jev = ctx.modelRegistry.findOfType("classifier", provider, id);
	if (!jev) return config.standardModel;
	try {
		const result = await ctx.modelRegistry.classify(
			jev,
			{
				state: { prompt: lastUserText(request.messages).slice(0, 16_000) },
				questions: {
					complexity: {
						type: "choice",
						instructions: "How demanding is the software engineering work requested in `prompt`?",
						criteria: {
							standard: "Ordinary features, fixes, reviews, or questions",
							complex: "Subtle design, cross-cutting changes, or hard debugging",
							extreme: "Architecture redesigns, multi-system migrations, or deep reasoning over large surfaces",
						},
					},
				},
			},
			{ signal: request.signal },
		);
		if (result.stopReason !== "stop") return config.standardModel;
		const answer = result.answers.complexity;
		if (answer?.type !== "choice") return config.standardModel;
		const probabilities = answer.probabilities;
		if ((probabilities.extreme ?? 0) >= config.complexityThreshold) return config.extremeModel;
		if ((probabilities.complex ?? 0) >= config.complexityThreshold) return config.complexModel;
		return config.standardModel;
	} catch {
		return config.standardModel;
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerVirtualModel<JevState>({
		provider: "openrouter",
		id: "jev-auto",
		name: "Auto (Jev)",
		thinkingLevels: ["low", "medium", "high", "xhigh"],
		// Shared by both target models; shown before the first response.
		contextWindow: 1_000_000,
		maxTokens: 128_000,
		async route(request, ctx) {
			const config = readConfig(pi);
			// Compaction summaries and extension calls: standard model, no state.
			if (request.reason === "direct") return routeTo(request, ctx, config.standardModel);
			// Tool follow-ups and retries stay on the model that handled the turn.
			if (request.state && request.reason !== "user") {
				return routeTo(request, ctx, request.state.model, request.state);
			}
			// New user turn (or a session's first request): classify with Jev.
			const ref = await chooseModelForTurn(request, ctx, config);
			return routeTo(request, ctx, ref, { model: ref });
		},
	});
}