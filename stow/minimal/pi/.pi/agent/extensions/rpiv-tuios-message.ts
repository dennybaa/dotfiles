// rpiv-tuios-message.ts — put the question itself on the tuios Inbox row.
//
// Why this exists: pi's `ui_prompt_start` carries no title for a `custom`
// dialog (runner.ts passes `title = undefined`), so tuios's own pi integration
// reports the placeholder "waits for an answer" and the Inbox lists that same
// sentence for every pane waiting on a question. The screen rule cannot fix it
// either: a rule's message is the line it matched, which for rpiv's dialog is
// the key hints at the bottom.
//
// rpiv publishes the questionnaire as `rpiv:ask-user:prompt`, so the words are
// available. This reports the same state again with those words as the title.
// The repeat is late on purpose (pi's own report must land first) and carries
// `if_state: needs_input`, so it can only refine a prompt that is already
// waiting — never create one, and never touch a pane that moved on.

import { spawn } from "node:child_process";

/** Late enough to follow pi's own ui_prompt_start report; retried in case one loses. */
const REPEAT_MS = [400, 1200];

function report(pane, text) {
  const payload = JSON.stringify({
    hook_event_name: "ui_prompt_start",
    kind: "custom",
    title: text,
    busy: true,
    if_state: "needs_input",
  });
  try {
    const args = ["agent-hook", "pi", "--integration", "5"];
    if (pane) args.push("-w", pane);
    const child = spawn("tuios", args, { stdio: ["pipe", "ignore", "ignore"], windowsHide: true, timeout: 2000 });
    child.on("error", () => {});
    child.stdin.on("error", () => {});
    child.stdin.end(payload);
  } catch {
    // A report that cannot be sent must never break a question.
  }
}

export default function (pi) {
  if (process.env.TUIOS_ENV !== "1" && !process.env.TUIOS_AGENT) return;
  if (typeof pi?.events?.on !== "function") return;

  pi.events.on("rpiv:ask-user:prompt", payload => {
    const first = payload?.questions?.[0];
    if (!first || typeof first.question !== "string") return;
    const header = typeof first.header === "string" ? first.header.trim() : "";
    const text = `${header ? `${header}: ` : ""}${first.question.replace(/\s+/g, " ").trim()}`.trim();
    if (!text) return;
    for (const delay of REPEAT_MS) setTimeout(() => report(process.env.TUIOS_PANE_ID, text), delay);
  });
}
