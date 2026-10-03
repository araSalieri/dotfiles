/**
 * Jev router — a virtual model that picks the physical model for each user turn.
 *
 * Registers `openrouter/jev-auto`, listed next to the physical OpenRouter
 * models. On every new user message, one classify call to the Jev classifier
 * (TypeSafe System One, via OpenRouter's Decisions API) picks which of the
 * configured candidate models best fits the prompt.
 *
 * Continuations, tool follow-ups, and retries stay on the model that answered
 * last, so prompt caches and thinking signatures stay valid within a turn.
 * Direct requests (compaction summaries, extension calls) go to the first
 * candidate.
 *
 * A candidate carries its own thinking level, which overrides the level
 * selected in pi for that turn:
 *
 *   "jevRouter": {
 *     "routerModel": "openrouter/~typesafe/jev-latest",
 *     "models": [
 *       { "model": "openrouter/z-ai/glm-5.3-flash", "thinkingLevel": "high", "when": "quick questions, small edits" },
 *       { "model": "openrouter/z-ai/glm-5.3", "thinkingLevel": "high", "when": "multi-file features, debugging" }
 *     ]
 *   }
 *
 * Entry fields: `model` (required, `provider/id`), `thinkingLevel` (optional —
 * overrides the pi selection for turns routed to this entry), `when` (optional
 * description Jev sees as the choice criterion). A plain string value is still
 * accepted as a single candidate with no thinking-level override.
 *
 * If Jev is unavailable or the classify call fails, the turn falls back to the
 * first candidate. The chosen model and thinking level are router state on the
 * session branch, so they survive compaction and /tree navigation.
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	ModelRoute,
	ModelRouteRequest,
} from "@earendil-works/pi-coding-agent";

/** Mirrors `ModelThinkingLevel` from @earendil-works/pi-ai (not a direct dependency). */
type ThinkingLevel =
	| "off"
	| "minimal"
	| "low"
	| "medium"
	| "high"
	| "xhigh"
	| "max";

/** One candidate model within a tier. */
interface ModelEntry {
	model: string;
	thinkingLevel?: ThinkingLevel;
	when?: string;
}

const THINKING_LEVELS: readonly ThinkingLevel[] = [
	"off",
	"minimal",
	"low",
	"medium",
	"high",
	"xhigh",
	"max",
];

interface JevRouterConfig {
	routerModel: string;
	models: ModelEntry[];
}

const DEFAULTS: JevRouterConfig = {
	routerModel: "openrouter/~typesafe/jev-latest",
	models: [{ model: "openrouter/z-ai/glm-5.3-flash" }],
};

/** Router state persisted on the session branch. */
interface JevState {
	/** Model reference routed to for the current turn. */
	model: string;
	/** Thinking level the entry dictated, if any. */
	thinkingLevel?: ThinkingLevel;
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

function parseEntry(raw: unknown): ModelEntry | undefined {
	if (typeof raw === "string" && raw.includes("/")) return { model: raw };
	if (typeof raw !== "object" || raw === null) return undefined;
	const obj = raw as Record<string, unknown>;
	if (typeof obj.model !== "string" || !obj.model.includes("/")) return undefined;
	const entry: ModelEntry = { model: obj.model };
	if (
		typeof obj.thinkingLevel === "string" &&
		(THINKING_LEVELS as readonly string[]).includes(obj.thinkingLevel)
	) {
		entry.thinkingLevel = obj.thinkingLevel as ThinkingLevel;
	}
	if (typeof obj.when === "string" && obj.when) entry.when = obj.when;
	return entry;
}

function parseEntries(raw: unknown, fallback: ModelEntry[]): ModelEntry[] {
	const list = Array.isArray(raw) ? raw.map(parseEntry) : [parseEntry(raw)];
	const entries = list.filter((entry): entry is ModelEntry => entry !== undefined);
	return entries.length > 0 ? entries : fallback;
}

function readConfig(pi: ExtensionAPI): JevRouterConfig {
	const raw = (pi.getSettings() as Record<string, unknown>).jevRouter;
	if (typeof raw !== "object" || raw === null) return DEFAULTS;
	const obj = raw as Record<string, unknown>;
	const str = (value: unknown, fallback: string) =>
		typeof value === "string" && value.includes("/") ? value : fallback;
	return {
		routerModel: str(obj.routerModel, DEFAULTS.routerModel),
		models: parseEntries(obj.models, DEFAULTS.models),
	};
}

function routeTo(
	request: JevRequest,
	ctx: ExtensionContext,
	entry: ModelEntry,
	state?: JevState,
): ModelRoute<JevState> {
	const { provider, id } = parseModelRef(entry.model);
	const model = ctx.modelRegistry.find(provider, id);
	if (!model) throw new Error(`Model ${entry.model} is not in the catalog`);
	return { model, thinkingLevel: entry.thinkingLevel ?? request.thinkingLevel, state };
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
 * Pick a candidate model with Jev in one classify call. Falls back to the
 * first candidate on any failure.
 */
async function chooseEntryForTurn(
	request: JevRequest,
	ctx: ExtensionContext,
	config: JevRouterConfig,
): Promise<ModelEntry> {
	const { provider, id } = parseModelRef(config.routerModel);
	const jev = ctx.modelRegistry.findOfType("classifier", provider, id);
	if (!jev) return config.models[0]!;
	const candidates = config.models;
	try {
		const result = await ctx.modelRegistry.classify(
			jev,
			{
				state: { prompt: lastUserText(request.messages).slice(0, 16_000) },
				questions: {
					model: {
						type: "choice",
						instructions:
							"Which candidate model fits the work requested in `prompt` best? " +
							"Each choice names a model and describes when it fits.",
						criteria: Object.fromEntries(
							candidates.map((entry) => [entry.model, entry.when ?? `The ${entry.model} model`]),
						),
					},
				},
			},
			{ signal: request.signal },
		);
		if (result.stopReason !== "stop") return config.models[0]!;
		const pick = result.answers.model;
		if (pick?.type === "choice") {
			const chosen = candidates.find((entry) => (pick.probabilities[entry.model] ?? 0) > 0);
			if (chosen) return chosen;
		}
		return config.models[0]!;
	} catch {
		return config.models[0]!;
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerVirtualModel<JevState>({
		provider: "openrouter",
		id: "jev-auto",
		name: "Auto (Jev)",
		thinkingLevels: ["low", "medium", "high", "xhigh"],
		// Shared by all candidate models; shown before the first response.
		contextWindow: 1_000_000,
		maxTokens: 128_000,
		async route(request, ctx) {
			const config = readConfig(pi);
			// Compaction summaries and extension calls: first candidate.
			if (request.reason === "direct") return routeTo(request, ctx, config.models[0]!);
			// Tool follow-ups and retries stay on the model that handled the turn.
			if (request.state && request.reason !== "user") {
				return routeTo(
					request,
					ctx,
					{ model: request.state.model, thinkingLevel: request.state.thinkingLevel },
					request.state,
				);
			}
			// New user turn (or a session's first request): classify with Jev.
			const entry = await chooseEntryForTurn(request, ctx, config);
			return routeTo(request, ctx, entry, {
				model: entry.model,
				thinkingLevel: entry.thinkingLevel,
			});
		},
	});
}