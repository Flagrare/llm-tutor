---
name: tutor-statusline-uninstall
description: "Uninstall the llm-tutor statusline integration. Restores the user's original Claude Code statusline command from before /tutor-statusline-install. Leaves tutoring state (XP, cycles, topics) intact. Triggers: '/tutor-statusline-uninstall', 'remove the tutor statusline', 'unwrap the statusline', 'restore my statusline'."
---

# Tutor Statusline Uninstall

This skill undoes `/tutor-statusline-install` by restoring the saved original `statusLine.command` in `~/.claude/settings.json`. Tutoring progress is preserved — only the wrapper plumbing is removed.

---

## Step 1 — Run the uninstall script

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/statusline-uninstall.sh"
```

Echo the output verbatim. The script prints what it restored or what it deleted.

---

## Step 2 — Tell the user how to re-enable later

> "Restart Claude Code to fully reload the statusline. Your tutoring progress is preserved in `~/.claude/llm-tutor/state.json`. If you want llm-tutor back in the statusline later, run `/tutor-statusline-install`."

---

## Hard rules

1. **Never edit `~/.claude/settings.json` directly.** Always delegate to the script.
2. **Don't delete `state.json`** — tutoring progress survives uninstall.
3. **Idempotent on second invocation** — the script handles the "already uninstalled" case silently. Don't error out if the user runs this twice.
