#!/usr/bin/env bash
# llm-tutor UserPromptSubmit hook — daily cycles refill check.
#
# Fires before every user prompt. Idempotent — state.sh refill-cycles is a
# no-op when less than a day has passed since the last reset. Silent on
# success (no stdout to avoid polluting the user prompt context).
#
# Only acts when state.json exists. A user who has never invoked any
# /tutor-* command has no state file, and the hook exits silently.
#
# Per the zero-dependencies constraint, this hook depends only on:
#   - Bash (standard)
#   - The plugin's own scripts/state.sh
#   - $CLAUDE_PLUGIN_ROOT and $CLAUDE_PLUGIN_DATA env vars (set by Claude Code)

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
STATE_FILE="$STATE_DIR/state.json"

# No state file = user hasn't started using the plugin yet. Skip silently.
[ -f "$STATE_FILE" ] || exit 0

# Call state.sh refill-cycles. Suppress all output; it's a no-op unless a day
# has passed, and we don't want it appearing in the user's prompt context
# even when it does refill.
"${CLAUDE_PLUGIN_ROOT}/scripts/state.sh" refill-cycles >/dev/null 2>&1 || true

exit 0
