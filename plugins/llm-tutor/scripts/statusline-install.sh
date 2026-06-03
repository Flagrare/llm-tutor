#!/usr/bin/env bash
# statusline-install.sh — wrap the existing statusline so llm-tutor's segment
# renders alongside whatever the user already has.
#
# What this does to ~/.claude/settings.json:
#   1. Reads the current statusLine block (whole object).
#   2. Saves it to ~/.claude/llm-tutor/wrapped-statusline.json (uninstall
#      restores from this).
#   3. Writes a self-locating wrapper SHIM to
#      ~/.claude/llm-tutor/statusline-wrapper.sh and points settings.json
#      at it.
#   4. Creates the enable flag file so the segment renders by default.
#
# How the shim survives plugin upgrades:
#   The wrapper script in the plugin's cache lives at a version-numbered
#   path (~/.claude/plugins/cache/llm-tutor/llm-tutor/<version>/scripts/),
#   which changes on every release. Older versions of this installer
#   symlinked from $STATE_DIR straight at the cache wrapper, but that
#   pinned the symlink at install-time's version — plugin upgrades didn't
#   take effect until /tutor-statusline-install ran again or the user
#   restarted Claude Code (so a SessionStart hook could refresh the
#   symlink).
#
#   v0.4.1 changed this: the path under $STATE_DIR is now a small bash
#   SHIM (not a symlink), generated once and never re-pointed. Each
#   render, the shim self-locates the latest cache version and execs
#   *its* wrapper. So /plugin update llm-tutor + /reload-plugins is now
#   enough — no /tutor-statusline-install rerun, no session restart.
#
# Idempotent: if statusLine.command already points at our shim path, no-op.
#
# Refuses to wrap itself: if we detect the wrapper path in any nested
# command field, we no-op rather than re-wrap (which would cause
# Wrapper(Wrapper(Original)) and recurse on uninstall).

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
WRAPPED_FILE="$STATE_DIR/wrapped-statusline.json"
ENABLED_FLAG="$STATE_DIR/statusline-enabled"
WRAPPER_PATH="$STATE_DIR/statusline-wrapper.sh"
SEGMENT_SYMLINK="$STATE_DIR/statusline-segment.sh"
SETTINGS="$HOME/.claude/settings.json"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEGMENT_REAL="$SCRIPT_DIR/statusline-segment.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  exit 1
fi

mkdir -p "$STATE_DIR"

# --- write the wrapper shim ---
# Self-locating: each render, the shim picks the highest semver-sorted
# subdir of the plugin cache and execs its real wrapper. Plugin upgrades
# are picked up automatically; no symlink to keep fresh.
#
# Replaces any existing symlink at this path (older installs created one
# pointing at the cache wrapper). Same path, different file type — the
# settings.json command we set below still points here, so the swap is
# transparent.
rm -f "$WRAPPER_PATH"
cat > "$WRAPPER_PATH" <<'WRAPPER_SHIM'
#!/usr/bin/env bash
# llm-tutor statusline wrapper shim — written by /tutor-statusline-install.
#
# This shim self-locates the latest installed llm-tutor plugin cache version
# and execs its statusline-wrapper.sh. The actual wrapper logic lives in
# the plugin cache and self-updates with every plugin upgrade — so /plugin
# update llm-tutor + /reload-plugins is enough; no /tutor-statusline-install
# rerun, no session restart.
#
# DO NOT EDIT BY HAND — this file is rewritten by /tutor-statusline-install.
CACHE_BASE="$HOME/.claude/plugins/cache/llm-tutor/llm-tutor"
LATEST=$(ls -1 "$CACHE_BASE" 2>/dev/null | sort -V | tail -1)
if [ -z "$LATEST" ]; then
  # Plugin cache is missing entirely. Degrade silently — statusline
  # rendering is not a place to fail loudly.
  exit 0
fi
exec bash "$CACHE_BASE/$LATEST/scripts/statusline-wrapper.sh" "$@"
WRAPPER_SHIM
chmod +x "$WRAPPER_PATH"

