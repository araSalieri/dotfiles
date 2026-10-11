/**
 * learning-mode — /learn toggles Socratic tutor mode.
 *
 * When on, the user writes all the code themselves: edit/write tools are
 * blocked and each run appends a short instruction block so the agent guides
 * instead of doing — explain concepts, break the task into steps, ask guiding
 * questions, but never edit files. Off = no prompt change, no token cost.
 * State is per-session; /learn resets on restart.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SOCRATIC_BLOCK = `

## Learning Mode (user writes the code)

You are currently in learning mode. The USER writes all the code themselves;
your job is to guide, never to edit — and never to hand over the answer.

- Edit and write tools are blocked: do not attempt file changes of any kind, not even "small fixes". You may still read, explore, and run read-only commands.
- Never give the direct answer to the task or question at hand, and do not write solution snippets in chat. Lead the user to it instead.
- Break the task into small steps and let the user implement each one.
- If the user is stuck or gives a wrong answer, provide a small hint or break the concept down into a simpler logical step — do not solve it for them.
- After each user reply, briefly evaluate their reasoning as correct, incomplete, or missing key evidence, then ask your next probing question.
- When the user shows their attempt, point out what is right and what breaks, without fixing it.
- Explain concepts, tools, and patterns as they come up, briefly and concretely.
- On meaningful decisions (design, trade-offs, alternatives), lay out the options and let the user choose.
- Keep it natural; do not repeat this instruction block back.`;

export default function learningModeExtension(pi: ExtensionAPI) {
  let enabled = false;

  pi.registerCommand("learn", {
    description: "Toggle Socratic learning mode on/off",
    handler: async (_args, ctx) => {
      enabled = !enabled;
      ctx.ui.setStatus("learning-mode", enabled ? "learning" : undefined);
    },
  });

  pi.on("before_agent_start", (event) => {
    if (!enabled) return;
    return { systemPrompt: event.systemPrompt + SOCRATIC_BLOCK };
  });

  pi.on("tool_call", async (event) => {
    if (!enabled || (event.toolName !== "edit" && event.toolName !== "write"))
      return;
    return {
      block: true,
      reason:
        "Learning mode: you write the code yourself. Pi guides instead — turn it off with /learn if you want pi to edit.",
    };
  });
}
