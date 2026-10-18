import assert from "node:assert/strict";
import test from "node:test";
import registerCommit from "../commit.ts";

function setup({ settings = { defaultProvider: "default", defaultModel: "commit" }, idle = true, found = true, authenticated = true } = {}) {
	const original = { provider: "session", id: "coding" };
	const commitModel = { provider: "default", id: "commit" };
	const events = new Map();
	const switches = [];
	const messages = [];
	const notices = [];
	let command;
	let thinkingLevel = "high";
	const ctx = {
		model: original,
		isIdle: () => idle,
		modelRegistry: {
			find(provider, id) {
				assert.equal(provider, "default");
				assert.equal(id, "commit");
				return found ? commitModel : undefined;
			},
		},
		ui: { notify: (...args) => notices.push(args) },
	};
	registerCommit({
		on: (name, handler) => events.set(name, handler),
		registerCommand: (_name, spec) => { command = spec.handler; },
		registerTool: () => {},
		getSettings: () => settings,
		getThinkingLevel: () => thinkingLevel,
		setThinkingLevel: (level) => { thinkingLevel = level; },
		setModel: async (model) => {
			if (!authenticated) return false;
			switches.push(model);
			ctx.model = model;
			thinkingLevel = "off";
			return true;
		},
		sendUserMessage: (message) => messages.push(message),
	});
	return {
		run: () => command("", ctx),
		settle: () => events.get("agent_settled")({}, ctx),
		ctx, original, commitModel, switches, messages, notices,
		thinking: () => thinkingLevel,
	};
}

test("/commit uses configured defaults and restores the model and thinking when settled", async () => {
	const app = setup();
	await app.run();
	assert.deepEqual(app.switches, [app.commitModel]);
	assert.equal(app.messages.length, 1);
	assert.equal(app.ctx.model, app.commitModel);
	await app.settle();
	assert.deepEqual(app.switches, [app.commitModel, app.original]);
	assert.equal(app.thinking(), "high");
	await app.settle();
	assert.equal(app.switches.length, 2);
});

for (const [name, settings] of [
	["both commit defaults", {
		defaultProvider: "other", defaultModel: "other",
		defaultCommitProvider: "default", defaultCommitModel: "commit",
	}],
	["only the commit provider", {
		defaultProvider: "other", defaultModel: "commit", defaultCommitProvider: "default",
	}],
	["only the commit model", {
		defaultProvider: "default", defaultModel: "other", defaultCommitModel: "commit",
	}],
]) {
	test(`/commit prefers ${name} over session defaults`, async () => {
		const app = setup({ settings });
		await app.run();
		assert.deepEqual(app.switches, [app.commitModel]);
		assert.equal(app.messages.length, 1);
		await app.settle();
		assert.equal(app.ctx.model, app.original);
		assert.equal(app.thinking(), "high");
	});
}

test("/commit rejects another invocation before the run settles", async () => {
	const app = setup();
	await app.run();
	await app.run();
	assert.equal(app.messages.length, 1);
	assert.equal(app.notices.at(-1)[1], "warning");
	await app.settle();
});

for (const [name, options] of [
	["busy agent", { idle: false }],
	["unknown default model", { found: false }],
	["missing authentication", { authenticated: false }],
]) {
	test(`/commit stops for ${name} without sending a prompt or changing models`, async () => {
		const app = setup(options);
		await app.run();
		await app.settle();
		assert.equal(app.messages.length, 0);
		assert.equal(app.switches.length, 0);
		assert.equal(app.notices.length, 1);
	});
}

for (const [name, settings] of [
	["no defaults", {}],
	["the current model as default", { defaultProvider: "session", defaultModel: "coding" }],
]) {
	test(`/commit keeps the current model with ${name}`, async () => {
		const app = setup({ settings });
		await app.run();
		await app.settle();
		assert.equal(app.messages.length, 1);
		assert.equal(app.switches.length, 0);
		assert.equal(app.thinking(), "high");
	});
}
