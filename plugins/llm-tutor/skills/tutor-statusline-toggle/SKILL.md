---
name: tutor-statusline-toggle
description: "Toggle the llm-tutor statusline segment on or off without uninstalling the wrapper. When off, the wrapper still runs but only emits the user's original statusline — zero visible change vs. no integration. Triggers: '/tutor-statusline-toggle', '/tutor-statusline-toggle on', '/tutor-statusline-toggle off', 'turn the tutor statusline off', 'hide the tutor statusline', 'show the tutor statusline'."
---

# Tutor Statusline Toggle

This skill flips the visibility flag for llm-tutor's statusline segment. The wrapper stays installed either way — toggling is the lightweight on/off, uninstall is the full removal.

---

## Step 1 — Run the toggle script

Pass the user's argument through unchanged (`on` / `off` / empty for cycle).

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/statusline-toggle.sh" $ARGUMENTS
```

Echo the script's output.

---

## Step 2 — One-line context for the user

If the user toggled **off** and the wrapper is currently installed:

> "Original statusline renders unchanged. Run `/tutor-statusline-toggle on` to bring the segment back."

If the user toggled **on** and the wrapper isn't installed yet (the script's output will warn about this), suggest:

> "Run `/tutor-statusline-install` first — the toggle is set, but nothing's wrapping the statusline yet so nothing changes visually."

---

## Hard rules

1. **Don't run install from this skill.** Toggle and install are intentionally separate — the user might want the wrapper installed but the segment hidden (e.g., during a screen-share).
2. **Don't modify settings.json.** The flag is a file under `~/.claude/llm-tutor/`, not a settings key.
