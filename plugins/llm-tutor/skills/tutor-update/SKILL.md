---
name: tutor-update
description: "Check whether llm-tutor has a newer release on GitHub and, if so, surface what's new along with the two commands needed to upgrade. Triggers: '/tutor-update', 'check for llm-tutor updates', 'is there a new tutor version', 'update the tutor', 'pull latest tutor'."
---

# Tutor Update

This skill answers the question *"is there a newer version of llm-tutor than the one I'm running, and what would I get by upgrading?"* It compares the installed plugin-cache version against the latest GitHub release, prints the release notes when an upgrade is available, and provides the two exact slash commands the user needs to type to perform the upgrade.

llm-tutor is a Claude Code plugin, so its install/update lifecycle is owned by `/plugin update llm-tutor@llm-tutor` + `/reload-plugins`. A skill cannot invoke another slash command, so this skill stops short of performing the update itself. What it does instead is the version check + diff that makes the manual upgrade worth doing — and tells you when you can skip it.

---

## Step 1 — Run the check script

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/check-for-update.sh"
```

Echo the script's output verbatim. Don't summarize — the user wants to see the installed version, the latest version, and (when behind) the actual release notes.

---

## Step 2 — Add a one-line context line

If the script reports **"You're up to date,"** no further action is needed. Optionally note the current version.

If the script reports **"Update available!"**, the script already prints the two commands. Add a single line of context:

> "Run those two commands above to upgrade — the second one (`/reload-plugins`) is required for the new version to take effect in the current Claude Code session without a restart."

If the script reports **"(couldn't reach GitHub)"**, suggest the user check their network and try again, or visit the releases page directly.

---

## Hard rules

1. **Never invoke `/plugin update` from this skill.** It's a Claude Code built-in slash command and skills can't trigger other slash commands. The user has to type it themselves.
2. **Never edit `~/.claude/plugins/cache/llm-tutor/` directly to "force" an update.** That bypasses Claude Code's plugin registry (`~/.claude/plugins/installed_plugins.json`) and leaves the install in an inconsistent state. The lifecycle is owned by `/plugin update`.
3. **Don't run if the user is mid-tutoring-session and has unsaved progress.** Tutoring state is in `state.json` and survives updates — but a reload mid-conversation may discard the active turn's context. Mention this if the user has an active `in_progress` topic and is mid-dialogue.
