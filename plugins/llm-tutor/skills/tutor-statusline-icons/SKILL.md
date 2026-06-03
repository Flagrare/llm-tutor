---
name: tutor-statusline-icons
description: "Switch llm-tutor statusline icon mode between emoji (default), nerd (Nerd Font glyphs), unicode (geometric text-presentation symbols), and ascii (pure 7-bit fallback). Mirrors claude-statusline's /statusline-icons. Pass an explicit mode name or no argument to cycle. Triggers: '/tutor-statusline-icons', '/tutor-statusline-icons nerd', 'switch tutor statusline to nerd font', 'change tutor statusline icons to ascii'."
---

# Tutor Statusline Icons

This skill flips the icon-rendering mode for llm-tutor's statusline segment. Same four modes as claude-statusline: emoji, nerd (Nerd Font glyphs), unicode (geometric symbols), and ascii (pure 7-bit).

---

## Step 1 — Run the icon switch script

Pass the user's argument through unchanged (a mode name or empty for cycle).

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/statusline-icons.sh" $ARGUMENTS
```

The script's output includes a rendered preview line so the user can see the chosen mode in their terminal immediately. Echo the output verbatim — don't summarize.

---

## Step 2 — Tell the user what to expect

> "The change applies to the next statusline render — usually within a second or two. If you don't see the new glyphs:
>
> - In **nerd** mode, your terminal font must be a Nerd Font (JetBrainsMono Nerd Font, FiraCode Nerd Font, etc.) — otherwise the glyphs render as tofu.
> - In **unicode** mode, your terminal must support text-presentation Unicode (works in most modern terminals).
> - In **ascii** mode, anything works."

---

## Hard rules

1. **Don't suggest installing a Nerd Font** unless the user explicitly says nerd-mode glyphs are missing. Most users picked their terminal font intentionally.
2. **Don't modify ~/.claude/statusline/.statusline.conf** — that's claude-statusline's config. We have our own at ~/.claude/llm-tutor/statusline.conf.
3. **No need to restart Claude Code** after switching modes. The change applies on the next render.