# Segment symlink: kept as a stable path for direct shell-out users
# (~/.claude/llm-tutor/statusline-segment.sh is documented in the
# statusline guide for users wiring llm-tutor into a non-Claude-Code
# statusline). The wrapper lazily refreshes this symlink on every render
# so it always points at the latest cache version.
ln -sf "$SEGMENT_REAL" "$SEGMENT_SYMLINK"

# --- read current statusLine block ---
current_block="null"
if [ -f "$SETTINGS" ]; then
  current_block=$(jq -c '.statusLine // null' "$SETTINGS")
fi

current_cmd=$(echo "$current_block" | jq -r '.command // empty')

# Already wrapped? Detect by matching the wrapper symlink path in the
# current command. The current command might be the symlink path directly
# (typical), or a shell snippet that includes it.
if [ -n "$current_cmd" ] && [[ "$current_cmd" == *"$WRAPPER_PATH"* ]]; then
  # Already installed; ensure flag is on and exit.
  touch "$ENABLED_FLAG"
  echo "llm-tutor statusline integration is already installed."
  echo "Segment enabled (flag: $ENABLED_FLAG)."
  exit 0
fi

# --- save the original ---
if [ "$current_block" = "null" ]; then
  # No prior statusLine. Save an explicit "none" marker so uninstall knows
  # to delete the key rather than restore something.
  echo '{"none": true}' > "$WRAPPED_FILE"
  echo "No existing statusLine found in $SETTINGS — installing standalone."
else
  echo "$current_block" | jq '.' > "$WRAPPED_FILE"
  echo "Saved original statusLine to $WRAPPED_FILE."
fi

# --- swap to our wrapper ---
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

tmp=$(mktemp)
jq --arg cmd "$WRAPPER_PATH" \
   '.statusLine = {type: "command", command: $cmd}' \
   "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"

# --- enable by default ---
touch "$ENABLED_FLAG"

# Seed icon-mode config (emoji default). The user can switch with
# /tutor-statusline-icons. We don't overwrite an existing conf — picks up
# whatever the user had if they reinstall.
CONF_FILE="$STATE_DIR/statusline.conf"
[ -f "$CONF_FILE" ] || printf "ICONS=emoji\n" > "$CONF_FILE"

# --- persona-aware success message ---
# Read the active output style from settings.json. Claude Code stores it
# under .outputStyle (string) at the user-settings level; we accept both
# shapes for robustness.
active_style=""
if [ -f "$SETTINGS" ]; then
  active_style=$(jq -r '.outputStyle // .output_style // ""' "$SETTINGS" 2>/dev/null || printf "")
  active_style=$(printf "%s" "$active_style" | tr '[:upper:]' '[:lower:]')
fi

echo
echo "Installed. Your existing statusline (if any) will still render, with"
echo "llm-tutor's segment appended as an extra row."
echo

case "$active_style" in
  echo|cipher|vex)
    pretty=$(printf "%s" "$active_style" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    echo "  Active teacher: $pretty (the row will render in $pretty's signature color)"
    ;;
  "")
    echo "  No teacher selected yet (the row renders in a neutral color)."
    echo "  Pick one: /config → Output style → Echo, Cipher, or Vex"
    ;;
  *)
    echo "  Active output style: $active_style (no llm-tutor persona — row renders neutral)"
    ;;
esac

# --- preview ---
# Render the segment right now so the user knows what they're about to see.
# We pass the persona explicitly because the wrapper would normally inject
# it; this is a static one-shot preview, not a live render.
if [ -f "$STATE_DIR/state.json" ]; then
  echo
  echo "  Preview:"
  echo -n "    "
  LLM_TUTOR_PERSONA="$active_style" bash "$SEGMENT_SYMLINK" 2>/dev/null || true
  echo
else
  echo
  echo "  No tutoring state yet. Start a session: /tutor-start <subject>"
  echo "  (the segment auto-appears the moment state.json is created)"
fi

echo
echo "Controls:"
echo "  /tutor-statusline-toggle [on|off]    show / hide without uninstalling"
echo "  /tutor-statusline-icons  [mode]      emoji | nerd | unicode | ascii"
echo "  /tutor-statusline-uninstall          full revert"
