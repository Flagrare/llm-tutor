---
name: tutor-statusline-install
description: "Install the llm-tutor statusline integration. Wraps your existing Claude Code statusline (any statusline — claude-statusline, custom, none) so llm-tutor's segment renders as an extra row alongside it. Saves your original statusline command so /tutor-statusline-uninstall can restore it. Triggers: '/tutor-statusline-install', 'install the tutor statusline', 'show my tutor progress in the statusline', 'enable tutor in statusline'."
---

# Tutor Statusline Install

This skill installs llm-tutor's statusline integration. After install, every statusline render shows the user's current tier, cycles balance, and (when active) the topic + concept progress, appended as a new row beneath whatever statusline they already had.

The install is non-destructive: it saves the user's original `statusLine.command` before swapping in our wrapper. `/tutor-statusline-uninstall` restores it.

---

## Step 0 — Confirm the user knows what they're agreeing to

Before mutating `~/.claude/settings.json`, print a short summary:

> "About to wrap your Claude Code statusline so llm-tutor's tier/cycles/progress shows up as an extra row. Your existing statusline will still render unchanged — we only add a row.
>
> - Saved original: `~/.claude/llm-tutor/wrapped-statusline.json`
> - Toggle off later: `/tutor-statusline-toggle off`
> - Full uninstall: `/tutor-statusline-uninstall`
>
> Proceed?"

If the user has already approved in their previous message (e.g. they explicitly typed `/tutor-statusline-install`), skip the confirmation and proceed directly.

---

## Step 1 — Run the install script

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/statusline-install.sh"
```

Echo the script's output to the user verbatim. Don't summarize — the script prints the exact paths it touched, which is what the user needs to see.

---

## Step 2 — Tell the user how to verify

> "Restart Claude Code (or wait for the next render) — you'll see an extra row beneath your existing statusline showing your tier, cycles, and active topic.
>
> If you don't see anything, you may not have started a tutoring session yet. The segment auto-hides when there's no state file. Run `/tutor-start <subject>` and it'll appear."

---

## Hard rules

1. **Never edit `~/.claude/settings.json` directly from this skill.** Always delegate to the install script — it has the idempotency + backup logic.
2. **Don't claim it's installed** until the script exits 0.
3. **Don't run install if it's already installed** — the script handles idempotency by detecting the wrapper symlink, but you can also short-circuit: if `~/.claude/llm-tutor/wrapped-statusline.json` already exists, tell the user it's already installed and offer `/tutor-statusline-toggle` instead.
