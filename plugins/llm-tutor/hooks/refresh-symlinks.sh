#!/usr/bin/env bash
# refresh-symlinks.sh — SessionStart hook that keeps llm-tutor's stable
# symlinks pointed at the current plugin version.
#
# /tutor-statusline-install creates symlinks at
#   ~/.claude/llm-tutor/statusline-wrapper.sh  →  $CLAUDE_PLUGIN_ROOT/scripts/statusline-wrapper.sh
#   ~/.claude/llm-tutor/statusline-segment.sh  →  $CLAUDE_PLUGIN_ROOT/scripts/statusline-segment.sh
#
# When the plugin updates (e.g., 0.2.0 → 0.3.0), $CLAUDE_PLUGIN_ROOT points
# at a new path but the existing symlinks still point at the old version's
# scripts. This hook fixes that by re-running `ln -sf` on every session
# start — idempotent when paths haven't changed, self-healing when they have.
#
# No-op if the statusline integration isn't installed (i.e., the user has
# never run /tutor-statusline-install). We use the existence of
# wrapped-statusline.json as the install marker.

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
WRAPPED_FILE="$STATE_DIR/wrapped-statusline.json"

# Not installed → nothing to refresh.
[ -f "$WRAPPED_FILE" ] || exit 0

[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || exit 0

ln -sf "$CLAUDE_PLUGIN_ROOT/scripts/statusline-wrapper.sh" "$STATE_DIR/statusline-wrapper.sh"
ln -sf "$CLAUDE_PLUGIN_ROOT/scripts/statusline-segment.sh" "$STATE_DIR/statusline-segment.sh"

exit 0
