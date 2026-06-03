#!/usr/bin/env bash
# statusline-wrapper.sh — llm-tutor's statusline integration entry point.
#
# When the user runs /tutor-statusline-install, ~/.claude/settings.json's
# statusLine.command is swapped to point at this script, and the previous
# command (if any) is saved to ~/.claude/llm-tutor/wrapped-statusline.json.
#
# Each render, this wrapper:
#   1. Reads the status JSON from stdin (sent by Claude Code).
#   2. Pipes that JSON to the saved original command and captures its stdout.
#   3. Optionally appends llm-tutor's segment as an additional row.
#
# The append is gated by a flag file (~/.claude/llm-tutor/statusline-enabled).
# When the flag is missing, the wrapper passes the original output through
# unchanged — same effect as if llm-tutor weren't involved at all.
#
# Performance: this runs on every statusline refresh. Both the original
# command and our segment renderer must complete in milliseconds. The
# segment renderer is one jq call + a tier lookup; the original cost is
# whatever the original statusline already cost.
#
# Failure modes are silent: if the original command is missing/unset/broken
# or the segment renderer errors, the wrapper still emits *something* so
# the user's statusline isn't blank. Statusline rendering is not a place
# to fail loudly.

set -u

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
WRAPPED_FILE="$STATE_DIR/wrapped-statusline.json"
ENABLED_FLAG="$STATE_DIR/statusline-enabled"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEGMENT_SH="$SCRIPT_DIR/statusline-segment.sh"

# Lazily refresh the segment symlink in $STATE_DIR so direct shell-out
# users (~/.claude/llm-tutor/statusline-segment.sh, the path documented
# in the statusline guide) always see the current cache version's
# segment renderer — not whatever cache version happened to be active
# when /tutor-statusline-install last ran. One readlink + string compare
# per render; the ln -sf only runs when the target has actually drifted.
SEGMENT_SYMLINK="$STATE_DIR/statusline-segment.sh"
if [ -L "$SEGMENT_SYMLINK" ]; then
  current_target=$(readlink "$SEGMENT_SYMLINK" 2>/dev/null)
  if [ "$current_target" != "$SEGMENT_SH" ]; then
    ln -sf "$SEGMENT_SH" "$SEGMENT_SYMLINK" 2>/dev/null
  fi
fi

# Read stdin once; we may need to feed it to the original command.
stdin_buf=$(cat)

# --- run the wrapped original command (if any) ---
original_output=""
if [ -f "$WRAPPED_FILE" ] && command -v jq >/dev/null 2>&1; then
  original_cmd=$(jq -r '.command // empty' "$WRAPPED_FILE" 2>/dev/null)
  if [ -n "$original_cmd" ]; then
    # Re-feed the same stdin. The original command sees exactly what
    # Claude Code sent — it doesn't know it's being wrapped.
    original_output=$(printf "%s" "$stdin_buf" | bash -c "$original_cmd" 2>/dev/null || printf "")
  fi
fi

# --- decide whether to append our segment ---
append_segment=true
[ -f "$ENABLED_FLAG" ] || append_segment=false

# Extract the active output style from Claude Code's status JSON. When the
# user has picked Echo / Cipher / Vex via /config → Output style, the
# segment renders in that persona's signature color. Anything else (or no
# selection) falls back to a neutral instructor color. We accept all four
# field-name variants Claude Code has shipped over time.
persona=""
if command -v jq >/dev/null 2>&1; then
  persona=$(printf "%s" "$stdin_buf" | jq -r '
    .output_style.name // .output_style //
    .outputStyle.name  // .outputStyle  //
    ""
  ' 2>/dev/null || printf "")
fi

segment=""
if $append_segment && [ -x "$SEGMENT_SH" ]; then
  # When we have original output to append our segment beneath, signal the
  # segment renderer to emit a dim full-width separator rule above its row.
  # That gives the eye a clear "section break" between the host statusline
  # and llm-tutor's content. Without an original to wrap, no rule is needed
  # (llm-tutor's row IS the entire statusline in that case).
  appended_flag=""
  [ -n "$original_output" ] && appended_flag="1"
  segment=$(LLM_TUTOR_PERSONA="$persona" LLM_TUTOR_APPENDED="$appended_flag" \
    bash "$SEGMENT_SH" 2>/dev/null || printf "")
fi

# --- combine ---
# When there's no original, emit just our segment (degrades to a
# llm-tutor-only statusline). When there's no segment, emit the original
# unchanged. When both are present, place our segment on a new row beneath
# the original so it never collides with the original layout regardless
# of how many rows the original uses.
if [ -n "$original_output" ] && [ -n "$segment" ]; then
  printf "%s\n%s" "$original_output" "$segment"
elif [ -n "$original_output" ]; then
  printf "%s" "$original_output"
elif [ -n "$segment" ]; then
  printf "%s" "$segment"
fi
